use BEST
go

/*
 * DROP PROC PsCMUSPLI_01
 */
IF OBJECT_ID('PsCMUSPLI_01') IS NOT NULL
BEGIN
    DROP PROC PsCMUSPLI_01
    PRINT '<<< DROPPED PROC PsCMUSPLI_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsCMUSPLI_01

with execute as caller as

/***************************************************

Programme: PsCMUSPLI_01
Fichier script associé : ESSCMI01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 15 octobre 1997
Description du programme: 

        Extraction de la table TCMUSPLI de BRET
            
Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’
*****************************************************/

create table #date (
     RETCTR_NF  URETCTR_NF  NOT NULL,
     CMU_NT     int         NULL,
     ACC_D      datetime    NULL )
     
declare @erreur int


/* Table temporaire contenant la date du rachat */
insert into #date
select distinct 
    RETCTR_NF,
    CMU_NT,
    ACC_D
from BRET..TACCTRAI
where CREUSR_CF != "DBC"
and   CMU_NT != 0
and   CMU_NT != null
and   convert(char(8),ACC_D,112) != "19990629"

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCMUSPLI" 
      return @erreur
   end


select      a.ssd_cf,
        a.retctr_nf,
        rty_nf,
        retsec_nf,
        ctr_nf,
        uw_nt,
        uwy_nf,
        sec_nf,
        end_nt,
        trncod_cf,
        cnvcur_cf,
        cnvamt_m,
        convert(char(8),c.acc_d,112),
        totcmu_r
from bret..tcmuspli a,
     btrav..testssd b,
     #date c
where a.ssd_cf=b.ssd_cf
and   a.retctr_nf = c.retctr_nf
and   a.cmu_nt = c.cmu_nt

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCMUSPLI" 
      return @erreur
   end

return 0
go

IF OBJECT_ID('PsCMUSPLI_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsCMUSPLI_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsCMUSPLI_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsCMUSPLI_01
 */
GRANT EXECUTE ON PsCMUSPLI_01 TO GOMEGA
go

