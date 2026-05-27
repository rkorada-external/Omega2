USE BEST
go
IF OBJECT_ID('dbo.PuVERSION_07') IS NOT NULL
BEGIN
  DROP PROC dbo.PuVERSION_07
  PRINT '<<< DROPPED PROC dbo.PuVERSION_07 >>>'
END
go
create procedure PuVERSION_07
	(
	@p_ssd_cf              USSD_CF,
	@p_vrs_nf              numeric(10,0),
	@p_segtyp_ct           char(1),
	@p_err_ano             tinyint
	)
as
/***************************************************
Programme: PuVERSION_07
Fichier script associé : BEST_PuVERSION_07.prc
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI - 22/08/2004 
Date de creation: 
Description du programme: Chargement partiel des tables d'estimations
Parametres: 
Conditions d'execution: 
Commentaires: Calquée sur la PuVERSION_03
_________________
MODIFICATION
1 M.DJELLOULI 30/09/2004 On ne verrouille plus les VERSIONS qui sont en ANOMALIES
2 Florent     01/06/2015 :spot:28694 Segmentation VIE
*****************************************************/
declare 	@erreur	int,
		@cre_d      datetime
            

SELECT  @cre_d=getdate()
SELECT  @erreur = 0	


/* Contrôles sur les segments non issus de la rétrocession interne
   ou ne regroupant pas des traités proportionnels du contrôle des 
   estimations, qui n'ont pas de ligne dans la table des estimations par segment */
/**************************************************/


insert into BEST..TSEGANO (VRS_NF, SSD_CF, SEGTYP_CT, UWY_NF, SEG_NF, ANO_CT)
select VRS_NF, SSD_CF, SEGTYP_CT, 0, SEG_NF, 12
from   BEST..TSEGMENT SEGMENT
where  VRS_NF=@p_vrs_nf 
and 	SEGTYP_CT=@p_segtyp_ct 
and 	SSD_CF=@p_ssd_cf 
and   SEG_NF not like '*%'
and 	( CTRRET_B=0 and ( SEGNAT_CT!='P' or SEGTYP_CT!='E' ) )
and 	not exists (
		select 1 
              from  	BEST..TSEGEST  SEGEST
              where 	SEGMENT.VRS_NF=SEGEST.VRS_NF 
		and 	SEGMENT.SSD_CF=SEGEST.SSD_CF 
		and 	SEGMENT.SEGTYP_CT=SEGEST.SEGTYP_CT 
		and 	SEGMENT.SEG_NF=SEGEST.SEG_NF )

select @erreur = @@error
if @erreur != 0 
goto fin


/* Contrôles sur les segments dont la somme des pourcentages
   de ventilations si renseignés est différent de 100 */
/***********************************************************/

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

insert into BEST..TSEGANO (VRS_NF, SSD_CF, SEGTYP_CT, UWY_NF, SEG_NF, ANO_CT, ACY_NF)
select A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.UWY_NF, A.SEG_NF, 13, A.ACY_NF
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


/* MAJ du champ d'anomalie dans la table TSEGMENT - jointure avec TCTRANO */
/**************************************************************************/

exec @erreur = BEST..PuSEGMENT_02 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct

if @erreur != 0  goto fin


/* Déverrouillage de la version */
/********************************/
-- En Cas d'erreur, on verrouille la Version
/* DEBUT MOD01 
If @p_err_ano = 1 
    Begin
        update BEST..TVERSION
        set    VRSLOC_B=1
        where  VRS_NF=@p_vrs_nf 
        and 	SEGTYP_CT=@p_segtyp_ct 
        and 	SSD_CF=@p_ssd_cf
        
        select @erreur = @@error
        if @erreur != 0 
        goto fin
    End
FIN MOD01 */

-- Else               -- MOD01
--    Begin           -- MOD01
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
                      from	BEST..TCTRANO
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
        and  	exists (
        		select 1
                      from	BEST..TSEGANO
                      where 	VRS_NF=@p_vrs_nf 
        		and 	SEGTYP_CT=@p_segtyp_ct 
        		and 	SSD_CF=@p_ssd_cf )
        
        select @erreur = @@error
        if @erreur != 0 
        goto fin
--    End           -- MOD01

   

fin:
   if @erreur != 0
    begin 
    return @erreur
    end

return 0
go
IF OBJECT_ID('dbo.PuVERSION_07') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuVERSION_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuVERSION_07 >>>'
go
GRANT EXECUTE ON dbo.PuVERSION_07 TO GOMEGA, GDBBATCH
go

