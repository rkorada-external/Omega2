USE BEST
GO

IF OBJECT_ID('dbo.PsTREQJOB_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsTREQJOB_01
    PRINT '<<< DROPPED PROC dbo.PsTREQJOB_01 >>>'
END
go

CREATE OR REPLACE PROCEDURE dbo.PsTREQJOB_01 (
    @date_t     UUPD_D
)

as
/***************************************************
Programme:                  PsTREQJOB_01
Fichier script associé :    ESSRJB01.PRC
Domaine :                   (RT) Rétro
Baseprincipale :            BEST
Version:                    1
Auteur:                     S.LLORENTE ( NON AUTO)
Date de creation:           10/2000 
Description du programme:   Determiner le Lancement de ESIJ0010
Conditions d'execution: 
Commentaires:               Sortie dans un fichier FRES des valeurs de launch_b, @yea_cf et @mth_cf sépares par ~
_________________
MODIFICATION    [001]
Auteur         : D.GATIBELZA
Date           : 05/10/2010
Version        : 10.1
Description    : ESTDOM19070 V10 scheduler pour le lancement des inventaires
[002] 20/09/2011 Roger Cassis :spot:22636 - Modification conditions pour comptabilisation
[003] 02/12/2011 Roger Cassis :spot:22859 - Extrait colonne clodat_d en plus
[100] 30/09/2013 P. Pezout    :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 31/05/2016 Roger Cassis :spot:30673  - refonte et simplification de la procedure
[102] 12/02/2018 R. cassis    :Spira:67171 Le mois comptable Reglement peut etre different du mois bilan IFRS, donc on extrait le mois bilan planifié dans la treqjobplan
[103] HR 95833 TI17REQJOBPLAN
*****************************************************/
declare @n_CdRet        int,
        @launch_b       char(1),
        @blcshtmth_dyn  tinyint,  	
        @blcshtyea_dyn  smallint,
        @mth_cf         char(2),
        @yea_cf         char(4),
        @clodat2_d      char(8),
        @clodat3_d      datetime  --[102]

declare @erreur         int,
        @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
	begin
      raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end

select @n_CdRet = 0

/* Selection du mois/an a traiter */
select  @blcshtyea_dyn = b.BALSHEYEA_NF
       ,@blcshtmth_dyn = b.BALSHTMTH_NF
-- [102]      ,@clodat2_d = convert(char(8),b.CLODAT_D,112)
-- [103] from BREF..TCALEND a, BEST..TREQJOBPLAN b       
from BREF..TCALEND a, BEST..TI17REQJOBPLAN b       
where b.REQCOD_CT = 'V'
  and b.LAUNCH_D = NULL
  and b.SITE_CF = @site_cf
-- [102] and a.BLCSHTYEA_NF = b.BALSHEYEA_NF
-- [102] and a.BLCSHTMTH_NF = b.BALSHTMTH_NF
-- [102] and a.SACCOUNT_D = b.DBCLO_D
  and a.SACCOUNT_D <= b.DBCLO_D
-- [103] and b.DBCLO_D = (select min(DBCLO_D) from BEST..TREQJOBPLAN c  
  and b.DBCLO_D = (select min(DBCLO_D) from BEST..TI17REQJOBPLAN c
                   Where c.REQCOD_CT = 'V'
                     and c.LAUNCH_D = NULL
                     and c.DBCLO_D >= @date_t
                     and c.SITE_CF = @site_cf)

select @n_CdRet = @@error
if @n_CdRet != 0 
begin
    raiserror 20002 "Error in select/PsTREQJOB_01"
    return 1
end

/* Gestion du bit de lancement pour savoir si on est mode Simu ou compta mensuelle */
select @launch_b = '0'
-- [103] if exists ( select CLODAT_D from BEST..TREQJOBPLAN
if exists ( select CLODAT_D from BEST..TI17REQJOBPLAN
            where REQCOD_CT    = 'V'
              and LAUNCH_D     = NULL
              and DBCLO_D      = @date_t   --  [002]
--            and CLODAT_D <= @date_t     [002]
--            and @specend <= @date_t     [002]
              and BALSHEYEA_NF = @blcshtyea_dyn
              and BALSHTMTH_NF = @blcshtmth_dyn 
              and SITE_CF      = @site_cf
          )
begin
    select @launch_b = '1'      
end

select @n_CdRet = @@error
if @n_CdRet != 0 
begin
    raiserror 20003 "Error in select/PsTREQJOB_01"
    return 1
end

--[102]
if @blcshtyea_dyn < 1 or @blcshtyea_dyn is null
begin
    raiserror 20003 "Error in select/PsTREQJOB_01 due to bad planification between best..treqjobplan and bref..tcalend"
    return 1
end


fin:
select @yea_cf = convert (char(4),@blcshtyea_dyn)
select @mth_cf = substring (convert (char(3),100 + @blcshtmth_dyn), 2,2)

--[102]
if @mth_cf = '12'
	select @clodat3_d = convert (char(4),@blcshtyea_dyn) +'1231'
else	
	select @clodat3_d = dateadd(dd, -1, (convert (char(4),@blcshtyea_dyn)) + substring (convert (char(3),100 + @blcshtmth_dyn+1), 2,2) + '01')
select @clodat2_d = convert(char(8),@clodat3_d,112)

-- Select final
select @launch_b+"~"+@yea_cf+"~"+@mth_cf+"~"+@clodat2_d+"~"                -- [003]

return
go
EXEC sp_procxmode 'dbo.PsTREQJOB_01', 'unchained'
go
IF OBJECT_ID('dbo.PsTREQJOB_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTREQJOB_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTREQJOB_01 >>>'
go
GRANT EXECUTE ON dbo.PsTREQJOB_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTREQJOB_01 TO GDBBATCH
go
