import sys
sys.path.insert(0, '/Users/pedrohserrano/crowdED/crowded')
import method as cr
import iterate as ci
import pandas as pd

tasks = [60, 80, 100, 120, 140, 160, 180]
workers = [20, 30, 40]
prop = [0.2, 0.3, 0.4, 0.5, 0.6]
wpt = [3, 5, 7, 9, 11]
answers_key = ["liver", "blood", "lung", "brain", "heart"]
hard_t = [0.1, 0.3, 0.5, 0.7, 0.9]
good_w = [0.1, 0.3, 0.5, 0.7, 0.9]

sim = []
for t in tasks:
    for w in workers:
        for p in prop:
            for x in wpt:
                for h in hard_t:
                    for g in good_w:
                        sim.append([t, w, p, x, h, g])
                #print(lista)
                #print (t, w, p, x, 'accu', 'prop')

for l in sim:
    try:
        accu, prop = ci.Iterate('test').get_accuracy(total_tasks=l[0], total_workers=l[1], p_hard_t=l[4], p_good_w=l[5], answers_key=["liver", "blood", "lung", "brain", "heart"], p_train_t=l[2], workers_per_task=l[3])
        l.insert(6, accu)
        l.insert(7, prop)
    except Exception:
        pass

        
#print(lista)

simulations = pd.DataFrame(sim)
print(simulations)
simulations.to_csv('simulations.csv')

#ci.Iterate('total_tasks').get_accuracy(t, w, p_hard_t, p_good_w, answers_key, p, x)
#for row in table:
#    calculate accuracy
