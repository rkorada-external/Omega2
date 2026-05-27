/*==============================================================================
 *  ** nom de l'application          : ESTIMATION SOLVENCY
 *   * * nom du source                 : ESTC2058.c
 *    *  * révision                      : $Revision: 1.0 $
 *     *   * date de création              : 29/08/18
 *      *    * auteur                        : Charles SOCIE
 *       *     * references des specifications :
 *        *      * squelette de base             : batch
 *         *       * ------------------------------------------------------------------------------
 *          *        *  description :
 *           *         *     Generate a sort file according to the condition TRSTYP_CT equal 3
 *            *          *
 *             *           *     ------------------------------------------------------------------------------
 *              *            *     historique des modifications :
[001] HR SPIRA 82685 : struct.h 
*               *             *     ================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
//#include "structA.h"
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define Kn_MaxPostes 100000     /* Le nombre max de postes est fixe a 100000 */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilDLSIIGTAR_O; /* pointer on the output file */
FILE   *Kp_InputFilFBOPRSLNK;     /* pointer on the input file FBOPRSLNK (binary file) */

T_RUPTURE_VAR  bd_RuptStatGta; /* variable de gestion de la synchronisation avec le fichier DTSTATGTx */

T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];
int Kn_NbLigTrslnk;
int Kn_FBOPRSLNK ;              /* number of line in the file FBOPRSLNK */


FILE *Kp_FBOPRSLNK;
/* Structure pour la recuperation des donnees dans le fichier binaire FBOPRSLNK */
#define Kn_MaxLigFBOPRSLNK   30000    // [002]

T_FBOPRSLNK Ktbd_FBOPRSLNK[Kn_MaxLigFBOPRSLNK];

int n_ChargerFBOPRSLNK();
int temp_n_ChargerFBOPRSLNK;
int n_RechTrn(char *sz_trn );
int temp_n_RechTrn;

int n_InitDLSIIGTAA                   ( T_RUPTURE_VAR *pbd_Rupt );
int temp_n_InitDLSIIGTAA;
int n_ActionLigneDLSIIGTAA (char **ptb_InRecCurrent);
int temp_n_ActionLigneDLSIIGTAA;

char Ksz_TRNCOD1_CF[2];          /* input parameter TRNCOD1_CF */
short s_TRNCOD1_CF;

int  is_TRT(char *);
char * trim(char *);
long   ligne=1;

/*==============================================================================
 *  *  * objet :
 *   *   *    point d'entree du programme
 *    *    *
 *     *     *    retour :
 *      *      *       En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
 *       *       *          Sinon, par l'appel systeme exit()
 *        *        *          ==============================================================================*/
