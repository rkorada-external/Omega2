use BEST
go
if object_id('dbo.PuPATTERNSII_async') is not null
begin
  drop procedure dbo.PuPATTERNSII_async
  if object_id('dbo.PuPATTERNSII_async') is not null
    print '<<< FAILED DROPPING procedure dbo.PuPATTERNSII_async >>>'
  else
    print '<<< DROPPED procedure dbo.PuPATTERNSII_async >>>'
end
go
create procedure PuPATTERNSII_async
  (
  @p_CRE_D     UUPD_D
 ,@p_CREUSR_CF UUPDUSR_CF
 ,@p_table     varchar(30) -- TLOBSII ou TRATINSII
 ,@p_erreur    varchar(64)=null output
  )
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 05/06/2012
Description du programme : :spot:23390 SOLVENCY II
Conditions d'execution :
Commentaires : cette proc est exécutée par le TP pour exec asynchrone de maj de TPATTERNSII avec le ESID0831.cmd
_________________
MODIFICATIONS
1 Florent 12/10/2012 :spot:24041 ajout de la gestion de per_cf et clodat_d pour les traces TPATSEGSII
2 Florent 22/04/2014 :spot:25427 - Suppression de quotes (') qui entourent la chaine de caractères @s_CRE_D. Le Daemon met les chaines entre "" depuis la 1B. 
*****************************************************/
declare
  @erreur       int
 ,@type_fichier char(3) -- DSC Illiquidity/Discount ou CUM cumulative
 ,@s_CRE_D      varchar(30)
 ,@clodat_d     datetime
 ,@per_cf       char(3)
 ,@s_clodat_d   char(8)

-- 1 pour exec par le batch
exec @erreur=BREF..PsCALEND_EBS @p_CRE_D,1,@clodat_d output, @per_cf output
if @erreur!=0 or @@error!=0 return 999

-- on lance l'asynchrone, on vient du TP, pour faire le fichier pour la chaîne des courbes de taux
select
 @s_CRE_D=convert(char(8),getdate(),112)+' '+ convert(char(12),getdate(),20) -- format SSAAMMJJ HH:MM:SS:mmm
,@s_clodat_d=convert(char(8),@clodat_d,112)
,@type_fichier=case when @p_table='TLOBSII' then 'DSI'
                    when @p_table='TRATINGSII' then 'BDT'
               end

exec @erreur=BTEC..PiJOBQUEUE_01 'best12a',@p_CREUSR_CF,null
-- paramètres du job
 ,@s_CRE_D,@type_fichier,@per_cf,@s_clodat_d,'','','','','','','','','','','','','','',@p_erreur output
return @erreur
go
if object_id('dbo.PuPATTERNSII_async') is not null
  print '<<< CREATED procedure dbo.PuPATTERNSII_async >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuPATTERNSII_async >>>'
go
grant execute on dbo.PuPATTERNSII_async TO GOMEGA
go
