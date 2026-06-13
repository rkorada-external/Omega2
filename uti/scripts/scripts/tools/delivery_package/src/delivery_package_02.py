#! /usr/bin/python3
# -*- coding: utf-8 -*-
import os, sys, re, smtplib, csv, shutil, pickle
from pprint import pprint
from glob import glob
from datetime import datetime
from xml.dom import minidom
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def csvParse(filename, parm):
    if not os.path.isfile(filename): raise Exception(2, "{} is not file".format(fileName))
    with open(filename, "r") as f: 
        lines = f.readlines()

    result = []
    for line in lines:
        data = line.strip().split(parm)
        result.append(data)

    if not result: raise Exception(1, filename)

    return result

def sendMail(subject, sender, receiver, html):
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

# -------------- Env ---------------
DUTI = os.environ.get('DUTI')
PY_SRC = os.environ.get('PY_SRC')
PY_DATA = os.environ.get('PY_DATA')
PY_RECEIVER = os.environ.get('PY_RECEIVER')

print(f"1 - Pickle load obj_pickle.pkl")
obj_pickle = {}
file_output = f"{PY_DATA}/obj_pickle.pkl"
with open(file_output, 'rb') as f:
    obj_pickle = pickle.load(f) 

print(f"2 - Pickle load component.pkl")
component_pickle = {}
file_output = f"{PY_DATA}/component.pkl"
with open(file_output, 'rb') as f:
    component_pickle = pickle.load(f) 

# pprint(component_pickle)

print(f"3 - Exec command shell")
cmd = f"svn log -l 1 {obj_pickle['file']}"
stream = os.popen(cmd)
print(f"    - {cmd}")

stdout = stream.read()
regex = r"-.*\sr(?P<revision>\d+)\s\|\s(?P<user>\w+)\s\|\s(?P<date>\d+-\d+-\d+\s\d+:\d+:\d+)\s.*\s\|\s\d+\sline\s\s(?P<message>.*)\s-.*"

out_svn_log = {
    'revision': '',
    'user': '',
    'date': '',
    'datetime': '',
    'message': ''
}
out_match = re.match(regex, stdout)
if out_match:
    out_svn_log = out_match.groupdict()

    format1 = "%Y-%m-%d %H:%M:%S"
    format2 = "%A %w %B %Y %H:%M:%S"
    dt = datetime.strptime(out_svn_log['date'], format1)
    out_svn_log['datetime'] = dt.strftime(format2)

print(f"4 - Check DDL")
width = [488, 88, 350, 312, 312]
th_items = ["component", "PROVIDER", "SPIRA", "COMMENT", "STATUS"]
thead = ""
for item in th_items:
    w = width[th_items.index(item)]
    thead += f'''<td width={w} valign="bottom" style="border:solid windowtext 1.0pt;mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:15.0pt">
      <p class="MsoNormal">
        <b><span style="font-size:10.0pt;font-family:&quot;Arial&quot;,sans-serif;mso-fareast-font-family:&quot;Times New Roman&quot;;color:black;">{item}</span></b>  
      </p>
    </td>'''

f = f"/scor/scoromega/delivery/{obj_pickle['VERSION']}_DELIVERY/OM2.DELIVERY/{obj_pickle['OUTPUT_FILENAME']}"
# f = f"/scor/home/u012294/delivery/{obj_pickle['VERSION']}_DELIVERY/OM2.DELIVERY/{obj_pickle['OUTPUT_FILENAME']}"
tbody = ""
count = 1
items = csvParse(f, ";")
for data in items[1:]:
    regex = r".*/.*/ddl/.*"
    out_match = re.match(regex, data[0])
    # print(out_match)
    if out_match and data[4] in ['Y', 'TBV', 'TBC']:
        # print(data[0],  data[2], data[4])
        row = [data[0], "", data[2], "", data[4]]
        td = ""
        for item in row:
            td += f'''<td nowrap valign=top style='width:366.0pt;border:solid windowtext 1.0pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:15.0pt'">
              <p class="MsoNormal">
                <b><span style="font-size:9.0pt">{item}</span></b>  
              </p>
            </td>'''

        tr = f'''<tr style='mso-yfti-irow:{count};height:15.0pt'>
        {td}
        </tr>'''

        tbody += tr
        count += 1

