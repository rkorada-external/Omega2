/*==============================================================================
Nom de l'application          : Life Estimates Closing Multi-GAAP GT
Nom du source                 : ESTC3701.c
Révision                      : $Revision: 1.0 $
Date de création              : 20/03/2015
Auteur                        : Julien FONTANA
References des specifications : #################
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
    Life Estimates Closing Multi-GAAP GT- IO Automatisation
    Crée pour l'EST24BT
    Séparation des lignes GT issu d'ecriture service et les autres
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[001] 21/01/2016 RBE spot:30080: Gestion des AE lors IO manuel
[002] 29/11/2016 DFI Correction recuperation montant des gaap sur cle dupliquee + correction NBCOL
[003] 08/02/2018 S.ROCH spira 64246 : Ajout le fichier d’entrée EST_SUBTRS au programme
[004] 26/02/2019 :spira:75061 : Suppression du parametre HEURE_TRAITEMENT jamais utilise 
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define NB_GAAP             5
#define BATCH_B             "1"
//[004] #define HEURE_TRAITEMENT    "23:59:05"  
#define NBCOL               GT_NBCOL3


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilDLRGTAA;       /* Pointeur sur le fichier DLRGTAA */
FILE    *Kp_OutputFilDLRGTAA_3_4_5; /* Pointeur sur le fichier format DLRGTAA contenant les gaap 3, 4, 5 filtrés car non ES */
FILE    *Kp_InputSubtrs ;            /* pointeur sur le fichier SUBTRS */
T_RUPTURE_VAR       pbd_RuptGT;
T_RUPTURE_SYNC_VAR  pbd_SyncPeri;
T_SUBTRS            SubTrsLigne;     /*[003]SUBTRS*/

char Ksz_Cre_D[22] = {'\0'};


int  B_Lob = 0;
int  Parent_Flag;
int  Local_Flag;


int  UpdateC = 1; // Booleen
int  UpdateE = 1; // Booleen
int  UpdateG = 1; // Booleen

double Ksz_Gaap_MNT[NB_GAAP + 1];

char *Ksz_MAJ_line_GT[5][NBCOL + 1];


/*------------------*/
/*    Prototypes    */
/*------------------*/

int  n_InitRuptGT(T_RUPTURE_VAR *pbd_RuptGT);
int  n_ActionLigneGT(char **);
int  n_ActionLastRuptGT(char **ptb_RuptGT);    /*[003]SUBTRS*/
int  n_ConditionRupture(char **ptd_InRec, char **ptd_InRec_Cur);

int  n_InitRuptPeri(T_RUPTURE_SYNC_VAR *pbd_SyncPeri);
int  n_ConditionSyncPERI(char **ptb_InRec_GT, char **pbd_InRec_PERI);
int  n_ActionLignePERI(char **ptb_InRec_GT, char **pbd_InRec_PERI);

void clean_Ksz_Gaap_MNT();
void clean_Ksz_MAJ_line_GT();
void init_SubTrsLigne();                                             /*[003]SUBTRS*/
int  find_gaap_ref();
int  errorMsg(char *error);

FILE *Kp_SubTRSFil;   

