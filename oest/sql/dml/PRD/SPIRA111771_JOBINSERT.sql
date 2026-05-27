USE BTEC
go

SELECT 'Delete BTEC JOB BEST26 begin:', getdate()

delete from btec..tjobtaskxref where I_JOB = 'best26a'
delete from btec..tgroupjobxref where I_JOB = 'best26a'
delete from BTEC..tjob where I_JOB = 'best26a'
delete from BTEC..ttask where I_TASK = 'best26a1'

SELECT 'Delete BTEC JOB BEST26 end:', getdate()
go

SELECT 'Insert BTEC JOB BEST26 begin:', getdate()

insert into btec..tjobtaskxref (I_JOB, Q_TASK_SEQ,I_TASK,T_LAST_UPDATE, V_IN_FILE_PATH_1,V_IN_FILE_PATH_2,V_OUT_FILE_PATH_1, V_OUT_FILE_PATH_2,V_OUT_FILE_PATH_3) 
values ('best26a',1,'best26a1', getDate(),'$DEST/$UTIDIR/ESED0501.cmd',' ',' ', ' ', ' ')

insert into BTEC..tgroupjobxref (C_GROUP, I_JOB, I_USER_UPDATE,T_LAST_UPDATE) values ('SYSADMIN', 'best26a','demon', getDate())

insert into BTEC..tjob 
(I_JOB, N_JOB,C_JOB_TYPE, C_JOB_PRIORITY, F_JOB_RELNCHABLE, C_JOB_PURGEABLE, F_REPORT_STEPS, F_BLACKOUT, T_BLACKOUT_START, T_BLACKOUT_END,
C_ADOBE_CONV, C_SS_CONV, Q_PURGE_DAYS, T_LAST_UPDATE, C_JOB_SIZE) 
values ('best26a', 'Closing Data Adjustments', 'best26', 5, 'N', 'A', 'N', 'N', getDate(), getDate(), 'X', 'X', 4, getDate(), 'N')

insert into BTEC..ttask 
(I_TASK, N_TASK, C_TASK_TYPE, F_TASK_RESTRTABLE, F_PERF_LOG, F_ACTIV_LOG, 
Q_COMMIT_FREQ, T_LAST_UPDATE, Q_RPT_TITLE_POS_1, Q_RPT_TITLE_POS_2, V_EXEC_FILE_PTH,
C_PARM_1, C_PARM_2, C_PARM_3, C_PARM_4, C_PARM_5, C_PARM_6, C_PARM_7, C_PARM_8, C_PARM_9,
V_RPT_PROG_PTH, V_RPT_TITLE_1, V_RPT_TITLE_2) 
values ('best26a1', 'Closing Data Adjustments', 'R', 'N', 'N', 'N', 0, getDate(), 0, 0, 'as_prserial.exe', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ')

SELECT 'Insert BTEC JOB BEST26 end:', getdate()
go

