#! /usr/bin/python3

import os,fnmatch
import re,collections,sys
import os,fnmatch
import re,json
import sys,collections
import sybpydb # il faut exportet cette variable: export PYTHONPATH=$SYBASE/$SYBASE_OCS/python/python26_64r/lib
from pprint import pprint





    
def extractRevision(file):
    f= open(file, "r")
    a = f.readlines()
    file=""
    buf=""
    composant=""
    spira=""
    revision=""
    usr=""
    dt=""
    comment=""
    for line in a:
        resultat = re.match("^----.*-----$", line.strip())
        if resultat:
            continue
        resultat = re.match("^r[0-9].*", line.strip())
        if resultat:
            if revision != "":  
                #print("debug:",line.strip())
                print(composant+";"+spira+";"+revision+";"+usr+";"+dt+";"+comment)
            infosRef=line.split("|") 
            composant=file
            revision=infosRef[0][1:].strip()
            usr=infosRef[1].strip()
            dt=infosRef[2][:20].strip()
            comment=""
            continue
        if line.startswith("#-#-#- "):
            #if revision != "":  
            file=os.path.basename((line.split(" ")[1] )).strip().split(";")[0]
            spira=line.strip().split(";")[1]
            continue
        if not line.startswith("........") :
            comment +=line.strip().replace(";",",") +" "
            regex = re.compile(r"\d{5,6}")  
            resultats = regex.findall(line.strip())
            for  result in resultats:
                #print("debug result:",result,type(result))
                if int(result) < 200000 or  int(result) > 900000:
                    spira = result.strip()
                    break ;
    if revision != "":  
        buf=composant+";"+spira+";"+revision+";"+usr+";"+dt+";"+comment
        print(buf)


def connect(base):
    conn = sybpydb.connect(
        servername='DEV_TPO2',
        user='batch', 
        #database="BTRAV",
        password='omega2--'
        )
    return  conn
      
def execQuery(query):
    try:
        print (query)
        conn = connect("BTRAV")
        cur = conn.cursor()
        cur.execute(query)
        rows = cur.fetchall()
        pprint(rows)
        results=[]
        for row in rows:
            result={}
            for i,col in enumerate(cur.description):
                result[col[0]]=row[i]
            results.append(result)
        json_result=json.dumps(results)
        pprint(json_result)
        cur.connection.commit()
    except sybpydb.Error:
        print (conn.connection.errors() )
    finally:
        cur.close()
        conn.close()


def createTable(branche):
    query="""
            USE BTRAV

            IF OBJECT_ID('dbo.SVN_REVISIONS_{branche}') IS NOT NULL                   
            BEGIN                                                      
                DROP TABLE dbo.SVN_REVISIONS_{branche}                                
            END          CREATE TABLE dbo.SVN_REVISIONS_{branche}
            (
                composant     varchar(128)     NOT NULL,
                spira         int null, 
                revision       int      NOT NULL,
                usr    varchar (16)  NOT nULL,
                dt   datetime NOT NULL,
                comment   varchar(2024) NULL
            )     
            GRANT REFERENCES ON dbo.SVN_REVISIONS_{branche} TO GOMEGA
            GRANT REFERENCES ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT SELECT ON dbo.SVN_REVISIONS_{branche} TO GCONSULT
            GRANT SELECT ON dbo.SVN_REVISIONS_{branche} TO GOMEGA
            GRANT SELECT ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT INSERT ON dbo.SVN_REVISIONS_{branche} TO GOMEGA
            GRANT INSERT ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT DELETE ON dbo.SVN_REVISIONS_{branche} TO GOMEGA
            GRANT DELETE ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT UPDATE ON dbo.SVN_REVISIONS_{branche} TO GOMEGA
            GRANT UPDATE ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT DELETE STATISTICS ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT TRUNCATE TABLE ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT UPDATE STATISTICS ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH
            GRANT TRANSFER TABLE ON dbo.SVN_REVISIONS_{branche} TO GDBBATCH

            """.format(branche=branche)  
    conn=connect("BTRAV")
    cur = conn.cursor()
    cur.execute(query) 
if __name__ == '__main__':
    file=sys.argv[1]
    branche=sys.argv[2]
    createTable(branche)
    extractRevision(file)
                                            
    #execQuery("USE BTRAV")