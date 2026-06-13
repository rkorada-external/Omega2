#! /usr/bin/python2
import os, sys, re, time
from glob import glob
from datetime import datetime
from pprint import pprint
# =========================================
# Parameter :
# 	DLOG = repertoire des logs (obligatoire)
# 	BATCHNAME = nom de la chaine qui a plante | vide (obligatoire)
# 	ANO_D = date au format yyyy/mm/dd h:m:s (obligatoire)
# 
# Exemple :
# 	$SCRIPT/reportRunBatch.py $DLOG "ESID8900" "2022/02/21 16:33:26"
# =========================================

# Environment
DLOG = sys.argv[1]
BATCHNAME = sys.argv[2]
ANO_D = sys.argv[3]

# Constant
FORMAT_DATE = "%Y%m%d"
FORMAT_DATETIME = "%Y/%m/%d %H:%M:%S"
ANO_DATETIME = datetime.strptime(ANO_D, FORMAT_DATETIME)
ANO_TIMESTAMP = time.mktime(ANO_DATETIME.timetuple())

def getLog(lines):
	chainCT = startDatetime = endDatetime = endStatus = ""

	match = re.search( r'# Chain name    :  ._(.*)  Date :  (.*)', lines)
	if match:
		chainCT = match.group(1)
		startDatetime = match.group(2)

	match = re.search( r'# End of Chain :  ._.* (.*)  Date:  (.*)', lines)
	if match:
		endStatus = match.group(1)
		endDatetime = match.group(2)
	
	return chainCT, startDatetime, endDatetime, endStatus

date = ANO_DATETIME.strftime(FORMAT_DATE)
pattern = "/*{0}*.log".format(date)
files = filter(os.path.isfile, glob(DLOG + pattern))
listDir = sorted(files, key = os.path.getmtime)

print("ANO DATE : {0}".format(ANO_D))
print("DLOG : {0}".format(DLOG))
print("BATCH NAME : {0}".format(BATCHNAME))
print("")
# print("{0}    {1}    {2}    {3}    {4}".format("BATCH   ", "START              ", "END                ", "STATUS" , "FILE NAME"))

for index in range(len(listDir)):
	fileName = os.path.basename(listDir[index])

	if "javalog" not in listDir[index]:

		with open(listDir[index], "r") as file: lines = file.read()

		chainCT, startDatetime, endDatetime, endStatus = getLog(lines)

		if endDatetime != "" and chainCT != BATCHNAME:
			startTimestamp = time.mktime(datetime.strptime(startDatetime, FORMAT_DATETIME).timetuple())
			endTimestamp = time.mktime(datetime.strptime(endDatetime, FORMAT_DATETIME).timetuple())

			if startTimestamp <= ANO_TIMESTAMP and endTimestamp >= ANO_TIMESTAMP:
				print("#################################################################")

				# print("{0}    {1}    {2}    {3}    {4}".format(chainCT, startDatetime, endDatetime, endStatus, fileName))
				print("{0}   {1}   {2}   {3}   {4}".format(chainCT, startDatetime, endDatetime, endStatus, listDir[index]))

				match = re.findall( '# Begin of job : (.*) Date : {0}'.format(ANO_D), lines)
				if match:
					for grp in match:
						print("=================================================================")
						print("Job : {0}".format(grp))

						steps = re.findall( '# Begin of step:  ({1}_.*)  Date:  {0}\n# Function: (.*)\n# Subject: (.*)'.format(ANO_D, grp), lines)
						if steps:
							for step in steps:
								print("-----------------------------------------------------------------")
								print("Step : {0}".format(step[0]))
								print("Function : {0}".format(step[1]))
								print("Subject : {0}".format(step[2]))
