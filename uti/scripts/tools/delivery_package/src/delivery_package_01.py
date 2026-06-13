#! /usr/bin/python3
# -*- coding: utf-8 -*-
import os, sys, re, smtplib, csv, shutil, pickle, subprocess
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
    if not os.path.isfile(filename): raise Exception(2, f"{filename} is not file")
    with open(filename, "r", encoding='utf-8', errors='ignore') as f: 
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
PY_SRC = os.environ.get('PY_SRC')
PY_DATA = os.environ.get('PY_DATA')
PY_RECEIVER = os.environ.get('PY_RECEIVER')
FILENAME_CAP = os.environ.get('FILENAME_CAP')
FILENAME_AZD = os.environ.get('FILENAME_AZD')

# ----------- Parameters -----------
VERSION = sys.argv[1]
ENV_SRC = sys.argv[2]
TARGET_RELEASE = sys.argv[3]
DELIVERY_PACKAGE = sys.argv[4]
FILENAME = sys.argv[5]
HOTFIX = sys.argv[6]
# FILENAME_CAP = sys.argv[7]

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

DELIVERY_CAP_FILENAME = f"{FILENAME_CAP}.csv"
DELIVERY_CAP_FILE = os.path.join(f"{DUTI}/scripts", DELIVERY_CAP_FILENAME)
DELIVERY_AZD_FILENAME = f"{FILENAME_AZD}.csv"
DELIVERY_AZD_FILE = os.path.join(f"{DUTI}/scripts", DELIVERY_AZD_FILENAME)



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
    prd['delivery_package'] = int(package[0])


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

    # for test PRD HF 00
    # file0 = os.path.join(DELIVERY_PATH, f"OM2.{VERSION}_DELIVERY_PRD_HF_0.csv")
    # if file0 in files: files.remove(file0)


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
    'OTHERS': {},
    'ALTERSIS': {},
    'CAPGEMINI': {},
    'ALL': {}
}
spira_items = excelParse(SPIRA_FILE)
for item in spira_items[6:]:
    key = ""
    target = ""
    package = ""
    handled_by = ""
    name = ""
    status = ""
    lot = ""
    domain = ""
    type1 = ""
    reopen = ""
    profil = ""

    if len(item) >= 1:
        key = item[0].decode()
    if len(item) >= 2:
        name = item[1].decode()
    if len(item) >= 5:
        type1 = item[4].decode()
    if len(item) >= 6:
        status = item[5].decode()
    if len(item) >= 28:
        domain = item[27].decode()
    if len(item) >= 29:
        lot = item[28].decode()
    if len(item) >= 32:
        target = item[31].decode()
    if len(item) >= 33:
        package = item[32].decode()
    if len(item) >= 38:
        reopen = item[37].decode()
    if len(item) >= 39:
        handled_by = item[38].decode()
    if len(item) >= 40:
        profil = item[39].decode()

    row = {
        'spira': key,
        'name': name,
        'status': status,
        'target': target,
        'package': package,
        'handled_by': handled_by,
        'domain': domain,
        'lot': lot,
        'type': type1,
        'reopen': reopen,
        'profil': profil,
    }
    spira_data['ALL'][key] = row

    if handled_by == COMPANY_ALTERSIS:
        target_nb2 = 10
        target_mtch = re.match(r'(..).*', target)
        if target_mtch:
            # print(target_mtch.group(0))
            nb = target_mtch.group(1)
            if nb.isdigit(): target_nb2 = int(nb)

        package_nb2 = -1
        package_nb3 = 99
        package_mtch = re.match(r'(...).*', package)
        if package_mtch:
            nb3 = package_mtch.group(1)
            if nb3.isdigit(): 
                package_nb3 = int(nb3)

        if package_nb3 == 101:
            mtch = re.match(r'.*#(..)', package)
            if mtch:
                nb2 = mtch.group(1)
                if nb2.isdigit(): 
                    package_nb2 = int(nb2)

        # ONLY PDR HF
        if not uat['target_release'] and prd['target_release']:
            # ---1---
            # spira TBC avec target release == target de livraison
            if target_nb2 == prd['target_release']:
                # ---2---
                # spira Y pour les PRD HF == 101 (101 == 101)
                if package_nb3 == prd['delivery_package']:
                    # ---3--- 
                    # spira Y entre PRD HF 101 du 00 et 01 
                    if package_nb2 != -1:
                        if package_nb2 == int(HOTFIX):
                            spira_data['Y'][key] = row
                            spira_data['ALTERSIS'][key] = row
                        if package_nb2 == 0 and int(HOTFIX) == 1:
                            spira_data['TBC'][key] = row 
                        else:
                            spira_data['OTHERS'][key] = row 
                    # ---3---  
                    # spira Y pour les PRD HF != 101
                    else:
                        spira_data['Y'][key] = row
                        spira_data['ALTERSIS'][key] = row
                # ---2---
                # spira TBC avec target release == target de livraison et un package <= pakacge de livraison (100 <= 101)
                elif (package_nb3 <= prd['delivery_package']) and (package_nb3 >= 100 or package_nb3 == 99):
                    spira_data['TBC'][key] = row
                # ---2---
                # spira CT si package > pakacge de livraison (102 > 101)
                else:
                    spira_data['OTHERS'][key] = row
            # ---1---
            # spira TBC avec target release < target de livraison et tout les packages des target release (03 < 04)
            elif target_nb2 < prd['target_release']:
                spira_data['TBC'][key] = row
            # ---1---
            # spira CT avec target release > target de livraison (05 > 04)
            else:
                spira_data['OTHERS'][key] = row


        # Condition pour UAT
        if uat['target_release']:
            # ---1---
            # spira avec target release == target de livraison
            if target_nb2 == uat['target_release']:
                # ---2---
                # spira Y pour les UAT == 210 (210 == 210)
                if package_nb3 == uat['delivery_package']:
                    spira_data['Y'][key] = row
                    spira_data['ALTERSIS'][key] = row
                # ---2---
                # spira TBC avec target release == target de livraison et un package <= pakacge de livraison (210 <= 90)
                elif (package_nb3 < uat['delivery_package']) and (package_nb3 >= 210 or package_nb3 == 99):
                    spira_data['TBC'][key] = row
                # ---2---
                # spira CT si package > pakacge de livraison (211 > 2010)
                else:
                    spira_data['OTHERS'][key] = row
            # ---1---
            # spira TBC avec target release < target de livraison et tout les packages des target release (03 < 04)
            elif target_nb2 < uat['target_release']:
                if (package_nb3 <= prd['delivery_package']) and (package_nb3 >= 100 or package_nb3 == 99):
                    spira_data['TBC'][key] = row
                else:
                    spira_data['OTHERS'][key] = row
            # ---1---
            # spira CT avec target release > target de livraison (05 > 04)    
            else:
                spira_data['OTHERS'][key] = row

    else:
        spira_data['OTHERS'][key] = row
        spira_data['CAPGEMINI'][key] = row


