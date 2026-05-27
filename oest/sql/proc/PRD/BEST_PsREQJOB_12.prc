use BEST
go
if object_id('dbo.PsREQJOB_12') is not null
begin
  drop procedure dbo.PsREQJOB_12
  if object_id('dbo.PsREQJOB_12') is not null
    print '<<< FAILED DROPPING procedure dbo.PsREQJOB_12 >>>'
  else
    print '<<< DROPPED procedure dbo.PsREQJOB_12 >>>'
end
go
create procedure PsREQJOB_12
  (
  @p_ssd_cf     USSD_CF              -- Filiale d'Appel
 ,@p_service    smallint             -- En Période de Service ( 1: OUI / 0 : Non)
 ,@p_date_d     datetime             -- Date
 ,@p_NameReqcod char(32)             -- Nom de Colonne à Utiliser pour le Filtre
 ,@p_FromWindow int                  -- Nom de Fenêtre d'Appel ( 1 : ES2700 / 2 : ES0002)
                                     -- Si l'on veut faire évoluer par exemple, l'une ou l'autre fenêtre
                                     -- Lors de la création, les 2 Fenêtres reçoivent le même Filtre
 ,@p_filtre     varchar(1024) output -- Résultat du Filtre
 )
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : M. DJELLOULI
Date de creation         : 14/02/2005
Description du programme : Renvoi de la sélection du Filtre des codes REQCOD_CT autorisé pour la Filiale
                           Powerbuilder w_feuille_es2700 ue_apres_open() et w_recherche_es0002 ue_apres_open()
                           Cette Procédure a été créée en réponse aux évolutions constantes des fenêtres w_recherche_es0002
                           et w_feuille_es2700 qui nécessitaient des modifications de l'Application PB.
                           Elle évite aussi, la duplication de Codes à travers 3 Fonctions/Event
Conditions d'execution :

Commentaires :Type de Demandes
              C Comptabilisation
              I Inventaire
              J Inventaire + SNEM
              L S/R Vie
              S Prop Sin CE
              Z Chargemt Inventaire
              D Demande Inventaire
              E Demande EBS
              B Booking
              T Demande PeopleSoft Conso-Social
              F BOOKING PeopleSoft Conso-Social
_________________
MODIFICATIONS
1 D.Ourmiah 14/09/2006 :spot:13150
2 G.BUISSON 10/10/2008 :spot:16189 Pouvoir faire des demandes S/R vie pour les filiales 18 et 19
3 G.BUISSON 10/10/2008 :spot:16286 Idem pour la filiale 23 qui fonctionne de la même façon que 4 & 14
4 T. RIPERT 09/11/2010 afficher les demandes V
5 Florent   08/03/2012 :spot:23390 sovency demande E
*****************************************************/
declare
  @erreur       int
 ,@A_traiter    int
 ,@v_codeerrmsg integer
 ,@filtre       varchar(1024)

-- En Fonction de l'appel, à partir de PB
--  Rtrim(@p_NameReqcod) = "ccolval_ct" ou Rtrim(@p_NameReqcod) = "T1.REQCOD_CT"

/*if (@p_service = 0)
     begin
          select @p_filtre =
            (CASE
                 WHEN (@p_ssd_cf In (4, 14, 16, 18, 19, 23))
                      then Rtrim(@p_NameReqcod) + " <> 'J' and " + Rtrim(@p_NameReqcod) + " <> 'S' and"

                 WHEN (@p_ssd_cf In (1, 7, 10, 11))
                      then Rtrim(@p_NameReqcod) + " <> 'J' and " + Rtrim(@p_NameReqcod) + " <> 'L' and"

                 WHEN (@p_ssd_cf In (2, 3, 12))
                      then Rtrim(@p_NameReqcod) + " <> 'L' and"

                 WHEN (@p_ssd_cf In (5, 6, 8, 9))
                      then  Rtrim(@p_NameReqcod) + " <> 'J' and"

                 WHEN (@p_ssd_cf > 12 and @p_ssd_cf Not In (18, 19, 20, 23))
                      then Rtrim(@p_NameReqcod) + " <> 'J' and " + Rtrim(@p_NameReqcod) + " <> 'L' and"

                 WHEN (@p_ssd_cf = 20) -- #1
                      then Rtrim(@p_NameReqcod) + " <> 'J' and"

                 else
                      ""
            end)
     end


-- Période de SERVICE
if (@p_service = 1)
     begin
          select @p_filtre =
               (CASE
                    WHEN (@p_ssd_cf In (4, 14, 16, 18, 19, 23))
                         then Rtrim(@p_NameReqcod) + " = 'I' and"

                    WHEN (@p_ssd_cf In (1, 5, 6, 7, 8, 9, 10, 11))
                         then Rtrim(@p_NameReqcod) + " <> 'J' and " + Rtrim(@p_NameReqcod)  + " <> 'L' and"

                    WHEN (@p_ssd_cf In (2, 3, 12))
                         then Rtrim(@p_NameReqcod) + " <> 'L' and"

                    WHEN (@p_ssd_cf > 12 and @p_ssd_cf Not In (14, 16, 18, 19, 23))
                         then Rtrim(@p_NameReqcod) + " <> 'J' and " + Rtrim(@p_NameReqcod) + " <> 'L' and"

                    else
                         ""
               end)
     end  */

if (Lower(Rtrim(@p_NameReqcod)) != "ccolval_ct")   -- Si Appel ue_declare_curseur, donc T1.REQCOD_CT
begin
  -- Si on n'inclut pas REQCOD_CT = 'I' (Donc, on vérifie seulement l'existence du '=' dans la chaine)
  if (patindex('%=%', @p_filtre) <= 0)
    select @p_filtre = @p_filtre +  " " + Rtrim(@p_NameReqcod) + " <> 'C' and "
end

if (@p_FromWindow = 1)
  select @p_filtre = @p_filtre +  " " + Rtrim(@p_NameReqcod) + " <> 'B' and "     -- on ne tient pas Compte des "Booking"

--select @p_filtre = @p_filtre +  " " + Rtrim(@p_NameReqcod) + " <> 'V' and "
--select @p_filtre = @p_filtre +  " " + Rtrim(@p_NameReqcod) + " <> 'M' and "
select @p_filtre = @p_filtre +  " " + Rtrim(@p_NameReqcod) + " not in('P','U','S','G','B','I','J')"

select @filtre = @p_filtre

fin:
select @filtre

return 0
go
if object_id('dbo.PsREQJOB_12') is not null
  print '<<< CREATED procedure dbo.PsREQJOB_12 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsREQJOB_12 >>>'
go
grant execute on dbo.PsREQJOB_12 TO GOMEGA
go
