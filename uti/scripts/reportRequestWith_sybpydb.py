#! /opt/rh/rh-python38/root/usr/bin/python
# -*- coding: utf-8 -*-
import os, sys, subprocess, re, gzip, smtplib
from glob import glob
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from pprint import pprint
from datetime import date, timedelta, datetime
import sybpydb # il faut exportet cette variable: export PYTHONPATH=$SYBASE/$SYBASE_OCS/python/python26_64r/lib


######! /usr/bin/python3
import uuid
import fnmatch
import re,collections
import datetime
import calendar 





dateTimeObj = datetime.datetime.now() 

if dateTimeObj.weekday() == 0: td=timedelta(-3)
else :  td=timedelta(-1)
dateTimeObj += td

DATE_CLOSING = dateTimeObj.strftime("%Y%m%d") 
NB_DAYS = 11 #sys.argv[1]
print (DATE_CLOSING)




uuid.uuid4()
import getpass
username = getpass.getuser()


  
def findDay(date,format): 
    born = datetime.datetime.strptime(date, format).weekday() 
    return (calendar.day_name[born]) 
  

COULR_FONT_POS="blue"
COULR_FONT_INV="black"
COULR_FONT_NORME="White"
COULR_FONT_HEAD="White"
COULR_FONT_WEEKEND="black"
COULR_BACKROUND_NORME="RoyalBlue"
COULR_BACKROUND_WEEKEND="Gainsboro"
COULR_BACKROUND_BOOKING="Yellow"
COULR_BACKROUND_WEEKEND="lightgrey"
COULR_BACKROUND_HEAD="CadetBlue"
gabarit="""
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
	{style}
</head>
<body>
	{bodyPRD}
	{bodyMAI}
	{bodyINT}
	{bodyIN2}
	{bodyUAT}
	{bodyCNV}
	{bodyITK}
	{bodyDEV}
</body>
</html>"""

style = """
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:8.0pt;
	margin-left:0cm;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
.MsoChpDefault
	{font-family:"Calibri",sans-serif;}
.MsoPapDefault
	{margin-bottom:8.0pt;
	line-height:107%;}
@page WordSection1
	{size:841.9pt 595.3pt;
	margin:70.85pt 70.85pt 70.85pt 70.85pt;}
div.WordSection1
	{page:WordSection1;}
-->
</style>"""




COMMASPACE = ", "


    
table_DT="""
    create table #DT
    (
        i int ,
        dt datetime ,
        jour varchar(64)
    )
"""

table_req="""
    create table #req
    (
        cpt int ,
        request varchar(10),
        label varchar (64)
    )
"""

result=""
for i in range(0,NB_DAYS):
    result +=",a{day} varchar(50)".format(day=i+1)
    
table_result="""
    create table #result(
    cpt int ,
    request varchar(20)
     {result}
     
    )
""".format(result=result)

table_report="""
    select * into #report   from #DT d
    left outer join BEST..TI17REQJOBPLAN p  on d.dt  = p.dbclo_d
    LEFT OUTER JOIN #req r on p.reqcod_ct like r.request
    where 1 = 2
"""

# def execQuery(srv,query):
#     cmd = '${BCPPDIR}/bcpmulti BIDON out '+ username + '"_query.out" -Udom_gen_ro -S'+srv+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\\n" -d0 -M0 -Q"'+ query + '"'
#     # print(cmd)
#     return os.system(cmd)

# def getResultSet0(srv,query):
# 	b = execQuery(srv,query)
# 	file = open('/tmp/'+ username + '_query.out.1', 'r')
# 	b = file.readlines()
# 	tab=[]
# 	for line in b:
# 		tab.append(line.strip().split("~"))
# 		file.close()
# 	return tab

