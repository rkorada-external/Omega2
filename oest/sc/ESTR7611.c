/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTR7611.c
révision                      : $Revision: 1.2 $
date de création              : 11/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   INJECTION DU TYPE DE NATURE RETROCESSION

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    12/06/1998  y.Bourdaillet     rajout d une fonction pere sans fils
                                pour obtenir toutes les lignes du gt d entree
                                en sortie. On prend ctrnat=X et lob = 98
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[02}  20/11/2014 Florent :spot:27747 corrections des warnings
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTR7611.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define Kn_MaxPostes 2000	/* Le nombre max de postes est fixe a 2000 */

char Ksz_vide[1];		/* Chaine vide pour initialisation */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilFti ; /* pointeur sur le fichier de sortie Fichier de travail intermediaire */
FILE 		*Kp_InputFilTrsLnk ; /* pointeur sur le fichier en entree des postes cumuls, code de traitement */
FILE 		*Kp_InputFilExc ; /* pointeur sur le fichier en entree des cours de change */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptGta ; /* variable de gestion de la synchronisation avec
						le fichier GTA */

T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];
int Kn_NbLigTrslnk;


int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitGta			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGta		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionFilsSansPereGta    ( char **pbd_InRecChild ) ;
int n_ConditionSyncGta		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ChargerTRSLNK ( short s_TrtCod ) ;
int n_RechPoste(char *sz_poste) ;



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
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTR7611_I3","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des postes cumuls FTRSLNK */
	if ( n_OpenFileAppl ( "ESTR7611_I4","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTR7611_O1","wt",&Kp_OutputFilFti ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGta */
	if ( n_InitGta( &bd_RuptGta ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Chargement des postes en memoire */
	Kn_NbLigTrslnk = n_ChargerTRSLNK ( 712 );
        if ( Kn_NbLigTrslnk > Kn_MaxPostes )
        {
                 n_WriteAno( "depassement de capacite du tableau Ktbd_TrsLnk" );
                 ExitPgm( ERR_XX , "" ) ;
        }


	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7611_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7611_I2", &( bd_RuptGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7611_I3", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7611_I4", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTR7611_O1", &Kp_OutputFilFti ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
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
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTR7611_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
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
	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* synchronisation avec le fichier GTA */
	n_ProcessingRuptureSyncVar( &bd_RuptGta, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « GTA »

retour :
	OK
==============================================================================*/
int n_InitGta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGta" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTR7611_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGta ;

        /* fonction d'action quand l'esclave n'a pas de maitre */
        pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGta ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGta ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGta" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGta(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	int i ;
	long l_AcmTrs ;		/* poste cumul */
	char sz_AcmTrs[6] ;	/* variable intermediaire: poste cumul */
	double d_Ratio ;	/* cours devise filiale */
	double d_Amt ; 		/* montant acceptation */
	char sz_Amt[20] ;	/* variable intermediaire: montant acceptation */
	char sz_CtrNat[2] ;	/* variable intermediaire: nature de l'affaire */
	char *Fti[NB_COL_FTIR + 1] ;	/* tableau de pointeur a l'image du fichier de travail intermediaire */

	char	MsgAno[300] ; /* message d'anomalie */

	DEBUT_FCT( "n_ActionLigneGta" ) ;

	/* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
	i=n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]) ;
	if (i==-1) l_AcmTrs = 0 ;
	else l_AcmTrs = Ktbd_TrsLnk[i].ACMTRS_NT ;

	/* conversion au cours bilan du montant en monnaie filiale et ecriture dans le fichier de sortie */
	if ( l_AcmTrs == 10000 || l_AcmTrs == 10030 || l_AcmTrs == 10031 || l_AcmTrs == 10100 || l_AcmTrs == 10130 ||
		l_AcmTrs == 10200 || l_AcmTrs == 10430 || l_AcmTrs == 20000 || l_AcmTrs == 20030 || l_AcmTrs == 20031 ||
		l_AcmTrs == 24030 || l_AcmTrs == 24031 || l_AcmTrs == 22000 )
	{
		d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[GT_SSD_CF] ),
			atoi( ptb_InRecChild[GT_BALSHEY_NF] ), ptb_InRecChild[GT_RETCUR_CF], 0 ) ;

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio < 0 )
		{
			sprintf( MsgAno, "The rate of subsidiary currency ( %s ) isn't known for the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n",
				ptb_InRecChild[GT_RETCUR_CF], ptb_InRecChild[GT_RETCTR_NF], ptb_InRecChild[GT_RETEND_NT],
				ptb_InRecChild[GT_RETSEC_NF],  ptb_InRecChild[GT_RTY_NF], ptb_InRecChild[GT_RETUW_NT], ptb_InRecChild[GT_BALSHEY_NF] ) ;
			n_WriteAno( MsgAno ) ;

			d_Amt = 0 ;
		}
		else	d_Amt = d_Ratio * atof( ptb_InRecChild[GT_RETAMT_M] ) ;

		/* ecriture en sortie dans le fichier de travail intermediaire */
		if ( d_Amt != 0 )
		{
			Fti[FTIR_SSD_CF] = ptb_InRecChild[GT_SSD_CF] ;
			Fti[FTIR_ESB_CF] = ptb_InRecChild[GT_ESB_CF] ;
			Fti[FTIR_LOB_CF] = ptb_InRecOwner[PER_LOB_CF] ;
			Fti[FTIR_CTRNAT_CT] = sz_CtrNat ;
			Fti[FTIR_ACMTRS_NT] = sz_AcmTrs ;
			Fti[FTIR_AMT_M] = sz_Amt ;
			Fti[FTIR_AMT_M + 1] = NULL ;

			sprintf( sz_AcmTrs, "%ld", l_AcmTrs ) ;
			sprintf( sz_Amt, "%-.3f", d_Amt ) ;

			if ( atoi( ptb_InRecOwner[PER_RETCTRCAT_CF] ) == 2 )
				strcpy( sz_CtrNat, "C" ) ;
			else	strcpy( sz_CtrNat, ptb_InRecChild[GT_RETKEY_CF + 1] ) ;

			n_WriteCols( Kp_OutputFilFti, Fti, SEPARATEUR, 0 ) ;
		}
	}

	RETURN_VAL( OK ) ;
}
/*==============================================================================
objet :
        fonction lancee quand le fils n'a pas de maitre

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereGta(
        char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
        int i ;
        long l_AcmTrs ;         /* poste cumul */
        char sz_AcmTrs[6] ;     /* variable intermediaire: poste cumul */
        double d_Ratio ;        /* cours devise filiale */
        double d_Amt ;          /* montant acceptation */
        char sz_Amt[20] ;       /* variable intermediaire: montant acceptation */
        char *Fti[NB_COL_FTIR + 1] ;    /* tableau de pointeur a l'image du fichier de travail intermediaire */
        char    MsgAno[300] ; /* message d'anomalie */

        DEBUT_FCT( "n_ActionFilsSansPereGta" ) ;

        /* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
        i=n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]) ;
        if (i==-1) l_AcmTrs = 0 ;
        else l_AcmTrs = Ktbd_TrsLnk[i].ACMTRS_NT ;

        /* conversion au cours bilan du montant en monnaie filiale et ecriture dans le fichier de sortie */
        if ( l_AcmTrs == 10000 || l_AcmTrs == 10030 || l_AcmTrs == 10031 ||
		l_AcmTrs == 10100 || l_AcmTrs == 10130 || l_AcmTrs == 10200 ||
		l_AcmTrs == 10430 || l_AcmTrs == 20000 || l_AcmTrs == 20030 ||
		l_AcmTrs == 20031 || l_AcmTrs == 24030 || l_AcmTrs == 24031 ||
		l_AcmTrs == 22000 )
        {
                d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[GT_SSD_CF] ),
                        atoi( ptb_InRecChild[GT_BALSHEY_NF] ), ptb_InRecChild[GT_RETCUR_CF], 0 ) ;

                /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
                if ( d_Ratio < 0 )
                {
                        sprintf( MsgAno, "The rate of subsidiary currency ( %s )isn't known for the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n",
                                ptb_InRecChild[GT_RETCUR_CF], ptb_InRecChild[GT_RETCTR_NF], ptb_InRecChild[GT_RETEND_NT],ptb_InRecChild[GT_RETSEC_NF], ptb_InRecChild[GT_RTY_NF], ptb_InRecChild[GT_RETUW_NT], ptb_InRecChild[GT_BALSHEY_NF] ) ;
                        n_WriteAno( MsgAno ) ;

                        d_Amt = 0 ;
                }
                else    d_Amt = d_Ratio * atof( ptb_InRecChild[GT_RETAMT_M] ) ;

                /* ecriture en sortie dans le fichier de travail intermediaire */
                if ( d_Amt != 0 )
                {
                        sprintf( sz_AcmTrs, "%ld", l_AcmTrs ) ;
                        sprintf( sz_Amt, "%-.3f", d_Amt ) ;

                        Fti[FTIR_SSD_CF] = ptb_InRecChild[GT_SSD_CF] ;
                        Fti[FTIR_ESB_CF] = ptb_InRecChild[GT_ESB_CF] ;
                        Fti[FTIR_LOB_CF] = "98" ;
                        Fti[FTIR_CTRNAT_CT] = "X" ;
                        Fti[FTIR_ACMTRS_NT] = sz_AcmTrs ;
                        Fti[FTIR_AMT_M] = sz_Amt ;
                        Fti[FTIR_AMT_M + 1] = NULL ;


                        n_WriteCols( Kp_OutputFilFti, Fti, SEPARATEUR, 0 ) ;
                }
        }

        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet:
	Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK( short s_TrtCod )
{
	int i = 0 ;

	DEBUT_FCT("n_ChargerTRSLNK");

	while ( fread( &Ktbd_TrsLnk[i], sizeof( T_TRSLNK ), 1, Kp_InputFilTrsLnk ) == 1 )
	{
		if ( Ktbd_TrsLnk[i].PRS_CF == s_TrtCod )
			i += 1 ;
	}

	RETURN_VAL( i );
}


/*==============================================================================
objet :
	fonction de recherche du poste
retour :
	0		---> Pas de rupture
	< 0   	---> On n'est pas arrive au bloc synchrone
	> 0   	---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
	int n_indice, ret;

	DEBUT_FCT("n_RechPoste");

	Ksz_vide[0]=0;
	n_indice=0;
	while (1==1)
	{
		/* Comparaison des codes */
		ret=strcmp(sz_poste,Ktbd_TrsLnk[n_indice].DETTRS_CF);

		/* S'ils sont egaux, retourner l'indice */
		if (ret==0) RETURN_VAL(n_indice);

		/* Si la ligne est passee, retourner -1 (echec) */
		if (ret<0) RETURN_VAL(-1);

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
	}
}


