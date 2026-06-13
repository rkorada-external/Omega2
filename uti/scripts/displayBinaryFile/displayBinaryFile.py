#! /usr/bin/env python

#import extractPermFilesFromlog
import os,fnmatch,sys
import re,collections,sys
filesI=[]
filesO=[]

SRC_DIRECTORY_DCMD="/scor/scoromega/runnable/cmd"
SRC_DIRECTORY_DCMD =  "/scoromega_dcvprdobbatch/runnable/cmd" #os.environ.get('DCMDD') #"/scor/home/frdev11/mehdi/sources/cmd/"

SRC_DIRECTORY_DUTI = "/scoromega_dcvprdobbatch/runnable/uti" #os.environ.get('DUTI') # "/scor/scoromega/runnable/uti/"
SRC_DIRECTORY_DUTI="/scor/scoromega/runnable/uti"

dicoPerms = () 

perms={} #collections.OrderedDict()
l=[]
  
  
def AnalyseChaine ( chaine):
#  dicoPerms = extractPermFilesFromlog.getDicoPerms( chaines,'/scordata_dcvprdobbatch/ubeu','/scor/home/frdev11/mehdi/data','P','T')
	path = SRC_DIRECTORY_DCMD + '/'
	dirs = os.listdir(path)
	dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_DCMD),chaine)
	#print path
	for chain in dirs :
		src_chain = path + chain
		#print src_chain
		if not os.path.exists(src_chain): return
		#if file.startswith("ESID200") and file.endswith(".cmd"):
		f= open(src_chain, "r")
		a = f.readlines()
		findCHAININT=0
		findJOBINIT=0
		for line in a:
			if line.strip().startswith("CHAININIT"):
				findCHAININT=1
				#print(src_chain)
			if line.strip().startswith("JOBINIT"):
				findJOBINIT=1
				#print(line)
			if  (not line.find(".cmd"))  :
				continue
			if findCHAININT == 1 and  (re.search(r'\.cmd.*2>&1 | ${TEE}',line)) :
				#print( line)
				AnalyseJobLine(chain.replace('.cmd',''),line.strip())
		f.close()
	l2=	sorted(set(l))
	l[:]=[]
	return sorted(set(l2))

	
					

def AnalyseJobLine ( chain,line):
    elmnts = re.split(r'\s+|\t+', line) 
    JOB=args= folder=""
    
    for elmnt in elmnts:
        if elmnt == '2>&1': break
        if folder != "" :  args +=  elmnt + " " 
        if re.search('.cmd',elmnt): 
            matchFolderJob = re.match( r'\$\{(.*)\}/(.*).cmd', elmnt)
            if matchFolderJob :
                folder=matchFolderJob.group(1)
                JOB=matchFolderJob.group(2)
                
    if folder == "DUTI" : SRC_DIRECTORY =SRC_DIRECTORY_DUTI 
    else: SRC_DIRECTORY = SRC_DIRECTORY_DCMD
    if JOB != "": 
		#print "\t" , JOB ,args
		AnalyseJobFile ( SRC_DIRECTORY ,chain, JOB)
   
def AnalyseJobFile ( SRC_DIRECTORY , chain,job):
	src_file=SRC_DIRECTORY  + '/' + job +".cmd"
	if not os.path.exists(src_file): return
	f=open(src_file, "r")
	a = f.readlines()
	findSTEPINT=0
	NSTEP ="" ;
	#print src_file 
	for line in a:
		if not line.strip().startswith("#")  :
			matchFolderJob = re.match( r".*\${(EST_[A-Z0-9_]*)}.*", line)
			if matchFolderJob :
				perm=matchFolderJob.group(1)
				l.append(perm)
			matchFolderJob = re.match( r".*\${(EPO_[A-Z0-9_]*)}.*", line)
			if matchFolderJob :
				perm=matchFolderJob.group(1)
				l.append(perm)
			matchFolderJob = re.match( r".*\${(STA_[A-Z0-9_]*)}.*", line)
			if matchFolderJob :
				perm=matchFolderJob.group(1)
				l.append(perm)

