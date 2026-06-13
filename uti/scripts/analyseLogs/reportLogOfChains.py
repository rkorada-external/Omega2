#! /usr/bin/env python

import os,fnmatch,glob
import re
import sys,datetime,dateutil.parser
from pprint import pprint
steps={}


flog="C:\\temp\\T_ESPD3700_dcvdevobbatch_20180426183618.log"
frmt='%Y/%m/%d %H:%M:%S'

def getSteps(flog,dt):
	startSteps={}
	endSteps={}
	reads={}
	output1s={}
	output2s={}
	output3s={}
	output4s={}
	output5s={}
	chain=''
	elapse=''
	f= open(flog, 'r')
	a = f.readlines()
	isInStep =False
	stepsInfo=[]
	for line in a:
		
		chain_grp=re.match( r'# Chain name    :  ._(.*)  Date :  ', line)
		if chain_grp :
			chain = chain_grp.group(1)
		start= re.match( r'# Begin of step:  (.*)  Date:  (.*)', line)
		if start :
			startSteps[start.group(1)]=start.group(2)
			step = start.group(1)
			isInStep = True
		end= re.match( r'# End of step  :  (.*) Date:  (.*)', line)
		if end :
			endSteps[end.group(1)]=end.group(2)
		elapse_grp= re.match( r'# Elapsed Time : (.*)', line)
		if elapse_grp :
			elapse=elapse_grp.group(1)	
		read=re.match( r'Records read:   (.*) Data read', line)
		output= re.match( r'Records output: (.*) Data output ', line)
		output1= re.match( r'Records output \(1\): (.*) Data output \(bytes\) \(1\):', line)
		output2= re.match( r'Records output \(2\): (.*) Data output \(bytes\) \(2\):', line)
		output3= re.match( r'Records output \(3\): (.*) Data output \(bytes\) \(3\):', line)
		output4= re.match( r'Records output \(4\): (.*) Data output \(bytes\) \(4\):', line)
		#print line
		function=re.match( r'# Function:(.*)', line)
		execprg=re.match( r'# Start of(.*)Execution', line)
		if read:                                                    
			reads[step]= read.group(1) 
		if output:    
			output1s[step]= output.group(1)
		else:
			if output1:    
				output1s[step]= output1.group(1)
			if output2:    
				output2s[step]= output2.group(1)
			if output3:    
				output3s[step]= output3.group(1)
			if output4:    
				output4s[step]= output4.group(1)
		if function and isInStep:
				output5s[step]= function.group(1)
		if execprg :
			output5s[step]= execprg.group(1)
		

	#print "Elapse: " , elapse
	for step in startSteps:
		deb=datetime.datetime.strptime(startSteps[step], frmt)
		s_end=''
		s_elapse=''
		read=''
		output1=''
		output2=''
		output3=''
		output4=''
		output5=''
		if step in endSteps:
			end=datetime.datetime.strptime(endSteps[step], '%Y/%m/%d %H:%M:%S')
			s_elapse=str(end -deb)
			s_end=end.strftime(frmt)
		if step in reads:
			read=reads[step].strip().replace(',','')
		if step in output1s:
			output1=output1s[step].strip().replace(',','')
		if step in output2s:
			output2=output2s[step].strip().replace(',','')
		if step in output3s:
			output3=output3s[step].strip().replace(',','')
		if step in output4s:
			output4=output4s[step].strip().replace(',','')
		if step in output5s:
			output5=output5s[step].strip().replace(',','')
		steps[step]=(deb.strftime(frmt),s_end,s_elapse,read,output1,output2,output3,output4,output5)
		step_detail=step.strip().split('_')
		job=num_step=''
		if len ( step_detail)  > 2 : job=step_detail[2]
		if len ( step_detail)  > 3 : num_step=step_detail[3]
		if len ( step_detail)  > 4 : 
			for i in range(4,len ( step_detail)):
				num_step +="_"+step_detail[i]
		if ( num_step != '') :
			stepsInfo.append(chain+";"+ job+";"+num_step+";"+steps[step][8]+";"+ steps[step][0] +";"+ steps[step][1]+";"+steps[step][2]+";"+steps[step][3]+";"+steps[step][4]+";"+steps[step][5]+";"+steps[step][6]+";"+dt)
	return (chain,elapse.strip(),stepsInfo,dt)


