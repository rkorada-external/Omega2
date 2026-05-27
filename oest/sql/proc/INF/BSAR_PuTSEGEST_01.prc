use BSAR
go
IF OBJECT_ID('dbo.PuTSEGEST_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuTSEGEST_01
   PRINT '<<< DROPPED PROC dbo.PuTSEGEST_01 >>>'
END
go
create procedure PuTSEGEST_01
	(
	@P_SSD_CF    USSD_CF,
	@P_SEGTYP_CT USEGTYP_CT,
	@P_SEG_NF    USEG_NF,
	@P_UWY_NF    UUWY_NF,
	@P_SEG_LL    UL64,
	@P_CUR_CF    UCUR_CF,
	@P_SEGNAT_CT char(1),
	@P_CTRRET_B  bit,
	@P_PRMAMT_M  UAMT_M,
	@P_CLMAMT_M  UAMT_M,
	@P_LOSRAT_R  USHORAT_R,
	@P_AMORAT_CT char(1),
	@P_ACY_NF    UUWY_NF
	)
as

/***************************************************

Programme: PuTSEGEST_01

Fichier script associé : BEST_PuTSEGEST_01.prc
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI - 
Date de creation: 25/08/2004 

Description du programme: 
    Insertion / Update de la Table BSAR..TSEGEST

Parametres: 
@P_SSD_CF : Filiale de l'utilisateur : paramètre
@P_SEGTYP_CT : " A " 
@P_SEG_NF : Code du segment : paramètre
@P_UWY_NF : Exercice saisi : paramètre
@P_SEG_LL : Libelle long du segment saisi : BEST..TSEGMENT
@P_CUR_CF : Devise saisie : paramètre
@P_SEGNAT_CT : Nature segment : BEST..TSEGMENT
@P_CTRRET_B : Indicateur rétro interne saisi : BEST..TSEGMENT
@P_PRMAMT_M : Montant prime saisie ou NULL sinon : BEST..TSEGEST
@P_CLMAMT_M : Montant sinistre saisi ou NULL sinon : BEST..TSEGEST
@P_LOSRAT_R : Taux saisi / 10 000 ou NULL sinon : BEST..TSEGEST
@P_AMORAT_CT : " R " si LOSRAT_R est saisi, " S " si CLMAMT_M est saisi : BEST..TSEGEST

Conditions d'execution: 

Commentaires:

_________________
MODIFICATIONS
2  Florent   01/06/2015 :spot:28694 Segmentation VIE
*****************************************************/

declare @erreur int

select @erreur = 0


if  ( exists ( select 1 from TSEGEST 
               where SSD_CF = @P_SSD_CF and SEGTYP_CT = @P_SEGTYP_CT and SEG_NF = @P_SEG_NF and UWY_NF = @P_UWY_NF and ACY_NF=@P_ACY_NF) )
BEGIN
  UPDATE TSEGEST
  SET SEG_LL = @P_SEG_LL,
      CUR_CF = @P_CUR_CF,
      SEGNAT_CT= @P_SEGNAT_CT,
      CTRRET_B = @P_CTRRET_B,
      PRMAMT_M = @P_PRMAMT_M,
      CLMAMT_M = @P_CLMAMT_M,
      LOSRAT_R = @P_LOSRAT_R,
      AMORAT_CT= @P_AMORAT_CT
  WHERE SSD_CF = @P_SSD_CF and 
        SEGTYP_CT = @P_SEGTYP_CT and 
        SEG_NF = @P_SEG_NF and 
        UWY_NF = @P_UWY_NF and
        ACY_NF = @P_ACY_NF
END
ELSE
BEGIN
  INSERT INTO TSEGEST (SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF,
                      SEG_LL, CUR_CF, SEGNAT_CT, CTRRET_B,
                      PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT,ACY_NF)
  VALUES (@P_SSD_CF,
          @P_SEGTYP_CT,
          @P_SEG_NF,
          @P_UWY_NF,
          @P_SEG_LL,
          @P_CUR_CF,
          @P_SEGNAT_CT,
          @P_CTRRET_B,
          @P_PRMAMT_M,
          @P_CLMAMT_M,
          @P_LOSRAT_R,
          @P_AMORAT_CT,
          @P_ACY_NF
         )
END

select @erreur = @@error

if @erreur != 0
begin
  return @erreur
end

return 0
go
IF OBJECT_ID('dbo.PuTSEGEST_01') IS NOT NULL
  PRINT '<<< CREATED PROC dbo.PuTSEGEST_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC dbo.PuTSEGEST_01 >>>'
go
GRANT EXECUTE ON dbo.PuTSEGEST_01 TO GOMEGA, GDBBATCH
go