/*==============================================================================
objet   :   Point d'entree du programme
retour  :   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR)                                                  ExitPgm(ERR_XX, "");

    // Recuperation des parametres
//[004]     sprintf(Ksz_Cre_D, "%s %s", psz_GetCharArgv(1), HEURE_TRAITEMENT);

    if (n_OpenFileAppl("ESTC3701_O1", "wt", &Kp_OutputFilDLRGTAA) == ERR)               ExitPgm(ERR_XX, "");
    if (n_OpenFileAppl("ESTC3701_O2", "wt", &Kp_OutputFilDLRGTAA_3_4_5) == ERR) 
    if (n_OpenFileAppl("ESTC3701_I3", "rb", &Kp_InputSubtrs ) == ERR )                   ExitPgm(ERR_XX, "");    /*[003]SUBTRS*/
    	
    	
    // Chargement fichier T_SUBTRS                                                                                /*[003]SUBTRS*/
    if (n_OpenFileAppl ("ESTC3701_I3","rb",&Kp_SubTRSFil) == ERR )
                ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR ) 					ExitPgm( ERR_XX , "" );      
      
    if (n_InitRuptGT(&pbd_RuptGT))                                                      ExitPgm(ERR_XX, "");
    if (n_InitRuptPeri(&pbd_SyncPeri))                                                  ExitPgm(ERR_XX, "");
    	  

    clean_Ksz_Gaap_MNT();
    clean_Ksz_MAJ_line_GT();

    if (n_ProcessingRuptureVar(&pbd_RuptGT) == ERR)                                     ExitPgm(ERR_XX, "");

    if (n_CloseFileAppl("ESTC3701_I1", &pbd_RuptGT.pf_InputFil) == ERR)                 ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3701_I2", &pbd_SyncPeri.pf_InputFil) == ERR)               ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3701_O1", &Kp_OutputFilDLRGTAA) == ERR)                    ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC3701_O2", &Kp_OutputFilDLRGTAA_3_4_5) == ERR)  
    if (n_CloseFileAppl("ESTC3701_I3", &Kp_SubTRSFil) == ERR )                       ExitPgm(ERR_XX, "");
    if (n_EndPgm() == ERR)                                                              ExitPgm(ERR_XX, "");

    exit(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture syncronisee du GT
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitRuptGT(T_RUPTURE_VAR *pbd_RuptGT)
{
    DEBUT_FCT("n_InitRuptGT");
    memset(pbd_RuptGT, 0, sizeof(*pbd_RuptGT));

    // Ouverture du fichier Peri
    if (n_OpenFileAppl("ESTC3701_I1", "rt", &(pbd_RuptGT->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("DLVGTAA openning failed. Error in ESTC3701.\n"));

    pbd_RuptGT->n_NbRupture             = 1;
    pbd_RuptGT->n_ConditionRupture[0] = n_ConditionRupture;
    pbd_RuptGT->n_ActionLast[0]       = n_ActionLastRuptGT;

    /* fonction d'action sur la ligne courante */
    pbd_RuptGT->n_ActionLigne           = n_ActionLigneGT;

    pbd_RuptGT->c_Separ                 = SEPARATEUR;
     // initialisation de la structure retour///  /////SUBTRS
    
    init_SubTrsLigne();          


    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Sauvegarde GT
==============================================================================*/
int n_ActionLigneGT(char **ptb_RuptGT)
{
    int     col = 0;
    DEBUT_FCT("n_ActionLigneGT");

    if (n_ProcessingRuptureSyncVar(&pbd_SyncPeri, ptb_RuptGT) == ERR)
        RETURN_VAL(errorMsg("n_ProcessingRuptureSyncVar failed. Error in ESTC3701.\n"));

    if (B_Lob == 1)
    {
        // Check du 2eme Digit du TRNCOD -> Si 4 ou 7 -> Pas Ecriture Service -> On ecrit uniquement le gaap 1 et 2
        if (ptb_RuptGT[GT_TRNCOD_CF][1] != '4' && ptb_RuptGT[GT_TRNCOD_CF][1] != '7')
        {
            if (ptb_RuptGT[GT_TRNCOD_CF][7] == '2' || ptb_RuptGT[GT_TRNCOD_CF][7] == 'A')
                n_WriteCols(Kp_OutputFilDLRGTAA, ptb_RuptGT, SEPARATEUR, 0);
            else
                n_WriteCols(Kp_OutputFilDLRGTAA_3_4_5, ptb_RuptGT, SEPARATEUR, 0);
        }
        else
        {
            switch (ptb_RuptGT[GT_TRNCOD_CF][7])
            {
            case '2':
                Ksz_Gaap_MNT[0] += atof(ptb_RuptGT[GT_AMT_M]); //[002]
                for (col = 0; col < NBCOL; ++col)
                {
                    if (ptb_RuptGT[col] != NULL)
                        Ksz_MAJ_line_GT[0][col] = strdup(ptb_RuptGT[col]);
                    else
                        Ksz_MAJ_line_GT[0][col] = "";
                }
                n_WriteCols(Kp_OutputFilDLRGTAA, ptb_RuptGT, SEPARATEUR, 0);
                break;

            case 'A':
                Ksz_Gaap_MNT[1] += atof(ptb_RuptGT[GT_AMT_M]); //[002]
                for (col = 0; col < NBCOL; ++col)
                {
                    if (ptb_RuptGT[col] != NULL)
                        Ksz_MAJ_line_GT[1][col] = strdup(ptb_RuptGT[col]);
                    else
                        Ksz_MAJ_line_GT[1][col] = "";
                }
                n_WriteCols(Kp_OutputFilDLRGTAA, ptb_RuptGT, SEPARATEUR, 0);
                break;

            case 'C':
                UpdateC = 0;
                Ksz_Gaap_MNT[2] += atof(ptb_RuptGT[GT_AMT_M]); //[002]
                for (col = 0; col < NBCOL; ++col)
                {
                    if (ptb_RuptGT[col] != NULL)
                        Ksz_MAJ_line_GT[2][col] = strdup(ptb_RuptGT[col]);
                    else
                        Ksz_MAJ_line_GT[2][col] = "";
                }
                break;

            case 'E':
                UpdateE = 0;
                Ksz_Gaap_MNT[3] += atof(ptb_RuptGT[GT_AMT_M]); //[002]
                for (col = 0; col < NBCOL; ++col)
                {
                    if (ptb_RuptGT[col] != NULL)
                        Ksz_MAJ_line_GT[3][col] = strdup(ptb_RuptGT[col]);
                    else
                        Ksz_MAJ_line_GT[3][col] = "";
                }
                break;

            case 'G':
                UpdateG = 0;
                Ksz_Gaap_MNT[4] += atof(ptb_RuptGT[GT_AMT_M]); //[002]
                for (col = 0; col < NBCOL; ++col)
                {
                    if (ptb_RuptGT[col] != NULL)
                        Ksz_MAJ_line_GT[4][col] = strdup(ptb_RuptGT[col]);
                    else
                        Ksz_MAJ_line_GT[4][col] = "";
                }
                break;

            default:
                n_WriteCols(Kp_OutputFilDLRGTAA, ptb_RuptGT, SEPARATEUR, 0);
                break;
            }
        }
    }
    else
        n_WriteCols(Kp_OutputFilDLRGTAA, ptb_RuptGT, SEPARATEUR, 0);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     n_ActionLastRuptGT
retour:     0   ----> OK
            ERR ----> Huge error in input file

Tableau simplifié des resultats attendus en fonction des flags.

#####################################
#        #        #        #        #
#  FLAG  # GAAP 3 # GAAP 4 # GAAP 5 #
#        #        #        #        #
#####################################
#        #        #        #        #
#   0    #    0   #    0   #   G5   #
#        #        #        #        #
#####################################
#   1    #        #        #        #
#   OR   #    0   #  -G3   #   G5   #
#  NULL  #        #        #        #
#####################################
#        #        #        #        #
#   2    #   G3   #    0   #   G5   #
#        #        #        #        #
#####################################
#        #        #        #        #
#   3    #  G3 +  #   G4   #   G5   #
#        #   G4   #        #        #
#####################################

G1 -> Montant du Gaap 1
G2 -> Montant du Gaap 2
G3 -> Montant du Gaap 3
G4 -> Montant du Gaap 4
G5 -> Montant du Gaap 5

On connait le Gaap a modifier en fonction du flag :
    -> PER_PARENT_FLAG : Gaap 3
    -> PER_LOCAL_FLAG  : Gaap 4
==============================================================================*/

int n_ActionLastRuptGT(char **ptb_RuptGT)

{
    char    buff[30];
    double  MntGaap3 = 0.0;
    double  MntGaap4 = 0.0;
    int     col = 0;
    int     index_ref = 0;
    int      resultposte =0;
    char   sz_dettrncod[6];
    
    DEBUT_FCT("n_ActionLastRuptGT");

    sprintf(sz_dettrncod,"%.5s", ptb_RuptGT[GT_TRNCOD_CF]+2);
    resultposte = n_FindTsubTRS(&SubTrsLigne,sz_dettrncod); 

    // Si non vie -> on ne fait rien
    if (B_Lob == 0)
        RETURN_VAL(OK);
    // On check le Parent_Flag -> Gaap 3

    switch (Parent_Flag) {
    
    // Flag == 0 -> Montant mis a 0
    case 0:
    	
//*===============================================================================*//
//   Si le poste est un poste cash, le montant ne doit pas être remis à zéro
//*===============================================================================*//
        if ( SubTrsLigne.TRSTYPE_CT != 1 )                                               /*[003]SUBTRS*/
   	    {
            MntGaap3 = 0.0;
            MntGaap3 = MntGaap3 - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1] ;
        }
        break;
  
    // Flag == 1 ou NULL -> Cas par defaut -> Montant MAJ -> Valeur = G1 + G2 - G1 - G2 = 0
    case 1:
        MntGaap3 = Ksz_Gaap_MNT[0] + Ksz_Gaap_MNT[1] - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1];
        break;

    // Flag == 2 -> Montant MAJ -> Valeur = G1 + G2 + G3 - G1 - G2 = G3
    case 2:
        MntGaap3 = Ksz_Gaap_MNT[0] + Ksz_Gaap_MNT[1] + Ksz_Gaap_MNT[2] - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1];
        break;

    // Flag == 3 -> Montant MAJ -> Valeur = G1 + G2 + G3 + G4 - G1 - G2 = G3 + G4
    case 3:
        MntGaap3 = Ksz_Gaap_MNT[0] + Ksz_Gaap_MNT[1] + Ksz_Gaap_MNT[2] + Ksz_Gaap_MNT[3] - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1];
        break;

    default:
        RETURN_VAL(errorMsg("Bad PER_PARENT_FLAG. Error in ESTC3701.\n"));
        break;
    }

    // On check le Local_Flag -> Gaap 4
    switch (Local_Flag) {
    // Flag == 0 -> Montant mis a 0
    case 0:
        MntGaap4 = 0.0;
        MntGaap4 = MntGaap4 - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1] - MntGaap3 ;
        break;

    // Flag == 1 ou NULL -> Cas par defaut -> Montant MAJ -> Valeur = G1 + G2 - G1 - G2 - G3 = - G3
    case 1:
        MntGaap4 = Ksz_Gaap_MNT[0] + Ksz_Gaap_MNT[1] - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1] - MntGaap3;
        break;

    // Flag == 2 -> Montant MAJ -> Valeur = G1 + G2 + G3 - G1 - G2 - G3 = 0
    case 2:
        MntGaap4 = Ksz_Gaap_MNT[0] + Ksz_Gaap_MNT[1] + Ksz_Gaap_MNT[2] - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1] - MntGaap3;
        break;

    // Flag == 3 -> Montant MAJ -> Valeur = G1 + G2 + G3 + G4 - G1 - G2 - G3 = G4
    case 3:
        MntGaap4 = Ksz_Gaap_MNT[0] + Ksz_Gaap_MNT[1] + Ksz_Gaap_MNT[2] + Ksz_Gaap_MNT[3] - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1] - MntGaap3;
        break;

    default:
        RETURN_VAL(errorMsg("Bad PER_LOCAL_FLAG. Error in ESTC3701.\n"));
        break;
    }

    // Montant MAJ -> Valeur = G1 + G2 + G3 + G4 + G5 - G1 - G2 - G3 - G4 = G5
    Ksz_Gaap_MNT[4] = Ksz_Gaap_MNT[0] + Ksz_Gaap_MNT[1] + Ksz_Gaap_MNT[2] + Ksz_Gaap_MNT[3] + Ksz_Gaap_MNT[4] - Ksz_Gaap_MNT[0] - Ksz_Gaap_MNT[1] - MntGaap3 - MntGaap4;

    // if ((index_ref = find_gaap_ref()) == -1)
    //     RETURN_VAL(errorMsg("Error finding Gaap. Error in ESTC3701.\n"));

    index_ref = find_gaap_ref();

    //////////////////
    // printf("\nParent_Flag = %d\tLocal_Flag = %d\n", Parent_Flag, Local_Flag);
    // printf("MNT Gaap 3 = %f\tMNT Gaap 4 = %f\tMNT Gaap 5 = %f\n", MntGaap3, MntGaap4, Ksz_Gaap_MNT[4]);
    // printf("Update C = %d / E = %d / G = %d\n", UpdateC, UpdateE, UpdateG);
    // printf("Index_ref = %d\n\n", index_ref);
    //////////////////


    if (UpdateC == 0)
    {
        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", MntGaap3);
        Ksz_MAJ_line_GT[2][GT_AMT_M] = buff;
        n_WriteCols(Kp_OutputFilDLRGTAA, Ksz_MAJ_line_GT[2], SEPARATEUR, 0);
        UpdateC = 1;
    }
    else if (MntGaap3 != 0.0 && index_ref != -1)
    {
        for (col = 0; col < NBCOL; ++col)
        {
            if (Ksz_MAJ_line_GT[index_ref][col] != NULL)
                Ksz_MAJ_line_GT[2][col] = strdup(Ksz_MAJ_line_GT[index_ref][col]);
            else
                Ksz_MAJ_line_GT[2][col] = "";
        }

        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", MntGaap3);
        Ksz_MAJ_line_GT[2][GT_AMT_M] = buff;

        Ksz_MAJ_line_GT[2][GT_TRNCOD_CF][7] = 'C';
        n_WriteCols(Kp_OutputFilDLRGTAA, Ksz_MAJ_line_GT[2], SEPARATEUR, 0);
    }

    if (UpdateE == 0)
    {
        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", MntGaap4);
        Ksz_MAJ_line_GT[3][GT_AMT_M] = buff;
        n_WriteCols(Kp_OutputFilDLRGTAA, Ksz_MAJ_line_GT[3], SEPARATEUR, 0);

        UpdateE = 1;
    }
    else if (MntGaap4 != 0.0 && index_ref != -1)
    {
        for (col = 0; col < NBCOL; ++col)
        {
            if (Ksz_MAJ_line_GT[index_ref][col] != NULL)
                Ksz_MAJ_line_GT[3][col] = strdup(Ksz_MAJ_line_GT[index_ref][col]);
            else
                Ksz_MAJ_line_GT[3][col] = "";
        }

        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", MntGaap4);
        Ksz_MAJ_line_GT[3][GT_AMT_M] = buff;

        Ksz_MAJ_line_GT[3][GT_TRNCOD_CF][7] = 'E';
        n_WriteCols(Kp_OutputFilDLRGTAA, Ksz_MAJ_line_GT[3], SEPARATEUR, 0);
    }

    if (UpdateG == 0)
    {
        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", Ksz_Gaap_MNT[4]);
        Ksz_MAJ_line_GT[4][GT_AMT_M] = buff;
        n_WriteCols(Kp_OutputFilDLRGTAA, Ksz_MAJ_line_GT[4], SEPARATEUR, 0);

        UpdateG = 1;
    }
    else if (Ksz_Gaap_MNT[4] != 0.0 && index_ref != -1)
    {
        for (col = 0; col < NBCOL; ++col)
        {
            if (Ksz_MAJ_line_GT[index_ref][col] != NULL)
                Ksz_MAJ_line_GT[4][col] = strdup(Ksz_MAJ_line_GT[index_ref][col]);
            else
                Ksz_MAJ_line_GT[4][col] = "";
        }

        memset(buff, 0, 30);
        sprintf(buff, "%.3lf", Ksz_Gaap_MNT[4]);
        Ksz_MAJ_line_GT[4][GT_AMT_M] = buff;

        Ksz_MAJ_line_GT[4][GT_TRNCOD_CF][7] = 'G';
        n_WriteCols(Kp_OutputFilDLRGTAA, Ksz_MAJ_line_GT[4], SEPARATEUR, 0);
    }

    clean_Ksz_Gaap_MNT();
    clean_Ksz_MAJ_line_GT();

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du PERICASE
retour:     0 ----> OK
            ERR --> Error
