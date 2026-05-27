USE BEST
Go


/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

 /* DROP PROC dbo.PuVERSION_02
*/
IF OBJECT_ID('dbo.PuVERSION_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuVERSION_02
   PRINT '<<< DROPPED PROC dbo.PuVERSION_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuVERSION_02
     (
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric(10,0),
       @p_segtyp_ct           char(1)
     )
as

/***************************************************

Programme: PuVERSION_02

Fichier script associé : ESUVER02.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Suppression totale d'une version

Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare 	@erreur 	int,
		@cre_d      datetime
            

select		@erreur     = 0
select		@cre_d	= getdate()



/***************************/
/* CONTROLES DE COHERENCES */
/***************************/

/* Liste des contrats avec plus d'un segment (tout contrat a forcement au moins un segment) */
/********************************************************************************************/

insert into BEST..TCTRANO ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT )
select a.CTR_NF, a.END_NT, a.SEC_NF, a.VRS_NF, a.SSD_CF, a.SEGTYP_CT, a.SEG_NF, 3
from   BEST..TCTRGRO a
where  a.VRS_NF=@p_vrs_nf and a.SEGTYP_CT=@p_segtyp_ct and a.SSD_CF=@p_ssd_cf
and	( a.CTRRET_B = 0 and ( a.SEGTYP_CT != 'E' or a.NAT_CF != 'P' ) )
and exists (select 1 from BEST..TCTRGRO b
				where a.CTR_NF = b.CTR_NF
				and a.END_NT = b.END_NT
				and a.SEC_NF = b.SEC_NF
				and a.VRS_NF = b.VRS_NF
				and a.SSD_CF = b.SSD_CF
				and a.SEGTYP_CT = b.SEGTYP_CT
				and a.SEG_NF != b.SEG_NF)



select @erreur = @@error
if @erreur != 0  
goto fin


/* Liste des contrats absents du portefeuille */
/**********************************************/

insert into BEST..TCTRANO ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT )
select CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, 2
from   BEST..TCTRGRO CTRGRO
where  VRS_NF=@p_vrs_nf 
and 	SEGTYP_CT=@p_segtyp_ct 
and 	SSD_CF=@p_ssd_cf
and	( CTRRET_B = 0 and ( SEGTYP_CT != 'E' or NAT_CF != 'P' ) )
and 	not exists ( 	
		select 1 
      	 	from  	BEST..TSEGPOR SEGPOR
       	where 	CTRGRO.CTR_NF=SEGPOR.CTR_NF 
		and 	CTRGRO.END_NT=SEGPOR.END_NT 
		and 	CTRGRO.SEC_NF=SEGPOR.SEC_NF 
		and 	CTRGRO.SEGTYP_CT=SEGPOR.SEGTYP_CT 
		and 	CTRGRO.SSD_CF=SEGPOR.SSD_CF )

select @erreur = @@error
if @erreur != 0  
goto fin


/* Liste des contrats absents de la table d'affectation issue de l'infocentre */
/******************************************************************************/

insert	into BEST..TCTRANO ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT )
select CTR_NF, END_NT, SEC_NF, @p_vrs_nf, SSD_CF, SEGTYP_CT, "", 1
from   BEST..TSEGPOR SEGPOR
where  SEGTYP_CT=@p_segtyp_ct 
and 	SSD_CF=@p_ssd_cf
and	( CTRRET_B = 0 and ( SEGTYP_CT != 'E' or CTRNAT_CT != 'P' ) )
and 	not exists ( 
		select 1 
              from	BEST..TCTRGRO CTRGRO
              where 	CTRGRO.CTR_NF=SEGPOR.CTR_NF 
		and 	CTRGRO.END_NT=SEGPOR.END_NT 
		and 	CTRGRO.SEC_NF=SEGPOR.SEC_NF 
		and 	CTRGRO.SEGTYP_CT=SEGPOR.SEGTYP_CT 
		and 	CTRGRO.SSD_CF=SEGPOR.SSD_CF 
		and 	CTRGRO.VRS_NF=@p_vrs_nf )

select @erreur = @@error
if @erreur != 0  
goto fin


/* Liste des contrats dont la nature est différente de celle du segment associé */
/********************************************************************************/

/* 05/12/1998 : On force l index de ctrgro pour des pb de perf */
/*              Sinon il prend l index ICTRGRO_00              */

insert	into BEST..TCTRANO ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT )
select CTRGRO.CTR_NF, CTRGRO.END_NT, CTRGRO.SEC_NF, CTRGRO.VRS_NF, CTRGRO.SSD_CF, 
	CTRGRO.SEGTYP_CT, CTRGRO.SEG_NF, 4
