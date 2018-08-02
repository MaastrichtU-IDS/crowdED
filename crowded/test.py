"""-----------------------------------------------------------------------------
  Name: Iterate CrowdED
  Description: This class is meant to run the crowdsourcing algorithm and get the overall accuracy of certain experiment, it will return two output, the median and the proportion
  Created By:  Pedro V (p.hernandezserrano@maastrichtuniversity.nl.
  Date:        30/01/18
-----------------------------------------------------------------------------"""

import sys
import os
import pandas as pd
import numpy as np
import crowded.method as cr

# coding: utf-8

class Iterate(object):
    def __init__(self, variable):
        self.variable = variable

    def get_accuracy(self, total_tasks=100, total_workers=40, p_hard_t=0.1, p_good_w=0.9,
                     answers_key=["liver", "blood", "lung", "brain", "heart"],
                     p_train_t=0.4, workers_per_task=5):
        accuracy, proportion = [], []
        for i in range(5): #simulations
            sys.stdout = open(os.devnull, "w")
            try:
                algorithm = cr.Compute(total_tasks, total_workers, p_hard_t, p_good_w, answers_key, p_train_t, workers_per_task)
            except Exception:
                pass
            sys.stdout = sys.__stdout__
            proportion.append(algorithm.accuracy()[0])
            accuracy.append(algorithm.accuracy()[1])

        proportion = np.mean(proportion)
        accuracy = np.mean(accuracy)
        return accuracy, proportion


    def train_workers(self, max_value=100):
        results = []
        for idx, i in enumerate(np.arange(1, max_value, 1)):
            try:
                results.append((idx, self.get_accuracy(total_workers = i+1)))
            except Exception:
                pass
        return results

    def train_tasks(self, max_value=100):
        results = []
        for idx, i in enumerate(np.arange(1, max_value, 1)):
            try:
                results.append((idx, self.get_accuracy(total_tasks=i + 1)))
            except Exception:
                pass
        return results

    def train_workerspertask(self, max_value=100):
        results = []
        for idx, i in enumerate(np.arange(3, max_value, 2)):
            try:
                results.append((idx, self.get_accuracy(workers_per_task=i + 1)))
            except Exception:
                pass
        return results

    def train_proportion(self, max_value=1):
        results = []
        for idx, i in enumerate(np.arange(0, max_value, 0.01)):
            try:
                results.append((idx, self.get_accuracy(p_train_t = i + 0.1)))
            except Exception:
                pass
        return results

    def table(self, max_value=1, number_iterations = 1):
        simulations = []
        for k in range(number_iterations):
            if self.variable == 'total_workers':
                results = self.train_workers(max_value)
            elif self.variable == 'total_tasks':
                results = self.train_tasks(max_value)
            elif self.variable == 'workers_per_task':
                results = self.train_workerspertask(max_value)
            elif self.variable == 'p_train_t':
                results = self.train_proportion(max_value)
            else:
                print('Insert a correct variable name')
            simulations.append((k, results))

        df_simulations = pd.DataFrame()
        vec_variable, vec_accuracy, vec_simulation = [], [], []
        for i in simulations:
            for j in i[1]:
                vec_variable.append(j[0])
                vec_accuracy.append(j[1])
                vec_simulation.append(i[0])

        df_simulations[str(self.variable)] = vec_variable
        df_simulations['accuracy'] = vec_accuracy
        df_simulations['simulation'] = vec_simulation
        
        return df_simulations