print(f"    - {len(spira_items)} of {SPIRA_FILE}")
print(f"    - {len(spira_data['Y'])} of Y")
print(f"    - {len(spira_data['TBC'])} of TBC")
print(f"    - {len(spira_data['OTHERS'])} of OTHERS")

print(f"5 - Get US data")

azd_items = csvParse(DELIVERY_AZD_FILE, ";")
us_data = azd_items[1:]
# us_data = us_data[:-2]
for i in us_data:
    if not i[0].isdigit():
        us_data.remove(i)

print(f"    - {len(us_data)} of {DELIVERY_AZD_FILE}")

print(f"6 - Change column Deploy of file {uat['filename_src']}")
uat_data = {
    'Y': [],
    'TBC': [],
    'OTHERS': [],
    'CAPGEMINI': [],
    'CAP_Y': [],
    'AZD_Y': [],
    'AZD': [],
    'DDL': [],
    'WARNING': [],
    'NONE': [],
}
cap_items = csvParse(DELIVERY_CAP_FILE, ";")
uat_items = csvParse(uat['file_src'], ";")
azd_components = []
for data in uat_items[1:]:
    component_key = f"{data[0]}+{data[1]}"
    is_spira_azd = False

    if not data[2].isdigit():
        if data[2][0:2] == 'CG':
            sp = data[2].split('-')
            sp = sp[-1]
        else:
            sp = data[2][2:]
            azd_components.append(component_key)
            is_spira_azd = True
        spira = sp
    else:
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
        'spira': data[2],
        'name': '#N/A',
        'status': '#N/A',
        'target': '#N/A',
        'package': '#N/A',
        'handled_by': '#N/A',
        'date_commit': '#N/A',
        'user_commit': '#N/A',
        }
    key = ""
    if spira in spira_data['Y'] and not is_spira_azd: 
        key = "Y"
        row2 = spira_data['Y'][spira]

        if row2['status'] != "DEV - Validated":
            data[4] = "TBV"
        else:
            data[4] = "Y"
        
        # print(row)
    elif spira in spira_data['TBC'] and component_key not in ref_data['Y'] and not is_spira_azd:
        key = "TBC"
        data[4] = "TBC"
        row2 = spira_data['TBC'][spira]
    else:
        key = "OTHERS"
        data[4] = "CT"

        if component_key in ref_data['Y']: 
            key = "NONE"
            # data[4] = "TBC"

        if spira == "NONE" or spira == "":
            row2['spira'] = '#N/A'
            key = "TBC"
            data[4] = "TBC"

        if spira == "99999" or spira == "999999":
            if component_key not in ref_data['Y']: 
                # print(component_key)
                key = "TBC"
                data[4] = "TBC"

        if spira in spira_data['TBC'] and not is_spira_azd:
            row2 = spira_data['TBC'][spira]

        if spira in spira_data['OTHERS'] and not is_spira_azd:
            row2 = spira_data['OTHERS'][spira]

    row1['deploy'] = data[4]

    if (not row2['spira'].isdigit() and row2['spira'] != "#N/A" and not is_spira_azd) or row2['handled_by'] == "CAPGEMINI":
        key = "CAPGEMINI"
        data[4] = deploy_old
        # print(component_key)

    if component_key in azd_components and component_key not in ref_data['Y'] and is_spira_azd:
        key = "AZD"
        data[4] = "TBC"
        row1['deploy'] = "TBC"
        # row2['spira'] = f"US{spira}"


    for data2 in cap_items[1:]:
        if data[0] == data2[0]:
            key = "CAP_Y"
            data[4] = "Y"
            row1['deploy'] = "Y"

    for data2 in azd_items[1:]:
        if spira == data2[0]:
            key = "AZD_Y"
            data[4] = "Y"
            row1['deploy'] = "Y"
            # row2['spira'] = f"US{spira}"
            row2['name'] = data2[1]
            row2['status'] = data2[2]

    if key == 'OTHERS' or key == 'TBC' and key != "CAPGEMINI":
        cmd = f"svn log -r 0:{data[1]} /scor/scoromega/delivery/{VERSION}_DELIVERY/{data[0]}"
        print(cmd)
        process = subprocess.Popen(cmd, shell=True, universal_newlines=True, stdout=subprocess.PIPE,  stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()

        # print(stdout)
        regex = r".*\sr(?P<revision>\d+)\s\|\s(?P<user>\w+)\s\|\s(?P<date>\d+-\d+-\d+\s\d+:\d+:\d+)\s.*\s\|\s\d+\sline\s\sSPIRA:\s(?P<message>\d+)\s.*"
        match_rev = re.findall(regex, stdout)
        match_rev.reverse()
        # if len(match_rev) > 2:
        for m in match_rev:
            # print(m)
            if m[3] in spira_data['Y']:
                key = "WARNING"
                data[4] = "W"
                print(m)
                # print(row1, row2)
                row1['revision'] = m[0]
                row2 = spira_data['Y'][m[3]]
                row2['date_commit'] = m[2]
                row2['user_commit'] = m[1]
                row1['deploy'] = "W"
                # print(row1, row2)
                break

    row = {**row1, **row2}

    # update 2.3 -- SCOR Target Release, Delivery Package, Status, Name
    data.append(row['target'])
    data.append(row['package'])
    data.append(row['status'])
    data.append(row['name'])

    uat_data[key].append(row)

    regex = r".*/.*/ddl/.*"
    out_match = re.match(regex, row['component'])
    if out_match:
        # print(row)

        if data[4] in ['Y', 'TBV', 'TBC']:
            uat_data['DDL'].append(row)

uat_items[0].append("STR")
uat_items[0].append("DEL_PKG")
uat_items[0].append("STATUS")
uat_items[0].append("DESC")

print(f"    - {len(uat_items)} of {uat['file_src']}")
print(f"    - {len(uat_data['Y'])} of Y")
print(f"    - {len(uat_data['TBC'])} of TBC")
print(f"    - {len(uat_data['OTHERS'])} of OTHERS")
print(f"    - {len(uat_data['CAPGEMINI'])} of CAPGEMINI")
print(f"    - {len(uat_data['CAP_Y'])} of CAPGEMINI Y")
print(f"    - {len(uat_data['WARNING'])} of WARNING")


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
print(f"    - create table Y ALTERSIS")

td_items = []
for data in uat_data['CAP_Y']:
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

table4 = createTable(th_items, td_items)
print(f"    - create table Y CAP")

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


th_items = ["Component", "Revision", "Date comit", "USER Comit", "SCOR Target Release", "Delivery Package", "Inc #","Name", "Status", "Deploy new", "Deploy old"]
td_items = []
for data in uat_data['WARNING']:
    # print(data)
    row = [
        data['component'],
        data['revision'],
        data['date_commit'],
        data['user_commit'],
        data['target'],
        data['package'],
        data['spira'],
        data['name'],
        data['status'],
        data['deploy'],
        data['deploy_old']
    ]
    # if (data['spira'].isdigit() or data['spira'] == "#N/A")  and data['handled_by'] != "CAPGEMINI":
    td_items.append(row)

table5 = createTable(th_items, td_items)
print(f"    - create table WARNING")

th_items = ["SCOR Target Release", "Delivery Package", "Inc #", "Name", "Status", "Component", "Revision", "Delivery Date", "User", "Deploy new", "Deploy old"]
td_items = []
for data in uat_data['AZD_Y']:
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

table6 = createTable(th_items, td_items)
print(f"    - create table Y AZD")


th_items = ["SCOR Target Release", "Delivery Package", "Inc #", "Name", "Status", "Component", "Revision", "Delivery Date", "User", "Deploy new", "Deploy old"]
td_items = []
for data in uat_data['AZD']:
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

table7 = createTable(th_items, td_items)
print(f"    - create table AZD")


body = f"""<div>
    <h2>Composant de {FILENAME}</h2>
    {table1}
    <h2>Composant de Azure DevOps : DELIVERY_AZD_US.csv</h2>
    {table6}
    <h2>Composant de AZD not in scope but modified since last delivery</h2>
    {table7}
    <h2>Composant de CAP : DELIVERY_CAP_FILE.csv</h2>
    {table4}
    <h2>Composant antérieur à {FILENAME}</h2>
    {table2}
    <h2>Composant Hors scope {FILENAME} : For each check if previous revision could be candidate to {FILENAME} </h2>
    {table3}
    <h2>COMPONENT WARNING</h2>
    {table5}
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
receiver = PY_RECEIVER.split(',')
# receiver = ["ddasilvateixeira-external@scor.com"]
# receiver = ["ddasilvateixeira-external@scor.com", "tdeutsch-external@scor.com", "mbrik-external@scor.com"]
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

print(f"10 - Pickle dump obj_pickle.pkl")
obj_pickle = {
    'spira_data_all': spira_data['ALL'],
    'spira_data_altersis': spira_data['ALTERSIS'],
    'us_data': us_data,
    'file': uat['file_src'],
    'VERSION': VERSION,
    'OUTPUT_FILENAME': OUTPUT_FILENAME
}

file_output = f"{PY_DATA}/obj_pickle.pkl"
with open(file_output, 'wb') as f:
    pickle.dump(obj_pickle, f, pickle.HIGHEST_PROTOCOL) 

print("------------------------------------------------------------------------------------------")
# -- End script --
