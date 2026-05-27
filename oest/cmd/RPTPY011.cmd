#! /opt/rh/rh-python38/root/usr/bin/python3
import os, sys, re
import sybpydb
import gzip
import pandas as pd
from pathlib import Path
from datetime import datetime, timedelta, date
from zipfile import ZipFile

def get_prm(file_path):
    result = {}
    try:
        with open(file_path, 'r') as file:
            for line_number, line in enumerate(file, start=1):
                regex = r'(?P<key>.+) (?P<value>.+)'
                m = re.search(regex, line)
                if m:
                    result[m.group('key')] = m.group('value')
    except FileNotFoundError:
        print(f"The file '{file_path}' does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")
    
    return result

def get_parm(file_path):
    result = {}
    try:
        with open(file_path, 'r') as file:
            for line_number, line in enumerate(file, start=1):
                regex = r'export (?P<key>.+)=(?P<value>.+)'
                m = re.search(regex, line)
                if m:
                    result[m.group('key')] = m.group('value')
    except FileNotFoundError:
        print(f"The file '{file_path}' does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")
    
    return result

def get_data(file_path):
    result = {}
    try:
        with open(file_path, 'r') as file:
            for line_number, line in enumerate(file, start=1):
                line_data = line.strip().split('~')
                result[line_number] = line_data
    except FileNotFoundError:
        print(f"The file '{file_path}' does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")
    
    return result

def exec_sql(srv, query):
    connection = sybpydb.connect(servername=srv, user='SVC_OM_Altersis_GRP_RO', password='LaRi7!H6M,Rh')
    cursor = connection.cursor()

    result = None
    try:
        cursor.execute(query)
        result = cursor.fetchall()
    except sybpydb.Error:
        for err in cursor.connection.messages:
            print(f"Exception {err[0]}, Value {err[1]}")
            exit(1)
    finally:
        cursor.close()
        connection.close()
    
    return result

def extract_esfj000_parm(site, norm):
    result = {}
    file = ''
    perm_path = Path(scor_data_path, f'ub{site.lower()}', 'perm')
    pattern = f'{prefix_arg}_ESFJ0000_PARM_{norm.upper()}.dat'
    for parm_file in perm_path.glob(pattern):
        file = parm_file
        result = get_parm(parm_file)
    return result, file

def get_esfj000_parm(parm_data):
    try:
        result = {}
        if date_arg:
            parm_data['PARM_CRE_D'] = date_arg
        if typeinv_arg:
            parm_data['PARM_TYPEINV'] = typeinv_arg

        result = {
            'TYPEINV': parm_data['PARM_TYPEINV'],
            'CRE_D': parm_data['PARM_CRE_D']
        }
        for key in result: 
            if result[key].isdigit(): result[key] = int(result[key])

    except Exception as e:
        print(f'An error occurred: {e}')
    
    return result

def sql_parm(site, cre_d):
    usr = f'ub{site.lower()}'
    srv = f'{env_arg}_TPO2'

    dt_1 = datetime.strptime(str(cre_d), "%Y%m%d")
    dt_str_1 = f'{dt_1.date()} 15:00:00'

    current_date = date.today()
    # Get current day of the week (Monday = 0, ..., Sunday = 6)
    if current_date.weekday() == 0:
        dt_2 = current_date
        dt_str_2 = f'{dt_2} 09:00:00'
    else:
        dt_2 = dt_1 + timedelta(days=1)
        dt_str_2 = f'{dt_2.date()} 15:00:00'

    return usr, srv, dt_str_1, dt_str_2

def create_dataframe(columns, data):
    df_columns = columns.strip().split(',')

    if data:
        df = pd.DataFrame(data, columns=df_columns)
    else:
        df = pd.DataFrame(columns=df_columns)
    
    return df

