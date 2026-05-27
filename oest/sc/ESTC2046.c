/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Verification des différences de gaap/Verification type de poste/Calcul gaap interdit
nom du source                 : ESTC2046.c
revision                      : 
date de creation              : 28/04/2014
auteur                        : S. Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
 28/04/2014     SBE         Création

_________________

[001] 12/06/2014 JBG :spot:25773 Warning suppress
[XXX] 09/10/2014  JBG  :spot:25773  suppress warning: no newline at end of file
[002] 25/11/2014 SBE : modification comportement gaap interdit au début - On écrit pas les lignes en sortie.
[003] 17/02/2015 ABJ :  Spot 28298 : Gestion du Gaap 1 pour  les postes de regroupement non interdit en Gaap 1 
[004] 10/01/2019 S.Behague    :sbe - REQ.L.02.05: Evolution quarterly
[005] 21/08/2019 BEL : Spot-78167 : if Automatic Traite then all gaap amount equal to cedent Gaap
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE       *Kp_PrevIFil,                // Pointeur sur le fichier Lifest en entree
           *Kp_LifestOFil,              // Pointeur sur le fichier de sortie de gaap
           *Kp_EsBpropIFil,             // Pointeur sur le fichier TRSESBPROP
           *Kp_LifestErrFil,            // Pointeur sur le fichier de ligne en erreur de gaap diff
           *Kp_SubTRSFil;               // pointeur sur le fichier SUBTRS

T_RUPTURE_VAR       bd_RuptPrevision;   // Gestion rupture fichier prevision

char psz_SavLignePrevPrecedente[PRE_NBCOL+1][25];
char sz_GaapPrec[25]="9";
char sz_EstmntPrec[25]="1";
T_SUBTRSESBPROP SubTrsEsBprop;                  // Structure EsBprop
T_SUBTRS        SubTrsLigne;                    // Strucutre SubTrs

// Fonctions de synchronisation
int n_InitPrev (T_RUPTURE_VAR *pbd_Rupt);
int n_IsR0Prev (char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev ( char **ptb_InRec_Cur);
int n_IsR1Prev (char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionLastRuptPrev ( char **ptb_InRec_Cur);
int n_FlagFirst = 0;
int n_FlagCash = 0;
int n_FlagAuto = 0;

// Fonctions utilitaires
void sav_LignePrevPrecedente(char **pbd_LignePrev);
void init_SubTrsEsBprop();
void init_SubTrsLigne();
int n_GaapInterdit( int , T_SUBTRSESBPROP * );


/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    // Initialisation des signaux
    InitSig () ;
    
    if ( n_BeginPgm (argc  ,argv) == ERR )                                   ExitPgm ( ERR_XX , "" );
    
    // Ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2046_O1","wt",&Kp_LifestOFil) == ERR )         ExitPgm ( ERR_XX , "" );

    if ( n_OpenFileAppl ("ESTC2046_O2","wt",&Kp_LifestErrFil) == ERR )       ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptPrevision
    if ( n_InitPrev(&bd_RuptPrevision) )                                     ExitPgm ( ERR_XX , "" );

    // Chargement fichier T_SUBTRSBPROP
    if (n_OpenFileAppl ("ESTC2046_I2","rb",&Kp_EsBpropIFil) == ERR )         ExitPgm ( ERR_XX , "" );
    if ( n_ChargerSUBTRSESBPROP(Kp_EsBpropIFil) == ERR )                     ExitPgm( ERR_XX , "" ); 
    
    // initialisation de la structure retour
    init_SubTrsEsBprop();

    // Chargement fichier T_SUBTRS
    if (n_OpenFileAppl ("ESTC2046_I3","rb",&Kp_SubTRSFil) == ERR )           ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR )                             ExitPgm( ERR_XX , "" ); 

    // initialisation de la structure retour
    init_SubTrsLigne();

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptPrevision) == ERR )                 ExitPgm ( ERR_XX , "" );
    
    // Fermeture des fichiers
    if (n_CloseFileAppl ("ESTC2046_I1",&(bd_RuptPrevision.pf_InputFil)))     ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2046_O1",&Kp_LifestOFil))                      ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2046_O2",&Kp_LifestErrFil))                    ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                ExitPgm ( ERR_XX , "" );

    exit(0) ;
}
/*************** Fin Main ****************/

/*============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier prevision.
retour :    0
============================================================================================*/
int n_InitPrev (T_RUPTURE_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitReserve");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2046_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 2;

    pbd_Rupt->n_ConditionRupture[0] = n_IsR0Prev;
    pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrev;
    
    pbd_Rupt->n_ConditionRupture[1] = n_IsR1Prev;
    pbd_Rupt->n_ActionLast[1] = n_ActionLastRuptPrev;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0); 
}

