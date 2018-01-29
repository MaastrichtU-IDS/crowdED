import sys
import os
import numpy as np
import crowded.method as cr

def get_accuracy(total_tasks=100, total_workers=40, p_hard_t=0.1, p_good_w=0.9,
                     answers_key=["liver", "blood", "lung", "brain", "heart"],
                     p_train_t=0.4, workers_per_task=5):
        accuracy = []
        for i in range (10):
            sys.stdout = open(os.devnull, "w")
            algorithm = cr.Compute(total_tasks, total_workers, p_hard_t, p_good_w, answers_key, p_train_t, workers_per_task)
            sys.stdout = sys.__stdout__
            accuracy.append(algorithm.accuracy()[1])

        accuracy = np.mean(accuracy)
        return accuracy


print(get_accuracy())
