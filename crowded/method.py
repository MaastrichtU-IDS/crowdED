"""-----------------------------------------------------------------------------
  Name: Method CrowdED
  Description: This class aims to compute a conditional probability and simulate answers in a crowdsourcing experiment
  Created By:  Pedro V (p.hernandezserrano@maastrichtuniversity.nl)
  Last Update: 23/08/18
-----------------------------------------------------------------------------"""

import sys
import pandas as pd
import numpy as np
from scipy.stats import bernoulli, beta

class ComputeProbability(object):
    def __init__(self, series1, series2, keys, size=1):
        """
        :series1: vector of probabilities (tasks)
        :series2: vector of probabilities (workers)
        :key: vector of odd number of strings
        """
        self.size = size
        self.series1 = series1
        self.series2 = series2
        self.keys = keys

    def _random_selection(self):
        return 1 / len(self.keys)

    def _bayes_prob(self):
        if len(self.series1) != len(self.series2):
            raise Exception("Probability series expected to be the same size")
        return (self.series1 * self.series2) / (self.series1 * self.series2 + self._random_selection() * (1 - self.series2))

    def predict(self):
        return self._bayes_prob().apply(lambda prob: bernoulli.rvs(size=1, p=prob)[0])
    


class WorkerAnswer(object):
    def __init__(self, series1, series2, keys):
        """
        :series1: vector of true answers
        :series2: vector of 1 and 0
        :key: vector of odd number of strings
        """
        self.series1 = series1
        self.series2 = series2
        self.keys = keys

    def match(self):
        answers = []
        for idx, i in enumerate(self.series2):
            if i == 1:
                answers.append(self.series1.loc[idx])
            else:
                answers.append(np.random.choice([i for i in set(self.keys) - set(self.series1.loc[idx])], 1)[0])

        return answers


IDX = 'worker_id'

class Performance(object):
    def __init__(self, df_tw):
        """
        :df_tw: dataframe of assigned tasks to workers
        """
        self.df_tw = df_tw

    def _agg(self):
        df = self.df_tw.groupby(IDX).agg('count')['task_id']
        df.index.name = 'tasks'
        return df

    def _workers(self):
        df = self.df_tw.groupby(self.df_tw[IDX]).mean(
        ).sort_values('performance', ascending=False)
        df['worker_ability'] = ['good_worker' if i >= df['performance'].mean() else 'poor_worker' for i in df['performance']]
        #df['worker_ability'] = ['good_worker' if i == 1 else 'poor_worker' for i in df['performance']]
        return df.reset_index().join(self._agg(), on=IDX, how='left')

    def good_workers(self):
        _good = self._workers()[(self._workers()['worker_ability'] == 'good_worker') & (
            (self._workers()['prob_task'] < self._workers()['prob_task'].median()))]
        return [i for i in _good[IDX]]

    def trained_workers(self):
        _w = self._workers()
        _w.index = _w['worker_id']
        dfw = _w.loc[self.good_workers()]
        dfw['alpha'] = round(dfw['performance'] * dfw['task_id'], 0)
        dfw['beta'] = dfw['task_id'] - dfw['alpha']
        dfw['alpha'] = [int(i + 28) for i in dfw['alpha']]
        dfw['beta'] = 1#[int(i + 1) for i in dfw['beta']]
        df = pd.DataFrame(
            {'worker_id': self.good_workers(),
             'prob_worker': [beta.rvs(a, b, size=1)[0] for a, b in zip(dfw['alpha'], dfw['beta'])]})
        df.index = df['worker_id']
        df.index.name = 'id'
        return df
