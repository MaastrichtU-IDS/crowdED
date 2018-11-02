![](base/CrowdEDlogo8.png)

CrowdED: Guideline for designing optimal crowdsourcing experiments
====

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fpedrohserrano%2FcrowdED.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fpedrohserrano%2FcrowdED?ref=badge_shield)

CrowdED is a two-staged statistical guideline for optimal crowdsourcing experimental design in order to a-priori estimate optimal workers and tasks' assignment to obtain maximum accuracy on all tasks.

[CrowdApp](https://pedrohserrano.shinyapps.io/crowdapp/) Beta

## Installation


To install the package, please use the `pip` installation as follows:
```shell
pip install crowdED
```
    

Installing from source **(Optional)**
```shell
git clone https://github.com/MaastrichtU-IDS/crowdED.git
cd crowdED
pip install --editable ./
```

**Note:** currently, crowdED is only compatible with: **Python 3.6**.

## Examples

Create a synthetic dataset of tasks

You will need to run ```!pip install shortuuid```

```python
import crowded.simulate as cs

#define your parameters
total_tasks = 415
p_hard_tasks = 0.4
number_of_valid_answers = 3

#create task dataset
df_tasks = cs.Tasks(number_of_valid_answers).create(total_tasks, p_hard_tasks)
```

Create a synthetic dataset of workers

```python
import crowded.simulate as cs

#define your parameters
total_workers = 40
alpha = 28
beta = 2
#create task dataset
df_workers = cs.Workers(alpha, beta).create(total_workers)
```

Assign easily and fairly workers to tasks

```python
import crowded.simulate as cs

#workers per task should always be smaller than the number of workers
wpt = 5 
#create assignment
df_tw = cs.AssignTasks(df_tasks, df_workers, wpt).create()
```

Compute Bayes probability and predict worker answers 

```python
import crowded.method as cs

#workers per task should always be smaller than the number of workers
wpt = 5 
#create assignment
df_tw = cs.AssignTasks(df_tasks, df_workers, wpt).create()
```

Compute Bayes probability and Predict answers of the workers

```python
import crowded.method as cm

#define the parameters
x = df_tw['prob_task'] #vector of probabilities of tasks
y = df_tw['prob_worker'] #vector of probabilities of workers
z = df_tasks['true_answers'].unique()  #vector of valid answers in the experiment
#compute probability
cp = cm.ComputeProbability(x, y, z)
```

```python
import crowded.method as cm

#define the parameters
g = df_tw['true_answers'] #vector of gold standar answers
p = cp.predict() #binary vector of 0 and 1
z = df_tasks['true_answers'].unique()  #vector of valid answers in the experiment
#compute match
worker_answer = cm.WorkerAnswer(g, p, z)
#add the answers to the assignation dataset
df_tw['worker_answers'] = worker_answer.match()
```
Compute confusion matrix 

```python
from pycm import *

#define parameters
g = df_tw['true_answers'] #vector of gold standar answers
a = df_tw['worker_answers'] #vector of simulated answers
#compute confusion matrix
cm = ConfusionMatrix(g.tolist(), a.tolist())
print(cm.Overall_ACC, cm.matrix())
```

Compute the crowdED methodology to get accuracy of workers and tasks selection on two stages

You will need to run ```!pip install pycm```

```python
import crowded.make as mk
from pycm import *

total_tasks=415 
total_workers=40 
proportion_of_hard_tasks=0.4
proportion_of_tasks_to_train=0.3
workers_per_task=5
number_of_valid_answers =3
alpha=28
beta=3

df = mk.crowd_table(total_tasks, 
        total_workers, 
        proportion_of_hard_tasks, 
        proportion_of_tasks_to_train, 
        workers_per_task, 
        number_of_valid_answers, 
        alpha, 
        beta)

cm = ConfusionMatrix(df['true_answers'].tolist(), df['worker_answers'].tolist())
print(cm.Overall_ACC, cm.matrix())
```

## Citing this work

If you use CrowdED in a scientific publication, you are highly encouraged (not required) to cite the following paper:

CrowdED: Guideline for Optimal Crowdsourcing Experimental Design.
Amrapali Zaveri, Pedro Hernandez Serrano Manisha Desai and Michel Dumontier
[https://doi.org/10.1145/3184558.3191543](https://doi.org/10.1145/3184558.3191543).

Bibtex entry:

        @inproceedings{Zaveri:2018:CGO:3184558.3191543,
        author = {Zaveri, Amrapali and Serrano, Pedro Hernandez and Desai, Manisha and Dumontier, Michel},
        title = {CrowdED: Guideline for Optimal Crowdsourcing Experimental Design},
        booktitle = {Companion Proceedings of the The Web Conference 2018},
        series = {WWW '18},
        year = {2018},
        isbn = {978-1-4503-5640-4},
        location = {Lyon, France},
        pages = {1109--1116},
        numpages = {8},
        url = {https://doi.org/10.1145/3184558.3191543},
        doi = {10.1145/3184558.3191543},
        acmid = {3191543},
        publisher = {International World Wide Web Conferences Steering Committee},
        address = {Republic and Canton of Geneva, Switzerland},
        keywords = {biomedical, crowdsourcing, data quality, data science, fair, metadata, reproducibility},
        }

## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fpedrohserrano%2FcrowdED.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fpedrohserrano%2FcrowdED?ref=badge_large)
