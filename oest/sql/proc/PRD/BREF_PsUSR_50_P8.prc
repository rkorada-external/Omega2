use BREF
go
 
IF OBJECT_ID('dbo.PsUSR_50_P8') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsUSR_50_P8
    IF OBJECT_ID('dbo.PsUSR_50_P8') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsUSR_50_P8 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsUSR_50_P8 >>>'
END
go
/***********************************************************************
BREF..PsUSR_50_P8 20,"G051","20ZF28180",-1,-1,-1,1
BREF..PsUSR_50_P8 1,"ISSO","01F014127",-1,-1,-1,0
BREF..PsUSR_50_P8 4,"PH","04F000001",-1,-1,-1,0
BREF..PsUSR_50_P8 18,"S042","18ZF07822",-1,-1,-1,0
BREF..PsUSR_50_P8 2,"ISSO","TR0000001",-1,-1,-1,0

select * from BTRT..TCONTR where ctr_nf like 'TR%'

		\\saturne\home\scordev\gedo\work\sql\proc\BREF_PsUSR_50_P8.prc

Description :
			 Indique si l'utilisateur est habilitÚ Ó modifier
                les documents d'un dossierContrat

Parametres :
		        @p_session_ssd_cf = filiale de la session GED
      		    @p_usr_cf = login de l'utilisateur
				@p_ctr_nf = numÚro du contrat
		                @p_uwy_nf = exercice
                		@p_uw_nt = n¦ d'ordre
		                @p_end_nt = avenant

		                @p_uwy_nf= -1 reprÚsente la valeur 'tous exercices'
		                @p_uw_nt = -1 reprÚsente la valeur 'tous n¦ d'ordre'
		                @p_end_nt = -1 reprÚsente la valeur 'tous avenants'

				@p_confsec = 0 (non confidentiel secteur)
					   = 1 ( confidentiel secteur )
Valeurs de retour :
				0: utilisateur non habilitÚ
				1: utilisateur habilitÚ

Commentaires :

Historique :
001   MNA	26/3/2007	Version 1.00
            fusion des proc PsUsr_32 et PsUSR_36 : mêmes règle d'habilitaion 
            pour les contrats et les groupes
002   MNA   Fiche spot 15869 prise end compte des unités sur 4 chiffres
003   MNA   14/10/2008 Fiche spot 16212 ajout de la filiale 17 dans 
            le traitement européenne
004   MNA   Overture Pour La vie
005   MNA   conversion des unités o1 vers o2 :  2/1410 et 1/240 ==> 2/4801 et 1/4531
005   MNA   revue pour O2 1B
006   MNA   03/02/2015 Ajout du profil 'SOUSC' 
007   MNA   09/02/2015 gestion de l'unité 5352 pour les filiales 20 et 22 
***********************************************************************/
CREATE PROCEDURE PsUSR_50_P8
(
    @p_session_ssd_cf USSD_CF, 
	@p_usr_cf char(4),
	@p_ctr_nf char(10),
	@p_uwy_nf  int,
	@p_uw_nt int,
	@p_end_nt int,
	@p_confsec int
)
AS
BEGIN

    DECLARE
          @p_return_value int,
    			@p_ssd_cf USSD_CF,
    			@p_grpGED_cf UGRP_CF,
    			@p_grp_cf UGRP_CF,
    			@p_bureau char(1),
    			@p_app_cf char(3)

    -- initialement, l'utilsateur n'a pas le droit d'indexer
    select @p_return_value = 0

    -- recherche de la filiale et l'unité principale de l'utilisateur
    select  @p_ssd_cf    = ssd_cf, 
            @p_grp_cf    = grp_cf, 
            @p_grpGED_cf = grpged_cf 
    from    BREF..TUSR 
    where   usr_cf= @p_usr_cf


--   select "debug 01" , @p_return_value 

   -- Traitement des filales Européennes


        -- Remise à 0 des droits de l'utilisateur
