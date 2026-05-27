use BSTA
go
if object_id('BSTA.dbo.PiSEGBA_01') is not null
begin
  drop procedure dbo.PiSEGBA_01
  if object_id('dbo.PiSEGBA_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PiSEGBA_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PiSEGBA_01 >>>'
end
go
create procedure PiSEGBA_01
(
  @ssd_cf   integer,
  @segtyp_ct  char(1) --type de segment (A ou E ou S)
)
as
/********************************************************************************
Domaine : (ES) Estimation
Base principale : BSAR
Description : Création et affectation des affaires sans liens avec le portefeuille à des segments balai
Conditions d'execution : Valeurs de retour 0:  OK -1: Echec
Commentaires :
_________________
MODIFICATIONS
1	PADB    11/05/1998 version 1.00  Création
2	PADB    19/06/1998 Division des taux par 100 dans TSEGEST
3	PADB    26/06/1998 Majuscule pour les SEG_NF + retrait du CR format dos
4	PADB    30/06/1998 Monnaie de la filiale pour les segments balais
5	CHFL    08/08/2000 on insere dans TBOSEGMT les libelles des segments sans notion d'UWY
6 Florent 14/02/2012 :spot:23390 SOLVENCY II
7	RGANDHE 22/10/2013 do not add BALAIs and missing segments changes for EVO CARD TRA01
8 Florent 04/04/2014 :spot:25427 on remets les balais
9 Florent 16/10/2014 :spot:27466 on enlève les contrôles sur TCTRGRO, la gestion du segment balai
********************************************************************************/
declare @max_uwy  integer

begin TRANSACTION
--  MODIF DU 19/06 - DIVISION DES TAUX PAR 100
update BSAR..TSEGEST
 set LOSRAT_R=round(LOSRAT_R / 100,8)
  where SSD_CF = @ssd_cf
    and SEGTYP_CT = @segtyp_ct
    and AMORAT_CT = 'R'
if @@error!=0 goto ERREUR

if @segtyp_ct!='S'
begin
  --  MODIF DU 26/06 - on repere et on élimine le caractère "Retour charriot" dos si il existe en fin de seg_nf
  update BSAR..TCTRGRO
   set SEG_NF=substring(SEG_NF,1,datalength(ltrim(SEG_NF))-1)
    where SSD_CF=@ssd_cf
      and SEGTYP_CT = @segtyp_ct
      and convert(integer,convert(binary,substring(SEG_NF,datalength(ltrim(SEG_NF)),1))) = 218103808
  if @@error!=0 goto ERREUR

  --  MODIF DU 26/06 - on met tout les seg_nf en majuscule
  update BSAR..TCTRGRO
   set SEG_NF=upper(SEG_NF)
    where SSD_CF=@ssd_cf
      and SEGTYP_CT = @segtyp_ct
  if @@error!=0 goto ERREUR

  update BSAR..TLABOCY
   set SEG_NF=upper(SEG_NF)
    where SSD_CF=@ssd_cf
      and SEGTYP_CT = @segtyp_ct
  if @@error!=0 goto ERREUR

end

update BSAR..TSEGEST
 set SEG_NF=upper(SEG_NF)
  where SSD_CF=@ssd_cf
    and SEGTYP_CT=@segtyp_ct
if @@error!=0 goto ERREUR

commit TRANSACTION
return 0

ERREUR:
rollback TRANSACTION
return -1
go
if object_id('dbo.PiSEGBA_01') is not null
    print '<<< CREATED PROC dbo.PiSEGBA_01 >>>'
else
    print '<<< FAILED CREATING PROC dbo.PiSEGBA_01 >>>'
go
grant execute on dbo.PiSEGBA_01 TO GOMEGA
go
grant execute on dbo.PiSEGBA_01 TO GDBBATCH
go
