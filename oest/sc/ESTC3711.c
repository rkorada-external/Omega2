/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP
Nom du source                 : ESTC3711.c
Révision                      : $Revision: 1.0 $
Date de création              : 19/06/2015
Auteur                        : Paul GARNIER
References des specifications : #################
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
    Calcul automatique de la prévision de sinistralité en fonction de la
    segestation
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[01] M.NAJI 11/09/2018 add UWY_NF  spira 57605
 
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

#define CTRGRO_UWY_NF 20 //dernier champs


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

#define GT_UNFILL_COL -1 // Colonne vide
#define GT_TO_PRE_END -2 // Fin Hashtab

#define PRE_COMACC_B         1
#define PRE_VRS_NF           2
#define PRE_SEG_NF           3
#define PRE_SEGTYP_CT        4
/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE                    *Kp_OutputFil_LIFEST_SEG;       /* Pointeur sur le fichier SEGMNT segmente en sortie*/

T_RUPTURE_SYNC_VAR      pbd_SyncLIFEST;                 /* Structure contenant les PA / CTR */
T_RUPTURE_VAR           pbd_RuptTCTRGRO;                /* Structure contenant le TCTRGRO */


/*------------------*/
/*    Prototypes    */
/*------------------*/

int n_InitSyncLIFEST(T_RUPTURE_SYNC_VAR *);
int n_ActionLigneTCTRGRO(char **);

int n_InitRuptTCTRGRO(T_RUPTURE_VAR *);
int n_ActionLigneLIFEST(char **, char **);
int n_ConditionRuptLIFEST(char **, char **);

int errorMsg(char *error);  /* Fonction d'appel en cas d'erreur */


