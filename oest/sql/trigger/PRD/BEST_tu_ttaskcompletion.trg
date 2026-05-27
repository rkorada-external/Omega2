USE BTEC
go

IF OBJECT_ID('dbo.tu_ttaskcompletion') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.tu_ttaskcompletion
    IF OBJECT_ID('dbo.tu_ttaskcompletion') IS NOT NULL
        PRINT '<<< FAILED DROPPING TRIGGER dbo.tu_ttaskcompletion >>>'
    ELSE
        PRINT '<<< DROPPED TRIGGER dbo.tu_ttaskcompletion >>>'
END
go
create trigger tu_ttaskcompletion on TTASKCOMPLETION for update
as
begin
/***************************************************
Programme:              tu_ttaskcompletion
Domaine:                ESTIMATION
Fichier script associé: tu_ttaskcompletion.prc
Base principale :       BEST
Version:
Auteur:                 JF VDV
Date de creation:
Description du programme: Trigger "tu_ttaskcompletion" - Ce trigger permet de MAJ la date d'excécution du job sur la table best..TSEGJOB_HIST.
                          Cette table contient l'historisation des demandes de périmétres segmentation .
                          Déclenchement dans le job ESEJ0000.cmd par la fonction LOOP_AS_PRINT
_________________
MODIFICATION    [001]
Auteur:
Date:
Version:
Description:
*****************************************************/

    declare   @errno    int,
              @errmsg   varchar(255)

    if update(t_task_completed)
       and exists ( select NULL
                    from inserted, deleted
                    where inserted.I_JOB      = deleted.I_JOB
                      and inserted.T_JOB_LNCH = deleted.T_JOB_LNCH
                      and inserted.I_JOB_USER = deleted.I_JOB_USER
                      and inserted.V_IN_FILE_PATH_1 like '%ESCD0001.cmd%' )

        begin --  traitement pour le passage du JOB ESEJ0000.cmd (si présence de données en entrée)

            update best..TSEGJOB_HIST

            set T2.TASK_COMPLETED_D = T1.T_TASK_COMPLETED,
                T2.JOB_COMPLETED_D  = T1.T_TASK_COMPLETED

            from best..TSEGJOB_HIST T2,
                 btec..TTASKCOMPLETION T1

            where
                  convert(varchar,t2.SSD_CF)         = convert(varchar,t1.n_parm_val_2)
--                  t2.SSD_CF         = convert(int,t1.n_parm_val_2)
              and t2.JOB_NAME       = t1.I_JOB
              and t2.JOB_LNCH_D     = t1.T_JOB_LNCH
              and t2.JOB_USER       = t1.I_JOB_USER
              and t2.nchain         = 'ESCD0001'
              and t2.typ_seg        =  t1.n_parm_val_1
              and t1.c_task_status  = 2

            select @errno  = @@error
            if @errno != 0
              begin
                select @errmsg = 'ERREUR TRIGGER'
                goto error
              end

        end

return

--  Gestion d'erreurs
error:
    raiserror @errno @errmsg
    rollback  trigger
end
go
IF OBJECT_ID('dbo.tu_ttaskcompletion') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.tu_ttaskcompletion >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.tu_ttaskcompletion >>>'
go
