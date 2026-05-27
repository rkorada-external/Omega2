use BTRT
go
if object_id('dbo.PiESTIMA_01') IS NOT null
begin
  drop PROC dbo.PiESTIMA_01
  print '<<< DROPPED PROC dbo.PiESTIMA_01 >>>'
end
go
create procedure PiESTIMA_01
  (
  @p_ctr_nf   UCTR_NF
 ,@p_end_nt   UEND_NT
 ,@p_uw_nt    UUW_NT
 ,@p_uwy_nf   UUWY_NF
 ,@p_sections varchar(912)  --modif 2, liste des numéros de sections concaténés : 1/2/3...
 ,@p_usr_cf		UUPDUSR_CF
 ,@p_ssd_cf 	USSD_CF
 ,@p_erreur	  varchar(64)=null output
  )
as
/***************************************************
Base principale : BEST
Auteur: ME01 - L.DEBEVER avec Infotool version 2.0 (AUTO)
Date de creation: 7/07/1997
Description du programme:
	- Proc lancée par l'appli TRT à la validation d'un traité
	- Cette proc lance la proc PiESTIMA_02 qui effectue les opérations suivantes :
      		. Sélection d'informations dans TRAITE et dans ESTIMATION
		. En fonction de la valeur des info rapportées, lancement des proc. de maj de ESTIMATION
	- L'équivalent dans l'appli FAC est PiESTIMA_03
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
   Auteur     Date       Description
1 Florent     31/01/2008 TRT15012 on allonge la longueur de la chaîne pour les sections
*****************************************************/
declare
  @erreur     int
 ,@num        int
 ,@parsed_sec tinyint
 ,@tran_imbr	bit

select @tran_imbr=1
if @@trancount = 0
begin
   select @tran_imbr=0
   begin tran
end

if @p_sections = '' goto NoSections

-- modif 1 simplification de la boucle !
select @num=1
while @num > 0
begin
  select @num=charindex('/',@p_sections)
  if @num=0
    select @parsed_sec=convert(tinyint,@p_sections)
  else
    select @parsed_sec=convert(tinyint,substring(@p_sections,1,@num - 1))

  if @parsed_sec=null break
  select @p_sections=substring(@p_sections,@num + 1,datalength(@p_sections))

	execute @erreur=BEST..PiESTIMA_02 @p_ctr_nf,@p_uwy_nf,@p_uw_nt,@p_end_nt,@parsed_sec,@p_usr_cf,@p_ssd_cf,@p_erreur output
  if @erreur!=0
	begin
	  select @p_erreur="20001 APPLICATIF;TCTRULT;"+ convert(varchar(10),@erreur)+";"
    goto fin
	end
end

NoSections:
if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
if object_id('dbo.PiESTIMA_01') IS NOT null
  print '<<< CREATED PROC dbo.PiESTIMA_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PiESTIMA_01 >>>'
go
grant execute on dbo.PiESTIMA_01 TO GOMEGA
go
