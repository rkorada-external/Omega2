USE BSTA
go

IF OBJECT_ID('dbo.PuTBOPAR_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PuTBOPAR_02
    PRINT '<<< DROPPED PROC dbo.PuTBOPAR_02 >>>'
END
go

-- creation de la procedure
create procedure PuTBOPAR_02
    @BALSHTYEA_NF	int,
    @BALSHTMTH_NF	smallint
as

/***************************************************
Programme               : PuTBOPAR_02
Fichier script associe  : BSTA_PuTBOPAR_02.PRC
Base principale         : BSTA
Version                 : 1
Auteur                  : JF VDV
Date de creation        : 25/11/2009

Description du programme:
      [12363] - MAJ du mois de FIELD1_CF dans la table bsar..TBOPAR dans le cas ou variante = 5
      [12363] - MAJ du mois de FIELD1_CF dans la table bsar..TBOPAR (prise en compte du zéro pour les mois de 1 à 9)  04/05/2010
      [12363] - D.GATIBELZA: prise en compte du zéro pour les mois de 1 à 9 ( 31/01/2011 )
_________________
[001] 03/11/2011 Roger Cassis     :spot:22752 - Affectation null a la variable @zero au lieu de champ vide.
*****************************************************/
declare @err int,
        @field01 varchar(4),
        @field02 varchar(2)
declare @zero    char(1)

select  @err = 0 ,
        @field01 = convert(varchar(4),@BALSHTYEA_NF),
        @field02 = convert(varchar(2),@BALSHTMTH_NF)
select  @zero = '0'

If @BALSHTMTH_NF = 12
begin
    PRINT '!!!!! Cas variante égale à 5 avec @BALSHTMTH_NF = 12 impossible !!!!!!'
    PRINT '!!!!! Revoir les paramètres d''inventaire éventuellement !!!!!'
    goto FIN
end
BEGIN Tran

    -- faire +1 sur le mois de la colonne FIELD1_CF (AAAAMM)
    -- ======================================================
    If @BALSHTMTH_NF >= 9
    begin
        select @zero=null   -- [001]
    end


    UPDATE bsar..TBOPAR
    SET FIELD1_CF    = substring(FIELD1_CF,1,4) + @zero + convert(varchar(2),(convert(int,substring(FIELD1_CF,5,2)) +1)),
        LSTUPDUSR_CF = NULL,
        LSTUPD_D     = NULL
    where DMN_CF = 'EST'
      and ( PAR_D = NULL or PAR_D  = '' )
      and ARCH_B  = 0
      and convert(int, substring(FIELD1_CF,1,4)) = @BALSHTYEA_NF
      and convert(int, substring(FIELD1_CF,5,2)) = @BALSHTMTH_NF
      and FIELD1_CF != "XXXXXXXX"

    select @err = @@error
    if @err = 0
    begin
        COMMIT Tran
        PRINT 'Mise à jour des lignes de TBOPAR si variante égale à 5 et le champs suivant:'
        PRINT 'FIELD1_CF = %1! %2!%3!', @field01, @zero, @field02
    end
    else
    begin
        print 'Erreur %1! sur update de la table bsar..TBOPAR', @err
        ROLLBACK Tran
        return
    end
FIN:

go
IF OBJECT_ID('dbo.PuTBOPAR_02') IS NOT NULL
BEGIN
    PRINT '<<< CREATED PROC dbo.PuTBOPAR_02 >>>'
END

go
GRANT EXECUTE ON dbo.PuTBOPAR_02 TO GOMEGA
go

