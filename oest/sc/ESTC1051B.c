/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION SOLVENCY
nom du source                 : ESTC1051.c
r�vision                      : $Revision: 1.0 $
date de cr�ation              : 20/04/2012
auteur                        : Roger Cassis
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spot:23802 - Ajout 8 informations au fichier format GT+3 cols
                 ACMTRS_NT,ACMAMT_MC,ACMCUR_CF,Seg,Lob,Nat,Type,Prs

------------------------------------------------------------------------------
historique des modifications :
[01] 29/08/2012 R. Cassis :spot:24041 - Solvency 2.
[02] 19/10/2012 -=Dch=-   :spot:24041 - Solvency 2.
[03]  20/01/2013 P. Pezout :spot:24698 ajout de la fonction is_TRT pour distinguer les natures P et F
[04]  20/01/2013 C. Despret :spot:25427 Modification de la fonction is_TRT pour distinguer les natures P et F pour 1B
                                        1er caractere du no de contrat = F->Facultative, T->Treaty                                          
[05]  12/05/2013 C. Despret :spot:25427 Passage de 20000 a 100000 pour la taille max du tableau des TRSLNK
[06]  09/01/2014 C. Despret :spot:28055 Suppression ecrasement memoire lors de l'affectation fin de ligne du tableau dans FilsSansPere
[07]  02/04/2015 P. Menant  :spot:26391 EST49, inclure les depots et les faire pointer vers des patterns CLACC ou CLRET
[08]  08/07/2015 Florent    :spot:29641 gestion retro interne
[09]  11/05/2016 S.Behague  :spot:30583 Spira 41148 
[10]  15/10/2018 C.Socie    IFRS17 EXT-IFRS17-903240 - REQ 10.03 - Cash flow: Flexibility on patterns to be apply on grouping 3 
[11]  27/06/2019 M.NAJI     IFRS17 optimisation , remove binary files
[12]  12/08/2020 JYP : SPIRA 89218 : taille tableau FBOPRSLNK
================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

#define GTSII_CURQUOT_RATE      51
#define GTSII_CURQUOT_RET_RATE  52
#define GTSII_TRSLNK_ACMTRS_NT  53
#define GTSII_FBOPRSLNK_ACMTRSL2_NT     54
#define GTSII_FBOPRSLNK_ACMTRSL3_NT     55
#define GTSII_FBOPRSLNK_TRNTYP_CT       56

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
//[005]
#define Kn_MaxPostes 100000	/* Le nombre max de postes est fixe a 100000 */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii; /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */
//FILE   *Kp_InputFilTrsLnk;  /* pointeur sur le fichier en entree des postes cumuls */
//FILE   *Kp_InputFilExc;     /* pointeur sur le fichier en entree des cours de change */

T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptStatGta; /* variable de gestion de la synchronisation avec le fichier DTSTATGTx */

T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];
int Kn_NbLigTrslnk;
int Kn_FBOTRSLNK ;   		/* compteur du nombre ligne chargees dans Ktbd_FBOTRSLNK */

/* [09] Objet  : FBOTRSLNK (Binaire) ** Entree : prg_I5 */

FILE *Kp_FBOTRSLNK;

int n_ChargerFBOTRSLNK();
//int n_RechTrn(char *sz_trn );
/* [09] */

int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLignePerUw     ( char **pbd_InRec_Cur );
int n_InitStatGta		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneStatGta   ( char **ptb_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncStatGta ( char **ptb_InRecOwner, char **pbd_InRecChild );
int n_ActionFilsSansPere(char **  ptb_InRecChild);
int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );

//int n_ChargerTRSLNK ( short s_TrtCod );
//int n_RechPoste     ( char *sz_poste );

char Ksz_Accret[2];          /* Type de fichier traité : Accept ou Retro (A/R) */
char Ksz_AnneeBilan[5];
char Ksz_Prs[4];
short s_Prs;