def getStepsOld(flog,dt):
	startSteps={}
	endSteps={}
	reads={}
	output1s={}
	output2s={}
	output3s={}
	output4s={}
	chain=''
	elapse=''
	f= open(flog, 'r')
	a = f.readlines()
	for line in a:
		
		chain_grp=re.match( r'# Chain name    :  ._(.*)  Date :  ', line)
		if chain_grp :
			chain = chain_grp.group(1)
		start= re.match( r'# Begin of step:  (.*)  Date:  (.*)', line)
		if start :
			startSteps[start.group(1)]=start.group(2)
			step = start.group(1)
		end= re.match( r'# End of step  :  (.*) Date:  (.*)', line)
		if end :
			endSteps[end.group(1)]=end.group(2)
		elapse_grp= re.match( r'# Elapsed Time : (.*)', line)
		if elapse_grp :
			elapse=elapse_grp.group(1)
		read=re.match( r'Records read:   (.*) Data read', line)
		output= re.match( r'Records output: (.*) Data output ', line)
		output1= re.match( r'Records output \(1\): (.*) Data output \(bytes\) \(1\):', line)
		output2= re.match( r'Records output \(2\): (.*) Data output \(bytes\) \(2\):', line)
		output3= re.match( r'Records output \(3\): (.*) Data output \(bytes\) \(3\):', line)
		output4= re.match( r'Records output \(4\): (.*) Data output \(bytes\) \(4\):', line)
		if read:                                                    
			reads[step]= read.group(1) 
		if output:    
			output1s[step]= output.group(1)
		else:
			if output1:    
				output1s[step]= output1.group(1)
			if output2:    
				output2s[step]= output2.group(1)
			if output3:    
				output3s[step]= output3.group(1)
			if output4:    
				output4s[step]= output4.group(1)
	print "Elapse: " , elapse
	for step in startSteps:
		deb=datetime.datetime.strptime(startSteps[step], frmt)
		s_end=''
		s_elapse=''
		read=''
		output1=''
		output2=''
		output3=''
		output4=''
		if step in endSteps:
			end=datetime.datetime.strptime(endSteps[step], '%Y/%m/%d %H:%M:%S')
			s_elapse=str(end -deb)
			s_end=end.strftime(frmt)
		if step in reads:
			read=reads[step].strip().replace(',','')
		if step in output1s:
			output1=output1s[step].strip().replace(',','')
		if step in output2s:
			output2=output2s[step].strip().replace(',','')
		if step in output3s:
			output3=output3s[step].strip().replace(',','')
		if step in output4s:
			output4=output4s[step].strip().replace(',','')
		steps[step]=(deb.strftime(frmt),s_end,s_elapse,read,output1,output2,output3,output4)
		step_detail=step.strip().split('_')
		job=num_step=''
		if len ( step_detail)  > 2 : job=step_detail[2]
		if len ( step_detail)  > 3 : num_step=step_detail[3]
		if len ( step_detail)  > 4 : num_step +="_"+step_detail[4]
		if ( num_step != '') :
			print chain+";"+ job+";"+num_step+";"+ steps[step][0] +";"+ steps[step][1]+";"+steps[step][2]+";"+steps[step][3]+";"+steps[step][4]+";"+steps[step][5]+";"+steps[step][6]+";"+dt

def getChainInfo(flog):
	f= open(flog, 'r')
	a = f.readlines()
	nchain=''
	status=''
	stepErr=''
	dt=''
	idf_ct=""
	for line in a:
		nchainGrp= re.match( r'# Chain name    :  ._(.*)  Date :  (.*)', line)
		if nchainGrp:
			nchain=nchainGrp.group(1)
			#dt=datetime.datetime.strptime(nchainGrp.group(2), frmt)
			dt = nchainGrp.group(2)
		nchainGrp= re.match( '#   ERROR: Step (.*) has failed with return Code', line)
		if nchainGrp:
			stepErr=nchainGrp.group(1)
		if line.startswith('# '+nchain+': NO GO'):
			status='NO GO'
		nchainGrp= re.match( '# End of Chain :  ._' + nchain+' (.*)  Date: ', line)
		if nchainGrp:
			if status != 'NO GO':
				status=nchainGrp.group(1)
		nchainGrp= re.match( '#----> IDF_CT .........................: (.*)', line)
		if nchainGrp:
			idf_ct=nchainGrp.group(1)
	if( idf_ct == ""): idf_ct=nchain
	return (nchain,idf_ct, status,dt,stepErr)


