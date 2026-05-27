#! /opt/rh/rh-python38/root/usr/bin/python3
import sybpydb
import smtplib, sys, os, re
import pandas as pd
from pathlib import Path
from datetime import datetime, timedelta, date
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

def get_prm(file_path):
    result = {}
    try:
        with open(file_path, 'r') as file:
            for line_number, line in enumerate(file, start=1):
                d = line.strip().split(' ', 1)
                if d[0] != '': result[d[0]] = d[1]
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
    finally:
        cursor.close()
        connection.close()
    
    return result

def send_mail(subject, sender, receiver, html, path_to_file, path_to_file2):
    message = MIMEMultipart()
    message["From"] = sender
    message["To"] = ", ".join(receiver)
    message["Subject"] = subject

    print(f"    - Subject : {message['Subject']}")
    print(f"    - From    : {message['From']}")
    print(f"    - To      : {message['To']}")

    part = MIMEText(html, "html")
    encoders.encode_base64(part)
    message.attach(part)

    if path_to_file.exists():
        print(f"    - File    : {path_to_file}")
        with open(path_to_file, 'rb') as file:
            # Attach the file with filename to the email
            message.attach(MIMEApplication(file.read(), Name=path_to_file.name))

    if path_to_file2.exists():
        print(f"    - File    : {path_to_file2}")
        with open(path_to_file2, 'rb') as file:
            # Attach the file with filename to the email
            message.attach(MIMEApplication(file.read(), Name=path_to_file2.name))

    server = smtplib.SMTP('localhost')
    # server.set_debuglevel(1)
    server.sendmail(sender, receiver, message.as_string())
    server.quit()

def create_tr(td_values):
    return f'''
    <tr style='height:15.0pt'>
        <td width=312 nowrap valign=bottom style='width:234.05pt;border:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
            <p class=MsoNormal><span style='color:black'>{td_values[0]}</span></p>
        </td>
        <td width=59 nowrap valign=bottom style='width:43.95pt;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
            <p class=MsoNormal align=center style='text-align:center'><span style='color:black'>{td_values[1]}</span></p>
        </td>
        <td width=107 nowrap valign=bottom style='width:80.0pt;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
            <p class=MsoNormal align=center style='text-align:center'><span style='color:black'>{td_values[2]}</span></p>
        </td>
        <td width=129 nowrap valign=bottom style='width:97.0pt;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
            <p class=MsoNormal align=center style='text-align:center'><span style='color:black'>{td_values[3]}</span></p>
        </td>
    </tr>
    '''

def create_query_sql(sql_select, site, table, date):
    return  f'''
    SELECT {sql_select}
    FROM BTRAV.UB{site}.{table}
    WHERE CLODAT_D = CONVERT(DATE, '{date}', 111)
    ORDER BY LSTUPD_D DESC
    '''

def create_dataframe(data, columns):
    df_columns = columns.copy()
    # df_columns.insert(0, 'BATCHUSER_CF')
    if data:
        df = pd.DataFrame(data, columns=df_columns)
    else:
        df = pd.DataFrame(columns=df_columns)
    return df

def create_report(df, site, dt_ref):
    report = {'candidats': 0,'updated': 0,'failed': 0}

    if not df.empty and dt_ref != '':
        date_ref = pd.to_datetime(dt_ref)

        df_candidats = df[((df['ISVALIDI17G_B'] == 1) | (df['ISVALIDI17P_B'] == 1) | (df['ISVALIDI17L_B'] == 1)) 
                        & ((df['ISTREATED_B'] == 0) | ((df['ISTREATED_B'] == 1) & (df['LSTUPD_D'] >= date_ref)))]
        candidats_counts = len(df_candidats)
        report['candidats'] = candidats_counts

        df_last_closing = df_candidats[(df_candidats['LSTUPD_D'] >= date_ref)]

        df_updated = df_last_closing[(df_last_closing['ISTREATED_B'] == 1)]
        updated_counts = len(df_updated)
        report['updated'] = updated_counts

        df_failed = df_last_closing[(df_last_closing['ISUPDATEFAILED_B'] == 1)]
        failed_counts = len(df_failed)
        report['failed'] = failed_counts

    return report

