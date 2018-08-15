"""
Naive brute force simulations generator, use with care, could take too long
"""
#import crowded.method as cr
#import crowded.iterate as ci
import sys
sys.path.insert(0, '/Users/pedrohserrano/crowdED/crowded')
import simulate as cs
import method as cm
from pycm import *
from datetime import datetime
import make
import pandas as pd

tasks = [60, 80, 100, 120, 140]
workers = [30, 40]
hard_t = [0.2, 0.4, 0.6, 0.8]
prop = [0.4, 0.6]
wpt = [3, 5, 7]
key = [3, 5, 7]


def _combinations(tasks, workers, hard_t, prop, wpt, key):
    table = []
    for t in tasks:
        for w in workers:
            for h in hard_t:
                for p in prop:
                    for x in wpt:
                        for k in key:
                            table.append([t, w, h, p, x, k])
    return table


def get_accuracy(tasks, workers, hard_t, prop, wpt, key):
    sim = _combinations(tasks, workers, hard_t, prop, wpt, key)
    for idx, l in enumerate(sim):
        make.update_progress("CrowdED simulation", idx / len(sim))
        try:
            df = make.crowd_table(total_tasks=l[0], total_workers=l[1], p_hard_tasks=l[2], PTT=l[3], wpt=l[4], NK=l[5])
            mat = ConfusionMatrix(df['true_answers'].tolist(), df['worker_answers'].tolist())
            l.insert(6, round(mat.Overall_ACC, 4))
        except Exception:
            pass
    return sim


simulations = pd.DataFrame(get_accuracy(
    tasks, workers, hard_t, prop, wpt, key)).fillna(0)
simulations.columns = ['total_tasks', 'total_workers', 'proportion_hard_tasks','proportion_train_tasks', 'workers_per_task', 'total_keys', 'accuracy']
sttime = datetime.now().strftime('%Y%m%d_%H:%M - ')
simulations.to_csv('data/' + str(sttime)+'simulations.csv', index=False)
