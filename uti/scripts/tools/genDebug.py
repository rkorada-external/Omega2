#! /usr/bin/env python

import os,fnmatch,glob
import re
import sys,datetime,dateutil.parser
from pprint import pprint

steps={}


flog=sys.argv[1] #"/scor/scordata/ubeu/temporaire/Y_STAD1500_STAD1501_26_dcvdevobbatch_20190307145104_30542_STAM1225.log"
idf_ct=sys.argv[2]
flog_bn=os.path.basename(flog)
ROOT=os.path.dirname(flog)+"/../"
print "#ROOT:", ROOT
frmt='%Y/%m/%d %H:%M:%S'
env=""
if len(sys.argv) == 4:
	env="dev"

	
isPrm = False
vars={}
export_I=[]
export_O=[]
f= open(flog, 'r')
a = f.readlines()
isInStep =False
stepsInfo=[]
prm=""
IB=""
i=0
for line in a:
	if i == 2 :
		tab= line.strip().split(":")
		NCHAIN=tab[1].strip()
	if i == 3 :
		tab= line.strip().split(":")
		NJOB=tab[1].strip()
	if i == 4 :
		tab= line.strip().split(":")
		NSTEP=tab[1].strip()
		tab_IB=flog_bn.replace(NSTEP,"").split("_")
		IB=tab_IB[1]+"_"+tab_IB[2]+"_"+tab_IB[3]

	tab= line.strip().split(";")
	if len(tab) == 3 : 
		PRG=re.sub(r"_.*", "",tab[2]).replace("export ","")
		folder = os.path.basename( os.path.abspath( tab[1]+"/..") )
		vars[tab[2].replace("export ","").split("=")[0]]=(tab[2].replace("export ","").split("=")[1],folder,tab[1])
	i +=1

print "#IB=", IB


#-------------------------------------------------------------------------
# FILE:T_ESFD3620_ESFD3621INV_07_AEnIntO2Batch_20220601004951_8505_ESTC2066.log
# Chain name : T_ESFD3620               Date : 2022/06/01 02:58:32
# Job name   : T_ESFD3620_ESFD3621INV
# Step name  : T_ESFD3620_ESFD3621INV_07


#print vars
#print "env:" ,env		

#pprint(vars)
print "#env:", env 
for var in vars:
	if  "_I" in  var:
		if env == "": fname=ROOT+vars[var][1]+"/"+vars[var][0] 
		if env == "dev": fname=vars[var][2] 
		#print"#fname;", fname 
		if  os.path.isfile(fname)  :
			export_I.append("export "+var+"="+fname)
			#print "export "+var+"="+fname
		else:
			#print IB, fname 
			#print fname
			zipFile = fname.replace(IB,idf_ct) +".gz"
			#print "zipfile= " , zipFile 
			if  os.path.isfile(zipFile)  :
				print "zcat "+ zipFile +"  > $DFILT/"+vars[var][0] 
				fname =  "$DFILT/"+vars[var][0] 
				export_I.append("export "+var+"="+fname)
				#print "export "+var+"="+fname
			else: 
				print " Error : file " + fname  + " not found"
	if "_O" in  var:
		export_O.append("export "+var+"=${DFILT}/"+vars[var][0] )
		#print "export "+var+"=${DFILT}/"+vars[var][0] 
		
	if "_PRM" in  var:
		prm="export "+var+"=${DFILT}/${PRG}.prm"
		isPrm = True


		
print  "PRG="+PRG

print "export ${PRG}_LOG=${DFILT}/${PRG}.log"
print "export ${PRG}_ANO=${DFILT}/${PRG}.ano"

print "export SRV=''"
print "export USR=''"
print "export PSWD=''"
print "export BASE=''"

export_I.sort()
export_O.sort()
print "\n#Input files .............................................."
print "\n".join(export_I)
print "\n#Output files .............................................."
print "\n".join(export_O)


if isPrm:
	prmName=flog.replace('.log','.prm')
	if os.path.isfile(prmName):
		print "export ${PRG}_PRM="+prmName
	else:
		print "#export ${PRG}_PRM=${DFILT}/${PRG}.prm"
		print "\n\n"
		print 'cat  <<EOF > ${DFILT}/${PRG}.prm'
		print " !!!!!  TO DO   input the parameters of programm !!!!!!!!!!!"
		print 'EOF'
	print "\n\n"


print  "gdb ${DEXE}/${PRG}.exe"
		
	
		
