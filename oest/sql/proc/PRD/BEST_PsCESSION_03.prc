USE BEST
go
IF OBJECT_ID('dbo.PsCESSION_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCESSION_03
    IF OBJECT_ID('dbo.PsCESSION_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCESSION_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCESSION_03 >>>'
END
go
/*
 * creation de la procedure
 */
CREATE PROCEDURE dbo.PsCESSION_03 AS
        /***************************************************

Programme:              PsCESSION_03
Fichier script associé: PsCESSION_03.PRC
Domaine:                (ES) Estimation
Base principale:        BEST
Version:                :spira:62073
Auteur:                 HH.Huynh 
Date de creation:       14 Mars 2018
Description du programme:
	a)  même travail que PsCESSION_01:
		Extraction des versements de la base retrocession
		avec selection des versements valides et actifs
        ou historises et supprimes.
    b)  ajout pour prise en compte des champs:
		BLCSHTSTR_D et BLCSHTEND_D
		
Parametres: aucun
Conditions d'execution:
Commentaires: A prévoir plus tard ces 2 champs en cas null que faire, attendant c'est la date courante:  convert(Char(8), getdate(),112) ligne(76,79,146,149)

*****************************************************/
        DECLARE @erreur INT
        DECLARE @curr_usr UUPDUSR_CF
        SELECT @curr_usr = USER_NAME ()
        SELECT
            BATCHUSER_CF,
            SSD_CF
        INTO #ssds
        FROM BREF..TBATCHSSD
        WHERE BATCHUSER_CF = @curr_usr
        SELECT
            a.CTR_NF,
            0 END_NT,
            a.SEC_NF,
            a.UWY_NF,
            a.UW_NT,
            a.RETCTR_NF,
            0 RETEND_NT,
            a.RETSEC_NF,
            a.RTY_NF,
            1 RETUW_NT,
            a.CESACCSTA_N,
            a.CESACCEND_N,
            a.CESSH_R,
            b.SSD_CF,
            b.esb_cf,
            b.retctrcat_cf,
            a.ACCADMTYP_CT,
            b.retaccadm_b,
            b.clecutper_b,
            b.clecutper_nb,
            a.LOB_CF,
            '' CUR_CF,
            /* champ cur_cf */
            b.retpcpcur_cf,
            b.CONRETCTR_B,
            /* MODIF 3 */
            b.ACCFAM_CT,
            CASE WHEN BLCSHTSTR_D IS NOT NULL THEN CONVERT (CHAR (8),
                                                            BLCSHTSTR_D,
                                                            112)
            ELSE CONVERT (CHAR (8),
                          GETDATE (),
                          112) END BLCSHTSTR_D,
            CASE WHEN BLCSHTEND_D IS NOT NULL THEN CONVERT (CHAR (8),
                                                            BLCSHTEND_D,
                                                            112)
            ELSE CONVERT (CHAR (8),
                          GETDATE (),
                          112) END BLCSHTEND_D
        INTO #CESSION
        FROM
            bret..tcession a,
            bret..tretctr b,
            #ssds s
        WHERE
            ((a.cesupdtyp_cf = '' AND
              a.cessts_cf = '01') OR
             (a.cesupdtyp_cf = 'S' AND
              a.cessts_cf = '03')) AND
            a.CESSIONCAT_CF = "1" AND
            a.retctr_nf *= b.retctr_nf AND
            a.rty_nf *= b.rty_nf AND
            a.ssd_cf = s.ssd_cf
        SELECT @erreur = @@ERROR
        IF @erreur != 0
            BEGIN
                RAISERROR 20005 "APPLICATIF;TCESSION"
                RETURN @erreur
            END -- Mettre à jour la devise à partir de la section si cette dernière est renseignée
        UPDATE
            #CESSION
            SET retpcpcur_cf = b.RETSPECUR_CF
            FROM
                #CESSION c,
                bret..tretsec b
            WHERE
                c.retctr_nf = b.retctr_nf AND
                c.retsec_nf = b.retsec_nf AND
                c.rty_nf = b.rty_nf AND
                b.RETSPECUR_CF IS NOT NULL AND
                b.RETSPECUR_CF != ' '
        SELECT @erreur = @@ERROR
        IF @erreur != 0
            BEGIN
                RAISERROR 20005 "APPLICATIF;TCESSION"
                RETURN @erreur
            END
        SELECT
            CTR_NF,
            END_NT,
            SEC_NF,
            UWY_NF,
            UW_NT,
            RETCTR_NF,
            RETEND_NT,
            RETSEC_NF,
            RTY_NF,
            RETUW_NT,
            CESACCSTA_N,
            CESACCEND_N,
            CESSH_R,
            SSD_CF,
            esb_cf,
            retctrcat_cf,
            ACCADMTYP_CT,
            retaccadm_b,
            clecutper_b,
            clecutper_nb,
            LOB_CF,
            CUR_CF,
            retpcpcur_cf,
            CONRETCTR_B,
            ACCFAM_CT,
            CASE WHEN BLCSHTSTR_D IS NOT NULL THEN CONVERT (CHAR (8),
                                                            BLCSHTSTR_D,
                                                            112)
            ELSE CONVERT (CHAR (8),
                          GETDATE (),
                          112) END BLCSHTSTR_D,
            CASE WHEN BLCSHTEND_D IS NOT NULL THEN CONVERT (CHAR (8),
                                                            BLCSHTEND_D,
                                                            112)
            ELSE CONVERT (CHAR (8),
                          GETDATE (),
                          112) END BLCSHTEND_D
        FROM #CESSION
        ORDER BY
            CTR_NF,
            END_NT,
            SEC_NF,
            UWY_NF,
            UW_NT
        SELECT @erreur = @@ERROR
        IF @erreur != 0
            BEGIN
                RAISERROR 20005 "APPLICATIF;TCESSION"
                RETURN @erreur
            END
        RETURN 0
go
EXEC sp_procxmode 'dbo.PsCESSION_03', 'unchained'
go
IF OBJECT_ID('dbo.PsCESSION_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCESSION_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCESSION_03 >>>'
go
GRANT EXECUTE ON dbo.PsCESSION_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCESSION_03 TO GDBBATCH
go
