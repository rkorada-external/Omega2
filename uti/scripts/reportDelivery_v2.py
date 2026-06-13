#! /usr/bin/python2
# -*- coding: utf-8 -*-
import os, sys, re, smtplib
from pprint import pprint
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from xml.dom import minidom

DUTI = os.environ.get('DUTI')
DELIVERY_PATH = os.environ.get('DELIVERY_PATH')
LELT_FILENAME = os.environ.get('LELT_FILENAME')
RIGHT_FILENAME = os.environ.get('RIGHT_FILENAME')
RECIPIENT = os.environ.get('RECIPIENT')

COMPANY_ASCOTT = "ASCOTT"
COMPANY_ALTERSIS = "ALTERSIS"
COMPANY_TECH_TEAM = "TECH TEAM"
COMPANY_CAPGEMINI = "CAPGEMINI"
COMMASPACE = ', '

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

def getData(filename):
    if not os.path.isfile(filename): raise Exception(2, "{} is not file".format(fileName))
    with open(filename, "r") as f: 
        lines = f.readlines()

    result = []
    for line in lines:
        data = line.strip().split(";")
        result.append(data)

    if not result: raise Exception(1, filename)

    return result

def createElement(tagName, className, content):
    if className: 
        return """<{0} class="{1}">{2}</{0}>\n""".format(tagName, className, content)
    return """<{0}>{1}</{0}>\n""".format(tagName, content)

def createListElement(tagName, elements):
    result = ""
    for element in elements: 
        result += createElement(tagName, "", element)
    return result

def createTable(parm_company, parm_user, parm_contents):
    user = name = company = result = ""
    status = target_release = delivery_package = ""
    contents = parm_contents[:]

    for user_data in user_delivery_data:
        if user_data[0] == parm_user:
            user, name, company = user_data

    for spira_data in spira_delivery_data:
        if spira_data[0] == contents[1]:
            status = spira_data[5]
            target_release = spira_data[31]
            delivery_package = spira_data[32]

    if user == parm_user:
        contents.insert(2, status)
        contents.insert(3, target_release)
        contents.insert(4, delivery_package)
        contents.append(user)
        contents.append(name)

        r = True
        if parm_company == COMPANY_CAPGEMINI and company == COMPANY_CAPGEMINI:
            contents.append(COMPANY_CAPGEMINI)
        elif parm_company == COMPANY_ALTERSIS and company == COMPANY_ASCOTT:
            contents.append(COMPANY_ALTERSIS)
        elif parm_company == COMPANY_ALTERSIS and company == COMPANY_TECH_TEAM:
            contents.append(COMPANY_TECH_TEAM)
        else:
            r = False

        if r:
            # print(contents)
            td = createListElement("td", contents)
            result = createElement("tr", "", td)

    return result

def firstTableHtml(parm_data, tables, table_name):
    for data in parm_data:
        componant = data[0]
        revision = data[1]
        spira = data[2]
        delivery_date = data[5]
        user_delivery = data[10]

        parm_contents = [componant, spira, delivery_date, revision]
        # print(parm_contents)
        tables[COMPANY_CAPGEMINI][table_name] += createTable(COMPANY_CAPGEMINI, user_delivery, parm_contents)
        tables[COMPANY_ALTERSIS][table_name] += createTable(COMPANY_ALTERSIS, user_delivery, parm_contents)

def secondTableHtml(parm_data, tables, table_name1, table_name2):
    for data in parm_data:
        left_revision = data['LEFT'][1]
        right_revision = data['RIGHT'][1]

        if int(left_revision) < int(right_revision):
            componant = data['RIGHT'][0]
            user_delivery = data['RIGHT'][10]
            left_delivery_date = data['RIGHT'][5]
            left_spira = data['RIGHT'][2]

            parm_contents = [componant, left_spira, left_delivery_date, left_revision, right_revision]
            tables[COMPANY_CAPGEMINI][table_name1] += createTable(COMPANY_CAPGEMINI, user_delivery, parm_contents)
            tables[COMPANY_ALTERSIS][table_name1] += createTable(COMPANY_ALTERSIS, user_delivery, parm_contents)
        
        if int(left_revision) > int(right_revision):
            componant = data['LEFT'][0]
            user_delivery = data['LEFT'][10]
            left_delivery_date = data['LEFT'][5]
            left_spira = data['LEFT'][2]
            
            parm_contents = [componant, left_spira, left_delivery_date, left_revision, right_revision]
            tables[COMPANY_CAPGEMINI][table_name2] += createTable(COMPANY_CAPGEMINI, user_delivery, parm_contents)
            tables[COMPANY_ALTERSIS][table_name2] += createTable(COMPANY_ALTERSIS, user_delivery, parm_contents)

## Getting data
left_filepath = os.path.join(DELIVERY_PATH, LELT_FILENAME)
right_filepath = os.path.join(DELIVERY_PATH, RIGHT_FILENAME)
user_list_filepath = os.path.join(DUTI, "scripts", "REPORT_DELIVERY_USER_LIST.csv")
spira_list_filepath = os.path.join(DUTI, "scripts", "REPORT_DELIVERY_SPIRA_LIST.xls")

left_data = right_data = user_delivery_data = []

try:
    print("#----------------------------------------------")
    print("# Getting data")
    left_data = getData(left_filepath)
    del left_data[0]
    right_data = getData(right_filepath)
    del right_data[0]
    user_delivery_data = getData(user_list_filepath)
    del user_delivery_data[0]
    spira_delivery_data = excelParse(spira_list_filepath)
    # spira_delivery_data = getData(spira_list_filepath)
    del spira_delivery_data[0:5]