==============================================================================*/
int n_InitRuptPeri(T_RUPTURE_SYNC_VAR * pbd_SyncPeri)
{
    DEBUT_FCT("n_InitRuptPeri");
    memset(pbd_SyncPeri, 0, sizeof(*pbd_SyncPeri));

    // Ouverture du fichier PERICASE
    if (n_OpenFileAppl("ESTC3701_I2", "rt", &(pbd_SyncPeri->pf_InputFil)) == ERR)
        RETURN_VAL(errorMsg("PERICASE openning failed. Error in ESTC3702.\n"));

    pbd_SyncPeri->n_NbRupture        = 0;
    pbd_SyncPeri->ConditionEndSync   = n_ConditionSyncPERI;
    pbd_SyncPeri->n_ActionLigne      = n_ActionLignePERI;
    pbd_SyncPeri->c_Separ            = SEPARATEUR;

    RETURN_VAL(OK);
}



/*==============================================================================
objet   :   fonction de test de rupture de niveau 1
retour  :   0       ---> pas de rupture
            sinon   ---> rupture
==============================================================================*/
int n_ConditionSyncPERI(char **ptb_InRec_GT, char **pbd_InRec_PERI)
{
    int     ret = 0;

    DEBUT_FCT("n_ConditionSyncPERI");

    if ((ret = strcmp(ptb_InRec_GT[GT_CTR_NF], pbd_InRec_PERI[PER_CTR_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec_GT[GT_SEC_NF], pbd_InRec_PERI[PER_SEC_NF])) != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptb_InRec_GT[GT_UWY_NF], pbd_InRec_PERI[PER_UWY_NF])) != 0) RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   fonction de test de synchronisation
