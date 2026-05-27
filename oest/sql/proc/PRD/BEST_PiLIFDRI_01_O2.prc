/** Alter Procedure Script **/

USE BEST
GO

IF OBJECT_ID('dbo.PiLIFDRI_01_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PiLIFDRI_01_O2
  IF OBJECT_ID('dbo.PiLIFDRI_01_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE BEST..PiLIFDRI_01_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE BEST..PiLIFDRI_01_O2 >>>'
END
GO

/*
 * creation de la procedure
*/

create procedure dbo.PiLIFDRI_01_O2
     (
       @p_acy_nf        smallint,
       @p_balshey_nf    smallint,
       @p_balshtmth_nf  tinyint,
       @p_ctr_nf        UCTR_NF,
       @p_end_nt        UEND_NT,
       @p_sec_nf        USEC_NF,
       @p_uw_nt         UUW_NT,
       @p_uwy_nf        UUWY_NF,
       @p_autupd_b      bit,
       @p_cmt_nt        UCMT_NT,
       @p_comacc_b      bit,
       @p_creusr_cf     UUPDUSR_CF,
       @p_lstupd_d      UUPD_D=NULL output,
       @p_lstupdusr_cf  UUPDUSR_CF=NULL output,
       @p_ssd_cf        USSD_CF,
       @p_erreur	      varchar(64)=NULL output,
	     @p_respropag_b   bit,
	     @p_segupd_b 	    bit  = 0,	--modif 06	
       @p_isAutUpdMngt  bit  = 0  --Modif 07
     )
as

/***************************************************

Programme: PiLIFDRI_01_O2

Fichier script associ? : ESIDRI01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation:

Description du programme:

      Insertion d'enregistrement dans TLIFDRI

Parametres:
       @p_acy_nf              smallint,
       @p_balshey_nf          smallint,
       @p_balshtmth_nf        tinyint,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_autupd_b            bit,
       @p_cmt_nt              UCMT_NT,
       @p_comacc_b            bit,
       @p_creusr_cf           UUPDUSR_CF,
       @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
       @p_ssd_cf              USSD_CF,
       @p_erreur	varchar(64)=NULL output,
	   @p_respropag_b  bit	

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:         G. Buisson

Date:           05/01/2004

Version:

Description:    On force la filiale avec les 2 premiers caracteres
                du contrat (probleme du a la filialisation vie)
				
MODIFICATION 2

Auteur:         A. Deshpande

Date:           08/07/2014

Version:

Description:    Added respropag_b for EST 22 evo card


MODIFICATION 3

Auteur:         A. Deshpande

Date:           16/10/2014

Version:

Description:    Changes for spira #031392 (change type of respropag_b to bit)


MODIFICATION 4

Auteur:         sumit Gupta

Date:           16/01/2015

Version:

Description:    Changes done when contracts start with 'TR'

MODIFICATION 5

Auteur:         Amit Deshpande

Date:           23/05/2015

Version:

Description:    Changes done when contracts start with 'TR'				

MODIFICATION 6

Auteur:         Amit Deshpande

Date:           25/05/2015

Version:

Description:    Added changes for EST LIF 39 - SEGUPD_B		
________________________________________________________________________
Modification : 7
------------
Aothor       : Lagha Bealid.
Date         : 27/06/2019.
Description  : Insert new line in TLIFDIR only if "Auto Update" indicator
state is changing or if is the first comment to add.
              
*****************************************************/

declare @erreur int,
        @tran_imbr  bit,
        @ssd_cf USSD_CF,
        @cmt_nt_v0 UCMT_NT,        -- MOD 7
        @p_autupd_b_v0 bit,        -- MOD 7
        @LSTUPD_D datetime,        -- MOD 7
        @CRE_D datetime           -- MOD 7

-------------------------------------------------------------
--                      MOD 7 - Begin                      --
-------------------------------------------------------------
-- get the last values of cmt_nt and autupd_b befor update --
-------------------------------------------------------------

SELECT
  @cmt_nt_v0     = T1.CMT_NT,
  @p_autupd_b_v0 = T1.AUTUPD_B,
  @LSTUPD_D      = T1.LSTUPD_D,
  @CRE_D         = T1.CRE_D
FROM BEST..TLIFDRI T1
INNER JOIN
(SELECT CTR_NF, ACY_NF, AUTUPD_B, CMT_NT, LSTUPD_D  , CMT_NT , AUTUPD_B , CRE_D 
  FROM   BEST..TLIFDRI
  WHERE    CTR_NF        = @p_ctr_nf
    AND    END_NT        = @p_end_nt
    AND    SEC_NF        = @p_sec_nf
    AND    UWY_NF        = @p_uwy_nf
    AND    UW_NT         = @p_uw_nt
    AND    ACY_NF        = @p_acy_nf
    AND    BALSHEY_NF    = @p_balshey_nf 
    AND    BALSHTMTH_NF <= @p_balshtmth_nf
 ) T2
ON       T1.CTR_NF        = @p_ctr_nf
  AND    T1.END_NT        = @p_end_nt
  AND    T1.SEC_NF        = @p_sec_nf
  AND    T1.UWY_NF        = @p_uwy_nf
  AND    T1.UW_NT         = @p_uw_nt
  AND    T1.ACY_NF        = @p_acy_nf
  AND    T1.BALSHEY_NF    = @p_balshey_nf 
  AND    T1.BALSHTMTH_NF <= @p_balshtmth_nf
  HAVING T1.LSTUPD_D      = MAX(T2.LSTUPD_D)          
  AND    T1.CRE_D         = MAX(T2.CRE_D)
  ORDER BY T1.LSTUPD_D

-------------------------------------------------------------------------
--                            FOLLOWING MOD 7                          --
-------------------------------------------------------------------------
-- insert line in TLIFDRI only if autupd_b indicator state changing or --
-- if the first comment                                                --
-------------------------------------------------------------------------
select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

IF ((@p_isAutUpdMngt = 1 AND ((@p_autupd_b_v0 != @p_autupd_b) OR (@cmt_nt_v0 != @p_cmt_nt))) OR @p_isAutUpdMngt = 0) -- MOD 7
BEGIN -- MOD 7
  --select @ssd_cf = convert(int,substring(@p_ctr_nf, 1, 2)) -- MOD4

  /***********************************************************************************/
  /* Insertion dans TLIFDRI                                                          */
  /***********************************************************************************/
      
  insert into TLIFDRI
    (
      acy_nf,
      balshey_nf,
      balshtmth_nf,
      cre_d,
      ctr_nf,
      end_nt,
      sec_nf,
      uw_nt,
      uwy_nf,
      autupd_b,
      cmt_nt,
      comacc_b,
      creusr_cf,
      lstupd_d,
      lstupdusr_cf,
      ssd_cf,
  		respropag_b,
	  	SEGUPD_B	-- MODIF 6	
    )
  values
   (
      @p_acy_nf,
      @p_balshey_nf,
      @p_balshtmth_nf,
      getdate(),
      @p_ctr_nf,
      @p_end_nt,
      @p_sec_nf,
      @p_uw_nt,
      @p_uwy_nf,
      @p_autupd_b,
      @p_cmt_nt,
      @p_comacc_b,
      @p_creusr_cf,
      getdate(),
      user,
      @p_ssd_cf, -- MOD4
  	  @p_respropag_b,
	  	@p_segupd_b -- MODIF 6
   )

  select @erreur = @@error
  if @@transtate = 2
    begin
     select @p_erreur = "ERREUR TRIGGER"
     goto fin
    end

  if @erreur != 0
    begin
      if @erreur = 2601
   	    select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliqu?e */
      else
 	      select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

      goto fin
    end

  select @p_lstupdusr_cf = lstupdusr_cf,
         @p_lstupd_d = lstupd_d
  from TLIFDRI
         where acy_nf = @p_acy_nf
           and balshey_nf = @p_balshey_nf
           and balshtmth_nf = @p_balshtmth_nf
           and ctr_nf = @p_ctr_nf
           and end_nt = @p_end_nt
           and sec_nf = @p_sec_nf
           and uw_nt  = @p_uw_nt
           and uwy_nf = @p_uwy_nf

  select @erreur = @@error
  if @erreur != 0
     select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

END  -- MOD 7
ELSE -- MOD 7
/***********************************************************************************/
/* Maj du n? de commentaire sur toutes les ann?es de compte                        */
/***********************************************************************************/
/*
BEGIN

Update TLIFDRI
	set cmt_nt = @p_cmt_nt
where
	ctr_nf = @p_ctr_nf and
      	end_nt =  @p_end_nt and
      sec_nf = @p_sec_nf and
	uw_nt = @p_uw_nt and
	uwy_nf = @p_uwy_nf and
	acy_nf = @p_acy_nf

 select @erreur = @@error
   if @erreur != 0
     begin
      select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
      goto fin
     end


END
*/

-----------------------------------------------------------------------------
---                          FOLLOWING MOD 7                              ---
-----------------------------------------------------------------------------
--  On doit modifier toutes les ligne de l'annÃ©e de compte mais uniquement --
-- la derniÃ¨rre ligne mise Ã  jour, afin de garder un historique propre     --
-----------------------------------------------------------------------------
BEGIN
  UPDATE TLIFDRI
  	SET CMT_NT   = @p_cmt_nt,
        LSTUPD_D = getdate()
  WHERE CTR_NF   = @p_ctr_nf
    AND END_NT   = @p_end_nt
    AND SEC_NF   = @p_sec_nf
	  AND UW_NT    = @p_uw_nt
	  AND UWY_NF   = @p_uwy_nf
	  AND ACY_NF   = @p_acy_nf
    AND LSTUPD_D = @LSTUPD_D
    AND CRE_D    = @CRE_D
  SELECT @erreur = @@error
     IF @erreur != 0
      BEGIN
        SELECT @p_erreur="20004 APPLICATIF;" + CONVERT(varchar(10), @erreur) + ";"
        GOTO fin
      END
END
------------------------------------------------------
---                 END OF MOD 7                   ---
------------------------------------------------------
if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
DROP TABLE #TLIFDRI_temp -- MOD 7
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur
go


USE BEST
GO
GRANT EXECUTE ON dbo.PiLIFDRI_01_O2 TO GDBBATCH
GO
GRANT EXECUTE ON dbo.PiLIFDRI_01_O2 TO GOMEGA
GO

