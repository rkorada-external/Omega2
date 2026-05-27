USE BEST
GO

IF OBJECT_ID('dbo.PsCheckRequest_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCheckRequest_01
    PRINT '<<< DROPPED PROC dbo.PsCheckRequest_01 >>>'
END
go
 
create procedure PsCheckRequest_01 (
    @CRE_D     UUPD_D
)

as
/***************************************************
Programme:                  PsCheckRequest_01 
Fichier script associé :    BEST_CheckRequest_01.prc
Domaine :                   Esitomation
Baseprincipale :            BEST
Version:                    1
Auteur:                     M.NAJI 
Date de creation:           17/03/2021 
Description du programme:   Determiner le Lancement de l'nventaire 
Conditions d'execution: 
Commentaires:               liste des demande 

 BEST..PsCheckRequest_01  "20220922"
_________________
[001] 17/03/2021			M.NAJI    :Spira:91531 Creation
[002] 22/09/2022			M.NAJI    :Spira:106994  add a control on the Closing Type POS to verify that the closing Type INV is booked as well
*****************************************************/
declare @n_CdRet        int
declare @erreur         int,
        @site_cf        varchar(10)
declare @suser_Name     varchar(20)
declare @msg			varchar(512)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
	begin
      raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end


-- trace all requests
select * 
	from  BEST..TI17REQJOBPLAN
	where launch_d = NULL
	and dbclo_d <=  @CRE_D
	AND SITE_CF =@site_cf
    --AND REQCOD_CT not like "%O"
    
-- trace requests to use
select NORME_CF ,
                        REQCOD_CT,
                        max( DBCLO_D)  dbclo_d 
                    from  BEST..TI17REQJOBPLAN
                    where launch_d = NULL
                    and dbclo_d <=  @CRE_D
                    AND SITE_CF =@site_cf
                    AND REQCOD_CT not like "%O"
                    group by NORME_CF ,REQCOD_CT
    

    
--   erreur 2
if exists ( 
                select NORME_CF, count(*) from
                (	select NORME_CF ,
                        REQCOD_CT,
                        max( DBCLO_D)  dbclo_d 
                    from  BEST..TI17REQJOBPLAN
                    where launch_d = NULL
                    and dbclo_d <=  @CRE_D
                    AND SITE_CF =@site_cf
                    and NORME_CF != NULL
                    AND REQCOD_CT not like "%O"
                    group by NORME_CF ,REQCOD_CT
                ) as toto
                group by NORME_CF
                having count(*) > 1
) 
begin
	select @erreur  = 2
	select NORME_CF, count(*) "Number of request" from
		(	select NORME_CF ,
				REQCOD_CT,
				max( DBCLO_D)  dbclo_d 
			from  BEST..TI17REQJOBPLAN
			where launch_d = NULL
			and dbclo_d <=  @CRE_D
			AND SITE_CF =@site_cf
			AND REQCOD_CT not like "%O"
			and NORME_CF != NULL
			group by NORME_CF ,REQCOD_CT
		) as toto
		group by NORME_CF
		having count(*  ) > 1
    select @msg="Planification issue: multiple requests by norme "
end

-- trace check 2
select NORME_CF ,
		REQCOD_CT,
		max( DBCLO_D)  dbclo_d 
	from  BEST..TI17REQJOBPLAN
	where launch_d = NULL
	and dbclo_d <=  @CRE_D
	AND SITE_CF =@site_cf
	AND REQCOD_CT  like "%O"
	and NORME_CF != NULL
	group by NORME_CF ,REQCOD_CT



-- select INVB request to check
select
    BALSHEYEA_NF,
    BALSHTMTH_NF,
    REQCOD_CT,
    str_replace (REQCOD_CT,'POS', 'INVB')  as REQCOD_INVB ,
    max( DBCLO_D)  dbclo_d
into #REQCOD_INVB
from  BEST..TI17REQJOBPLAN
where 1 = 1
and  launch_d = NULL
and dbclo_d <=  @CRE_D
AND SITE_CF =@site_cf
AND REQCOD_CT  like  "%POS"
AND NORME_CF  <>   "I17S"
group by NORME_CF ,REQCOD_CT
having DBCLO_D = max( DBCLO_D)  AND SITE_CF =@site_cf


-- [002]  erreur 3
if exists ( 
	select *
	from #REQCOD_INVB b
	LEFT OUTER JOIN  BEST..TI17REQJOBPLAN p on
		b.BALSHEYEA_NF = p.BALSHEYEA_NF     and
		b.BALSHTMTH_NF = p.BALSHTMTH_NF and
		b.REQCOD_INVB = p.REQCOD_CT and
		p.launch_d != null
	where p.REQCOD_CT = NULL
) 
BEGIN
	select *
	from #REQCOD_INVB b
	LEFT OUTER JOIN  BEST..TI17REQJOBPLAN p on
		b.BALSHEYEA_NF = p.BALSHEYEA_NF     and
		b.BALSHTMTH_NF = p.BALSHTMTH_NF and
		b.REQCOD_INVB = p.REQCOD_CT and
		p.launch_d != null
	where p.REQCOD_CT = NULL

	select @erreur  = 4
	select @msg="Planification issue: missing technical booking of current quater "
END 

-- trace check 3
select *
from #REQCOD_INVB b
LEFT OUTER JOIN  BEST..TI17REQJOBPLAN p on
	b.BALSHEYEA_NF = p.BALSHEYEA_NF     and
	b.BALSHTMTH_NF = p.BALSHTMTH_NF and
	b.REQCOD_INVB = p.REQCOD_CT and
	p.launch_d != null
where p.REQCOD_CT = NULL



select @n_CdRet = @@error



if @n_CdRet != 0 
begin
    raiserror 20003 "Error in select/PsCheckRequest_01"
    return 1
end



if @erreur  > 0 
begin
    declare @message varchar(1000)
    raiserror 20003 @msg
    return 1
end

return 0
go

IF OBJECT_ID('dbo.PsCheckRequest_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCheckRequest_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCheckRequest_01 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsCheckRequest_01 */
GRANT EXECUTE ON dbo.PsCheckRequest_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCheckRequest_01 TO GDBBATCH
go


