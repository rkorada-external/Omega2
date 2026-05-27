#! /usr/bin/python2.7
import os, sys, subprocess, csv, re, gzip, pickle, time, fnmatch
from pprint import pprint

file = sys.argv[1]

with open(file, 'rb') as f:
	dico=pickle.load(f)


pprint(dico)