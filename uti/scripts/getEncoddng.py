#! /opt/rh/rh-python38/root/usr/bin/python
import chardet
import os, sys
from datetime import datetime
import codecs
import glob
from pprint import pprint


def detect_bom(file_path):
    with open(file_path, 'rb') as file:
        raw = file.read(4)  # Lire les premiers 4 octets

    if raw.startswith(b'\xef\xbb\xbf'):
        return "UTF-8 BOM"
    elif raw.startswith(b'\xff\xfe\x00\x00') or raw.startswith(b'\xff\xfe'):
        return "UTF-16 LE BOM"
    elif raw.startswith(b'\x00\x00\xfe\xff'):
        return "UTF-32 BE BOM"
    elif raw.startswith(b'\xfe\xff'):
        return "UTF-16 BE BOM"
    elif raw.startswith(b'\x00\x00\xff\xfe'):
        return "UTF-32 LE BOM"
    else:
        return ""



def detect_encoding(file_path):
    with open(file_path, 'rb') as file:
        raw_data = file.read()
        result = chardet.detect(raw_data)
        encoding = result['encoding']
        confidence = result['confidence']
        return encoding, confidence


def diplay_result(file_path):
    encoding, confidence = detect_encoding(file_path)
    bom_type = detect_bom(file_path)
    file_info = os.stat(file_path)
    modification_time = datetime.fromtimestamp(file_info.st_mtime)
    if bom_type != "" : 
        encoding=bom_type
        bom_type=""

    print(f"{file_path}:{modification_time}  {encoding} {bom_type}       avec une confiance de {confidence*100:.2f}") 

pattern=sys.argv[1]
#print(pattern)
#pattern="/scor/OmegaDomain/*/oest/sql/proc/PRD/BEST_PsLIFEST_09_CUR.prc"
fichiers = glob.glob(pattern, recursive=True)
#pprint(fichiers)

for fichier in fichiers:
    diplay_result(fichier)

    

