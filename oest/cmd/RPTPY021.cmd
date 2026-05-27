#! /opt/rh/rh-python38/root/usr/bin/python3
import sybpydb
import smtplib, sys, os
from datetime import datetime
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

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

def send_mail(subject, sender, receiver, html):
    message = MIMEMultipart()
    message["From"] = sender
    message["To"] = ", ".join(receiver)
    message["Subject"] = subject

    part = MIMEText(html, "html")
    encoders.encode_base64(part)
    message.attach(part)

    print(f"    - Subject : {message['Subject']}")
    print(f"    - From    : {message['From']}")
    print(f"    - To      : {message['To']}")

    server = smtplib.SMTP('localhost')
    # server.set_debuglevel(1)
    server.sendmail(sender, receiver, message.as_string())
    server.quit()

def create_thead(th_items):
    result = '<tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes;height:18.0pt">'
    for key, value in th_items.items():
        result += f'''
        <td width={value} nowrap style='width:67.0pt;border-top:solid #8EA9DB 1.0pt;border-left:solid #8EA9DB 1.0pt;border-bottom:none;border-right:solid #D9E1F2 1.0pt;mso-border-top-alt:solid #8EA9DB .5pt;mso-border-left-alt:solid #8EA9DB .5pt;mso-border-right-alt:solid #D9E1F2 .5pt;background:#8EA9DB;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
        <p class="MsoNormal" align=center style='text-align:center'>
            <span style='font-size:9.0pt;mso-ascii-font-family:Calibri;mso-fareast-font-family:"Times New Roman";mso-hansi-font-family:Calibri;mso-bidi-font-family:Calibri;color:black;mso-font-kerning:0pt;mso-ligatures:none'>{key}</span>
        </p>
        </td>
        '''
    result += '</tr>'
    return result

def create_tbody(th_items, data):
    result = ''
    width = list(th_items.values())
    for line in data:
        print(line)
        result += '''<tr style=mso-yfti-irow:1;height:15.75pt'>'''
        for value in line:
            result += f'''
            <td width={width[line.index(value)]} nowrap style='width:67.0pt;border:solid gray 1.0pt;border-right:solid #D0CECE 1.0pt;mso-border-alt:solid gray .5pt;mso-border-right-alt:solid #D0CECE .5pt;background:#E7E6E6;padding:0cm 5.4pt 0cm 5.4pt;height:15.75pt'>
                <p class=MsoNormal align=center style='text-align:center'>
                    <span style='mso-ascii-font-family:Calibri;mso-fareast-font-family:"Times New Roman";mso-hansi-font-family:Calibri;mso-bidi-font-family:Calibri;color:black;mso-font-kerning:0pt;mso-ligatures:none'>{value}</span>
                </p>
            </td>
            '''
        result += '</tr>'
    return result

def create_table(thead, tbody):
    result = f'''
    <table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse;mso-yfti-tbllook:1184;mso-padding-alt:0cm 3.5pt 0cm 3.5pt">
        {thead}
        {tbody}
    </table>'''
    return result

# Environment var
env_prefix_env = os.environ.get('ENV_PREFIX')
nchain_env = os.environ.get('NCHAIN')
hostname_env = os.environ.get('HOSTNAME')

# Argument var
env_arg = sys.argv[1]
receiver_mail_arg = sys.argv[2]

# Defaults var
srv = f'{env_arg}_TPO2'
chain_name = nchain_env.split('_')[1]
dt_now = datetime.now()
dt_now_formatted = dt_now.strftime('%m/%d/%Y %H:%M:%S')

query = '''
SELECT t.ctr_nf, t.sec_nf, t.uwy_nf, t.USGAAP_CT, t.ACCADMTYP_CT, t2.GRPANCO_NF, t2.PARANCO_NF, t2.LOCANCO_NF, SECSTS_CT
FROM btrt..tsection t, btrt..tsecifrs t2
where t.ctr_nf = t2.ctr_nf and t.sec_nf = t2.sec_nf and t.uwy_nf = t2.uwy_nf
and t.UWY_NF = 2024
and t.ACCADMTYP_CT = 2
and t.USGAAP_CT in (2, 3)
and t.SECSTS_CT in (14, 16, 17, 19)
and t.LOB_CF in ('30', '31')
and (t2.GRPANCO_NF != 2024 or t2.PARANCO_NF != 2024 or t2.LOCANCO_NF != 2024)
'''

result = exec_sql(srv, query)
if not result:
    exit(0)

th_items = {'CTR_NF': 90, 'SEC_NF': 80, 'UWY_NF': 80, 'USGAAP_CT': 80, 'ACCADMTYP_CT': 90, 'GRPANCO_NF': 90, 'PARANCO_NF': 90, 'LOCANCO_NF': 90, 'SECSTS_CT': 80}
thead = create_thead(th_items)
tbody = create_tbody(th_items, result)
table = create_table(thead, tbody)

html = f'''
<html>
<body lang=EN-US>
    <p class=MsoNormal>
        <span>Dear all,</span>
        <br>
        <span>this is the report annual cohort {env_arg} from chain {chain_name} run at {dt_now_formatted}</span> 
    </p>
    <p class=MsoNormal>
        <span style='color:red'><b>WARNING :</b> New contracts identified, please check the list below !</span>
    </p> 
    {table}
</body>
</html>
'''
# print(html)

receiver = receiver_mail_arg.split(',')
sender = f"O2.ANNUALCOHORT.{env_arg}.REPORT@{hostname_env}.azure.scor.com"
subject = f"WARNING : {env_arg} Annual Cohort checks - REPORT"
send_mail(subject, sender, receiver, html)
