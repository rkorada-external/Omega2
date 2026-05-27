#! /opt/rh/rh-python38/root/usr/bin/python3
# -*- coding: utf-8 -*-
import os, sys, re, smtplib
from pathlib import Path
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

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

# Environment var
env_prefix_env = os.environ.get('ENV_PREFIX')
nchain_env = os.environ.get('NCHAIN')
hostname_env = os.environ.get('HOSTNAME')
ftmp_1_env = os.environ.get('RPTPY010_FTMP_1')
error_sas_ae_file_env = os.environ.get('RPTPY010_SAS_AE_ERROR_FILE')
error_sas_pai_file_env = os.environ.get('RPTPY010_SAS_PAI_ERROR_FILE')

# Argument var
env_arg = sys.argv[1]
receiver_mail_arg = sys.argv[2]
date_arg = sys.argv[3]

step_nb = 0

print(f'#{"="*70}')
print(f'# Start Job RPTPY012')
print(f'#{"="*70}')
print(f'#')

step_nb += 1
print(f'#{"-"*70}')
print(f'# Step {step_nb} Start : Check Report')
print(f'#')

ftmp_1_file = Path(ftmp_1_env)
ftmp_1_data = get_data(ftmp_1_file)

report = {
    'AE': {
        'am': {'fail': 0, 'success': 0, 'total': 0, 'generate': True},
        'as': {'fail': 0, 'success': 0, 'total': 0, 'generate': True},
        'eu': {'fail': 0, 'success': 0, 'total': 0, 'generate': True}
    },
    'PA': {
        'am': {'fail': 0, 'success': 0, 'total': 0, 'generate': True},
        'as': {'fail': 0, 'success': 0, 'total': 0, 'generate': True},
        'eu': {'fail': 0, 'success': 0, 'total': 0, 'generate': True}
    }
}

for key in ftmp_1_data:
    data = ftmp_1_data[key]
    report[data[0]][data[1].lower()]['total'] = data[2]
    report[data[0]][data[1].lower()]['success'] = data[3]
    report[data[0]][data[1].lower()]['fail'] = data[4]

    if int(data[2]) == 0 and int(data[3]) == 0 and int(data[4]) == 0:
        report[data[0]][data[1].lower()]['generate'] = False


send_report_pa = False
if report['PA']['as']['generate'] or report['PA']['eu']['generate'] or report['PA']['am']['generate']:
    send_report_pa = True
    print(f'{" "*4} - Profitability report generated')
else:
    print(f'{" "*4} - Profitability report not generated')

send_report_ae = False
if report['AE']['as']['generate'] or report['AE']['eu']['generate'] or report['AE']['am']['generate']:
    send_report_ae = True
    print(f'{" "*4} - Assistance Entry report generated')
else:
    print(f'{" "*4} - Assistance Entry report not generated')

bg_color_pa_as = '#A9D08E'
bg_color_pa_eu = '#A9D08E'
bg_color_pa_am = '#A9D08E'
if int(report['PA']['as']['fail']) > 0:
    bg_color_pa_as = '#FFD966'
if int(report['PA']['eu']['fail']) > 0:
    bg_color_pa_eu = '#FFD966'
if int(report['PA']['am']['fail']) > 0:
    bg_color_pa_am = '#FFD966'


bg_color_ae_as = '#A9D08E'
bg_color_ae_eu = '#A9D08E'
bg_color_ae_am = '#A9D08E'
if int(report['AE']['as']['fail']) > 0:
    bg_color_ae_as = '#FFD966'
if int(report['AE']['eu']['fail']) > 0:
    bg_color_ae_eu = '#FFD966'
if int(report['AE']['am']['fail']) > 0:
    bg_color_ae_am = '#FFD966'

print(f'#')
print(f'# Step {step_nb} End')
print(f'#{"-"*70}')
print(f'#')


