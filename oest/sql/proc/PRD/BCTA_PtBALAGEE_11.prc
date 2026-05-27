use BCTA
go

--* DROP PROC PtBALAGEE_11

IF OBJECT_ID('PtBALAGEE_11') IS NOT NULL
begin
    DROP PROC PtBALAGEE_11
    PRINT '<<< DROPPED PROC PtBALAGEE_11 >>>'
end
go

-- création de la procédure

create procedure PtBALAGEE_11
     (
	@p_DATE_T   	datetime,   -- closing date  ( date production )
	@p_FORCE_DTE 	varchar(8), -- closing date ( date user )
	@p_listssd		char(40) 	  -- liste des filiales à prendre en compte ou 99 pour toutes les filiales
     )
with execute as caller as

/***************************************************

Programme: PtBALAGEE_11
Fichierscript associé : bcta_PtBALAGEE_11.prc
Base principale : BCTA
Version: 1
Auteur: van de velde
Date de creation: 05/02/2008
Description du programme:

        Extraction des donnees nécessaire à la constitution de la table bsta..TDEBCRED
        données extraites en fonction de la date du document différenciées par la variable LOCAL_CF =1

Parametres:
		@p_DATE_T     datetime,
		@p_FORCE_DTE  varchar(8),
		@p_listssd		char(40)

Conditions d'execution:
Batch asynchrone

Commentaires:
Cas ou la période saisie correspond à un mois antérieur au mois courant,le tiers réglement est complet, le domaine est compensé.
Sélection des RES uniquement si elles sont définitives.
Le paramétre @p_DATE_T contient la date de cloture sous la forme ssaamm30, ssaamm31 ou ssaamm28.
Pour les RES uniquement (TRSTYP_CT =1), on prend la date du document (DOC_D) à la place de la date bilan (pour le calcul de la tranche d'âge)
------------------------------------------------------------------------
Modification - Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare
		@dte			datetime,
    @errmsg     varchar,
    @errno      int,
		@datarret		datetime,
		@mth			tinyint,
		@mth_nf		tinyint,
		@yea_nf		smallint,
		@RetourProc		int,
		@p_FORCE_DTE_OK	varchar(8),
    @RetourProc1 int


-- initialisation

select  @RetourProc = 0
select  @RetourProc1 = 0

-- Chargement des filiales en table #TLSTSSD
--==================================

CREATE TABLE #TLSTSSD
             ( SSD_CF 		USSD_CF 	NOT NULL )

exec @RetourProc1 = bref..PtUTILSTSSD_01
                    @p_listssd

if @@error <> 0 or @RetourProc1 <> 0 return

------------------------
-- update clothing date
------------------------

IF @p_FORCE_DTE = '' or @p_FORCE_DTE = 'null'
  begin
  print 'treatment of DATE_T'
  select @datarret =  convert(char(8),@p_DATE_T,112)
	end

ELSE
	begin
	print 'treatment FORCE_DTE'
  select @p_FORCE_DTE_OK = convert(char(8),@p_FORCE_DTE,112)
	select @dte 		= @p_FORCE_DTE_OK
	select @mth_nf	= datepart(mm,@dte)	--selected month
	select @yea_nf	= datepart(yy,@dte)	--selected year
	IF ( @mth_nf = 12)
    	begin
	      select @mth=1
	      select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),(@yea_nf+1)*10000+@mth*100+01,102)))
      end
  else
	      select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),@yea_nf*10000+(@mth_nf+1)*100+01,102)))
END

PRINT '--  DELETE de la table TBRGLBALAGEE'
DELETE btrav..TBRGLBALAGEE

PRINT ''
PRINT 'Début BEGIN Tran'
BEGIN Tran

PRINT '-A- Add the values FROM bcta..TCURTRS to  btrav..TBRGLBALAGEE'
------------------------------------------------------------

PRINT ' A1 - Type d''écriture: Autres que des RES'
INSERT INTO btrav..TBRGLBALAGEE
          (
		SSD_CF,
		ESB_CF,
    CPY_NF,
    BRK_NF,
    PAY_NF,
    KEY_CF,
		TRNCOD_CF,
		TRA_NF,
		CUR_CF,
		AMTLFT_M,
		AMTCV_M,
		AMTSSD_M,
		AMTESB_M,
    BALSHT_D,
		PCR_CF,
		NBRJOUR,
    DMN_CT
			)
SELECT
    T1.SSD_CF,
		T1.ESB_CF,
		T1.CPY_NF,
    T1.BRK_NF,
	  T1.PAY_NF,
    T1.KEY_CF,
    T1.TRNCOD1_CF,
		0,
		T1.CUR_CF,
   	T7.AMTLFT_M,
		0,
		0,
		0,
    convert(char(6), T1.BALSHT_D,12),
		'',
    0,
		T1.DMN_CT

FROM bcta..TCURTRS T1,
     bcta..TTRSHTZ T7
WHERE
    T1.PSTTRS_B   = 1
AND T1.SSD_CF   in (SELECT SSD_CF FROM #TLSTSSD) 	-- sélection de la filiale paramétrée
AND T1.TRSTYP_CT != '1'
AND T7.AMTLFT_M  != 0
AND T7.SSD_CF     = T1.SSD_CF
AND T1.ESB_CF     = T7.ESB_CF
AND T7.TPPTRS_NF  = T1.TPPTRS_NF
AND convert(char(8),T1.BALSHT_D,112) <= @datarret
AND	convert(char(8),T7.MODIF_D,112) <= @datarret
AND T7.MODIF_D = (
                    SELECT MAX(T20.MODIF_D)
      				      FROM bcta..TTRSHTZ T20
       			        WHERE  convert(char(8),T20.MODIF_D,112) < @datarret
				            AND   T7.SSD_CF 	 = 	T20.SSD_CF
				            AND 	T7.ESB_CF 	 = 	T20.ESB_CF
   			            AND   T7.TPPTRS_NF = 	T20.TPPTRS_NF
                   )
IF @@error != 0
   begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; btrav..TBRGLBALAGEE - A1 : ' + convert(varchar(10),@@error) + ';'
      goto ERR
   end

PRINT ' A2 - Type d''écriture: RES uniquement'
--------------------------------------------
INSERT INTO btrav..TBRGLBALAGEE
          (
		SSD_CF,
		ESB_CF,
   	CPY_NF,
   	BRK_NF,
   	PAY_NF,
   	KEY_CF,
		TRNCOD_CF,
		TRA_NF,
		CUR_CF,
		AMTLFT_M,
		AMTCV_M,
		AMTSSD_M,
		AMTESB_M,
   	BALSHT_D,
		PCR_CF,
		NBRJOUR,
   	DMN_CT
			)

SELECT
 		tcurtrs.SSD_CF,
		tcurtrs.ESB_CF,
		tcurtrs.CPY_NF,
   	tcurtrs.BRK_NF,
   	tcurtrs.PAY_NF,
   	tcurtrs.KEY_CF,
   	tcurtrs.TRNCOD1_CF,
		0,
		tcurtrs.CUR_CF,
   	ttrshtz.AMTLFT_M,
		0,
		0,
		0,
   	convert(char(6), tdoc.DOC_D,12),    -- convert(char(6), tcurtrs.BALSHT_D,12),
		'',
    0,
		tcurtrs.DMN_CT

FROM bcta..TCURTRS tcurtrs,
     bcta..TTRSHTZ ttrshtz,
     bcta..TDOC tdoc,
     bcta..TREB treb

WHERE
      tcurtrs.SSD_CF  in (SELECT  SSD_CF FROM #TLSTSSD) 	-- sélection de la filiale paramétrée
  AND tcurtrs.PSTTRS_B  = 1
  AND ttrshtz.SSD_CF    = tcurtrs.SSD_CF
  AND ttrshtz.ESB_CF    = tcurtrs.ESB_CF
  AND ttrshtz.TPPTRS_NF = tcurtrs.TPPTRS_NF
  AND tcurtrs.TRSTYP_CT = '1'
  AND ttrshtz.AMTLFT_M != 0
  AND	convert(char(8),ttrshtz.MODIF_D,112) <= @datarret
  AND convert(char(8),tcurtrs.BALSHT_D,112) <= @datarret
  AND ttrshtz.MODIF_D = (
                    SELECT MAX(ttrshtz1.MODIF_D)
			              FROM bcta..TTRSHTZ ttrshtz1
         			      WHERE convert(char(8), ttrshtz1.MODIF_D,112) <= @datarret
				            AND   ttrshtz.SSD_CF	   = ttrshtz1.SSD_CF
				            AND 	ttrshtz.ESB_CF    = ttrshtz1.ESB_CF
        			      AND   ttrshtz.TPPTRS_NF = ttrshtz1.TPPTRS_NF
                    )
-- jointure pour récupération de la date du documment pour une RES
and treb.ssd_cf    = tcurtrs.ssd_cf
and treb.esb_cf    = tcurtrs.esb_cf
and treb.reb_nf    = tcurtrs.nbr_nf

and treb.ssd_cf    = tdoc.ssd_cf
and treb.esb_cf    = tdoc.esb_cf
and treb.docnbr_nf = tdoc.docnbr_nf

IF @@error != 0
   begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; btrav..TBRGLBALAGEE - A2 : ' + convert(varchar(10),@@error) + ';'
      goto ERR
   end


PRINT '-B- Add the values FROM bcta..TBRKTRS to btrav..TBRGLBALAGEE'
-------------------------------------------------------------

PRINT ' B1 - Type d''écriture: Autres que RES'
--------------------------------------------
INSERT INTO btrav..TBRGLBALAGEE
    (
		SSD_CF,
		ESB_CF,
    CPY_NF,
    BRK_NF,
    PAY_NF,
    KEY_CF,
		TRNCOD_CF,
		TRA_NF,
		CUR_CF,
		AMTLFT_M,
		AMTCV_M,
		AMTSSD_M,
		AMTESB_M,
    BALSHT_D,
		PCR_CF,
		NBRJOUR,
    DMN_CT
		)

SELECT
    T1.SSD_CF,
		T1.ESB_CF,
		T1.CPY_NF,
    T1.BRK_NF,
	  T1.PAY_NF,
    T1.KEY_CF,
    T1.TRNCOD1_CF,
		0,
		T1.CUR_CF,
	  T7.AMTLFT_M,
		0,
		0,
		0,
    convert(char(6), T1.BALSHT_D,12),
		'',
    0,
		T1.DMN_CT

FROM bcta..TBRKTRS T1,
     bcta..TTRSHTZ T7

WHERE
    T1.SSD_CF IN (SELECT  SSD_CF FROM #TLSTSSD) 	-- sélection des filiales paramétrées
AND T1.PSTTRS_B   = 1
AND T1.TRSTYP_CT != '1'
AND T1.ESB_CF     = T7.ESB_CF
AND T7.SSD_CF     = T1.SSD_CF
AND	T7.AMTLFT_M	 != 0
AND T7.TPPTRS_NF  = T1.TPPTRS_NF
AND (convert(char(8),T1.CAN_D,112) > @datarret OR   T1.CAN_D = NULL)
AND convert(char(8),T1.BALSHT_D,112) <= @datarret
AND	convert(char(8),T7.MODIF_D,112) <= @datarret
AND T7.MODIF_D= (
                 SELECT MAX(T20.MODIF_D)
      			     FROM   bcta..TTRSHTZ T20
         		     WHERE	convert(char(8),T20.MODIF_D,112)<= @datarret
				         AND  T20.SSD_CF	 = T7.SSD_CF
				         AND	T20.ESB_CF	 = T7.ESB_CF
				         AND	T7.TPPTRS_NF = T20.TPPTRS_NF
                )

IF @@error!= 0
  begin
      select @errno = 20020 ,
            @errmsg = '20020 BATCH; btrav..TBRGLBALAGEE - B1 : ' + convert(varchar(10),@@error) + ';'
      goto ERR
  end

PRINT ' B2 - Type d''écriture: RES uniquement'
------------------------------------------------
INSERT INTO btrav..TBRGLBALAGEE

    (
		SSD_CF,
		ESB_CF,
   	CPY_NF,
   	BRK_NF,
   	PAY_NF,
   	KEY_CF,
		TRNCOD_CF,
		TRA_NF,
		CUR_CF,
		AMTLFT_M,
		AMTCV_M,
		AMTSSD_M,
		AMTESB_M,
   	BALSHT_D,
		PCR_CF,
		NBRJOUR,
   	DMN_CT
   	)

SELECT
   	tbrktrs.SSD_CF,
		tbrktrs.ESB_CF,
		tbrktrs.CPY_NF,
   	tbrktrs.BRK_NF,
	 	tbrktrs.PAY_NF,
   	tbrktrs.KEY_CF,
   	tbrktrs.TRNCOD1_CF,
		0,
		tbrktrs.CUR_CF,
	 	ttrshtz.AMTLFT_M,
		0,
		0,
		0,
   	convert(char(6), tdoc.DOC_D,12),    -- convert(char(6), tbrktrs.BALSHT_D,12),
		'',
    0,
		tbrktrs.DMN_CT

FROM bcta..TBRKTRS tbrktrs,
     bcta..TTRSHTZ ttrshtz,
     bcta..TDOC tdoc,
     bcta..TREB treb
WHERE
	  tbrktrs.SSD_CF    IN (SELECT  SSD_CF FROM #TLSTSSD) 	-- sélection des filiales paramétrées
AND tbrktrs.PSTTRS_B  = 1
AND ttrshtz.SSD_CF 	  = tbrktrs.SSD_CF
AND ttrshtz.ESB_CF	  = tbrktrs.ESB_CF
AND tbrktrs.TRSTYP_CT = '1'
AND ttrshtz.AMTLFT_M != 0
AND ttrshtz.TPPTRS_NF = tbrktrs.TPPTRS_NF
AND (convert(char(8),tbrktrs.CAN_D,112) > @datarret   OR   tbrktrs.CAN_D = NULL)
AND convert(char(8),tbrktrs.BALSHT_D,112)<= @datarret
AND	convert(char(8),ttrshtz.MODIF_D,112)	<= @datarret
AND ttrshtz.MODIF_D	= (
                    SELECT MAX(ttrshtz1.MODIF_D)
      				      FROM   bcta..TTRSHTZ ttrshtz1
        			      WHERE  	convert(char(8),ttrshtz1.MODIF_D,112) <= @datarret
					          AND	ttrshtz1.SSD_CF    = ttrshtz.SSD_CF
					          AND	ttrshtz1.ESB_CF	   = ttrshtz.ESB_CF
					          AND ttrshtz1.TPPTRS_NF = ttrshtz.TPPTRS_NF
                    )
-- jointure pour récupération de la date du documment pour une RES
and treb.ssd_cf    = tbrktrs.ssd_cf
and treb.esb_cf    = tbrktrs.esb_cf
and treb.reb_nf    = tbrktrs.nbr_nf

and treb.ssd_cf    = tdoc.ssd_cf
and treb.esb_cf    = tdoc.esb_cf
and treb.docnbr_nf = tdoc.docnbr_nf

IF @@error!= 0
   begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; btrav..TBRGLBALAGEE - B2 : ' + convert(varchar(10),@@error) + ';'
      goto ERR
   end

PRINT 'COMMIT Tran'
COMMIT tran
return 0

ERR:
   PRINT 'ROLLBACK tran'
   raiserror @errno @errmsg
   ROLLBACK TRAN PtBALAGEE_11
   return @errno
go

IF OBJECT_ID('PtBALAGEE_11') IS NOT NULL
    PRINT '<<< CREATED PROC PtBALAGEE_11 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtBALAGEE_11 >>>'

go

-- Granting/Revoking Permissions on PtBALAGEE_11

GRANT EXECUTE ON PtBALAGEE_11  TO GOMEGA
go
