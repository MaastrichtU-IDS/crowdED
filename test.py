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
import make
import pandas as pd

#tasks = [60, 80, 100, 120, 140]
#workers = [30, 40]
#hard_t = [0.2, 0.4, 0.6, 0.8]
#prop = [0.4, 0.6]
#wpt = [3, 5, 7]
#key = [3, 5, 7]


df = make.crowd_table()
#print(df)
mat = ConfusionMatrix(df['true_answers'].tolist(), df['worker_answers'].tolist())
print(mat.Overall_ACC)
#print(mat.Overall_ACC)