/*==============================================================================
objet :     fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR0Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR0Prev");

    if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ESTMTH_NF],ptb_InRec_Cur[PRE_ESTMTH_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACMTRS_NT],ptb_InRec_Cur[PRE_ACMTRS_NT])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF],ptb_InRec_Cur[PRE_DETTRNCOD_CF])!=0)     RETURN_VAL(1);
    
    RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction de test de rupture du niveau 2
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1Prev");

    if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)                 RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ESTMTH_NF],ptb_InRec_Cur[PRE_ESTMTH_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACMTRS_NT],ptb_InRec_Cur[PRE_ACMTRS_NT])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF],ptb_InRec_Cur[PRE_DETTRNCOD_CF])!=0)     RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_GAAP_NF],ptb_InRec_Cur[PRE_GAAP_NF])!=0)               RETURN_VAL(1);
    
    RETURN_VAL (0);
}

/*==============================================================================
objet : Fonction lancee a chaque rupture première sur contrat/sec/uwy
        
==============================================================================*/
int n_ActionFirstRuptPrev ( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptPrev");
    n_FlagFirst = 1 ;
    n_FlagCash = 0;
    n_FlagAuto = 0;
    
    RETURN_VAL (0);
}
/*==============================================================================
objet : Fonction lancee a chaque rupture derniere sur contrat/sec/uwy
        Cela permet de recuperer les infos du perimetre sur le CTR/SEC/UWY
==============================================================================*/
int n_ActionLastRuptPrev ( char **ptb_InRec_Cur)
{
    double montantEnCours = 0;
    double montantPrecedent = 0;
    double gaapDiff = 0;
    double montantDiffGaap1 = 0;
    char   sz_GaapDiff[25]="0.000";
    char   sz_gaapEnCours[2];
    int    gaapOrg;
    char   sz_montantEnCours[25]="0.000";
    int    i;
    int    resultgaap = 0, result_bprop=0, result_cash = 0;

    DEBUT_FCT("n_ActionLastRuptPrev");
    
    montantEnCours=atof(ptb_InRec_Cur[PRE_ESTMNT_M]);
    montantPrecedent=atof(sz_EstmntPrec);

    if ( n_FlagFirst == 1 )
    {
        if ( atoi(ptb_InRec_Cur[PRE_GAAP_NF]) != 1 )
        {
            montantDiffGaap1=atof(ptb_InRec_Cur[PRE_ESTMNT_M]);
        }
        sprintf(sz_GaapDiff,"%.3lf",montantDiffGaap1);
        ptb_InRec_Cur[PRE_GAAPDIFF_M]=sz_GaapDiff;
        n_FlagFirst = 0 ;
        // Appel fonction pour vérifier si c'est un poste cash
        result_cash = n_FindTsubTRS(&SubTrsLigne,ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
        if ( result_cash != (-1) )
        {   // [005] : 
            // Si poste Cash ou Traite AUTO ==> le montant de tous les GAAP = montant de Gaap1
            if ( SubTrsLigne.TRSTYPE_CT == 1 || strcmp(ptb_InRec_Cur[PRE_ESTCRB_CT], "A") == 0)
            {
                int MAX_I = 6;
                // [005] :
                // Si poste Cash, on ecrit le montant sur tous les gaap 
                // Si Traite AUTO on ecrit le montant sur les gaap {1,2,3,4} et 0.000 sur Gaap5                
                if (SubTrsLigne.TRSTYPE_CT == 1)
                {
                   n_FlagCash = 1;
                }
                if (strcmp(ptb_InRec_Cur[PRE_ESTCRB_CT], "A") == 0 && SubTrsLigne.TRSTYPE_CT != 1)
                { 
                   // [005] : Si c'est un Traite Automatique
                   n_FlagAuto = 1;
                   MAX_I = 5;
                }

                // [005] : On ecrit le montant sur tous les gaap dans [1 ; MAX_I].
                for (i=1; i < MAX_I; i++)
                {
                    ptb_InRec_Cur[PRE_GAAPDIFF_M]="0";
                    sprintf(sz_montantEnCours,"%.3lf",montantEnCours);
                    sprintf(sz_gaapEnCours,"%d",i);
                    ptb_InRec_Cur[PRE_ESTMNT_M]=sz_montantEnCours;
                    ptb_InRec_Cur[PRE_GAAP_NF]=sz_gaapEnCours;
                    n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);
                }

                if (n_FlagAuto == 1)
                {
                    // [005] : Dans le cas d'un Traite Auto
                    // les montants des gaap 1, 2, 3 et 4 sont egales

                    sprintf(sz_gaapEnCours,"%d",5);
                    ptb_InRec_Cur[PRE_GAAP_NF]    = sz_gaapEnCours;

                    // Appel fonction pour vérifier si le gaap est interdit
                    result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, ptb_InRec_Cur[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_SSD_CF], ptb_InRec_Cur[PRE_ESB_CF]);
                    resultgaap = n_GaapInterdit(atoi(ptb_InRec_Cur[PRE_GAAP_NF]),&SubTrsEsBprop);
                    if ( resultgaap == 1 )
                    { 
                       // Si Gaap5 est interdit --> le montant du gaap 5 est egale a '0.000'
                       ptb_InRec_Cur[PRE_ESTMNT_M]   = "0.000";

                       if (montantEnCours != 0)
                       {
                          sprintf(sz_montantEnCours,"%.3lf",-montantEnCours);
                          ptb_InRec_Cur[PRE_GAAPDIFF_M]=sz_montantEnCours;
                       }
                       else
                       {
                          ptb_InRec_Cur[PRE_GAAPDIFF_M] = "0";
                       }
                    }
                    else
                    {
                       ptb_InRec_Cur[PRE_GAAPDIFF_M]="0";
                       sprintf(sz_montantEnCours,"%.3lf",montantEnCours);
                       ptb_InRec_Cur[PRE_ESTMNT_M]=sz_montantEnCours;
                    }
                    n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);
                }
            }
            else      // if pas Cash [003]
            {
                if ( atoi(ptb_InRec_Cur[PRE_GAAP_NF]) != 1 )  // on commence pas par le Gaap Cedant 
             { 
                
                  gaapOrg= atoi(ptb_InRec_Cur[PRE_GAAP_NF]);
                   for (i=1; i<atoi(ptb_InRec_Cur[PRE_GAAP_NF]); i++)
                     {
                          result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, ptb_InRec_Cur[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_SSD_CF], ptb_InRec_Cur[PRE_ESB_CF]);
                    resultgaap = n_GaapInterdit(i,&SubTrsEsBprop);
                     if ( resultgaap != 1 )
                     {
                           ptb_InRec_Cur[PRE_GAAPDIFF_M]="0";
                         sprintf(sz_gaapEnCours,"%d",i);
                     ptb_InRec_Cur[PRE_ESTMNT_M]="0";
                     ptb_InRec_Cur[PRE_GAAP_NF]=sz_gaapEnCours;
                     n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);
                   
                         } 
                     } 
                        resultgaap=0;
                        result_bprop=0;
                        sprintf(sz_montantEnCours,"%.3lf",montantEnCours);
                        ptb_InRec_Cur[PRE_ESTMNT_M]=sz_montantEnCours;
                        sprintf(sz_gaapEnCours,"%d",gaapOrg);
                    ptb_InRec_Cur[PRE_GAAP_NF]=sz_gaapEnCours;
                    ptb_InRec_Cur[PRE_GAAPDIFF_M]=sz_GaapDiff;
                   
             } 
           } 
        }       
        else
        {
            // Si erreur de la fonction de recherche de type poste, on réécrit tel quelle la ligne
            n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);
        }
        if ( n_FlagCash == 0 && n_FlagAuto == 0)
        {
            // Appel fonction pour vérifier si le gaap est interdit
            result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, ptb_InRec_Cur[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_SSD_CF], ptb_InRec_Cur[PRE_ESB_CF]);
            resultgaap = n_GaapInterdit(atoi(ptb_InRec_Cur[PRE_GAAP_NF]),&SubTrsEsBprop);
            if ( resultgaap == 1 )
            {
                montantEnCours = 0;
                resultgaap = 0;
                sprintf(sz_montantEnCours,"%.3lf",montantEnCours);
                ptb_InRec_Cur[PRE_ESTMNT_M]=sz_montantEnCours;
                n_FlagFirst = 1 ; //[002]
                //n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0); [002]
                // On n'écrit pas la ligne si le 1er gaap rencontré est interdit.
                // Si on écrit pas la ligne on considère qu'on est toujours sur le 1er gaap trouvé 
            }
            else 
            {
                n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);
            }
        }
    }
    else if ( atoi(sz_GaapPrec) < atoi(ptb_InRec_Cur[PRE_GAAP_NF]) && n_FlagFirst == 0 && n_FlagCash == 0 && n_FlagAuto == 0)
    {
        // Appel fonction pour vérifier si le gaap est interdit
        result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, ptb_InRec_Cur[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_SSD_CF], ptb_InRec_Cur[PRE_ESB_CF]);
        resultgaap = n_GaapInterdit(atoi(ptb_InRec_Cur[PRE_GAAP_NF]),&SubTrsEsBprop);
        if ( resultgaap == 1 )
        {
            montantEnCours = 0;
            resultgaap = 0;
        }
    
        // Vérification de la différence de montant
        if ( montantEnCours != montantPrecedent || montantEnCours == 0)
        {
            gaapDiff = montantEnCours - montantPrecedent;
            //if ( gaapDiff != atof(ptb_InRec_Cur[PRE_GAAPDIFF_M]) )
            //{
                // Si GAAP_DIFF différent, on écrit la ligne en erreur dans le fichier ERR des gaap recalculés
                // Si GAAP_DIFF différent, on réécrit la ligne avec la différence de GAAP calculée
                sprintf(sz_GaapDiff,"%.3lf",gaapDiff);
                sprintf(sz_montantEnCours,"%.3lf",montantEnCours);
                ptb_InRec_Cur[PRE_GAAPDIFF_M]=sz_GaapDiff;
                ptb_InRec_Cur[PRE_ESTMNT_M]=sz_montantEnCours;
                n_WriteCols(Kp_LifestErrFil,ptb_InRec_Cur,SEPARATEUR,0);
                n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);            //}
            //else 
            //{
                // Si GAAP_DIFF identique, on réécrit la ligne telle quelle
            //    n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);
            //}
        }
        else 
        {
            // Si aucune différence de montant, on réécrit la ligne avec 0 dans le gaapDiff
            strcpy(sz_GaapDiff,"0.000");
            ptb_InRec_Cur[PRE_GAAPDIFF_M]=sz_GaapDiff;
            n_WriteCols(Kp_LifestOFil,ptb_InRec_Cur,SEPARATEUR,0);
        }
    }
    sav_LignePrevPrecedente(ptb_InRec_Cur);

    RETURN_VAL(0);
}

