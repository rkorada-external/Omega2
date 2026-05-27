USE BTEC
go

IF OBJECT_ID('dbo.ti_TTASKQUEUE') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.ti_TTASKQUEUE
    IF OBJECT_ID('dbo.ti_TTASKQUEUE') IS NOT NULL
        PRINT '<<< FAILED DROPPING TRIGGER dbo.ti_TTASKQUEUE >>>'
    ELSE
        PRINT '<<< DROPPED TRIGGER dbo.ti_TTASKQUEUE >>>'
END
go

/***************************************************
Programme:              ti_TTASKQUEUE
Domaine:                ESTIMATION
Fichier script associé: ti_TTASKQUEUE.prc
Base principale :       BEST
Version:
Auteur:                 JF VDV
Date de creation:
Description du programme: Trigger "ti_TTASKQUEUE" - Ce trigger permet d'alimenter la table best..TSEGJOB_HIST.
                          Cette table contient l'historisation des demandes de périmétres segmentation .
                          On alimente best..TSEGJOB_HIST à la création d'une demande de périmètre via l'application OEST "Lancement du périmètre".
_________________
MODIFICATION    [001]
Auteur:
Date:
Version:
Description:
*****************************************************/

create trigger ti_TTASKQUEUE on TTASKQUEUE for insert as
begin
 declare
 @numrows int,
 @numnull int,
 @errno int,
 @errmsg varchar(255)

 select @numrows= @@rowcount
 if @numrows = 0
 return

     INSERT into best..TSEGJOB_HIST
     (
     JOB_NAME,
     JOB_LNCH_D,
     JOB_USER,
     SSD_CF,
     TYP_SEG,
     JOB_COMPLETED_D,
     TASK_COMPLETED_D,
     NCHAIN
     )

     SELECT
     t1.i_job,
     t1.T_job_lnch,
     t1.i_job_user,
     convert(int,t1.n_parm_val_2), --ssd
     t1.n_parm_val_1,
     '19000101', --T_JOB_COMPLETED,
     t1.T_TASK_COMPLETED,
     'ESCD0001'

     from INSERTED T1,
          btec..ttaskqueue T2
     WHERE
         t2.V_IN_FILE_PATH_1 like '%/ESCD0001.cmd'
     and t2.c_task_status = 9
     and t2.I_JOB       = t1.I_JOB
     and t2.T_JOB_LNCH  = t1.T_JOB_LNCH
     and t2.I_JOB_USER  = t1.I_JOB_USER
     and t2.n_parm_val_2 = t1.n_parm_val_2
     and t2.n_parm_val_1 = t1.n_parm_val_1

	select @errno = @@error
	if @errno != 0
	 begin
	 select @errmsg = 'ERREUR TRIGGER'
	 goto error
	 end

	return

-- Gestion d'erreurs
error:
 raiserror @errno @errmsg
 rollback trigger
end
go

IF OBJECT_ID('dbo.ti_TTASKQUEUE') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.ti_TTASKQUEUE >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.ti_TTASKQUEUE >>>'
go
