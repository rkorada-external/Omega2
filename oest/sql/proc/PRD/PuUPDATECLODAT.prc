USE BEST
go
IF OBJECT_ID('dbo.PuUPDATECLODAT') IS NOT NULL
BEGIN
  DROP PROC dbo.PuUPDATECLODAT
  PRINT '<<< DROPPED PROC dbo.PuUPDATECLODAT >>>'
END
go
create procedure dbo.PuUPDATECLODAT
 (
   @p_clodat_d   datetime
  )
as
/***************************************************
Domaine :                   Update Closing Date
Base principale :           BEST
Version:                    1
Auteur:                     C.SOCIE
Description du programme: EXT-IFRS17 - REQ 1000.7
    - Update Closing date
Parametres:  
  				-   @p_clodat_d  datetime
_________________
MODIFICATIONS
*****************************************************/
declare @erreur int,
        @tran_imbr  bit,
        @account_d datetime,
		@lignes int

select @erreur=0, @tran_imbr=1

if @@trancount=0
begin
  select @tran_imbr=0
  BEGIN TRAN
end

-- Calculation of new CLODAT 
-- the next closing is the last day of the next quarter
-- to have the good behavior with 30 and 31 the solution is :
-- take the first day of the actual Closing 
-- add 4 month (so you will be the first day of next closing)
-- and whitdraw 1 days 
DECLARE @p_NEW_CLODAT_D DATETIME
SELECT @p_NEW_CLODAT_D =
               DATEADD(DAY, -1,DATEADD(MONTH, 3,DATEADD(DAY, 1,@p_clodat_d)))

-- insert rows with new quarter if there is no existing rows for the new closing date
if not exists ( select * from BEST..TEXPRAT where CLODAT_D=@p_NEW_CLODAT_D)
    begin     
		insert into BEST..TEXPRAT
		select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF,CREUSR_CF,CRE_D,LSTUPDUSR_CF,LSTUPD_D
		from BEST..TEXPRAT
		where CLODAT_D=@p_clodat_d
    end
else
	begin	
	-- delete the potential already update if they are existing and insert old line with new quarter
		delete from BEST..TEXPRAT where CLODAT_D=@p_NEW_CLODAT_D and 
		exists ( select 1 from BEST..TEXPRAT a , BEST..TEXPRAT b 
		where a.CLODAT_D=@p_NEW_CLODAT_D and b.CLODAT_D=@p_clodat_d
		and (a.SSD_CF=b.SSD_CF and a.ESB_CF=b.ESB_CF and  a.SEG_NF=b.SEG_NF and a.NORME_CF=b.NORME_CF and a.CTRNAT_CT=b.CTRNAT_CT and  a.CREUSR_CF=b.CREUSR_CF and a.CRE_D=b.CRE_D and a.PER_CF=b.PER_CF and a.LSTUPDUSR_CF=b.LSTUPDUSR_CF and a.LSTUPD_D=b.LSTUPD_D)
		and (a.ACQRAT_R!=b.ACQRAT_R or a.MAINTRAT_R!=b.MAINTRAT_R)  )
		insert into BEST..TEXPRAT 
		select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF,CREUSR_CF,CRE_D,LSTUPDUSR_CF,LSTUPD_D 
		from BEST..TEXPRAT 
		where CLODAT_D=@p_clodat_d 
		and not exists ( select 1 from BEST..TEXPRAT a , BEST..TEXPRAT b where a.CLODAT_D=@p_NEW_CLODAT_D and b.CLODAT_D=@p_clodat_d and (a.SSD_CF=b.SSD_CF and a.ESB_CF=b.ESB_CF and a.SEG_NF=b.SEG_NF and a.NORME_CF=b.NORME_CF and a.CTRNAT_CT=b.CTRNAT_CT and  a.CREUSR_CF=b.CREUSR_CF and a.CRE_D=b.CRE_D and a.PER_CF=b.PER_CF and a.LSTUPDUSR_CF=b.LSTUPDUSR_CF and a.LSTUPD_D=b.LSTUPD_D ))
	end
	
	-- insert rows with new quarter if there is no existing rows for the new closing date
if not exists ( select * from BEST..TRARAT where CLODAT_D=@p_NEW_CLODAT_D)
    begin     
		insert into BEST..TRARAT
		select SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, DOMAIN_CF, PRMRAT_R, RSRVRAT_R, CLODAT_D=@p_NEW_CLODAT_D, PER_CF, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D
		from BEST..TRARAT
		where CLODAT_D=@p_clodat_d
    end
else
	begin	
	-- delete the potential already update if they are existing and insert old line with new quarter
		delete from BEST..TRARAT where CLODAT_D=@p_NEW_CLODAT_D and 
		exists ( select 1 from BEST..TRARAT a , BEST..TRARAT b 
		where a.CLODAT_D=@p_NEW_CLODAT_D and b.CLODAT_D=@p_clodat_d
		and (a.SSD_CF=b.SSD_CF and a.ESB_CF=b.ESB_CF and  a.SEG_NF=b.SEG_NF and a.NORME_CF=b.NORME_CF and a.CTRNAT_CT=b.CTRNAT_CT and  a.CREUSR_CF=b.CREUSR_CF and a.CRE_D=b.CRE_D and a.PER_CF=b.PER_CF and a.LSTUPDUSR_CF=b.LSTUPDUSR_CF and a.LSTUPD_D=b.LSTUPD_D and a.DOMAIN_CF=b.DOMAIN_CF)
		and (a.PRMRAT_R!=b.PRMRAT_R or a.RSRVRAT_R!=b.RSRVRAT_R)  )
		insert into BEST..TRARAT 
		select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,DOMAIN_CF,PRMRAT_R,RSRVRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF,CREUSR_CF,CRE_D,LSTUPDUSR_CF,LSTUPD_D 
		from BEST..TRARAT 
		where CLODAT_D=@p_clodat_d 
		and not exists ( select 1 from BEST..TRARAT a , BEST..TRARAT b where a.CLODAT_D=@p_NEW_CLODAT_D and b.CLODAT_D=@p_clodat_d and (a.SSD_CF=b.SSD_CF and a.ESB_CF=b.ESB_CF and a.SEG_NF=b.SEG_NF and a.NORME_CF=b.NORME_CF and a.CTRNAT_CT=b.CTRNAT_CT and  a.CREUSR_CF=b.CREUSR_CF and a.CRE_D=b.CRE_D and a.PER_CF=b.PER_CF and a.LSTUPDUSR_CF=b.LSTUPDUSR_CF and a.LSTUPD_D=b.LSTUPD_D and a.DOMAIN_CF=b.DOMAIN_CF ))
	end
	
select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin

if @tran_imbr=0
  COMMIT TRAN
return 0

fin:
if @tran_imbr=0
  ROLLBACK TRAN
return @erreur
go
IF OBJECT_ID('dbo.PuUPDATECLODAT') IS NOT NULL
  PRINT '<<< CREATED PROC dbo.PuUPDATECLODAT >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC dbo.PuUPDATECLODAT >>>'
go
GRANT EXECUTE ON dbo.PuUPDATECLODAT TO GOMEGA
go