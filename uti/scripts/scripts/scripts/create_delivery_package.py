#! /usr/bin/python3
# -*- coding: utf-8 -*-
import os, sys, re, smtplib, csv, shutil
from pprint import pprint
from glob import glob
from datetime import datetime
from xml.dom import minidom
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def excelParse(fileName, sheet=1):
    def callback(data):
        text = ""
        for element in data.childNodes:
            if element.nodeType == element.TEXT_NODE:
                text += element.data
            else:
                text += callback(element)
        return text

    t = []
    root = minidom.parse(fileName)
    worksheets = root.getElementsByTagName("Worksheet")
    worksheet = worksheets.item(sheet - 1)
    
    table = worksheet.getElementsByTagName("Table")
    for row in table.item(0).childNodes:
        if row.localName == 'Row':
            rw = [] 
            for cell in row.childNodes:
                if cell.localName == 'Cell':
                    for data in cell.childNodes:
                        if data.localName == 'Data':
                            text = callback(data)
                            rw.append(text.encode('ascii','ignore'))
            t.append(rw)
    return t

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

def createElement(tagName, className, content):
    if className: 
        return f"""<{tagName} class="{className}">{content}</{tagName}>\n"""
    return f"""<{tagName}>{content}</{tagName}>\n"""

def createListElement(tagName, elements):
    result = ""
    for element in elements: 
        result += createElement(tagName, "", element)
    return result

def createTable(th_items, td_items):
    # thead = """
    # <tr class="thead">
    #     <th>Component</th> 
    #     <th>Spira</th> 
    #     <th>Name</th> 
    #     <th>Target Release</th> 
    #     <th>Delivery Package</th> 
    #     <th>Status</th>
    # </tr>"""

    thead = ""
    th = createListElement("th", th_items)
    thead += createElement("tr", "thead", th)

    tbody = ""
    for item in td_items:
        td = createListElement("td", item)
        tbody += createElement("tr", "", td)

    table = f"""
    <table>
        {thead}
        {tbody}
    </table>"""

    return table

# -- Start script --

if (len(sys.argv) < 5):
    print("exemple for prod hofix : create_delivery_package.py '4A' 'IN2' '01-PROD 4A June 2022 Hotfix' '103 - Production Hot Fix #03'")
    print("exemple for release : create_delivery_package.py '4B' 'ITK' '03-Jan. 2023,01-PROD 4A June 2022 Hotfix' '220 – UAT#2 – Main,103 - Production Hot Fix #03'")
    sys.exit()

# -------------- Env ---------------
DUTI = os.environ.get('DUTI')
# RECIPIENT = os.environ.get('RECIPIENT')

# ----------- Parameters -----------
VERSION = sys.argv[1]
ENV_SRC = sys.argv[2]
TARGET_RELEASE = sys.argv[3]
DELIVERY_PACKAGE = sys.argv[4]
FILENAME = sys.argv[5]

# ----------- Constants ------------
DIALECT = csv.excel
DIALECT.delimiter = ";"
DIALECT.lineterminator = "\n"

COMPANY_ALTERSIS = "ALTERSIS"

# DELIVERY_PATH = f"/scor/home/u012294/delivery/{VERSION}_DELIVERY/OM2.DELIVERY"
DELIVERY_PATH = f"/scor/scoromega/delivery/{VERSION}_DELIVERY/OM2.DELIVERY"
DELIVERY_FILENAME = f"OM2.{VERSION}_DELIVERY_AZ{ENV_SRC}.csv"
DELIVERY_FILE = os.path.join(DELIVERY_PATH, DELIVERY_FILENAME)

SPIRA_FILENAME = "REPORT_DELIVERY_SPIRA_LIST.xls"
SPIRA_FILE = os.path.join(f"{DUTI}/scripts", SPIRA_FILENAME)

OUTPUT_FILENAME = f"OM2.{VERSION}_DELIVERY_{FILENAME}.csv"

