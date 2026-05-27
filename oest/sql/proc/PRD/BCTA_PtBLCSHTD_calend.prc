USE BCTA
go
IF OBJECT_ID('PtBLCSHTD_calend') IS NOT NULL
BEGIN
    DROP PROCEDURE PtBLCSHTD_calend
    IF OBJECT_ID('PtBLCSHTD_calend') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PtBLCSHTD_calend >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PtBLCSHTD_calend >>>'
END
go

CREATE OR REPLACE PROCEDURE dbo.PtBLCSHTD_calend
  (
  @p_blcshtyea_nf smallint=null
 ,@p_blcshtmth_nf tinyint=null
 ,@p_erreur       varchar(64)=null output
  )
as
/***************************************************
Domaine : (RF) Références
Base principale : BCTA
Auteur: Florent
Date de creation: 21/04/2011
Description du programme: :spot:21886 Insertion ou modification
Conditions d'execution: par une insertion ou update de BREF..TCALEND
Commentaires: appelée par RFRJ0042.cmd (exec sans paramètres), PuCALEND_01 et PiCALEND_01
_________________
1 Florent 08/10/2012 :spot:24041 modif possible si l'année/mois bilan est supérieur ou égale l'année/mois du système
                                     gestion de la date de comptabilisation des règlements
2 Florent 22/01/2013 :spot:24698 mise à null des Fin Post Oméga Social IFRS et EBS si pas de clôture
3 Florent 25/07/2013 :spot:25176 on teste plus de colonne pour la maj de TBLCSHTD !
[004] 26/05/2015 Roger  :spot:28811 Ajout de la gestion de la demande R pour pour le blocage du deversement de la Rétro
[006] 02/05/2017 Ruhi :CR:59027 Group Calendar: Add two new columns for booking POCI and POCE  
[007] 16/06/2017 Riyadh : Spira 52744 : GUI: Mut Re wrong value on Closing Date 
[008] 25/09/2018 Keshav : REQ 03.01 Group Calendar: Add two new columns for booking POSI17 and POC17
[009] 25/10/2021 HR: SPIRA 95833 M, R, V request in TI17REQJOBPLAN
[010] 14/12/2021 HR: SPIRA 101004 CRE_D
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@maj       datetime
 ,@REQCOD_CT char(1)
 ,@annee_mois int
 ,@REQCOD_CT2 varchar(10)  --[004]
 ,@inc smallint        --[004]
 ,@p_blcshtmth_tmp tinyint --[007]

select @erreur=0, @tran_imbr=1, @maj=getdate(), @REQCOD_CT='V',@annee_mois=year(getdate())*100+month(getdate())
if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

-- modif 2
update BREF..TCALEND
 set PSTOMGEND_D=null
    ,EBSPSTOMGEND_D=null
  where CLOSING_B=0
    and (PSTOMGEND_D!=null or EBSPSTOMGEND_D!=null)
	
-- Modification [006]
update BREF..TCALEND
 set PSTOMGCONEND_D=null
    ,EBSPSTOMGCONEND_D=null
  where CLOSING_B=0
    and (PSTOMGCONEND_D!=null or EBSPSTOMGCONEND_D!=null)	
	
-- Modification [008]
update BREF..TCALEND
 set PSTOMGEND17_D=null
    ,PSTOMGCONEND17_D=null
  where CLOSING_B=0
    and (PSTOMGEND17_D!=null or PSTOMGCONEND17_D!=null)	

update TBLCSHTD
 set STR_D=(select convert(char(8),dateadd(dd,1,END_D),112) from TBLCSHTD m
            where m.BLCSHTMTH_NF= case when a.BLCSHTMTH_NF=1 then 12 else a.BLCSHTMTH_NF - 1 end
              and m.BLCSHTYEA_NF= a.BLCSHTYEA_NF - case when a.BLCSHTMTH_NF=1 then 1 else 0 end
              and a.DIR_CF=m.DIR_CF
              and a.DMN_CF=m.DMN_CF
              and a.ESB_CF=m.ESB_CF
              and a.SSD_CF=m.SSD_CF)
    ,END_D=convert(char(8),case when DMN_CF=3 then b.SACCOUNT_D else b.END_D end,112)+' 23:59:59' -- modif 1
    ,SPCEND_D=convert(char(8),b.SPECEND_D,112)+' 23:59:59'
    ,VLD1_D=@maj
from TBLCSHTD a, BREF..TCALEND b
 where a.DMN_CF in(1,2,3)
   and ((@p_blcshtyea_nf=null and b.BLCSHTYEA_NF*100+b.BLCSHTMTH_NF >= @annee_mois)
            or (b.BLCSHTYEA_NF=@p_blcshtyea_nf and b.BLCSHTMTH_NF=@p_blcshtmth_nf))                 --modif 1
   and a.BLCSHTMTH_NF = b.BLCSHTMTH_NF
   and a.BLCSHTYEA_NF = b.BLCSHTYEA_NF
   and VLDUSR1_CF='dbo'
   and (   a.END_D!=convert(char(8),case when DMN_CF=3 then b.SACCOUNT_D else b.END_D end,112)+' 23:59:59'  --modif 1
        or SPCEND_D!=convert(char(8),b.SPECEND_D,112)+' 23:59:59'
        or STR_D!=(select convert(char(8),dateadd(dd,1,END_D),112) from TBLCSHTD m
            where m.BLCSHTMTH_NF= case when a.BLCSHTMTH_NF=1 then 12 else a.BLCSHTMTH_NF - 1 end
              and m.BLCSHTYEA_NF= a.BLCSHTYEA_NF - case when a.BLCSHTMTH_NF=1 then 1 else 0 end
              and a.DIR_CF=m.DIR_CF
              and a.DMN_CF=m.DMN_CF
              and a.ESB_CF=m.ESB_CF
              and a.SSD_CF=m.SSD_CF)
        ) -- modif 3, fin du OR

select @erreur = @@error
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;TBLCSHTD_" + convert(varchar(10), @erreur) + ";"
  goto fin
end

insert into TBLCSHTD
  (
  SSD_CF
 ,ESB_CF
 ,DIR_CF
 ,DMN_CF
 ,BLCSHTYEA_NF
 ,BLCSHTMTH_NF
 ,SPCSTR_D
 ,END_D
 ,SPCEND_D
 ,VLDUSR1_CF
 ,VLD1_D
 ,VLDUSR2_CF
 ,VLD2_D
 ,STRDAY_NF
 ,ENDDAY_NF
  )
 select distinct SSD_CF,ESB_CF,DIR_CF,DMN_CF,b.BLCSHTYEA_NF,b.BLCSHTMTH_NF
  ,SPCSTR_D='19000101 23:59:59'
  ,END_D=convert(char(8),case when DMN_CF=3 then b.SACCOUNT_D else b.END_D end,112)+' 23:59:59' -- modif 1
  ,SPCEND_D=convert(char(8),b.SPECEND_D,112)+' 23:59:59'
  ,'dbo'
  ,dateadd(ms,1,@maj)
  ,''
  ,null
  ,1
  ,day(dateadd(day,-1,dateadd(month,1,convert(char(8),b.BLCSHTYEA_NF*10000+b.BLCSHTMTH_NF*100+1)))) -- modif 1 : par rapport à l'année bilan
  from TBLCSHTD a, BREF..TCALEND b
   where a.DMN_CF in(1,2,3)
     and a.BLCSHTYEA_NF >= year(getdate()) -- pour avoir la liste des SSD_CF,ESB_CF,DIR_CF courant à insérer
     and ((@p_blcshtyea_nf=null and b.BLCSHTYEA_NF*100+b.BLCSHTMTH_NF >= @annee_mois)
            or (b.BLCSHTYEA_NF=@p_blcshtyea_nf and b.BLCSHTMTH_NF=@p_blcshtmth_nf)) --modif 1
     and not exists(select 1 from TBLCSHTD s
         where s.BLCSHTMTH_NF = b.BLCSHTMTH_NF
           and s.BLCSHTYEA_NF = b.BLCSHTYEA_NF
           and s.DIR_CF = a.DIR_CF
           and s.DMN_CF = a.DMN_CF
           and s.ESB_CF = a.ESB_CF
           and s.SSD_CF = a.SSD_CF)
 group by SSD_CF,ESB_CF,DIR_CF,DMN_CF,b.BLCSHTYEA_NF,b.BLCSHTMTH_NF
 order by SSD_CF,ESB_CF,DIR_CF,DMN_CF,b.BLCSHTYEA_NF,b.BLCSHTMTH_NF
select @erreur=@@error
if @@transtate=2
begin
  select @p_erreur="ERREUR trigger TBLCSHTD"
  goto fin
end
if @erreur!=0
begin
  if @erreur=2601
    select @p_erreur="20002 APPLICATIF;TBLCSHTD_2601;"
  else
    select @p_erreur="20001 APPLICATIF;TBLCSHTD_" + convert(varchar(10),@erreur) + ";"
  goto fin
end

-- maj année/mois + 1 pour la date de début normale
update TBLCSHTD
 set STR_D=(select convert(char(8),dateadd(dd,1,END_D),112) from TBLCSHTD m
            where m.BLCSHTMTH_NF=case when a.BLCSHTMTH_NF=1 then 12 else a.BLCSHTMTH_NF - 1 end
              and m.BLCSHTYEA_NF=a.BLCSHTYEA_NF - case when a.BLCSHTMTH_NF=1 then 1 else 0 end
              and a.DIR_CF=m.DIR_CF
              and a.DMN_CF=m.DMN_CF
              and a.ESB_CF=m.ESB_CF
              and a.SSD_CF=m.SSD_CF)
    ,VLDUSR1_CF='dbo'
    ,VLD1_D=@maj
from TBLCSHTD a
 where a.DMN_CF in(1,2,3)
   and ((@p_blcshtyea_nf=null and a.BLCSHTYEA_NF*100+a.BLCSHTMTH_NF > @annee_mois) -- --modif 1 strictement après le mois de la date système
           or (a.BLCSHTYEA_NF=@p_blcshtyea_nf + case when @p_blcshtmth_nf=12 then 1 else 0 end
               and a.BLCSHTMTH_NF=case when @p_blcshtmth_nf=12 then 1 else @p_blcshtmth_nf + 1 end))
   and isnull(STR_D,'19000101')!=(select convert(char(8),dateadd(dd,1,END_D),112) from TBLCSHTD m
            where m.BLCSHTMTH_NF=case when a.BLCSHTMTH_NF=1 then 12 else a.BLCSHTMTH_NF - 1 end
              and m.BLCSHTYEA_NF=a.BLCSHTYEA_NF - case when a.BLCSHTMTH_NF=1 then 1 else 0 end
              and a.DIR_CF=m.DIR_CF
              and a.DMN_CF=m.DMN_CF
              and a.ESB_CF=m.ESB_CF
              and a.SSD_CF=m.SSD_CF)
select @erreur = @@error
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;TBLCSHTD_" + convert(varchar(10), @erreur) + ";"
  goto fin
end

-- maj de la date suite à l'insertion car on se repose sur les lignes précédentes
update TBLCSHTD
 set STR_D=(select convert(char(8),dateadd(dd,1,END_D),112) from TBLCSHTD m
            where m.BLCSHTMTH_NF= case when a.BLCSHTMTH_NF=1 then 12 else a.BLCSHTMTH_NF - 1 end
              and m.BLCSHTYEA_NF= a.BLCSHTYEA_NF - case when a.BLCSHTMTH_NF=1 then 1 else 0 end
              and a.DIR_CF=m.DIR_CF
              and a.DMN_CF=m.DMN_CF
              and a.ESB_CF=m.ESB_CF
              and a.SSD_CF=m.SSD_CF)
from TBLCSHTD a, BREF..TCALEND b
 where a.DMN_CF in(1,2,3)
   and ((@p_blcshtyea_nf=null and b.BLCSHTYEA_NF*100+b.BLCSHTMTH_NF >= @annee_mois)
          or (b.BLCSHTYEA_NF=@p_blcshtyea_nf and b.BLCSHTMTH_NF=@p_blcshtmth_nf)) --modif 1
   and a.BLCSHTMTH_NF = b.BLCSHTMTH_NF
   and a.BLCSHTYEA_NF = b.BLCSHTYEA_NF
   and VLDUSR1_CF='dbo'
   and VLD1_D=dateadd(ms,1,@maj) -- uniquement les lignes qu'on a insérées
select @erreur = @@error
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;TBLCSHTD_" + convert(varchar(10), @erreur) + ";"
  goto fin
end

-- modif 1 gestion demande V Comptabilisation des règlements
--  et demande M Maj Ultimes sur cours de change
-- [004] Traite les codes V,puis M,puis R.
-- 009
-- select @REQCOD_CT2='CVMRX' -- last value X to quit loop
select @REQCOD_CT2='VMRX' -- last value X to quit loop
select @inc=1
select @REQCOD_CT=substring(@REQCOD_CT2,@inc,1)
while @REQCOD_CT!='X'
begin
-- [009]  insert BEST..TREQJOBPLAN
  insert BEST..TI17REQJOBPLAN
  (SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,CLOPER_LS,UPDUSR_CF,SITE_CF,START_D,END_D)  --[004]
  select distinct
    SSD_CF=99
   ,BALSHEYEA_NF=a.BLCSHTYEA_NF
   ,BALSHTMTH_NF=a.BLCSHTMTH_NF
   ,CLODAT_D=dateadd(day,-1,dateadd(month,1,convert(char(8),BLCSHTYEA_NF*10000+BLCSHTMTH_NF*100+1))) -- dernier jour par rapport à l'année/mois bilan
   ,REQCOD_CT=@REQCOD_CT
   ,CRE_D=@maj
   ,DBCLO_D=case when @REQCOD_CT='C' then ACCOUNT_D        --[004]
                 when @REQCOD_CT='R' then ACCRETSTART_D    --[004]
                 when @REQCOD_CT='V' then SACCOUNT_D 
                 else FXRATES_D end
   ,CLOPER_LS=case when @REQCOD_CT='C' then 'Technical BOOKING'          --[004]
                   when @REQCOD_CT='V' then 'Settlement Accounting' 
                   when @REQCOD_CT='R' then 'Retro Accounting Locked'    --[004]
                   else 'Exchange rates '+convert(char(4),a.BLCSHTYEA_NF)+'/'+convert(varchar(2),BLCSHTMTH_NF) end
   ,UPDUSR_CF=suser_name()
   ,SITE_CF=case when @REQCOD_CT in ('C','R','V') then x.PRDSIT_CF else 'ALL' end   --[004]
   ,START_D=case when @REQCOD_CT='R' then a.ACCRETSTART_D else null end  --[004]
   ,END_D=case when @REQCOD_CT='R' then a.ACCRETEND_D else null end      --[004]
   from BREF..TCALEND a, BREF..TBATCHNIGHT x
    where ((@p_blcshtyea_nf=null and BLCSHTYEA_NF*100+BLCSHTMTH_NF >= @annee_mois)
            or (BLCSHTYEA_NF=@p_blcshtyea_nf and BLCSHTMTH_NF=@p_blcshtmth_nf))
--[009]      and not exists(select 1 from BEST..TREQJOBPLAN b where b.BALSHEYEA_NF=a.BLCSHTYEA_NF and b.BALSHTMTH_NF=a.BLCSHTMTH_NF and 
      and not exists(select 1 from BEST..TI17REQJOBPLAN b where b.BALSHEYEA_NF=a.BLCSHTYEA_NF and b.BALSHTMTH_NF=a.BLCSHTMTH_NF and 
                      b.REQCOD_CT=@REQCOD_CT and b.SITE_CF=case when @REQCOD_CT in ('C','R','V') then x.PRDSIT_CF else 'ALL' end)  --[004]
  select @erreur = @@error
  if @@transtate=2
  begin
    select @p_erreur="ERREUR trigger BEST..TI17REQJOBPLAN"
    goto fin
  end
  if @erreur!=0
  begin
    if @erreur=2601
      select @p_erreur="20002 APPLICATIF;BEST..TI17REQJOBPLAN_2601;"
    else
      select @p_erreur="20001 APPLICATIF;BEST..TI17REQJOBPLAN_" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
/*Modif [007] Start*/
-- 009
-- if @REQCOD_CT in ('C','M','V')
if @REQCOD_CT in ('M','V')
begin
 
  select @p_blcshtmth_tmp = case when @p_blcshtmth_nf in (1 ,2,3) then 3 
                                               when @p_blcshtmth_nf in (4 ,5,6) then 6 
                                               when @p_blcshtmth_nf in (7 ,8,9) then 9 
                                               else 12
                                               end
