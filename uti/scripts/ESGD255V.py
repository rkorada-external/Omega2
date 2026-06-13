#! /opt/rh/rh-python38/root/usr/bin/python
#-*-coding:Latin-1 -*
from pprint import pprint

dic={}
envs=[]

#pprint(dic)


import subprocess
commande="""grep VSERQS /scordata_aen*o2batch/ub*/prm/ESGD255V.prm | sed -e s"/.scordata_aen//"  -es"/o2batch.ub/ /" -es"/.prm.ESGD255V.prm.VSERQS_/ /" | grep -v gl | sort -u"""
resultat = subprocess.run(commande, shell=True, capture_output=True, text=True)

dic={}
for line in resultat.stdout.split("\n"):
    if( line.strip() != "") :
        #print(line)
        tab=(line.strip()).split(" ")
        if tab[0] not in envs: 
            envs.append(tab[0])
        dic[tab[0]+ " " + tab[1]+ " " + tab[2].replace("117","I17")] = tab[3]

    


print()
print(f"""{" ":<10} {"I4I":<10} {"EBS":<10} {"I17G":<10} {"I17P":<10} {"I17L":<10}""")
for env in envs: #["itk" ,"uat","in2","int"] :
    for site in ["as","eu","am"] :
        print( f"""{env + " " + site:<10} {dic[env+ " "+ site + " " + "I4I"]:<10} {dic[env+ " "+ site + " " + "EBS"]:<10} {dic[env+ " "+ site + " " + "I17G"]:<10} {dic[env+ " "+ site + " " + "I17P"]:<10} {dic[env+ " "+ site + " " + "I17L"]:<10}"""  )
    print()