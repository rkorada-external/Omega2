use BEST
go

if object_id('dbo.PsUOASII_01') is not null
	begin
		drop procedure dbo.PsUOASII_01
		if object_id('dbo.PsUOASII_01') is not null
			print '<<< FAILED DROPPING procedure dbo.PsUOASII_01 >>>'
		else
			print '<<< DROPPED procedure dbo.PsUOASII_01 >>>'
	end
go

create procedure dbo.PsUOASII_01
as

/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : AGD
Date de creation         : 10/09/2019
Description du programme : extract table TUOASII
*****************************************************/

SELECT
	A.SSD_CF,
	A.ESB_CF,
	A.SGMT_NF,
    B.SGMT_LS,
	A.SGT_NT,
	A.SGTVER_NT,
	A.NORME_CF,
	A.THRESHOLD_M,
	convert(char(8),A.FCLODAT_D,112) + ' ' + convert(char(8),A.FCLODAT_D,108),
	convert(char(8),A.CRE_D,112) + ' ' + convert(char(8),A.CRE_D,108),
	A.CREUSR_CF,
	A.LSTUPDUSR_CF,
	convert(char(8),A.LSTUPD_D,112) + ' ' + convert(char(8),A.LSTUPD_D,108)
FROM
	dbo.TUOASII A, dbo.TSEGMT B, dbo.TSEGMENTATION C
WHERE A.SGT_NT = B.SGT_NT
AND A.SGT_NT = C.SGT_NT
AND C.SGTSTS_CF = '3'
AND B.SGTVER_NT = C.SGTVER_NT
AND A.SGMT_NF = B.SGMT_NF

go

if object_id('dbo.PsUOASII_01') is not null
	print '<<< CREATED procedure dbo.PsUOASII_01 >>>'
else
	print '<<< FAILED CREATING procedure dbo.PsUOASII_01 >>>'
go

grant execute on dbo.PsUOASII_01 TO GOMEGA
go

grant execute on dbo.PsUOASII_01 TO GDBBATCH
go