target = TARGET_RELEASE.split(',')
package = DELIVERY_PACKAGE.split(',')

uat = {
    'target_release': "",
    'delivery_package': "",
    'filename_src': OUTPUT_FILENAME,
    'file_src': os.path.join(DELIVERY_PATH, OUTPUT_FILENAME)
}

prd = {
    'target_release': "",
    'delivery_package':"",
}

if len(target) > 1:
    uat['target_release'] = int(target[0])
    prd['target_release'] = int(target[1])
else:
    prd['target_release'] = int(target[0])

if len(package) > 1:
    uat['delivery_package'] = int(package[0])
    prd['delivery_package'] = int(package[1])
else:
    prd['target_release'] = int(package[0])


pprint(uat)
pprint(prd)
print("")

cmd = f"svn up {DELIVERY_PATH}"
print(f"1 - Execute {cmd}")
os.system(cmd)
print("")


print(f"2 - Copy file {DELIVERY_FILENAME} to {uat['filename_src']}")
shutil.copy(DELIVERY_FILE, uat['file_src'])
print(f"    - {uat['file_src']}")


print(f"4 - Create REF data")
files = []
if uat['target_release']:
    files_pattern = os.path.join(DELIVERY_PATH, f"OM2.{VERSION}_DELIVERY_UAT_*.csv")
    files = filter(os.path.isfile, glob(files_pattern))
    files = sorted(files, key=os.path.getmtime)
    if uat['file_src'] in files: files.remove(uat['file_src'])

if not uat['target_release'] and prd['target_release']:
    files_pattern = os.path.join(DELIVERY_PATH, f"OM2.{VERSION}_DELIVERY_PRD_HF_*.csv")
    files = filter(os.path.isfile, glob(files_pattern))
    files = sorted(files, key=os.path.getmtime)
    if uat['file_src'] in files: files.remove(uat['file_src'])


ref_data = {
    'Y': {},
    'OTHERS': {}
}
for f in files:
    items = csvParse(f, ";")

    for item in items[1:]: 
        key1 = "OTHERS"
        key2 = f"{item[0]}+{item[1]}"
        row = {
            'component': item[0],
            'revision': item[1],
            'spira': item[2],
            'status': item[4],
            'files': [f]
        }

        if item[4] == "Y": 
            key1 = "Y"
      
        if key2 not in ref_data[key1]:
            ref_data[key1][key2] = row
        else:
            ref_data[key1][key2]['files'].append(f)

    print(f"    - {len(items)} of {f}")

print(f"    - {len(ref_data['Y'])} of Y")
print(f"    - {len(ref_data['OTHERS'])} of OTHERS")



print(f"5 - Get Spira data")
spira_data = {
    'Y': {},
    'TBC': {},
    'OTHERS': {}
}
spira_items = excelParse(SPIRA_FILE)
for item in spira_items[6:]:
    key = ""
    target = ""
    package = ""
    handled_by = ""
    name = ""
    status = ""

    if len(item) >= 1:
        key = item[0].decode()
    if len(item) >= 2:
        name = item[1].decode()
    if len(item) >= 6:
        status = item[5].decode()
    if len(item) >= 32:
        target = item[31].decode()
    if len(item) >= 33:
        package = item[32].decode()
    if len(item) >= 39:
        handled_by = item[38].decode()

    row = {
        'spira': key,
        'name': name,
        'status': status,
        'target': target,
        'package': package,
        'handled_by': handled_by
    }

    if handled_by == COMPANY_ALTERSIS:
        target_nb2 = 0
        target_mtch = re.match(r'(..).*', target)
        if target_mtch:
            nb = target_mtch.group(1)
            if nb.isdigit(): target_nb2 = int(nb)

        package_nb3 = 99
        package_mtch = re.match(r'(...).*', package)
        if package_mtch:
            nb3 = package_mtch.group(1)
            if nb3.isdigit(): 
                package_nb3 = int(nb3)

        if uat['target_release'] and target_nb2 == uat['target_release']:

            if package_nb3 == uat['delivery_package']:
                spira_data['Y'][key] = row

            elif (package_nb3 < uat['delivery_package']) and (package_nb3 >= 210 or package_nb3 == 99):
                spira_data['TBC'][key] = row

            else:
                spira_data['OTHERS'][key] = row

        elif prd['target_release'] and target_nb2 == prd['target_release']:

            if not uat['target_release'] and package_nb3 == prd['delivery_package']:
                spira_data['Y'][key] = row

            elif (package_nb3 <= prd['delivery_package']) and (package_nb3 >= 100 or package_nb3 == 99):
                spira_data['TBC'][key] = row

            else:
                spira_data['OTHERS'][key] = row

        else:
            spira_data['OTHERS'][key] = row

    else:
        spira_data['OTHERS'][key] = row


