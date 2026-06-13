#! /usr/bin/python3
import sys,errno
from pprint import pprint
from closingStatusLib import logsList


status=""
if  len (sys.argv) <= 2 :
    print ( "!!!!!!!!!!!!!!!!!!!!\nneed 2 arguments or 3 : env{PRD,UAT,...} site{eu,as,am} status(Waiting,Succeeded,Failed)\n!!!!!!!!!!!!!!!!!!!!!") 
    sys.exit(errno.EACCES)
else:
    env=sys.argv[1]
    site=sys.argv[2]
    if len (sys.argv) > 3 : status = sys.argv[3] 

print(f"-----------------------------------------------\n{env},{site},{status}\n")
if status != "":
    for log in logsList(env,site):
        if log['status'] == status:   pprint(log)
else : 
    pprint(logsList(env,site))