def extract_esfd3860_data(site, norm, typeinv, cre_d):
    result = {}
    data = {}
    file = ''
    perm_path = Path(scor_data_path, f'ub{site.lower()}', 'perm')

    pattern = f"{prefix_arg}_ESFD3860_{norm}_PRO_INT_STD_PI_REPORT_{typeinv}_{cre_d}.dat"
    files = perm_path.glob(pattern)
    for f in files:
        data = get_data(f)
        file = f

    for key in data:
        item = f'{data[key][0]}_{data[key][1]}_{data[key][2]}_{data[key][3]}'
        if item not in result:
            result[item] = data[key]
    
    return result, file, data

def analyse_esfd3860_report(data):
    report = {
        'ok': 0,
        'ko': 0,
        'total': 0
    }
    for key in data:
        status_data = data[key][2]

        if status_data == 'OK':
            report['ok'] +=1
        else:
            report['ko'] +=1
        report['total'] +=1
    return report

def extract_esij0800_error_data(site, cre_d):
    usr, srv, dt_str_1, dt_str_2 = sql_parm(site, cre_d)

    query = f'''
    SELECT DISTINCT suiv.NUMFIC_NT, suiv.SSD_CF, suiv.ESB_CF, suiv.NOMFICORIG_LL, suiv.FICSTS_CF, suiv.NBLGTOT_NT, suiv.NBLGKO_NT, mess.MESS_L, mess.MESS_N, acc.NUMLIGNE_NT, suiv.INTEG_D
    FROM BCTA.dbo.TSUIVINTACC suiv
    LEFT JOIN BCTA.dbo.TANOINTACC acc
    ON suiv.NUMFIC_NT = acc.NUMFIC_NT AND suiv.SSD_CF = acc.SSD_CF AND suiv.ESB_CF = acc.ESB_CF
    INNER JOIN BREF.dbo.TMESSAGE mess
    ON acc.MESS_N = mess.MESS_N AND mess.LANG_C = 'E' AND mess.MESSTHM_C = 'ESTIMATION'
    WHERE suiv.INTEG_D >= '{dt_str_1}'
    AND suiv.INTEG_D < '{dt_str_2}'
    AND suiv.USR_CF = '{usr}'
    AND suiv.NOMFICORIG_LL like '%ESIJ0800%_1-CSMENG%'
    ORDER BY suiv.INTEG_D DESC
    '''
    print(query)

    data = exec_sql(srv, query)
    return data

def extract_esij0800_data(site, cre_d):
    usr, srv, dt_str_1, dt_str_2 = sql_parm(site, cre_d)

    query = f'''
    SELECT SSD_CF, ESB_CF, USR_CF, FICSTS_CF
    FROM BCTA..TSUIVINTACC  
    WHERE NOMFICORIG_LL like '%ESIJ0800%_1-CSMENG%'
    AND USR_CF = '{usr}'
    AND INTEG_D >= '{dt_str_1}'
    AND INTEG_D < '{dt_str_2}'
    '''
    print(query)

    data = exec_sql(srv, query)
    return data

def analyse_esij0800_report(data):
    report = {
        'ok': 0,
        'ko': 0,
        'total': 0
    }
    
    for value in data:
        status_data = value[3]
        if status_data == 'OK':
            report['ok'] +=1
        else:
            report['ko'] +=1
        report['total'] +=1

    return report

def extract_esij0800_data2(site, cre_d):
    result = []
    data = {}
    file = ''
    scorftp_path = Path(scor_data_path, f'ub{site.lower()}', 'scorftp/LifeReserving/to')

    pattern = f"{prefix_arg}_ESIJ0790_REPORTFILE_{cre_d}.dat"
    files = scorftp_path.glob(pattern)
    for f in files:
        data = get_data(f)
        file = f

    for key in data:
        d = data[key][0].split(';')
        if len(d) >= 3:
            result.append(d)
    
    return result, file

def analyse_esij0800_report2(data):
    report = {
        'ok': 0,
        'ko': 0,
        'total': 0
    }
    
    for value in data:
        status_data = value[1]
        if status_data == 'OK':
            report['ok'] +=1
        else:
            report['ko'] +=1
        report['total'] +=1

    return report

