use BCTA
go
/*
 * DROP PROC PsBALAGEE_06
 */
IF OBJECT_ID('PsBALAGEE_06') IS NOT NULL
BEGIN
    DROP PROC PsBALAGEE_06
    PRINT '<<< DROPPED PROC PsBALAGEE_06 >>>'
END
go

/*
 * creation de la procedure
*/
create proc PsBALAGEE_06
@yea_nf            smallint,
@mth_nf            tinyint,
@simulation        char          -- [001]
with execute as caller as

/***************************************************
Fichierscript associé : balagee6.prc
Base principale :       BCTA
Version:                1.00
Auteur:                 JFrançois van de velde
Date de creation:       11/07/2000
Description de la procedure : Extraction de la date du taux de convertion
                              En cas de reussite, elle retourne la valeur 0
                              Sinon 1.
Parametres:
  entree  :
  sortie  : neant
Conditions d'execution:
Commentaires:
_________________
MODIFICATION [001]

Auteur:       D.GATIBELZA
Date:         03/12/2002
Version:      1.00
Description:  ajout du paramètre: @simulation char
              on récupère les derniers taux connus dans le cas d'une simulation
_________________
MODIFICATION [002]

Auteur:       jf VDV
Date:         12/12/2008
Description   [SPOT16619] Problème de source lors de la dernière livraison du 13/03/2008 SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
                          Action: reprise de la version de PROD_V06_1.1.1.1 avec ajout des modif de la fiche SPOT15180. 
_________________                                                                                                                                                         
MODIFICATION [003]                                                                                                                                                        
                                                                                                                                                                          
Auteur:       jf VDV                                                                                                                                                      
Date:         03/12/2010                                                                                                                                                  
Description   [SPOT20875] pour l'extraction du cours de change, ne pas prendre en compte les filiales 98 et 99.                                                   
_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’        
_________________
MODIFICATION 004
Author:      Prajakta
Date:        09/09/2013
Description: Data selection changes
                  
*************************************************************************/

/* [001] ----------------------*/
if ( @simulation = 'Y')
begin
    INSERT INTO BTRAV..TRGLBALAGEQUOT
    select
        SSD_CF = a.SSD_CF,
        CUR_CF = a.CUR_CF,
        EXC_D  = max(a.EXC_D),
        EXC_R  = 0.000
    from BREF..TCURQUOT a
	,BREF..TBATCHSSD TSSD						-- Modification 004
    where a.ssd_cf not in (98,99)	-- [20875]
	and a.ssd_cf = TSSD.ssd_cf           		-- Modification 004
	and TSSD.BATCHUSER_CF = suser_name()		-- Modification 004
    group by a.SSD_CF,a.CUR_CF
    order by a.SSD_CF,a.CUR_CF   -- [spot15180]
end
else
begin
    if ( @mth_nf = 12)
    begin
        select @mth_nf=1

        INSERT INTO BTRAV..TRGLBALAGEQUOT
        select
        	SSD_CF = a.SSD_CF,
        	CUR_CF = a.CUR_CF,
        	EXC_D  = max(a.EXC_D),
        	EXC_R  = 0.000
        from BREF..TCURQUOT a
		,BREF..TBATCHSSD TSSD							-- Modification 004
        where a.exc_d = dateadd(dd,-1,convert(datetime,convert(char(8),(@yea_nf+1)*10000+@mth_nf*100+01,102)))
        and   a.ssd_cf not in (98,99)	-- [20875]
			and a.ssd_cf = TSSD.ssd_cf           		-- Modification 004
			and TSSD.BATCHUSER_CF = suser_name()		-- Modification 004
        group by a.SSD_CF,a.CUR_CF
        order by a.SSD_CF,a.CUR_CF      -- [spot15180]
    end
    else
    begin

        INSERT INTO BTRAV..TRGLBALAGEQUOT
        select
        	SSD_CF = a.SSD_CF,
        	CUR_CF = a.CUR_CF,
        	EXC_D  = max(a.EXC_D),
        	EXC_R  = 0.000
        from BREF..TCURQUOT a
		,BREF..TBATCHSSD TSSD							-- Modification 004
        where a.exc_d = dateadd(dd,-1,convert(datetime,convert(char(8),@yea_nf*10000+(@mth_nf+1)*100+01,102)))
        and   a.ssd_cf not in (98,99)	-- [20875]
		and a.ssd_cf = TSSD.ssd_cf           		-- Modification 004
		and TSSD.BATCHUSER_CF = suser_name()		-- Modification 004
        group by a.SSD_CF,a.CUR_CF
        order by a.SSD_CF,a.CUR_CF      -- [spot15180]
    end
end


update BTRAV..TRGLBALAGEQUOT
set EXC_R = a.EXC_R
from BREF..TCURQUOT a, BTRAV..TRGLBALAGEQUOT b
where a.EXC_D = b.EXC_D
and   a.SSD_CF = b.SSD_CF
and   a.CUR_CF = b.CUR_CF



/*--------------------------*/
/* FIN 'OK' DE LA PROCEDURE */
/*--------------------------*/
return 0

go
IF OBJECT_ID('PsBALAGEE_06') IS NOT NULL
    PRINT '<<< CREATED PROC PsBALAGEE_06 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsBALAGEE_06 >>>'
go
/*
 * Granting/Revoking Permissions on PsBALAGEE_06
 */
GRANT EXECUTE ON PsBALAGEE_06 TO GOMEGA
go



