use BEST
go

if object_id('dbo.PsLIFPEN_02') IS NOT null
    begin
        drop procedure dbo.PsLIFPEN_02
        if object_id('dbo.PsLIFPEN_02') IS NOT null
            print '<<< FAILED DROPPING procedure dbo.PsLIFPEN_02 >>>'
        else
            print '<<< DROPPED procedure dbo.PsLIFPEN_02 >>>'
    end
go

create procedure PsLIFPEN_02 (@p_ret_nt smallint)
as

/**************************************************************************************

Domaine                     : Estimation
Base principale             : BEST
Auteur                      : Florent
Date de creation            : 08/07/2004
Description du programme    : estimation Vie, suivi dépassement du seuil
Conditions d'execution      : évènement open de l'objet application estimation
Commentaires                :
_________________
MODIFICATION            : 1
Auteur                  : G.BUISSON
Date                    : 03/06/2005
Description             : SPOT n° 11042
                          A l'ouverture de l'appli Estimation, n'afficher que le
                          nombre de messages correspondant à l'appli (acceptation
                          ou retrocession)

***************************************************************************************/

If @p_ret_nt = 1            -- Acceptation
    begin
        select Compte=count(*)
        from   BEST..TLIFPEN a
        where  USR_CF = suser_name()
        and    exists (select 1
                       from   BTRT..TCONTR b
                       where  a.CTR_NF = b.CTR_NF)
    end
Else
    begin
        select Compte=count(*)
        from   BEST..TLIFPEN a
        where  USR_CF = suser_name()
        and    exists (select 1
                       from   BRET..TRETCTR b
                       where  a.CTR_NF = b.RETCTR_NF)
    end

go

if object_id('dbo.PsLIFPEN_02') IS NOT null
  print '<<< CREATED procedure dbo.PsLIFPEN_02 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFPEN_02 >>>'
go

grant execute on dbo.PsLIFPEN_02 TO GOMEGA
go