int  is_TRT(char *);
char * trim(char *); 
long   ligne=1;

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{

	/* Initialisation des signaux */
	InitSig ();

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* recuperation des arguments passes au programme */
	strcpy(Ksz_Accret,psz_GetCharArgv(1));
	strcpy(Ksz_AnneeBilan,psz_GetCharArgv(2));
	strcpy(Ksz_Prs,psz_GetCharArgv(3));
	s_Prs = atoi(Ksz_Prs);
//printf("==> s_prs %i\n",s_Prs);	

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	//if ( n_OpenFileAppl ( "ESTC1051B_I4","rb",&Kp_InputFilExc ) == ERR )
	//	ExitPgm( ERR_XX , "" );
    //
	///* ouverture du fichier en entree des postes cumuls FTRSLNK */
	//if ( n_OpenFileAppl ( "ESTC1051B_I3","rb",&Kp_InputFilTrsLnk ) == ERR )
	//	ExitPgm( ERR_XX , "" );
	//	
    //if (n_OpenFileAppl("ESTC1051B_I5", "rb", &Kp_FBOTRSLNK) == ERR )
    //    ExitPgm(ERR_XX ,"");
    //
    ///* Chargement du tableau TRSLNK pour les postes 750 */
    //Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();
    //if ( Kn_FBOTRSLNK == -1 )
    //		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ;
    //		
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1051B_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptStatGta */
	if ( n_InitStatGta( &bd_RuptStatGta ) )
		ExitPgm( ERR_XX , "" );

	/* Chargement des postes en memoire */
	//Kn_NbLigTrslnk = n_ChargerTRSLNK( s_Prs );  // 750 remplace par variable

	//if ( Kn_NbLigTrslnk > Kn_MaxPostes )
	//		ExitPgm( ERR_XX , "" );

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1051B_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1051B_I2", &( bd_RuptStatGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	//if ( n_CloseFileAppl( "ESTC1051B_I3", &Kp_InputFilTrsLnk ) == ERR )
	//	ExitPgm( ERR_XX , "" );
    //
	//if ( n_CloseFileAppl( "ESTC1051B_I4", &Kp_InputFilExc ) == ERR )
	//	ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1051B_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1051B_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	pbd_Rupt->n_NbRupture = 0;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerUw( char **ptb_InRec_Cur )
{

	DEBUT_FCT( "n_ActionLignePerUw" );

	/* synchronisation avec le fichier DTSTATGTXX */
	n_ProcessingRuptureSyncVar( &bd_RuptStatGta, ptb_InRec_Cur );

	RETURN_VAL( OK );
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « DTSTATGTXX »

retour :
	OK
==============================================================================*/
int n_InitStatGta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitStatGta" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1051B_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncStatGta;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneStatGta;

	//if(*Ksz_Accret=='R')
		pbd_Rupt->n_FilsSansPere=n_ActionFilsSansPere;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}




/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncStatGta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncStatGta" );


	if ( strcmp(Ksz_Accret, "A") == 0)
	{
		if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
		//if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret;
		if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[GT_SEC_NF]) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;
	}
	if ( strcmp(Ksz_Accret, "R") == 0)
	{
		if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTSII_RETCTR_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTSII_RETEND_NT] ) ) != 0 ) return ret;
		//if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTSII_RETSEC_NF] ) ) != 0 ) return ret;
		if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[GTSII_RETSEC_NF]) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTSII_RTY_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTSII_RETUW_NT] ) ) != 0 ) return ret;
	}

	RETURN_VAL( 0 );
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneStatGta(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

	char	 *FctrestSii[GTSII_NBCOL + 1]; /* tableau de pointeur a l'image du fichier en sortie */
	char   sz_Trncod[9];
	char   sz_AcmTrs[6];
	char   sz_AcmAmt[25];
	char   sz_Nat[2];
	char   sz_Cur[4];
	char   sz_Patcat0[3];
	char   sz_Patcat[6];
	char   sz_Seglob[15];
	//char   sz_AcmTrs3[6];
	double d_AcmAmt;     /* montant acceptation ou retrocession */
	double d_Ratio;      /* ratio: cours montant de prime/cours aliment */
	char   MsgAno[300];  /* message anomalie*/
	//int    i;
	long   l_AcmTrs;
//	int    n_indice_trn = 0;
	
	int PER_PCPCUR_RATE=205;
	int PER_EGPCUR_RATE=206;
	double rate = 0 ;

	DEBUT_FCT( "n_ActionLigneStatGta" );

	memset( sz_Cur, 0, sizeof( sz_Cur ) );
	memset( sz_Nat, 0, sizeof( sz_Nat ) );
	memset( sz_Patcat, 0, sizeof( sz_Patcat ) );
	memset( sz_Seglob, 0, sizeof( sz_Seglob ) );

    //n_indice_trn = n_RechTrn(ptb_InRecChild[GTSII_TRNCOD_CF]);

    // [09]
    //if ( Ktbd_FBOTRSLNK[n_indice_trn].TRNTYP_CT == 3 )
    if ( ptb_InRecChild[GTSII_FBOPRSLNK_TRNTYP_CT] &&  *ptb_InRecChild[GTSII_FBOPRSLNK_TRNTYP_CT] == '3' )
    {
        // Si les postes comptables du local GAAP, TRNTYP_CT = 3
        RETURN_VAL(OK);
    }
    
	if ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
	{
		n_WriteCols( Kp_OutputFilResSii, ptb_InRecChild, SEPARATEUR, 0 );
 		RETURN_VAL(OK);
	}

	// [001]

	// Pour l'accept 1er traitement 
	if (((*Ksz_Accret=='A') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
			|| ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='2') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='4'))))
	{
		if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			//fac
				strcpy(sz_Nat,"F");
		else
			if (atoi(ptb_InRecOwner[PER_NAT_CF]) < 30 ) 
				strcpy(sz_Nat,"P");
			else 
				strcpy(sz_Nat,"N");
	}
	else
	{
		if(*Ksz_Accret=='A')	
		{
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"P");
			//*sz_Nat='P';
		}
		else 
			strcpy (sz_Nat,ptb_InRecChild[GTSII_NAT_CF]);
	}
		
	memset(sz_Trncod, 0, sizeof(sz_Trncod));
	/* Si retro, on force le 1er car à 1 et le dernier à 0 pour extraction du bon regroupement */
	sprintf( sz_Trncod, "%s", ptb_InRecChild[GTSII_TRNCOD_CF] );
			
	/* Recherche taux pour conversion du montant acceptation en devise aliment */
	d_Ratio = 1;

