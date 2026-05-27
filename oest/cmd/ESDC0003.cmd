#! /usr/bin/python3
# -*- coding: utf-8 -*-
# ===============================================================================
# application name               : Compare data already extracted by EXTJ0010
# source name                    : ESDC0003.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 27/01/2020
# author                         : Lagha Belaid
# specifications reference       :
#                                :
# -------------------------------------------------------------------------------
# description                    : Extract delivered components between DATE1 and DATE2
# parameters                     :
#   1. FPARM - File containes parametres of comparaison
# -------------------------------------------------------------------------------
# modifications chronology       :
# [01] 20/02/2023 D.DASILVATEIXEIRA : SPIRA 99999 new job ESDC0003
# ===============================================================================

# imports
#------------------------------------------------------------------------------
import os, sys, re, subprocess, csv
from pprint import pprint

# envs
#------------------------------------------------------------------------------
DUTI = os.environ.get('DUTI')
DTMP = os.environ.get('DTMP')
DFILT = os.environ.get('DFILT')
NCHAIN = os.environ.get('NCHAIN')
NJOB = os.environ.get('NJOB')
IB = os.environ.get('IB')

# Parameters
#------------------------------------------------------------------------------
FPARM = sys.argv[1]

def get_file_var(filename):
    if not os.path.isfile(filename): raise Exception(2, "{} is not file".format(filename))

    read_file = ""
    env_file = {}
    with open(filename, "r") as f: 
        read_file = f.read()

    re_finditer = re.finditer(r'(?P<key>.*)="(?P<value>.*)"', read_file)
    for i in re_finditer:
        grp_dict = i.groupdict()
        env_file[grp_dict['key']] = grp_dict['value']

    return env_file

def search_env(env):
    _env = {
        'ITK':'AZITK',
        'UAT':'AZUAT',
        'INTZ':'AZINT',
        'IN2Z':'AZIN2',
        'MAIZ':'AZMAI',
        'CNVZ':'AZCNV',
        'PRD':'AZPRD',
        'DEV':'AZDEV',
        'default':'AZDEV'
    }

    if env in _env: return _env[env]

    return _env['default']


try:
    # print(sys.argv)
    file_var = get_file_var(FPARM)  
    # pprint(file_var)

    l_env = file_var['LENV']
    r_env = file_var['RENV']
    date1 = file_var['DATE1']
    date2 = file_var['DATE2']
    compo = '%%'

    env = search_env(r_env)
    # print(env)
    # date1 = ""
    if date1 == '': raise Exception(3, 'DATE1 is empty')
    if date2 == '': raise Exception(3, 'DATE2 is empty')
    
    NSTEP = f'{NCHAIN}_{NJOB}_01'

    print(f'DATE1   = {date1}')
    print(f'DATE2   = {date2}')
    print(f'ENV     = {env}')
    print(f'COMPO   = {compo}')


    isql_q = "use bdliv\n"
    isql_q += "go\n"
    isql_q += "select b.file, a.revision_id, a.dt_delivery, c.SPOT_ID, a.login\n"
    isql_q += "from bdliv..tdelivery a, bdliv..tcompo b , bdliv..trevision c\n"
    isql_q += "where a.branch_to_id in (select branch_env_id\n"
    isql_q += "                    from bdliv..tbranch_env\n"
    isql_q += f"                    where env_id = (select env_id from bdliv..tenv where env_LL = '{env}'))\n"
    isql_q += "and a.revision_id = b.revision_id\n"
    isql_q += f"and b.file like '{compo}'\n"
    isql_q += f"and a.dt_delivery >= '{date1}'\n"
    isql_q += f"and a.dt_delivery < dateadd(day, 1, convert(datetime, '{date2}'))\n"
    isql_q += "and a.revision_id = c.revision_id\n"
    isql_q += "order by a.dt_delivery, b.file ASC\n"
    isql_q += "go\n"

    isql_i = f'{DTMP}/{NSTEP}_{IB}_COMPONENTS.sql'
    # isql_o = f'{DTMP}/{NSTEP}_{IB}_COMPONENTS.dat'

    print('Query :')
    print(isql_q)

    with open(isql_i, "w") as f: 
        f.write(isql_q)

    # cmd = f'isql -Udom_gen_ro -PscorRO -SPRD_TPO2 -i "{isql_i}" -o "{isql_o}" -s ";" -w 1000'
    cmd = f'isql -USVC_OM_Altersis_GRP_RO -PLaRi7!H6M,Rh -SPRD_TPO2 -i {isql_i} -s ";" -w 1000'
    print(cmd)
    process = subprocess.Popen(cmd, shell=True, universal_newlines=True, stdout=subprocess.PIPE,  stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    
    if stderr: raise Exception(4, stderr)

    output = stdout.strip().split('\n')
    count = output[-1]
    print(count)

    del output[1]
    del output[-1]
    del output[-1]

    csv_f = f'{DFILT}/TNR-EXTRACT-COMPONENTS-{date1}_{date2}_REPORT.csv'
    
    with open(csv_f, 'w', newline='') as csvfile:
        csv_writer = csv.writer(csvfile, delimiter=';')
        csv_writer.writerow([f'Component of {env}', '', '', '', ''])

        for o in output:
            l = " ".join(o.split())
            ll = l.split(';')

            del ll[0]
            del ll[-1]

            csv_writer.writerow(ll)

    if os.path.exists(isql_i): os.remove(isql_i)
    # if os.path.exists(isql_o): os.remove(isql_o)

    print(f'OUTPUT : {csv_f}')

except Exception as err:
    code, msg = err.args
    print('#-------------------------------------------------------------------------')
    print(f'# Error :  {code}')
    print(f'#   {msg}')
    print('#-------------------------------------------------------------------------')
