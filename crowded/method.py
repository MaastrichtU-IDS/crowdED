"""-----------------------------------------------------------------------------
  Name: Method CrowdED
  Description: This class aims to compute a conditional probability and simulate answers in a crowdsourcing experiment
  Created By:  Pedro V (p.hernandezserrano@maastrichtuniversity.nl)
  Date:        15/08/18
-----------------------------------------------------------------------------"""

import sys
import pandas as pd
import numpy as np
from scipy.stats import bernoulli

class ComputeProbability(object):
    def __init__(self, series1, series2, keys, size=1):
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
        return pd.Series([bernoulli.rvs(size=self.size, p=prob)[0] for prob in self._bayes_prob()])

class WorkerAnswer(object):
    def __init__(self, series1, series2, keys):
        """
        series1 = vector of true values correspondet to 1
        series2 = vector of 1 and 0
        key = vector of odd number of strings
        """
        self.series1 = series1
        self.series2 = series2
        self.keys = keys

    def match(self):
        answers = []
        for idx, i in enumerate(self.series1):
            if i == 1:
                answers.append(self.series2.loc[idx])
            else:
                answers.append(np.random.choice(
                    [i for i in set(self.keys) - set(self.series2.loc[idx])], 1)[0])

        return answers

IDX = 'worker_id'

class Performance(object):
    def __init__(self, df_tw):
        self.df_tw = df_tw

    def _agg(self):
        df = self.df_tw.groupby(IDX).agg('count')['task_id']
        df.name = 'tasks'
        return df

    def _workers(self):
        df = self.df_tw.groupby(self.df_tw[IDX]).mean(
        ).sort_values('performance', ascending=False)
        df['worker_hability'] = ['good_worker' if i ==
                                 1 else 'poor_worker' for i in df['performance']]
        return df.join(self._agg(), on=IDX, how='left')

    def good_workers(self):
        _good = self._workers()[(self._workers()['worker_hability'] == 'good_worker') & ((self._workers()[
            'prob_task'] < self._workers()['prob_task'].median()))]  # & ((df['tasks'] > df['tasks'].median()))]
        #print('Selected Good Workers: {}'.format(good_workers['performance'].sum()))
        return [i for i in _good.index]
