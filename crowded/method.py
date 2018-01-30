"""-----------------------------------------------------------------------------
  Name: Method CrowdED
  Description: This class contains the function that calculates the accuracy of consensus in a crowdsourcing problem, in addition, creates the summary data frame for workers and tasks
  Created By:  Pedro V (p.hernandezserrano@maastrichtuniversity.nl.
  Date:        30/01/18
-----------------------------------------------------------------------------"""

import uuid as ui
import pandas as pd
import numpy as np

# coding: utf-8

class Compute(object):
    def __init__(self, total_tasks, total_workers, p_hard_tasks, p_good_workers, answers_key, p_train_tasks, workers_per_task):
        self.total_tasks = total_tasks
        self.total_workers = total_workers
        self.p_hard_tasks = float(p_hard_tasks)
        self.p_good_workers = float(p_good_workers)
        self.answers_key = answers_key
        self.p_train_tasks = float(p_train_tasks)
        self.workers_per_task = workers_per_task
        
    def accuracy(self):

        n_hard_tasks = int(round(self.p_hard_tasks * self.total_tasks, 0))
        p_easy_tasks = 1 - self.p_hard_tasks
        n_easy_tasks = int(round(p_easy_tasks * self.total_tasks, 0))

        n_good_workers = int(round(self.p_good_workers * self.total_workers, 0))
        p_poor_workers = 1 - self.p_good_workers
        n_poor_workers = int(round(p_poor_workers * self.total_workers, 0))
        
        # Workers random choice normal distribuited
        workers = ['worker_' + str(ui.uuid4())[:4] for i in range(self.total_workers)]
        poor_workers = [worker for worker in np.random.choice(workers, n_poor_workers, replace=False)]
        good_workers = [worker for worker in set(workers) - set(poor_workers)]

        # Creating the workers dataframe
        df_workers = pd.DataFrame()
        df_workers['worker_id'] = workers

        label_worker = ['good_worker' if workers[i]in good_workers else 'poor_worker' for i in range(self.total_workers)]
        df_workers['label_worker'] = label_worker

        # Tasks simulatiom
        tasks = ['task_' + str(ui.uuid4())[:4] for i in range(self.total_tasks)]
        easy_tasks = [task for task in np.random.choice(tasks, n_easy_tasks, replace=False)]
        hard_tasks = [task for task in set(tasks) - set(easy_tasks)]

        print('Tasks Answers: {}'.format(self.answers_key))
        true_answers = [answer for answer in np.random.choice(self.answers_key, self.total_tasks)]
        df_tasks = pd.DataFrame()
        df_tasks['task_id'] = tasks
        df_tasks['true_answers'] = true_answers

        label_task = ['hard_task' if tasks[i] in hard_tasks else 'easy_task' for i in range(self.total_tasks)]
        df_tasks['label_task'] = label_task


        # ----------------------------------------- Probability to Respond -----------------------------------------
        cut_tasks = 0.75
        cut_workers = 0.75

        probs_tasks = []
        for i in label_task:
            if i == 'easy_task':
                # a random number form cut to 1
                probs_tasks.append(np.random.choice((np.arange(cut_tasks, 1, 0.01)), 1))
            elif i == 'hard_task':
                # a random number form chance to cut
                probs_tasks.append(np.random.choice((np.arange(0.5, cut_tasks, 0.01)), 1))
            else:
                probs_tasks.append(1)

        probs_tasks = [item for prob in probs_tasks for item in prob]

        probs_workers = []
        for i in label_worker:
            if i == 'good_worker':
                # a random number form cut to 1
                probs_workers.append(np.random.choice((np.arange(cut_workers, 1, 0.01)), 1))
            elif i == 'poor_worker':
                # a random number form chance to 1
                probs_workers.append(np.random.choice((np.arange(0.5, cut_workers, 0.01)), 1))
            else:
                probs_workers.append(1)

        probs_workers = [item for prob in probs_workers for item in prob]

        df_workers['prob_worker'] = probs_workers
        df_tasks['prob_task'] = probs_tasks


        # ----------------------------------------- Stage 1 -----------------------------------------

        tasks_to_train = int(self.p_train_tasks * self.total_tasks)
        print('Tasks to train: {}'.format(tasks_to_train))

        # Take randomly the number of tasks to train the workers
        training_tasks = np.random.choice(tasks, tasks_to_train, replace=False)

        # replicate the tasks to train
        list_tasks1 = [[training_tasks[i]] * self.workers_per_task for i in range(tasks_to_train)]
        # flat and clean list
        list_tasks1 = [item for sublist in list_tasks1 for item in sublist]

        # Asign workers on every task (we're assuming the tasks are ordered)
        tasks_workers1 = [np.random.choice(workers, self.workers_per_task, replace=False) for task in training_tasks]
        # flat and clean list
        tasks_workers1 = [worker for sublist in tasks_workers1 for worker in sublist]

        temp_frame = pd.DataFrame()
        temp_frame['task_id'] = list_tasks1
        temp_frame['worker_id'] = tasks_workers1

        workers_agg = temp_frame.groupby('worker_id').agg('count')
        workers_agg.sort_values('task_id', ascending=False)
        num_workers_trained = len(workers_agg.reset_index())
        print('Workers Trained: {}'.format(num_workers_trained))

        # Merge the datasets stage 1
        temp_frame1 = pd.merge(temp_frame, df_tasks, on='task_id', how='left')
        df_tw1 = pd.merge(temp_frame1, df_workers, on='worker_id', how='left')

        #Probability to asnwer correct
        df_tw1['prob_answer'] = 1 - (df_tw1['prob_worker'] * (1 - df_tw1['prob_task']))

        # We want to get where is the position of the real_answer column on the answer_key array
        positions = []
        for answer in df_tw1['true_answers']:
            for k in range(len(self.answers_key)):
                if self.answers_key[k] == answer:
                    positions.append(k)

        # Assign a vector of probabilities depending on the position of the item on anser_key array
        list_vect_probs = []
        for p in df_tw1['prob_answer']:
            for i in positions:
                vec_probs = [(1 - p) / (len(self.answers_key) - 1)] * (len(self.answers_key) - 1)
                vec_probs.insert(i, p)  # insert place, value
            list_vect_probs.append(vec_probs)

        #"Predict" every answer
        worker_answers = []
        for vec in list_vect_probs:
            worker_answers.append(np.random.choice(self.answers_key, 1, p=vec))

        worker_answers = [item for answer in worker_answers for item in answer]
        df_tw1['worker_answers'] = worker_answers

        #We match the real answers with worker answers
        vec_matches = df_tw1['worker_answers'] == df_tw1['true_answers']
        predict_value = [1 if i == True else 0 for i in vec_matches]
        df_tw1['performance'] = predict_value

        # ----------------------------------------- Measuring Performance -----------------------------------------

        cutoff_task = 0.5  # More than 50% of consensus

        tasks_mean1 = df_tw1.groupby('task_id').mean().sort_values('performance', ascending=False)
        first_tasks = tasks_mean1[tasks_mean1['performance'] >= cutoff_task]['performance']

        # - Trained Workers
        workers_mean1 = df_tw1.groupby('worker_id').mean().sort_values('performance', ascending=False)
        df_workers = pd.merge(workers_mean1.reset_index(), df_workers.drop('prob_worker', 1), on='worker_id', how='left')

        # - prob_task: Average of difficulty of the tasks asigned to the workers, this measure should be close each other in order to make the metrics equivalent
        # - prob_worker: Prob to score correct
        # - prob_answer: Combined probability of score and task difficulty
        # - performance: Percentage of the times the worker score correct
        #print('Workers Performance Summary: \n{}'.format(df_workers.describe()))

        cutoff_prob = df_workers['prob_worker'].quantile(.5)
        cutoff_perf = df_workers['performance'].quantile(.5)
        print('Cutoff: \n Performance: {} \n Probability: {}'.format(round(cutoff_perf, 3), round(cutoff_prob, 3)))

        # ----------------------------------------- Stage 2 - Best workers -----------------------------------------

        # We are going take only the best workers, it means high probability and high performance, above certain percentile.
        list_perf = [1 if i > cutoff_perf else 0 for i in df_workers['performance']]
        list_prob = [1 if i > cutoff_prob else 0 for i in df_workers['prob_worker']]

        flag_best_workers = []
        for i in range(len(list_perf)):
            if list_perf[i] == 1 and list_prob[i] == 1:  # we need to be strict here
                flag_best_workers.append(1)
            else:
                flag_best_workers.append(0)

        print('Selected Best Workers: {}'.format(sum(flag_best_workers)))

        df_workers['best_worker'] = flag_best_workers
        df_workers2 = df_workers[df_workers['best_worker'] == 1]
        # But we want to "reset" them:
        df_workers2 = df_workers2[['worker_id', 'prob_worker', 'label_worker']]
        best_workers = [i for i in df_workers2['worker_id']]

        # - Now we take the tasks that we decide were already difficult
        # - Then we're going to add them in the df_tasks that we did not use
        # - This "rest" of the tasks remain are going to be performed for our final workers
        tasks_mean1 = tasks_mean1.reset_index()
        list_done_tasks = [
            1 if i > cutoff_task else 0 for i in tasks_mean1['performance']]

        tasks_mean1['done_task'] = list_done_tasks
        #All those with value 1 is because was good consensus, so we don't need them to evaluate again
        done_tasks = tasks_mean1[tasks_mean1['done_task'] == 1]['task_id']
        done_tasks = [i for i in done_tasks]


        print('Number of donde Tasks in Stage 1: {}'.format(len(done_tasks)))
        # Take all the rest of the tasks excluding those that already we have concensus
        # This is the number we want to evaluate in stage 2
        df_tasks2 = df_tasks[~df_tasks['task_id'].isin(done_tasks)]
        print('Original Tasks: {} \nRemain Tasks for Stage 2: {}'.format(len(df_tasks), len(df_tasks2)))

        # ----------------------------------------- Stage 2 - Task Assignation -----------------------------------------
        # Before we assigne the best workers to the rest of the tasks we have to be sure that the workers dont responde the same task
        # All the tasks done for the best workers and is not in the list of tasks already done
        tasks_redo = df_tw1[~df_tw1['task_id'].isin(done_tasks)]
        tasks_redo = tasks_redo.reset_index()
        tasks_redo_unique = tasks_redo['task_id'].unique()
        tasks_redo_unique = [i for i in tasks_redo_unique]

        # ** Check Groups: ** All the trained and consensus tasks + All the tasks already done = Trained Tasks
        print(' Matching Tasks Value: {}'.format(len(tasks_redo_unique) == tasks_to_train))

        # we should take in account that there is a low chance that the worker repat the task
        tasks_workers2 = []
        for i in tasks_redo_unique:
            # show the worker id of every task
            each = [i for i in tasks_redo[tasks_redo['task_id']== str(i)]['worker_id']]
            # select all those not did the task before
            rest_workers = [worker for worker in set(best_workers) - set(each)]
            if len(rest_workers) > self.workers_per_task:
                tasks_workers2.append(np.random.choice(
                    rest_workers, self.workers_per_task, replace=False))
            else:
                tasks_workers2.append(np.random.choice(rest_workers, self.workers_per_task))

        # flat and clean list
        tasks_workers2 = [worker for sublist in tasks_workers2 for worker in sublist]

        list_tasks2 = [[tasks_redo_unique[i]] * self.workers_per_task for i in range(len(tasks_redo_unique))]  
        list_tasks2 = [item for sublist in list_tasks2 for item in sublist]

        temp_frame1 = pd.DataFrame()
        temp_frame1['task_id'] = list_tasks2
        temp_frame1['worker_id'] = tasks_workers2
        # - **Tasks Un-done**
        tasks_undone_unique = df_tasks[~df_tasks['task_id'].isin(training_tasks)]['task_id']
        tasks_undone_unique = [i for i in tasks_undone_unique]
        # ** Check Groups: ** Tasks re-do unique + Tasks un-done unique = df_tasks2
        print('Final Stage\n Tasks Re-do: {} \n Tasks Not Done: {}'.format(len(tasks_redo_unique), len(tasks_undone_unique)))

        tasks_workers3 = []
        for i in tasks_undone_unique:
            tasks_workers3.append(np.random.choice(best_workers, self.workers_per_task, replace=False))
            
        # flat and clean list
        tasks_workers3 = [worker for sublist in tasks_workers3 for worker in sublist]

        list_tasks3 = [[tasks_undone_unique[i]] * self.workers_per_task for i in range(
            len(tasks_undone_unique))]  # replicate the tasks to train
        # flat and clean list
        list_tasks3 = [item for sublist in list_tasks3 for item in sublist]

        temp_frame2 = pd.DataFrame()
        temp_frame2['task_id'] = list_tasks3
        temp_frame2['worker_id'] = tasks_workers3

        # ----------------------------------------- Final Join -----------------------------------------

        temp_frame = temp_frame1.append(temp_frame2, ignore_index=True)
        print('Number of Tasks in Final Join: {}'.format(
            len(temp_frame['task_id'].unique())))

        temp_frame0 = pd.merge(temp_frame, df_tasks2, on='task_id', how='left')
        df_tw = pd.merge(temp_frame0, df_workers2, on='worker_id', how='left')

        #Probability to asnwer correct
        df_tw['prob_answer'] = 1 - (df_tw['prob_worker'] * (1 - df_tw['prob_task']))

        # We want to get where is the position of the real_answer column on the answer_key array
        positions = []
        for answer in df_tw['true_answers']:
            for k in range(len(self.answers_key)):
                if self.answers_key[k] == answer:
                    positions.append(k)

        # Assign a vector of probabilities depending on the position of the item on anser_key array
        list_vect_probs = []
        for p in df_tw['prob_answer']:
            for i in positions:
                vec_probs = [(1 - p) / (len(self.answers_key) - 1)] * (len(self.answers_key) - 1)
                vec_probs.insert(i, p)  # insert place, value
            list_vect_probs.append(vec_probs)

        #"Predict" every answer
        worker_answers = []
        for vec in list_vect_probs:
            worker_answers.append(np.random.choice(self.answers_key, 1, p=vec))

        worker_answers = [item for answer in worker_answers for item in answer]
        df_tw['worker_answers'] = worker_answers
        #We match the real answers with worker answers
        vec_matches = df_tw['worker_answers'] == df_tw['true_answers']
        predict_value = [1 if i == True else 0 for i in vec_matches]
        df_tw['performance'] = predict_value

        # ----------------------------------------- Final Results -----------------------------------------

        tasks_mean = df_tw.groupby('task_id').mean().sort_values('performance', ascending=False)
        final_tasks = tasks_mean[tasks_mean['performance'] >= cutoff_task]['performance']
        p_consensus = (len(final_tasks) + len(done_tasks)) / len(df_tasks)
        a_consensus = final_tasks.mean()
        #print('\n ==== Tasks under consensus  ==== \n {}'.format(final_tasks))
        print('\n ==== Results ==== \n')
        print('Hard Tasks: {} \nEasy Tasks: {}'.format(n_hard_tasks, n_easy_tasks))
        print('Good Workers: {} \nPoor Workers: {}'.format(n_good_workers, n_poor_workers))
        print('Number of Tasks under consensus      n = {}'.format(len(final_tasks)))        
        print('Proportion of Consensus              p = {}'.format(p_consensus))        
        print('Accuracy Consensus                   a = {}'.format(a_consensus))

        return p_consensus, a_consensus, final_tasks, df_tw
