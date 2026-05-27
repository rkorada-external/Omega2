USE BEST
go
IF OBJECT_ID('PsFULAERAT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFULAERAT_01
    IF OBJECT_ID('dbo.PsFULAERAT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFULAERAT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFULAERAT_01 >>>'
END
go
create procedure dbo.PsFULAERAT_01
(
   @p_CLOSING_D datetime
  ,@p_PER_CF   char(3)
)
as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : Florent
Date de creation        : 03/07/2015
Description du programme: :spot:28941
Conditions d'execution  : chaine ESPD0061
Commentaires            :
_________________
MODIFICATIONS
*****************************************************/
select SSD_CF,ESB_CF,PER_CF,CLOSING_D,RATIO_NF,CREUSR_CF,CRE_D
 from TULAERAT
  where CLOSING_D=@p_CLOSING_D
    and PER_CF=@p_PER_CF
go
IF OBJECT_ID('dbo.PsFULAERAT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFULAERAT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFULAERAT_01 >>>'
go
GRANT EXECUTE ON dbo.PsFULAERAT_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFULAERAT_01 TO GDBBATCH
go
