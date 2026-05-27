use BEST
go

/* DROP PROC PsCPLACCI17_02
 */
IF OBJECT_ID('PsCPLACCI17_02') IS NOT NULL
   BEGIN
   DROP PROC PsCPLACCI17_02
   PRINT '<<< DROPPED PROC PsCPLACCI17_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCPLACCI17_02
	(
	@p_clodat_d	datetime
	)
with execute as caller as

/***************************************************
Programme: PsCPLACCI17_02
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Arnaud RUFFAULT
Date de creation:  08/06/2021
Description du programme: 
						Cre a partir de la procedure PsCPLACC_02 utilise dans IFRS4
      Sélection d'enregistrement dans TCPLACC

Parametres: 
	- libellé d'inventaire

Conditions d'execution: 
Commentaires:

*****************************************************/

SELECT SSD_CF,
CTR_NF,
ACY_NF,
SCOSTRMTH_NF,
SCOENDMTH_NF,
convert(char(8),LSTUPD_D,112) + ' ' + convert(char(8),LSTUPD_D,108),
RESPROPAG_B,
LSTUPDUSR_CF
FROM BCTA..TCPLACC

where convert(char(8), blcsht_d, 112) <= @p_clodat_d
and SSD_CF in ( select s.SSD_CF from BREF..TBATCHSSD s where BATCHUSER_CF = suser_name() )
order by ctr_nf

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/


IF OBJECT_ID('PsCPLACCI17_02') IS NOT NULL
   PRINT '<<< CREATED PROC PsCPLACCI17_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsCPLACCI17_02 >>>'
go
/*
 * Granting/Revoking Permissions on PsCPLACCI17_02
 */
GRANT EXECUTE ON PsCPLACCI17_02 TO GOMEGA
go
GRANT EXECUTE ON PsCPLACCI17_02 TO GDBBATCH
go

