"""
Naive brute force simulations generator, use with care, could take too long
"""
import crowded.method as cr
import crowded.iterate as ci
import pandas as pd

tasks = [100]#[60, 80, 100, 120]
workers = [30, 40]
prop = [0.5, 0.6]
wpt = [3, 5, 7]
answers_key = ["liver", "blood", "lung", "brain", "heart"]
hard_t = [0.2]#[0.2, 0.4, 0.6, 0.8]
good_w = [0.9]

sim = []
for t in tasks:
    for w in workers:
        for p in prop:
            for x in wpt:
                for h in hard_t:
                    for g in good_w:
                        sim.append([t, w, p, x, h, g])

for l in sim:
    try:
        accu, prop = ci.Iterate('all_variables').get_accuracy(
            total_tasks=l[0], total_workers=l[1], p_hard_t=l[4], p_good_w=l[5], answers_key=answers_key, p_train_t=l[2], workers_per_task=l[3])
        l.insert(6, accu)
        l.insert(7, prop)
    except Exception:
        pass

simulations = pd.DataFrame(sim)
simulations.to_csv('data/df_simulations.csv')