int main(int argc  , char *argv[])
{

        /* Initialisation des signaux */
        InitSig ();

        if ( n_BeginPgm ( argc, argv ) == ERR )
                ExitPgm( ERR_XX , "" );

        /* get the parameter TRNCOD1_CF */
        strcpy(Ksz_TRNCOD1_CF,psz_GetCharArgv(1));
        s_TRNCOD1_CF = atoi(Ksz_TRNCOD1_CF);

        /* OPEN THE FILE FBOPRSLNK */
        if ( n_OpenFileAppl ( "ESTC2058_I2","rb",&Kp_InputFilFBOPRSLNK ) == ERR )
                ExitPgm( ERR_XX , "" );

    /* load the binary file FBOPRSLNK */
    Kn_FBOPRSLNK = n_ChargerFBOPRSLNK();
    if ( Kn_FBOPRSLNK == -1 )
                ExitPgm( ERR_XX , "Taille tableau FBOPRSLNK insuffisante " ) ;

        /* open the output file DLSIIGTAR_O */
        if ( n_OpenFileAppl ( "ESTC2058_O1","wt",&Kp_OutputFilDLSIIGTAR_O ) == ERR )
                ExitPgm( ERR_XX , "" );

        /* init of the variable bd_RuptStatGta */
        if ( n_InitDLSIIGTAA( &bd_RuptStatGta ) )
                ExitPgm( ERR_XX , "" );

        /* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
        if ( n_ProcessingRuptureVar( &bd_RuptStatGta ) == ERR )
                ExitPgm( ERR_XX , "" );

        /* close the input file DLSIIGTAA_O */
        if ( n_CloseFileAppl( "ESTC2058_I1", &( bd_RuptStatGta.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

        /* close the input file DLSIIGTAR_O */
        if ( n_CloseFileAppl( "ESTC2058_I2", &( Kp_InputFilFBOPRSLNK ) ) == ERR )
                ExitPgm( ERR_XX , "" );

        /* close the output file DLSIIGTAR_O */
        if ( n_CloseFileAppl( "ESTC2058_O1", &Kp_OutputFilDLSIIGTAR_O ) == ERR )
                ExitPgm( ERR_XX , "" );

        exit(OK);
}

/*==============================================================================
 *  *  * objet :
 *   *   *  Initialisation de la synchronisation du maitre « Perimetre de souscription »
 *    *    *                 avec l.esclave « DTSTATGTXX »
 *     *     *
 *      *      *               retour :
 *       *       *                      OK
 *        *        *                     ==============================================================================*/
int n_InitDLSIIGTAA( T_RUPTURE_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitDLSIIGTAA" );
        temp_n_InitDLSIIGTAA++;
        printf("appel numero %d de la fonction n_InitDLSIIGTAA\n", temp_n_InitDLSIIGTAA);
        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

        /* ouverture du fichier courant */
        if ( n_OpenFileAppl( "ESTC2058_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneDLSIIGTAA;

        pbd_Rupt->c_Separ = SEPARATEUR;

        RETURN_VAL( OK );
}

/*==============================================================================
 *  *  * objet :
 *   *   *  fonction lancee pour chaque ligne
 *    *    *
 *     *     *        retour :        OK ---> traitement correctement effectue
 *      *      *                       ERR --> probleme rencontre
 *       *       *                      ==============================================================================*/
int n_ActionLigneDLSIIGTAA(
        char **ptb_InRecCurrent) /* adresse de la ligne courante */
{

        char     *FctrestSii[GTSII_NBCOL + 1]; /* tableau de pointeur a l'image du fichier en sortie */
         int    n_indice_trn = 0;


        DEBUT_FCT( "n_ActionLigneDLSIIGTAA" );

     n_indice_trn = n_RechTrn(ptb_InRecCurrent[GTSII_TRNCOD_CF]);

if (n_indice_trn == -1){
        return 0;
}

        temp_n_ActionLigneDLSIIGTAA++;

        n_WriteCols( Kp_OutputFilDLSIIGTAR_O, ptb_InRecCurrent, SEPARATEUR, 0 );


        RETURN_VAL( OK );
}

/*==============================================================================
 *  *  * objet :
 *   *   *  fonction de recherche du trncod
 *    *    *  retour :
 *     *     *   0---> Pas de rupture
 *      *      *    < 0     ---> On n'est pas arrive au bloc synchrone
 *       *       *     > 0     ---> On a depasse le bloc synchrone
 *        *        *     ==============================================================================*/
int n_RechTrn(char *sz_trn)
{
        int i;

        DEBUT_FCT("n_RechTrn");

        if (strncmp(sz_trn, Ksz_TRNCOD1_CF, 1) == 0 ){
           for ( i = 0; i <  Kn_FBOPRSLNK ; i++ )
           {
                if ( strcmp( sz_trn, Ktbd_FBOPRSLNK[i].DETTRS_CF ) == 0 )
                                {
                                        if ( Ktbd_FBOPRSLNK[i].TRSTYP_NT != 3)
                                                RETURN_VAL(-1);
                                        else
                                                RETURN_VAL(i);
                }
           }
        }
        RETURN_VAL(-1);
}

/*==============================================================================
 *  *  * objet :
 *   *   *   Load the binary file FBOPRSLNK
 *    *    *   retour :
 *     *     *     array's size
 *      *      *     ==============================================================================*/
int n_ChargerFBOPRSLNK()
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerFBOPRSLNK");
                temp_n_ChargerFBOPRSLNK++;
                printf("appel numero %d de la fonction n_ChargerFBOPRSLNK\n", temp_n_ChargerFBOPRSLNK);

  while (fread(&Ktbd_FBOPRSLNK[i], sizeof(T_FBOPRSLNK), 1, Kp_InputFilFBOPRSLNK) == 1)
    {
        i += 1 ;
        if ( i > Kn_MaxLigFBOPRSLNK )
        {
            n_WriteAno("Depassement de capacite du tableau");
            RETURN_VAL(-1);
        }
    }
  if ( i == 0 )
  {
     n_WriteAno("Fichier FBOPRSLNK vide");
     RETURN_VAL(-1);
  }
  RETURN_VAL(i);
}

