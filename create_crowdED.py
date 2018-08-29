"""
Naive brute force simulations generator, use with care, could take too long
"""
import sys
from datetime import datetime
import crowded.simulate as cs
import crowded.method as cm
import crowded.make as mk
from pycm import *
import pandas as pd

tasks = [i for i in range(500)]
workers = [i for i in range(500)]
hard_t = [i / 100 for i in range(100)]
prop = [i / 100 for i in range(100)]
wpt = [i for i in range(20) if i % 2 == 1]
key = [i for i in range(20) if i % 2 == 1]
alpha = [i for i in range(20)]
#5,000,000,000,000

def _combinations(tasks, workers, hard_t, prop, wpt, key, alpha):
    table = []
    for t in tasks:
        for w in workers:
            for h in hard_t:
                for p in prop:
                    for x in wpt:
                        for k in key:
                            for a in alpha:
                                table.append([t, w, h, p, x, k, a])
    return table


def get_accuracy(tasks, workers, hard_t, prop, wpt, key, alpha):
    sim = _combinations(tasks, workers, hard_t, prop, wpt, key, alpha)
    for idx, l in enumerate(sim):
        mk._update_progress("CrowdED simulation", idx / len(sim))
        try:
            df = mk.crowd_table(total_tasks=l[0], total_workers=l[1], p_hard_tasks=l[2], ptt=l[3], wpt=l[4], nk=l[5], a=l[6])
            mat = ConfusionMatrix(df['true_answers'].tolist(), df['worker_answers'].tolist())
            l.insert(7, round(mat.Overall_ACC, 4))
        except Exception:
            pass
    return sim


simulations = pd.DataFrame(get_accuracy(
    tasks, workers, hard_t, prop, wpt, key, alpha)).fillna(0)
simulations.columns = ['total_tasks', 'total_workers', 'proportion_hard_tasks','proportion_train_tasks', 'workers_per_task', 'total_keys','alpha', 'accuracy']
sttime = datetime.now().strftime('%Y%m%d_%H:%M - ')

simulations.to_csv('data/' + str(sttime)+'simulations.csv', index=False)
