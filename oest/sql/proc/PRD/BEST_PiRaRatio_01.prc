use BEST
go

if object_id('PiRaRatio_01') is not null
begin
  drop procedure PiRaRatio_01
   if object_id('PiRaRatio_01') is not null
      print '<<< FAILED DROPPING procedure PiRaRatio_01 >>>'
    else
      print '<<< DROPPED procedure PiRaRatio_01 >>>'
end
go


create procedure PiRaRatio_01
  (
  @p_ssd_cf USSD_CF,
  @p_closingd datetime,
  @p_per_cf CHAR(4),
  @p_usr_cf UUSR_CF,
  @p_erreur varchar(64)=null output
  )
with execute as caller as 
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME34 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    Select data from BTRAV..ESID0901_TRARAT based on SSD_CF, ESB_CF
	Check existence of data in BEST..TRARAT based on condition SSD_CF, ESB_CF, closing date and closing period and quator
	-  If row found then update the new ratio in table.
	-  If no row found then insert into BEST..TRARAT table
Parametres:

 	@p_ssd_cf	 SSD_CF         : Filiale
    @p_esb_cf	 ESB_CF			: 
    @p_closingd	 CLOSINGD		: closing date
	@p_per_cf  CLOSINGP		: closing period
    @p_erreur       varchar(64)=null output
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS

[001] 30/11/2018 Quentin DESMETTRE   :spira:72732 : Table empty after successful load
[002] 10/10/2019 Charles SOCIE       :spira:79785 : ratios not updated 
[003] 21/09/2021 KBhimasen      	 :spira:99006 : Omega/DIP interface 
*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 

/* -------------------------------------------------------------------
    Select data from BTRAV..ESID0901_TRARAT based on USR_CF
---------------------------------------------------------------------*/
 
	UPDATE BEST..TRARAT 
	SET B.PRMRAT_R = A.PRMRAT_R,
		B.RSRVRAT_R = A.RSRVRAT_R,
		B.LSTUPDUSR_CF = @p_usr_cf,
		B.LSTUPD_D = getdate(),
		B.RALIC_R = A.RALIC_R,
		B.RALRC_R = A.RALRC_R
	FROM BTRAV..ESID0901_TRARAT A, BEST..TRARAT B 
	WHERE
		A.USR_CF = @p_usr_cf AND
		B.CLODAT_D = @p_closingd AND
		B.PER_CF = @p_per_cf AND
		A.SSD_CF = B.SSD_CF AND
		A.SEG_NF = B.SEG_NF  AND
		A.ESB_CF = B.ESB_CF AND
		A.NORME_CF  = B.NORME_CF AND
		A.CTRNAT_CT = B.CTRNAT_CT AND
		ISNULL(A.DOMAIN_CF,'0') = ISNULL(B.DOMAIN_CF,'0')	--MOD03

	select @erreur = @@error	
	if @erreur != 0 
	  begin 
		   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
		   goto fin
	end	
		
	INSERT INTO BEST..TRARAT 
    (SSD_CF,ESB_CF,SEG_NF ,CTRNAT_CT,NORME_CF ,DOMAIN_CF,PRMRAT_R ,RSRVRAT_R, CLODAT_D ,PER_CF, CRE_D, CREUSR_CF, LSTUPD_D ,LSTUPDUSR_CF, RALIC_R, RALRC_R )     
    SELECT SSD_CF, ESB_CF, SEG_NF , CTRNAT_CT, NORME_CF, DOMAIN_CF, PRMRAT_R, RSRVRAT_R, @p_closingd ,@p_per_cf, getdate(), @p_usr_cf, getdate(), @p_usr_cf, RALIC_R, RALRC_R
	from BTRAV..ESID0901_TRARAT A
	WHERE NOT EXISTS ( SELECT 1 from BEST..TRARAT B	WHERE	A.SSD_CF = B.SSD_CF AND A.ESB_CF = B.ESB_CF AND A.SEG_NF = B.SEG_NF  AND
								A.NORME_CF  = B.NORME_CF AND A.CTRNAT_CT = B.CTRNAT_CT AND  B.CLODAT_D = @p_closingd AND B.PER_CF = @p_per_cf AND ISNULL(A.DOMAIN_CF,'0') = ISNULL(B.DOMAIN_CF,'0')   ) AND		--MOD03
	A.USR_CF = @p_usr_cf 
	
	select @erreur = @@error	
	if @erreur != 0 
	  begin 
		   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
		   goto fin
	end		

COMMIT TRAN		
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur

go

if object_id('PiRaRatio_01') is not null
  print '<<< CREATED PROC PiRaRatio_01 >>>'
else
  print '<<< FAILED CREATING PROC PiRaRatio_01 >>>'
go
grant execute on PiRaRatio_01 TO GOMEGA
go
grant execute on PiRaRatio_01 TO GDBBATCH
go