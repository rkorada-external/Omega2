use BEST
go

if object_id('dbo.PtLIFEST_01') IS NOT null
begin
  drop procedure dbo.PtLIFEST_01
  if object_id('dbo.PtLIFEST_01') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PtLIFEST_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PtLIFEST_01 >>>'
end
go

create procedure PtLIFEST_01 (
                @p_end_nt       UEND_NT = 0,
                @p_sec_nf       USEC_NF = 0,
                @p_uw_nt        UUW_NT  = 0,
                @p_uwy_nf       UUWY_NF = 0,
                @p_ssd_cf       USSD_CF = 0,
                @p_ctr_nf       UCTR_NF = '',
                @p_type_calcul  varchar(4))
as

/***************************************************

Programme               : PtLIFEST_01
Fichier script associé  : PtLIFEST_01.PRC
Domaine                 : (EST) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  : Tony RIPERT
Date de creation        : 08 Juillet 2010
Description du programme:

 	ESTIMATIONS VIE : Calcul les montants (acmtrs_nt=1900) ou pour-millième (acmtrs_nt=1901) des dépots

Parametres              :

       @p_end_nt        UEND_NT,
       @p_sec_nf        USEC_NF,
       @p_uw_nt         UUW_NT,
       @p_uwy_nf        UUWY_NF,
       @p_ssd_cf  		  USSD_CF,
   	   @p_ctr_nf        UCTR_NF,
       @p_type_calcul  	int

Conditions d'execution  :
Commentaires            :
_________________
MODIFICATION 1

Auteur                  :	TRIPERT
Date                    :	04/01/2011
Version                 : 10
Description             : Ne par faire le lien avecc le mois bilan
_________________
MODIFICATION  2
Auteur: P. COPPIN
Date: 16/10/2013
Description: :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
*****************************************************/

/*Dépots*/
If @p_type_calcul = '0001'
BEGIN
  	/* Création de la table de travail #TLIFEST */
	CREATE TABLE #TLIFEST
	(
		CTR_NF       UCTR_NF    NOT NULL,
		END_NT       UEND_NT    NOT NULL,
		SEC_NF       USEC_NF    NOT NULL,
		UWY_NF       UUWY_NF    NOT NULL,
		UW_NT        UUW_NT     NOT NULL,
		CRE_D        UUPD_D     NOT NULL,
		BALSHEY_NF   smallint   NOT NULL,
		BALSHTMTH_NF tinyint    NOT NULL,
		ACY_NF       smallint   NOT NULL,
		PRS_CF       smallint   NOT NULL,
		ACMTRS_NT    smallint   NOT NULL,
		SSD_CF       USSD_CF    NOT NULL,
		ESTMNT_M     UAMT_M     NOT NULL,
		ESTMNT_C     UAMT_M     NOT NULL,    
		ESTMNTTOT_M  UAMT_M     NOT NULL    
	)
 
	
	-- Récupérer les postes 1900 et 1901
	insert into #TLIFEST
	select  distinct
	        A.CTR_NF,
	        A.END_NT,
	        A.SEC_NF,
	        A.UWY_NF,
	        A.UW_NT,
	        A.CRE_D,
	        A.BALSHEY_NF,
	        A.BALSHTMTH_NF,
	        A.ACY_NF,
	        A.PRS_CF,
	        A.ACMTRS_NT,
	        A.SSD_CF,
	        A.ESTMNT_M,
	        0,
	        0
	  from    best..tlifest A, BREF..TBATCHSSD T
	where   acmtrs_nt in (1900, 1901)
	and     oricod_ls <> 'CALC'
	
   and A.SSD_CF = T.SSD_CF
   and T.BATCHUSER_CF = suser_name()
	
	and     CRE_D = ( select  max(cre_d)
	                  from    best..tlifest b
	                  where   A.CTR_NF = b.CTR_NF
	                  and     A.END_NT = b.END_NT
	                  and     A.SEC_NF = b.SEC_NF
	                  and     A.UWY_NF = b.UWY_NF
	                  and     A.UW_NT  = b.UW_NT
	                  and     A.ACY_NF = b.ACY_NF
	                  and     A.acmtrs_nt = b.acmtrs_nt )                              	                  

	-- Récupérer les postes 1900 et 1901
	insert into    #TLIFEST               
	select  distinct
	          A.CTR_NF,
	          A.END_NT,
	          A.SEC_NF,
	          A.UWY_NF,
	          A.UW_NT,
	          A.CRE_D,
	          A.BALSHEY_NF,
	          A.BALSHTMTH_NF,
	          A.ACY_NF,
	          A.PRS_CF,
	          A.ACMTRS_NT,
	          A.SSD_CF,
	          A.ESTMNT_M,
	          0,
	          0
	  from    best..tlifest A, BREF..TBATCHSSD T
	  where   acmtrs_nt in (2900, 2901)
	  and     oricod_ls <> 'CALC'

     and A.SSD_CF = T.SSD_CF
     and T.BATCHUSER_CF = suser_name()

	  and     CRE_D = ( select  max(cre_d)
	                    from    best..tlifest b
	                    where   A.CTR_NF = b.CTR_NF
	                    and     A.END_NT = b.END_NT
	                    and     A.SEC_NF = b.SEC_NF
	                    and     A.UWY_NF = b.UWY_NF
	                    and     A.UW_NT  = b.UW_NT
	                    and     A.ACY_NF = b.ACY_NF
	                    and     A.acmtrs_nt = b.acmtrs_nt )                              


