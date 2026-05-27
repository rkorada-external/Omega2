use BEST
go
if object_id('dbo.PdVERSION_01') is not null
begin
  drop procedure dbo.PdVERSION_01
   if object_id('dbo.PdVERSION_01') is not null
      print '<<< FAILED DROPPING procedure dbo.PdVERSION_01 >>>'
    else
      print '<<< DROPPED procedure dbo.PdVERSION_01 >>>'
end
go
create procedure PdVERSION_01
  (
  @p_ssd_cf     USSD_CF,
  @p_segtyp_ct  USEGTYP_CT,
  @p_vrs_nf     numeric,
  @p_mode_batch tinyint,
  @p_sgt_nt     int=null,
  @p_erreur     varchar(64)=null output
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME34 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
     - Contrôle si la version n'est pas comptabilisée
     - Contrôle si la version n'est pas vérouillée

     - Modification d'enregistrement dans TVERSION (vérouillage de l'enregistrement).

     - Insertion de certaine paramètre dans BTEC..PiJOBQUEUE_02 afin
       de lancer une procedure de batch asynchrone qui suivant le "@p_mode_batch" oriente
       le type de traitement à effectuer tel que :
		0 => supprime les infos spécifique
		1 => supprime les infos spécifique, puis charge les infos segmentation + estimation
		2 => supprime les infos spécifique, puis charge les infos estimation
Parametres:

 	 @p_ssd_cf              USSD_CF,        : Filiale
       @p_segtyp_ct           USEGTYP_CT,     : Type segment
       @p_vrs_nf              numeric,        : Code de la version
       @p_mode_batch          tinyint,        : Mode batch a lancer
       @p_erreur       varchar(64)=null output
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 rgandhe 27/02/2014 change dateformat convert(varchar(30),@getdate) to convert(varchar(30),@getdate, 23)
2 Florent 03/04/2014 :spot:25427 Maj pour compatibilité avec la segmentation omega 1
3 Florent 02/09/2014 :spot:27368 maj pour prendre la PiJOBQUEUE_01 et message d'erreur
4 Florent 11/05/2017 :spira:58025 gestion segmentation estimation uniquqment dans base BEST
5 Charles 17/08/2018 :BJTD-CLO-905316 EXT-IFRS17-903277 - REQ 03.05 ajout du segment type 
6 M.NAJI  02/07/2019 :add uwy spira57605 ,REQ.P.03.2
*****************************************************/


declare
  @erreur      int,
  @tran_imbr   bit,
  @nbligne     smallint,
  @vrssts_ct   char(2),
  @vrsloc_b    bit,
  @sgtver_nt   int,
  @ssd_cf      varchar(30),
  @vrs_nf      varchar(30),
  @lag_cf      char(1),
  @user        UUPDUSR_CF,
  @cre_d       varchar(30),
  @vrs_copie   numeric,
  @vrs_copie_s varchar(30),
  @segtyp_SII  USEGTYP_CT

select @erreur=0, @tran_imbr=1, @cre_d=convert(varchar(30),getdate(),23), @user=suser_name(),@lag_cf=isnull((select LAG_CF from BREF..TUSR where USR_CF=suser_name()),'E')
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin tran
end

if @p_sgt_nt=null and @p_mode_batch=1
  select @p_mode_batch=3 -- rechargement avec copie version précédente

/* -------------------------------------------------------------------
   Contrôle si "vrsloc_b" est égal à 1 alors
   update interdit et renvoi message d'erreur à l'application
---------------------------------------------------------------------*/
select @vrsloc_b = vrsloc_b
  from TVERSION
 where segtyp_ct = @p_segtyp_ct
   and ssd_cf = @p_ssd_cf
   and vrs_nf = @p_vrs_nf

if @vrsloc_b = 1  begin select @p_erreur="20000 ESTIMATION;TVERSION LOCK" goto fin end

