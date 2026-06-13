#! /usr/bin/python3

import os,fnmatch,glob
import re
import sys,datetime
from pprint import pprint 

steps={}


flog=sys.argv[1] #"/scor/scordata/ubeu/temporaire/Y_STAD1500_STAD1501_26_dcvdevobbatch_20190307145104_30542_STAM1225.log"
frmt='%Y/%m/%d %H:%M:%S'
env=""
ID_FCT=sys.argv[2]
if len(sys.argv) == 3:
	env="dev"


CWD=os.getcwd()
#print "#CWD:" , CWD
ROOT = os.path.dirname(os.path.abspath(flog)) + "/../.." 
print( "#ROOT:" , os.path.dirname( flog),ROOT)
IB=""
isPrm = False
vars={}
export_I=[]
export_O=[]
f= open(flog, 'r')
a = f.readlines()
isInStep =False
stepsInfo=[]
prm=""
log=""
for line in a:
	if line.startswith("# Step name  :"): 
		step_name=line.split(" ")[5].strip()
		tab_IB=os.path.basename(flog).replace(step_name,"").strip().split("_")
		#print tab_IB
		#print "step_name:",step_name
		IB=(tab_IB[1]+"_"+tab_IB[2]+"_"+tab_IB[3]).strip()
	tab= line.strip().split(";")
	if len(tab) == 3 : 
		PRG=re.sub(r"_.*", "",tab[2]).replace("export ","")
		folder = os.path.basename( os.path.abspath( tab[1]+"/..") )
		vars[tab[2].replace("export ","").split("=")[0]]=(tab[2].replace("export ","").split("=")[1],folder,tab[1])

 
print ("#IB=", IB)
 	
#pprint(vars)
for var in vars:
	if  "_I" in  var:
		if env == "": fname=ROOT+"/"+vars[var][1]+"/"+vars[var][0] 
		if env == "dev": fname=vars[var][2]
		#print "#fname:", fname 		
		fname_orig=fname.replace("/scor/scordata",ROOT)
		#print "#fname_orig:", fname_orig 		
		if  os.path.isfile(fname_orig)  :
			export_I.append("export "+var+"="+fname_orig)
			#print "export "+var+"="+fname
		else:
			
			zipFile = fname_orig.replace(IB,ID_FCT) +".gz"
			#print "#zipfile= " , zipFile 
			if  os.path.isfile(zipFile)  :
				print( "zcat "+ zipFile +"  > $DFILT/"+vars[var][0] )
				fname =  "$DFILT/"+vars[var][0] 
				export_I.append("export "+var+"="+fname)
				#print "export "+var+"="+fname
			else: 
				print (" Error : file " + fname  + " not found")
	if "_O" in  var:
		export_O.append("export "+var+"=${DFILT}/"+vars[var][0] )
		#print "export "+var+"=${DFILT}/"+vars[var][0] 
		
	if "_PRM" in  var:
		prm="export "+var+"=${DFILT}/${PRG}.prm"
		isPrm = True


		
print ( "PRG="+PRG                               )
print ("export ${PRG}_LOG=${DFILT}/${PRG}.log"   )
print ("export ${PRG}_ANO=${DFILT}/${PRG}.ano"   )
print ("export SRV=''"                           )
print ("export USR=''"                           )
print ("export PSWD=''"                          )
print ("export BASE=''"                          )
export_I.sort()
export_O.sort()
print ("\n#Input files .............................................."    )
print ("\n".join(export_I)                                                )
print ("\n#Output files .............................................."   )
print ("\n".join(export_O)                                                )


if isPrm:
	prmName=flog.replace('.log','.prm')
	if os.path.isfile(prmName):
		print( "export ${PRG}_PRM="+prmName)          
	else:
		print ("#export ${PRG}_PRM=${DFILT}/${PRG}.prm"                           )
		print ("\n\n"                                                             )
		print ('cat  <<EOF > ${DFILT}/${PRG}.prm'                                 )
		print (" !!!!!  TO DO   input the parameters of programm !!!!!!!!!!!"     )
		print ('EOF'                                                              )
	print( "\n\n")


print  ("gdb ${DEXE}/${PRG}.exe")
		
	
		
