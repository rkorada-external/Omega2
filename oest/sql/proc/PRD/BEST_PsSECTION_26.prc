use BEST
go
if object_id('dbo.PsSECTION_26') is not null
begin
  drop PROC dbo.PsSECTION_26
  print '<<< DROPPED PROC dbo.PsSECTION_26 >>>'
end
go
create procedure PsSECTION_26
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Descente du périmètre rétrocession vie au niveau CASEX
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: M.NAJI
Date: 29/07/98
Version: 1
Description:
	- Déscente du perimètre vie pour toutes les filiales pour la COND3 di ESID006
_________________
MODIFICATION 2
Auteur:      Roger Cassis
Date:        07/10/2010
Version:     1.2
Description: :spot:20133 - V102 - on ne restreint plus le perimetre aux status de section rétro 3 et 19, on prend tout
_________________
MODIFICATION 3
Auteur:  D. Chetboul
Date: 16/08/2011
SPOT: 22459
Description: .
Ajout du champ filler (null) pour compléter le champ manquant lors de la fusion
[004] 11/01/2013 Roger Cassis :spot:24041 pour Livraison solvency 2
[005] 12/08/2013 Florent :spot:25427 Centralisation des bases (filiales)
[006] 17/03/2015 Sarah Askri : spot 28465. EST29a-R1 devise Retro
*****************************************************/
declare @erreur int

----------------------------------------------
-- Périmètre de souscription rétrocession vie
---------------------------------------------

-- Affichage du périmètre rétrocession vie
select RETSEC.SSD_CF,
  null,
  RETSEC.RETCTR_NF,
  0,
  RETSEC_NF,
  RETSEC.RTY_NF,
  1,
  ESB_CF,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  convert(char(1), " "),
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  RETSEC.GAR_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
  null,
  null,
  null,
  null,
  null,
  LOB_CF,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  NAT_CF,
  null,
  isnull(RETSPECUR_CF,RETPCPCUR_CF), --RETPCPCUR_CF, REcuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1 17/03/2015
  RETSEC.PCPRSKTRY_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  RETSEC.SOB_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
  null,
  null,
  RETSEC.TOP_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
  null,
  null,
  PROPER_N,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  RETACCTYP_CT,
  null,
  RETCTRSTS_CT,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  RETCTRCAT_CF,
  CLECUTPER_B,
  CLECUTPER_NB,
  ORICUR_B,
  RETACCADM_B,
  SSDRTO_B,
  RAICOM_B,
  null,
  RETSEC.USRCRTCOD_CT,  -- Champ rajouté au perimètre, modif du 12/03/98
  RETSEC.USRCRTVAL_LM,  -- Champ rajouté au perimètre, modif du 12/03/98
  null, -- Champs acceptation non utilisé en rétro, modif du 26/03/98
  null, -- Champs acceptation non utilisé en rétro, modif du 26/03/98
  null,   -- Champ acceptation non utilisé en rétro, modif du 26/05/98
  null     -- FILLER 				 MODIF 003 Dch
 from   BRET..TRETSEC RETSEC, BRET..TRETCTR RETCTR
--where  (RETCTRSTS_CT=3 or RETCTRSTS_CT=19) -- V102
  where (LOB_CF='30' or LOB_CF='31')
    and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF
    and RETSEC.RTY_NF=RETCTR.RTY_NF
    and exists(select 1 from BREF..TBATCHSSD c where RETCTR.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())
order by RETCTR_NF, RETSEC_NF, RTY_NF
select @erreur = @@error
if @erreur != 0
  return @erreur

return 0
go
if object_id('dbo.PsSECTION_26') is not null
  print '<<< CREATED PROC dbo.PsSECTION_26 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsSECTION_26 >>>'
go
grant execute on dbo.PsSECTION_26 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_26 TO GDBBATCH
go
