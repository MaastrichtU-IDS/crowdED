"""
Naive brute force simulations generator, use with care, could take too long
"""
import time; start_time = time.monotonic()
import sys
from datetime import datetime, timedelta
import crowded.simulate as cs
import crowded.method as cm
import crowded.make as mk
from pycm import *
import pandas as pd

#tasks = [60,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360,380,400]
tasks = [100,200,300,400,500,600,800,900,1000]
workers = [30,40,50,60,70,80,90,100]
#hard_t = [0, 0.2, 0.4, 0.6, 0.8, 1]
hard_t = [1]
prop = [0.2, 0.4, 0.6, 0.8]
wpt = [3, 5, 7, 9, 11, 13, 15]
key = [3, 5, 7, 11]
stg = 2

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


def simulate_scenarios(tasks, workers, hard_t, prop, wpt, key, stages=2):
    sim = _combinations(tasks, workers, hard_t, prop, wpt, key)
    for idx, row in enumerate(sim):
        mk._update_progress("CrowdED simulations progress", (idx + 1) / len(sim))
        try:
            if stages == 2:
                df = mk.crowd_table(total_tasks=sim[idx][0], total_workers=sim[idx][1], p_hard_tasks=sim[idx][2], ptt=sim[idx][3], wpt=sim[idx][4], nk=sim[idx][5])
            else:
                df = mk.crowd_table_one_stage(total_tasks=sim[idx][0], total_workers=sim[idx][1], p_hard_tasks=sim[idx][2], ptt=sim[idx][3], wpt=sim[idx][4], nk=sim[idx][5])
            mat = ConfusionMatrix(df['true_answers'].tolist(),df['worker_answers'].tolist())
            sim[idx].insert(6, round(mat.Overall_ACC, 4))
            sim[idx].insert(7, round(mat.CrossEntropy, 4))
            sim[idx].insert(8, round(sum([i for i in mat.F1.values()]) / len([i for i in mat.F1.values()]), 4))
        except Exception:
            pass
    return sim


simulations = pd.DataFrame(simulate_scenarios(tasks, workers, hard_t, prop, wpt, key, stg)).fillna(0)
simulations.columns = ['total_tasks', 'total_workers', 'proportion_hard_tasks','proportion_train_tasks', 'workers_per_task', 'total_keys','accuracy','cross_entropy','f1']
sttime = datetime.now().strftime('%Y%m%d_%H:%M_')
end_time = time.monotonic()
ex_time = timedelta(seconds=end_time - start_time)
simulations.to_csv('data/' + str(sttime) + 'simulations'+ str(stg)+ 'stg_execution_time_'+str(ex_time)+'.csv', index=False)
print("Simulations computed - Execution time: {}".format(ex_time))
