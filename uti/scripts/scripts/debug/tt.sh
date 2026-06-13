PRG=ESTC2066
export ${PRG}_LOG=${DFILT}/${PRG}.log
export ${PRG}_ANO=${DFILT}/${PRG}.ano
export SRV=''
export USR=''
export PSWD=''
export BASE=''

#Input files ..............................................
export ESTC2066_I1=$DFILT/T_ESFD3620_ESFD3621POS_05_AEnItkO2Batch_20220721230400_21595_SORT_GTSII_GLOBAL_CASHFLOW.dat
export ESTC2066_I2=/scordata_aenitko2batch/ubeu/perm/T_ESFD1130_FSEGPATTERNDSCf17_I17G_POS_20210930.dat
export ESTC2066_I3=/scordata_aenitko2batch/ubeu/perm/T_ESID0060_FCURSII_INV_20220331.dat
export ESTC2066_I4=/scordata_aenitko2batch/ubeu/perm/T_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRNPOS_20211231.dat
export ESTC2066_I5=/scordata_aenitko2batch/ubeu/perm/T_ESFD2050_ILL_BUCKET_I17G.dat

#Output files ..............................................
export ESTC2066_O1=${DFILT}/T_ESFD3620_ESFD3621POS_07_AEnItkO2Batch_20220721230400_21595_ESTC2066_GTSII_CSF.dat
export ${PRG}_PRM=/scordata_aenitko2batch/ubeu/temporaire/T_ESFD3620_ESFD3621POS_07_AEnItkO2Batch_20220721230400_21595_ESTC2066.prm



gdb ${DEXE}/${PRG}.exe

