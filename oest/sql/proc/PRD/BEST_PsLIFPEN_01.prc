use BEST
go

if object_id('dbo.PsLIFPEN_01') IS NOT null
begin
  drop procedure dbo.PsLIFPEN_01
  if object_id('dbo.PsLIFPEN_01') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PsLIFPEN_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFPEN_01 >>>'
end
go

create procedure PsLIFPEN_01  (
      @p_USR_CF   UUSR_CF,
      @p_ssd_cf   char(2)
                              )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 06/07/2004
Description du programme: estimation Vie, suivi dépassement du seuil
Conditions d'execution: par la dw d_seuil_action
Commentaires:
_________________
MODIFICATIONS
M  Auteur         Date        Description
1  Florent        15/11/2004  On prend le ssd_cf de tlifmod pour recherche libellé de UWGRP_CF et plus celui de @p_USR_CF dans BREF..TUSR

_________________
MODIFICATIONS 1
M  Auteur         Date        Description
1  Tony           20/10/2010  Ajout la filiale dans la recherche + ctitere cre_d en dd/mm/yyyy hh:mm:ss (116)

*****************************************************/
declare
  @SSD_CF char(3)
 ,@LAG_CF char(1)

select @LAG_CF=isnull(LAG_CF,'E') from BREF..TUSR where USR_CF=@p_USR_CF
if @LAG_CF=null select @LAG_CF='E'

select @ssd_cf = @p_ssd_cf + '%'
select   a.USR_CF
         ,a.CTR_NF
         ,a.SEC_NF
         ,a.CRE_D
         ,a.BALSHEY_NF
         ,a.BALSHTMTH_NF
         ,a.PENSTS_CT
         ,PENSTS_LM  =  (  select   COLVAL_LM
                             from   BREF..TBANTECL
                            where   LAG_CF      =  @LAG_CF
                              and   COL_LS      =  'PENSTS_CT'
                              and   COLVAL_CT   =  convert(char(3),a.PENSTS_CT)
                              and   CODVALSSD_CF=  null)
         ,a.UWGRP_CF
         ,UWGRP_LS   =  (  select   GRP_LS
                             from   BREF..TGRP
                            where   GRP_CF   =  a.UWGRP_CF
                              and   SSD_CF=b.SSD_CF)
         ,b.TYPMOD1_CT
         ,TYPMOD1_LM =  (  select   COLVAL_LM
                             from   BREF..TBANTECL
                            where   LAG_CF      =  @LAG_CF
                              and   COL_LS      =  'TYPMOD1_CT'
                              and   COLVAL_CT   =  convert(char(3),b.TYPMOD1_CT)
                              and   CODVALSSD_CF=null)
 from    TLIFPEN a, TLIFMOD b
  where
         a.CTR_NF       =  b.CTR_NF
    and  a.SEC_NF       =  b.SEC_NF
    and  a.BALSHEY_NF   =  b.BALSHEY_NF
    and  a.BALSHTMTH_NF =  b.BALSHTMTH_NF
    and  convert(varchar,a.CRE_D,116)  =  convert(varchar,b.CRE_D,116)
    and  a.CTR_NF       like @ssd_cf
order by a.CRE_D DESC
go
if object_id('dbo.PsLIFPEN_01') IS NOT null
  print '<<< CREATED procedure dbo.PsLIFPEN_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFPEN_01 >>>'
go
grant execute on dbo.PsLIFPEN_01 TO GOMEGA
go
