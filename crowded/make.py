"""-----------------------------------------------------------------------------
  Name: Make CrowdED
  Description: This class aims to simulate the whole pipeline within different scenarios
  Created By:  Pedro V (p.hernandezserrano@maastrichtuniversity.nl)
  Last Update: 23/08/18
-----------------------------------------------------------------------------"""

import time, sys
import crowded.simulate as cs
import crowded.method as cm

PTT = .3

def tasks_split(df, p=PTT):
    _train = df.sample(frac=p, random_state=23)
    _rest = df.loc[df.index.difference(_train.index)]
    return _train, _rest

def _update_progress(job_title, progress):
    length = 20
    block = int(round(length * progress))
    msg = "\r{0}: [{1}] {2}%".format(
        job_title, "#" * block + "-" * (length - block), round(progress * 100, 2))
    if progress >= 1:
        msg += " DONE\r\n"
    sys.stdout.write(msg)
    sys.stdout.flush()


def crowd_table(total_tasks=100, total_workers=30, p_hard_tasks=1, ptt=.3, wpt=5, nk=5, a=7.6, b=3.3):
    #Defining the experiment parameters
    df_tasks = cs.Tasks(nk).create(total_tasks, p_hard_tasks)
    workers = cs.Workers(a, b).create(total_workers)
    keys = df_tasks['true_answers'].unique()
    tasks_train, tasks_rest = tasks_split(df_tasks, ptt)
    #Compute Method for Training set
    df_tw = cs.AssignTasks(tasks_train, workers, wpt).create()
    cp = cm.ComputeProbability(df_tw['prob_task'], df_tw['prob_worker'], keys)
    df_tw['worker_answers'] = cm.WorkerAnswer(
        df_tw['true_answers'], cp.predict(), keys).match()
    df_tw['performance'] = cp.predict()
    #Select the good workers from training phase
    perf = cm.Performance(df_tw)
    trained_workers = perf.trained_workers()
    #Compute Method for the rest of the set
    df_tw_2 = cs.AssignTasks(tasks_rest, trained_workers, wpt).create()
    cp2 = cm.ComputeProbability(
        df_tw_2['prob_task'], df_tw_2['prob_worker'], keys)
    df_tw_2['worker_answers'] = cm.WorkerAnswer(
        df_tw_2['true_answers'], cp2.predict(), keys).match()
    df_tw_2['performance'] = cp2.predict()
    #Append two sets in one final set
    df = df_tw.append(df_tw_2)
    return df

def crowd_table_one_stage(total_tasks=100, total_workers=30, p_hard_tasks=1, ptt=.3, wpt=5, nk=5, a=7.6, b=3.3):
    #Defining the experiment parameters
    df_tasks = cs.Tasks(nk).create(total_tasks, p_hard_tasks)
    workers = cs.Workers(a, b).create(total_workers)
    keys = df_tasks['true_answers'].unique()
    #Compute Method
    df_tw = cs.AssignTasks(df_tasks, workers, wpt).create()
    cp = cm.ComputeProbability(df_tw['prob_task'], df_tw['prob_worker'], keys)
    df_tw['worker_answers'] = cm.WorkerAnswer(
        df_tw['true_answers'], cp.predict(), keys).match()
    df_tw['performance'] = cp.predict()
    return df_tw


