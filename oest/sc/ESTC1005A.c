/*==============================================================================
Nom de l'application          : Filtre du fichier XADPERICASE pour eliminer les
                                affaires en retrocession interne
Nom du source                 : ESTM1005A.c
Revision                      : $Revision: 1.2 $
Date de creation              : 12/10/2019/
Auteur                        : M.NAJI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Filtre du fichier XADPERICASE pour eliminer les affaires en retrocession
  interne
  En entree : fichier DTSTATGTAAF Enrechi
  En sortie : fichier DSUMGTAA, IADPERICASE, IADPERIPRM, PERICASESNEM, DSUMGTAASNEM, _DSUMGTAAREC
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    25/03/2004    M. DJELLOULI  Modification sur POSTES 10301 & 10311 - MOD01
    30/08/2004    M. DJELLOULI  SPOT 10422 - Modification des Date D'effet, Date d'échéance,    MOD02
                                            Durée des Polices, et Taux de Polices,
                                            pour LOB = '04' et SSD_CF = 2, 3, 12     ...           ...            ...              ...
    21/04/2005    M.DJELLOULI  SPOT 11416 - MOD03
                                          Pour charger Omega SAR, plutôt que de ne prendre que les provisions de clôture sur
                                          le bilan sauf les ouvertures on prend également les ouvertures pour les postes suivants :
                                          10321, 10331, 10341, 10351, 14201, 42181, 42411, 42891, 45101.

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[XX] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[XX] 19/02/2015 F Maragnes :spot:28305 Ajout  Determination des sous code de regroupement pour distinguer les comptes complets/incomplet, sinistre paye/a payer
[07] 05/02/2016  Florent   :spot:29066 enlever le define du GT
[08] 18/12/2019  M.NAJI    : Optimisation en enlevant les fichier binaire
[09] 08/02/2021 MZM        : Spira 78325 Brokerage REC Absents
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputDSUMGTAA; /* Pointeur sur le fichier de sortie */
FILE    		*Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT */
FILE 		   *Kp_OutputFilGtRI; /* Pointeur sur le fichier de sortie2 traites terminés (MOD06)  */
FILE 		   *Kp_OutputFilGtREC; /* Pointeur sur le fichier de sortie */


#define GT_PER_NAT_CF  		71
#define GT_PER_CTRNAT_CT    72
#define GT_PER_UWORG_CF	 	73
#define GT_PER_EGPCUR_CF    74
#define GT_PER_SECACCSTS_CT 75
#define GT_PER_PCPRSKTRY_CF 76 
//#define GT_PER_EGPCUR_RATE  77
#define GT_PER_LOB_CF       78
#define GT_PER_RECBRK_B		79
#define GT_CMP_ACY_NF 		80
#define GT_CMP_SCOENDMTH_NF 81
#define DETTRS_TRSTYP_CT 	82
#define TRSLNK_ACMTRS_NT 	83
#define GT_CUR_RATE      	84
#define GT_PER_EGPCUR_RATE  85



/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionLigneGt(  char **ptb_InRecOwner ) ;

double d_GetTaux(
        char* sz_RateOrig, /* Cours d'origine */
        char* sz_RateDest  /* Cours destination */
        );