// [001]
	if (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
	{
		d_AcmAmt = atof( ptb_InRecChild[GTSII_RETAMT_M] );
		if ( b_IsBlankOrEmpty( ptb_InRecOwner[PER_PCPCUR_CF] ) )
			sprintf( sz_Cur, "%s", "EUR" );
		else			
			sprintf( sz_Cur, "%s", ptb_InRecOwner[PER_PCPCUR_CF] );
		
		if (b_IsBlankOrEmpty( ptb_InRecOwner[PER_PCPCUR_RATE]) )	rate = atof(ptb_InRecOwner[PER_PCPCUR_RATE]) ;

		//printf("PCP%s\n",ptb_InRecOwner[PER_PCPCUR_RATE]);
		if ( strcmp(Ksz_Accret, "R") == 0 && strcmp( ptb_InRecChild[GTSII_RETCUR_CF], sz_Cur ) != 0 )
		{
			//d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[GTSII_SSD_CF] ), atoi( ptb_InRecChild[GTSII_BALSHEY_NF] ), ptb_InRecChild[GTSII_RETCUR_CF], sz_Cur );
			//d_Ratio = atof(ptb_InRecChild[GTSII_CURQUOT_RET_RATE]);
		    if ( b_IsBlankOrEmpty( ptb_InRecChild[GTSII_CURQUOT_RET_RATE]) || rate <= 0 ) 
				d_Ratio = -1 ;
			else 
				d_Ratio = atof(ptb_InRecChild[GTSII_CURQUOT_RET_RATE])/rate ;
		}
	}
	else
	{
		d_AcmAmt = atof( ptb_InRecChild[GTSII_AMT_M] );
		if ( b_IsBlankOrEmpty( ptb_InRecOwner[PER_EGPCUR_CF] ) )
		{
			sprintf(sz_Cur, "%s", ptb_InRecChild[GTSII_CUR_CF] );
		    rate = atof(ptb_InRecChild[GTSII_CURQUOT_RATE]) ;
		}
		else
		{
			sprintf(sz_Cur, "%s", ptb_InRecOwner[PER_EGPCUR_CF] );
			rate=atof(ptb_InRecOwner[PER_EGPCUR_RATE] ) ;
		}
		//printf("EPG%f\n",rate);
			
		if ( strcmp( ptb_InRecChild[GTSII_CUR_CF], sz_Cur ) != 0 )
		{
			
			//d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[GTSII_SSD_CF] ), atoi( ptb_InRecChild[GTSII_BALSHEY_NF] ), ptb_InRecChild[GTSII_CUR_CF], sz_Cur );
		    if ( b_IsBlankOrEmpty( ptb_InRecChild[GTSII_CURQUOT_RATE] ) || rate <= 0 ) 
				d_Ratio = -1 ;
			else 
				d_Ratio = atof(ptb_InRecChild[GTSII_CURQUOT_RATE])/rate ;
		}
	}

	/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
	if ( d_Ratio < 0 )
	{
		if (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
		{
			sprintf( MsgAno, "The rates of retro currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", 
			         ptb_InRecChild[GTSII_RETCUR_CF], ptb_InRecOwner[PER_PCPCUR_CF], ptb_InRecChild[GTSII_RETCTR_NF],  ptb_InRecChild[GTSII_RETEND_NT], ptb_InRecChild[GTSII_RETSEC_NF], ptb_InRecChild[GTSII_RTY_NF], ptb_InRecChild[GT_UW_NT], ptb_InRecChild[GT_BALSHEY_NF] );
		}
		else
		{
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", 
			         ptb_InRecChild[GTSII_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF], ptb_InRecChild[GT_CTR_NF],  ptb_InRecChild[GT_END_NT], ptb_InRecChild[GT_SEC_NF], ptb_InRecChild[GT_UWY_NF], ptb_InRecChild[GT_UW_NT], ptb_InRecChild[GT_BALSHEY_NF] );
		}
		n_WriteAno( MsgAno );
		/* montant positionne a zero */
		d_AcmAmt = 0;
	}
	else
		/* conversion du montant acceptation en devise aliment */
		d_AcmAmt *= d_Ratio;
	sprintf( sz_AcmAmt, "%-.3f", d_AcmAmt );

//printf("---> avant n_RechPoste - %s\n",sz_Trncod);
	// [001]

		/* Synchro du fichier trslnk afin de recuperer ACMTRS_NT */
		//i=n_RechPoste(sz_Trncod);
		
		//if (i==-1)
		//if( *ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT] == 0 )
		//	l_AcmTrs = 0;
		//else
		//	l_AcmTrs = atoi(ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT]);
		l_AcmTrs=*ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT] == 0 ? 0 : atof(ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT]) ;
		
//printf("---> apres n_RechPoste - %s - %d\n",ptb_InRecChild[GTSII_TRNCOD_CF],l_AcmTrs);
	snprintf( sz_AcmTrs, 6, "%ld", l_AcmTrs );              // [007]
//printf("---> apres sz_AcmTrs\n");