retour  :   0   --->
            1   ---> Pas de syncronisation
==============================================================================*/
int n_ConditionRupture(char **ptd_InRec, char **ptd_InRec_Cur)
{
    int     ret = 0;
    char    trncod[8] = "";
    char    trncod_cur[8] = "";

    DEBUT_FCT("n_ConditionRupture");

    if ((ret = strcmp(ptd_InRec[GT_CTR_NF],       ptd_InRec_Cur[GT_CTR_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[GT_SEC_NF],       ptd_InRec_Cur[GT_SEC_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[GT_UWY_NF],       ptd_InRec_Cur[GT_UWY_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[GT_ACY_NF],       ptd_InRec_Cur[GT_ACY_NF]))       != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[GT_BALSHEY_NF],   ptd_InRec_Cur[GT_BALSHEY_NF]))   != 0) RETURN_VAL(ret);
    if ((ret = strcmp(ptd_InRec[GT_BALSHRMTH_NF], ptd_InRec_Cur[GT_BALSHRMTH_NF])) != 0) RETURN_VAL(ret);

    strncpy(trncod, ptd_InRec[GT_TRNCOD_CF], 7);
    strncpy(trncod_cur, ptd_InRec_Cur[GT_TRNCOD_CF], 7);

    if ((ret = strcmp(trncod,                    trncod_cur))                    != 0) RETURN_VAL(ret);

    RETURN_VAL(OK);
}


/*==============================================================================
objet :     obtenir la lob associer au contrat provenant du GT
==============================================================================*/
int n_ActionLignePERI(char **ptb_RuptGT, char **pbd_RuptPERI)
{
    DEBUT_FCT("n_ActionLignePERI");

    // Check si la ligne GT est Vie (LOB 30 et 31)
    if (pbd_RuptPERI[PER_LOB_CF] != NULL)
    {
        if (strcmp(pbd_RuptPERI[PER_LOB_CF], "30") == 0 || strcmp(pbd_RuptPERI[PER_LOB_CF], "31") == 0)
            B_Lob = 1;
        else
            B_Lob = 0;
    }
    else
        B_Lob = 0;

    // Check de la valeur du PER_PARENT_FLAG. NULL a la meme comportement que la valeur 1
    if (pbd_RuptPERI[PER_PARENT_FLAG] != NULL)
    {
        if (pbd_RuptPERI[PER_PARENT_FLAG][0] != '\0')
            Parent_Flag = atoi(pbd_RuptPERI[PER_PARENT_FLAG]);
        else
            Parent_Flag = 1;
    }
    else
        Parent_Flag = 1;

    // Check de la valeur du PER_LOCAL_FLAG. NULL a la meme comportement que la valeur 1
    if (pbd_RuptPERI[PER_LOCAL_FLAG] != NULL)
    {
        if (pbd_RuptPERI[PER_LOCAL_FLAG][0] != '\0')
            Local_Flag = atoi(pbd_RuptPERI[PER_LOCAL_FLAG]);
        else
            Local_Flag = 1;
    }
    else
        Local_Flag = 1;

    RETURN_VAL(OK);
}


/*==============================================================================
objet   :   trouve le gaap de referance
retour  :   index ---> gaap trouve
            -1    ---> Pas de gaap
==============================================================================*/
int find_gaap_ref()
{
    int col = 0;
    DEBUT_FCT("find_gaap_ref");

    for (col = 0; col < 4; ++col)
    {
        if (Ksz_MAJ_line_GT[col][0] != NULL)
            RETURN_VAL(col);
    }
    RETURN_VAL(-1);
}

/*==========================================================================                       [003]SUBTRS
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsLigne

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsLigne()
{
      
          strcpy(SubTrsLigne.DETTRNCOD_CF, "");
          strcpy(SubTrsLigne.SUBTRS_GL,"");
          strcpy(SubTrsLigne.SUBTRS_GS,"");
          strcpy(SubTrsLigne.SUBTRSEXP_D,""); 
          strcpy(SubTrsLigne.SUBTRSINC_D,"");
          SubTrsLigne.CMT_NT =0;
          SubTrsLigne.TRSINPUTTYPE_CT = 0;
          SubTrsLigne.TRSNATURE_CT = 0 ;
          strcpy(SubTrsLigne.LOGSIG_CT,"");
          strcpy(SubTrsLigne.LOB_CF,"");
          SubTrsLigne.TRSTYPE_CT = 0; 
          SubTrsLigne.TRSPURERETRO_B = 0;
          SubTrsLigne.DACTYPE_B   = 0;
          SubTrsLigne.COMPLEMENT_B = 0;
          SubTrsLigne.NEWBALSHEETPROPAG_B = 0;
          SubTrsLigne.CELLPROTECEXC_B = 0;
}

/*==============================================================================
objet   :   Init et nettoye la variable globale Ksz_Gaap_MNT
==============================================================================*/
void clean_Ksz_Gaap_MNT()
{
    int i = 0;
    DEBUT_FCT("clean_Ksz_Gaap_MNT");

    for (i = 0; i < NB_GAAP; ++i)
    {
        Ksz_Gaap_MNT[i] = 0.0;
    }
}


/*==============================================================================
objet   :   Init et nettoye la variable globale Ksz_MAJ_line_GT
==============================================================================*/
void clean_Ksz_MAJ_line_GT()
{
    int i = 0;
    int col = 0;
    DEBUT_FCT("clean_Ksz_MAJ_line_GT");

    for (i = 0; i < 4; ++i)
    {
        for (col = 0; col < NBCOL; ++col)
        {
            Ksz_MAJ_line_GT[i][col] = NULL;
        }
    }
}


/*==============================================================================
objet   :   Fonction d'affichage de message d'erreur
retour  :   ERR --> permet l'arret du programme
==============================================================================*/
int errorMsg(char *error)   // error : message d'erreur à écrire
{
    char    MsgAno[100];    /* message d'anomalie */

    sprintf(MsgAno, error);
    n_WriteAno(MsgAno);

    RETURN_VAL(ERR);
}