/* -------------------------------------------------------------------
   Contrôle si la version à été comptabilisée "vrssts_ct" est égal à "CO"
   Si OUI alors
   suppression interdit et renvoi message d'erreur à l'application
---------------------------------------------------------------------*/
select @vrssts_ct = vrssts_ct
  from TVERSION
 where segtyp_ct = @p_segtyp_ct
   and ssd_cf = @p_ssd_cf
   and vrs_nf = @p_vrs_nf

if @vrssts_ct = "CO"  begin select @p_erreur="20001 ESTIMATION;TVERSION CO" goto fin end

/* -------------------------------------------------------------------------

Get version number of the valid segmentation

---------------------------------------------------------------------------*/

select @sgtver_nt = sgtver_nt
  from TSEGMENTATION
 where sgt_nt = @p_sgt_nt
   and sgtsts_cf = '3'

/*--------------------------------------------
    update de vérouillage de l'enregistrement
----------------------------------------------*/
update TVERSION
 set vrsloc_b = 1,
     sgt_nt = @p_sgt_nt,
     sgtver_nt = @sgtver_nt
   where segtyp_ct = @p_segtyp_ct
     and ssd_cf = @p_ssd_cf
     and vrs_nf = @p_vrs_nf
select @erreur = @@error, @nbligne = @@rowcount
if @@transtate = 2
begin
  select @p_erreur = "ERREUR trigger"
  goto fin
end
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;TVERSION " + convert(varchar(10), @erreur) + ";"
  goto fin
end

-- Suppression totale version et rechargement total
--  ou option 3 rechargement via la copie de la version précédente
IF @p_mode_batch in(1,3)
begin
  delete BEST..TCTRANO
   where  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf    
   and 1 = ( case 						--modif5
              when @p_segtyp_ct = "A" and SEGTYP_CT IN ('A' ,'V') then 1
                  ELSE   
                        CASE when @p_segtyp_ct = "T" and SEGTYP_CT IN ('T' ,'W') then  1  
                                ELSE 
                                    case when @p_segtyp_ct = "U" and SEGTYP_CT IN ('U' ,'X') then 1
                                        ELSE
                                             case when @p_segtyp_ct = "E" and SEGTYP_CT IN ('E') then 1
                                                ELSE
                                                     case when @p_segtyp_ct = "S" and SEGTYP_CT IN ('S') then 1  ELSE 0
                                                END
                                        END
                                END
                            END
                                
                    
                end)
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20003 APPLICATIF;TCTRANO " + convert(varchar(10), @erreur) + ";"
    goto fin
  end
end

-- Suppression partielle version et rechargement partiel
IF @p_mode_batch in(1,2,3)
begin
  delete BEST..TSEGANO
   where VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and 
    1 = ( case 						--modif5
              when @p_segtyp_ct = "A" and SEGTYP_CT IN ('A' ,'V') then 1
                  ELSE   
                        CASE when @p_segtyp_ct = "T" and SEGTYP_CT IN ('T' ,'W') then  1  
                                ELSE 
                                    case when @p_segtyp_ct = "U" and SEGTYP_CT IN ('U' ,'X') then 1
                                        ELSE
                                             case when @p_segtyp_ct = "E" and SEGTYP_CT IN ('E') then 1
                                                ELSE
                                                     case when @p_segtyp_ct = "S" and SEGTYP_CT IN ('S') then 1  ELSE 0
                                                END
                                        END
                                END
                            END
                                
                    
                end)
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20003 APPLICATIF;TSEGANO " + convert(varchar(10), @erreur) + ";"
    goto fin
  end
end
 --modif5 add p_segtyp_ct='V'