/*	
	patcat = si 1er car sz_acmtrs = 3 'CL' sinon 'PR' +
	         si 1er car de trncod = 1 'ACC' sinon 'RET'
 si Ksz_Accret="R" et sz_Nat>=30 alors ptb_InRecOwner[PER_LOB_CF] sinon ptb_InRecOwner[PER_SEG_NF]	         
*/	

	if ((sz_AcmTrs[0] == '3') || (sz_AcmTrs[0] == '7') || ( sz_AcmTrs[0] == '9' && sz_AcmTrs[1] == '0' &&  sz_AcmTrs[2] == '2'))     // [007]
		strcpy(sz_Patcat0, "CL");
	else
		strcpy(sz_Patcat0, "PR");

	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
		sprintf(sz_Patcat, "%sACC", sz_Patcat0);
	else
		sprintf(sz_Patcat, "%sRET", sz_Patcat0);

	if ((*Ksz_Accret=='R') && (*sz_Nat=='P') && (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4' ))
	{
			sprintf(sz_Seglob, "%s", ptb_InRecChild [GTSII_SEGLOB_CF]);
	}
	else
	{	
		if (*sz_Nat =='N' && (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4' ))
		{
			sprintf(sz_Seglob, "%s%s", ptb_InRecOwner[PER_LOB_CF],ptb_InRecChild[GTSII_RTY_NF]);
		}
		else
		{
			if ( strlen(trim(ptb_InRecOwner[PER_SEG_NF]))== 0 )
			{
				if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
				{
					sprintf(sz_Seglob, "*%s",   ptb_InRecChild[GTSII_UWY_NF] );
				}
				else 
					sprintf(sz_Seglob, "*%s",   ptb_InRecChild[GTSII_RTY_NF] );
			}
			else
			{
				if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
				{
					sprintf(sz_Seglob, "%s%s", ptb_InRecOwner[PER_SEG_NF],	ptb_InRecChild[GTSII_UWY_NF] );
				}
				else 
					sprintf(sz_Seglob, "%s%s", ptb_InRecOwner[PER_SEG_NF],	ptb_InRecChild[GTSII_RTY_NF]);
			}
	 	}
	}


//printf("%s %s %s %s\n",ptb_InRecChild[GTSII_RETCTR_NF],ptb_InRecOwner[PER_PCPCUR_CF],ptb_InRecChild[GTSII_RETCUR_CF],sz_Cur);

	FctrestSii[GTSII_SSD_CF] = ptb_InRecChild[GTSII_SSD_CF];
	FctrestSii[GTSII_ESB_CF] = ptb_InRecChild[GTSII_ESB_CF];
	FctrestSii[GTSII_BALSHEY_NF] = ptb_InRecChild[GTSII_BALSHEY_NF];
	FctrestSii[GTSII_BALSHRMTH_NF] = ptb_InRecChild[GTSII_BALSHRMTH_NF];
	FctrestSii[GTSII_BALSHRDAY_NF] = ptb_InRecChild[GTSII_BALSHRDAY_NF];
	FctrestSii[GTSII_TRNCOD_CF] = ptb_InRecChild[GTSII_TRNCOD_CF];
	FctrestSii[GTSII_DBLTRNCOD_CF] = ptb_InRecChild[GTSII_DBLTRNCOD_CF];
	FctrestSii[GTSII_CTR_NF] = ptb_InRecChild[GTSII_CTR_NF];
	FctrestSii[GTSII_END_NT] = ptb_InRecChild[GTSII_END_NT];
	FctrestSii[GTSII_SEC_NF] = ptb_InRecChild[GTSII_SEC_NF];
	FctrestSii[GTSII_UWY_NF] = ptb_InRecChild[GTSII_UWY_NF];
	FctrestSii[GTSII_UW_NT] = ptb_InRecChild[GTSII_UW_NT];
	FctrestSii[GTSII_OCCYEA_NF] = ptb_InRecChild[GTSII_OCCYEA_NF];
	FctrestSii[GTSII_ACY_NF] = ptb_InRecChild[GTSII_ACY_NF];
	FctrestSii[GTSII_SCOSTRMTH_NF] = ptb_InRecChild[GTSII_SCOSTRMTH_NF];
	FctrestSii[GTSII_SCOENDMTH_NF] = ptb_InRecChild[GTSII_SCOENDMTH_NF];
	FctrestSii[GTSII_CLM_NF] = ptb_InRecChild[GTSII_CLM_NF];
	FctrestSii[GTSII_CUR_CF] = ptb_InRecChild[GTSII_CUR_CF];
	FctrestSii[GTSII_AMT_M] = ptb_InRecChild[GTSII_AMT_M];
	FctrestSii[GTSII_CED_NF] = ptb_InRecChild[GTSII_CED_NF];
	FctrestSii[GTSII_BRK_NF] = ptb_InRecChild[GTSII_BRK_NF];
	FctrestSii[GTSII_PAY_NF] = ptb_InRecChild[GTSII_PAY_NF];
	FctrestSii[GTSII_KEY_NF] = ptb_InRecChild[GTSII_KEY_NF];
	FctrestSii[GTSII_RETCTR_NF] = ptb_InRecChild[GTSII_RETCTR_NF];
	FctrestSii[GTSII_RETEND_NT] = ptb_InRecChild[GTSII_RETEND_NT];
	FctrestSii[GTSII_RETSEC_NF] = ptb_InRecChild[GTSII_RETSEC_NF];
	FctrestSii[GTSII_RTY_NF] = ptb_InRecChild[GTSII_RTY_NF];
	FctrestSii[GTSII_RETUW_NT] = ptb_InRecChild[GTSII_RETUW_NT];
	FctrestSii[GTSII_RETOCCYEA_NF] = ptb_InRecChild[GTSII_RETOCCYEA_NF];
	FctrestSii[GTSII_RETACY_NF] = ptb_InRecChild[GTSII_RETACY_NF];
	FctrestSii[GTSII_RETSCOSTRMTH_NF] = ptb_InRecChild[GTSII_RETSCOSTRMTH_NF];
	FctrestSii[GTSII_RETSCOENDMTH_NF] = ptb_InRecChild[GTSII_RETSCOENDMTH_NF];
	FctrestSii[GTSII_RCL_NF] = ptb_InRecChild[GTSII_RCL_NF];
	FctrestSii[GTSII_RETCUR_CF] = ptb_InRecChild[GTSII_RETCUR_CF];
	FctrestSii[GTSII_RETAMT_M] = ptb_InRecChild[GTSII_RETAMT_M];
	FctrestSii[GTSII_PLC_NT] = ptb_InRecChild[GTSII_PLC_NT];
	FctrestSii[GTSII_RTO_NF] = ptb_InRecChild[GTSII_RTO_NF];
	FctrestSii[GTSII_INT_NF] = ptb_InRecChild[GTSII_INT_NF];
	FctrestSii[GTSII_RETPAY_NF] = ptb_InRecChild[GTSII_RETPAY_NF];
	FctrestSii[GTSII_RETKEY_CF] = ptb_InRecChild[GTSII_RETKEY_CF];
	FctrestSii[GTSII_RETINTAMT_M] = ptb_InRecChild[GTSII_RETINTAMT_M];
	//sprintf(sz_AcmTrs, "%d", Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL2_NT);
	FctrestSii[GTSII_ACMTRS_NT] = sz_AcmTrs;
	FctrestSii[GTSII_ACMAMT_MC] = sz_AcmAmt;
	FctrestSii[GTSII_ACMCUR_CF] = sz_Cur;
	FctrestSii[GTSII_PRS_CF] = Ksz_Prs;
	if ((*Ksz_Accret=='R') && (*sz_Nat=='P') && (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4' ))
	{
		FctrestSii[GTSII_SEG_NF] = ptb_InRecChild [GTSII_SEG_NF] ;
	}
	else
	{
		FctrestSii[GTSII_SEG_NF] = ptb_InRecOwner[PER_SEG_NF];
	}
	FctrestSii[GTSII_LOB_CF] = ptb_InRecOwner[PER_LOB_CF];
	FctrestSii[GTSII_NAT_CF] = sz_Nat;
	FctrestSii[GTSII_TYP_CT] = ((*ptb_InRecChild[GTSII_TRNCOD_CF] =='1')|| (*ptb_InRecChild[GTSII_TRNCOD_CF] =='3')) ? "A" : "R" ; 
	FctrestSii[GTSII_PATTYP_CT] = sz_Patcat;
	FctrestSii[GTSII_SEGLOB_CF] = sz_Seglob;
	//[010]
	//sprintf(sz_AcmTrs3, "%d", Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL3_NT);
//	FctrestSii[GTSII_ACMTRS3_NT] =sz_AcmTrs3;
	FctrestSii[GTSII_NBCOL]=0;
	
//[08] en cas de retro interne, ne pas ecrire la ligne
	if ( *ptb_InRecOwner[PER_CTRRET_B] == '1'  && strcmp(Ksz_Accret, "A") == 0)
	{
		FctrestSii[GTSII_ACMTRS_NT] = "1";
	}	 
	
	n_WriteCols( Kp_OutputFilResSii, FctrestSii, SEPARATEUR, 0 );

	RETURN_VAL( OK );
}


///*==============================================================================
//objet:
//	Lit le fichier binaire des postes et les met en memoire
//
//==============================================================================*/
//int n_ChargerTRSLNK( short s_TrtCod )
//{
//	int i = 0;
//
//	char sz_message[200];
//
//	DEBUT_FCT("n_ChargerTRSLNK");
//
//	//Pour réinitialiser le buffer du fichier en lecture car sans cela à la 16537 ème ligne on a
//	// que des lignes avec n'importe quoi dedans, le fflush résout cela
//	fflush( Kp_InputFilTrsLnk );
//
//	while ( fread( &Ktbd_TrsLnk[i], sizeof( T_TRSLNK ), 1, Kp_InputFilTrsLnk ) == 1 )
//	{  
//		if ( Ktbd_TrsLnk[i].PRS_CF == s_TrtCod)
//			i += 1;
//		if ( i > Kn_MaxPostes )
//		{
//
//			sprintf(sz_message,"la taille du tableau Ktbd_TrsLnk depasse la taille allouee %d", i);
//			n_WriteAno(sz_message);
//			RETURN_VAL( i );
//		}
//
//	}
//
//	RETURN_VAL( i );
//}


// /*==============================================================================
// objet :
// 	fonction de recherche du poste
// retour :
// 	0		---> Pas de rupture
// 	< 0   	---> On n'est pas arrive au bloc synchrone
// 	> 0   	---> On a depasse le bloc synchrone
// ==============================================================================*/
// int n_RechPoste(char *sz_poste)
// {
// 	int n_indice, ret;
// 	char Ksz_vide[1];		/* Chaine vide pour initialisation */
// 
// 	DEBUT_FCT("n_RechPoste");
// 
// 	Ksz_vide[0]=0;
// 	n_indice=0;
// 	while (1==1)
// 	{
// 		/* Comparaison des codes */
// 		ret=strcmp(sz_poste,Ktbd_TrsLnk[n_indice].DETTRS_CF);
// 
// 		/* S'ils sont egaux, retourner l'indice */
// 		if (ret==0) RETURN_VAL(n_indice);
// 
// 		/* Si la ligne est passee, retourner -1 (echec) */
// 		if (ret<0) RETURN_VAL(-1);
// 
// 		/* Ligne suivante */
// 		n_indice++;
// 
// 		/* Si on est a la fin du tableau, echec */
// 		if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
// 	}
// }
// 
/*==============================================================================
// renvoi 1 si TRT, 0 si FAC, -1 si pas une lettre !
==============================================================================*/
int is_TRT(char *contract)
{ 
  char thirdCar;
	thirdCar = toupper(contract[2]);
	
  char firstCar;
	firstCar = toupper(contract[0]);
		
  //[004]
	if(( thirdCar >= 'A' && thirdCar <= 'M') || firstCar == 'F') //'FAC' 
		return 0; 

	if(( thirdCar >= 'N' && thirdCar <= 'Z') || firstCar == 'T')  // Traité
		return 1; 
		
	if( firstCar == 'R')  // Rétro
		return 2; 
		
	
	return -1; 
} 


/*
	Trim permet de supprimer les espaces dans une chaine de caractères,
	si la chaine est vide (longueur =0), elle est retournée tel que.
	si la chaine contient des blancs, ils sont remplacés par des \0 et la chaine est renvoyée
*/
char *trim(char *s) 
{
    char *ptr;
    
	/*if (!s)
        return (char*) NULL;   // handle NULL string
	*/	
    if (!*s)
        return s;      // handle empty string
    for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr);
    ptr[1] = '\0';
    return s;
}

/*==============================================================================
objet : fonction lancee quand le Fils n'a pas de Pere

retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
dans ce cas on reporte telle quelle la ligne dans le fichier en sortie
==============================================================================*/
int n_ActionFilsSansPere(char ** ptb_InRecChild)
{
	char   sz_Trncod[9];
	char   sz_AcmTrs[6];
	char   sz_AcmAmt[25];
	char   sz_Nat[2];
	char   sz_Cur[4];
	char   sz_Patcat0[3];
	char   sz_Patcat[6];
	char   sz_Seglob[15];
//	char   sz_AcmTrs3[6];
	double d_AcmAmt;     /* montant acceptation ou retrocession */
//	int    i;
	long   l_AcmTrs;
	char   *FctrestSii[GTSII_NBCOL+ 1]; /* tableau de pointeur a l'image du fichier en sortie */
//    int    n_indice_trn = 0;
    
	char BufferAno[100];

	memset( sz_Cur, 0, sizeof( sz_Cur ) );
	memset( sz_Nat, 0, sizeof( sz_Nat ) );
	memset( sz_Patcat, 0, sizeof( sz_Patcat ) );
	memset( sz_Seglob, 0, sizeof( sz_Seglob ) );
	memset( sz_Trncod , 0 , sizeof(sz_Trncod) );
	memset( BufferAno,0,sizeof(BufferAno));

	// [001]

    //n_indice_trn = n_RechTrn(ptb_InRecChild[GTSII_TRNCOD_CF]);

    // [09]
    //if ( Ktbd_FBOTRSLNK[n_indice_trn].TRNTYP_CT == 3 )
    if ( ptb_InRecChild[GTSII_FBOPRSLNK_TRNTYP_CT] && *ptb_InRecChild[GTSII_FBOPRSLNK_TRNTYP_CT] == '3' )
    {
        // Si les postes comptables du local GAAP, TRNTYP_CT = 3
        RETURN_VAL(OK);
    }
    	
	if ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
	{
		n_WriteCols( Kp_OutputFilResSii, ptb_InRecChild, SEPARATEUR, 0 );
 		RETURN_VAL(OK);
	}


	if (*Ksz_Accret=='A')
	{
		if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
		{
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"P");
		}
		else 
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				if (is_TRT(ptb_InRecChild[GT_CTR_NF]) < 0)
					strcpy(sz_Nat,"N");
				else
					strcpy(sz_Nat,"P");
	}
	else
	{
		if(*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
		{
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"N");
		}
		else 
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"P");
	}	
	
	sz_Nat[1] = 0;

	

	/* Si retro, on force le 1er car à 1 et le dernier à 0 pour extraction du bon regroupement */
	sprintf( sz_Trncod, "%s", ptb_InRecChild[GTSII_TRNCOD_CF] );
	sz_Trncod[8]=0;


		
	/* Recherche taux pour conversion du montant acceptation en devise aliment */
	if (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
	{
		d_AcmAmt = atof( ptb_InRecChild[GTSII_RETAMT_M] );
		sprintf( sz_Cur, "%s", ptb_InRecChild[GTSII_RETCUR_CF] );
	}
	else
	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
	{	
		d_AcmAmt = atof( ptb_InRecChild[GTSII_AMT_M] );
		sprintf( sz_Cur, "%s", ptb_InRecChild[GTSII_CUR_CF] );
	}
	sprintf( sz_AcmAmt, "%-.3f", d_AcmAmt );

//printf("---> avant n_R!echPoste - %s\n",sz_Trncod);
	// [001]

		/* Synchro du fichier trslnk afin de recuperer ACMTRS_NT */
	//	//i=n_RechPoste(sz_Trncod);
	//	if( *ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT] != 0 )
	//		l_AcmTrs = 0;
	//	else
			l_AcmTrs = atoi(ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT]);
	l_AcmTrs=*ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT] == 0 ? 0 : atof(ptb_InRecChild[GTSII_TRSLNK_ACMTRS_NT]) ;
	
		
//printf("---> apres n_RechPoste - %s - %d\n",ptb_InRecChild[GTSII_TRNCOD_CF],l_AcmTrs);
	snprintf( sz_AcmTrs, 6, "%ld", l_AcmTrs );             // [007]
//printf("---> apres sz_AcmTrs\n");

/*	
	patcat = si 1er car sz_acmtrs = 3 'CL' sinon 'PR' +
	         si 1er car de trncod = 1 'ACC' sinon 'RET'
 si Ksz_Accret="R" et sz_Nat>=30 alors ptb_InRecOwner[PER_LOB_CF] sinon ptb_InRecOwner[PER_SEG_NF]	         
*/	

	if ((sz_AcmTrs[0] == '3') || (sz_AcmTrs[0] == '7') || ( sz_AcmTrs[0] == '9' && sz_AcmTrs[1] == '0' &&  sz_AcmTrs[2] == '2'))     // [007]
		strcpy(sz_Patcat0, "CL");
	else
		strcpy(sz_Patcat0, "PR");

	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
		sprintf(sz_Patcat, "%sACC", sz_Patcat0);
	else
		sprintf(sz_Patcat, "%sRET", sz_Patcat0);

	if ((*Ksz_Accret=='A') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
	{
			sprintf(sz_Seglob, "*%s",   ptb_InRecChild[GTSII_UWY_NF] );
	}
	else
	{
			sprintf(sz_Seglob, "*%s", ptb_InRecChild[GTSII_RTY_NF] );
	}	
	
	//[006] Ecrasement memoire car GTSII_NBCOL+ 1 pointe au-dela du tableau : valeur max = GTSII_NBCOL
	//[006] Cela est deja fait par la ligne qui met "0" dans FctrestSii[GTSII_NBCOL] en fin de fonction...
	//[006] FctrestSii[GTSII_NBCOL+ 1]= NULL;

	FctrestSii[GTSII_SSD_CF] = ptb_InRecChild[GTSII_SSD_CF];
	FctrestSii[GTSII_ESB_CF] = ptb_InRecChild[GTSII_ESB_CF];
	FctrestSii[GTSII_BALSHEY_NF] = ptb_InRecChild[GTSII_BALSHEY_NF];
	FctrestSii[GTSII_BALSHRMTH_NF] = ptb_InRecChild[GTSII_BALSHRMTH_NF];
	FctrestSii[GTSII_BALSHRDAY_NF] = ptb_InRecChild[GTSII_BALSHRDAY_NF];
	FctrestSii[GTSII_TRNCOD_CF] = ptb_InRecChild[GTSII_TRNCOD_CF];
	FctrestSii[GTSII_DBLTRNCOD_CF] = ptb_InRecChild[GTSII_DBLTRNCOD_CF];
	FctrestSii[GTSII_CTR_NF] = ptb_InRecChild[GTSII_CTR_NF];
	FctrestSii[GTSII_END_NT] = ptb_InRecChild[GTSII_END_NT];
	FctrestSii[GTSII_SEC_NF] = ptb_InRecChild[GTSII_SEC_NF];
	FctrestSii[GTSII_UWY_NF] = ptb_InRecChild[GTSII_UWY_NF];
	FctrestSii[GTSII_UW_NT] = ptb_InRecChild[GTSII_UW_NT];
	FctrestSii[GTSII_OCCYEA_NF] = ptb_InRecChild[GTSII_OCCYEA_NF];
	FctrestSii[GTSII_ACY_NF] = ptb_InRecChild[GTSII_ACY_NF];
	FctrestSii[GTSII_SCOSTRMTH_NF] = ptb_InRecChild[GTSII_SCOSTRMTH_NF];
	FctrestSii[GTSII_SCOENDMTH_NF] = ptb_InRecChild[GTSII_SCOENDMTH_NF];
	FctrestSii[GTSII_CLM_NF] = ptb_InRecChild[GTSII_CLM_NF];
	FctrestSii[GTSII_CUR_CF] = ptb_InRecChild[GTSII_CUR_CF];
	FctrestSii[GTSII_AMT_M] = ptb_InRecChild[GTSII_AMT_M];
	FctrestSii[GTSII_CED_NF] = ptb_InRecChild[GTSII_CED_NF];
	FctrestSii[GTSII_BRK_NF] = ptb_InRecChild[GTSII_BRK_NF];
	FctrestSii[GTSII_PAY_NF] = ptb_InRecChild[GTSII_PAY_NF];
	FctrestSii[GTSII_KEY_NF] = ptb_InRecChild[GTSII_KEY_NF];
	FctrestSii[GTSII_RETCTR_NF] = ptb_InRecChild[GTSII_RETCTR_NF];
	FctrestSii[GTSII_RETEND_NT] = ptb_InRecChild[GTSII_RETEND_NT];
	FctrestSii[GTSII_RETSEC_NF] = ptb_InRecChild[GTSII_RETSEC_NF];
	FctrestSii[GTSII_RTY_NF] = ptb_InRecChild[GTSII_RTY_NF];
	FctrestSii[GTSII_RETUW_NT] = ptb_InRecChild[GTSII_RETUW_NT];
	FctrestSii[GTSII_RETOCCYEA_NF] = ptb_InRecChild[GTSII_RETOCCYEA_NF];
	FctrestSii[GTSII_RETACY_NF] = ptb_InRecChild[GTSII_RETACY_NF];
	FctrestSii[GTSII_RETSCOSTRMTH_NF] = ptb_InRecChild[GTSII_RETSCOSTRMTH_NF];
	FctrestSii[GTSII_RETSCOENDMTH_NF] = ptb_InRecChild[GTSII_RETSCOENDMTH_NF];
	FctrestSii[GTSII_RCL_NF] = ptb_InRecChild[GTSII_RCL_NF];
	FctrestSii[GTSII_RETCUR_CF] = ptb_InRecChild[GTSII_RETCUR_CF];
	FctrestSii[GTSII_RETAMT_M] = ptb_InRecChild[GTSII_RETAMT_M];
	FctrestSii[GTSII_PLC_NT] = ptb_InRecChild[GTSII_PLC_NT];
	FctrestSii[GTSII_RTO_NF] = ptb_InRecChild[GTSII_RTO_NF];
	FctrestSii[GTSII_INT_NF] = ptb_InRecChild[GTSII_INT_NF];
	FctrestSii[GTSII_RETPAY_NF] = ptb_InRecChild[GTSII_RETPAY_NF];
	FctrestSii[GTSII_RETKEY_CF] = ptb_InRecChild[GTSII_RETKEY_CF];
	FctrestSii[GTSII_RETINTAMT_M] = ptb_InRecChild[GTSII_RETINTAMT_M];
	//sprintf(sz_AcmTrs, "%d", Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL2_NT);
	FctrestSii[GTSII_ACMTRS_NT] = sz_AcmTrs;
	FctrestSii[GTSII_ACMAMT_MC] = sz_AcmAmt;
	FctrestSii[GTSII_ACMCUR_CF] = sz_Cur;
	FctrestSii[GTSII_PRS_CF] = Ksz_Prs;
	FctrestSii[GTSII_SEG_NF] ="";
 	if ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
		FctrestSii[GTSII_SEG_NF] ="*";
	FctrestSii[GTSII_LOB_CF] = "";
	FctrestSii[GTSII_NAT_CF] = sz_Nat;
	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
	{
		FctrestSii[GTSII_TYP_CT] = "A" ;
	}
	else 
		FctrestSii[GTSII_TYP_CT] = "R" ;
	FctrestSii[GTSII_PATTYP_CT] = sz_Patcat;
	FctrestSii[GTSII_SEGLOB_CF] = sz_Seglob;
	//[010]
	//FctrestSii[GTSII_ACMTRS3_NT] = ptb_InRecChild[GTSII_ACMTRS3_NT];
	//sprintf(sz_AcmTrs3, "%d", Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL3_NT);
    //FctrestSii[GTSII_ACMTRS3_NT] = ptb_InRecChild[GTSII_FBOPRSLNK_ACMTRSL3_NT] ; //sz_AcmTrs3;
	FctrestSii[GTSII_NBCOL] =0; 

	n_WriteCols( Kp_OutputFilResSii, FctrestSii, SEPARATEUR, 0 );
	
	/*
	if(*Ksz_Accret =='A')
	{
		
		
		
			sprintf(BufferAno, "%s;%s;%s",  ptb_InRecChild[GT_CTR_NF] ,
											ptb_InRecChild[GT_END_NT] ,
											ptb_InRecChild[GT_SEC_NF] ,
											ptb_InRecChild[GT_UWY_NF],
											ptb_InRecChild[GT_UW_NT] );
	}
	else 
	{
			sprintf(BufferAno, "%s;%s;%s",  ptb_InRecChild[GTSII_RETCTR_NF] ,
											ptb_InRecChild[GTSII_RETEND_NT] ,
											ptb_InRecChild[GTSII_RETSEC_NF] ,
											ptb_InRecChild[GTSII_RTY_NF],
											ptb_InRecChild[GTSII_RETUW_NT] );

	}


	n_WriteLog('I',BufferAno);
	*/

 	RETURN_VAL(OK);
}

///*==============================================================================
//objet :
// fonction de recherche du trncod
//retour :
// 0---> Pas de rupture
// < 0     ---> On n'est pas arrive au bloc synchrone
// > 0     ---> On a depasse le bloc synchrone
//==============================================================================*/
//int n_RechTrn(char *sz_trn)
//{
//        int i;
//
//        DEBUT_FCT("n_RechTrn");
//
//
//        for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
//        {
//                if ( strcmp( sz_trn, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
//                   RETURN_VAL(i);
//        }
//
//        RETURN_VAL(-1);
//}
//
//
//
///*==============================================================================
//objet :
//  Chargement du tableau FBOTRSLNK
//retour :
//  Taille du tableau
//==============================================================================*/
//int n_ChargerFBOTRSLNK()
//{
//  int i = 0 ;
//
//  DEBUT_FCT("n_ChargerFBOTRSLNK");
//
//  while (fread(&Ktbd_FBOTRSLNK[i], sizeof(T_FBOTRSLNK), 1, Kp_FBOTRSLNK) == 1)
//    {
//        /*printf("[%s][%d]-------[%c][%d][%d][%d][%d][%d][%s][%s][%c][%s][%d]\n", Ktbd_FBOTRSLNK[i].DETTRS_CF,Ktbd_FBOTRSLNK[i].TRNTYP_CT,
//                Ktbd_FBOTRSLNK[i].TRSPFX_CF,       //char    TRSPFX_CF;
//                Ktbd_FBOTRSLNK[i].ACMTRSL0_NT,     //short   ACMTRSL0_NT;        
//                Ktbd_FBOTRSLNK[i].ACMTRSL1_NT,     //short   ACMTRSL1_NT;        
//                Ktbd_FBOTRSLNK[i].ACMTRSL2_NT,     //short   ACMTRSL2_NT;        
//                Ktbd_FBOTRSLNK[i].ACMTRSL3_NT,     //short   ACMTRSL3_NT;        
//                Ktbd_FBOTRSLNK[i].TRSTYP_NT,       //short   TRSTYP_NT;          
//                Ktbd_FBOTRSLNK[i].DETTRS_CF,       //char        DETTRS_CF[9];   
//                Ktbd_FBOTRSLNK[i].PCPTRS_CF,       //char        PCPTRS_CF[3];   
//                Ktbd_FBOTRSLNK[i].TRS_CF,          //char        TRS_CF;         
//                Ktbd_FBOTRSLNK[i].SUBTRS_CF,       //char        SUBTRS_CF[3];   
//                Ktbd_FBOTRSLNK[i].ESTIM_NT         //short       ESTIM_NT;[%s][%c]
//                );*/
//        i += 1 ;
//
//  
//        if ( i > Kn_MaxLigFBOTRSLNK )
//        {
//            n_WriteAno("Depassement de capacite du tableau");
//            RETURN_VAL(-1);
//        }
//
//    }
//  if ( i == 0 )
//  {
//     n_WriteAno("Fichier FBOTRSLNK vide");
//     RETURN_VAL(-1);
//  }
//  RETURN_VAL(i);
//}
//
