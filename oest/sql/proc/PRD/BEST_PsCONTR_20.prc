USE BEST
go

IF OBJECT_ID('dbo.PsCONTR_20') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCONTR_20
    IF OBJECT_ID('dbo.PsCONTR_20') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCONTR_20 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCONTR_20 >>>'
END
go

CREATE PROCEDURE dbo.PsCONTR_20
           (
            @p_ctr_nf  UCTR_NF,
            @p_uwy_nf UUWY_NF,
			@p_uw_nt UUW_NT,
			@p_end_nt UEND_NT,
			@p_ssd_cf USSD_CF
           )
AS

/***************************************************

Programme: PsCONTR_20

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: Dominique Ourmiah

Date de creation: 27/06/2007

Description du programme:

      SPOT 13135 : Controle si le contrat est à l'état "Terminé comptable"

Paramètres:

@p_ctr_nf  UCTR_NF,
@p_uwy_nf UUWY_NF,
@p_uw_nt UUW_NT,
@p_end_nt UEND_NT,
@p_ssd_cf USSD_CF

Conditions d'execution:

Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/


declare @error int,
            @ret int

/* Fac */
select @ret = 1 from BFAC..TCONTR
where ctr_nf = @p_ctr_nf
and uwy_nf = @p_uwy_nf
and uw_nt = @p_uw_nt
and end_nt = @p_end_nt
and ssd_cf = @p_ssd_cf
and ctraccsts_ct = 9

select @error = @@error
if @error != 0
begin
    raiserror 20003 "APPLICATIF;TCONTR"
    return 1
end

/* Traité */
if @ret = null
begin
    select @ret = 1 from BTRT..TCONTR
    where ctr_nf = @p_ctr_nf
    and uwy_nf = @p_uwy_nf
    and uw_nt = @p_uw_nt
    and end_nt = @p_end_nt
    and ssd_cf = @p_ssd_cf
    and ctraccsts_ct = 9

    select @error = @@error
    if @error != 0
    begin
        raiserror 20003 "APPLICATIF;TCONTR"
        return 1
    end
end

if @ret = null select @ret = 0

select @ret

return 0


EXEC sp_procxmode 'dbo.PsCONTR_20','unchained'

go
EXEC sp_procxmode 'dbo.PsCONTR_20','unchained'
go
IF OBJECT_ID('dbo.PsCONTR_20') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCONTR_20 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCONTR_20 >>>'
go
GRANT EXECUTE ON dbo.PsCONTR_20 TO GOMEGA
go
