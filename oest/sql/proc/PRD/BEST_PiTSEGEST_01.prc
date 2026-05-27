USE BEST
GO


/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PiTSEGEST_01
*/

IF OBJECT_ID('dbo.PiTSEGEST_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiTSEGEST_01
   PRINT '<<< DROPPED PROC dbo.PiTSEGEST_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiTSEGEST_01
     (
        @p_vers_nf 	numeric   ,
        @p_ssd_cf       USSD_CF   ,
        @p_segtyp_ct    USEGTYP_CT,
        @p_seg_nf 	USEG_NF   ,
        @p_uwy_nf 	UUWY_NF   ,
        @p_cre_d 	UUPD_D    ,
        @p_cur_cf 	UCUR_CF   ,
        @p_prmamt_m     UAMT_M    ,
        @p_clmamt_m     UAMT_M    ,
        @p_losart_r    	USHORAT_R       ,
        @p_amorat_ct 	char(1)         ,
        @p_acy_nf 	UUWY_NF   ,
        @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
       @p_ret		     char(64) = NULL output,
       @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiTSEGEST_01

Fichier script associé : BEST_PiTSEGEST_01

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation:03/08/2004

Description du programme:

      * Insertion d'enregistrement dans TSEGEST

Parametres:
    @p_vers_nf
@p_ssd_cf
@p_segtyp_ct
@p_seg_nf
@p_uwy_nf
@p_cre_d
@p_cur_cf
@p_prmamt_m
@p_clmamt_m
@p_losart_r
@p_amorat_ct
@p_ret
@p_erreur
@p_acy_nf


Conditions d'execution:


Commentaires:

_________________
MODIFICATION 01

Auteur: KBagwe

Date:22-05-2015

Version:

Description:EST39 evo card changes

*****************************************************/

declare @erreur int,
            @tran_imbr	bit,
            @getdate      datetime,
            @user         UUPDUSR_CF

select @getdate = GetDate()
select @user = user

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


/*-----------------------------------------------------------------------------
  Insertion dans TSEGEST
---------------------------------------------------------------------------*/

insert into BEST..TSEGEST
      (  VRS_NF    ,
        SSD_CF    ,
        SEGTYP_CT ,
        SEG_NF    ,
        UWY_NF    ,
        CRE_D     ,
        CUR_CF    ,
        PRMAMT_M  ,
        CLMAMT_M  ,
        LOSRAT_R  ,
        AMORAT_CT,
        ACY_NF  )						--MOD01
 values
      ( @p_vers_nf 	,
        @p_ssd_cf       ,
        @p_segtyp_ct    ,
        @p_seg_nf 	,
        @p_uwy_nf 	,
        @p_cre_d 	,
        @p_cur_cf 	,
        @p_prmamt_m     ,
        @p_clmamt_m     ,
        @p_losart_r    	,
        @p_amorat_ct,
        @p_acy_nf )						--MOD01



select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   if @erreur = 2601
 	   select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
 	   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end


 /* ---------------------------------------------- */
 /* Execution ASYNCHRONE                           */
 /* ---------------------------------------------- */

declare @dateISO char(8) 
declare @w_erreur	varchar(64)
declare @SelectParm1 varchar(30)
declare @SelectParm2 varchar(30) 
declare @SelectParm3 varchar(30)
declare @SelectParm4 varchar(30)
declare @SelectParm5 varchar(30)
declare @SelectParm6 varchar(30)
declare @SelectParm7 varchar(30)		--MOD01

declare @Vide varchar(12)

Select @dateISO = convert(char(8), GetDate(), 112)
Select @Vide = ""
Select @SelectParm1 = "U"                            -- U = Insert / Update , D = Delete
Select @SelectParm2 = convert(char(2),@p_ssd_cf)     -- N° Filiale
Select @SelectParm3 = convert(char(3),@p_vers_nf)    -- N° Version
Select @SelectParm4 = '"' + @p_seg_nf + '"'          -- Segment
Select @SelectParm5 = convert(char(4),@p_uwy_nf)     -- Annee
Select @SelectParm6 = @p_cur_cf                      -- Devise
Select @SelectParm7 = convert(char(4),@p_acy_nf)     -- acy	--MOD01

Execute BTEC..Pijobqueue_01
	"best10a", 	@user, null, @dateISO, 
    @SelectParm1, @SelectParm2, @SelectParm3, @SelectParm4, @SelectParm5, @SelectParm6, @SelectParm7, @Vide,
	@Vide, @Vide, @Vide, @Vide,	@Vide, @Vide, @Vide, @Vide,	@Vide, 
    @w_erreur

if @erreur != 0
  begin
   if @erreur = 2601
 	   select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
 	   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end
/* -- */


select  @p_lstupd_d =  @getdate
select  @p_lstupdusr_cf =  @user
select  @p_ret = "1"          --On ne l'utilise pas

/*----------------------------------------------------------------------------*/
/* Fin transaction                                                            */
/*----------------------------------------------------------------------------*/

if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur

go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESISUP01', 'PiTSEGEST_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PiTSEGEST_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiTSEGEST_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiTSEGEST_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiTSEGEST_01
 */
GRANT EXECUTE ON dbo.PiTSEGEST_01 TO GOMEGA
go

