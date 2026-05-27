USE BEST
go
IF OBJECT_ID('PsCESSION_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PsCESSION_01
    IF OBJECT_ID('PsCESSION_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsCESSION_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsCESSION_01 >>>'
END
go
/*
 * creation de la procedure
 */

create procedure PsCESSION_01

as

/***************************************************

Programme: PsCESSION_01
Fichier script associ� : ESSCES01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: C.Soulier (CGI)
Date de creation: 5 aout 1997
Description du programme:

		Extraction des versements de la base retrocession
		avec selection des les versements valides et actifs
	    	ou historises et supprimes.

Parametres: aucun
Conditions d'execution:
Commentaires:

_________________
MODIFICATION 1
Auteur: Kuhna
Date:
Version:
Description: Ajout du champ retpcpcur_cf de bret..tretctr dans la selection

_________________
MODIFICATION 2
Auteur: M.HA-THUC
Date: 	14/09/1998
Version:
Description: la jointure avec la table de travail TESTSSD a �t� supprim�e. On descend
	maintenant les versements de toutes les filiales.

MODIFICATION 3
Auteur: J. Ribot
Date: 	14/02/2003
Version:
Description: ajout indicateur CONRETCTR_B

4 -=Dch=- 08/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
5 R. BEN EZZINE 01/09/2015 : spot : 29298   -- chercher la devise � partir de la section si elle est renseign�e
6 -=Dch=- 21/10/2015 :spot:29162
7 - SPIRA 111672  Evolution WAQS
*****************************************************/

declare @erreur int

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr



select
	 	a.CTR_NF,
	 	0 END_NT,
	 	a.SEC_NF,
	 	a.UWY_NF,
	 	a.UW_NT	,
	 	a.RETCTR_NF,
	 	0 RETEND_NT,
	 	a.RETSEC_NF,
	 	a.RTY_NF,
	 	1 RETUW_NT,
	 	a.CESACCSTA_N,
	 	a.CESACCEND_N,
	 	a.CESSH_R,
	 	b.SSD_CF,
	 	b.esb_cf,
	 	b.retctrcat_cf,
	 	a.ACCADMTYP_CT,
	 	b.retaccadm_b,
	 	b.clecutper_b,
	 	b.clecutper_nb,
	 	a.LOB_CF,
	  	'' CUR_CF,             /* champ cur_cf */
	 	b.retpcpcur_cf ,
	    b.CONRETCTR_B,          /* MODIF 3 */
		b.ACCFAM_CT
into #CESSION    
from	bret..tcession a, bret..tretctr b, #ssds s
where 	((a.cesupdtyp_cf='' AND a.cessts_cf='01') OR
       (a.cesupdtyp_cf='S' AND a.cessts_cf='03'))
and 	a.CESSIONCAT_CF= "1"
and 	a.retctr_nf*=b.retctr_nf
and   	a.rty_nf*=b.rty_nf
and     a.ssd_cf = s.ssd_cf


select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCESSION"
      return @erreur
   end
   
-- Mettre à jour la devise à partir de la section si cette dernière est renseignée   
update #CESSION
   set retpcpcur_cf = b.RETSPECUR_CF
 from  #CESSION c, bret..tretsec b
 where c.retctr_nf = b.retctr_nf
   and c.retsec_nf = b.retsec_nf
   and c.rty_nf = b.rty_nf
   and b.RETSPECUR_CF is not null 
   and b.RETSPECUR_CF != ' '


select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCESSION"
      return @erreur
   end
   
   
 select CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT	,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        CESACCSTA_N,
        CESACCEND_N,
        CESSH_R,
        SSD_CF,
        esb_cf,
        retctrcat_cf,
        ACCADMTYP_CT,
        retaccadm_b,
        clecutper_b,
        clecutper_nb,
        LOB_CF,
        CUR_CF,
        retpcpcur_cf,
        CONRETCTR_B,
		ACCFAM_CT
   from #CESSION
	order by CTR_NF, END_NT,SEC_NF,UWY_NF, UW_NT


select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCESSION"
      return @erreur
   end

return 0
go
EXEC sp_procxmode 'dbo.PsCESSION_01', 'unchained'
go
IF OBJECT_ID('dbo.PsCESSION_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCESSION_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCESSION_01 >>>'
go
GRANT EXECUTE ON dbo.PsCESSION_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCESSION_01 TO GDBBATCH
go