def getResultSet(srv,query,select):
    conn = sybpydb.connect(
            servername=srv+'_TPO2',
            user='SVC_OM_Altersis_GRP_RO', 
            password='LaRi7!H6M,Rh'
            )
    cur = conn.cursor()
    cur.execute("if object_id('#DT') is not null drop TABLE #DT" )
    cur.execute("if object_id('#req') is not null drop TABLE #req" )
    cur.execute("if object_id('#report') is not null drop TABLE #report" )
    cur.execute("if object_id('#result') is not null drop TABLE #result" )

    cur.execute(table_DT)
    cur.execute(table_req)
    cur.execute(table_report)
    cur.execute(table_result)
 
    cur.execute(query)
    #print("------  query --------------")
    #print( query)
    #print("------  select --------------")
    #print(select)
    cur.execute(select)
    #print( "Query Returned %d row(s)" % cur.rowcount)
    rows =cur.fetchall()
    #pprint(rows)    
    return rows



 

query="""
declare @dt datetime , @nbd int ,@site char(4)

select @dt = '{date}', @nbd = {nbd}, @site = '{site}'
--select * from BEST..TI17REQ order by 1


declare @i int
select @i =0

while @i < @nbd
BEGIN
    insert into #DT values(
	@i+1,
	dateadd(day,@i,@dt),
	convert(varchar,dateadd(day,@i,@dt),102)  +  '<br /> ' +
	 case
	when datepart(weekday,dateadd(day,@i,@dt)) = 1 then 'Sunday'
	when datepart(weekday,dateadd(day,@i,@dt)) =2 then 'Monday'
	when datepart(weekday,dateadd(day,@i,@dt)) = 3 then 'Tuesday'
	when datepart(weekday,dateadd(day,@i,@dt)) = 4 then 'Wednesday'
	when datepart(weekday,dateadd(day,@i,@dt)) = 5 then 'Thursday'
	when datepart(weekday,dateadd(day,@i,@dt)) = 6 then 'Friday '
	when datepart(weekday,dateadd(day,@i,@dt)) = 7 then 'Saturday'
    end
	)
    select @i = @i +1
END


--select * from #DT



insert into #req values(1,'I4I%','IFRS 4')
insert into #req values(2,'EBS%','EBS')
insert into #req values(3,'I17G%','IFRS 17 Group')
insert into #req values(4,'I17P%','IFRS 17 Parent')
insert into #req values(5,'I17L%','IFRS 17 Local')
insert into #req values(6,'%O','Micro AOC')
insert into #req values(11,'Y','local IFRS4')
--insert into #req values(7,'S','SAP')
--insert into #req values(8,'A','Life plan')
--insert into #req values(9,'R','Retro. Accounting Freeze')
--insert into #req values(10,'V','Settlement Booking')
--insert into #req values(12,'Z','Chargement Inv')
--insert into #req values(13,'L','Stat/Reporting Life')
--insert into #req values(14,'M','Ultimates update on exchnge rate')
insert into #report
select *    from #DT d
left outer join BEST..TI17REQJOBPLAN p  on d.dt  = p.dbclo_d
LEFT OUTER JOIN #req r on p.reqcod_ct like r.request
where p.DBCLO_D between @dt and dateadd(day,@nbd,@dt)
and (p.SITE_CF =@SITE or p.SITE_CF = 'ALL')
order by r.cpt , d.dt
update #report set CLOTYP_CT="POSX" where REQCOD_CT like "%POSX"
"""


case=""
for i in range(0,NB_DAYS):
    case +=""",case	 when rp{day}.BALSHEYEA_NF = null then ''	 else     convert(varchar,rp{day}.BALSHEYEA_NF) + '/' +     convert(varchar,rp{day}.BALSHTMTH_NF) + ' ' +     convert(varchar,rp{day}.CLOTYP_CT ) + case  when rp{day}.REQCOD_CT like '%P'  then 'P'	 else ''	 end + case  when rp{day}.REQCOD_CT like '%B'  then '-Book'	 else ''	 end end a{day}
    """.format(day=i+1)

join="""
    left outer join #report rp1 on rp1.request=  rq.request  and rp1.dt = '{dt}'
""".format(dt=DATE_CLOSING)