print(f"    - create table DDL")
table1 = f'''<table class="MsoTableGrid" border="1" cellspacing="0" cellpadding="0" style="margin-left:-.4pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:0cm 5.4pt 0cm 5.4pt">
      <tbody>
        <tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes;height:15.0pt">
          {thead}
        </tr>
        {tbody}
      </tbody>
    </table>'''


print(f"5 - Spira list ALTERSIS only")

width = [167, 179, 110, 60, 53, 55, 111, 468, 79, 122]
# th_items = ["Target Release", "Target Package", "Target Date", "Domain", "Lot", "Inc #", "ReOpen", "Type", "Desc.", "Profil", "Status"]
th_items = ["Target Release", "Target Package", "Domain", "Lot", "Inc #", "ReOpen", "Type", "Desc.", "Profil", "Status"]
thead = ""
for item in th_items:
    w = width[th_items.index(item)]
    thead += f'''<td width={w} valign="top" style="border:solid #4472C4 1.0pt;border-left:none;border-right:solid white 1.0pt;mso-border-top-alt:solid #4472C4 .5pt;mso-border-bottom-alt:solid #4472C4 .5pt;mso-border-right-alt:solid white 1.0pt;background:#006A8D;padding:0cm 3.5pt 0cm 3.5pt;height:25pt">
      <p class="MsoNormal">
        <b><span style="font-size:9.0pt;color:white">{item}</span></b>  
      </p>
    </td>'''

# print(obj_pickle['spira_data_altersis'])
target_release=""
package_delivery=""

tbody = ""
count = 1
for spira in obj_pickle['spira_data_altersis']:
    data = obj_pickle['spira_data_altersis'][spira]

    if count == 1:
        target_release = data['target']
        package_delivery = data['package']

    # row = [data['target'], data['package'], "", data['domain'], data['lot'], data['spira'], data['reopen'], data['type'], data['name'], data['profil'], data['status']]
    row = [data['target'], data['package'], data['domain'], data['lot'], data['spira'], data['reopen'], data['type'], data['name'], data['profil'], data['status']]
    td = ""
    for item in row:
        td += f'''<td nowrap="" valign="bottom" style="border-top:none;border-left:none;border-bottom:dotted windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:dotted windowtext .5pt;mso-border-top-alt:dotted windowtext .5pt;mso-border-bottom-alt:dotted windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:0cm 3.5pt 0cm 3.5pt;height:11.0pt">
          <p class="MsoNormal">
            <b><span style="font-size:9.0pt">{item}</span></b>  
          </p>
        </td>'''

    tr = f'''<tr style='mso-yfti-irow:{count};height:11.0pt'>
      {td}
    </tr>'''

    tbody += tr
    count += 1
    # td_items.append(row)

print(f"    - create table SPIRA List (ALTERSIS only)")
table2 = f'''<table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse;mso-yfti-tbllook:1184;mso-padding-alt:0cm 3.5pt 0cm 3.5pt">
      <tbody>
        <tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes;height:25pt">
          {thead}
        </tr>
        {tbody}
      </tbody>
    </table>'''



print(f"5 - DevOps list ALTERSIS only")

width = [60, 468, 122]
th_items = ["US", "Desc.", "Status"]
thead = ""
for item in th_items:
    w = width[th_items.index(item)]
    thead += f'''<td width={w} valign="top" style="border:solid #4472C4 1.0pt;border-left:none;border-right:solid white 1.0pt;mso-border-top-alt:solid #4472C4 .5pt;mso-border-bottom-alt:solid #4472C4 .5pt;mso-border-right-alt:solid white 1.0pt;background:#006A8D;padding:0cm 3.5pt 0cm 3.5pt;height:25pt">
      <p class="MsoNormal">
        <b><span style="font-size:9.0pt;color:white">{item}</span></b>  
      </p>
    </td>'''

tbody = ""
count = 1
for data in obj_pickle['us_data']:

    row = [data[0], data[1], data[2]]
    td = ""
    for item in row:
        td += f'''<td nowrap="" valign="bottom" style="border-top:none;border-left:none;border-bottom:dotted windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:dotted windowtext .5pt;mso-border-top-alt:dotted windowtext .5pt;mso-border-bottom-alt:dotted windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:0cm 3.5pt 0cm 3.5pt;height:11.0pt">
          <p class="MsoNormal">
            <b><span style="font-size:9.0pt">{item}</span></b>  
          </p>
        </td>'''

    tr = f'''<tr style='mso-yfti-irow:{count};height:11.0pt'>
      {td}
    </tr>'''

    tbody += tr
    count += 1