from   BEST..TCTRGRO CTRGRO (INDEX ICTRGRO_01), BEST..TSEGMENT SEGMENT
where	CTRGRO.VRS_NF=@p_vrs_nf 
and 	CTRGRO.SEGTYP_CT=@p_segtyp_ct 
and 	CTRGRO.SSD_CF=@p_ssd_cf
and	( CTRGRO.CTRRET_B = 0 and ( CTRGRO.SEGTYP_CT != 'E' or CTRGRO.NAT_CF != 'P' ) )
and 	CTRGRO.VRS_NF=SEGMENT.VRS_NF 
and 	CTRGRO.SSD_CF=SEGMENT.SSD_CF
and 	CTRGRO.SEGTYP_CT=SEGMENT.SEGTYP_CT 
and 	CTRGRO.SEG_NF=SEGMENT.SEG_NF 
and exists (
	SELECT NULL FROM 
	BEST..TSEGPOR SEGPOR
	where
		CTRGRO.CTR_NF=SEGPOR.CTR_NF 
		and 	CTRGRO.END_NT=SEGPOR.END_NT 
		and 	CTRGRO.SEC_NF=SEGPOR.SEC_NF 
		and 	CTRGRO.SEGTYP_CT=SEGPOR.SEGTYP_CT 
		and 	CTRGRO.SSD_CF=SEGPOR.SSD_CF
		and 	SEGMENT.SEGNAT_CT<>SEGPOR.CTRNAT_CT
	)

select @erreur = @@error
if @erreur != 0  
goto fin


/* Liste des contrats dont l'indice de rétrocession est différent de celui du segment associé */
/**********************************************************************************************/

insert	into BEST..TCTRANO ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT )
select CTRGRO.CTR_NF, CTRGRO.END_NT, CTRGRO.SEC_NF, CTRGRO.VRS_NF, CTRGRO.SSD_CF, 
	CTRGRO.SEGTYP_CT, CTRGRO.SEG_NF, 5
from   BEST..TCTRGRO CTRGRO, BEST..TSEGMENT SEGMENT, BEST..TSEGPOR SEGPOR
where  CTRGRO.VRS_NF=@p_vrs_nf 
and 	CTRGRO.SEGTYP_CT=@p_segtyp_ct 
and 	CTRGRO.SSD_CF=@p_ssd_cf
and	( CTRGRO.CTRRET_B = 0 and ( CTRGRO.SEGTYP_CT != 'E' or CTRGRO.NAT_CF != 'P' ) )
and 	CTRGRO.CTR_NF=SEGPOR.CTR_NF 
and 	CTRGRO.END_NT=SEGPOR.END_NT 
and 	CTRGRO.SEC_NF=SEGPOR.SEC_NF 
and 	CTRGRO.SEGTYP_CT=SEGPOR.SEGTYP_CT 
and 	CTRGRO.SSD_CF=SEGPOR.SSD_CF
and 	CTRGRO.VRS_NF=SEGMENT.VRS_NF
and 	CTRGRO.SSD_CF=SEGMENT.SSD_CF
and 	CTRGRO.SEGTYP_CT=SEGMENT.SEGTYP_CT 
and 	CTRGRO.SEG_NF=SEGMENT.SEG_NF 
and 	SEGMENT.CTRRET_B<>SEGPOR.CTRRET_B

select @erreur = @@error
if @erreur != 0  
goto fin


/* Liste des segments non issus de la rétrocession interne ou regroupant des traités proportionnels du contrôle des estimations, qui n'ont pas de ligne dans la table des estimations par segment */
/**************************************************************************************************************************************************************************************************/

insert into BEST..TSEGANO (VRS_NF, SSD_CF, SEGTYP_CT, UWY_NF, SEG_NF, ANO_CT)
select VRS_NF, SSD_CF, SEGTYP_CT, 0, SEG_NF, 12
from   BEST..TSEGMENT SEGMENT
where  VRS_NF=@p_vrs_nf 
and 	SEGTYP_CT=@p_segtyp_ct 
and 	SSD_CF=@p_ssd_cf 
and 	( CTRRET_B=0 and ( SEGNAT_CT!='P' or SEGTYP_CT!='E' ) )
and 	not exists (
		select 1 
              from	BEST..TSEGEST  SEGEST
              where	SEGMENT.VRS_NF=SEGEST.VRS_NF 
		and 	SEGMENT.SSD_CF=SEGEST.SSD_CF 
		and 	SEGMENT.SEGTYP_CT=SEGEST.SEGTYP_CT 
		and 	SEGMENT.SEG_NF=SEGEST.SEG_NF )

