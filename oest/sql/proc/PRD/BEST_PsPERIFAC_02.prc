use BEST
go
if object_id('dbo.PsPERIFAC_02') is not null
begin
  drop PROC dbo.PsPERIFAC_02
  print '<<< DROPPED PROC dbo.PsPERIFAC_02 >>>'
end
go
create procedure PsPERIFAC_02
  (
    @p_segtyp_ct      char(1), --type de segmentation ( 'A' ou 'E' )
    @p_clo_date       char(8) = '',
    @p_x_days         int = 0,
    @norme_cf         char(4) = 'I4I',
    @p_quarter_end    varchar(10) = 'NONE', --quarter end for dry run
    @p_typeinv_cf 	  char(4) = '' --[008]
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME69 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    - g�n�ration d'une table interm�diaire regroupant la derni�re ligne de BEST..TCTRULT
( CRE_D maxi ) pour un CASEX donn� afin de r�cup�rer le champs ADMMODPRM_CT
    - proc�dure appelant PsPeriFac_01 ( g�n�ration du p�rim�tre pour les affaires FAC )
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  M.HA-THUC 06/10/1998 - cette proc�dure n'est plus appel�e pour les p�rim�tres de segmentation. En
                           effet, la restriction sur la s�lection des affaires des p�rim�tres n'est plus la
                           m�me ( en segmentation, on ne prend que les contrats non termin�s SECACCSTS_CT != 9 ).
2  r. Cassis 04/06/2010 :spot:19204 - V102 - Tctrult retire car pas de facs dedans
3  Kbagwe    12/04/2013 Replacement TCLREPCR tableau obsolute
4  Kbagwe    16/04/2013 Modified for calling O2 specific PsPeriFac_01_O2 for Obsolete table change
5  P.Coppin  14/10/2013 :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2 et plus besoin de #TCLI
[006] DaD    08/01/2022  spira : 94569 Condition on contract recognition date and inception dates in pericase extractions
[007] DaD    25/04/2022    spira : 94569 add parameter Quarter End
[008] FCI    18/09/2023    spira : 101193 -  EBS / I17 - Fac Accepted 
************************************************************************************/
declare @erreur int

/* creation d'une table temporaire #TCTRULT */
/* ---------------------------------------- */
/*  V102
create table #TCTRULT(
    CTR_NF      UCTR_NF     not null,
    END_NT      UEND_NT     not null,
    SEC_NF      USEC_NF     not null,
    UWY_NF      UUWY_NF     not null,
    UW_NT       UUW_NT          not null,
    ADMMODPRM_CT    char(1)     DEFAULT 'M',
    CRE_D       datetime        null )
*/

/* Recherche de la derni�re ligne de TCTRULT pour un CASEX donn� */
/* ------------------------------------------------------------- */
/*  V102
insert into #TCTRULT
select T1.CTR_NF, T1.END_NT, T1.SEC_NF, T1.UWY_NF, T1.UW_NT, T1.ADMMODPRM_CT, T1.CRE_D
from BEST..TCTRULT T1
where T1.CRE_D = ( select max( T3.CRE_D )
    from BEST..TCTRULT T3
    where   T1.CTR_NF = T3.CTR_NF and
              T1.END_NT = T3.END_NT and
              T1.SEC_NF = T3.SEC_NF and
              T1.UWY_NF= T3.UWY_NF  and
              T1.UW_NT = T3.UW_NT )

select max(CRED_D), T1.CTR_NF, T1.END_NT, T1.SEC_NF, T1.UWY_NF, T1.UW_NT, T1.ADMMODPRM_CT
from #TCTRULT
group by T1.CTR_NF, T1.END_NT, T1.SEC_NF, T1.UWY_NF, T1.UW_NT, T1.ADMMODPRM_CT

select @erreur = @@error
if @erreur != 0  goto fin
*/

/* Cr�ation d'un index sur la table temporaire #TCTRULT */
/* ---------------------------------------------------- */

-- V102
--create index ICTRULT on #TCTRULT ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT )

-- Lancement de la proc qui g�n�re le perim�tre des affaires FAC
-- [006]
exec @erreur=BEST..PsPeriFac_01 @p_segtyp_ct, @p_clo_date, @p_x_days, @norme_cf, @p_quarter_end, @p_typeinv_cf

if @@error!=0 or @erreur!=0 goto fin
return 0

fin:
return 1
go
if object_id('dbo.PsPERIFAC_02') is not null
  print '<<< CREATED PROC dbo.PsPERIFAC_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsPERIFAC_02 >>>'
go
grant execute on dbo.PsPERIFAC_02 TO GOMEGA
go
grant execute on dbo.PsPERIFAC_02 TO GDBBATCH  -- Modif 5
go
