USE BEST
go
IF OBJECT_ID('dbo.PuVERSION_03') IS NOT NULL
BEGIN
  DROP PROC dbo.PuVERSION_03
  PRINT '<<< DROPPED PROC dbo.PuVERSION_03 >>>'
END
go
create procedure PuVERSION_03
  (
  @p_ssd_cf              USSD_CF,
  @p_vrs_nf              numeric(10,0),
  @p_segtyp_ct           char(1)
  )
as
/***************************************************
Programme: PuVERSION_03
Fichier script associé : ESUVER03.PRC
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: 
Parametres: 
Conditions d'execution: 
Commentaires:
_________________
MODIFICATIONS
1                      Chargement partiel des tables d'estimations
2 Florent   01/06/2015 :spot:28694 Segmentation VIE
3 KBagwe  09/01/2019 :Closing Version Information not available [IN:074327]
*****************************************************/
declare   @erreur int,
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
and   SEGTYP_CT=@p_segtyp_ct 
and   SSD_CF=@p_ssd_cf 
and   SEG_NF not like '*%'
and   ( CTRRET_B=0 and ( SEGNAT_CT!='P' or SEGTYP_CT!='E' ) )
and   not exists (
    select 1 
              from    BEST..TSEGEST  SEGEST
              where   SEGMENT.VRS_NF=SEGEST.VRS_NF 
    and   SEGMENT.SSD_CF=SEGEST.SSD_CF 
    and 1 = ( case 					--mod3
              when SEGMENT.SEGTYP_CT = "A" and SEGEST.SEGTYP_CT IN ('A' ,'V') then 1
                  ELSE   
                        CASE when SEGMENT.SEGTYP_CT = "T" and SEGEST.SEGTYP_CT IN ('T' ,'W') then  1  
                                ELSE 
                                    case when SEGMENT.SEGTYP_CT = "U" and SEGEST.SEGTYP_CT IN ('U' ,'X') then 1
                                        ELSE
                                             case when SEGMENT.SEGTYP_CT = "E" and SEGEST.SEGTYP_CT IN ('E') then 1
                                                ELSE
                                                     case when SEGMENT.SEGTYP_CT = "S" and SEGEST.SEGTYP_CT IN ('S') then 1  ELSE 0
                                                END
                                        END
                                END
                            END
                                
                    
                end)
    and   SEGMENT.SEG_NF=SEGEST.SEG_NF )

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
and   A.SEGTYP_CT = @p_segtyp_ct
and   A.SSD_CF = @p_ssd_cf
and   A.VRS_NF = B.VRS_NF
and A.SSD_CF = B.SSD_CF
and A.SEGTYP_CT = B.SEGTYP_CT
and A.SEG_NF = B.SEG_NF
and ( B.CTRRET_B = 0 and ( B.SEGTYP_CT != 'E' or B.SEGNAT_CT != 'P' ) )
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
and   A.SEGTYP_CT = @p_segtyp_ct
and   A.SSD_CF = @p_ssd_cf
and   ( ( A.AMORAT_CT='S' and A.CLMAMT_M is null ) or ( A.AMORAT_CT='R' and A.LOSRAT_R is null ) )
and   A.VRS_NF = B.VRS_NF
and A.SSD_CF = B.SSD_CF
and 1 = ( case 			--mod3
              when B.SEGTYP_CT = "A" and A.SEGTYP_CT IN ('A' ,'V') then 1
                  ELSE   
                        CASE when B.SEGTYP_CT = "T" and A.SEGTYP_CT IN ('T' ,'W') then  1  
                                ELSE 
                                    case when B.SEGTYP_CT = "U" and A.SEGTYP_CT IN ('U' ,'X') then 1
                                        ELSE
                                             case when B.SEGTYP_CT = "E" and A.SEGTYP_CT IN ('E') then 1
                                                ELSE
                                                     case when B.SEGTYP_CT = "S" and A.SEGTYP_CT IN ('S') then 1  ELSE 0
                                                END
                                        END
                                END
                            END
                                
                    
                end)

and A.SEG_NF = B.SEG_NF
and ( B.CTRRET_B = 0 and ( B.SEGTYP_CT != 'E' or B.SEGNAT_CT != 'P' ) )

select @erreur = @@error
if @erreur != 0 
goto fin


/* MAJ du champ d'anomalie dans la table TSEGMENT - jointure avec TCTRANO */
/**************************************************************************/

exec @erreur = BEST..PuSEGMENT_02 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct

if @erreur != 0  goto fin


/* Déverrouillage de la version */
/********************************/

update BEST..TVERSION
set    VRSLOC_B=0,
       LOADING_D=@cre_d,
       VRSSTS_CT=''
where  VRS_NF=@p_vrs_nf 
and   SEGTYP_CT=@p_segtyp_ct 
and   SSD_CF=@p_ssd_cf

select @erreur = @@error
if @erreur != 0 
goto fin


update BEST..TVERSION
set    VRSSTS_CT='AN'
where  VRS_NF=@p_vrs_nf 
and   SEGTYP_CT=@p_segtyp_ct 
and   SSD_CF=@p_ssd_cf
and   exists (
    select 1
              from  BEST..TCTRANO
              where   VRS_NF=@p_vrs_nf 
    and   SEGTYP_CT=@p_segtyp_ct 
    and   SSD_CF=@p_ssd_cf )

select @erreur = @@error
if @erreur != 0 
goto fin


update BEST..TVERSION
set    VRSSTS_CT='AN'
where  VRS_NF=@p_vrs_nf 
and   SEGTYP_CT=@p_segtyp_ct 
and   SSD_CF=@p_ssd_cf
and   VRSSTS_CT<>'AN'
and   exists (
    select 1
              from  BEST..TSEGANO
              where   VRS_NF=@p_vrs_nf 
    and   SEGTYP_CT=@p_segtyp_ct 
    and   SSD_CF=@p_ssd_cf )

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
IF OBJECT_ID('dbo.PuVERSION_03') IS NOT NULL
  PRINT '<<< CREATED PROC dbo.PuVERSION_03 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC dbo.PuVERSION_03 >>>'
go
GRANT EXECUTE ON dbo.PuVERSION_03 TO GOMEGA, GDBBATCH
go