select @erreur = @@error
if @erreur != 0  
goto fin


/* Liste des segments dont la somme des pourcentages de ventilations si renseignés est différent de 100 */
/********************************************************************************************************/

insert into BEST..TSEGANO (VRS_NF, SSD_CF, SEGTYP_CT, UWY_NF, SEG_NF, ANO_CT)
select A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.UWY_NF, A.SEG_NF, 11
from   BEST..TLABOCY A, BEST..TSEGMENT B
where  A.VRS_NF = @p_vrs_nf
and 	A.SEGTYP_CT = @p_segtyp_ct
and 	A.SSD_CF = @p_ssd_cf
and 	A.VRS_NF = B.VRS_NF
and	A.SSD_CF = B.SSD_CF
and	A.SEGTYP_CT = B.SEGTYP_CT
and	A.SEG_NF = B.SEG_NF
and	( B.CTRRET_B = 0 and ( B.SEGTYP_CT != 'E' or B.SEGNAT_CT != 'P' ) )
group  by A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.SEG_NF, A.UWY_NF
having sum( A.SPIRAT_R ) != 1     

select @erreur = @@error
if @erreur != 0  
goto fin


/* Liste des segments dont l'indicateur S/P ne correspond pas au montant fourni */
/********************************************************************************/

insert into BEST..TSEGANO (VRS_NF, SSD_CF, SEGTYP_CT, UWY_NF, SEG_NF, ANO_CT)
select A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.UWY_NF, A.SEG_NF, 13
from   BEST..TSEGEST A, BEST..TSEGMENT B
where  A.VRS_NF = @p_vrs_nf 
and 	A.SEGTYP_CT = @p_segtyp_ct
and 	A.SSD_CF = @p_ssd_cf
and 	( ( A.AMORAT_CT='S' and A.CLMAMT_M is null ) or ( A.AMORAT_CT='R' and A.LOSRAT_R is null ) )
and 	A.VRS_NF = B.VRS_NF
and	A.SSD_CF = B.SSD_CF
and	A.SEGTYP_CT = B.SEGTYP_CT
and	A.SEG_NF = B.SEG_NF
and	( B.CTRRET_B = 0 and ( B.SEGTYP_CT != 'E' or B.SEGNAT_CT != 'P' ) )

select @erreur = @@error
if @erreur != 0  
goto fin


/* MAJ du champ d'anomalie dans la table TSEGMENT - jointure avec TSEGANO */
/**************************************************************************/

exec @erreur = BEST..PuSEGMENT_02 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct

if @erreur != 0  
goto fin


/* MAJ du champ d'anomalie dans la table TSEGMENT - jointure avec TCTRANO */
/**************************************************************************/

exec @erreur = BEST..PuSEGMENT_03 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct

if @erreur != 0  
goto fin


/* Déverrouillage de la version */
/********************************/

update BEST..TVERSION
set    VRSLOC_B=0,
       LOADING_D=@cre_d,
       VRSSTS_CT=''
where  VRS_NF=@p_vrs_nf 
and 	SEGTYP_CT=@p_segtyp_ct 
and 	SSD_CF=@p_ssd_cf

select @erreur = @@error
if @erreur != 0  
goto fin


update BEST..TVERSION
set    VRSSTS_CT='AN'
where  VRS_NF=@p_vrs_nf 
and 	SEGTYP_CT=@p_segtyp_ct 
and 	SSD_CF=@p_ssd_cf
and 	exists ( 
		select 1
              from   BEST..TCTRANO
              where 	VRS_NF=@p_vrs_nf 
		and 	SEGTYP_CT=@p_segtyp_ct 
		and 	SSD_CF=@p_ssd_cf )

select @erreur = @@error
if @erreur != 0  
goto fin


update BEST..TVERSION
set    VRSSTS_CT='AN'
where  VRS_NF=@p_vrs_nf 
and 	SEGTYP_CT=@p_segtyp_ct 
and 	SSD_CF=@p_ssd_cf
and 	VRSSTS_CT<>'AN'
and 	exists (
		select 1
              from 	BEST..TSEGANO
              where  VRS_NF=@p_vrs_nf 
		and 	SEGTYP_CT=@p_segtyp_ct 
		and 	SSD_CF=@p_ssd_cf )

select @erreur = @@error
if @erreur != 0 
goto fin
   
fin:
   if @erreur != 0
   begin
   return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESUVER02', 'PuVERSION_02', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PuVERSION_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuVERSION_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuVERSION_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuVERSION_02
 */
GRANT EXECUTE ON dbo.PuVERSION_02 TO GOMEGA
go

