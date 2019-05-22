"""-----------------------------------------------------------------------------
  Name: Simulate CrowdED
  Description: This class aims to simulate dummy tasks and workers and its assignation following statistical Bayesian approach
  Created By:  Pedro V (p.hernandezserrano@maastrichtuniversity.nl)
  Date:        23/08/18
-----------------------------------------------------------------------------"""

import sys
import numpy as np
import pandas as pd
import shortuuid as uid
from scipy.stats import beta
import crowded.key_words as kw

KEYS = 7
HARD = 1
WPT = 3
LEN = 12 #Default parameter for the lenght of the unique identifier generated
N = 10
#Default values means the number of succes and fails in the beta distribution is uniform
a = 7.6
b = 3.3

class Tasks(object):
    def __init__(self, keys=KEYS, length=LEN):
        """
        :param keys: number of valid answers expected to be assessed
        :type keys: python list or numpy array of any stringable objects
        :param length: length of the identifier
        :type length: int
        """
        self.length = length
        self.keys = keys

    def _generate_tasks(self, n=N):
        """
        :param n: number of tasks to be generated (default value: 10)
        :type n: int
        """
        return ['task_' + uid.ShortUUID().random(length=self.length) for i in range(n)]

    def _random_words(self):
        return [i for i in np.random.choice(kw.words(), self.keys, replace=False)]

    def _true_answer(self, n=N):
        """
        :param n: number of true answers to be generated (default value: 10)
        :type n: int
        """
        return [answer for answer in np.random.choice(self._random_words(), n)]

    def create(self, n=N, h=HARD):
        """
        :param n: number of tasks to be generated (default value: 10)
        :type n: int
        :param h: proportion of hard tasks a priori selected for the experiment (default value: 0.2)
        :type h: float
        """
        e = 1 - h
        cut_tasks = 0.5
        tasks = self._generate_tasks(n)
        probs_tasks = []
        easy_tasks = [task for task in np.random.choice(
            tasks, int(round(e * n, 0)), replace=False)]
        hard_tasks = [task for task in set(tasks) - set(easy_tasks)]
        df = pd.DataFrame()
        df['task_id'] = tasks
        df['true_answers'] = self._true_answer(n)
        df['label_task'] = ['hard_task' if tasks[i]
                            in hard_tasks else 'easy_task' for i in range(n)]
        for i in df['label_task']:
            if i == 'easy_task':  # uniform from .5 to 1
                probs_tasks.append(np.random.choice(
                    (np.arange(cut_tasks, 1, 0.01)), 1))
            elif i == 'hard_task':  # uniform from .0 to .5
                probs_tasks.append(np.random.choice(
                    (np.arange(0.01, cut_tasks, 0.01)), 1))
            else:
                probs_tasks.append(1)

        df['prob_task'] = [item for prob in probs_tasks for item in prob]
        df.index = df['task_id']
        df.index.name = 'id'
        return df


class Workers(object):
    def __init__(self, alpha=a, beta=b, length=LEN):
        """
        :param alpha: parameter alpha of a beta distribution (default value: 28)
        :type alpha: float
        :param beta: parameter beta of a beta distribution (default value: 3)
        :type beta: float
        :param length: number of workers to be created (default value:10)
        :type length: type
        """
        self.length = length
        self.alpha = alpha
        self.beta = beta

    def create(self, n=N):
        df = pd.DataFrame(
            {'worker_id': [uid.ShortUUID().random(self.length) for i in range(n)],
             'prob_worker': beta.rvs(self.alpha, self.beta, size=n)})
        df.index = df['worker_id']
        df.index.name = 'id'
        return df


class AssignTasks(object):
    def __init__(self, tasks, workers, wpt=WPT):
        """
        :param tasks: table created usings Tasks().create() object
        :type tasks: pandas dataframe
        :param workers: table created using Workers().create object
        :type workers: pandas dataframe
        :param wpt: number of workers per task for the simulation
        "param type: integer
        """
        self.wpt = wpt
        self.tasks = tasks
        self.workers = workers

    def _worker_assign(self):
        if self.wpt > len(self.workers):
            raise Exception(
                'Number of workers per task must be smaller than the number of workers. Please re-run')
        return [worker for i in [np.random.choice(self.workers.index, self.wpt, replace=False) for task in self.tasks.index] for worker in i]

    def _task_asssign(self):
        if self.wpt % 2 == 0:
            raise Exception('Number of workers per task must be odd. Please re-run')
        return [item for k in [[self.tasks.index[i]] * self.wpt for i in range(len(self.tasks.index))] for item in k]

    def create(self):
        df = pd.DataFrame({'task_id': self._task_asssign(),
                           'worker_id': self._worker_assign()})
        df = pd.merge(df, self.tasks, on='task_id', how='left')
        df = pd.merge(df, self.workers, on='worker_id', how='left')
        return df
