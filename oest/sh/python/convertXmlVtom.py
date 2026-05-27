#! /usr/bin/env python
#-*-coding:Latin-1 -*

import os, sys,datetime,time
import uuid

import xml.etree.ElementTree as ET




def getChains ( fin, fout, foutClosinChain,fsql ):
	fp = open(fin,"r")
	fp_out = open(fout,"w")
	fp_sql = open(fsql,"w")
	fp_sql.write("USE TEMPDB                               \n")
	fp_sql.write("go                                       \n")
	fp_sql.write("IF OBJECT_ID('VTOM_CLOS') IS NOT NULL    \n")
	fp_sql.write("BEGIN                                    \n")
	fp_sql.write("    DROP TABLE VTOM_CLOS                 \n")
	fp_sql.write("END                                      \n")
	fp_sql.write("go                                       \n")
	fp_sql.write("                                         \n")
	fp_sql.write("                                         \n")
	fp_sql.write("create table VTOM_CLOS                   \n")
	fp_sql.write("(                                        \n")
	fp_sql.write("    Application	 varchar(30) null,     \n")
	fp_sql.write("    JOB_Name	varchar(30) null,          \n")
	fp_sql.write("    JOB	        varchar(30) null,      \n")
	fp_sql.write("    Param       varchar(50) null,        \n")
	fp_sql.write("    Description  varchar(124) null,       \n")
	fp_sql.write("    env       varchar(50) null,        \n")
	fp_sql.write("    IDF_CT       varchar(50) null,        \n") 
	fp_sql.write("    NORME       varchar(50) null,       \n")
	fp_sql.write("    VTYPEAOC       varchar(50) null        \n")
	fp_sql.write("                                         \n")
	fp_sql.write(")                                        \n")
	fp_sql.write("go                                       \n")
	fp_out_clo_chain = open(foutClosinChain,"w")
	fp_out.write("Application;JOB Name;JOB;Paramètres;Description\n" )
	fp_out_clo_chain.write("Application;JOB\n" )
	root = ET.parse(fp)
	e_app = root.findall('Environments/Environment/Applications/Application')
	for app in e_app:
		app_name=app.attrib["name"]
		#print  app_name
		xpath='Environments/Environment/Applications/Application[@name="'+app_name+'"]/Variables/Variable'
		variables=root.findall(xpath)
		VNORME=""
		VTYPEAOC=""
		for variable in variables:
			if variable.attrib["name"] == "VNORME":  VNORME=variable.attrib["value"]
			if variable.attrib["name"] == "VTYPEAOC":  VTYPEAOC=variable.attrib["value"]
		#print VNORME, VTYPEAOC
		xpath='Environments/Environment/Applications/Application[@name="'+app_name+'"]/Jobs/Job'
		#print xpath
		for job in root.findall(xpath):
			#print job
			job_name=job.attrib["name"]
			comment=""
			if "comment" in job.attrib:
				comment=job.attrib["comment"]
			xpath='Environments/Environment/Applications/Application[@name="'+app_name+'"]/Jobs/Job[@name="'+job_name+'"]/Script'
			cmd_name=root.findall(xpath)[0].text
			NCHAIN=root.findall(xpath)[0].text.replace("#$DCMD/","" ).replace(".cmd","")
			xpath='Environments/Environment/Applications/Application[@name="'+app_name+'"]/Jobs/Job[@name="'+job_name+'"]/Parameters/Parameter'
			parameters=root.findall(xpath)
			xpath='Environments/Environment/Applications/Application[@name="'+app_name+'"]/Jobs/Job[@name="'+job_name+'"]/Node'
			#print app_name, job_name, NCHAIN , xpath
			coord=root.findall(xpath)
			x=coord[0].attrib["x"]
			y=coord[0].attrib["y"]
			buf = app_name +";" + job_name + ";" + cmd_name + "; "+str(x)+ "; "+str(y)+ "; "
			params=""
			params2=["","",""]
			i=0
			for paramter in  parameters:
					buf += " "+ paramter.text.replace("$(echo $VNORME)",VNORME).replace("$(echo $VTYPEAOC)",VTYPEAOC).replace('$(echo $TOM_JOB | cut -d"_" -f2)',NCHAIN)
					if i < 2 :
						params2[i]=paramter.text.replace("$(echo $VNORME)",VNORME).replace("$(echo $VTYPEAOC)",VTYPEAOC).replace('$(echo $TOM_JOB | cut -d"_" -f2)',NCHAIN)
					i +=1
					params +=  " "+ paramter.text.replace("$(echo $VNORME)",VNORME).replace("$(echo $VTYPEAOC)",VTYPEAOC).replace('$(echo $TOM_JOB | cut -d"_" -f2)',NCHAIN)
			params2[0]=params2[0].replace("=",cmd_name.replace("#$DCMD/","" ).replace(".cmd","") + ".env")
			params2[1]=params2[1].replace('$(echo $TOM_JOB | cut -d"_" -f2)',cmd_name.replace("#$DCMD/","" ).replace(".cmd",""))
			IDF_CT=params2[1].replace('$(echo $TOM_JOB | cut -d"_" -f2)',cmd_name.replace("#$DCMD/","" ).replace(".cmd",""))
			if IDF_CT == "" :IDF_CT =NCHAIN
			#params2[1]=params2[1].replace("$(echo $VNORME)",VNORME) 
			#params2[1]=params2[1].replace("$(echo $VTYPEAOC)",VTYPEAOC) 
			buf += ";" + comment + ";" + VNORME+";" + VTYPEAOC +";" +IDF_CT
			#buf += "insert into TEMPDB..VTOM_CLOS values('{0}','{1}','{2}','{3}','{4}','{5}')".format( app_name,job_name,cmd_name.encode('utf-8'),str(x),str(y),comment.encode('utf-8'))
			if cmd_name.startswith("#$DCMD"):
				if params2[1] =='Y' or params2[1] =='Q' or params2[1] =='M'  : IDF_CT = NCHAIN                           
				if params2[1] =="I4_PC___" or params2[1] =="I4_PC_C__" or params2[1] =="I4_PC_M__"  : IDF_CT = NCHAIN + "_" +   params2[1]                       
				fp_out.write(buf.replace("#$DCMD/","" ).encode('utf-8').replace(".cmd","") +"\n") 
				fp_out_clo_chain.write(app_name +";" +  cmd_name.replace("#$DCMD/","" ).encode('utf-8').replace(".cmd","") +"\n" )
				if( app_name.startswith("EOMA_")):
					#fp_sql.write("insert into VTOM_CLOS values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}')\n".format( app_name.encode('utf-8'),job_name.encode('utf-8'),cmd_name.encode('utf-8').replace("#$DCMD/","" ).encode('utf-8').replace(".cmd","") ,params.encode('utf-8'),comment.encode('utf-8').replace("'","\""),params2[0].encode('utf-8'),params2[1].encode('utf-8'),params2[2].encode('utf-8')))
					fp_sql.write("insert into VTOM_CLOS values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')\n".format( app_name.encode('utf-8'),job_name.encode('utf-8'),NCHAIN ,params.encode('utf-8'),comment.encode('utf-8').replace("'","\""),params2[0].encode('utf-8'),IDF_CT, VNORME, VTYPEAOC ))
	fp_sql.write("GO\n")
	fp.close()
	fp_out.close()
	fp_out_clo_chain.close() 
	fp_sql.close()
#getChains(sys.argv[1],sys.argv[2],sys.argv[3])
bn=os.path.splitext(os.path.basename(sys.argv[1]))[0]+"_" + time.strftime('%Y%m%d') 
fsql=os.environ.get('DFILT')+"/"+os.path.splitext(os.path.basename(sys.argv[1]))[0]+".sql" 
print bn
getChains(sys.argv[1],os.environ.get('DFILT')+"/"+bn+".csv",os.environ.get('DFILT')+"/"+bn+"_chain.csv",fsql)    