/*==============================================================================
objet   :   Point d'entree du programme
retour  :   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR)                                          ExitPgm(ERR_XX, "");

    if (n_OpenFileAppl("ESTC3711_O1", "wt", &Kp_OutputFil_LIFEST_SEG) == ERR)   ExitPgm(ERR_XX, "");
    if (n_InitRuptTCTRGRO(&pbd_RuptTCTRGRO))                                    ExitPgm(ERR_XX, "");
    if (n_InitSyncLIFEST(&pbd_SyncLIFEST))                                      ExitPgm(ERR_XX, "");

    /* Lancement du traitement */
    if (n_ProcessingRuptureVar(&pbd_RuptTCTRGRO) == ERR)                         ExitPgm(ERR_XX, "");

    /* Fermeture de tout les fichiers ouverts */
    if (n_CloseFileAppl("ESTC3711_I1", &(pbd_SyncLIFEST.pf_InputFil)) == ERR)   ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3711_I2", &(pbd_RuptTCTRGRO.pf_InputFil)) == ERR)  ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3711_O1", &Kp_OutputFil_LIFEST_SEG) == ERR)        ExitPgm(ERR_XX , "");

    if (n_EndPgm() == ERR)                                                      ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du LIFEST
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitSyncLIFEST(T_RUPTURE_SYNC_VAR *pbd_SyncLIFEST)
{
    DEBUT_FCT("n_InitSyncLIFEST");
    memset(pbd_SyncLIFEST, 0, sizeof(T_RUPTURE_SYNC_VAR));

    // Ouverture du fichier LIFEP
    if (n_OpenFileAppl("ESTC3711_I1", "rt", &(pbd_SyncLIFEST->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("LIFEST openning failed. Error in ESTC3711.\n"));

    pbd_SyncLIFEST->n_NbRupture             = 0;

    pbd_SyncLIFEST->ConditionEndSync        = n_ConditionRuptLIFEST;
    pbd_SyncLIFEST->n_ActionLigne           = n_ActionLigneLIFEST;

    pbd_SyncLIFEST->c_Separ                 = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du TCTRGRO
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitRuptTCTRGRO(T_RUPTURE_VAR *pbd_RuptTCTRGRO)
{
    DEBUT_FCT("n_InitRuptTCTRGRO");
    memset(pbd_RuptTCTRGRO, 0, sizeof(T_RUPTURE_VAR));

    // Ouverture du fichier Peri
    if (n_OpenFileAppl("ESTC3711_I2", "rt", &(pbd_RuptTCTRGRO->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("PERICASE openning failed. Error in ESTC3711.\n"));

    pbd_RuptTCTRGRO->n_NbRupture       = 0;

    /* fonction d'action sur la ligne courante */
    pbd_RuptTCTRGRO->n_ActionLigne     = n_ActionLigneTCTRGRO;

    /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */

    pbd_RuptTCTRGRO->c_Separ           = SEPARATEUR;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee à la première rupture
retour  :   0 ---> traitement correctement effectue
==============================================================================*/
int n_ActionLigneTCTRGRO(char **ptd_inRec_Cur_TCTRGRO)
{
    DEBUT_FCT("n_ActionFirstSyncLIFEST");

    if (n_ProcessingRuptureSyncVar(&pbd_SyncLIFEST, ptd_inRec_Cur_TCTRGRO) == ERR)
        RETURN_VAL(ERR);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   Fonction lancee pour chaque ligne du TCTRGRO
retour  :   0 ----> traitement correctement effectue
==============================================================================*/
int n_ActionLigneLIFEST(char **ptd_RuptTCTRGRO, char **ptd_SyncLIFEST)
{
    char *pz_ligne[PRE_NBCOL + 6];
    int i;

    DEBUT_FCT("n_ActionLigneTCTRGRO");
    for (i = 0; i <= PRE_NBCOL + PRE_COMACC_B; ++i)
    {
        if (ptd_SyncLIFEST[i] != NULL)
            pz_ligne[i] = ptd_SyncLIFEST[i];
        else
            pz_ligne[i] = "";
    }

    // Recuperation de la version et du type de segment

    pz_ligne[PRE_NBCOL + PRE_VRS_NF   ] = ptd_RuptTCTRGRO[CTRGRO_VRS_NF];
    pz_ligne[PRE_NBCOL + PRE_SEG_NF   ] = ptd_RuptTCTRGRO[CTRGRO_SEG_NF];
    pz_ligne[PRE_NBCOL + PRE_SEGTYP_CT] = ptd_RuptTCTRGRO[CTRGRO_SEGTYP_CT];
    pz_ligne[PRE_NBCOL + 5] = NULL;

    n_WriteCols(Kp_OutputFil_LIFEST_SEG, pz_ligne, SEPARATEUR, 0);
    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   ---> pbd_SyncLIFEST = pbd_RuptTCTRGRO (égalité de rubrique à synchroniser)
            1   ---> Pas de syncronisation
==============================================================================*/
int n_ConditionRuptLIFEST(char **ptd_RuptTCTRGRO, char **ptd_SyncLIFEST)
{
    int     ret = 0;

    DEBUT_FCT("n_ConditionRuptTCTRGRO");

    // Test de rupture CTR - SEC - END   --->   TCTRGRO
    if ((ret = strcmp(ptd_RuptTCTRGRO[CTRGRO_CTR_NF], ptd_SyncLIFEST[PRE_CTR_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptTCTRGRO[CTRGRO_SEC_NF], ptd_SyncLIFEST[PRE_SEC_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_RuptTCTRGRO[CTRGRO_END_NT], ptd_SyncLIFEST[PRE_END_NT])) != 0) RETURN_VAL(ret);
	
	// si l'exercice dans CTRGRO est vide ou égale 0 , on considère qu'il y a synchro pour n'importe quel exercice
	if (   *ptd_RuptTCTRGRO[CTRGRO_UWY_NF] == 0 || *ptd_RuptTCTRGRO[CTRGRO_UWY_NF] == '0' ) return 0 ;
	// sinon il faut que l'exercie synchronise 

	
    if ((ret = strcmp(ptd_RuptTCTRGRO[CTRGRO_UWY_NF], ptd_SyncLIFEST[PRE_UWY_NF])) != 0) RETURN_VAL(ret);

    RETURN_VAL(OK);
}

/*==============================================================================
objet   :   Fonction d'affichage de message d'erreur
retour  :   ERR --> permet l'arret du programme
==============================================================================*/
int errorMsg(char *error)   // error : message d'erreur à écrire
{
    char    MsgAno[100];

    sprintf(MsgAno, error);
    n_WriteAno(MsgAno);

    RETURN_VAL(ERR);
}
