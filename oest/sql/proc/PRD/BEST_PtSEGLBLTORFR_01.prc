USE BEST

go
IF OBJECT_ID('dbo.PtSEGLBLTORFR_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtSEGLBLTORFR_01
    IF OBJECT_ID('dbo.PtSEGLBLTORFR_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtSEGLBLTORFR_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtSEGLBLTORFR_01 >>>'
END
go

/***************************************************
Program:		PtSEGLBLTORFR_01
File script :	BEST_PtSEGLBLTORFR_01.prc
Main database :	BEST
Version:		1
Author:			NGA
Creation date:	12/03/2015
Description:
	. For each corresponding segments in RFR by code
      and associated to the given segtype's valid segmentations:
		- If the segment exists in RFR with a different
          label, update the label and the last update user
		- If the segment does not exist in RFR, insert it
Parameters:
    @p_sgttyp_nt    Target segmentation type
Conditions:
    @p_sgttyp_nt related segments will be exported only
    if has an UW mapping in BEST..TUWEXPORT.
Comments:
    Important note: the mapping is the following
        - SEG SGMT_LS -> RFR COLVAL_CT
        - SEG SGMT_LL -> RFR COLVAL_LS
Change log:
001	N. Gasull (Capgemini)	27/05/2015	Restricted scope to only group segmentations
****************************************************/
CREATE PROCEDURE dbo.PtSEGLBLTORFR_01 (@p_sgttyp_nt USGTTYP_NT, @p_erreur VARCHAR (64) = NULL OUTPUT)
AS
    DECLARE
        @GROUP_MGT UBANVAL_CT,
        @SEGSTS_ACTIVE UBANVAL_CT,
        @lang ULAG_CF,
		@countDuplicates INT,
        @erreur INT,
        @tran_imbr BIT,
        @nbligne INT

    SELECT @GROUP_MGT = '1'
    SELECT @SEGSTS_ACTIVE = '3'
    SELECT @erreur = 0
    SELECT @tran_imbr = 1

    IF @@trancount = 0
        BEGIN
            SELECT @tran_imbr = 0
            BEGIN TRAN
        END

    DECLARE lang_c CURSOR FOR
        SELECT LAG_CF FROM BREF..TLAG

    open lang_c
    
    fetch lang_c into @lang
    while (@@sqlstatus != 2)
    begin
        if (@@sqlstatus = 1)
        begin
            SELECT @erreur = 1
            SELECT @p_erreur = "Error while fetching language codes, aborting"
            GOTO fin
        end
        else
        begin
            -- Matching LS: update LL in RFR (actually RFR's COLVAL_LS)
            UPDATE
                bref..tbantecl
                SET
                    COLVAL_LS = SUBSTRING (gmt.SGMT_LL,
                                        1,
                                        16),
                    LSTUPDUSR_CF = SUSER_NAME ()
                FROM
                    bref..tbantecl rfr
                    INNER JOIN
                    best..tuwexport uwx
                    ON
                        rfr.COL_LS = uwx.SGTTGT_LS
                    INNER JOIN
                    BEST..TSEGTYPE typ
                    ON
                        typ.SGTTYP_NT = uwx.SGTTYP_NT AND
                        typ.SGTSCOPE_CT = uwx.SGTSCOPE_CT
                    INNER JOIN
                    BEST..TSEGMENTATION seg
                    ON
                        seg.SGTTYP_NT = typ.SGTTYP_NT
                    INNER JOIN
                    BEST..TSEGMT gmt
                    ON
                        gmt.SGT_NT = seg.SGT_NT AND
                        gmt.SGTVER_NT = seg.SGTVER_NT AND
                        gmt.SGTLVL_NT = uwx.SGTLVL_NT AND
                        rfr.COLVAL_CT = gmt.SGMT_LS
                WHERE
					rfr.LAG_CF = @lang AND
                    seg.SGTSTS_CF = @SEGSTS_ACTIVE AND
                    typ.SGTTYP_NT = @p_sgttyp_nt AND
                    rtrim(typ.SGTMGTLVL_CT) = @GROUP_MGT AND
                    rfr.COLVAL_LS != gmt.SGMT_LL

            -- Handle errors on RFR segments updates
            SELECT
                @erreur = @@error,
                @nbligne = @@rowcount
            
            IF @@transtate = 2
                BEGIN
                    SELECT @p_erreur = "ERREUR TRIGGER"
                    GOTO fin
                END
            
            IF @erreur != 0
                BEGIN
                    SELECT @p_erreur = "20001 APPLICATIF;" + CONVERT (VARCHAR (10),
                                                                      @erreur) + ";"
                    GOTO fin
                END
        
            -- In SEG not in RFR: new RFR segments

			-- First check if we are going to insert duplicates
			SELECT @countDuplicates = count(1) FROM (
				SELECT
					uwx.SGTTGT_LS AS COL_LS,
					gmt.SGMT_LS AS COLVAL_CT,
					SUBSTRING (gmt.SGMT_LL,
							   1,
							   16) AS COLVAL_LS
				FROM
					BREF..TBANCOD cod
                    INNER JOIN
                    best..tuwexport uwx
					ON
						cod.COL_LS = uwx.SGTTGT_LS
					INNER JOIN
					BEST..TSEGTYPE typ
					ON
						typ.SGTTYP_NT = uwx.SGTTYP_NT AND
						typ.SGTSCOPE_CT = uwx.SGTSCOPE_CT
					INNER JOIN
					BEST..TSEGMENTATION seg
					ON
						seg.SGTTYP_NT = typ.SGTTYP_NT
					INNER JOIN
					BEST..TSEGMT gmt
					ON
						gmt.SGT_NT = seg.SGT_NT AND
						gmt.SGTVER_NT = seg.SGTVER_NT AND
						gmt.SGTLVL_NT = uwx.SGTLVL_NT
				WHERE
                    cod.TECCOD_B = 1 AND
                    seg.SGTSTS_CF = @SEGSTS_ACTIVE AND
					typ.SGTTYP_NT = @p_sgttyp_nt AND
                    rtrim(typ.SGTMGTLVL_CT) = @GROUP_MGT AND
					NOT EXISTS (SELECT 1
								FROM bref..tbantecl rfr
								WHERE
									rfr.LAG_CF = @lang AND
									rfr.COL_LS = uwx.SGTTGT_LS AND
									rfr.COLVAL_CT = gmt.SGMT_LS)
				GROUP BY
					uwx.SGTTGT_LS,
					gmt.SGMT_LS,
					SUBSTRING (gmt.SGMT_LL,
							   1,
							   16)
				HAVING COUNT (1) > 1
			) r
			
			IF @countDuplicates > 0
			BEGIN
				SELECT @erreur = 19
				SELECT @p_erreur = "20019 SEGMENTATION;" + CONVERT (VARCHAR (10), @erreur) + ";" 
				GOTO fin
			END
			
			-- Insert in TBANTEC if not existing yet
            INSERT
                INTO
                    BREF..TBANTEC
                    (
                        COL_LS,
                        COLVAL_CT,
                        ACTCOD_B,
                        LSTUPDUSR_CF
                    )
                SELECT
                    uwx.SGTTGT_LS AS COL_LS,
                    gmt.SGMT_LS AS COLVAL_CT,
                    1 AS ACTCOD_B,
                    SUSER_NAME () AS LSTUPDUSR_CF
                FROM
					BREF..TBANCOD cod
                    INNER JOIN
                    best..tuwexport uwx
					ON
						cod.COL_LS = uwx.SGTTGT_LS
                    INNER JOIN
                    BEST..TSEGTYPE typ
                    ON
                        typ.SGTTYP_NT = uwx.SGTTYP_NT AND
                        typ.SGTSCOPE_CT = uwx.SGTSCOPE_CT
                    INNER JOIN
                    BEST..TSEGMENTATION seg
                    ON
                        seg.SGTTYP_NT = typ.SGTTYP_NT
                    INNER JOIN
                    BEST..TSEGMT gmt
                    ON
                        gmt.SGT_NT = seg.SGT_NT AND
                        gmt.SGTVER_NT = seg.SGTVER_NT AND
                        gmt.SGTLVL_NT = uwx.SGTLVL_NT
                WHERE
                    cod.TECCOD_B = 1 AND
                    seg.SGTSTS_CF = @SEGSTS_ACTIVE AND
                    typ.SGTTYP_NT = @p_sgttyp_nt AND
                    rtrim(typ.SGTMGTLVL_CT) = @GROUP_MGT AND
                    NOT EXISTS (SELECT 1
                                FROM bref..tbantec rfr
                                WHERE
                                    rfr.COL_LS = uwx.SGTTGT_LS AND
                                    rfr.COLVAL_CT = gmt.SGMT_LS)

			-- Insert new codes
			-- Nothing to do if the tech code is not defined (join on TBANCOD)
            INSERT
                INTO
                    BREF..TBANTECL
                    (
                        LAG_CF,
                        COL_LS,
                        COLVAL_CT,
                        COLVAL_LM,
                        COLVAL_LS,
                        LSTUPDUSR_CF
                    )
                SELECT
                    @lang AS LAG_CF,
                    uwx.SGTTGT_LS AS COL_LS,
                    gmt.SGMT_LS AS COLVAL_CT,
                    SUBSTRING (gmt.SGMT_LL,
                               1,
                               16) AS COLVAL_LS,
                    gmt.SGMT_LL AS COLVAL_LM,
                    SUSER_NAME () AS LSTUPDUSR_CF
                FROM
					BREF..TBANCOD cod
                    INNER JOIN
                    best..tuwexport uwx
					ON
						cod.COL_LS = uwx.SGTTGT_LS
                    INNER JOIN
                    BEST..TSEGTYPE typ
                    ON
                        typ.SGTTYP_NT = uwx.SGTTYP_NT AND
                        typ.SGTSCOPE_CT = uwx.SGTSCOPE_CT
                    INNER JOIN
                    BEST..TSEGMENTATION seg
                    ON
                        seg.SGTTYP_NT = typ.SGTTYP_NT AND
                        seg.SGTSTS_CF = '3'
                    INNER JOIN
                    BEST..TSEGMT gmt
                    ON
                        gmt.SGT_NT = seg.SGT_NT AND
                        gmt.SGTVER_NT = seg.SGTVER_NT AND
                        gmt.SGTLVL_NT = uwx.SGTLVL_NT
                WHERE
                    cod.TECCOD_B = 1 AND
                    typ.SGTTYP_NT = @p_sgttyp_nt AND
                    rtrim(typ.SGTMGTLVL_CT) = @GROUP_MGT AND
                    NOT EXISTS (SELECT 1
                                FROM bref..tbantecl rfr
                                WHERE
                                    rfr.LAG_CF = @lang AND
                                    rfr.COL_LS = uwx.SGTTGT_LS AND
                                    rfr.COLVAL_CT = gmt.SGMT_LS)
        
            -- Handle errors on new RFR segments
            SELECT
                @erreur = @@error,
                @nbligne = @@rowcount
            
            IF @@transtate = 2
                BEGIN
                    SELECT @p_erreur = "ERREUR TRIGGER"
                    GOTO fin
                END
            
            IF @erreur != 0
                BEGIN
                    SELECT @p_erreur = "20001 APPLICATIF;" + CONVERT (VARCHAR (10),
                                                                      @erreur) + ";"
                    GOTO fin
                END
        
            /* In RFR not in SEG: Not to do. Unmatched codes should be kept */
        end

        fetch lang_c into @lang
    end
    
    close lang_c

    IF @tran_imbr = 0
        COMMIT TRAN

    RETURN @erreur

    fin:
    close lang_c

    IF @tran_imbr = 0
        ROLLBACK TRAN

    RETURN @erreur
go

EXEC sp_procxmode 'dbo.PtSEGLBLTORFR_01', 'unchained'
go
IF OBJECT_ID('dbo.PtSEGLBLTORFR_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtSEGLBLTORFR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtSEGLBLTORFR_01 >>>'
go

GRANT EXECUTE ON dbo.PtSEGLBLTORFR_01 TO GOMEGA
go