def getLogs ( folder, patern, dtMinChain ):
	print "chain;job;step;start;end;elapse;#rows read;rows out1;#rows read;rows out2;rows out3;rows out4"
	logs = glob.glob(folder+patern)
	logs.sort(key=os.path.getmtime)
	for log in logs :
		info=getChainInfo(log)
		#if info[2] > dtMinChain: 
		getSteps(log,dtMinChain)
		

def getLogsOfFolder ( folder, patern,dt ):
	DFILT=os.getenv("DFILT")
	fChains = open(DFILT+"/"+"ElapsesChain.txt", "a")
	logs = glob.glob(folder+'/'+patern)
	logs.sort(key=os.path.getmtime)
	for log in logs :
		#info=getChainInfo(log)
		ret=getSteps(log,dt)
		fChains.write(dt+";"+ret[0]+";"+ret[1]+"\n" )
	fChains.close()
		
def getChainsInfo( folder,patern,dtMinChain):
	chains={}
	files = glob.glob(folder+patern)
	files.sort(key=os.path.getmtime)
	file = open("allChains.txt", "r")
	a = file.readlines()
	chainsClos=[]
	for line in a:
        	chainsClos.append( line.strip())
	file.close()

	pprint(files)
	
	#files=fnmatch.filter(os.listdir(folder),chaines)
	for file in files :
		chain=getChainInfo(file)
		chains[chain[0]]=chain
	for chain in  chains:
#		if chain[1] > dtMinChain  :
		if chain in chainsClos:
			print chains[chain][3]+';'+chains[chain][0]+';'+chains[chain][1]+';'+chains[chain][2]+';'+chains[chain][4]


	
def getStatusLocal(env,site,dtInf,dtSup): 
	if env == 'prd' and site == 'mu' : 
		root='/scordata_dcvprdobmutbat/ubeu/log/'	
	else: 
		root='/scordata_dcv' + env + 'obbatch/ub'+site+ '/log/'	

	statusChains={}
	
	if env == 'itk' : root='/scordata_dcvtsto2db02/ub'+ site+'/log/'

	files = glob.glob(root + '*_ESL*.log')
	files.sort(key=os.path.getmtime)
	for file in files:  # pour eliminer les doublons on cree un dictionaire de status
		dt=datetime.datetime.fromtimestamp(os.path.getmtime(file))
		if datetime.datetime.strftime(dt,frmt) >=  dtInf and datetime.datetime.strftime(dt,frmt) <=  dtSup:
			status = getChainInfo(file)
			statusChains[status[0]] = status
			#print status 

	status = 1 
	for chain in statusChains:
		if   statusChains[chain][1] not in ('Succeeded','NO GO','Succeeded-Warning'): 
			status = 0
	
	return status
	

#getLogs(sys.argv[1],sys.argv[2],sys.argv[3])                             
#getLogsOfFolder(sys.argv[1],sys.argv[2],sys.argv[3])		

#getLogs("/scordata_dcvprdobbatch/ubeu/log/","P_ESPD3700_dcvprdobbatch_20181113232055.log")
		
#getStatusLocal(	'prd','eu','2018/11/16 18:00:00','2018/11/19 01:00:00')

#getComment(	'itk','am','2018/06/01 07:17:04','2018/06/04 07:17:04')
#getTypeInventaire('dev','eu','P')
#getLogs("/scordata_dcvprdobbatch/ubeu/log","P_ESID3700_dcvprdobbatch_20181117222453.log")
    
getChainsInfo(sys.argv[1],sys.argv[2],sys.argv[3])
