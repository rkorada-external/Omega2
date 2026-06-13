#! /opt/rh/rh-python38/root/usr/bin/python
 
import os, sys,datetime
import uuid
import fnmatch
import re,collections,sys
import datetime
import configparser
from pprint import pprint

delivryEnv= os.environ.get('DELIVERY_ENV', '')

pathname = os.path.dirname(sys.argv[0])
config = configparser.RawConfigParser()
print (pathname +  "/" + 'deliver'+delivryEnv +'.properties' )
config.read(pathname +  "/" + 'deliver'+delivryEnv +'.properties')


poropExts= config.get('properties', 'components').split(";")
autorizedExt=[]
for ext in poropExts:
    autorizedExt.append(ext.strip())
    
print("........ Autorized extesion :", autorizedExt )


now = datetime.datetime.now()

uuid.uuid4()
import getpass
username = getpass.getuser()

fName= '/tmp/deliverDC_'  + username + '.txt'
listDelivredComponents={}
	

				
def checkComponents(componentsList,autorizedExt):				
    ret=0
    f= open(componentsList, 'r')
    a = f.readlines()
    for line in a:
        if not line.strip().startswith("#")  and line.strip() != "": 	
            component=line.strip().split(";")[0]
            ret += checkComponent ( component,autorizedExt )
    f.close()
    return ret 
				
def checkComponent(component,autorizedExt):	
    ext=os.path.splitext(component)[1].strip().replace(".","")
    if ext in autorizedExt: 
        print(f"......component [{component}] extention [{ext}] OK ")
        return 0
    else:
        print(f"......component [{component}] extention [{ext}] KO ")
        return 1


ret = 1 
if os.path.splitext(sys.argv[1])[1] == '.lst':
    ret = checkComponents(sys.argv[1],autorizedExt)
else :
    ret = checkComponent ( sys.argv[1],autorizedExt)   
if ret == 0:
    print ( "\n Info: check components OK\n")
else:
    print ( "\n Info: check components KO\n")
    sys.exit(1) 
	
  