/*=============================================================================
objet:  Sauvegarde la ligne prevision pour comparaison

Parametre:  La ligne courante des previsions
=============================================================================*/
void sav_LignePrevPrecedente(char **pbd_LignePrev)
{
    strcpy(sz_GaapPrec,pbd_LignePrev[PRE_GAAP_NF]);
    strcpy(sz_EstmntPrec,pbd_LignePrev[PRE_ESTMNT_M]);
}

/*==========================================================================
     Objet :    Initialisation de la structure TRSESBPROP

     Nom:       init_SubTrsEsBprop

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsEsBprop()
{
            strcpy(SubTrsEsBprop.DETTRNCOD_CF, "");
            SubTrsEsBprop.SSD_CF=0;
            SubTrsEsBprop.ESB_CF=0;
            SubTrsEsBprop.GLTFEEDING_B=0;
            SubTrsEsBprop.INTERNRETRO_B=0;
            SubTrsEsBprop.SRVFEEDING_B=0;
            SubTrsEsBprop.PREMIUMPNPEGPI_B=0;
            SubTrsEsBprop.RETROAUTO_B=0;
            SubTrsEsBprop.COMACIMPACT_B=0;
            SubTrsEsBprop.CASHFLOWPOS_CT=0;
            SubTrsEsBprop.GAAP1TRS_CT=0;
            SubTrsEsBprop.GAAP2TRS_CT=0;
            SubTrsEsBprop.GAAP3TRS_CT=0;
            SubTrsEsBprop.GAAP4TRS_CT=0;
            SubTrsEsBprop.GAAP5TRS_CT=0;
            strcpy(SubTrsEsBprop.CRE_D,"");
            strcpy(SubTrsEsBprop.CREUSR_CF,"");
            strcpy(SubTrsEsBprop.LSTUPD_D,"");
            strcpy(SubTrsEsBprop.LSTUPDUSR_CF,"");
}

/*==========================================================================
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

/*=============================================================================
objet:
        Retourne si le gaap passé en paramètre est interdit ou non
Parametre:
        
Retour:
        -> 1 - Si interdit / 0 - Si autorisé
=============================================================================*/
int n_GaapInterdit( int n_gaap, T_SUBTRSESBPROP * s_EsbProp )
{
    switch(n_gaap)
    {
        case 1:
            if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
            {
                return 1;
            }
            else
            {
                return 0;
            }
            break;
        case 2:
            if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
            {
                return 1;
            }
            else
            {
                return 0;
            }
            break;
        case 3:
            if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
            {
                return 1;
            }
            else
            {
                return 0;
            }
            break;
        case 4:
            if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
            {
                return 1;
            }
            else
            {
                return 0;
            }
                break;                                                      
        case 5:
            if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
            {
                return 1;
            }
            else
            {
                return 0;
            }
            break;
    }    
    
    RETURN_VAL(1);
}