for i in range(1,NB_DAYS):
    join +="""left outer join #report rp{day} on rp{day}.request=  rq.request  and rp{day}.dt = dateadd(day,{day_1},'{dt}')
    """.format(day=i+1,day_1=i,dt=DATE_CLOSING)

select="""
    select
        rq.cpt
        ,rq.label
        {case}
      from #req rq
    {join}
""".format(case=case,join=join) 


#query="select * from BEST..TI17REQJOBPLAN"
def getResults(srv):
	global  request_AS,request_EU,request_AM,query,select 
	request_AS = getResultSet(srv,query.format(site="SGP1",date=DATE_CLOSING ,nbd=NB_DAYS),select)
	request_EU = getResultSet(srv,query.format(site="FRA1",date=DATE_CLOSING ,nbd=NB_DAYS),select)
	request_AM = getResultSet(srv,query.format(site="USA1",date=DATE_CLOSING ,nbd=NB_DAYS),select)
	#pprint(request_AS)
	#pprint(request_EU)
	#pprint(request_AM)


def makeHead():
	bkr="background:{};".format(COULR_BACKROUND_HEAD)
	couleur_font=COULR_FONT_HEAD
	align="text-align:center;"
	h ="""
			<td
				valign=bottom
				style=' border-top:none;

			>
				<p class=MsoNormal style='
					line-height:normal'>
				</p>
			</td>
			<td
				valign=center
				style=' border-top:none;
						border:solid windowtext 1.0pt;
						{background}      padding:0cm 3.5pt 0cm 3.5pt;
						height:14.25pt'
				>
				<p class=MsoNormal style='margin-bottom:0cm;
					{align}
					line-height:normal'>
					<span
						style='font-size:10.0pt;
						font-family:"Tahoma",sans-serif;
						color:{couleur_font}'>{value}
					</span>
				 </p>
			</td>""".format(value="   SITE   ",background=bkr,couleur_font=couleur_font,align=align)
	for i in range(0,NB_DAYS):
		value=datetime.datetime.strftime(datetime.datetime.strptime(DATE_CLOSING, '%Y%m%d') + timedelta(days=i),"%d/%m/%Y|%A" ).replace('|','</br>')
		#value=datetime.datetime.strftime(datetime.datetime.strptime(DATE_CLOSING, '%Y%m%d') + timedelta(days=i),"%d/%m/%Y" )
		#value=findDay(value,"%d/%m/%Y" )
		if "Sunday" in  value or "Saturday" in value:
				bkr="background:{};".format(COULR_BACKROUND_WEEKEND)
				couleur_font=COULR_FONT_WEEKEND
		else:
			bkr="background:{};".format(COULR_BACKROUND_HEAD)
			couleur_font=COULR_FONT_HEAD
		h +="""
					<td
						valign=center
						style=' border-top:none;
								border:solid windowtext 1.0pt;
								{background}      padding:0cm 3.5pt 0cm 3.5pt;
								height:14.25pt'
					>
						<p class=MsoNormal style='margin-bottom:0cm;
							{align}
							line-height:normal'>
							<span
								style='font-size:10.0pt;
								font-family:"Tahoma",sans-serif;
								color:{couleur_font}'>{value}
							</span>
						 </p>
					</td>""".format(value=value,background=bkr,couleur_font=couleur_font,align=align)
	return h