print(f"    - create table DEV OPS List (ALTERSIS only)")
table3 = f'''<table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse;mso-yfti-tbllook:1184;mso-padding-alt:0cm 3.5pt 0cm 3.5pt">
      <tbody>
        <tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes;height:25pt">
          {thead}
        </tr>
        {tbody}
      </tbody>
    </table>'''


body = f"""<body>
      <p class=MsoNormal>
        <span>Dear Tech Support,</span>
      </p>
      <br>
      <p class=MsoNormal>
        <span>You will find below the <b>OFFICAL {package_delivery} DELIVERY</b> package for {target_release} release.</span>
      </p>
      <ol style='margin-top:0cm' start=1 type=1>
        <li class=MsoListParagraph style='margin-left:0cm'>
          <span>CSV file includes NON JAVA COMPONENTS<span style='color:red'>*</span> from ALTERSIS and CAPGEMINI</span>
        </li>
        <li class=MsoListParagraph style='margin-left:0cm'>
          <span>Go for JAVA Build on ALTERSIS side.</span>
        </li>
        <li class=MsoListParagraph style='margin-left:0cm'>
          <span>Post installation action</span>
        </li>
        <li class=MsoListParagraph style='margin-left:0cm'>
          <span>vTOM modifications</span>
        </li>
      </ol>
      <br>
      <p class=MsoNormal>
        <i>
          <span><span style='color:red'>*</span> Please provide component comparison between ITK and UAT afterinstallation.</span>
        </i>
      </p>
      <br>
      <p class=MsoNormal>
        <b><u><span style='color:#4472C4'>NON JAVA COMPONENT</span></u></b>
      </p>
      <br>
      <p class=MsoNormal>
        <span>Revision : </span>
        <i><span style='color:red'>TBC components to be checked in CSV</span></i>
      </p>
      <p class=MsoNormal>
        <span>Author : {out_svn_log['user']}</span>
      </p>
      <p class=MsoNormal>
        <span>Date : {out_svn_log['datetime']}</span>
      </p>
      <p class=MsoNormal>
        <span>Message : </span>
      </p>
      <p class=MsoNormal>
        <span>{out_svn_log['message']}</span>
      </p>
      <p class=MsoNormal>
        <span>----</span>
      </p>
      <p class=MsoNormal>
        <b>
          <span>Modified : /OMEGA-2/branches/{obj_pickle['VERSION']}_DELIVERY/OM2.DELIVERY/{obj_pickle['OUTPUT_FILENAME']}</span>
        </b>
      </p>
      <br>
      <p class=MsoNormal>
        <b><u><span style='color:#4472C4'>POST NON JAVA INSTALLATION</span></u></b>
      </p>
      <br>
      <p class=MsoNormal>
        <b><u><span style='color:#4472C4'>vTOM modifications</span></u></b>
      </p>
      <br>
      <p class=MsoNormal>
        <b><u><span style='color:#4472C4'>DDL checks :</span></u></b>
      </p>
      <br>
      {table1}
      <br>
      <p class="MsoNormal">
        <b><u><span style="color:#4472C4">SPIRA List (ALTERSIS only) :</span></u></b>
        <span style="mso-spacerun:yes">&nbsp;</span>
        <span>{target_release} / {package_delivery} / SCOR – DELIVERED</span>
      </p>
      <br>
      {table2}
      <br>
      <p class="MsoNormal">
        <b><u><span style="color:#4472C4">DEV OPS List (ALTERSIS only) :</span></u></b>
      </p>
      <br>
      {table3}
    </body>"""

head = component_pickle['head']
head = head.replace("{{title}}", f"<title>Omega 2 | {target_release} Release - {package_delivery} Delivery</title>")
head = head.replace("{{style}}", "<style></style>")

html = component_pickle['html']
html = html.replace("{{body}}", body)
html = html.replace("{{head}}", head)


print(f"6 - Send HTML mail")
receiver = PY_RECEIVER.split(',')
# receiver = ["ddasilvateixeira-external@scor.com"]
# receiver = ["ddasilvateixeira-external@scor.com", "tdeutsch-external@scor.com", "mbrik-external@scor.com"]
sender = "DELIVERY.PACKAGE@AEnDevO2Batch.azure.scor.com"
subject = f"Omega 2 | {target_release} Release - {package_delivery} Delivery"
sendMail(subject, sender, receiver, html)

