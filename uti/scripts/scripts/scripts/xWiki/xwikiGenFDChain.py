#! /usr/bin/env python

#import extractPermFilesFromlog
import os,fnmatch
import re
import sys,collections
filesI=[]
filesO=[]

SRC_DIRECTORY_DCMD = os.environ.get('DCMD')
# SRC_DIRECTORY_DCMD =  "/scoromega_dcvprdobbatch/runnable/cmd" #os.environ.get('DCMDD') #"/scor/home/frdev11/mehdi/sources/cmd/"
# #SRC_DIRECTORY_DCMD="/scor/home/u007314/JYP/cmd"
# SRC_DIRECTORY_DCMD="/scoromega_runnable_aenitko2batch/cmd"

# SRC_DIRECTORY_DUTI = "/scoromega_dcvprdobbatch/runnable/uti" #os.environ.get('DUTI') # "/scor/scoromega/runnable/uti/"
# SRC_DIRECTORY_DUTI = "/scoromega_runnable_aenitko2batch/uti" #os.environ.get('DUTI') # "/scor/scoromega/runnable/uti/"
SRC_DIRECTORY_DUTI = os.environ.get('DUTI') # "/scor/scoromega/runnable/uti/"

dicoPerms = () 

xWikiFD=collections.OrderedDict()
  
def AnalyseCmd ( chaines,job,step):
#  dicoPerms = extractPermFilesFromlog.getDicoPerms( chaines,'/scordata_dcvprdobbatch/ubeu','/scor/home/frdev11/mehdi/data','P','T')
  path = SRC_DIRECTORY_DCMD + '/'
  dirs = os.listdir(path)
  dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_DCMD),chaines)
  for chain in dirs :
	src_chain = path + chain
	if not os.path.exists(src_chain): return
	#if file.startswith("ESID200") and file.endswith(".cmd"):
	f= open(src_chain, "r")
	a = f.readlines()
	findCHAININT=0
	findJOBINIT=0
	xWikiFD[chain.replace('.cmd','')] = collections.OrderedDict() # chain.replace('.cmd','')
	for line in a:
	   if line.strip().startswith("CHAININIT"):
		   findCHAININT=1
		   print(src_chain)
	   if line.strip().startswith("JOBINIT"):findJOBINIT=1
		   #print(line)
	   if  (not line.find(".cmd"))  :
			   continue
	   if findCHAININT == 1 and  (re.search(r'\.cmd.*2>&1 | ${TEE}',line)) :
		   #print( line)
		   AnalyseJobLine(chain.replace('.cmd',''),line.strip())
	f.close()
	t=genxWiki(job,step)
	print job, step, chain,'out/'+ chaines+ '.xWiki'
	open('out/'+ chaines+ '.xWiki', "w").write(t)
	