def row(req,j,site):
	align=""
	r = ""
	#print("req:------",req)
	for i in range(1,NB_DAYS +2):
		cel = req[i]
		bkr=""
		if "Book" in cel: bkr="background:wheat;"

		if "POS" in cel :
			#couleur ="lightskyblue"
			couleur_font ="blue"
		else :
			couleur_font ="black"


		if i == 1  :
			if site == "AS" :
				bkr="background:{};".format(COULR_BACKROUND_NORME)
				couleur_font ="white"
				r +="""
					<td
						rowspan=3
						valign=center
						style=' border-top:none;
								border:solid windowtext 1.0pt;
								{background}      padding:0cm 3.5pt 0cm 3.5pt;
								height:14.25pt'
					>
						<p class=MsoNormal style='margin-bottom:0cm;
							{align}
							line-height:normal'>
							<span
								style='font-size:10.0pt;
								font-family:"Tahoma",sans-serif;
								color:{couleur_font}'>{value}
							</span>
						 </p>
					</td>""".format(value=cel,background=bkr,couleur_font=couleur_font,align=align)
			bkr=""
			couleur_font ="black"
			r +="""
				<td
					valign=bottom
					style=' border-top:none;
							border:solid windowtext 1.0pt;
							{background}      padding:0cm 3.5pt 0cm 3.5pt;
							height:14.25pt'
				>
					<p class=MsoNormal style='margin-bottom:0cm;
						{align}
						line-height:normal'>
						<span
							style='font-size:10.0pt;
							font-family:"Tahoma",sans-serif;
							color:{couleur_font}'>{value}
						</span>
					 </p>
				</td>""".format(value=site,background=bkr,couleur_font=couleur_font,align=align)

		else:
			value=datetime.datetime.strftime(datetime.datetime.strptime(DATE_CLOSING, '%Y%m%d') + timedelta(days=i-2),"%d/%m/%Y|%A" ).replace('|','</br>')
			#value=datetime.datetime.strftime(datetime.datetime.strptime(DATE_CLOSING, '%Y%m%d') + timedelta(days=i-2),"%d/%m/%Y" )
			#day=findDay(value,"%d/%m/%Y" )
			if "Sunday" in  value or "Saturday" in value:
				bkr="background:{};".format(COULR_BACKROUND_WEEKEND)

			r +="""
					<td
						valign=bottom
						style=' border-top:none;
								border:solid windowtext 1.0pt;
								{background}      padding:0cm 3.5pt 0cm 3.5pt;
								height:14.25pt'
					>
						<p class=MsoNormal style='margin-bottom:0cm;
							{align}
							line-height:normal'>
							<span
								style='font-size:10.0pt;
								font-family:"Tahoma",sans-serif;
								color:{couleur_font}'>{value}
							</span>
						 </p>
					</td>""".format(value=cel,background=bkr,couleur_font=couleur_font,align=align)
	align="text-align:center;"
	return r



def makeBody(srv):
    j=0

    titre="""
    <p class=MsoNormal style='margin-bottom:0cm;line-height:27.0pt;background:#F8F9FA'>
    <span lang=EN style='font-size:21.0pt;font-family:"inherit",serif;color:#202124'>
        {0}  environment request report for the next {1} days
    </span>
    </p>
    <p class=MsoNormal><span lang=EN-US>&nbsp;</span></p>
    """.format(srv,NB_DAYS)

    table =""
    getResults(srv)
    for req in request_AS:
        #v=""
        #for i in range(2,NB_DAYS+2):
        #    v +=request_AS[j][i].strip() + request_EU[j][i].strip() + request_AM[j][i].strip()
   
        table += "<tr style='height:14.25pt'>{row}      </tr>\n".format(row=row(request_AS[j],j+1,"AS"))\
                + "<tr style='height:14.25pt'>{row}     </tr>\n".format(row=row(request_EU[j],j+1,"EU"))\
                + "<tr style='height:14.25pt'>{row}     </tr>\n".format(row=row(request_AM[j],j+1,"AM"))
        #print(j,request_AS[j])
        j +=1


    table_1 = "<table>{0}{1}</table>".format(makeHead(),table)


    body = titre+table_1
    body += "<br>"
    return body




def makeHtmlPROD():
	return  gabarit.format( style=style,	      \
							bodyPRD=makeBody("PRD"),  \
							bodyMAI=makeBody("MAI"),  \
							bodyINT="",	       \
							bodyIN2="",	       \
							bodyUAT="",	       \
							bodyCNV="",	       \
							bodyITK="",	       \
							bodyDEV="")

