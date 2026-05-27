#! /bin/ksh
#===============================================================================
# application name               : AE and Profitability rapport
# source name                    : ESDC0021.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 22/09/2025
# author                         : S.Behague
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
# modifications chronology       :
# [001] - 22/09/2025 S.Behague :US5609: PROD Report- job that generates closing report should be migrated in PRD - Spira 111994
# [002] - 18/11/2025 S.Behague :US7785: SAS/Omega interface - Improvement
#===============================================================================

# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd


# Job Initialization variables
#----------------------------------------------------------------------------

# Job Initialisation
#-------------------
JOBINIT

# Parameter
# ------------------------------------
set `GETPRM ${DPRM}/ESDC0020.prm`
export MAIL_ADR=$1

# Parameter
# ------------------------------------
set `GETPRM ${DPRM}/ESCJ0000.prm`
export CRE_D=$1

#AE_FICHIER_CR=${DTRANSFER}/${REPERTORY}/to/${ENV_PREFIX}_ESIJ0780_CR_${CRE_D}.dat
#AE_FICHIER_RAPPORT=${DTRANSFER}/${REPERTORY}/to/${ENV_PREFIX}_ESIJ0780_ERROR_RAPPORT_${CRE_D}.csv
#PAI_FICHIER_CR_I17G=`ls ${DTRANSFER}/${REPERTORY}/to/${ENV_PREFIX}_ESFD3860_I17G_PRO_INT_STD_PI_REPORT_*_${CRE_D}.dat`
#PAI_FICHIER_CR_I17P=`ls ${DTRANSFER}/${REPERTORY}/to/${ENV_PREFIX}_ESFD3860_I17P_PRO_INT_STD_PI_REPORT_*_${CRE_D}.dat`
#PAI_FICHIER_CR_I17L=`ls ${DTRANSFER}/${REPERTORY}/to/${ENV_PREFIX}_ESFD3860_I17L_PRO_INT_STD_PI_REPORT_*_${CRE_D}.dat`
Mail_To_Send="${DFILT}/${ENV_PREFIX}_ESDC0020_MAIL.dat"
FichierPJ=`basename ${AE_FICHIER_RAPPORT}`
FichierPJPaiI17G=`basename ${PAI_FICHIER_CR_I17G}`
FichierPJPaiI17P=`basename ${PAI_FICHIER_CR_I17P}`
FichierPJPaiI17L=`basename ${PAI_FICHIER_CR_I17L}`
RepFichierPJ=`dirname ${AE_FICHIER_RAPPORT}`
rm -f ${Mail_To_Send}


if [ ! -f ${AE_FICHIER_CR} ]
then
  JOBEND
fi
if [ ! -f ${AE_FICHIER_RAPPORT} ]
then
  touch ${AE_FICHIER_RAPPORT}
fi


NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Sort of RAPPORT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${AE_FICHIER_RAPPORT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RAPPORT_SORT_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS NOMFIC         1:1 -  1:,
        SSD_CF         2:1 -  2:EN,
        ESB_CF         3:1 -  3:EN
/OUTFILE ${SORT_O}
/KEYS
      SSD_CF,
      ESB_CF
exit
EOF
SORT

mv ${AE_FICHIER_RAPPORT} ${AE_FICHIER_RAPPORT}.tmp
echo "File name;Line error;Error message" > ${DFILT}/${NSTEP}_${IB}_RAPPORT_SORT_O2.dat
cat ${DFILT}/${NSTEP}_${IB}_RAPPORT_SORT_O.dat | awk -F";" 'BEGIN { OFS=FS } { $2 = substr($2,2) } 1' >> ${DFILT}/${NSTEP}_${IB}_RAPPORT_SORT_O2.dat
cp ${DFILT}/${NSTEP}_${IB}_RAPPORT_SORT_O2.dat ${AE_FICHIER_RAPPORT}


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Sort of CR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${AE_FICHIER_CR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CR_SORT_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS NOMFIC         4:25 - 4:28,
        SSD_CF         1:1 -  1:EN,
        ESB_CF         2:1 -  2:EN
/OUTFILE ${SORT_O}
/KEYS
      NOMFIC,
      SSD_CF,
      ESB_CF
exit
EOF
SORT


BOUNDARY=$(date +%s%N)
ENVIRONNEMENT=`echo $PRD_SRV | awk -F_ '{ print $1 }'`
Serveur=`echo $DFILP | awk -F"/" '{ print $4 }'`
MAIL_SUBJECT="Omega 2 | SAS interface report for ${ENVIRONNEMENT} ${Serveur}"

echo "To: ${MAIL_ADR}" >> ${Mail_To_Send}
echo "Subject: ${MAIL_SUBJECT}" >> ${Mail_To_Send}
echo "MIME-Version: 1.0" >> ${Mail_To_Send}
echo "Content-Type: multipart/mixed; boundary=\"${BOUNDARY}\""  >> ${Mail_To_Send}
echo "" >> ${Mail_To_Send}

# Corps du mail html
echo "--${BOUNDARY}"  >> ${Mail_To_Send}
echo "Content-Type: text/html" >> ${Mail_To_Send}
echo "" >> ${Mail_To_Send}
echo "<html>
    <body lang=EN-US>
        <div class=WordSection1>
            <table class=TableauNormal border=0 cellspacing=0 cellpadding=0 width=494 style='width:370.55pt;margin-left:.1pt;border-collapse:collapse'>
                <tr style='height:15.0pt'>
                    <td width=410 nowrap colspan=5 rowspan=2 style='width:410.0pt;border:black;border-style:solid;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:14.0pt;font-family:"Arial",sans-serif;color:#0070C0'>SAS/Omega interface status</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=2 rowspan=2 style='width:70.0pt;border:black;border-style:solid;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:14.0pt;font-family:"Arial",sans-serif;color:#0070C0'>${ENVIRONNEMENT} ${Serveur}</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=2 rowspan=2 style='width:70.0pt;border:black;border-style:solid;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:14.0pt;font-family:"Arial",sans-serif;color:#0070C0'>${CRE_D}</span>
                        </p>
                    </td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=50 nowrap colspan=9 rowspan=2 style='width:550.0pt;borderblack;border-style:solid;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:14.0pt;font-family:"Arial",sans-serif;color:#0070C0'>AE files</span>
                        </p>
                    </td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=50 nowrap colspan=1 rowspan=2 style='width:50.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Norme</span>
                        </p>
                    </td>
                    <td width=50 nowrap colspan=1 rowspan=2 style='width:50.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>SSD_CF</span>
                        </p>
                    </td>
                    <td width=50 nowrap colspan=1 rowspan=2 style='width:50.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>ESB_CF</span>
                        </p>
                    </td>
                    <td width=100 nowrap colspan=1 rowspan=2 style='width:100.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Control Status</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Total Lines</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Lines KO</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Lines Amount = 0</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Lines OK</span>
                        </p>
                    </td>
                    <td width=100 nowrap colspan=1 rowspan=2 style='width:100.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Loading Status</span>
                        </p>
                    </td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>" >> ${Mail_To_Send}
while read line
do
  SSD_CF=`echo ${line} | cut -d"~" -f1`
  ESB_CF=`echo ${line} | cut -d"~" -f2`
  NORME_CF=`echo ${line} | cut -d"~" -f4 | cut -d"_" -f 6 | awk -F"ENG" '{ print $2 }'`
  CTRL_STS=`echo ${line} | cut -d"~" -f5`
  TOT_LINES=`echo ${line} | cut -d"~" -f6`
  KO_LINES=`echo ${line} | cut -d"~" -f8`

  if [ "X${KO_LINES}" == "X" ] 
  then
    KO_LINES=${TOT_LINES}
  fi
  OK_LINES=`echo ${line} | cut -d"~" -f7`
  if [ "X${OK_LINES}" == "X" ]
  then
    OK_LINES=0
  fi
  ZERO_LINES=`echo ${line} | cut -d"~" -f9`
  if [ "X${ZERO_LINES}" == "X" ]
  then
    ZERO_LINES=0
  fi  

  #LOAD_STS=`echo ${line} | cut -d"~" -f9`
  LOAD_STS=`echo ${CTRL_STS} | awk -F"~" '{ if (($1 == "OK") || ($1 == "Few data errors"))  print "Processed" ; else  print "Not completed" }'`
  Couleur=`echo ${CTRL_STS} | awk -F"~" '{ if (($1=="KO") || ($1=="Too many errors"))  print "F7EF0F"; else print "FFFFFF" }'`
  CouleurPolice=`echo ${CTRL_STS} | awk -F"~" '{ if (($1=="KO") || ($1=="Too many errors") || ($1=="Few data errors") )  print "DB2607"; else print "black" }'`
  
  echo "<tr style='height:15.75pt'>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${NORME_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${SSD_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${ESB_CF}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${CTRL_STS}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${TOT_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${KO_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${ZERO_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${OK_LINES}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${LOAD_STS}</span>
          </b>
        </p>
      </td>
  </tr>
  <tr style='height:10.0pt'>
      <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
  </tr>" >> ${Mail_To_Send}
done < ${DFILT}/${NSTEP}_${IB}_CR_SORT_O.dat

#### Gestion PAI Files
echo "<tr style='height:15.0pt'>
                    <td width=50 nowrap colspan=9 rowspan=2 style='width:550.0pt;borderblack;border-style:solid;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:14.0pt;font-family:"Arial",sans-serif;color:#0070C0'>PAI files</span>
                        </p>
                    </td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=50 nowrap colspan=1 rowspan=2 style='width:50.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Norme</span>
                        </p>
                    </td>
                    <td width=50 nowrap colspan=1 rowspan=2 style='width:50.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>SSD_CF</span>
                        </p>
                    </td>
                    <td width=50 nowrap colspan=1 rowspan=2 style='width:50.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>ESB_CF</span>
                        </p>
                    </td>
                    <td width=100 nowrap colspan=1 rowspan=2 style='width:100.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Control Status</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Total Lines</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Lines KO</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Empty Lines</span>
                        </p>
                    </td>
                    <td width=70 nowrap colspan=1 rowspan=2 style='width:70.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Lines OK</span>
                        </p>
                    </td>
                    <td width=100 nowrap colspan=1 rowspan=2 style='width:100.0pt;border-top:#0070C0;border-left:#0070C0;border-bottom:black;border-right:#0070C0;border-style:solid;background:#E3E3E3;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:12.0pt;font-family:"Arial",sans-serif;color:#0070C0'>Loading Status</span>
                        </p>
                    </td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>" >> ${Mail_To_Send}

#PAI FIle 17G
if [ "X${PAI_FICHIER_CR_I17G}" != "X" ]
then
while read line
do
  SSD_CF=`echo ${line} | cut -d"~" -f1`
  ESB_CF=`echo ${line} | cut -d"~" -f2`
  CTRL_STS=`echo ${line} | cut -d"~" -f3`
  NORME_CF=`echo ${line} | cut -d"~" -f4 | cut -d"_" -f 3 | awk -F"PA" '{ print $2 }'`
  TOT_LINES=`echo ${line} | cut -d"~" -f5`
  KO_LINES=`echo ${line} | cut -d"~" -f6`
  let OK_LINES=${TOT_LINES}-${KO_LINES}
  LOAD_STS=`echo ${CTRL_STS} | awk '{ if ($1 == "OK")  print "Processed" ; else  print "Not completed" }'`
  Couleur=`echo ${CTRL_STS} | awk '{ if (($1=="KO") || ($1=="TME"))  print "F7EF0F"; else print "FFFFFF" }'`
  CouleurPolice=`echo ${CTRL_STS} | awk -F"~" '{ if (($1=="KO"))  print "DB2607"; else print "black" }'`
  
  echo "<tr style='height:15.75pt'>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${NORME_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${SSD_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${ESB_CF}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${CTRL_STS}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${TOT_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${KO_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${EMPTY_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${OK_LINES}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${LOAD_STS}</span>
          </b>
        </p>
      </td>
  </tr>
  <tr style='height:10.0pt'>
      <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
  </tr>" >> ${Mail_To_Send}
done < ${DFILI}/PAI_FICHIER_CR_I17G.dat
fi

#PAI File I17L
if [ "X${PAI_FICHIER_CR_I17L}" != "X" ]
then
while read line
do
  SSD_CF=`echo ${line} | cut -d"~" -f1`
  ESB_CF=`echo ${line} | cut -d"~" -f2`
  CTRL_STS=`echo ${line} | cut -d"~" -f3`
  NORME_CF=`echo ${line} | cut -d"~" -f4 | cut -d"_" -f 3 | awk -F"PA" '{ print $2 }'`
  TOT_LINES=`echo ${line} | cut -d"~" -f5`
  KO_LINES=`echo ${line} | cut -d"~" -f6`
  let OK_LINES=${TOT_LINES}-${KO_LINES}
  LOAD_STS=`echo ${CTRL_STS} | awk '{ if ($1 == "OK")  print "Processed" ; else  print "Not completed" }'`
  Couleur=`echo ${CTRL_STS} | awk '{ if (($1=="KO") || ($1=="TME"))  print "F7EF0F"; else print "FFFFFF" }'`
  CouleurPolice=`echo ${CTRL_STS} | awk -F"~" '{ if (($1=="KO"))  print "DB2607"; else print "black" }'`
  
  echo "<tr style='height:15.75pt'>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${NORME_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${SSD_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${ESB_CF}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${CTRL_STS}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${TOT_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${KO_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${EMPTY_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${OK_LINES}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${LOAD_STS}</span>
          </b>
        </p>
      </td>
  </tr>
  <tr style='height:10.0pt'>
      <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
  </tr>" >> ${Mail_To_Send}
done < ${DFILI}/PAI_FICHIER_CR_I17L.dat
fi

#PAI File I17P
if [ "X${PAI_FICHIER_CR_I17P}" != "X" ]
then
while read line
do
  SSD_CF=`echo ${line} | cut -d"~" -f1`
  ESB_CF=`echo ${line} | cut -d"~" -f2`
  NORME_CF=`echo ${line} | cut -d"~" -f4 | cut -d"_" -f 3 | awk -F"PA" '{ print $2 }'`
  CTRL_STS=`echo ${line} | cut -d"~" -f3`
  TOT_LINES=`echo ${line} | cut -d"~" -f5`
  KO_LINES=`echo ${line} | cut -d"~" -f6`
  let OK_LINES=${TOT_LINES}-${KO_LINES}
  LOAD_STS=`echo ${CTRL_STS} | awk '{ if ($1 == "OK")  print "Processed" ; else  print "Not completed" }'`
  Couleur=`echo ${CTRL_STS} | awk '{ if (($1=="KO") || ($1=="TME"))  print "F7EF0F"; else print "FFFFFF" }'`
  CouleurPolice=`echo ${CTRL_STS} | awk -F"~" '{ if (($1=="KO"))  print "DB2607"; else print "black" }'`
  
  echo "<tr style='height:15.75pt'>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${NORME_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${SSD_CF}</span>
          </b>
        </p>
      </td>
      <td width=50 nowrap colspan=1 rowspan=2 style='width:50pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${ESB_CF}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${CTRL_STS}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${TOT_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${KO_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${EMPTY_LINES}</span>
          </b>
        </p>
      </td>
      <td width=70 nowrap colspan=1 rowspan=2 style='width:70pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:black'>${OK_LINES}</span>
          </b>
        </p>
      </td>
      <td width=100 nowrap colspan=1 rowspan=2 style='width:100pt;border:solid black 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;background:#${Couleur};height:10.75pt'>
        <p class=MsoNormal align=center style='text-align:center'>
          <b>
            <span style='font-size:12.0pt;color:#${CouleurPolice}'>${LOAD_STS}</span>
          </b>
        </p>
      </td>
  </tr>
  <tr style='height:10.0pt'>
      <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
  </tr>" >> ${Mail_To_Send}
done < ${DFILI}/PAI_FICHIER_CR_I17P.dat
fi


#if [ ! -s ${PAI_FICHIER_CR_I17G} ] -a [ ! -s ${PAI_FICHIER_CR_I17P} ] -a [ ! -s ${PAI_FICHIER_CR_I17L} ]
if [ "X${PAI_FICHIER_CR_I17G}" = "X" ] -a [ "X${PAI_FICHIER_CR_I17P}" = "X" ] -a [ "X${PAI_FICHIER_CR_I17L}" = "X" ]
then
  echo "<tr style='height:15.0pt'>
                    <td width=50 nowrap colspan=9 rowspan=2 style='width:550.0pt;borderblack;border-style:solid;border-width:1.0pt'>
                        <p class=MsoNormal align=center style='text-align:center'>
                            <span style='font-size:14.0pt;font-family:"Arial",sans-serif;color:#0070C0'>No SAS files processing</span>
                        </p>
                    </td>
                </tr>
                <tr style='height:15.0pt'>
                    <td width=6 nowrap valign=bottom style='width:4.55pt;padding:0cm 3.5pt 0cm 3.5pt;height:15.0pt'></td>
                </tr>" >> ${Mail_To_Send}
fi 


echo "</table>
        </div>
    </body>
    </html>" >> ${Mail_To_Send}
echo "" >> ${Mail_To_Send}

#Calcul Nb ligne total du FichierPJ
NbLigneRapport=`cat ${AE_FICHIER_RAPPORT} | grep -v "File name" | wc -l`
NbLignePAI17G=0
NbLignePAI17P=0
NbLignePAI17L=0

if [ "X${PAI_FICHIER_CR_I17G}" != "X" ] 
then
  NbLignePAI17G=`cat ${PAI_FICHIER_CR_I17G} | wc -l`
fi
if [ "X${PAI_FICHIER_CR_I17P}" != "X" ] 
then
  NbLignePAI17P=`cat ${PAI_FICHIER_CR_I17P} | wc -l`
fi
if [ "X${PAI_FICHIER_CR_I17L}" != "X" ] 
then
  NbLignePAI17L=`cat ${PAI_FICHIER_CR_I17L} | wc -l`
fi

if [ ${NbLigneRapport} -ne 0 ]
then
  # Pièce jointe du mail
  echo "--${BOUNDARY}"  >> ${Mail_To_Send}

  echo "Content-Type: application/octet-stream; name=\"${FichierPJ}\"" >> ${Mail_To_Send}
  echo "Content-Transfer-Encoding: base64" >> ${Mail_To_Send}
  echo "Content-Disposition: attachment; filename=\"${FichierPJ}\"" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
  base64 "${AE_FICHIER_RAPPORT}" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
fi

if [ ${NbLignePAI17G} -ne 0 ]
then
  echo "--${BOUNDARY}"  >> ${Mail_To_Send}
  echo "Content-Type: application/octet-stream; name=\"${FichierPJPaiI17G}\"" >> ${Mail_To_Send}
  echo "Content-Transfer-Encoding: base64" >> ${Mail_To_Send}
  echo "Content-Disposition: attachment; filename=\"${FichierPJPaiI17G}\"" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
  base64 "${PAI_FICHIER_CR_I17G}" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
fi
if [ ${NbLignePAI17P} -ne 0 ]
then
  echo "--${BOUNDARY}"  >> ${Mail_To_Send}
  echo "Content-Type: application/octet-stream; name=\"${FichierPJPaiI17P}\"" >> ${Mail_To_Send}
  echo "Content-Transfer-Encoding: base64" >> ${Mail_To_Send}
  echo "Content-Disposition: attachment; filename=\"${FichierPJPaiI17P}\"" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
  base64 "${PAI_FICHIER_CR_I17P}" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
fi
if [ ${NbLignePAI17L} -ne 0 ]
then
  echo "--${BOUNDARY}"  >> ${Mail_To_Send}
  echo "Content-Type: application/octet-stream; name=\"${FichierPJPaiI17L}\"" >> ${Mail_To_Send}
  echo "Content-Transfer-Encoding: base64" >> ${Mail_To_Send}
  echo "Content-Disposition: attachment; filename=\"${FichierPJPaiI17L}\"" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
  base64 "${PAI_FICHIER_CR_I17L}" >> ${Mail_To_Send}
  echo "" >> ${Mail_To_Send}
fi

echo "--${BOUNDARY}--"  >> ${Mail_To_Send}


NSTEP=${NJOB}_200
# Mailing
#-----------------------------------------------------------------------------
LIBEL="Mailing to user"
MAIL_CONTENT=${Mail_To_Send}

cat ${MAIL_CONTENT} | sendmail -t 

rm -f ${AE_FICHIER_RAPPORT}.tmp

# END Of Job
#------------------------------------------------------------------------------
JOBEND

