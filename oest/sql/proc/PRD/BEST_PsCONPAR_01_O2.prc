USE BEST
go
IF OBJECT_ID('dbo.PsCONPAR_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCONPAR_01_O2
    IF OBJECT_ID('dbo.PsCONPAR_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCONPAR_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCONPAR_01_O2 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PsCONPAR_01_O2
     (
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
    @p_ssd_cf              USSD_CF,
       @p_lag_cf              ULAG_CF,
       @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsCONPAR_01_O2

Fichier script associé : ESSCON01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME08 (G.DIMCEA) avec Infotool version 2.0 (AUTO)

Date de creation: 13/06/1997


Description du programme: 

    - Select BEST..TCONPAR

    - Si ctr_nf = "__T%" ou ctr_nf = "__Z% "
        - Select de BTRT..TSECTION  
        - Select de BTRT..TCONTR  
        - Select de BTRT..TBOQPRG (libellé programme)
        - Select de BTRT..TBOQPRG (libellé bouquet)

    - Si ctr_nf = "__F%" ou ctr_nf = "__G%"
        - Select de BFAC..TSECTION  
        - Select de BFAC..TCONTR  (bandeau fac)

    - Select BCLI..TCLIENT (libellé cédante)
    - Select BREF..TBANTECL (status du contrat)
    - Select BREF..TCTYSUPL (libellé territorialité ou marché)

    - Select final des variables
    
Parametres: 

      @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
    @p_ssd_cf              USSD_CF,
       @p_lag_cf              ULAG_CF,
       @p_ctr_nf              UCTR_NF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 17/01/1998

Version:

Description: Rajout accès à TREQJOB

_________________
MODIFICATION 2

Auteur: L.DEBEVER

Date: 26/01/1998

Version:

Description: Condition pour déterminer si un contrat est 
          un Traité:
            IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z% or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%",
          au lieu de :
         IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%"
          Il existe des traités de type "__U%" et "__W%"

_________________
MODIFICATION 3

Auteur: L.DEBEVER

Date: 20/05/1998

Version:

Description: Modif clause where / TREQJOB

_________________
MODIFICATION 4

Auteur: L.DEBEVER

Date: 15/12/1998

Version:

Description: REQCOD_CT in ("I", "J") et non pas 
         uniquement "I"
_________________
MODIFICATION 005
Auteur:J CHOCHON
Date : 19/11/2012
Description: Omega 2 SSL Impact
                                keyword "like" on ctr_nf is removed
_________________
MODIFICATION 006
Auteur: A BOUTHERIN
Date: 19/11/2012
Description: 1. Concatenation on period removed.
			 2. Retrieve the Ledger of the Contract

*****************************************************/

declare @erreur int

/*------------------------------------
  déclaration table BEST.. TCONPAR
------------------------------------*/
declare     @ctr_nf        UCTR_NF,        /* Contrat */
            @end_nt        UEND_NT,        /* Avenant */
           @sec_nf        USEC_NF,        /* Section */
            @uwy_nf        UUWY_NF,        /* Exercice */    
            @uw_nt            UUW_NT,         /* N° d'ordre */     
            @cur_cf        UCUR_CF,          /* Devise */       
            @accadmtyp_ct    UACCADMTYP_CT,     /* code type comptable */        
            @retced_r        USHORAT_R,         /* Retro ceded share */      
             @balshepla_r        USHORAT_R,         /* Balance Sheet Placed share */
        @ctrnat_ct        char(1)        /* Type de contrat */

/*------------------------------------
  déclaration table BEST..  TREQJOB
------------------------------------*/

 Declare  @cre_d		UUPD_D,
          @clodat_d		datetime, 
		@launch_d		UUPD_D,
		@balsheyea_nf	smallint,
		@balshtmth_nf	tinyint,
		@period			varchar(7)

/*--------------------------------- 
  Déclaration table BREF..TBANTECL 
---------------------------------*/      
declare     @ctrsts_ls           UL16            /* libellé status du traité ou fac */    
        
/*--------------------------------- 
  Déclaration table BREF..TCTYSUPL 
---------------------------------*/
declare     @pcprsktry_ls         UL16            /* libellé territorialité ou marché */

/*--------------------------------- 
  Déclaration table BCLI..TCLIENT
---------------------------------*/      
declare     @ced_ld              UCLISHONAM_LD    /* libellé cédante    */


/*-----------------------------------------
  Déclaration table TBOQPRG (TRAITE et FAC)
-------------------------------------------*/      
declare    @prg_ll              UL64,            /* libellé programme */
          @boq_ll              UL64            /* libellé bouquet    */              

/*----------------------------------------
  Déclaration table TCONTR (TRAITE et FAC)
------------------------------------------*/
declare    @prg_nf             UCTRGRP_NF,        /* code programme */
        @boq_nf             UCTRGRP_NF,        /* code bouquet                    */
        @ctrpcpnam_ll       UL64,        /* nom du traité ou affaire            */
        @ced_nf             UCLI_NF,        /* code cédante                    */
        @ctrsts_ct          UCTRSTS_CT,        /* code status du traité ou fac            */
        @scoinc_d           datetime,        /* date d'effet du traité            */
        @ctrinc_d           datetime,        /* date d'effet de la facultative        */
		@ssd_cf             USSD_CF,        /* filiale                                    */
		@accesb_cf			UESB_CF			/* Subledger                                    */

/*---------------------------------------------- 
  Déclaration table TSECTION (TRAITE ET FAC) 
----------------------------------------------*/                
declare    @subnat_cf          UCTRSUBNAT_CF,    /* sous nature                                */
        @nat_cf             UCTRNAT_CF,        /* nature                                    */ 
        @lob_cf             ULOB_CF,        /* Lob                                        */
        @top_cf             UTOP_CF,        /* Top                                        */
        @sob_cf             USOB_CF,        /* Sob                                        */
        @gar_cf             UGAR_CF,        /* garantie                                    */
        @pcprsktry_cf       UCTY_CF,        /* territoire principal de risque (territorialité ou marché)    */
        @usrcrtval_lm       UL32,        /* valeur critère utilisateur                        */
        @secsts_ct          UCTRSTS_CT,        /* etat de la section                            */
        @frsuwy_nf          UUWY_NF        /* 1er exercice de souscription de ce contrat */

        
/*************************************************************************************************
  Table TCONPAR
**************************************************************************************************/

 Select @ctr_nf = ctr_nf,
        @end_nt = end_nt,
        @sec_nf = sec_nf,
        @uwy_nf = uwy_nf,
        @uw_nt  = uw_nt,
        @cur_cf = cur_cf,
        @accadmtyp_ct = accadmtyp_ct,
        @retced_r = retced_r
     from TCONPAR
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf

 select @erreur = @@error
 if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;BEST..TCONPAR" /* erreur de selection */
      goto fin 
   end
 

/*************************************************************************************************
  Table TREQJOB
**************************************************************************************************/

/* REQUETE INITIALE -> PB : ON COMPARE 19986 à 199806 */
/*
Select @cre_d = Max(CRE_D) 
from treqjob 
where convert(varchar(6), CLODAT_D, 112) = convert(varchar(4), BALSHEYEA_NF) + convert(varchar(2), BALSHTMTH_NF) 
and SSD_CF = @p_ssd_cf and LAUNCH_D <> NULL and REQCOD_CT = "I"
*/

/* RUSTINE : ON VIRE CONDITION SUR CLODAT_D */
/*
Select @cre_d = Max(CRE_D) 
from treqjob 
where SSD_CF = @p_ssd_cf and LAUNCH_D <> NULL and REQCOD_CT = "I"
*/

/* Modif 3 : et Modif 4 : */

Select @cre_d = Max(CRE_D) 
from treqjob 
where (Convert(varchar(4),(datepart(yy,CLODAT_D))) + substring(convert(varchar(3),100 + datepart(mm, CLODAT_D)),2,2))
= (convert(varchar(4), BALSHEYEA_NF) + substring(convert(varchar(3), 100 + BALSHTMTH_NF),2,2)) 
and SSD_CF = @p_ssd_cf and LAUNCH_D <> NULL and REQCOD_CT in ("I", "J")


select @erreur = @@error
 if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;BEST..TREQJOB" /* erreur de selection */
      goto fin 
   end


Select @clodat_d = CLODAT_D, 
    @launch_d = LAUNCH_D,
    @balsheyea_nf = BALSHEYEA_NF,
    @balshtmth_nf = BALSHTMTH_NF,
    @period = convert(varchar(4), BALSHEYEA_NF) + "-" + convert(varchar(2), BALSHTMTH_NF) 
from treqjob  
where CRE_D = @cre_d and SSD_CF = @p_ssd_cf


 select @erreur = @@error
 if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;BEST..TREQJOB" /* erreur de selection */
      goto fin 
   end


/*****************************************************************************************
  TRAITE
*******************************************************************************************/
--IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%"
IF exists ( select 1 from BTRT..TCONTR where ctr_nf = @p_ctr_nf)
begin

    /*------------------------
     Select  BTRT..TSECTION       
    --------------------------*/            
    select        @subnat_cf    = subnat_cf,
            @nat_cf       = nat_cf,
            @lob_cf       = lob_cf,
            @top_cf       = top_cf,
            @sob_cf       = sob_cf,
            @gar_cf       = gar_cf,
            @pcprsktry_cf = pcprsktry_cf,
            @usrcrtval_lm = usrcrtval_lm,
            @frsuwy_nf    = frsuwy_nf
            
      from BTRT..TSECTION
     where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uwy_nf = @p_uwy_nf
         and uw_nt  = @p_uw_nt
         and secsts_ct in (14,16,17,18,19) /* (accepté, définitif, renouvelé, expiré, résilié) */ 

    select @erreur = @@error
    if @erreur != 0 begin raiserror 20001 "APPLICATIF;BTRT..TSECTION" goto fin end



     /*---------------------------------
      select de BTRT..TCONTR 
        bandeau (TRAITE)
     ---------------------------------*/
      select @prg_nf       = prg_nf,
             @boq_nf       = boq_nf,
             @ctrpcpnam_ll = ctrpcpnam_ll,
             @ced_nf       = ced_nf,
             @ctrsts_ct    = ctrsts_ct,
             @scoinc_d     = scoinc_d,
			 @ssd_cf       = ssd_cf,
			 @accesb_cf    = accesb_cf
       from BTRT..TCONTR 
       where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt       
         and uw_nt  = @p_uw_nt
         and uwy_nf = @p_uwy_nf
 
      select @erreur = @@error
      if @erreur != 0 begin raiserror 20001 '20001 APPLICATIF;BTRT..TCONTR;' goto fin end 

      /*---------------------------------
      Recherche du libellé du programme
    -----------------------------------*/
    select @prg_ll = grpnam_ll
      from BTRT..TBOQPRG
     where grp_nf = @prg_nf

    select @erreur = @@error
    if @erreur != 0 begin raiserror 20001 "APPLICATIF;BTRT..TBOQPRG " goto fin end

    /*-------------------------------
      Recherche du libellé du bouquet
    ---------------------------------*/
    select @boq_ll = grpnam_ll
      from BTRT..TBOQPRG
     where grp_nf = @boq_nf

    select @erreur = @@error
    if @erreur != 0 begin raiserror 20001 "APPLICATIF;BTRT..TBOQPRG " goto fin end

      /*---------------------
     Nature de l'affaire
    ---------------------*/
    if @nat_cf <  "30" begin select @ctrnat_ct = "P" end     /* traité proportionnel        */
    if @nat_cf >= "30" begin select @ctrnat_ct  = "N" end     /* traité non proportionnel   */

end 
 

/*****************************************************************************************
  FACULTATIVE
*******************************************************************************************/
--if @p_ctr_nf like "__F%" or @p_ctr_nf like "__G%"
IF exists ( select 1 from BFAC..TCONTR where ctr_nf = @p_ctr_nf)
 begin
    /*------------------------
     Select  BFAC..TSECTION       
    --------------------------*/            
    select        @subnat_cf = subnat_cf,
            @nat_cf = nat_cf,
            @lob_cf = lob_cf,
            @top_cf = top_cf,
            @sob_cf = sob_cf,
            @gar_cf = gar_cf,
            @pcprsktry_cf = pcprsktry_cf,
            @usrcrtval_lm = usrcrtval_lm,
            @frsuwy_nf = frsuwy_nf            
      from BFAC..TSECTION
     where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uwy_nf = @p_uwy_nf
         and uw_nt  = @p_uw_nt
         and secsts_ct in (16,17,18,19) /* (définitif, renouvelé, expiré, résilié) */ 
 
    select @erreur = @@error
    if @erreur != 0 begin raiserror 20001 "APPLICATIF;BFAC..TSECTION" goto fin end

    /*---------------------------------
      select de BFAC..TCONTR 
        bandeau (FACULTATIVE)
     ---------------------------------*/
      select @prg_nf         = prg_nf,
             @boq_nf         = boq_nf,
             @ctrpcpnam_ll   = ctrpcpnam_ll,
             @ced_nf         = ced_nf,
             @ctrsts_ct      = ctrsts_ct,
             @ctrinc_d       = ctrinc_d,
			 @ssd_cf       = ssd_cf,
			 @accesb_cf    = accesb_cf
        from BFAC..TCONTR 
       where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt       
         and uw_nt  = @p_uw_nt
         and uwy_nf = @p_uwy_nf
 
      select @erreur = @@error
      if @erreur != 0 begin raiserror 20001 '20001 APPLICATIF;BFAC..TCONTR;' goto fin end  
 
    /*---------------------
     Nature de l'affaire
    ---------------------*/
    select @ctrnat_ct = "F"     /* facultative    */

 end


/*-------------------------------
  Recherche du libellé cédante
  BCLI..TCLIENT
---------------------------------*/
select @ced_ld = clishonam_ld
  from BCLI..TCLIENT
 where cli_nf = @ced_nf

select @erreur = @@error
if @erreur != 0 begin raiserror 20001 "APPLICATIF;BCLI..TCLIENT " goto fin end

/*-------------------------------
  Recherche du status du contrat 
  BREF..TBANTECL
---------------------------------*/
select @ctrsts_ls = colval_ls
  from BREF..TBANTECL
 where col_ls    = "CTRSTS_CT"
   and lag_cf    = @p_lag_cf
   and colval_ct = convert(char(5),@ctrsts_ct)

select @erreur = @@error
if @erreur != 0 begin raiserror 20001 "APPLICATIF;BREF..TBANTECL " goto fin end

/*--------------------------------------------------------------
  Recherche du libellé territorialité ou marché du contrat 
  BREF..TCTYSUPL
--------------------------------------------------------------*/
select @pcprsktry_ls = ctysup_ls
  from BREF..TCTYSUPL
 where ctysup_cf = @pcprsktry_cf
   and lag_cf    = @p_lag_cf

select @erreur = @@error
if @erreur != 0 begin raiserror 20001 "APPLICATIF;BREF..TCTYSUPL " goto fin end

/*-----------------
 Select final
-----------------*/

select  @p_ctr_nf			ctr_nf,        /* Contrat */    
        @p_end_nt			end_nt,        /* Avenant */
        @p_sec_nf			sec_nf,        /* Section */        
        @p_uwy_nf			uwy_nf,        /* Exercice */        
        @p_uw_nt			uw_nt,            /* N° d'ordre */    
        @clodat_d			clodat_d,         /* Libellé Inventaire: */
        @launch_d			launch_d,         /* Résultat en date du:  */
        @balsheyea_nf		balsheyea_nf,     /* Year of the Period */
        @balshtmth_nf		balshtmth_nf,    /* Month of the Period */
        @period             period,        /* Période:          */
        @cur_cf             cur_cf,        /* Devise */
        @accadmtyp_ct		accadmtyp_ct,              /* Code type comptable */ 
		@retced_r * 100		retced_r,        /* Retro ceded share */      
        @subnat_cf			subnat_cf,        /* sous nature */
        @nat_cf				nat_cf,        /* nature */ 
        @lob_cf				lob_cf,        /* Lob     */
        @top_cf				top_cf,         /* Top */
        @sob_cf				sob_cf,         /* Sob */
        @gar_cf				gar_cf,         /* garantie */
        @pcprsktry_cf		pcprsktry_cf,     /* code territoire principal de risque (territorialité ou marché)    */
        @pcprsktry_ls		ctysup_ls,          /* libellé du teritoir principal de risque */
        @usrcrtval_lm		usrcrtval_lm,     /* valeur critère utilisateur */
        @ssd_cf				ssd_cf,          /* code filialle */
        @accesb_cf			accesb_cf,       /* code subledger */
        @secsts_ct			secsts_ct,        /* etat de la section */
        @prg_nf				prg_nf,        /* code programme */
        @prg_ll				prg_ll,        /* libelle programm */
        @boq_nf				boq_nf,        /* code bouquet */
        @boq_ll				boq_ll,        /* libellé bouquet */
        @ctrpcpnam_ll		ctrpcpnam_ll,    /* nom du traite ou affaire */
        @ced_nf				ced_nf,        /* code cédente */
        @ced_ld				ced_ld,        /* libellé cédente */
        @ctrsts_ct			ctrsts_ct,        /* code status du traité ou fac */
        @ctrsts_ls			ctrsts_ls,        /* libellé status du traité ou fac */
        @scoinc_d			scoinc_d,        /* date d'effet du traité */
        @ctrinc_d			ctrinc_d,        /* date d'effet du facultatives */
        @frsuwy_nf			frsuwy_nf,        /* 1er exercice de souscription de ce contrat */
        @ctrnat_ct			ctrnat_ct        /* nature du contrat */
        

fin:
return @erreur
go
EXEC sp_procxmode 'dbo.PsCONPAR_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsCONPAR_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCONPAR_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCONPAR_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PsCONPAR_01_O2 TO GOMEGA
go