char Ksz_AnneeBilan[5];
/**************************************************************************/
/*** Objet : Filtrage du fichier XADPERICASE			***/
/***									***/
/*** Nom : main		     						***/
/***									***/
/*** Parametres:							***/
/***	i argc : nombre de parametres					***/
/***	i argv : tableau de pointeurs sur les parametres		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int main(
   int argc,
   char *argv[]
)
{
   T_RUPTURE_VAR bd_Rupture;

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

	sprintf(Ksz_AnneeBilan, "%s", psz_GetCharArgv(1));
/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC1005A_O1", "wt", &Kp_OutputFilGt) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }
   if (n_OpenFileAppl("ESTC1005A_O2", "wt", &Kp_OutputFilGtRI) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }
   if (n_OpenFileAppl("ESTC1005A_O3", "wt", &Kp_OutputFilGtREC) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }
  


/* Initialisation de la structure de rupture */
   if (n_InitRupture(&bd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(&bd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC1005A_I1", &(bd_Rupture.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC1005A_O1", &Kp_OutputFilGt) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }
   if (n_CloseFileAppl("ESTC1005A_O2", &Kp_OutputFilGtRI) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC1005A_O3", &Kp_OutputFilGtREC) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }


   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

  
   exit(OK);
}




/**************************************************************************/
/*** Objet : initialisation de la structure de rupture			***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Rupture : pointeur sur la structure de rupture		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupt
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

   
    /* ouverture du fichier esclave Primes et sinistres ultimes */
  if ( n_OpenFileAppl( "ESTC1005A_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    RETURN_VAL (ERR )  ;

  /* nombre de rupture a gerer sur le fichier de travail */
  pbd_Rupt->n_NbRupture = 0 ;

  pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

  pbd_Rupt->c_Separ = '~' ;


   RETURN_VAL(OK);
}





/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(  char **ptb_InRecOwner ) /* adresse de la ligne de l'esclave */
{
  double d_Amt ;   /* montant acceptation */
  double d_Ratio ; /* ratio: devise acceptation/devise aliment */
  long  l_AcmTrs ; /* poste cumul */
  short n_type;
  int n_poste;


  
  char  MsgAno[300] ; /* message d'anomalie */

  DEBUT_FCT( "n_ActionLigneGt" ) ;

  /* Récupération du type de poste ds DETTRS */
  //n_type = n_TypePoste(ptb_InRecOwner[GT_TRNCOD_CF], Kp_Dettrs);

  n_type = *ptb_InRecOwner[DETTRS_TRSTYP_CT] ? atoi(ptb_InRecOwner[DETTRS_TRSTYP_CT]) : 0 ;

  /*
  ** On ne cumule que les provisions du bilan hors L0. Les provisions sont identifiées
  ** grace au TRSTYP_CF (=3) de TDETTRS et les libérations d'ouverture à ne pas cumuler
  ** sont telles que leur suffixe=1 & TRNCOD[3-7] dans {LST}
  */
  //n_poste = 10000 * INT(ptb_InRecOwner[GT_TRNCOD_CF][2]) +
  //          1000 * INT(ptb_InRecOwner[GT_TRNCOD_CF][3]) +
  //          100 * INT(ptb_InRecOwner[GT_TRNCOD_CF][4]) +
  //          10 * INT(ptb_InRecOwner[GT_TRNCOD_CF][5]) +
  //          INT(ptb_InRecOwner[GT_TRNCOD_CF][6]);

  char sz_poste [8] ;
  strcpy(  sz_poste , ptb_InRecOwner[GT_TRNCOD_CF]+2) ;
  sz_poste[5] = 0 ;
  n_poste = atoi(sz_poste) ;
  
  /* MOD01 - Ajout des POSTES 10301 & 10311 */
  /* MOD02 - 10321, 10331, 10341, 10351, 14201, 42181, 42411, 42891, 45101 */
  if(
		( *ptb_InRecOwner[GT_PER_CTRNAT_CT] == 'P' ) ||
		( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) == 40 ) ||
		( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) == 41 ) ||
		!(
			(
				n_type == 3 && atoi(ptb_InRecOwner[GT_BALSHEY_NF]) < atoi(Ksz_AnneeBilan)
			) ||
			(
				n_type == 3 &&  (
									ptb_InRecOwner[GT_TRNCOD_CF][7] == '1' ||
									(
										n_poste == 41101 || n_poste == 41901 || n_poste == 42101 ||
										n_poste == 42111 || n_poste == 42141 || n_poste == 42151 ||
										n_poste == 42161 || n_poste == 42191 || n_poste == 42801 ||
										n_poste == 43101 || n_poste == 43701 || n_poste == 44101 ||
										n_poste == 48101 || n_poste == 48111 || n_poste == 48801 ||
										n_poste == 42401 || n_poste == 48121 || n_poste == 10301 ||
										n_poste == 10311 || n_poste == 10321 || n_poste == 10331 ||
										n_poste == 10341 || n_poste == 10351 || n_poste == 14201 ||
										n_poste == 42181 || n_poste == 42411 || n_poste == 42891 ||
										n_poste == 45101
									)
								)
				
			)
		)
	) 
	{
		
		/* affectation du montant acceptation */
		d_Amt = atof( ptb_InRecOwner[GT_AMT_M] ) ;

		/* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
		//i = n_RechPoste(ptb_InRecOwner[GT_TRNCOD_CF]) ;
		//if (i == -1) l_AcmTrs = 0 ;
		//else l_AcmTrs = Ktbd_TrsLnk[i].ACMTRS_NT ;

		if (*ptb_InRecOwner[TRSLNK_ACMTRS_NT] == 0 ) l_AcmTrs = 0;
		else l_AcmTrs = atoi(ptb_InRecOwner[TRSLNK_ACMTRS_NT]) ;

		/* test: compte complet ? */
		if ( ( ( *ptb_InRecOwner[GT_PER_CTRNAT_CT] == 'P' ) ||
			   (( *ptb_InRecOwner[GT_PER_CTRNAT_CT] == 'N' ) &&
				(( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) == 40 ) || ( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) == 41 )))
			 )
			 && l_AcmTrs == 20000 )
		{
			
			
			
		  if( ( atoi( ptb_InRecOwner[GT_ACY_NF] ) < atoi( ptb_InRecOwner[GT_CMP_ACY_NF] )  ) ||
			  ( (  strcmp(ptb_InRecOwner[GT_ACY_NF],ptb_InRecOwner[GT_CMP_ACY_NF] ) == 0  ) &&
				( atoi( ptb_InRecOwner[GT_SCOENDMTH_NF] ) <= atoi( ptb_InRecOwner[GT_CMP_SCOENDMTH_NF] ) ) 
			  ) 
			)
		  {
			if (atof( ptb_InRecOwner[GT_TRNCOD_CF] ) > 11329999 )
			{
			  l_AcmTrs = -20030 ;
			}
			else
			{
			  l_AcmTrs = -20000 ;
			}
		  }
		}

		/*FCharles en NP hors stop loss et annual aggregate tout est complet */
		/*ceci pour la ventilation du ESTC0626 */
		if ( ( ( *ptb_InRecOwner[GT_PER_CTRNAT_CT] == 'N' ) &&
			   (( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) != 40 ) &&
				( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) != 41 ))
			 ) && l_AcmTrs == 20000 )
		{
		  l_AcmTrs = -20030 ;
		}




		if ( ( ( *ptb_InRecOwner[GT_PER_CTRNAT_CT] == 'P' ) ||
			   (( *ptb_InRecOwner[GT_PER_CTRNAT_CT] == 'N' )  &&
				(( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) == 40 ) || ( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) == 41 )))
			 )
			 && l_AcmTrs == 20500 )
		{


		  if( ( atoi( ptb_InRecOwner[GT_ACY_NF] ) < atoi( ptb_InRecOwner[GT_CMP_ACY_NF] )  ) ||
			  ( (  strcmp(ptb_InRecOwner[GT_ACY_NF],ptb_InRecOwner[GT_CMP_ACY_NF] ) == 0  ) &&
				( atoi( ptb_InRecOwner[GT_SCOENDMTH_NF] ) <= atoi( ptb_InRecOwner[GT_CMP_SCOENDMTH_NF] ) ) 
			  ) 
			)
		  {
			if (atof( ptb_InRecOwner[GT_TRNCOD_CF] ) > 11329999 )
			{
			  l_AcmTrs = -20530 ;
			}
			else
			{
			  l_AcmTrs = -20500 ;
			}
		  }
		}

		/*FCharles en NP hors stop loss et annual aggregate tout est complet */
		/*ceci pour la ventilation du ESTC0626 */
		if ( ( ( *ptb_InRecOwner[GT_PER_CTRNAT_CT] == 'N' ) &&
			   (( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) != 40 ) &&
				( atoi( ptb_InRecOwner[GT_PER_NAT_CF] ) != 41 ))
			 ) && l_AcmTrs == 20500 )
		{
		  l_AcmTrs = -20530 ;
		}

		/* conversion du montant acceptation en devise aliment */
		if ( strcmp( ptb_InRecOwner[GT_CUR_CF], ptb_InRecOwner[GT_PER_EGPCUR_CF] ) != 0 )
		{
		  //d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecOwner[GT_SSD_CF] ),
		  //                     atoi( ptb_InRecOwner[GT_BALSHEY_NF] ), ptb_InRecOwner[GT_CUR_CF], ptb_InRecOwner[GT_PER_EGPCUR_CF] ) ;

			d_Ratio = strcmp(ptb_InRecOwner[GT_PER_EGPCUR_CF],ptb_InRecOwner[GT_CUR_CF]) == 0 ? 1 :  d_GetTaux(
																						ptb_InRecOwner[GT_PER_EGPCUR_RATE], 
																						ptb_InRecOwner[GT_CUR_RATE]  
																						);
			/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
			if ( d_Ratio < 0 )
			{
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the accounting transaction ( SSD %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - Balance sheet date %s/%s/%s - TRNCOD %s - ACY %s - accounting period %s/%s ) \n",
					 ptb_InRecOwner[GT_CUR_CF],  ptb_InRecOwner[GT_PER_EGPCUR_CF], ptb_InRecOwner[GT_SSD_CF],
					 ptb_InRecOwner[GT_CTR_NF],  ptb_InRecOwner[GT_END_NT], ptb_InRecOwner[GT_SEC_NF],
					 ptb_InRecOwner[GT_UWY_NF],  ptb_InRecOwner[GT_UW_NT] , ptb_InRecOwner[GT_BALSHRDAY_NF],
					 ptb_InRecOwner[GT_BALSHRMTH_NF], ptb_InRecOwner[GT_BALSHEY_NF], ptb_InRecOwner[GT_TRNCOD_CF],
					 ptb_InRecOwner[GT_ACY_NF], ptb_InRecOwner[GT_SCOSTRMTH_NF], ptb_InRecOwner[GT_SCOENDMTH_NF] ) ;
			n_WriteAno( MsgAno ) ;

			/* montant positionne a zero */
			d_Amt = 0 ;
			}
			else d_Amt *= d_Ratio ;
		}


		  //if (( l_AcmTrs != 0 ) && Kb_cond ) Kb_cond toujours vrai
		if ( l_AcmTrs != 0   ) 
		{

			fprintf(Kp_OutputFilGt,
				"%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%ld~%-.3f~%s~%s\n",
				ptb_InRecOwner[GT_SSD_CF],
				ptb_InRecOwner[GT_ESB_CF],
				ptb_InRecOwner[GT_CTR_NF],
				ptb_InRecOwner[GT_END_NT],
				ptb_InRecOwner[GT_SEC_NF],
				ptb_InRecOwner[GT_UWY_NF],
				ptb_InRecOwner[GT_UW_NT],
				ptb_InRecOwner[GT_OCCYEA_NF],
				ptb_InRecOwner[GT_ACY_NF],
				ptb_InRecOwner[GT_SCOSTRMTH_NF],
				ptb_InRecOwner[GT_SCOENDMTH_NF],
				ptb_InRecOwner[GT_CLM_NF],
				ptb_InRecOwner[GT_CED_NF],
				ptb_InRecOwner[GT_BRK_NF],
				ptb_InRecOwner[GT_PAY_NF],
				ptb_InRecOwner[GT_KEY_NF],
				l_AcmTrs,
				d_Amt ,
				ptb_InRecOwner[GT_PER_EGPCUR_CF],
				ptb_InRecOwner[GT_PER_SECACCSTS_CT]);


		   /* L'ensemble des postes comptable de courtage se trouve dans le poste de regroupement 10400
			 Le courtage sur prime de REC 11140100 se trouve dans le poste 10400 et 10401
			 Si le poste comptable a ete trouve une premiere fois associe au poste 10400, on verifie
			 si il fait partie du poste 10401 plus restrictif, et on met de cote les montants correspondant au courtage sur prime de REC */
			//if ( l_AcmTrs == 10400 )
			//{
			//  if ( n_RechPoste_CourtageREC(ptb_InRecChild[GT_TRNCOD_CF], 10401 ) == TRUE )
			//    CC_Amt_REC += d_Amt;
			//}
		  
			  
		}
		  
		 

		int b_condRI ;
		b_condRI = ( 	(	(strcmp(ptb_InRecOwner[GT_PER_PCPRSKTRY_CF], "FRA") == 0) 	&& 
							(strcmp(ptb_InRecOwner[GT_PER_LOB_CF], "04") == 0) 			&&
							//(strcmp(ptb_InRec_Cur[PER_CTRRET_B], "0") == 0) 		&& 
							(	atoi(ptb_InRecOwner[GT_SSD_CF]) == 2 || 
								atoi(ptb_InRecOwner[GT_SSD_CF]) == 3 || 
								atoi(ptb_InRecOwner[GT_SSD_CF]) == 12
							)
						)&&
						(	
							(strcmp(ptb_InRecOwner[GT_CTR_NF], "02Z041517")
							)&&
							( strcmp(ptb_InRecOwner[GT_CTR_NF], "02G0X7677") || strcmp(ptb_InRecOwner[GT_UWY_NF], "1993"))
						)
				  );
			  
		if 
		(	( l_AcmTrs == 20000 || l_AcmTrs == -20000 || l_AcmTrs == -20030 ||
			  l_AcmTrs == 10000 || l_AcmTrs == 10010 || l_AcmTrs == 10020 || l_AcmTrs == 10030 || l_AcmTrs == 10130 ||
			  l_AcmTrs == 10430 || l_AcmTrs == 10040 || l_AcmTrs == 28030 || l_AcmTrs == -20500 || l_AcmTrs == -20530 || l_AcmTrs == 20500  
			) && b_condRI 
		) 
		{
			
			 fprintf(Kp_OutputFilGtRI,
				"%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%ld~%-.3f~%s~%s\n",
				ptb_InRecOwner[GT_SSD_CF],
				ptb_InRecOwner[GT_ESB_CF],
				ptb_InRecOwner[GT_CTR_NF],
				ptb_InRecOwner[GT_END_NT],
				ptb_InRecOwner[GT_SEC_NF],
				ptb_InRecOwner[GT_UWY_NF],
				ptb_InRecOwner[GT_UW_NT],
				ptb_InRecOwner[GT_OCCYEA_NF],
				ptb_InRecOwner[GT_ACY_NF],
				ptb_InRecOwner[GT_SCOSTRMTH_NF],
				ptb_InRecOwner[GT_SCOENDMTH_NF],
				ptb_InRecOwner[GT_CLM_NF],
				ptb_InRecOwner[GT_CED_NF],
				ptb_InRecOwner[GT_BRK_NF],
				ptb_InRecOwner[GT_PAY_NF],
				ptb_InRecOwner[GT_KEY_NF],
				l_AcmTrs,
				d_Amt,
				ptb_InRecOwner[GT_PER_EGPCUR_CF],
				ptb_InRecOwner[GT_PER_SECACCSTS_CT]);
		  
		}		


}

  
	double d_CC_REC_Amt =0 ;
	
	//[09]if ( l_AcmTrs == 10400  && strcmp(ptb_InRecOwner[TRSLNK_ACMTRS_NT],"10401") == 0  )
	if ( strcmp(ptb_InRecOwner[TRSLNK_ACMTRS_NT],"10401") == 0  )
	{
		d_CC_REC_Amt = d_Amt;
	}
	if ( strcmp( ptb_InRecOwner[GT_PER_RECBRK_B], "1" )  == 0  &&  strcmp(  ptb_InRecOwner[GT_PER_SECACCSTS_CT],"9") != 0)
		/*ajout une colonne pour retintamt_m */
		fprintf(Kp_OutputFilGtREC,
			"%s~%s~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%d~%-.3f~%s~%s\n",
			ptb_InRecOwner[GT_SSD_CF],
			ptb_InRecOwner[GT_ESB_CF],
			ptb_InRecOwner[GT_CTR_NF],
			ptb_InRecOwner[GT_END_NT],
			ptb_InRecOwner[GT_SEC_NF],
			ptb_InRecOwner[GT_UWY_NF],
			ptb_InRecOwner[GT_UW_NT],
			ptb_InRecOwner[GT_OCCYEA_NF],
			ptb_InRecOwner[GT_ACY_NF],
			ptb_InRecOwner[GT_SCOSTRMTH_NF],
			ptb_InRecOwner[GT_SCOENDMTH_NF],
			ptb_InRecOwner[GT_CLM_NF],
			ptb_InRecOwner[GT_CED_NF],
			ptb_InRecOwner[GT_BRK_NF],
			ptb_InRecOwner[GT_PAY_NF],
			ptb_InRecOwner[GT_KEY_NF],
			10401,
			d_CC_REC_Amt,
			ptb_InRecOwner[GT_PER_EGPCUR_CF],
			ptb_InRecOwner[GT_PER_SECACCSTS_CT]);
	
  RETURN_VAL( OK ) ;
}






/*==============================================================================
objet :
   Traitement d'une ligne, r¦sultat du SELECT de la proc. ps_UTCTLIB_Example_out

retour :
        retourne le cours de la devise d'origine sur le cours de la devise
        destination.
        si la devise destination est nulle la fonction retourne le cours de
        la devise d'origine
        elle retourne une valeur negative ou nulle en cas de probleme
==============================================================================*/
double d_GetTaux(
        char* sz_RateOrig, /* Cours d'origine */
        char* sz_RateDest  /* Cours destination */
        )
{
// [010]p

    DEBUT_FCT ( "d_GetTaux" );

    if( *sz_RateOrig == 0 || atof(sz_RateOrig) <= 0)
        RETURN_VAL ( (double)(-1));
    if( *sz_RateDest == 0 || atof(sz_RateDest) <= 0)
        RETURN_VAL ( (double)(-1));

  RETURN_VAL(  atof(sz_RateDest)/atof(sz_RateOrig));
}