def create_table_html(report, env, date_now):
    td_values = ['Number of NTAP candidates', report['total_candidats']['AS'], report['total_candidats']['EU'], report['total_candidats']['AM']]
    tr_candidats = create_tr(td_values)

    td_values = ['Updated succesfully during last Closing', report['total_updated']['AS'], report['total_updated']['EU'], report['total_updated']['AM']]
    tr_succeeded = create_tr(td_values)

    td_values = ['Failed update', report['total_failed']['AS'], report['total_failed']['EU'], report['total_failed']['AM']]
    tr_failed = create_tr(td_values)

    dt_now_formatted = date_now.strftime('%d-%m-%Y')

    return f'''
        <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=616 style='width:462.3pt;margin-left:.1pt;border-collapse:collapse'>
            <tr style='height:17.2pt'>
                <td width=616 nowrap colspan=4 rowspan=2 style='width:462.3pt;border:solid windowtext 1.0pt;background:#D9E1F2;padding:0cm 3.5pt 0cm 3.5pt;height:17.2pt'>
                    <p class=MsoNormal align=center style='text-align:center'>
                        <b><span style='font-size:12.0pt;color:#0070C0'>{env} NTAP report : {dt_now_formatted}</span></b>
                    </p>
                </td>
            </tr>
            <tr style='height:17.2pt'>
                <td style='padding:0cm 3.5pt 0cm 3.5pt;height:17.2pt'></td>
            </tr>
            <tr style='height:15.75pt'>
                <td width=312 nowrap valign=bottom style='width:234.05pt;border:solid windowtext 1.0pt;background:#8EA9DB;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                    <p class=MsoNormal><b><span style='font-size:12.0pt;color:black'>&nbsp;</span></b></p>
                </td>
                <td width=59 nowrap style='width:43.95pt;border:solid windowtext 1.0pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                    <p class=MsoNormal align=center style='text-align:center'><b><span style='color:black'>ASIA</span></b></p>
                </td>
                <td width=107 nowrap style='width:80.0pt;border:solid windowtext 1.0pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                    <p class=MsoNormal align=center style='text-align:center'><b><span style='color:black'>EUROPE</span></b></p>
                </td>
                <td width=129 nowrap style='width:97.0pt;border:solid windowtext 1.0pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                    <p class=MsoNormal align=center style='text-align:center'><b><span style='color:black'>AMERICA</span></b></p>
                </td>
            </tr>
            {tr_candidats}
            {tr_succeeded}
            {tr_failed}
            <tr style='height:16.5pt'>
                <td width=607 nowrap colspan=4 valign=bottom style='width:455.0pt;border:solid #0070C0 1.0pt;border-top:none;padding:0cm 3.5pt 0cm 3.5pt;height:16.5pt'>
                    <p class=MsoNormal align=center style='text-align:center'>
                        <b><span lang=EN-GB style='font-size:12.0pt;color:#0070C0'>Attached files contain the details of NTAP of current quarter</span></b>
                    </p>
                </td>
            </tr>
        </table>
    '''

def create_df_legend(columns):
    data = {'column': [], 'label': []}
    a = ''
    isto = True
    isfrom = True
    istechnical = True
    for value in columns:
        if value[0:2] == 'TO':
            a = 'TO'
            key = value[2:]
        elif value[0:4] == 'FROM':
            a = 'FROM'
            key = value[4:]
        else:
            a = 'TECHNICAL'
            key = value

        
        if a == 'TO' and isto:
            isto = False
            data['column'].append('Parameters of contract which should be updated (TO***)')
            data['label'].append('')
        
        if a == 'FROM' and isfrom:
            isfrom = False
            data['column'].append('')
            data['label'].append('')
            data['column'].append('Parameters of Replaced contract (FROM***)')
            data['label'].append('')
        
        if a == 'TECHNICAL' and istechnical:
            istechnical = False
            data['column'].append('')
            data['label'].append('')
            data['column'].append('TECHNICAL INFORMATION')
            data['label'].append('')

        data['column'].append(value)
        data['label'].append(rptpy030_prm_data[key])

    return pd.DataFrame(data)

# Environment var
env_prefix_env = os.environ.get('ENV_PREFIX')
nchain_env = os.environ.get('NCHAIN')
hostname_env = os.environ.get('HOSTNAME')
srv_env = os.environ.get('SRV')
dtmp_path_env = os.environ.get('DTMP')
dprm_path_env = os.environ.get('DPRM')

# Argument var
env_arg = sys.argv[1]
env_prefix_arg = sys.argv[2]
receiver_mail_arg = sys.argv[3]

# Constant var
site_const = ['AS', 'EU', 'AM']

# Defaults var
step_nb = 0
srv = f'{env_arg.upper()}_TPO2'
chain_name = nchain_env.split('_')[1]
dt_now = date.today()
dt_now_formatted = dt_now.strftime('%d-%m-%Y')
file_excel_report_assumed = Path(dtmp_path_env, f'{env_prefix_env.upper()}_{chain_name.upper()}_{env_arg.upper()}_NTAP_ASSUMED_REPORTS.xlsx')
file_excel_report_retro = Path(dtmp_path_env, f'{env_prefix_env.upper()}_{chain_name.upper()}_{env_arg.upper()}_NTAP_RETRO_REPORTS.xlsx')

scor_data_path = '/scor/scordata'
if (srv_env == 'DEV_TPO2' and env_arg != 'DEV'):
    scor_data_path = f'/scordata_aen{env_arg.lower()}o2batch'

