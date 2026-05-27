use BEST
go

if object_id('PiExpratio_01') is not null
begin
  drop procedure PiExpratio_01
   if object_id('PiExpratio_01') is not null
      print '<<< FAILED DROPPING procedure PiExpratio_01 >>>'
    else
      print '<<< DROPPED procedure PiExpratio_01 >>>'
end
go


create procedure PiExpratio_01
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
    Select data from BTRAV..TEXPRAT based on SSD_CF, ESB_CF
	Check existence of data in BEST..TEXPRAT based on condition SSD_CF, ESB_CF, closing date and closing period and quator
	-  If row found then update the new ratio in table.
	-  If no row found then insert into BEST..TEXPRAT table
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
MOD01:12/09/2019 : 80563 - REQ 3.4 Additional lines in maintenance table not stored
*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @rowcount int

select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 

/* -------------------------------------------------------------------
    Select data from BTRAV..TEXPRAT based on USR_CF
---------------------------------------------------------------------*/
 
	UPDATE BEST..TEXPRAT 
	SET B.ACQRAT_R = A.ACQRAT_R,
		B.MAINTRAT_R = A.MAINTRAT_R,
		B.LSTUPDUSR_CF = @p_usr_cf,
		B.LSTUPD_D = getdate(),
		B.MAINTRATINI_R = A.MAINTRATINI_R
	FROM BTRAV..TEXPRAT A, BEST..TEXPRAT B 
	WHERE
		A.USR_CF = @p_usr_cf AND
		B.CLODAT_D = @p_closingd AND
		B.PER_CF = @p_per_cf AND
		A.SSD_CF = B.SSD_CF AND
		A.ESB_CF = B.ESB_CF AND			--MOD01
		A.SEG_NF = B.SEG_NF  AND
		A.NORME_CF  = B.NORME_CF AND
		A.CTRNAT_CT = B.CTRNAT_CT AND
		A.UWY_NF = B.UWY_NF

	select @erreur = @@error, @rowcount = @@rowcount
	if @erreur != 0 
	  begin 
		   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
		   goto fin
	end	
		
	print "Rows Updated : %1! ", @rowcount
	select @rowcount = 0
	
	INSERT INTO BEST..TEXPRAT 
    (SSD_CF,ESB_CF,SEG_NF ,CTRNAT_CT, NORME_CF ,ACQRAT_R, MAINTRAT_R, CLODAT_D ,PER_CF, CRE_D, CREUSR_CF, LSTUPD_D ,LSTUPDUSR_CF, MAINTRATINI_R, UWY_NF)     
    SELECT SSD_CF, ESB_CF, SEG_NF , CTRNAT_CT, NORME_CF, ACQRAT_R, MAINTRAT_R, @p_closingd ,@p_per_cf, getdate(), @p_usr_cf, getdate(), @p_usr_cf, MAINTRATINI_R, UWY_NF
	from BTRAV..TEXPRAT A
	WHERE NOT EXISTS ( SELECT 1 from BEST..TEXPRAT B	WHERE	A.SSD_CF = B.SSD_CF AND A.ESB_CF = B.ESB_CF AND A.SEG_NF = B.SEG_NF  AND				--MOD01
								A.NORME_CF  = B.NORME_CF AND A.CTRNAT_CT = B.CTRNAT_CT AND  B.CLODAT_D = @p_closingd AND B.PER_CF = @p_per_cf AND A.UWY_NF = B.UWY_NF  ) AND
	A.USR_CF = @p_usr_cf 
	
	select @erreur = @@error, @rowcount = @@rowcount
	if @erreur != 0 
	  begin 
		   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
		   goto fin
	end		

	print "Rows Inserted : %1! ", @rowcount
	

COMMIT TRAN		
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur

go

if object_id('PiExpratio_01') is not null
  print '<<< CREATED PROC PiExpratio_01 >>>'
else
  print '<<< FAILED CREATING PROC PiExpratio_01 >>>'
go
grant execute on PiExpratio_01 TO GOMEGA
go
grant execute on PiExpratio_01 TO GDBBATCH
go