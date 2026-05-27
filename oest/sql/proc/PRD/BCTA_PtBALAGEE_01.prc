use BCTA
go
/*
 * DROP PROC PtBALAGEE_01   
 */
IF OBJECT_ID('PtBALAGEE_01') IS NOT NULL
BEGIN
    DROP PROC PtBALAGEE_01
    PRINT '<<< DROPPED PROC PtBALAGEE_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtBALAGEE_01
     (
	@p_DATE_T   		datetime,  	/* closing date  ( date production )*/
	@p_FORCE_DTE 	varchar(8),  /* closing date ( date user )*/
	@p_listssd		char(40) 	/* liste des filiales à prendre en compte ou 99 pour toutes les filiales*/
     )
with execute as caller as

/***************************************************

Programme: PtBALAGEE_01

Fichierscript associé : BALAGEE1.prc

Base principale : BCTA

Version: 1

Auteur: van de velde 

Date de creation: 23/10/98

Description du programme: 

Extraction des donnees necessaire a la constitution de la table TDEBCRED

Parametres: 
		@p_DATE_T         datetime,
		@p_FORCE_DTE      varchar(8),
		@p_listssd		char(40)

Conditions d'execution: 

Batch asynchrone

Commentaires:
Cas ou la periode saisie correspond a un mois anterieur au mois courant,
le tiers reglement est complet, le domaine est compense.      
Sélection des RES uniquement si elles sont définitives
_____________________________________________________
MODIFICATION  1
Auteur: van de velde 
Date:	16/12/98		  	
Version:    001
Description:		- 1 - Ajout de l'établissement dans les jointures .
		  	        - 2 - Prise en compte du paramètre FORCE_DTE si égal à null ou blanc
 			          - 3 - 29/06/1999 - modif jointure sur filiale pour le 1 er select	  

_____________________________________________________
MODIFICATION  2
Auteur: van de velde 
Date:	20/02/06		  	
Version:    002
Description:		aménagement pour le déclenchement de la balance 
                le paramétre @p_DATE_T contient la date de cloture (ssaamm30, ssaamm31 ou ssaamm28)
----------------------------------------------------------------------
Modification - Removed dbo and added ‘with execute as caller as’
*****************************************************/
/*----------------*/
/* Initialization */
/*----------------*/

declare
		@erreur		int,
		@dte			datetime,
       	@tran_imbr		bit,
		@datarret		datetime,
		@mth			tinyint,
		@mth_nf		tinyint,
		@yea_nf		smallint,
		@RetourProc		int,
		@p_FORCE_DTE_OK	varchar(8)

	
select  @erreur = 0
select  @tran_imbr = 1

/*-----------------------*/
/*update clothing date  */
/*----------------------*/


IF @p_FORCE_DTE = " " or @p_FORCE_DTE = "null"

--********************
-- treatment of DATE_T
--******************** 			 
	BEGIN 
  select @datarret =  convert(char(8),@p_DATE_T,112)
/**** modif 002
	select @dte 		= convert(char(8),@p_DATE_T,112)
	select @mth_nf 	= datepart(mm,@dte)	--selected month of DATE_T
	select @yea_nf 	= datepart(yy,@dte)	--selected year of DATE_T
	select @mth_nf 	= @mth_nf - 1
	IF @mth_nf = 0
	   Begin
	   select @mth_nf 	= 12
	   select @yea_nf 	= @yea_nf - 1
	   end	
***/
	END

ELSE
	BEGIN
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

	-- Création de la table  temporaire des filiales demandées 
	-- *******************************************************


CREATE TABLE #TLSTSSD ( SSD_CF 		USSD_CF 	NOT NULL )

IF OBJECT_ID('#TLSTSSD') IS NOT NULL
    PRINT '<<< CREATED TABLE #TLSTSSD >>>'
ELSE
  begin
    PRINT '<<< FAILED CREATING TABLE #TLSTSSD >>>'
  end

exec @RetourProc=BREF..PtUTILSTSSD_01 @p_listssd

if @@error<>0 or @RetourProc<>0 return
-- les filiales sont maintenant dans #TLSTSSD