--  [009]  update BEST..TREQJOBPLAN
--  [010] cre_d added
    update BEST..TI17REQJOBPLAN
    set CLODAT_D=dateadd(day,-1,dateadd(month,1,convert(char(8),BALSHEYEA_NF*10000+@p_blcshtmth_tmp*100+1))) ,CRE_D=dateadd(minute,-1,CRE_D)
    from BEST..TI17REQJOBPLAN 
    where BALSHEYEA_NF=@p_blcshtyea_nf and BALSHTMTH_NF=@p_blcshtmth_nf
       
 
  
  select @erreur = @@error
  if @erreur != 0
  begin
    select @p_erreur="20001 APPLICATIF;BEST..TI17REQJOBPLAN_" + convert(varchar(10), @erreur) + ";"
    goto fin
  end
end
/*Modif [007] END*/


-- [009]  update BEST..TREQJOBPLAN
-- [010] cre_d added
  update BEST..TI17REQJOBPLAN
   set DBCLO_D=case when @REQCOD_CT='C' then ACCOUNT_D        --[004]
                    when @REQCOD_CT='R' then ACCRETSTART_D    --[004]
                    when @REQCOD_CT='V' then SACCOUNT_D
                    else FXRATES_D end
   	,START_D=case when @REQCOD_CT='R' then b.ACCRETSTART_D end    --[004]
   	,END_D=case when @REQCOD_CT='R' then b.ACCRETEND_D end        --[004]
      ,UPDUSR_CF=suser_name(), CRE_D=dateadd(minute,-1,CRE_D)
