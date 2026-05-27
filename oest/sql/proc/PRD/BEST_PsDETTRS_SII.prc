use BEST
go
if object_id('dbo.PsDETTRS_SII') IS NOT null
begin
  drop PROC dbo.PsDETTRS_SII
  print '<<< DROPPED PROC dbo.PsDETTRS_SII >>>'
end
go
create procedure PsDETTRS_SII
  (
  @p_NAT_TS       char(2) -- nature transation service : CR couverture rétro ou ES écriture service ou SI Service IBNR tool
 ,@p_SSD_CF       USSD_CF
 ,@p_accept       char(1)
 ,@p_CTR_NF       UCTR_NF
 ,@p_END_NT       UEND_NT
 ,@p_UW_NT        UUW_NT
 ,@p_UWY_NF       UUWY_NF
 ,@p_SEC_NF       USEC_NF -- 0 si fenêtre w_recherche_es0001
 ,@p_SPEENTNAT_CT tinyint -- le type d'écriture service, 0 si fenêtre w_recherche_es0001
 ,@p_TRNCOD_CF    UDETTRS_CF=null
  )
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 21/05/2012
Description du programme : :spot:23390 SOLVENCY II
Conditions d'execution : pour le tag des postes comptable d_ff_sp_es2600 et d_ff_ex_es0001
_________________
MODIFICATIONS
  Auteur   Date       Description
2 28/04/2015 Florent :spot:26391 pour prendre les comptes de dépôts
*****************************************************/
declare
 @LOB_CF ULOB_CF
,@erreur int
,@s_SQL  varchar(600)
,@s_LIKE varchar(100)
,@s_filiale char(2)

-- ajouter la filiale au contrat
select @s_filiale=right(convert(char(3),@p_SSD_CF+100),2)

if @p_NAT_TS='ES'
begin
  if @p_SEC_NF = 0 -- si fenêtre w_recherche_es0001
    select @s_LIKE = "[1234][4679CEGHJLNORSUVWXYZ]%'"
  else
  begin
    if @p_accept='A'
    begin
      select @LOB_CF=LOB_CF from BTRT..TSECTION where CTR_NF=@s_filiale+@p_CTR_NF and SEC_NF=@p_SEC_NF and UWY_NF=@p_UWY_NF and END_NT=@p_END_NT and UW_NT=@p_UW_NT
      if @@error!=0 return 999
      if @LOB_CF='30' select @s_LIKE='3' else select @s_LIKE='1'
    end
    else -- retro
    begin
      select @LOB_CF=LOB_CF from BRET..TRETSEC where RETCTR_NF=@s_filiale+@p_CTR_NF and RETSEC_NF=@p_SEC_NF and RTY_NF=@p_UWY_NF
      if @@error!=0 return 999
      if @LOB_CF='30' select @s_LIKE='4' else select @s_LIKE='2'
    end
    if @p_SPEENTNAT_CT in(4,5,6) -- type EBS
      -- pas de poste comptable pour les LOB vie pour le moment
      select @s_LIKE = case when @LOB_CF in('30','31') then @s_LIKE+"9Z9Z9Z9Z%'" else @s_LIKE+"[EGHJL]%'" end
    else
      select @s_LIKE = @s_LIKE + "[4679CNORSUVWXY]%'"
  end
end
else
begin
    select @s_LIKE = case when @p_NAT_TS='CR' then "2[123]%2'"
                          when @p_NAT_TS='SI' then "[12]%2'"
                     end
end

select @s_SQL="
select "+case when @p_TRNCOD_CF=null then "d.DETTRS_CF,s.SUBTRS_HL," else "" end+"s.SUBTRS_HS
 from BREF..TDETTRS d, BREF..TSUBTRSH s
  where d.pcptrs_cf=s.pcptrs_cf
    and d.trs_cf=s.trs_cf
    and d.subtrs_cf=s.subtrs_cf
    and d.opn_b=1
    and s.ssd_cf="+@s_filiale+"
    and d.dettrs_cf!=d.ctrscod_cf"+case when @p_TRNCOD_CF!=null then "
    and d.dettrs_cf='"+@p_TRNCOD_CF+"'" else "" end+"
    and d.dettrs_cf like '"+@s_LIKE+"
"
exec (@s_SQL)
if @@error!=0 return 999
go
if object_id('dbo.PsDETTRS_SII') is not null
  print '<<< CREATED PROC dbo.PsDETTRS_SII >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsDETTRS_SII >>>'
go
grant execute on dbo.PsDETTRS_SII TO GOMEGA
go
