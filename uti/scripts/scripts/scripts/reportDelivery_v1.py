#! /usr/bin/python2
# -*- coding: utf-8 -*-
import os, sys, re, smtplib
from pprint import pprint
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

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

def getData(filename):
    if not os.path.isfile(filename): raise Exception(2, "{} is not file".format(fileName))
    with open(filename, "r") as f: 
        lines = f.readlines()

    result = []
    for line in lines:
        data = line.strip().split(";")
        result.append(data)

    if not result: raise Exception(1, filename)
    del result[0]
        
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
    result = ""
    for user_data in user_delivery_data:
        user, name, company = user_data
        contents = parm_contents[:]

        if user == parm_user:
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

        tables[COMPANY_CAPGEMINI][table_name] += createTable(COMPANY_CAPGEMINI, user_delivery, [componant, spira, delivery_date, revision])
        tables[COMPANY_ALTERSIS][table_name] += createTable(COMPANY_ALTERSIS, user_delivery, [componant, spira, delivery_date, revision])

def secondTableHtml(parm_data, tables, table_name1, table_name2):
    for data in parm_data:
        componant = data['RIGHT'][0]
        left_revision = data['LEFT'][1]
        left_spira = data['LEFT'][2]
        left_delivery_date = data['LEFT'][5]
        right_revision = data['RIGHT'][1]
        user_delivery = data['RIGHT'][10]

        if int(data['LEFT'][1]) < int(data['RIGHT'][1]):
            tables[COMPANY_CAPGEMINI][table_name1] += createTable(COMPANY_CAPGEMINI, user_delivery, [componant, left_spira, left_delivery_date, left_revision, right_revision])
            tables[COMPANY_ALTERSIS][table_name1] += createTable(COMPANY_ALTERSIS, user_delivery, [componant, left_spira, left_delivery_date, left_revision, right_revision])
        
        if int(data['LEFT'][1]) > int(data['RIGHT'][1]):
            tables[COMPANY_CAPGEMINI][table_name2] += createTable(COMPANY_CAPGEMINI, user_delivery, [componant, left_spira, left_delivery_date, left_revision, right_revision])
            tables[COMPANY_ALTERSIS][table_name2] += createTable(COMPANY_ALTERSIS, user_delivery, [componant, left_spira, left_delivery_date, left_revision, right_revision])

## Getting data
left_filepath = os.path.join(DELIVERY_PATH, LELT_FILENAME)
right_filepath = os.path.join(DELIVERY_PATH, RIGHT_FILENAME)
user_list_filepath = os.path.join(DUTI, "scripts", "REPORT_DELIVERY_USER_LIST.csv")

left_data = right_data = user_delivery_data = []

try:
    print("#----------------------------------------------")
    print("# Getting data")
    left_data = getData(left_filepath)
    right_data = getData(right_filepath)
    user_delivery_data = getData(user_list_filepath)

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
            right_data_rest.remove(right)
            left_data_rest.remove(left)

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
        <th class="th-1">Component</th> <th>Spira</th> <th>Delivery Date</th> <th>Revision</th> <th>User</th> <th>Name</th> <th>Provider</th>
    </tr>"""

tables[COMPANY_ALTERSIS]['table1'] = thead
tables[COMPANY_CAPGEMINI]['table1'] = thead
firstTableHtml(left_data_rest, tables, 'table1')

tables[COMPANY_ALTERSIS]['table2'] = thead
tables[COMPANY_CAPGEMINI]['table2'] = thead
firstTableHtml(right_data_rest, tables, 'table2')

thead = \
    """<tr class="thead">
        <th class="th-1">Component</th> <th>Spira</th> <th>Delivery Date</th> <th>Revision DEV</th> <th>Revision ITK</th> <th>User</th> <th>Name</th> <th>Provider</th>
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
        th { border: 1px solid #17657D;padding: 4px 10px;width: 100px;text-align: left; }
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