# ESTJ0000 PRM var
# prm_path = Path(scor_data_path, 'ubas', 'prm')
# esfj0000_prm_file = Path(prm_path, 'ESCJ0000.prm')
# esfj0000_prm_data = get_prm(esfj0000_prm_file)
# esfj0000_DATE_T = esfj0000_prm_data['DATE_T']


# ESTJ0000 PARM var
perm_path = Path(scor_data_path, 'ubas', 'perm')
try:
    esfj0000_parm_file = Path(perm_path, f'{env_prefix_arg}_ESFJ0000_PARM_I17G.dat')
    esfj0000_parm_data = get_parm(esfj0000_parm_file)
except Exception as e:
    print(f"# !!! Parm PARM_ICLODAT_D not exists in {esfj0000_parm_file}")

try:
    esfj0000_ICLODAT_D = esfj0000_parm_data['PARM_ICLODAT_D']
except Exception as e:
    print(f"# !!! Parm PARM_ICLODAT_D not exists in {esfj0000_parm_file}")

try:
    esfj0000_CRE_D = esfj0000_parm_data['PARM_CRE_D']
except Exception as e:
    print(f"# !!! Parm PARM_CRE_D not exists in {esfj0000_parm_file}")


# RPTPY030 PRM var
rptpy030_prm_file = Path(dprm_path_env, 'RPTPY030.prm')
rptpy030_prm_data = get_prm(rptpy030_prm_file)
rptpy030_SQL_TREPLINK_COL = rptpy030_prm_data['SQL_TREPLINK_COL']
rptpy030_SQL_TRREPLINK_COL = rptpy030_prm_data['SQL_TRREPLINK_COL']

columns_assumed = rptpy030_SQL_TREPLINK_COL.strip().split(',')
columns_retro = rptpy030_SQL_TRREPLINK_COL.strip().split(',')

try:
    dt_ICLODAT_D = datetime.strptime(esfj0000_ICLODAT_D, "%Y%m%d")

    dt_CRE_D = datetime.strptime(esfj0000_CRE_D, "%Y%m%d")
    dt_CRE_D = datetime.strptime(f'{dt_CRE_D.date()} 15:00:00', "%Y-%m-%d %H:%M:%S")

    dt_string = dt_ICLODAT_D.strftime("%Y/%m/%d")
    dt_ref = dt_CRE_D
except Exception as e:
    print(f"# /!\ ")

print(f'#{"="*70}')
print(f'# Start Job RPTPY031')
try:
    print(f'{" "*2} env = {env_arg}')
    print(f'{" "*2} scor_data_path = {scor_data_path}')
    print(f'{" "*2} parm file = {esfj0000_parm_file}')
    print(f'{" "*2} CRE_D     from (parm file) = {dt_CRE_D}')
    print(f'{" "*2} ICLODAT_D from (parm file) = {dt_ICLODAT_D}')
except Exception as e:
    print(f"# /!\ ")
print(f'#{"="*70}')
print(f'#')

# -----------------------------------------------------------------------------------------------------
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Exec query sql on {srv}')
print(f'#')

try:
    select_assumed = ', '.join(columns_assumed)
    select_retro = ', '.join(columns_retro)

    data_assumed = {'AS': [], 'EU': [], 'AM': []}
    data_retro = {'AS': [], 'EU': [], 'AM': []}
    data_info = {'total_line': {'assumed': 0, 'retro': 0}}
    for site in site_const:
        query_assumed = create_query_sql(select_assumed, site, 'SCOPE_TREPLINK', dt_string)
        data_assumed[site] = exec_sql(srv, query_assumed)
        data_info['total_line']['assumed'] += len(data_assumed[site])

        query_retro = create_query_sql(select_retro, site, 'SCOPE_TRREPLINK', dt_string)
        data_retro[site] = exec_sql(srv, query_retro)
        data_info['total_line']['retro'] += len(data_retro[site])

    print(f'{" "*2} Number of NTAP Assumed line : {data_info["total_line"]["assumed"]}')
    print(f'{" "*4} AS : {len(data_assumed["AS"])}')
    print(f'{" "*4} EU : {len(data_assumed["EU"])}')
    print(f'{" "*4} AM : {len(data_assumed["AM"])}')

    print(f'{" "*2} Number of NTAP Retro line : {data_info["total_line"]["retro"]}')
    print(f'{" "*4} AS : {len(data_retro["AS"])}')
    print(f'{" "*4} EU : {len(data_retro["EU"])}')
    print(f'{" "*4} AM : {len(data_retro["AM"])}')
except Exception as e:
    print(f"# /!\ ")

print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Generate legend for excel file')
print(f'#')

df_legend_assumed = create_df_legend(columns_assumed)
df_legend_retro = create_df_legend(columns_retro)

