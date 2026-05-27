USE BEST
Go

/*
 * DROP PROC PiCTRULT_01 */
IF OBJECT_ID('PiCTRULT_01') IS NOT NULL
BEGIN
    DROP PROC PiCTRULT_01
    PRINT '<<< DROPPED PROC PiCTRULT_01 >>>'
END
go

/*
 * creation de la procedure */
create procedure PiCTRULT_01
with execute as caller
as
/***************************************************
Programme:                  PiCTRULT_01
Fichier script associé :    ESIULT01.PRC
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation:           18/06/97
Description du programme:   - Extraction de la dernière position d'ultime en primes et sinistres pour chaque affaire sélectionnée.

_________________
MODIFICATION 1
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           07/12/2009
Version:        9.1
Description:    ESTDOM15043 Ultimes  Revisions des regles de gestion et corrections de l'écran estimation des ultimes
                - Mise aux normes de la table BTRAV TESTCTRULT devient : BTRAV..EST_ULT_ESEJ1000_TCTRULT
[003] 30/09/2013 R. Cassis   :spot:25427  - Modifications pour omega2 -1b ajout 'execute avec caller'
*****************************************************/

declare @erreur     int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
begin
    select @tran_imbr = 0
    BEGIN TRAN
end


/* ------------------------------------------------------------
   Sélection des montants ultimes
 -------------------------------------------------------------- */
insert into	BTRAV..EST_ULT_ESEJ1000_TCTRULT     --[002] BTRAV..TESTCTRULT
    ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, CRE_D, SSD_CF, DIV_NT, CUR_CF,
      CALAMTPRM_M, ENTAMTPRM_M, RETAMTPRM_M, ADMMODPRM_CT, RESPRM_M, CALAMTCLM_M, ENTAMTCLM_M, RETAMTCLM_M,
      ADMMODCLM_CT, ORICOD_LS, UPDUSR_CF )
select A.CTR_NF,
       A.UWY_NF,
       A.UW_NT,
       A.END_NT,
       A.SEC_NF,
       A.CRE_D,
       A.SSD_CF,
       A.DIV_NT,
       A.CUR_CF,
       A.CALAMTPRM_M,
       A.ENTAMTPRM_M,
       A.RETAMTPRM_M,
       A.ADMMODPRM_CT,
       A.RESPRM_M,
       A.CALAMTCLM_M,
       A.ENTAMTCLM_M,
       A.RETAMTCLM_M,
       A.ADMMODCLM_CT,
       A.ORICOD_LS,
       A.UPDUSR_CF
from BEST..TCTRULT A, BTRAV..TESTCTRLIS B
where A.CTR_NF = B.CTR_NF
  and A.UWY_NF = B.UWY_NF
  and A.UW_NT = B.UW_NT
  and A.END_NT = B.END_NT
  and A.SEC_NF = B.SEC_NF
group by A.CTR_NF, A.UWY_NF, A.UW_NT, A.END_NT, A.SEC_NF
having A.CRE_D = max (A.CRE_D)
order by A.CTR_NF, A.UWY_NF, A.UW_NT, A.END_NT, A.SEC_NF

select @erreur = @@error
if @erreur != 0
    goto fin


select CTR_NF,
       UWY_NF,
       UW_NT,
       END_NT,
       SEC_NF,
       convert( char(10), CRE_D, 102 ),
       SSD_CF,
       DIV_NT,
       CUR_CF,
       CALAMTPRM_M,
       ENTAMTPRM_M,
       RETAMTPRM_M,
       ADMMODPRM_CT,
       RESPRM_M,
       CALAMTCLM_M,
       ENTAMTCLM_M,
       RETAMTCLM_M,
       ADMMODCLM_CT,
       ORICOD_LS,
       UPDUSR_CF,
       ULTUPDTYP_CF
from BTRAV..EST_ULT_ESEJ1000_TCTRULT     --[002] BTRAV..TESTCTRULT

select @erreur = @@error
if @erreur != 0
    goto fin


/**********************************************************************************/

if @tran_imbr = 0
	COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return 1
go

/*
 * fin de la procedure */

IF OBJECT_ID('PiCTRULT_01') IS NOT NULL
    PRINT '<<< CREATED PROC PiCTRULT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiCTRULT_01 >>>'
go

/*
 * Granting/Revoking Permissions on PiCTRULT_01 */
GRANT EXECUTE ON PiCTRULT_01 TO GOMEGA
go
GRANT EXECUTE ON PiCTRULT_01 TO GDBBATCH
go


