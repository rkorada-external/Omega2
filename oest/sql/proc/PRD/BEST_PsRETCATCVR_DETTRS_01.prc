USE BEST
go
IF OBJECT_ID('dbo.PsRETCATCVR_DETTRS_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsRETCATCVR_DETTRS_01
  IF OBJECT_ID('dbo.PsRETCATCVR_DETTRS_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsRETCATCVR_DETTRS_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsRETCATCVR_DETTRS_01 >>>'
END
go
create table #CATCVRDETTRS
(
 ACMTRS_NT  smallint   NOT NULL
,DETTRS_CF  UDETTRS_CF NOT NULL
,CTRSCOD_CF UDETTRS_CF DEFAULT '' NOT NULL
)
go
create procedure dbo.PsRETCATCVR_DETTRS_01
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 09/02/2015
Description du programme: :spot:28139 sélection des comptes des cat cover pour les ES de TACCSUP
Conditions d'execution: par BEST..PsRETCATCVR_ACCSUP_01/ESIJ2001.cmd
Commentaires: c'est dans le regroupement PRS_CF 715
_________________
MODIFICATIONS
*****************************************************/
print 'Création des la tables des comptes pour les CAT COVER'

create unique index CATCVRDETTRS_01 on #CATCVRDETTRS(ACMTRS_NT)

insert #CATCVRDETTRS values(110,'24200000','')
insert #CATCVRDETTRS values(111,'24420000','')
insert #CATCVRDETTRS values(112,'24101200','')
insert #CATCVRDETTRS values(113,'24102000','')

update #CATCVRDETTRS
 set CTRSCOD_CF=b.CTRSCOD_CF
  from #CATCVRDETTRS a, BREF..TDETTRS b
   where a.DETTRS_CF=b.DETTRS_CF
go
IF OBJECT_ID('dbo.PsRETCATCVR_DETTRS_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PsRETCATCVR_DETTRS_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PsRETCATCVR_DETTRS_01 >>>'
go
GRANT EXECUTE ON dbo.PsRETCATCVR_DETTRS_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRETCATCVR_DETTRS_01 TO GDBBATCH
go