with pd.ExcelWriter(file_excel_report_assumed) as writer:  
    df_legend_assumed.to_excel(writer, sheet_name='LEGEND', header=False, index=False)

with pd.ExcelWriter(file_excel_report_retro) as writer:  
    df_legend_retro.to_excel(writer, sheet_name='LEGEND', header=False, index=False)

print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Generate NTAP report')
print(f'#')

df_assumed = {'AS': [], 'EU': [], 'AM': []}
df_retro = {'AS': [], 'EU': [], 'AM': []}
report_assumed = {'AS': [], 'EU': [], 'AM': []}
report_retro = {'AS': [], 'EU': [], 'AM': []}
report_info = {
    'total_candidats': {'AS': 0, 'EU': 0, 'AM': 0},
    'total_updated': {'AS': 0, 'EU': 0, 'AM': 0},
    'total_failed': {'AS': 0, 'EU': 0, 'AM': 0}
    }
try:
    for site in site_const:
        df_assumed[site] = create_dataframe(data_assumed[site], columns_assumed)
        report_assumed[site] = create_report(df_assumed[site], site, dt_ref)

        report_info['total_candidats'][site] += report_assumed[site]['candidats']
        report_info['total_updated'][site] += report_assumed[site]['updated']
        report_info['total_failed'][site] += report_assumed[site]['failed']

        df_retro[site] = create_dataframe(data_retro[site], columns_retro)
        report_retro[site] = create_report(df_retro[site], site, dt_ref)

        report_info['total_candidats'][site] += report_retro[site]['candidats']
        report_info['total_updated'][site] += report_retro[site]['updated']
        report_info['total_failed'][site] += report_retro[site]['failed']


    with pd.ExcelWriter(file_excel_report_assumed, mode='a') as writer:  
        df_assumed['AS'].to_excel(writer, sheet_name='NTAP Asia', index=False)
        df_assumed['EU'].to_excel(writer, sheet_name='NTAP Europe', index=False)
        df_assumed['AM'].to_excel(writer, sheet_name='NTAP America', index=False)

    with pd.ExcelWriter(file_excel_report_retro, mode='a') as writer:  
        df_retro['AS'].to_excel(writer, sheet_name='NTAP Asia', index=False)
        df_retro['EU'].to_excel(writer, sheet_name='NTAP Europe', index=False)
        df_retro['AM'].to_excel(writer, sheet_name='NTAP America', index=False)
except Exception as e:
    print(f"# /!\ ")

print(f'{" "*2} Report NTAP Assumed result :')
print(f'{" "*4} AS : {report_assumed["AS"]}')
print(f'{" "*4} EU : {report_assumed["EU"]}')
print(f'{" "*4} AM : {report_assumed["AM"]}')
print(f'{" "*2} Report NTAP Retro result :')
print(f'{" "*4} AS : {report_retro["AS"]}')
print(f'{" "*4} EU : {report_retro["EU"]}')
print(f'{" "*4} AM : {report_retro["AM"]}')
print(f'{" "*2} Report NTAP result :')
print(f'{" "*4} Candidats : {report_info["total_candidats"]}')
print(f'{" "*4} Updated : {report_info["total_updated"]}')
print(f'{" "*4} Failed : {report_info["total_failed"]}')

print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Create NTAP Report mail')
print(f'#')

table = create_table_html(report_info, env_arg.upper(), dt_now)

d = ''
if dt_ref: 
    dt_ref_formatted = dt_ref.strftime('%d-%m-%Y')
    d = f'-- Date Ref ({dt_ref_formatted})'

print(f'{" "*2} Create table for Assmued')
print(f'{" "*2} Create table for Retro')

html = f'''
    <html>
    <body lang=EN-US>
        <p class=MsoNormal>
            <span>Dear all,</span>
        </p>
        <p class=MsoNormal>
            <span>This is the NTAP Report {env_arg.upper()} from chain {chain_name.upper()} run at {dt_now_formatted} {d}</span> 
        </p> 
        {table}
    </body>
    </html>
'''
print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Sending NTAP Report mail')
print(f'#')

receiver = receiver_mail_arg.split(',')
sender = f"O2.NTAP.{env_arg}.REPORT@{hostname_env}.azure.scor.com"
subject = f"Omega 2 : {env_arg} NTAP Report"
send_mail(subject, sender, receiver, html, file_excel_report_assumed, file_excel_report_retro)


print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Remove {chain_name} files')
print(f'#')

file_excel_report_assumed.unlink()
file_excel_report_retro.unlink()

print(f'{" "*2} Romove file :', file_excel_report_assumed)
print(f'{" "*2} Romove file :', file_excel_report_retro)

print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')
# -----------------------------------------------------------------------------------------------------

print(f'#{"="*70}')
print(f'# End Job RPTPY011')
print(f'#{"="*70}')
print(f'#')