import time, sys
sys.path.insert(0, '/Users/pedrohserrano/crowdED/crowded')
import simulate as cs
import method as cm

PTT = .3

def tasks_split(df, p=PTT):
    _train = df.sample(frac=p, random_state=23)
    _rest = df.loc[df.index.difference(_train.index)]
    return _train, _rest


def crowd_table(total_tasks=100, total_workers=30, p_hard_tasks=0.4, PTT=.3, wpt=5, NK=5):
    df_tasks = cs.Tasks(NK).create(total_tasks, p_hard_tasks)
    workers = cs.Workers().create(total_workers)
    keys = df_tasks['true_answers'].unique()
    tasks_train, tasks_rest = tasks_split(df_tasks, PTT)
    df_tw = cs.AssignTasks(tasks_train, workers, wpt).create()
    cp = cm.ComputeProbability(df_tw['prob_task'], df_tw['prob_worker'], keys)
    df_tw['worker_answers'] = cm.WorkerAnswer(
        cp.predict(), df_tw['true_answers'], keys).match()
    df_tw['performance'] = cp.predict()
    perf = cm.Performance(df_tw)
    good_workers = workers.loc[perf.good_workers()]
    df_tw_2 = cs.AssignTasks(tasks_rest, good_workers, wpt).create()
    cp2 = cm.ComputeProbability(
        df_tw_2['prob_task'], df_tw_2['prob_worker'], keys)
    df_tw_2['worker_answers'] = cm.WorkerAnswer(
        cp2.predict(), df_tw_2['true_answers'], keys).match()
    df_tw_2['performance'] = cp2.predict()
    df = df_tw.append(df_tw_2)
    return df


def update_progress(job_title, progress):
    length = 20  
    block = int(round(length * progress))
    msg = "\r{0}: [{1}] {2}%".format(
        job_title, "#" * block + "-" * (length - block), round(progress * 100, 2))
    if progress >= 1:
        msg += " DONE\r\n"
    sys.stdout.write(msg)
    sys.stdout.flush()