def extract_esfd3860_zip_data(site, content_data):
    zip_extract_data = []
    zip_content_data = {}
    zip_content = {}

    for key in content_data:
        data = content_data[key]
        if data[2] == 'KO':
            internal_path = Path(data[3])
            zip_file = Path(scor_data_path, f'ub{site.lower()}', 'scorftp/LifeReserving/fromsave', f'{internal_path.stem}.zip')

            with ZipFile(zip_file, 'r') as z:
                with z.open(internal_path.name, 'r') as f:
                    zip_extract_data = f.readlines()

            for idx, value in enumerate(zip_extract_data):
                try:
                    texte = value.decode('utf-8')
                except UnicodeDecodeError:
                    texte = value.decode('latin-1')

                zip_content_data[f"{idx + 1}"] = texte.strip()
            
            zip_content[internal_path.name] = zip_content_data

    return zip_content

def extract_esij0800_gz_data(site, content_data):
    file_path = Path(content_data[3])

    gz_extract_data = []
    gz_content_data = {}
    gz_path = Path(scor_data_path, f'ub{site.lower()}', 'scorftp/local/fromsave')
    gz_files = gz_path.glob(f"*{data_parm['CRE_D']}*{file_path}.gz")
    
    gz_files_list = list(gz_files)
    gz_file = None
    if gz_files_list != []: gz_file = gz_files_list[0]


    if gz_file != None:
        with gzip.open(gz_file, 'rb') as f_in:
            gz_extract_data = f_in.readlines()

    nb_line = 0
    for idx, value in enumerate(gz_extract_data):
        try:
            texte = value.decode('utf-8')
        except UnicodeDecodeError:
            texte = value.decode('latin-1')

        nb_line = texte.split('~')[2]

        gz_content_data[f"{nb_line}"] = texte.strip()

    return gz_content_data


# Arguments var
env_arg = sys.argv[1]
prefix_arg = sys.argv[2]
date_arg = sys.argv[3]
typeinv_arg = sys.argv[4]

# Environments var
env_prefix_env = os.environ.get('ENV_PREFIX')
nchain_env = os.environ.get('NCHAIN')
hostname_env = os.environ.get('HOSTNAME')
srv_env = os.environ.get('SRV')

dprm_path_env = os.environ.get('DPRM')
dtmp_path_env = os.environ.get('DTMP')

ftmp_1_env = os.environ.get('RPTPY010_FTMP_1')
report_sas_ae_file_env = os.environ.get('REPORT_SAS_AE_FILE')
error_sas_ae_file_env = os.environ.get('RPTPY010_SAS_AE_ERROR_FILE')
error_sas_pai_file_env = os.environ.get('RPTPY010_SAS_PAI_ERROR_FILE')

# Constant var
site_const = ['AS', 'EU', 'AM']
norm_const = ['I17G', 'I17P', 'I17L']

# Defaults var
step_nb = 0
scor_data_path = '/scor/scordata'
if (srv_env == 'DEV_TPO2' and env_arg != 'DEV'):
    scor_data_path = f'/scordata_aen{env_arg.lower()}o2batch'

version = 'version : 1.3.0 - spira 112879'
print(f'#{"="*70}')
print(f'# Start Job RPTPY011')
print(f'{" "*2} version = {version}')
print(f'{" "*2} env = {env_arg}')
print(f'{" "*2} prefix = {prefix_arg}')
print(f'{" "*2} date = {date_arg}')
print(f'{" "*2} typeinv = {typeinv_arg}')
print(f'{" "*2} scor_data_path = {scor_data_path}')
print(f'#{"="*70}')
print(f'#')

# ===================================================================
report = {
    'PA': {
        'AS': {'ok': 0, 'ko': 0, 'total': 0},
        'EU': {'ok': 0, 'ko': 0, 'total': 0},
        'AM': {'ok': 0, 'ko': 0, 'total': 0}
    },
    'AE': {
        'AS': {'ok': 0, 'ko': 0, 'total': 0},
        'EU': {'ok': 0, 'ko': 0, 'total': 0},
        'AM': {'ok': 0, 'ko': 0, 'total': 0}
    }
}
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : SAS profitability files')
print(f'#')

