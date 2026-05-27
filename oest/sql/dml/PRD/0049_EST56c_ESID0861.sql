USE BTEC

go

INSERT INTO BTEC..TTASK ( I_TASK, N_TASK, C_TASK_TYPE, F_TASK_RESTRTABLE, F_PERF_LOG, F_ACTIV_LOG, Q_COMMIT_FREQ, C_PARM_1, C_PARM_2, C_PARM_3, C_PARM_4, C_PARM_5, C_PARM_6, C_PARM_7, C_PARM_8, C_PARM_9, T_LAST_UPDATE, Q_RPT_TITLE_POS_1, Q_RPT_TITLE_POS_2, V_EXEC_FILE_PTH, V_RPT_PROG_PTH, V_RPT_TITLE_1, V_RPT_TITLE_2 ) 
        VALUES ( 'best21a1', 'P&C Cat Cover Upload', 'R', 'Y', 'N', 'N', 1, '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ',getDate(), 0, 0, 'as_process.exe', '', '', '' )
go


INSERT INTO BTEC..TJOBTASKXREF ( I_JOB, Q_TASK_SEQ, I_TASK, T_LAST_UPDATE, V_IN_FILE_PATH_1, V_IN_FILE_PATH_2, V_OUT_FILE_PATH_1, V_OUT_FILE_PATH_2, V_OUT_FILE_PATH_3 ) 
        VALUES ( 'best21a', 1, 'best21a1', getDate(), '$DEST/$UTIDIR/ESID0861.cmd', '', '', '', '' )
go


INSERT INTO BTEC..TJOB ( I_JOB, N_JOB, C_JOB_TYPE, C_JOB_PRIORITY, F_JOB_RELNCHABLE, C_JOB_PURGEABLE, F_REPORT_STEPS, F_BLACKOUT, T_BLACKOUT_START, T_BLACKOUT_END, C_ADOBE_CONV, C_SS_CONV, Q_PURGE_DAYS, T_LAST_UPDATE, C_JOB_SIZE ) 
        VALUES ( 'best21a', 'P&C Cat Cover Upload', 'best21a  ', 5, 'N', 'A', 'N', 'N', getDate(), getDate(), 'X', 'X', 5, getDate(), 'N' )
go


INSERT INTO btec..TGROUPJOBXREF ( C_GROUP, I_JOB, I_USER_UPDATE, T_LAST_UPDATE ) 
        VALUES ( 'SYSADMIN', 'best21a', 'demon',getDate() )
go