-- [009]    from BEST..TREQJOBPLAN a, BREF..TCALEND b
    from BEST..TI17REQJOBPLAN a, BREF..TCALEND b
    where ((@p_blcshtyea_nf=null and b.BLCSHTYEA_NF*100+b.BLCSHTMTH_NF >= @annee_mois)
            or (b.BLCSHTYEA_NF=@p_blcshtyea_nf and b.BLCSHTMTH_NF=@p_blcshtmth_nf))
       and a.BALSHEYEA_NF=b.BLCSHTYEA_NF
       and a.BALSHTMTH_NF=b.BLCSHTMTH_NF
       and a.REQCOD_CT=@REQCOD_CT
       and a.LAUNCH_D=null
       and (a.DBCLO_D!=case when @REQCOD_CT='C' then ACCOUNT_D        --[004]
                           when @REQCOD_CT='R' then ACCRETSTART_D    --[004]
                           when @REQCOD_CT='V' then SACCOUNT_D 
                           else FXRATES_D end
   	      or a.START_D!=case when @REQCOD_CT='R' then b.ACCRETSTART_D end   --[004]
   	      or a.END_D!=case when @REQCOD_CT='R' then b.ACCRETEND_D end)       --[004]
  select @erreur = @@error
  if @erreur != 0
  begin
    select @p_erreur="20004 APPLICATIF;TBLCSHTD_" + convert(varchar(10), @erreur) + ";"
    goto fin
  end

 -- la première fois c'est V, la deuxième M, la troisieme R et ensuite vide
--  select @REQCOD_CT=case when @REQCOD_CT='V' then 'M' else '' end [004]
  select @inc=@inc+1
  select @REQCOD_CT=substring(@REQCOD_CT2,@inc,1)
end

if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PtBLCSHTD_calend', 'unchained'
go
IF OBJECT_ID('dbo.PtBLCSHTD_calend') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtBLCSHTD_calend >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtBLCSHTD_calend >>>'
go
GRANT EXECUTE ON dbo.PtBLCSHTD_calend TO GOMEGA
go
GRANT EXECUTE ON dbo.PtBLCSHTD_calend TO GDBBATCH
go