-- create en commentaire --
/*CREATE TABLE BTRAV..TBRGLBALAGEE(
		SSD_CF		USSD_CF 		NULL,
		ESB_CF		UESB_CF 		NULL, 
		CPY_NF		UCLI_NF 		NULL,
		BRK_NF		UCLI_NF 		NULL,
		PAY_NF		UCLI_NF 		NULL,
		KEY_CF		UKEY_CF		NULL,
		TRNCOD_CF	UDETTRS_CF		NULL,
		TRA_NF		INT			NULL,
		CUR_CF		UCUR_CF 		NULL,
		AMTLFT_M	UAMT_M 		NOT NULL,
		AMTCV_M	UAMT_M 		NULL,
		AMTSSD_M	UAMT_M 		NULL,
		AMTESB_M	UAMT_M 		NULL,
		BALSHT_D	datetime		not NULL,
		PCR_CF		CHAR(8)		NULL,
		NBRJOUR	INT			not NULL, 
		DMN_CT		USTLBAN_CT		not NULL
           )

*/

/*---------------------------------------------------------------*/
/*  DELETE du contenu de la table TBRGLBALAGEE avant chargement  */
/*---------------------------------------------------------------*/

DELETE BTRAV..TBRGLBALAGEE



/*---------------------------------------------------------*/
/*Add the values FROM BCTA..TCURTRS to  BTRAV..TBRGLBALAGEE*/
/*---------------------------------------------------------*/

INSERT INTO BTRAV..TBRGLBALAGEE
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
		"",
           	0,
		T1.DMN_CT


FROM BCTA..TCURTRS T1, 
     BCTA..TTRSHTZ T7

