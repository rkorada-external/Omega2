USE BEST
go

/*
 * DROP PROC dbo.PsCTRULT_01
 */
IF OBJECT_ID('dbo.PsCTRULT_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRULT_01
    PRINT '<<< DROPPED PROC dbo.PsCTRULT_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCTRULT_01
      (
       @p_option         char(1)
      )
     
as

/***************************************************

Programme: PsCTRULT_01

Fichier script associé : ESSULT01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 23/10/97

Description du programme: 
   Selection des enregistrements les plus récents de la table TCTRULT en segemntation et en inventaire
 

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: M.HA-THUC
 
Date:   14/09/1998

Version: 

Description: suppression de la jointure avec BTRAV..TESTSSD. On descend 
    maintenant les ultimes de toutes les filiales. De plus, le paramètre
    @p_option ne prend plus la valeur 'I' ( pour inventaire ) mais 'Q'
    ( pour quotidien ).
    Avant cette modif, la table BEST..TCTRULT était descendue à chaque 
    inventaire; maintenant, elle est descendue quotidiennement. 

[002] -=Dch=- 07/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
*****************************************************/


declare @erreur      int        

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr



select @erreur = 0


-- Cas multifiliale ( quotidien )

if @p_option = 'Q'
BEGIN

select 
        A.CTR_NF,
        A.END_NT,
        A.SEC_NF,
    A.UWY_NF,
        A.UW_NT,
    CONVERT(char(8), A.CRE_D, 112),
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
    A.UPDUSR_CF,
    A.CREUSR_CF,
    CONVERT(char(8), A.LSTUPD_D, 112),
    A.LSTUPDUSR_CF 
from    BEST..TCTRULT A inner join #ssds S on A.SSD_CF = S.SSD_CF
where A.CRE_D = ( select max(b.CRE_D) from BEST..TCTRULT b
                  where a.CTR_NF = b.CTR_NF
                  and   a.END_NT = b.END_NT
                  and   a.SEC_NF = b.SEC_NF
                  and   a.UWY_NF = b.UWY_NF
                  and   a.UW_NT  = b.UW_NT   )                    
order by A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT

--group     by A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT
--having    A.CRE_D = max( A.CRE_D )
--order by A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT

END


-- Cas multifiliale (segmentation)
-- La liste des filiales est dans la table BTRAV..TESTSSDTMP

ELSE if @p_option = 'S'
BEGIN

select 
        A.CTR_NF,
        A.END_NT,
        A.SEC_NF,
    A.UWY_NF,
        A.UW_NT,
    CONVERT(char(8), A.CRE_D, 112),
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
    A.UPDUSR_CF,
    A.CREUSR_CF,
    CONVERT(char(8), A.LSTUPD_D, 112),
    A.LSTUPDUSR_CF 
from    BEST..TCTRULT A, #ssds S
where A.SSD_CF = S.SSD_CF
and   A.CRE_D = ( select max(b.CRE_D) from BEST..TCTRULT b
                  where a.CTR_NF = b.CTR_NF
                  and   a.END_NT = b.END_NT
                  and   a.SEC_NF = b.SEC_NF
                  and   a.UWY_NF = b.UWY_NF
                  and   a.UW_NT  = b.UW_NT   )       
order by A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT


--group     by A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT
--having    A.CRE_D = max( A.CRE_D )
--order by A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT

END

select @erreur = @@error

if @erreur != 0  goto fin


               
/**********************************************************************************/

return 0

fin:

return 1
go

/*
 * fin de la procedure 
 */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/

go

IF OBJECT_ID('PsCTRULT_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsCTRULT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsCTRULT_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsCTRULT_01
 */
GRANT EXECUTE ON PsCTRULT_01 TO GOMEGA
go
GRANT EXECUTE ON PsCTRULT_01 TO GDBBATCH
go