def genxWiki(job0,step0):
	t=''
	for chain in xWikiFD:
		print chain
		for job in xWikiFD[chain]:
			if job0 != ''  and  job != job0: continue
			i=0
			for step in xWikiFD[chain][job]:
				i +=1
				if step0 != ''  and  step != job + '_' + step0 : continue
				titre_step= 'R'+str(i) + ' (STEP ' + step.split('_')[1] + '): '+ xWikiFD[chain][job][step]['libel'] 
				print '\t','\t', 'STEP: ',xWikiFD[chain][job][step]['step'] , titre_step
				t += open('cartouches/headerService.txt').read().replace('[[libel]]',titre_step).replace('[[i]]',str(i+100))
				if  xWikiFD[chain][job][step]['libel'] != '' :
					if len( xWikiFD[chain][job][step]['services']) == 0 :
						t += open('cartouches/lineService.txt').read().replace('[[service]]','').replace('[[comment]]','')
					else:
						for service in xWikiFD[chain][job][step]['services']:
							print '\t','\t','\t',service
							t += open('cartouches/lineService.txt').read().replace('[[service]]',service[0]).replace('[[comment]]',service[1])
				
					t += open('cartouches/headerIO.txt').read().replace('[[io]]','Input')
					if len( xWikiFD[chain][job][step]['input']) == 0 :
							t += open('cartouches/lineIO.txt').read().replace('[[io]]','').replace('[[dataType]]','').replace('[[value]]','')
					else:
						for io in xWikiFD[chain][job][step]['input']	:
							v = open('cartouches/lineIO.txt').read().replace('[[io]]',io[0])
							if io[0] == 'Keys' :
								v = v.replace('[[dataType]]','Parameters')
								v = v.replace('[[value]]',io[1])
							else :
								v = v.replace('[[dataType]]','Data file')
								v = v.replace('[[value]]',io[1].replace('"','').split(' ')[0])
							t +=v #+'\n'
							print '\t','\t','\t',io
						for cond in xWikiFD[chain][job][step]['condition']	:
							v = open('cartouches/lineIO.txt').read().replace('[[io]]','SORT Condition ' + cond[0] )
							v = v.replace('[[dataType]]','Parameters')
							v = v.replace('[[value]]',cond[1].replace('!=','<>') )
							t +=v #+'\n'
							print '\t','\t','\t', 'SORT Condition ' ,cond

					t += open('cartouches/headerIO.txt').read().replace('[[io]]','output')
					if len( xWikiFD[chain][job][step]['output']) == 0 :
							t += open('cartouches/lineIO.txt').read().replace('[[io]]','').replace('[[dataType]]','').replace('[[value]]','')
					else:
						for io in xWikiFD[chain][job][step]['output']:		
							v = open('cartouches/lineIO.txt').read().replace('[[io]]',io[0])
							v = v.replace('[[dataType]]','Data file')
							v = v.replace('[[value]]',io[1].replace('"','').split(' ')[0])
							t +=v #'\n'
							print '\t','\t','\t',io
				else: # Si le step n'est pas identifier on cree un tableau vide
					t += open('cartouches/lineService.txt').read().replace('[[service]]','').replace('[[comment]','')

					t += open('cartouches/headerIO.txt').read().replace('[[io]]','Input')
					t += open('cartouches/lineIO.txt').read().replace('[[io]]','').replace('[[dataType]]','').replace('[[value]]','')

					t += open('cartouches/headerIO.txt').read().replace('[[io]]','output')
					t += open('cartouches/lineIO.txt').read().replace('[[io]]','').replace('[[dataType]]','').replace('[[value]]','')
				

	return t
					


					
#    if findCHAININT == 1  :
#      filesI_ = list(set(filesI)) 
#      filesO_ = list(set(filesO)) 
#      filesI_.sort()
#      filesO_.sort()
#      for perm in dicoPerms:
#        print perm
#      print '\nImput permanent and interm files:'
#      for f in filesI_:
#        f2=f
#        if f2 in dicoPerms : 
#          print '\t' , f2 + '=' + dicoPerms[f2][0]
#        else: 
#          print '\t' , f2
#      print '\nOutput permanent and interm files:'
#      for f in filesO_:
#  		  print '\t' , f
#  return   dicoPerms 

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
		print "\t" , JOB ,args
		AnalyseJobFile ( SRC_DIRECTORY ,chain, JOB)
   
def AnalyseJobFile ( SRC_DIRECTORY , chain,job):
	src_file=SRC_DIRECTORY  + '/' + job +".cmd"
	if not os.path.exists(src_file): return
	f=open(src_file, "r")
	a = f.readlines()
	findSTEPINT=0
	NSTEP ="" ;
	linesOfStep=[]
	xWikiFD[chain][job] = collections.OrderedDict()
	for line in a:
		if line.strip().startswith("NSTEP=") :#or line.strip().startswith("JOBEND"): 
			if NSTEP != "": 
				xWikiFD[chain][job][NSTEP] = collections.OrderedDict()
				AnalyseStep ( chain,job,linesOfStep , NSTEP)
			NSTEP = line.strip().replace("NSTEP=","").replace("{NJOB}",job).replace("$","").strip()
			linesOfStep=[]
			linesOfStep.append(NSTEP) 
		
		else: 
			if  line != "" and NSTEP != "" :
				linesOfStep.append(line)  
	if NSTEP != "": 
		xWikiFD[chain][job][NSTEP] = collections.OrderedDict()
		AnalyseStep ( chain,job,linesOfStep , NSTEP)
	
	f.close()
	#print linesOfStep
def isListContainRegex(list,reg):
	for line in list:
		if re.search(reg,line.replace("PARALLEL","").strip()): return 1
	return 0
	   
