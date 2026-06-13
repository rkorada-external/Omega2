#! /usr/bin/env python

import os,fnmatch,glob
import re
import sys,datetime,dateutil.parser

steps={}


flog=sys.argv[1] #"/scor/scordata/ubeu/temporaire/Y_STAD1500_STAD1501_26_dcvdevobbatch_20190307145104_30542_STAM1225.log"
frmt='%Y/%m/%d %H:%M:%S'


ROOT = os.path.abspath( flog+"/../..") 
tab_IB=re.sub(r".*_dcv", "dcv",flog).split("_")
IB=""
if len(tab_IB) > 3 :
	IB=tab_IB[0]+"_"+tab_IB[1]+"_"+tab_IB[2]
	
print "#IB=", IB
isPrm = False
vars={}
export_I=[]
export_O=[]
f= open(flog, 'r')
a = f.readlines()
isInStep =False
stepsInfo=[]
prm=""
for line in a:
	tab= line.strip().split(";")
	if len(tab) == 3 : 
		PRG=re.sub(r"_.*", "",tab[2]).replace("export ","")
		folder = os.path.basename( os.path.abspath( tab[1]+"/..") )
		vars[tab[2].replace("export ","").split("=")[0]]=(tab[2].replace("export ","").split("=")[1],folder)

		
for var in vars:
	if  "_I" in  var:
		fname=ROOT+"/"+vars[var][1]+"/"+vars[var][0] 
		if  os.path.isfile(fname)  :
			export_I.append("export "+var+"="+fname)
			#print "export "+var+"="+fname
		else:
			#print IB, fname 
			zipFile = fname .replace(IB,"") +".gz"
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

print "export ${PRG}_SRV=''"
print "export ${PRG}_USR=''"
print "export ${PRG}_PSWD=''"

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
		print "export ${PRG}_PRM=${DFILT}/${PRG}.prm"
		print "\n\n"
		print 'export ${PRG}_PRM=${DFILT}/${PRG}.prm'
		print 'cat  <<EOF > ${DFILT}/${PRG}.prm'
		print " !!!!!  TO DO   input the parameters of programm !!!!!!!!!!!"
		print 'EOF'
	print "\n\n"


print  "gdb ${DEXE}/${PRG}.exe"
		
	
		
