USE BEST
go
IF OBJECT_ID('dbo.PtREQJOBPLAN_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtREQJOBPLAN_04
    IF OBJECT_ID('dbo.PtREQJOBPLAN_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtREQJOBPLAN_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtREQJOBPLAN_04 >>>'
END
go
create procedure dbo.PtREQJOBPLAN_04
  (
    @p_dbclo_d      char(8)
   ,@p_clodat_d     char(8)
   ,@p_balshtmth_nf tinyint
  )
as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  : Roger Cassis
Date de creation        : 24/02/2016
Description du programme: :spot:30163 Génération d'un enregistrement plan pour planification d'un closing
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
*****************************************************/

declare @balshey_nf  int
       ,@erreur      int
       ,@cloper_ls   UL64
       
select @balshey_nf = convert(int,substring(@p_clodat_d,1,4))       

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output       

set rowcount 1
select @cloper_ls = CLOPER_LS from best..treqjobplan
                    Where SITE_Cf = @site_cf
                    and   REQCOD_CT = 'D'
                    and   LAUNCH_D is not null
                    and   BALSHEYEA_NF = @balshey_nf
set rowcount 0

if NOT exists (select 1 from best..treqjobplan
               where BALSHEYEA_NF = @balshey_nf
               and   BALSHTMTH_NF = @p_balshtmth_nf
               and   CLODAT_D     = @p_clodat_d
               and   REQCOD_CT    = 'D'
               and   DBCLO_D      = @p_dbclo_d
               and   LAUNCH_D     is null
               and   CLOPER_LS    = @cloper_ls
               and   SITE_CF      = @site_cf)

   insert into best..treqjobplan
   (SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOPER_LS,VRS_NF,UPDUSR_CF,SITE_CF)
   values (3,@balshey_nf,@p_balshtmth_nf,@p_clodat_d,"D",getdate(),@p_dbclo_d,null,@cloper_ls,0,"dbat",@site_cf)

return 0
go
IF OBJECT_ID('dbo.PtREQJOBPLAN_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtREQJOBPLAN_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtREQJOBPLAN_04 >>>'
go
GRANT EXECUTE ON dbo.PtREQJOBPLAN_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtREQJOBPLAN_04 TO GDBBATCH
go
