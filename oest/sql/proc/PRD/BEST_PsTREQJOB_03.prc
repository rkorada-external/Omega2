/*
 * DROP PROC dbo.PsTREQJOB_03
 */
 
use BEST

IF OBJECT_ID('dbo.PsTREQJOB_03') IS NOT NULL
BEGIN
    DROP PROC dbo.PsTREQJOB_03
    PRINT '<<< DROPPED PROC dbo.PsTREQJOB_03 >>>'
END
go
 



create procedure PsTREQJOB_03
(
    @date_t UUPD_D
)
as
declare @n_CdRet int, 
	 @specend datetime, 
	 @blcshtmth_dyn tinyint,  	
	 @blcshtyea_dyn smallint,
	 @mth_cf char(2),
	 @yea_cf char(4),
	 @cmgts char(1)

select @n_Cdret = 0



/***************************************************

Programme: PsTREQJOB_03

Fichier script associé : BEST_PsTREQJOB_03.PRC
Domaine : (RT) Rétro
Baseprincipale : BEST
Version: 1
Auteur: S.LLORENTE ( NON AUTO)
Date de creation: 10/2000 
Description du programme: 
    Determiner le Lancement de ESIJ0010

Parametres: 4
Conditions d'execution: 
Commentaires: Sortie dans un fichier FRES des valeurs de  @yea_cf et @mth_cf sépares par ~
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/
declare @erreur         int,
        @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output


/* Recherche dynamique des paramètres de la période écoulée */
select A.*, B.SPECEND_D, A.CLODAT_D as MAX_D into #TREQJOB
from BEST..TREQJOB A, BREF..TCALEND B
where A.BALSHEYEA_NF = B.BLCSHTYEA_NF
  and A.BALSHTMTH_NF = B.BLCSHTMTH_NF
  and A.REQCOD_CT    = 'V'
  and A.LAUNCH_D     = NULL
  and A.SITE_CF      = @site_cf
  

update #TREQJOB
set MAX_D = B.SPECEND_D
from #TREQJOB A, BREF..TCALEND B
where A.BALSHEYEA_NF = B.BLCSHTYEA_NF
  and A.BALSHTMTH_NF = B.BLCSHTMTH_NF
  and A.MAX_D < B.SPECEND_D

select @specend = SPECEND_D,
       @blcshtyea_dyn = BALSHEYEA_NF,
       @blcshtmth_dyn = BALSHTMTH_NF
from #TREQJOB
where MAX_D <= @date_t


select @n_CdRet = @@error
if @n_CdRet != 0 
   begin
     raiserror 20001 "Error in select/PsTREQJOB_03"
     return 1
   end



fin:
select @yea_cf = convert (char(4),@blcshtyea_dyn)
select @mth_cf = substring (convert (char(3),100 + @blcshtmth_dyn), 2,2)


if exists ( select CLODAT_D from BEST..TREQJOB
                         where REQCOD_CT    = 'V'
                           and LAUNCH_D     = NULL
                    	     and CLODAT_D    <= @date_t
                           and @specend    <= @date_t
                           and BALSHEYEA_NF = @blcshtyea_dyn
                           and BALSHTMTH_NF = @blcshtmth_dyn
                           and SITE_CF      = @site_cf )
                        
  begin
    select @cmgts = '1'      
  end

select @n_CdRet = @@error
if @n_CdRet != 0 
  begin
    raiserror 20003 "Error in select/PsTREQJOB_03"
    return 1
  end             



if ( @blcshtmth_dyn = null) 
 begin
     select @cmgts = '2'
     select @mth_cf = '0'
   end

   
if ( @blcshtyea_dyn = null) 
 begin
     select @cmgts = '2'
     select @yea_cf = '0'
   end


select @yea_cf+"~"+@mth_cf+"~"+@cmgts"~"

return

go

IF OBJECT_ID('dbo.PsTREQJOB_03') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsTREQJOB_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsTREQJOB_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsTREQJOB_03
 */
GRANT EXECUTE ON dbo.PsTREQJOB_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTREQJOB_03 TO GDBBATCH
go