print(f"    - {len(spira_items)} of {SPIRA_FILE}")
print(f"    - {len(spira_data['Y'])} of Y")
print(f"    - {len(spira_data['TBC'])} of TBC")
print(f"    - {len(spira_data['OTHERS'])} of OTHERS")



print(f"6 - Change column Deploy of file {uat['filename_src']}")
uat_data = {
    'Y': [],
    'TBC': [],
    'OTHERS': [],
    'CAPGEMINI': []
}
uat_items = csvParse(uat['file_src'], ";")
for data in uat_items[1:]:
    component_key = f"{data[0]}+{data[1]}"
    spira = data[2]
    deploy_old = data[4]

    row1 = { 
        'component': data[0],
        'revision': data[1],
        'delivery_date': data[5],
        'user': data[10],
        'dev_date': data[12],
        'deploy': '',
        'deploy_old': deploy_old
    }
    row2 = {
        'spira': spira,
        'name': '#N/A',
        'status': '#N/A',
        'target': '#N/A',
        'package': '#N/A',
        'handled_by': '#N/A'
        }
    key = ""
    if spira in spira_data['Y']: 
        key = "Y"
        row2 = spira_data['Y'][spira]

        if row2['status'] != "DEV - Validated":
            data[4] = "TBV"
        else:
            data[4] = "Y"
        
        # print(row)
    elif spira in spira_data['TBC'] and component_key not in ref_data['Y']:
        key = "TBC"
        data[4] = "TBC"
        row2 = spira_data['TBC'][spira]
    else:
        key = "OTHERS"
        data[4] = "CT"

        if component_key not in ref_data['Y']: 
            key = "TBC"
            data[4] = "TBC"

        if spira == "NONE" or spira == "":
            row2['spira'] = '#N/A'

        if spira in spira_data['TBC']:
            row2 = spira_data['TBC'][spira]

        if spira in spira_data['OTHERS']:
            row2 = spira_data['OTHERS'][spira]

    # row1['component'] = data[0]
    # row1['revision'] = data[1]
    row1['deploy'] = data[4]
    # row1['deploy_old'] = deploy_old

    row = {**row1, **row2}

    if (not row['spira'].isdigit() and row['spira'] != "#N/A") or row['handled_by'] == "CAPGEMINI":
        key = "CAPGEMINI"
        data[4] = deploy_old

    # update 2.3 -- SCOR Target Release, Delivery Package, Status, Name
    data.append(row['target'])
    data.append(row['package'])
    data.append(row['status'])
    data.append(row['name'])

    uat_data[key].append(row)


print(f"    - {len(uat_items)} of {uat['file_src']}")
print(f"    - {len(uat_data['Y'])} of Y")
print(f"    - {len(uat_data['TBC'])} of TBC")
print(f"    - {len(uat_data['OTHERS'])} of OTHERS")
print(f"    - {len(uat_data['CAPGEMINI'])} of CAPGEMINI")


with open(uat['file_src'], mode='w') as f:
    csv_file = csv.writer(f, dialect=DIALECT)
    csv_file.writerows(uat_items)