def AnalyseStep ( chain,job,linesOfStep , STEP):
	print "\t\t" , STEP
	xWikiFD[chain][job][STEP]['step']=STEP.split('_')[1]
	xWikiFD[chain][job][STEP]['libel']=''
	xWikiFD[chain][job][STEP]['services']=[]
	xWikiFD[chain][job][STEP]['input']=[]
	xWikiFD[chain][job][STEP]['output']=[]
	xWikiFD[chain][job][STEP]['condition']=[]
	
	if isListContainRegex(linesOfStep,r'^\s*SORT.*=*') == 1 : AnalyseSort (chain,job,linesOfStep , STEP) 

	if isListContainRegex(linesOfStep,r'^\s*BCP.*=*') == 1 : AnalyseBCP (chain,job,linesOfStep , STEP) 
	
	if isListContainRegex(linesOfStep,r'^\s*EXECPRG.*=*') == 1 :  AnalyseProg (chain,job,linesOfStep , STEP)

	if isListContainRegex(linesOfStep,r'^\s*AWK.*=*') == 1 :  AnalyseAwk (chain,job,linesOfStep , STEP)
	
	if isListContainRegex(linesOfStep,r'^\s*FTP.*=*') == 1 :  AnalyseFTP (chain,job,linesOfStep , STEP)

	if isListContainRegex(linesOfStep,r'EXECKSH ') == 1 :  AnalyseOther (chain,job,linesOfStep , STEP)

	if isListContainRegex(linesOfStep,r'RMFIL ') == 1 :  AnalyseOther (chain,job,linesOfStep , STEP)
    
	#if isListContainRegex(linesOfStep,r'^\s*GZIPM.*=*') == 1 :  AnalyseOther (chain,job,linesOfStep , STEP,'GZIPM_I=')
    
def AnalyseSort ( chain,job,linesOfStep ,STEP):
	#print linesOfStep
	keys=''
	endKeys=0
	condition=''
	conditions=collections.OrderedDict()
	conditionName=''
	endCondition=0
	for line in  linesOfStep: 
		if  re.search(r'LIBEL=',line.strip()) :  
			libel=line.strip().replace('LIBEL=','').replace('"','')
			xWikiFD[chain][job][STEP]['libel']=libel
			xWikiFD[chain][job][STEP]['services'].append(('SORT',libel))
		if  re.search(r'^\s*SORT_I[0-9]*\=.*$',line) :  
			xWikiFD[chain][job][STEP]['input'].append(line.strip().split('='))
			print "\t\t\t" +  line.strip()
		if  re.search(r'^SORT_O[0-9]*',line.strip()) :  
			xWikiFD[chain][job][STEP]['output'].append(line.strip().split('='))
			print "\t\t\t" +  line.strip()
		# parse Keys
		if  keys != '' and endKeys == 0 and re.search(r'^/',line.strip()):  
			endKeys = 1
		if  re.search(r'^/KEYS\s*',line.strip()) :  
			keys=line.strip().replace("#.*",'')
		if  keys != '' and endKeys == 0 and  not re.search(r'^/KEYS\s',line):  
			keys+=line.strip()
		# parse Condition
		if  conditionName != '' and endCondition == 0 and re.search(r'^/',line.strip()):  
			endCondition = 1
			conditionName=''
		if  re.search(r'^/CONDITION\s',line.strip()) :  
			condition=line.strip().replace("#.*",'').replace('/CONDITION','').strip()
			conditionName = condition.split(' ') [0]
			conditions[conditionName]=condition.replace(conditionName,'').strip()
			endCondition == 0
		if  conditionName != '' and endCondition == 0 and  not re.search(r'^/CONDITION\s',line) :
			condition=line.strip().replace("#.*",'').replace('/CONDITION','').strip()
			conditions[conditionName] +=line.strip()		

		FindPermAndInterFile (line)
	if 	keys != '' : 
		xWikiFD[chain][job][STEP]['input'].append(['Keys',keys.replace('/KEYS','').strip()]  )
		print "\t\t\tKeys:", keys 
	for condition in conditions	:
		print "\t\t\tcondition:", condition , conditions[condition]
		xWikiFD[chain][job][STEP]['condition'].append([condition,conditions[condition]])
		
def AnalyseBCP ( chain,job,linesOfStep ,STEP):
    for line in  linesOfStep: 
        if  re.search(r'.*BCP_[IO]\=.*$',line) :  
            print "\t\t\t" +  line.strip()
            FindPermAndInterFile (line)