error_sas_pai_file = []
for site in site_const:
    print(f'  {"="*30} {site} {"="*30}')

    report_site = {
        'ok': 0,
        'ko': 0,
        'total': 0
    }
    for norm in norm_const:
        print(f'{" "*2} -- {site} {norm} --')
        
        esfj000_parm_data, esfj000_parm_file = extract_esfj000_parm(site, norm)
        data_parm = get_esfj000_parm(esfj000_parm_data)

        print(f'{" "*4} PARM file :', esfj000_parm_file)
        print(f'{" "*4} PARM data :', data_parm)

        try:
            esfd3860_data, esfd3860_file, esfd3860_data_full = extract_esfd3860_data(site, norm, data_parm['TYPEINV'], data_parm['CRE_D'])
            esfd3860_report = analyse_esfd3860_report(esfd3860_data)
            
            print(f'{" "*4} REPORT file :', esfd3860_file)
            print(f'{" "*4} REPORT result :', esfd3860_report)

            report_site['ok'] += esfd3860_report['ok']
            report_site['ko'] += esfd3860_report['ko']
            report_site['total'] += esfd3860_report['total']

            zip_content = extract_esfd3860_zip_data(site, esfd3860_data)

            for key in esfd3860_data_full:
                data = esfd3860_data_full[key]
                if data[2] == 'KO':
                    nb = data[10]
                    if data[10] == '0':
                        nb = '1'

                    line_number = ''
                    if nb in zip_content[data[3]]: line_number = zip_content[data[3]][nb]

                    date_formated = datetime.strptime(data[9], "%Y%m%d%H:%M:%S")
                    new_data = [data[0], data[1], data[3], date_formated, data[2], data[5], data[6], data[11], data[10], line_number]
                    print(new_data)
                    error_sas_pai_file.append(new_data)

        except Exception as e:
            print(f'An error occurred: {e}')

    report['PA'][site] = report_site
    print(f'{" "*2} Report Global result :', report_site)

print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')


# ===================================================================
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : SAS Assistance entry files')
print(f'#')

error_sas_ae_file = []
for site in site_const:
    print(f'  {"="*30} {site} {"="*30}')

    report_site_2 = {
        'ok': 0,
        'ko': 0,
        'total': 0
    }

    esfj000_parm_data, esfj000_parm_file = extract_esfj000_parm(site, 'I17G')
    data_parm = get_esfj000_parm(esfj000_parm_data)

    print(f'{" "*4} PARM file :', esfj000_parm_file)
    print(f'{" "*4} PARM data :', data_parm)

    try:
        esij0800_data, esij0800_file = extract_esij0800_data2(site, data_parm['CRE_D'])
        esij0800_report_2 = analyse_esij0800_report2(esij0800_data)

        print(f'{" "*4} REPORT file :', esij0800_file)
        print(f'{" "*4} REPORT result :', esij0800_report_2)

        report_site_2['ok'] += esij0800_report_2['ok']
        report_site_2['ko'] += esij0800_report_2['ko']
        report_site_2['total'] += esij0800_report_2['total']

        for data in esij0800_data:
            if data[1] == 'KO':
                d = data[0].split("_")
                date_modif = datetime.fromtimestamp(esij0800_file.stat().st_mtime)
                date_formated = datetime.strftime(date_modif, "%Y-%m-%d %H:%M:%S")

                new_data = [d[3], d[4], data[0], date_formated, data[1], "", "", data[2], "", ""]
                print(new_data)
                error_sas_ae_file.append(new_data)

    except Exception as e:
        print(f'An error occurred: {e}')
    
    # report['AE'][site]['ok'] += report_site_2['ok']
    report['AE'][site]['ko'] += report_site_2['ko']
    # report['AE'][site]['total'] += report_site_2['total']

print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')


# ===================================================================
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : SAS Assistance entry Table TSUIVINTACC')
print(f'#')