except Exception as error:
    code, content = error.args
    print("ERROR : {}".format(code))
    print(content)
    sys.exit()

right_data_rest = right_data[:]
left_data_rest = left_data[:]
left_and_right_data = []

for left in left_data:
    for right in right_data: 
        if left[0] == right[0]: 
            try: 
                right_data_rest.remove(right)
                left_data_rest.remove(left)
            except Exception as error:
                print("Exception")

            left_and_right_data.append({'LEFT': left, 'RIGHT': right})

print("# Status OK")

## creating Table
print("#----------------------------------------------")
print("# Creating table")

tables = {}
tables[COMPANY_ALTERSIS] = {}
tables[COMPANY_CAPGEMINI] = {}

thead = \
    """<tr class="thead">
        <th class="th-1">Component</th> <th>Spira</th> <th>Status</th> <th>Target Release</th> <th>Delivery Package</th> <th>Delivery Date</th> <th>Revision</th> <th>User</th> <th>Name</th> <th>Provider</th>
    </tr>"""
tables[COMPANY_ALTERSIS]['table1'] = thead
tables[COMPANY_CAPGEMINI]['table1'] = thead
firstTableHtml(left_data_rest, tables, 'table1')

tables[COMPANY_ALTERSIS]['table2'] = thead
tables[COMPANY_CAPGEMINI]['table2'] = thead
firstTableHtml(right_data_rest, tables, 'table2')

thead = \
    """<tr class="thead">
        <th class="th-1">Component</th> <th>Spira</th> <th>Status</th> <th>Target Release</th> <th>Delivery Package</th> <th>Delivery Date</th> <th>Revision DEV</th> <th>Revision ITK</th> <th>User</th> <th>Name</th> <th>Provider</th>
    </tr>"""
tables[COMPANY_ALTERSIS]['table3'] = thead
tables[COMPANY_CAPGEMINI]['table3'] = thead

tables[COMPANY_ALTERSIS]['table4'] = thead
tables[COMPANY_CAPGEMINI]['table4'] = thead

secondTableHtml(left_and_right_data, tables, 'table3', 'table4')

p = createElement("p", "", "Nombre de composant présent sur DEV : {}".format(len(left_data)))
p += createElement("p", "", "Nombre de composant présent sur ITK : {}".format(len(right_data)))
p += createElement("p", "", "Nombre de composant présent sur DEV et ITK : {}".format(len(left_and_right_data)))
p += createElement("p", "", "Nombre de composant présent sur DEV mais absents sur ITK : {}".format(len(left_data_rest)))
p += createElement("p", "", "Nombre de composant présent sur ITK mais absents sur DEV : {}".format(len(right_data_rest)))

tables_ascott = \
    """
    <h2>Les composants présents sur DEV mais absents sur ITK :</h2>
    <table>
        {table1}
    </table>
    <h2>Les composants plus récents sur DEV que ITK :</h2>
    <table>
        {table4}
    </table>
    <h2>Les composants présents sur ITK mais absents sur DEV :</h2>
    <table>
        {table2}
    </table>
    <h2>Les composants plus récents sur ITK que DEV :</h2>
    <table>
        {table3}
    </table>""".format(**tables[COMPANY_ALTERSIS])

tables_cap = \
    """
    <h2>Les composants présents sur DEV mais absents sur ITK :</h2>
    <table>
        {table1}
    </table>
    <h2>Les composants plus récents sur DEV que ITK :</h2>
    <table>
        {table4}
    </table>
    <h2>Les composants présents sur ITK mais absents sur DEV :</h2>
    <table>
        {table2}
    </table>
    <h2>Les composants plus récents sur ITK que DEV :</h2>
    <table>
        {table3}
    </table>""".format(**tables[COMPANY_CAPGEMINI])

style = \
    """<style type="text/css">
        table { font-family: Roboto, sans-serif;font-size: 12px;border-collapse: collapse; }
        th { border: 1px solid #17657D;padding: 4px 10px;text-align: left; }
        td { border: 1px solid #17657D;padding: 2px 10px; }
        p { margin: 2px 0; font-size: 14px; }
        h2 { font-size: 18px;font-weight: bold; }
        h3 { font-size: 16px; }
        .thead { color: #ffffff;background-color: #17657D; }
        .th-1 { width: 400px; }
    </style>"""

body = \
    """
    <div>{}</div>
    <h1>ALTERSIS</h1>
    {}
    <h1>CAPGEMINI</h1>
    {}""".format(p, tables_ascott, tables_cap)

html = \
    """<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Check Component Delivery DEV vs ITK</title>
        {}
    </head>
    <body>{}</body>
    </html>""".format(style, body)

print("# Status OK")

## Sending mail
print("#----------------------------------------------")
print("# Sending mail")

subject = "Check Component Delivery DEV vs ITK"
sender = "CHECK.DELIVERY.REPORT@AEnDevO2Batch.azure.scor.com"
receiver = RECIPIENT.split(',')

message = MIMEMultipart()
message["From"] = sender
message["To"] = COMMASPACE.join(receiver)
message["Subject"] = subject

part = MIMEText(html, "html")
encoders.encode_base64(part)
message.attach(part)

print("# Subject : {}".format(message["Subject"]))
print("# From    : {}".format(message["From"]))
print("# To      : {}".format(message["To"]))

server = smtplib.SMTP('localhost')
# server.set_debuglevel(1)
server.sendmail(sender, receiver, message.as_string())
server.quit()

print("# Status OK")