if send_report_pa or send_report_ae:

    step_nb += 1
    print(f'#{"-"*70}')
    print(f'# Step {step_nb} Start : Sending Report mail')
    print(f'#')


    html = f"""
    <html>
    <body lang=EN-US>
        <div class=WordSection1>
            <table class=TableauNormal border=0 cellspacing=0 cellpadding=0 width=494 style='width:370.55pt;margin-left:.1pt;border-collapse:collapse'>
                <tr style='height:15.0pt'>
                    <td width=307 nowrap colspan=2 rowspan=2 style='width:230.0pt;border-top:#00B0F0;border-left:#00B0F0;border-bottom:black;border-right:black;border-style:solid;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:14.0pt;font-family:"Arial",sans-serif;color:#0070C0'>SAS/Omega interface status</span>
                        </p>
                    </td>
                    <td width=91 nowrap rowspan=2 style='width:68.0pt;border-top:solid #00B0F0 1.0pt;border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='font-size:12.0pt;color:#0070C0'>{env_arg.upper()}</span>
                            </b>
                        </p>
                    </td>
                    <td width=91 nowrap rowspan=2 style='width:68.0pt;border-top:solid #00B0F0 1.0pt;border-left:none;border-bottom:solid black 1.0pt;border-right:solid #00B0F0 1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='font-size:12.0pt;color:#0070C0'>{date_arg}</span>
                            </b>
                        </p>
                    </td>
                    <td style='border:none;padding:0cm 0cm 0cm 0cm' width=6>
                        <p class='MsoNormal'>&nbsp;
                    </td>
                </tr>

                <tr style='height:15.0pt'>
                    <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                
                <tr style='height:15.75pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;background:#8EA9DB;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal>
                            <b>
                                <span style='font-size:12.0pt;color:black'>PAI interface</span>
                            </b>
                        </p>
                    </td>
                    <td width=50 nowrap style='width:37.4pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='color:black'>ASIA</span>
                            </b>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='font-size:10.0pt;color:black'>EUROPE</span>
                            </b>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='font-size:10.0pt;color:black'>AMERICA</span>
                            </b>
                        </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'></td>
                </tr>

                <tr style='height:15.0pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal>
                            <span style='color:black'>Number of processed files
                            </span>
                        </p>
                    </td>
                    <td width=50 nowrap valign=bottom style='width:37.4pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['as']['total']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['eu']['total']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap valign=bottom
                        style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['am']['total']}</span>
                            </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal>
                            <span style='color:black'>SUCCEEDED
                            </span>
                        </p>
                    </td>
                    <td width=50 nowrap valign=bottom style='width:37.4pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['as']['success']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['eu']['success']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap valign=bottom
                        style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['am']['success']}</span>
                            </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal>
                            <span style='color:black'>FAILED
                            </span>
                        </p>
                    </td>
                    <td width=50 nowrap valign=bottom style='width:37.4pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt;background:{bg_color_pa_as}'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['as']['fail']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt;background:{bg_color_pa_eu}'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['eu']['fail']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap valign=bottom style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt;background:{bg_color_pa_am}'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['PA']['am']['fail']}</span>
                            </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>

                
                <tr style='height:15.75pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;background:#8EA9DB;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal>
                            <b>
                                <span style='font-size:12.0pt;color:black'>AE interface</span>
                            </b>
                        </p>
                    </td>
                    <td width=50 nowrap style='width:37.4pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='color:black'>ASIA</span>
                            </b>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='font-size:10.0pt;color:black'>EUROPE</span>
                            </b>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;background:#EDEDED;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='font-size:10.0pt;color:black'>AMERICA</span>
                            </b>
                        </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.75pt'></td>
                </tr>

                <tr style='height:15.0pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal>
                            <span style='color:black'>Number of processed files
                            </span>
                        </p>
                    </td>
                    <td width=50 nowrap valign=bottom style='width:37.4pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['as']['total']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['eu']['total']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap valign=bottom
                        style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['am']['total']}</span>
                            </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal>
                            <span style='color:black'>SUCCEEDED
                            </span>
                        </p>
                    </td>
                    <td width=50 nowrap valign=bottom style='width:37.4pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['as']['success']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['eu']['success']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap valign=bottom
                        style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['am']['success']}</span>
                            </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=257 nowrap valign=bottom style='width:192.6pt;border:none;border-left:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'>
                        <p class=MsoNormal>
                            <span style='color:black'>FAILED
                            </span>
                        </p>
                    </td>
                    <td width=50 nowrap valign=bottom style='width:37.4pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt;background:{bg_color_ae_as}'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['as']['fail']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap style='width:68.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt;background:{bg_color_ae_eu}'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['eu']['fail']}</span>
                        </p>
                    </td>
                    <td width=91 nowrap valign=bottom style='width:68.0pt;border:none;border-right:solid #00B0F0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt;background:{bg_color_ae_am}'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:10.0pt;color:black'>{report['AE']['am']['fail']}</span>
                            </p>
                    </td>
                    <td width=6 style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>

                <tr style='height:16.5pt'>
                    <td width=488 nowrap colspan=4 valign=bottom style='width:366.0pt;border:solid #0070C0 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;height:16.5pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <b>
                                <span style='font-size:12.0pt;color:#0070C0'>See Error details in attached files</span>
                            </b>
                        </p>
                   </td>
                </tr>
            </table>
        </div>
    </body>
    </html>
    """

    error_sas_ae_file = Path(error_sas_ae_file_env)
    error_sas_pai_file = Path(error_sas_pai_file_env)

    receiver = receiver_mail_arg.split(',')
    sender = f"O2.SAS.{env_arg}.REPORT@{hostname_env}.azure.scor.com"
    subject = f"Omega 2 | SAS interface report for {env_arg}"
    send_mail(subject, sender, receiver, html, error_sas_ae_file, error_sas_pai_file)

    print(f'#')
    print(f'# Step {step_nb} End')
    print(f'#{"-"*70}')
    print(f'#')

print(f'#{"="*70}')
print(f'# End Job RPTPY012')
print(f'#{"="*70}')
print(f'#')