#print "\n".join(AnalyseChaine( sys.argv[1] + "*" ))


def getExport9001 ( ):
	src_file=SRC_DIRECTORY_DCMD  + '/ESCD9001.cmd' 
	f=open(src_file, "r")
	a = f.readlines()
	exports=[]
	for line in a:
		if line.strip().startswith("export")  :
			#print line.strip()
			grp = re.match( r".*(export E.*`.*`).*", line)
			if grp:
				exports.append(grp.group(1).replace("="," ").replace("`", " " ))
				#print grp.group(1)

	exports.sort()
	print '\t', '\n\t'.join(exports)	

	
def getDescription(file,struc):	
	src_file=file
	f=open(src_file, "r")
	a = f.readlines()
	isIn_typedef_struct=False
	isTypeStruct=False
	blocStruct=[]
	nameOfStruct=""
	isFind=False
	for line in a:
		match_typedef_struct_deb = re.match( r"typedef struct.*", line.strip())
		match_typedef_struct_end = re.match( r".*\}\s*(.*)\s*;.*", line.strip())

		
		if isIn_typedef_struct and  match_typedef_struct_end :
			isIn_typedef_struct = False
			#blocStruct.append(line.strip().replace("\n",""))
			nameOfStruct=match_typedef_struct_end.group(1)
			#print line , "'"+ nameOfStruct +"'"
			if nameOfStruct.strip() == struc:
				isFind=True
				break

		if isIn_typedef_struct:
			blocStruct.append(line.strip().replace("\n",""))
			
		if match_typedef_struct_deb :
			isIn_typedef_struct = True
			blocStruct=[]
	#print "\n".join(blocStruct)

	blocStruct1=[]
	for line in blocStruct:
		tab1 = line.split("{")
		tab2 = line.split("}")
		if len(tab1) > 1 :
			if len(tab1[1].strip()) > 0 :
				blocStruct1.append(tab1[1].strip())
		else :
			if len(tab2) > 1 : 
				if len(tab2[1].strip()) > 0 :
					blocStruct1.append(tab2[0].strip())
			else :
				blocStruct1.append(line.strip())

	#print nameOfStruct	
	#print "\n".join(blocStruct1)
	
	if not isFind:
		print "not found"
		return
		
	typ=""
	isLastComma=False 
	for line in blocStruct1:
		match_item= re.match( r"(\w*)\s*(.*)\s*(.*).*", line.split(";")[0])
		match_item2= re.match( r"(\w*)\s*(\w*)\s*(.*).*", line.split(";")[0])
		match_item3= re.match( r"(.*),.*", line)
		match_item4= re.match( r"(.*);.*", line)
		match_size= re.match( r".*(\[.*\]).*", line)
		if match_item :
			if match_item.group(1) == "unsigned" :
				typ = match_item2.group(1)+" "+match_item2.group(2)
				print typ +";"+match_item2.group(3).replace(",",";").replace("[",";").replace("]","")
			else :
				if match_item.group(1) != "}" :
					if isLastComma :
						if match_item3 :
							print typ + ";" + match_item3.group(1)
						if match_item4 :
							print typ + ";" + match_item4.group(1)
					else:
						#typ = match_item.group(1)
						#print match_item.group(1)+";"+match_item.group(2).replace(",",";").replace("[",";").replace("]","")
						typ = match_item.group(1)
						if match_size:
							print typ + ";"+match_item.group(2).replace(",",";").replace("[",";").replace("]","")
						else:	
							print typ + ";"+match_item.group(2).replace(",",";").replace("[",";").replace("]","") + ";1"
		if match_item4 :
			isLastComma = False 
		if match_item3 :
			isLastComma = True 
		
				
#getDescription("/scor/scoromega/otec/sc/estserv.h","T_LIFDRI_ALL1")
#getDescription("estserv.h_woc","T_TabPart")
getDescription(sys.argv[1],sys.argv[2])