def AnalyseProg ( chain,job,linesOfStep ,STEP):
	prg=''
	libel='WARNING missing description !!!!!!' 
	for line in  linesOfStep:
		if  re.search(r'LIBEL=',line.strip()) :  
			libel=line.strip().replace('LIBEL=','').replace('"','')
			xWikiFD[chain][job][STEP]['libel']=libel
		if not  line.strip().startswith('#') :
			prgGrp = re.match( r'.*PRG\=(.*).*', line)
			if  prgGrp :
				prg =  prgGrp.group(1) 
				xWikiFD[chain][job][STEP]['services'].append((prg,libel))
				print "\t\t\tPRG=" +  prg
		if prg != '' :
			line2=(line.replace('${PRG}',prg)).replace('${NSTEP}',STEP)
			if  re.search(r'.*\$\{PRG\}_I.*\=.*$',line) :
				xWikiFD[chain][job][STEP]['input'].append(line.replace('export','').replace('${PRG}',prg).strip().split('='))
				print "\t\t\t" +  line2.strip()
			if  re.search(r'.*\$\{PRG\}_O.*\=.*$',line) :
				xWikiFD[chain][job][STEP]['output'].append(line.replace('export','').replace('${PRG}',prg).strip().split('='))
				print "\t\t\t" +  line2.strip()
				FindPermAndInterFile (line)

def AnalyseAwk ( chain,job,linesOfStep ,STEP):
	libel=''
	for line in  linesOfStep:
		if  re.search(r'LIBEL=',line.strip()) :  
			libel=line.strip().replace('LIBEL=','').replace('"','')
			xWikiFD[chain][job][STEP]['libel']=libel
		if not  line.strip().startswith('#') :
			awkGrp = re.match( r'^AWK$', line.strip())
			if  awkGrp :
				xWikiFD[chain][job][STEP]['services'].append(('AWK',libel))
				print "\t\t\tAWK", libel 
			if  re.search(r'^AWK_I.*\=.*$',line.strip()) :
				xWikiFD[chain][job][STEP]['input'].append(line.strip().replace('"','').split('='))
				print "\t\t\t" +  line.strip()
			if  re.search(r'^AWK_O.*\=.*$',line.strip()) :
				xWikiFD[chain][job][STEP]['output'].append(line.strip().replace('"','').split('='))
				print "\t\t\t" +  line.strip()
			FindPermAndInterFile (line)
				
def AnalyseFTP ( chain,job,linesOfStep ,STEP):
    for line in  linesOfStep: 
        if  re.search(r'.*FTP\=.*$',line) :  
            print "\t\t\t" +  line.strip()
            FindPermAndInterFile (line)

def AnalyseEXECKSH ( chain,job,linesOfStep ,STEP):
	#print 'AnalyseEXECKSH :' ,linesOfStep
	for line in  linesOfStep:
		if  re.search(r'LIBEL=',line.strip()) :
			libel=line.strip().replace('LIBEL=','').replace('"','')
			xWikiFD[chain][job][STEP]['libel']=libel
		if  re.search(r'EXECKSH "',line.strip()) :
			xWikiFD[chain][job][STEP]['services'].append(line.strip().split('"'))
			print "\t\t\t" +  line.strip()

def AnalyseRMFIL ( chain,job,linesOfStep ,STEP):
  for line in  linesOfStep: 
      if  re.search(r'\s*RMFIL ".*',line) :  
        print "\t\t\t" +  line.strip()

def AnalyseOther ( chain,job,linesOfStep ,STEP):
	#print 'AnalyseEXECKSH :' ,linesOfStep
	for line in  linesOfStep:
		if  re.search(r'LIBEL=',line.strip()) :
			libel=line.strip().replace('LIBEL=','').replace('"','')
			xWikiFD[chain][job][STEP]['libel']=libel
		if  re.search(r'EXECKSH "',line.strip()) :
			xWikiFD[chain][job][STEP]['services'].append(line.strip().split('"'))
			print "\t\t\t" +  line.strip()
		if  re.search(r'RMFIL ',line.strip()) :
			if xWikiFD[chain][job][STEP]['libel'] == '' : xWikiFD[chain][job][STEP]['libel'] ='RMFIL'
			xWikiFD[chain][job][STEP]['services'].append(line.strip().split(' '))
			print "\t\t\t" +  line.strip()

 
def FindPermAndInterFile( line):
    matchFolderJob = re.match( r'^.*(?:SORT|PRG|BCP|FTP).*_I([0-9]*)\=.*\$\{(EST_.*)\}.*', line)
    if matchFolderJob :
        s=matchFolderJob.group(2)
        if filesO.count(s) == 0 :
            filesI.append(s)
 
    matchFolderJob = re.match( r'^.*(?:SORT|PRG|BCP|FTP).*_O([0-9]*)\=.*\$\{(EST_.*)\}.*', line)
    if matchFolderJob :
        s=matchFolderJob.group(2)
        filesO.append(s)
 
if len(sys.argv) >= 3:  job =  sys.argv[2] 
else: job=''

if len(sys.argv) >= 4:  step =  sys.argv[3] 
else: step = ''
                    
AnalyseCmd ( sys.argv[1] ,job,step)
