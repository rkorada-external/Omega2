#! /usr/bin/python
import sys,csv
#-------------------------------------------------------#
# This script parses a file and retruns the size of		# 
# the largest item and its index (row),					#
# It taks file name & column number as parameters :		#
# Check_Max_Len.py file_name col_number    				#
#-------------------------------------------------------#
with open(sys.argv[1], 'r') as my_file:
    reader = csv.reader(my_file)
    col	= int(sys.argv[2])
    j = 0
    sizeMaxRef	= 0
    index_Ref 	= 0
    for row in reader:
        for item in row:
            cpt = 0
            count = 0
            sizeMax = 0
            for i in item:
                if i == '~':
					cpt = cpt + 1
					if cpt == col:
						sizeMax = count
						break
					else:
						count = 0
                elif i != ' ':
					count = count + 1
        j = j + 1
        if sizeMaxRef < sizeMax:
            sizeMaxRef = sizeMax
            index_Ref = j
    print ('Max size :' + str(sizeMaxRef))
    print ('Line :' + str(index_Ref))