for site in site_const:
    print(f'  {"="*30} {site} {"="*30}')

    report_site_1 = {
        'ok': 0,
        'ko': 0,
        'total': 0
    }

    esfj000_parm_data, esfj000_parm_file = extract_esfj000_parm(site, 'I17G')
    data_parm = get_esfj000_parm(esfj000_parm_data)

    print(f'{" "*4} PARM file :', esfj000_parm_file)
    print(f'{" "*4} PARM data :', data_parm)


    try:
        esij0800_data = extract_esij0800_data(site, data_parm['CRE_D'])
        esij0800_report_1 = analyse_esij0800_report(esij0800_data)
        print(f'{" "*4} REPORT result :', esij0800_report_1)

        report_site_1['ok'] += esij0800_report_1['ok']
        report_site_1['ko'] += esij0800_report_1['ko']
        report_site_1['total'] += esij0800_report_1['total']

        esij0800_error_data = extract_esij0800_error_data(site, data_parm['CRE_D'])

        for data in esij0800_error_data:
            gz_content_data = extract_esij0800_gz_data(site, data)
            nb = str(data[9])
            # if nb == '0':
            #     nb = '1'

            line_number = ''
            if nb in gz_content_data: line_number = gz_content_data[nb]
            
            # "SSD_CF,ESB_CF,SAS AE file,Integration date,Status,Total line,KO line,Error message,line number,Error line"
            new_data = [data[1], data[2], data[3], data[10], data[4], data[5], data[6], data[7], data[9], line_number]
            print(new_data)
            error_sas_ae_file.append(new_data)

    except Exception as e:
        print(f'An error occurred: {e}')

    report['AE'][site]['ok'] += report_site_1['ok']
    report['AE'][site]['ko'] += report_site_1['ko']

    report['AE'][site]['total'] = report['AE'][site]['ok'] + report['AE'][site]['ko']


print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')


# ===================================================================
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Generate Error data excel file')
print(f'#')

try:
    columns_error_sas_ae_file = "SSD_CF,ESB_CF,SAS AE file,Integration date,Status,Total line,KO line,Error message,line number,Error line"
    df_error_sas_ae_file = create_dataframe(columns_error_sas_ae_file, error_sas_ae_file)

    file_excel_report_error = Path(error_sas_ae_file_env)
    with pd.ExcelWriter(file_excel_report_error) as writer:  
        df_error_sas_ae_file.to_excel(writer, sheet_name='SAS AE Error report', index=False)
    print(f'{" "*4} Excel file SAS AE : OK')

except Exception as e:
    print(f'An error occurred: {e}')

try:
    columns_error_sas_pai_file = "SSD_CF,ESB_CF,SAS PAI file,Integration date,Status,Total line,KO line,Error message,line number,Error line"
    df_error_sas_pai_file = create_dataframe(columns_error_sas_pai_file, error_sas_pai_file)

    file_excel_report_error = Path(error_sas_pai_file_env)
    with pd.ExcelWriter(file_excel_report_error) as writer:  
        df_error_sas_pai_file.to_excel(writer, sheet_name='SAS PAI Error report', index=False)
    print(f'{" "*4} Excel file SAS PAI : OK')

except Exception as e:
    print(f'An error occurred: {e}')


print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')


# ===================================================================
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Generate report')
print(f'#')
try:
    data = []
    for key in report:
        for site in report[key]:
            total = report[key][site]['total']
            success = report[key][site]['ok']
            fail = report[key][site]['ko']
            data.append([key, site, str(total), str(success), str(fail)])

    content = ''
    for line in data:
        content += '~'.join(line)
        content += '\n'

    tmp_file_1 = Path(ftmp_1_env)
    with open(tmp_file_1, 'w') as file:
        file.write(content)

    print(f'file : {tmp_file_1}')
    print(content)
except Exception as e:
    print(f"An error occurred: {e}")
print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')



print(f'#{"="*70}')
print(f'# End Job RPTPY011')
print(f'#{"="*70}')
print(f'#')