-- Ajout les postes manquants          
	insert into    #TLIFEST               
	select  distinct
		A.CTR_NF,
		A.END_NT,
		A.SEC_NF,
		A.UWY_NF,
		A.UW_NT,
		A.CRE_D,
		A.BALSHEY_NF,
		A.BALSHTMTH_NF,
		A.ACY_NF,
		A.PRS_CF,
		A.ACMTRS_NT,
		A.SSD_CF,
		A.ESTMNT_M,
		0,
		0
	 FROM	best..tlifest a, 
	      #TLIFEST      b,
	      best..taccpar c
	 WHERE	a.ctr_nf = b.ctr_nf
	 and    	a.sec_nf = b.sec_nf
	 and    	a.uwy_nf = b.uwy_nf
	 and    	a.ACY_NF = b.acy_nf
	 and    	a.BALSHEY_NF = b.BALSHEY_NF
	 --and    	a.BALSHTMTH_NF = b.BALSHTMTH_NF
	 AND     a.acmtrs_nt = c.acmtrs_nt
	 and		 a.cre_d = (select 	max(cre_d) from best..tlifest d
	 										where		a.ctr_nf = d.ctr_nf
	                    and     A.END_NT = d.END_NT	 										
	 										and			a.sec_nf = d.sec_nf
	 										and			a.uwy_nf = d.uwy_nf
	                    and     A.UW_NT  = d.UW_NT	 										
	 										and			a.acy_nf = d.acy_nf
	 										and			a.acmtrs_nt = d.acmtrs_nt)
	 AND     b.prs_cf    = 500
	 AND     c.sumrisk_b = 1
	 and     a.acmtrs_nt not in (1900,1901,2900,2901)

          
	-- Calcul la somme des postes 
	select	a.ctr_nf, a.sec_nf, a.end_nt, a.uwy_nf, a.uw_nt, a.acy_nf, a.BALSHEY_NF, a.BALSHTMTH_NF, sum(a.estmnt_m) total
	into 		#somme
	from 		#TLIFEST A
	where 	acmtrs_nt not in (1900,1901,2900,2901)
	group by a.ctr_nf, a.sec_nf, a.end_nt, a.uwy_nf, a.uw_nt, a.acy_nf, a.BALSHEY_NF, a.BALSHTMTH_NF
   
   -- Mise jour la somme
	update	#TLIFEST
	set     	ESTMNTTOT_M = total
	from		#TLIFEST A,  #somme B
	where 	a.acmtrs_nt in (1900,1901,2900,2901)
	and 		a.ctr_nf = b.ctr_nf
	and 		a.sec_nf = b.sec_nf
	and 		a.uwy_nf = b.uwy_nf
	and 		a.acy_nf = b.acy_nf
	and    	a.BALSHEY_NF = b.BALSHEY_NF
	--and    	a.BALSHTMTH_NF = b.BALSHTMTH_NF    

	update #TLIFEST
	set ESTMNT_C = convert(FLOAT,(ESTMNT_M * ESTMNTTOT_M)/1000)
	where acmtrs_nt in (1901,2901)

	update #TLIFEST
	set ESTMNT_C = convert(FLOAT,(ESTMNT_M / ESTMNTTOT_M)*1000)
	where acmtrs_nt in (1900, 2900)
	and ESTMNTTOT_M is not null
	and ESTMNTTOT_M > 0
    
	update #TLIFEST
	set acmtrs_nt = acmtrs_nt + 2
	where acmtrs_nt in (1900, 2900)    
	
	update #TLIFEST
	set acmtrs_nt = acmtrs_nt - 1
    
	UPDATE    BEST..TLIFEST
	SET       a.estmnt_m = estmnt_c, oricod_ls = 'CALC'
	FROM      BEST..TLIFEST A, #TLIFEST B
	WHERE     a.CTR_NF = B.CTR_NF
	AND       a.SEC_NF = B.SEC_NF
	AND       a.end_nt = b.end_nt
	AND       a.uwy_nf = b.uwy_nf
	AND       a.uw_nt  = b.uw_nt
	AND       a.acy_nf = b.acy_nf
	AND       a.acmtrs_nt = b.acmtrs_nt
	AND       b.acmtrs_nt in (1900,1901,2900,2901)
END
go

if object_id('dbo.PtLIFEST_01') IS NOT null
    print '<<< CREATED procedure dbo.PtLIFEST_01 >>>'
else
    print '<<< FAILED CREATING procedure dbo.PtLIFEST_01 >>>'
go

grant execute on dbo.PtLIFEST_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtLIFEST_01 TO GDBBATCH
go