# pprint(uat_data['Y'])

print(f"7 - Create HTML mail")
# th_items = ["SCOR Target Release", "Delivery Package", "Inc #", "Name", "Status", "Component", "Revision","Deploy new", "Deploy old"]
th_items = ["SCOR Target Release", "Delivery Package", "Inc #", "Name", "Status", "Component", "Revision", "Delivery Date", "User", "Deploy new", "Deploy old"]
td_items = []
for data in uat_data['Y']:
    # print(data)
    row = [
        data['target'],
        data['package'],
        data['spira'],
        data['name'],
        data['status'],
        data['component'],
        data['revision'],
        data['delivery_date'],
        data['user'],
        data['deploy'],
        data['deploy_old']
    ]

    td_items.append(row)

table1 = createTable(th_items, td_items)
print(f"    - create table Y")

td_items = []
for data in uat_data['TBC']:
    # print(data)
    row = [
        data['target'],
        data['package'],
        data['spira'],
        data['name'],
        data['status'],
        data['component'],
        data['revision'],
        data['delivery_date'],
        data['user'],
        data['deploy'],
        data['deploy_old']
    ]
    # if (data['spira'].isdigit() or data['spira'] == "#N/A") and data['handled_by'] != "CAPGEMINI":
    td_items.append(row)

table2 = createTable(th_items, td_items)
print(f"    - create table TBC")

th_items = ["SCOR Target Release", "Delivery Package", "Inc #", "Name", "Status", "Component", "Revision","Deploy new", "Deploy old"]
td_items = []
for data in uat_data['OTHERS']:
    # print(data)
    row = [
        data['target'],
        data['package'],
        data['spira'],
        data['name'],
        data['status'],
        data['component'],
        data['revision'],
        data['deploy'],
        data['deploy_old']
    ]
    # if (data['spira'].isdigit() or data['spira'] == "#N/A")  and data['handled_by'] != "CAPGEMINI":
    td_items.append(row)

table3 = createTable(th_items, td_items)
print(f"    - create table OTHERS")


body = f"""<div>
    <h2>Composant de {FILENAME}</h2>
    {table1}
    <h2>Composant antérieur à {FILENAME}</h2>
    {table2}
    <br/>
    {table3}
    </div>"""
style = """<style type="text/css">
    table { font-family: Roboto, sans-serif;font-size: 12px;border-collapse: collapse; }
    th { border: 1px solid #17657D;padding: 4px 10px;text-align: left; }
    td { border: 1px solid #17657D;padding: 2px 10px; }
    p { margin: 2px 0; font-size: 14px; }
    h2 { font-size: 18px;font-weight: bold; }
    h3 { font-size: 16px; }
    .thead { color: #ffffff;background-color: #17657D; }
    .th-1 { width: 400px; }
    </style>"""
html = f"""<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Delivery Package {DELIVERY_PACKAGE}</title>
        {style}
    </head>
    <body>
        {body}
    </body>
    </html>"""


print(f"8 - Send HTML mail")
# receiver = RECIPIENT.split(',')
# receiver = ["ddasilvateixeira-external@scor.com"]
receiver = ["ddasilvateixeira-external@scor.com", "tdeutsch-external@scor.com", "mbrik-external@scor.com"]
sender = "DELIVERY.PACKAGE@AEnDevO2Batch.azure.scor.com"
subject = f"Delivery Package {FILENAME}"
sendMail(subject, sender, receiver, html)



print(f"9 - Commit")
cmd = f"svn st {uat['file_src']}"
print(f"    - {cmd}")
os.system(cmd)
cmd = f"svn add {uat['file_src']}"
print(f"    - {cmd}")
os.system(cmd)
cmd = f"svn ci {uat['file_src']} -m '{FILENAME} Delivery Package'"
print(f"    - {cmd}")
os.system(cmd)

print("------------------------------------------------------------------------------------------")
# -- End script --

