use BEST
go

if object_id('dbo.PsSECTION_36') IS not null
begin
    drop PROC dbo.PsSECTION_36
    print '<<< DROPPED PROC dbo.PsSECTION_36 >>>'
end
go

create procedure PsSECTION_36
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Mise a jour de la table TFAMLIA de la base BTRT a partir de la table ESTFAMLIA (BTRAV)
                          Comme on enleve les triggers pour la base traite avant la proc il faut mettre a jour TFAMLIA_V
Conditions d'execution:
Commentaires:
_________________
HISTORIQUE
Nb Auteur    date       Description
*****************************************************/
declare @erreur    int,
        @tran_imbr bit,
        @retour    int

select @erreur=0, @tran_imbr=1
if @@trancount = 0
begin
    select @tran_imbr = 0
    begin tran
end

-- modif 1
-------------- MISE A JOUR DE BTRT..TFAMLIA ------------------
-- ATTENTION LES TRIGGERS ONT ETE DROPPES AVANT LE LANCEMENT
-- DE LA PROC. LA MAJ D AUTRES JOURS CHAMPS DE BTRT..TFAMLIA
-- DOIT ETRE REALISEE EN COHERENCE AVEC L ACTION DES TRIGGERS
update BTRT..TFAMLIA
   set PMLRAT_R=TRAV.PMLRAT_R
from BTRT..TFAMLIA FAMLIA, BTRAV..ESTFAMLIA TRAV
where FAMLIA.CTR_NF=TRAV.CTR_NF
  and FAMLIA.END_NT=TRAV.END_NT
  and FAMLIA.SEC_NF=TRAV.SEC_NF
  and FAMLIA.UWY_NF=TRAV.UWY_NF
  and FAMLIA.UW_NT=TRAV.UW_NT

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRT..TFAMLIA_V
   set PMLRAT_R=TRAV.PMLRAT_R
from BTRT..TFAMLIA_V FAM_V, BTRAV..ESTFAMLIA TRAV
where FAM_V.CTR_NF=TRAV.CTR_NF
  and FAM_V.UWY_NF=TRAV.UWY_NF
  and FAM_V.UW_NT=TRAV.UW_NT
  and FAM_V.SEC_NF=TRAV.SEC_NF
  and FAM_V.END_NT=( select max( END_NT )
                     from BTRT..TFAMLIA_V
                     where CTR_NF=TRAV.CTR_NF
                       and UWY_NF=TRAV.UWY_NF
                       and UW_NT=TRAV.UW_NT
                       and SEC_NF=TRAV.SEC_NF )

select @erreur = @@error
if @erreur!=0
    goto fin

if @tran_imbr = 0
    commit tran
return 0


fin:
if @tran_imbr = 0
    rollback tran
return @erreur
go

if object_id('dbo.PsSECTION_36') IS not null
    print '<<< CREATED PROC dbo.PsSECTION_36 >>>'
else
    print '<<< FAILED CREATING PROC dbo.PsSECTION_36 >>>'
go

grant execute on dbo.PsSECTION_36 TO GOMEGA
go

