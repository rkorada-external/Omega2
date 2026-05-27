USE BEST
Go

 /* DROP PROC dbo.PsPERITRT_02
*/
IF OBJECT_ID('dbo.PsPERITRT_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsPERITRT_02
   PRINT '<<< DROPPED PROC dbo.PsPERITRT_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsPERITRT_02
     (
        @p_segtyp_ct      char(1), --type de segmentation ( 'A' ou 'E' )
        @p_clo_date       char(8) = '',
	    @p_x_days         int = 0,
	    @norme_cf         char(4) = 'I4I',
        @p_quarter_end    varchar(10) = 'NONE' --quarter end for dry run,
     )

as

/***************************************************

Programme: PsPERITRT_02

Fichier script associ� : ESSSEC45.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME69 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
    - g�n�ration d'une table interm�diaire identique � BTRT..TFAMRSVP mais o� le champs
ERNPRMADM_B est d�fini en DEFAULT 1 au lieu de DEFAULT 0
    - proc�dure appelant PsPeriTrt_01 ( g�n�ration du p�rim�tre pour les affaires TRT )
      

Parametres: 
       - @p_segtyp_ct : type de segmentation ( 'A' ou 'E' )
      

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION      1

Auteur: M.HA-THUC   

Date:   06/10/98    

Version:    

Description:    
    - cette proc�dure n'est plus appel�e pour les p�rim�tres de segmentation. En 
effet, la restriction sur la s�lection des affaires des p�rim�tres n'est plus la 
m�me ( en segmentation, on ne prend que les contrats non termin�s SECACCSTS_CT != 9 ).

____________________
MODIFICATION 4
Auteur:      Kbagwe
Date:        17/04/2013
Version:
Description: :Modified for calling O2 specific PsPeriTrt_01_O2 for Obsolete table change
__________________
MODIFICATION  5
Auteur: P.Coppin
Date:   16/10/2013    
Description:  :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2

[006] D. Fillinger  03/06/2015 :spot:28742 EST41 r�cup�ration du champ URRCAL_R
[007] 10/09/2019 S.Behague :REQ_9.2: REQ.P.9.2 - Change in UPR calculation rules
[008] DaD           08/01/2022    spira : 94569 Condition on contract recognition date and inception dates in pericase extractions
[009] DaD           25/04/2022    spira : 94569 add parameter Quarter End
************************************************************************************/

declare @erreur      int
        
select @erreur = 0


/* creation d'une table temporaire #TFAMRSVP */
/* ----------------------------------------- */

create table #TFAMRSVP(
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT  1,
    END_NT       UEND_NT              DEFAULT  0,
    SEC_NF       USEC_NF              NOT NULL,
    ERNPRMADM_B  tinyint                  NULL,
    POLDURMTH_NF UPERIOD              DEFAULT 12,
    INSPOL_R     USHORAT_R            DEFAULT 1,
    URRCAL_R    USHORAT_R             NULL,   -- MODIF 006 
    POLED_D      datetime      			NULL,-- [007]
	MULTICAN_D 	datetime      			NULL	)     -- [008]    
    
/* creation d'une table temporaire #TCLI */
/* ----------------------------------------- */

create table #TCLI(
   CLI_NF        UCLI_NF   NOT NULL,
   CLIRESSSD_CF  USSD_CF   NULL,
   HORDNBR_NT    int       NULL)

/* Alimentation de la table #TFAMRSVP */
/* ---------------------------------- */

insert into #TFAMRSVP
select a.CTR_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.SEC_NF, a.ERNPRMADM_B, a.POLDURMTH_NF, a.INSPOL_R, a.URRCAL_R, a.POLED_D, a.MULTICAN_D  --MODIF 006 
from BTRT..TFAMRSVP a, BTRT..TCONTR b, BREF..TBATCHSSD T

where a.CTR_NF = b.CTR_NF
and   a.UWY_NF = b.UWY_NF
and   a.UW_NT  = b.UW_NT
and   a.END_NT = b.END_NT

and   b.SSD_CF  = T.SSD_CF
and   T.BATCHUSER_CF = suser_name()


select @erreur = @@error

if @erreur != 0  goto fin

/* Alimentation de la table #TCLI */
/* ---------------------------------- */

insert into #TCLI
select a.CLI_NF, a.CLIRESSSD_CF, A.HORDNBR_NT
from BCLI..TCLIENT a, BCLI..TCLINTSU b, BREF..TBATCHSSD T
where a.CLI_NF = b.CLI_NF
and a.CLIRESSSD_CF = b.CLIINTSSD_CF and a.HORDNBR_NT != null

and   b.CLIINTSSD_CF  = T.SSD_CF
and   T.BATCHUSER_CF = suser_name()


select @erreur = @@error
if @erreur != 0  goto fin

/* Cr�ation d'un index sur la table temporaire #TFAMRSVP */
/* ---------------------------------------------------- */

create index IFAMRSVP on #TFAMRSVP( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF ) 

/* Cr�ation d'un index sur la table temporaire #TCLI    */
/* ---------------------------------------------------- */

create index ICLI on #TCLI( CLI_NF ) 


/* Lancement de la proc qui g�n�re le perim�tre des affaires TRT */
/* ------------------------------------------------------------- */
-- [008]
exec BEST..PsPeriTrt_01 @p_segtyp_ct, @p_clo_date, @p_x_days, @norme_cf, @p_quarter_end


select @erreur = @@error

if @erreur != 0  goto fin


/***********************************************************************************/

   
return 0

fin:
return 1

go


IF OBJECT_ID('dbo.PsPERITRT_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsPERITRT_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsPERITRT_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPERITRT_02
 */
GRANT EXECUTE ON dbo.PsPERITRT_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPERITRT_02 TO GDBBATCH
go