WHERE 
   T1.PSTTRS_B =1
  AND convert(char(8),T1.BALSHT_D,112) <= @datarret
  AND T1.SSD_CF IN ( select SSD_CF FROM #TLSTSSD )   -- sélection des filiales paramétrées
  AND T7.SSD_CF  = T1.SSD_CF
  AND T1.ESB_CF = 	T7.ESB_CF
  AND T7.TPPTRS_NF = T1.TPPTRS_NF
  AND	convert(char(8),T7.MODIF_D,112) <= @datarret
  AND T1.TRSTYP_CT != '1' 
  AND T7.MODIF_D = (SELECT MAX(T20.MODIF_D) 
      				FROM BCTA..TTRSHTZ T20
       			WHERE  convert(char(8),T20.MODIF_D,112) < @datarret
				AND   T7.SSD_CF 	= 	T20.SSD_CF 
			--	AND	T20.SSD_CF in ( select SSD_CF FROM #TLSTSSD ) modif 29/06/99   
				AND 	T7.ESB_CF 	= 	T20.ESB_CF
           			AND   T7.TPPTRS_NF = 	T20.TPPTRS_NF)  
  AND T7.AMTLFT_M != 0


SELECT @erreur = @@error
   IF @erreur != 0
   BEGIN
     raiserror 20010 "ERROR IN THE REQUEST"/* erreur de selection */
     goto fin
   END

/* MODIF1*/

INSERT INTO BTRAV..TBRGLBALAGEE
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
		"",
           	0,
		T1.DMN_CT

FROM BCTA..TCURTRS T1, 
     BCTA..TTRSHTZ T7 
     

WHERE 
      T1.SSD_CF IN ( select  SSD_CF FROM #TLSTSSD )   -- sélection des filiales paramétrées
  AND T1.PSTTRS_B =1
  AND convert(char(8),T1.BALSHT_D,112) <= @datarret
  AND T7.SSD_CF = T1.SSD_CF
  AND T7.ESB_CF = T1.ESB_CF	
  AND T7.TPPTRS_NF = T1.TPPTRS_NF
  AND	convert(char(8),T7.MODIF_D,112) <= @datarret
  AND T7.MODIF_D = (SELECT MAX(T20.MODIF_D) 
			     FROM BCTA..TTRSHTZ T20
         			WHERE convert(char(8), T20.MODIF_D,112) <= @datarret
				AND   T7.SSD_CF	= T20.SSD_CF
				AND 	T7.ESB_CF    = T20.ESB_CF   
        			AND   T7.TPPTRS_NF = T20.TPPTRS_NF) 
  
  AND T1.TRSTYP_CT = '1'
  AND T7.AMTLFT_M != 0
	
SELECT @erreur = @@error
   IF @erreur != 0
   BEGIN
     raiserror 20010 "ERROR IN THE REQUEST"/* erreur de selection */
     goto fin
   END

/*---------------------------------------------------------*/
/*  Add the values FROM BCTA..TBRKTRS to #TBRGLBALAGEE   */
/*---------------------------------------------------------*/

INSERT INTO BTRAV..TBRGLBALAGEE

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
		"",
           	0,
		T1.DMN_CT

FROM BCTA..TBRKTRS T1, 
     BCTA..TTRSHTZ T7

WHERE  T1.SSD_CF IN ( select  SSD_CF FROM #TLSTSSD )   -- sélection des filiales paramétrées
  AND T1.PSTTRS_B = 1
  AND (convert(char(8),T1.CAN_D,112) > @datarret OR   T1.CAN_D = NULL)
  AND convert(char(8),T1.BALSHT_D,112) <= @datarret
  AND T1.ESB_CF = T7.ESB_CF	
  AND T7.SSD_CF = T1.SSD_CF
  AND T7.TPPTRS_NF = T1.TPPTRS_NF
  AND	convert(char(8),T7.MODIF_D,112) <= @datarret
  AND T1.TRSTYP_CT != '1'  
  AND T7.MODIF_D= (SELECT MAX(T20.MODIF_D) 
			     FROM   BCTA..TTRSHTZ T20
       		     WHERE	convert(char(8),T20.MODIF_D,112)<= @datarret
				AND   T20.SSD_CF	= T7.SSD_CF
				AND	T20.ESB_CF	= T7.ESB_CF
				AND	T7.TPPTRS_NF	 = T20.TPPTRS_NF)

 AND	T7.AMTLFT_M	!= 0
 
SELECT @erreur = @@error
 IF @erreur!= 0
 BEGIN
      raiserror 20002 "ERROR IN THE REQUEST"/* erreur de selection */
      goto fin
   END

  
INSERT INTO BTRAV..TBRGLBALAGEE

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
		"",
           	0,
		T1.DMN_CT

FROM BCTA..TBRKTRS T1, 
     BCTA..TTRSHTZ T7 
     
WHERE 
	T1.SSD_CF IN ( select  SSD_CF FROM #TLSTSSD )   -- sélection des filiales paramétrées 
  AND T1.PSTTRS_B 	= 1
  AND (convert(char(8),T1.CAN_D,112) > @datarret   OR   T1.CAN_D = NULL)
  AND convert(char(8),T1.BALSHT_D,112)<= @datarret
  AND T7.SSD_CF 	= T1.SSD_CF
  AND T7.ESB_CF	= T1.ESB_CF	
  AND T7.TPPTRS_NF	= T1.TPPTRS_NF
  AND	convert(char(8),T7.MODIF_D,112)	<= @datarret
  AND T7.MODIF_D	= (SELECT MAX(T20.MODIF_D) 
      				FROM   BCTA..TTRSHTZ T20
        			 WHERE  	convert(char(8),T20.MODIF_D,112) <= @datarret
					AND	T20.SSD_CF    = T7.SSD_CF
					AND	T20.ESB_CF	  = T7.ESB_CF	
					AND   	T7.TPPTRS_NF  = T20.TPPTRS_NF) 
  AND T1.TRSTYP_CT	= '1'
  AND T7.AMTLFT_M 	!= 0	  	

DROP TABLE #TLSTSSD

SELECT @erreur = @@error
 IF @erreur!= 0
   BEGIN
      raiserror 20002 "ERROR IN THE REQUEST" 
      goto fin
   END


if @tran_imbr = 0
   COMMIT TRAN

RETURN 0

fin:
if @tran_imbr = 0
begin

	ROLLBACK TRAN
end
 RAISERROR 20020 "Procedure PtBALAGEE_01 has failed"
return 1
go

IF OBJECT_ID('PtBALAGEE_01') IS NOT NULL
    PRINT '<<< CREATED PROC PtBALAGEE_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtBALAGEE_01 >>>'
go

/*
 * Granting/Revoking Permissions on PtBALAGEE_01
 */
GRANT EXECUTE ON PtBALAGEE_01  TO GOMEGA
go
