import sys
import numpy as np
import pandas as pd
import shortuuid as uid
from random_words import RandomWords
from scipy.stats import beta

KEYS = 7
HARD = 0.2
WPT = 3
LEN = 6
N = 10
a = 5
b = 1



class Tasks(object):
    def __init__(self, keys=KEYS, length=LEN):
        self.length = length
        self.keys = keys

    def _generate_tasks(self, n=N):
        return ['task_' + uid.ShortUUID().random(length=self.length) for i in range(n)]

    def _random_words(self):
        key = RandomWords().random_words(count=self.keys)
        #print('Generated Random Key: {}\n'.format(key))
        return key

    def _true_answer(self, n=N):
        return [answer for answer in np.random.choice(self._random_words(), n)]

    def create(self, n=N, h=HARD):
        e = 1 - h
        # ; print('Percentage of Hard Tasks: {}'.format(HARD))
        cut_tasks = 0.75
        tasks = self._generate_tasks(n)
        probs_tasks = []
        easy_tasks = [task for task in np.random.choice(
            tasks, int(round(e * n, 0)), replace=False)]
        hard_tasks = [task for task in set(tasks) - set(easy_tasks)]
        df = pd.DataFrame()
        #df['task_id'] = tasks
        df['true_answers'] = self._true_answer(n)
        df.index = tasks
        df['label_task'] = ['hard_task' if tasks[i]
                            in hard_tasks else 'easy_task' for i in range(n)]
        for i in df['label_task']:
            if i == 'easy_task':  # uniform from .75 to 1
                # a random number form cut to 1
                probs_tasks.append(np.random.choice(
                    (np.arange(cut_tasks, 1, 0.01)), 1))
            elif i == 'hard_task':  # uniform from .5 to .75
                # a random number form chance to cut
                probs_tasks.append(np.random.choice(
                    (np.arange(0.5, cut_tasks, 0.01)), 1))
            else:
                probs_tasks.append(1)

        df['prob_task'] = [item for prob in probs_tasks for item in prob]
        return df




class Workers(object):
    def __init__(self, alpha=a, beta=b, length=LEN):
        self.length = length
        self.alpha = alpha
        self.beta = beta

    def create(self, n=N):
        df = pd.DataFrame(
            {'prob_worker': beta.rvs(self.alpha, self.beta, size=n)})
        df.index = [uid.ShortUUID().random(self.length) for i in range(n)]
        return df




class AssignTasks(object):
    def __init__(self, tasks, workers, wpt=WPT):
        self.wpt = wpt
        self.tasks = tasks
        self.workers = workers

    def _worker_assign(self):
        if self.wpt > len(self.workers):
            raise Exception(
                'Number of workers per task must be smaller than the number of workers!')
        return [worker for i in [np.random.choice(self.workers.index, self.wpt, replace=False) for task in self.tasks.index] for worker in i]

    def _task_asssign(self):
        if self.wpt % 2 == 0:
            raise Exception('Number of workers per task must be odd!')
        return [item for k in [[self.tasks.index[i]] * self.wpt for i in range(len(self.tasks.index))] for item in k]

    def create(self):
        df = pd.DataFrame({'task_id': self._task_asssign(),
                           'worker_id': self._worker_assign()})
        df = pd.merge(df, self.tasks, left_on='task_id',
                      right_index=True, how='left')
        df = pd.merge(df, self.workers, left_on='worker_id',
                      right_index=True, how='left')
        return df
