use best
go

IF OBJECT_ID('PuLIFPEN_02') IS NOT NULL
BEGIN
    DROP PROCEDURE PuLIFPEN_02
    IF OBJECT_ID('PuLIFPEN_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PuLIFPEN_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PuLIFPEN_02 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PuLIFPEN_02
with execute as caller as

/***************************************************

Programme: PuLIFPEN_02

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: J. Ribot

Date de creation: 01/09/2004

Description du programme:

      Mise a jour UWGRP_CF, USR_CF dans table TLIFPEN

Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: J Ribot

Date: 14/09/2005

Version:

Description: ajout recuperation USR_CF a partir de ADMUSR_CF de TCONTR
                                    et a partir de LSTUPDUSR_CF de TLIFEST si <> dbo et sur max CRE_D

MODIFICATION "Removed dbo and added 'with execute as caller as'"									
_________________
MODIFICATION  3
Auteur: P. COPPIN
Date: 16/10/2013
Description: :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
[004] 27/05/2015 R. cassis :spot:28817 - Optimisation du traitement
*****************************************************/

declare @erreur int

CREATE TABLE #USR (
    CTR_NF          UCTR_NF         NOT NULL,
    LSTUPDUSR_CF    UUPDUSR_CF          NULL)

update btrav..EST_ESID8030_PEN_1
set UWGRP_CF = contr.UWGRP_CF,
    USR_CF   = contr.ADMUSR_CF
from btrav..EST_ESID8030_PEN_1 pen, BTRT..TCONTR contr
       where pen.CTR_NF = contr.CTR_NF
             and CTRSTS_CT in (14,16,19)

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;EST_ESID8030_PEN_1" /* erreur de modification UWGRP */
      return @erreur
   end



insert #USR ( CTR_NF)
select distinct CTR_NF from btrav..EST_ESID8030_PEN_1
--select distinct a.CTR_NF from best..tlifest a,  BREF..TBATCHSSD T WHERE a.SSD_CF = T.SSD_CF  and   T.BATCHUSER_CF = suser_name()  -- [004]


update #USR
set LSTUPDUSR_CF = a.LSTUPDUSR_CF
          from #USR d, best..tlifest a
           where  d.ctr_nf = a.ctr_nf
             and a.LSTUPDUSR_CF <> 'dbo'
              and a.CRE_D = (SELECT MAX( b.CRE_D )
                from best..tlifest b
          where  a.ctr_nf = b.ctr_nf
              and b.LSTUPDUSR_CF <> 'dbo')

update btrav..EST_ESID8030_PEN_1
set USR_CF = usr.LSTUPDUSR_CF
from btrav..EST_ESID8030_PEN_1 pen, #USR usr
       where pen.CTR_NF = usr.CTR_NF
          and usr.LSTUPDUSR_CF <> NULL

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;EST_ESID8030_PEN_1" /* erreur de modification USR  a partir TLIFEST*/
      return @erreur
   end

update btrav..EST_ESID8030_PEN_1
set USR_CF = placc.LSTUPDUSR_CF
from btrav..EST_ESID8030_PEN_1 pen, BCTA..TCPLACC placc
       where pen.CTR_NF = placc.CTR_NF
         and placc.LSTUPD_D <  pen.CRE_D
         and placc.SCOENDMTH_NF = 12
         and placc.LSTUPDUSR_CF <> 'dbo'
         and placc.ACY_NF = (SELECT MAX( b.ACY_NF )
                from BCTA..TCPLACC b
          where  placc.ctr_nf = b.ctr_nf
          and b.LSTUPD_D <  pen.CRE_D
          and b.SCOENDMTH_NF = 12)

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20007 "APPLICATIF;EST_ESID8030_PEN_1" /* erreur de modification USR a paretir TCPLACC */
      return @erreur
   end


select  USR_CF, CTR_NF, SEC_NF, convert(char(8),CRE_D, 112)+ " 23:59:59",
        BALSHEY_NF, BALSHTMTH_NF, PENSTS_CT, UWGRP_CF, CREUSR_CF,
        convert(char(8),LSTUPD_D, 112)+ " 23:59:59", LSTUPDUSR_CF, TIMESTAMP
         from btrav..EST_ESID8030_PEN_1

return 0
go
GRANT EXECUTE ON PuLIFPEN_02 TO GOMEGA
go
GRANT EXECUTE ON PuLIFPEN_02 TO GDBBATCH
go

IF OBJECT_ID('PuLIFPEN_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PuLIFPEN_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PuLIFPEN_02 >>>'
go
EXEC sp_procxmode 'PuLIFPEN_02','unchained'
go