IF @p_mode_batch=3
begin
  -- on n'aura pas de type S ici, mais pour faire TSEGEST il faut prendre les type S quand on traite le type A et V
  if (@p_segtyp_ct='A' or @p_segtyp_ct='V')
    select @segtyp_SII='S'
  else
    select @segtyp_SII=@p_segtyp_ct

  delete BEST..TESTSCH where USR_CF=@user
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20003 APPLICATIF;TCTRGRO " + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  delete BEST..TCTRGRO
  where VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20003 APPLICATIF;TCTRGRO " + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  delete BEST..TSEGEST
  where  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and  (SEGTYP_CT = @segtyp_SII
  OR
       1 = ( case 						--modif5
              when @p_segtyp_ct = "A" and SEGTYP_CT IN ('A' ,'V') then 1
                  ELSE   
                        CASE when @p_segtyp_ct = "T" and SEGTYP_CT IN ('T' ,'W') then  1  
                                ELSE 
                                    case when @p_segtyp_ct = "U" and SEGTYP_CT IN ('U' ,'X') then 1
                                        ELSE
                                             case when @p_segtyp_ct = "E" and SEGTYP_CT IN ('E') then 1
                                                ELSE
                                                     case when @p_segtyp_ct = "S" and SEGTYP_CT IN ('S') then 1  ELSE 0
                                                END
                                        END
                                END
                            END
                                
                    
                end)
  )
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20003 APPLICATIF;TSEGEST " + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  delete BEST..TSEGMENT
  where  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20003 APPLICATIF;TSEGMENT " + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  --insertion à partir de la version précédente
  select @vrs_copie=max(VRS_NF) from BEST..TVERSION where  SEGTYP_CT=@p_segtyp_ct and SSD_CF=@p_ssd_cf and VRS_NF!=@p_vrs_nf

  insert TCTRGRO
  select CTR_NF,END_NT,SEC_NF,VRS_NF=@p_vrs_nf,SSD_CF,SEGTYP_CT,SEG_NF,DIV_NT,CED_NF
        ,UWGRP_CF,LOB_CF,SOB_CF,TOP_CF,NAT_CF,SUBNAT_CF,PCPRSKTRY_CF,SECINC_D,SECCAN_D,CTRRET_B,CRE_D=@cre_d,UWY_NF -- [6] add UWY_NF
    from TCTRGRO
     where VRS_NF=@vrs_copie and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20001 APPLICATIF;TCTRGRO " + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  insert TSEGEST
  select VRS_NF=@p_vrs_nf,SSD_CF,SEGTYP_CT,SEG_NF,UWY_NF,CRE_D=@cre_d,CUR_CF,PRMAMT_M,CLMAMT_M,LOSRAT_R,AMORAT_CT,ACY_NF
   from TSEGEST
    where VRS_NF=@vrs_copie and SSD_CF=@p_ssd_cf and  SEGTYP_CT in (@p_segtyp_ct, @segtyp_SII)
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20001 APPLICATIF;TSEGEST " + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  insert TSEGMENT
  select VRS_NF=@p_vrs_nf,SSD_CF,SEGTYP_CT,SEG_NF,SEG_LL,CUR_CF,SEGNAT_CT,CTRRET_B,ANO_B,RETRO_NP
   from TSEGMENT
    where VRS_NF=@vrs_copie and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20001 APPLICATIF;TSEGMENT " + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  -----------------------------------------------------------------------------
  -- Lancement procedure batch asynchrone qui supprime les infos spécifique
  --  à la version et les infos segment qui lui sont rattachées.
  ------------------------------------------------------------------------------
  select @ssd_cf=convert(varchar(30),@p_ssd_cf)
  select @vrs_nf=convert(varchar(30),@p_vrs_nf)
  select @vrs_copie_s=convert(varchar(30),@vrs_copie)
  exec @erreur=BTEC..PiJOBQUEUE_01
                            "best04a",
                            @user,
                            null,
                            @ssd_cf,
                            @p_segtyp_ct,
                            @user,
                            @lag_cf,
                            'null',  --SGT_NT
                            @vrs_nf,
                            '3', -- mode batch
                            @cre_d,
                            @vrs_copie_s,
             '','','','','','','','','',@p_erreur output
  if @erreur!=0 goto fin
end

if @tran_imbr=0 commit tran
return @erreur

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
if object_id('dbo.PdVERSION_01') is not null
  print '<<< CREATED PROC dbo.PdVERSION_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PdVERSION_01 >>>'
go
grant execute on dbo.PdVERSION_01 TO GOMEGA
go
grant execute on dbo.PdVERSION_01 TO GDBBATCH
go