def makeHtmlBusiness():
	return  gabarit.format(	      \
			style=style,		 \
			bodyPRD="",		  \
			bodyMAI="",			      \
			bodyINT=makeBody("INT"),     \
			bodyIN2=makeBody("IN2"),     \
			bodyUAT=makeBody("UAT"),     \
			bodyCNV=makeBody("CNV"),     \
			bodyITK="",		  \
			bodyDEV="")

def makeHtmlIT():
	return  gabarit.format(	     \
			style=style,		\
			bodyPRD="",		 \
			bodyMAI="",			     \
			bodyINT="",		 \
			bodyIN2="",		 \
			bodyUAT="",		 \
			bodyCNV="",		 \
			bodyITK=makeBody("ITK"),    \
			bodyDEV=makeBody("DEV"))


def senMail(html,objet,receiver):
	subject = "{0}  request report ".format( objet)
	sender = "{0}.Requests.report@scor.com".format( objet)

	message = MIMEMultipart()
	message["From"] = sender
	message["To"] = COMMASPACE.join(receiver)
	message["Subject"] = subject

	partHtml = MIMEText(html, "html")
	encoders.encode_base64(partHtml)
	message.attach(partHtml)

	server = smtplib.SMTP('localhost')
	#server.set_debuglevel(1)
	server.sendmail(sender, receiver, message.as_string())
	server.quit()





receiver_PROD=['mnaji@scor.com','mbrik-external@scor.com','akalluru-external@scor.com']
receiver_Business=['mnaji@scor.com','mbrik-external@scor.com','akalluru-external@scor.com']
receiver_IT=['mnaji@scor.com','mbrik-external@scor.com','akalluru-external@scor.com']



receiver_PROD=["mnaji@scor.com"]
receiver_Business=["mnaji@scor.com"]
receiver_IT=["mnaji@scor.com"]


receiver_PROD=["DEVclosingmanagement@scorglobal.onmicrosoft.com"]
receiver_Business=["DEVclosingmanagement@scorglobal.onmicrosoft.com"]
receiver_IT=["DEVclosingmanagement@scorglobal.onmicrosoft.com"]


receiver_PROD=['mnaji@scor.com'
    ,'mbrik-external@scor.com'
    ,'kngoran@scor.com'
    ,'tdeutsch-external@scor.com'
    ,'SPIGOT@scor.com'
    ,'SKESAVAMOORTHY@scor.com'
    ,'LYDIER@scor.com'
    ,'PPOUX@scor.com'
    ,'SLONGEAU@scor.com'
    ,'RFLOUQUET-EXTERNAL@scor.com'
    ,'CTRUFFAUT-EXTERNAL@scor.com'
    ,'YPERSEE-EXTERNAL@scor.com'
    ,'MZANGUIM-EXTERNAL@scor.com'
    ]
receiver_Business=["mnaji@scor.com"
    ,"mbrik-external@scor.com"
    ,"kngoran@scor.com"
    ,"tdeutsch-external@scor.com"
    ,'SPIGOT@scor.com'
    ,"slongeau@scor.com"
    ,'YPERSEE-EXTERNAL@scor.com'
    ,'MZANGUIM-EXTERNAL@scor.com']
receiver_IT=["kngoran@scor.com"
    ,"OmegaCapgeminiTeam@scor.com"
    ,"OmegaAscottTeam@scor.com"
    ,'SPIGOT@scor.com'
    ,"slongeau@scor.com"
    ]
   

receiver_PROD=['akalluru-external@scor.com','mujain-external@scor.com','djain-external@scor.com']
receiver_Business=['akalluru-external@scor.com','mujain-external@scor.com','djain-external@scor.com']
receiver_IT=['akalluru-external@scor.com','mujain-external@scor.com','djain-external@scor.com']


senMail(makeHtmlPROD(),"PROD",receiver_PROD)
senMail(makeHtmlBusiness(),"Business",receiver_Business)
senMail(makeHtmlIT(),"IT",receiver_IT)
 
