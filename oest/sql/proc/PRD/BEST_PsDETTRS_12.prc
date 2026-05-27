use BEST
go
if object_id('dbo.PsDETTRS_12') is not null
begin
  drop PROC dbo.PsDETTRS_12
  print '<<< DROPPED PROC dbo.PsDETTRS_12 >>>'
end
go
create procedure PsDETTRS_12
  (
  @p_balshey_nf   int
 ,@p_balshrmth_nf int
 ,@p_balshrday_nf int
 ,@p_valpery_nf   int
 ,@p_valpermth_nf int
 ,@p_entpery_nf   int
 ,@p_entpermth_nf int
 ,@p_trncod_cf    UDETTRS_CF
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 01/04/2005
Description du programme:
      SPOT 11833
      PowerBuider : w_feuille_es2600
      Vérification Poste Comptable d'ouverture lors de la Saisie Ecriture_Service

Parametres:
		@p_balshey_nf   int                 -- Periode Inventaire : AAAA
		@p_balshrmth_nf  int               -- Periode Inventaire : MM
		@p_balshrday_nf int                -- Periode Inventaire : DD
		@p_valpery_nf        int            -- Periode Validité : AAAA
		@p_valpermth_nf     int            -- Periode Validité : MM
		@p_entpery_nf        int,           -- Periode de Saisie AAAA
		@p_entpermth_nf     int,           -- Periode de Saisie MM
		@p_trncod_cf          UDETTRS_CF,   -- Poste Comptable
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 Florent 26/07/2012 :spot:24040 Solvency II, EBS
*****************************************************/
declare   @erreur       int,
          @A_traiter     int

declare    @v_codeerrmsg   integer
declare @v_LibelleMsg char(240)
declare @TypePoste char(1)

-- Debut de Traitement de Contrôle des Erreurs
select @v_codeerrmsg = 0
select @erreur = 0
select @v_LibelleMsg = ''   -- Futuring : pour Ajouter une Période Par exemple, Au Msg à Afficher en Retour

-- -------------------------------------------------------------------------------------------------------
-- 1. Si le Poste n'est pas de Type Ouverture, on quitte !
-- -------------------------------------------------------------------------------------------------------
--    Pour les écritures services, les postes d'ouvertures sont ceux de second préfixe égal à :
---	7 pour compte de résultat - service rejet,
---	8 pour bilan - service rejet,
---	9 pour compte de résultat financier - service rejet.
-- écritures EBS : J G L
select @TypePoste = Substring(@p_trncod_cf, 2 ,1)
if (@TypePoste != '7' and @TypePoste != '8' and @TypePoste != '9' and @TypePoste != 'J' and @TypePoste != 'G' and @TypePoste != 'L') -- modif 1
begin
  goto fin
end

-- -------------------------------------------------------------------------------------------------------
-- 2. Contrôle Période de Fin de Validité doit être égale à Période d'Inventaire
-- -------------------------------------------------------------------------------------------------------
if (@p_balshey_nf = @p_valpery_nf  and @p_balshrmth_nf != @p_valpermth_nf) or (@p_balshey_nf != @p_valpery_nf)
begin
  select @v_codeerrmsg = 2023     -- 2023 La Période de Fin de Validité doit être égale à la Période d'Inventaire pour les Postes D'ouvertures !  ~r~n §
                                               -- 2023 Ajouter MSG English
  goto fin
end
-- Fin de Traitement de Contrôle des Erreurs
fin:
select @v_codeerrmsg, @v_LibelleMsg
go
if object_id('dbo.PsDETTRS_12') is not null
  print '<<< CREATED PROC dbo.PsDETTRS_12 >>>'
else
    print '<<< FAILED CREATING PROC dbo.PsDETTRS_12 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsDETTRS_12
 */
grant execute on dbo.PsDETTRS_12 TO GOMEGA
go

