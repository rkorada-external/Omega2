USE BEST
go
IF OBJECT_ID('dbo.PsLIFDRIY_ALL_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFDRIY_ALL_01
    IF OBJECT_ID('dbo.PsLIFDRIY_ALL_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFDRIY_ALL_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFDRIY_ALL_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsLIFDRIY_ALL_01
	(
	@p_balshtyea_nf	 smallint,
    @p_balshtmth_nf  tinyint
	)
with execute as caller as

/***************************************************

Programme: PsLIFDRI_ALL_QUARTER_01
Fichier script associé : ESCJ0060.cmd / ESIX0061.c
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Rafael Vieville
Date de creation: 06/02/2019
Description du programme: 
	exctract TLIFRDID
	
Parametres: 
	@p_balshtyea_nf -> balshey year
	@p_balshtmth_nf -> balshey mounth
Conditions d'execution: 
Commentaires: servira en estimation pour la fonction 
_________________
[001] 12/06/2019 R. VIEVILLE :spira:78940: remove check uwy
***********************************************************************/

SELECT
	A.CTR_NF,
	A.END_NT,
	A.SEC_NF,
	A.UWY_NF,
	A.UW_NT,
	A.ACY_NF,
	13, 
	A.SSD_CF,
	A.BALSHEY_NF,
	A.BALSHTMTH_NF,
	A.AUTUPD_B,
	A.COMACC_B,
	A.RESPROPAG_B,											--[001]
	A.SEGUPD_B,												--[004]
	Convert(Char(8), A.CRE_D, 112) + ' ' + Convert(Char, A.CRE_D, 108) CRE_D,
	A.CMT_NT,
	A.CREUSR_CF,
	Convert(Char, A.LSTUPD_D, 109) LSTUPD_D,
	A.LSTUPDUSR_CF
 FROM
 	BEST..TLIFDRI  A,
	BTRAV..TESTSSD E--,
	--BTRT..TCONTR C											--[005]
 WHERE
 	A.SSD_CF		= E.SSD_CF AND
	A.BALSHEY_NF 	= (	SELECT
							Max(B.BALSHEY_NF) 
						FROM
							BEST..TLIFDRI B
						WHERE
							B.CTR_NF = A.CTR_NF AND
							B.END_NT = A.END_NT AND			--[002]
							B.ACY_NF = A.ACY_NF
						GROUP BY
							B.CTR_NF,
							B.END_NT,						--[002]
							B.ACY_NF
                	    ) AND
	A.CRE_D			= (	SELECT
							Max(C.CRE_D)
						FROM
							BEST..TLIFDRI C
						WHERE
							C.CTR_NF = A.CTR_NF AND
							C.END_NT = A.END_NT AND			--[002]
							C.SEC_NF = A.SEC_NF AND			--[002]
							C.ACY_NF = A.ACY_NF
						GROUP BY
							C.CTR_NF,
							C.END_NT,						--[002]
							C.SEC_NF,
							C.ACY_NF						--[002]
                        ) AND
	A.CTR_NF		!= '         ' AND
	A.UWY_NF		= A.ACY_NF AND
	(A.BALSHEY_NF < @p_balshtyea_nf OR A.BALSHTMTH_NF !> @p_balshtmth_nf) --AND	--[003]
	--A.CTR_NF = C.CTR_NF AND
	--A.UWY_NF = C.UWY_NF AND -- [005]
	--C.ESTCRB_CT NOT IN ('T', 'U')
	ORDER BY
	A.CTR_NF,
	A.SEC_NF,
	A.ACY_NF,
	A.AUTUPD_B,
	A.COMACC_B,
	A.BALSHEY_NF
/*
UNION --[005]

SELECT
	A.CTR_NF,
	A.END_NT,
	A.SEC_NF,
	A.UWY_NF,
	A.UW_NT,
	A.ACY_NF,
	13,
	A.SSD_CF,
	A.BALSHEY_NF,
	A.BALSHTMTH_NF,
	A.AUTUPD_B,
	A.COMACC_B,
	A.RESPROPAG_B,											--[001]
	A.SEGUPD_B,												--[004]
	Convert(Char(8), A.CRE_D, 112) + ' ' + Convert(Char, A.CRE_D, 108) CRE_D,
	A.CMT_NT,
	A.CREUSR_CF,
	Convert(Char, A.LSTUPD_D, 109) LSTUPD_D,
	A.LSTUPDUSR_CF
 FROM
 	BEST..TLIFDRI  A,
	BTRAV..TESTSSD E,
	BRET..TRETCTR RC
 WHERE
 	A.SSD_CF		= E.SSD_CF AND
	A.BALSHEY_NF 	= (	SELECT
							Max(B.BALSHEY_NF) 
						FROM
							BEST..TLIFDRI B
						WHERE
							B.CTR_NF = A.CTR_NF AND
							B.END_NT = A.END_NT AND			--[002]
							B.ACY_NF = A.ACY_NF
						GROUP BY
							B.CTR_NF,
							B.END_NT,						--[002]
							B.ACY_NF
                	    ) AND
	A.CRE_D			= (	SELECT
							Max(C.CRE_D)
						FROM
							BEST..TLIFDRI C
						WHERE
							C.CTR_NF = A.CTR_NF AND
							C.END_NT = A.END_NT AND			--[002]
							C.SEC_NF = A.SEC_NF AND			--[002]
							C.ACY_NF = A.ACY_NF
						GROUP BY
							C.CTR_NF,
							C.END_NT,						--[002]
							C.SEC_NF,
							C.ACY_NF						--[002]
                        ) AND
	A.CTR_NF		!= '         ' AND
	A.UWY_NF		= A.ACY_NF AND
	(A.BALSHEY_NF < @p_balshtyea_nf OR A.BALSHTMTH_NF !> @p_balshtmth_nf) AND	--[003]
	A.CTR_NF = RC.RETCTR_NF AND
	A.UWY_NF = RC.RTY_NF AND -- [005]
	RC.ESTCRB_CT NOT IN ('T', 'U')
	*/


RETURN 0
go
EXEC sp_procxmode 'dbo.PsLIFDRIY_ALL_01', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFDRIY_ALL_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFDRIY_ALL_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFDRIY_ALL_01 >>>'
go
GRANT EXECUTE ON dbo.PsLIFDRIY_ALL_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFDRIY_ALL_01 TO GDBBATCH
go