--    select "debug  02" , @p_return_value 
        create table #tuwgrp
        (
          ssd_cf USSD_CF, 
          grp_cf UGRP_CF null   -- Modif 010
        )
    
        insert #tuwgrp
        select  SSD_CF,UWGRP_CF
        from    BTRT..TCONTR
        where   ctr_nf = @p_ctr_nf 
        AND     (uwy_nf = @p_uwy_nf or @p_uwy_nf = -1 )
        AND     (uw_nt = @p_uw_nt   or @p_uw_nt = -1 )
        AND     (end_nt = @p_end_nt or @p_end_nt = -1 )
    
        UNION
    
        select  SSD_CF,UWGRP_CF
        from    BFAC..TCONTR
        where   ctr_nf = @p_ctr_nf 
        AND     (uwy_nf = @p_uwy_nf or @p_uwy_nf = -1 ) 
        AND     (uw_nt = @p_uw_nt or @p_uw_nt = -1)
        AND     (end_nt = @p_end_nt or @p_end_nt = -1)
    
        UNION
    
        select  SSD_CF,UWGRP_NF
        from    BTRT..TBOQPRG
        where   grp_nf = @p_ctr_nf 
        AND     (uwy_nf = @p_uwy_nf or @p_uwy_nf = -1 ) 
    
        UNION
    
        select  SSD_CF,UWGRP_CF
        from    BFAC..TMASTER
        where   mas_nf = @p_ctr_nf 
        AND     (uwy_nf = @p_uwy_nf or @p_uwy_nf = -1 ) 
    
        
        
        
                -- quel est le type du contrat attach+ au document - indexer ?

        if @p_ctr_nf like"__[C-N]%"  or @p_ctr_nf like"__A%" or @p_ctr_nf like"F%" -- C'est uneFAC
            select @p_app_cf = "FAC"
        else
            select @p_app_cf = "TRT"

        -- l'utilisateur a t-il le droit d'indexer sur le contrat ?
        -- c-d a-t-il les droits suffisants sur le contrat dans OMEGA
        -- ou si le gestionnaire sinsitre a le profil GEDIND sur FAC ou TRT
        -- et  la filiale du contrat est celle de la session

        if ( exists ( select 1
                        from troles
                        where usr_cf = @p_usr_cf
                        and   app_cf = @p_app_cf
                        and  prf_cf in ("ADMSSD", "SUPERVIS", "GEDIND","TAC","SOUSC")
                    ) 
                    
                    and 
                    
              exists ( select 1
                        from #tuwgrp c
                        where @p_session_ssd_cf = c.ssd_cf
                    )
            )
            select @p_return_value = 1 -- l'utilisateur - les droits



    
    --select "debug 03" , @p_return_value 
    
         /* Si le document est confidentiel */
        if (@p_confsec = 1)
        begin
    
            -- Remise à 0 des droits de l'utilisateur
            select @p_return_value = 0
    
            /*
            Si confidentiel alors seuls les utilisateurs ayant leur boite GED = unité de souscription du contrat
            peuvent voir et modifier le doc et l'indexation du document
                */
            select  @p_return_value = 1
            from    #tuwgrp c
            where   @p_grpGED_cf = c.grp_cf
            AND     @p_ssd_cf    = c.ssd_cf
            
            /* utilisateurs de l'unité principale 2/1410 peuvent indexer en confidentiel sur la 1/240 tout en se servant
            toujours de leur unité 1410 pour continuer à indexer en confidentiel sur Paris*/
    
            
            -- 005
            if @p_ssd_cf = 2  and @p_grpGED_cf = 4801   --  2,1410 devient  2,4801 dans O2 
               select  @p_return_value = 1
                from    #tuwgrp c
                where   c.grp_cf = 4531      -- 240 devient 4531 dans o2
                AND     c.ssd_cf = 1
                
                
            /*Il faudrait coupler l’unité sinistre 5352 qui couvre le périmètre Asie avec les unités de souscription présente sur le
              périmètre des filiales 20 et 22. 5352 et 4093/4094/4095/4096/4098/4099/4100/4577/4578/4579/4580/4581/4584 */
            
            --007     
            if @p_ssd_cf in (20,22)  and @p_grpGED_cf = 5352 
               select  @p_return_value = 1
                from    #tuwgrp c
                where   c.grp_cf in( 5352,4093,4094,4095,4096,4098,4099,4100,4577,4578,4579,4580,4581,4584)
                AND     c.ssd_cf  in (20,22)
           
                
--   select "debug 04" , @p_return_value 
    
        end /* end du else de if @p_confsec = 1 */
    

    select @p_return_value

    RETURN 0

END


go
EXEC sp_procxmode 'dbo.PsUSR_50_P8','unchained'
go
IF OBJECT_ID('dbo.PsUSR_50_P8') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsUSR_50_P8 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsUSR_50_P8 >>>'
go
GRANT EXECUTE ON dbo.PsUSR_50_P8 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsUSR_50_P8 TO GCONSULT
go
