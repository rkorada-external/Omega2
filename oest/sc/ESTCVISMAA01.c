/*==============================================================================
Nom de l'application          : GENERATION DU FICHIER MENSUEL VISMA GTA
Nom du source                 : ESTCVISMAA01.c
Revision                      : $Revision:   1.0  $
Date de creation              : 22/05/2008
Auteur                        : D.GATIBELZA
Squelette de base             : batch
------------------------------------------------------------------------------
Description :       Génération du fichier mensuel VISMA GTA pour la Suède 
                    ESTDOM16015 Specifications for the Omega to Visma interface (phase mensuelle)
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "struct.h"

//#define TRACE_1


/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE *OutputFileVISMAA;         /* Pointeur sur le fichier de sortie        */
FILE *OutputFileGTA;            /* Pointeur sur le fichier de sortie        */

T_RUPTURE_VAR  	*pbd_Rupture;   /* Pointeur sur la structure de la rupture  */
T_UTCTLIB        bd_utctlib ;



/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/
int n_InitRupture       (T_RUPTURE_VAR  *);
int n_ActionLigne       (char **);
int n_InitVariables     ();
int n_InitClosingDate   (char **ptb_InRec_Cur);

CS_RETCODE n_RecupereLabels (T_UTCTLIB *, char **);
CS_RETCODE n_labels         (T_UTCTLIB *);
CS_RETCODE n_InitCalend     (T_UTCTLIB *);
CS_RETCODE n_calend         (T_UTCTLIB *);
CS_RETCODE n_EnteteVISMAA   ();


/*----------------------*/
/* Variables globales   */
/*----------------------*/
char type_traite[3]="12";   // Acceptation      ( et 14 pour la rétro )
char label_type_traite[30]="Foreign busin.accept. Life";


typedef struct type{
    CS_SMALLINT BLCSHTYEA_NF;
    CS_TINYINT  BLCSHTMTH_NF;
    CS_CHAR     ACCOUNT_D[9];
    CS_BIT      CLOSING_B;
}struct_tcalend;

struct_tcalend  *str_tcalend[1000];

int booking_date=0;
int treatment_date=0;
int treatment_year=0;
int taille_tcalend=0;
int annee_booking_date=0;
int mois_booking_date=0;
int December_closing_date=0;
int March_closing_date=0;
char label_cedente[26]="";
char label_pays[4]="";
char LOB_CF[3]="";
char label_Lob[17]="";
char GAR_CF[4]="";
char label_guarantie[17]="";
char TOP_CF[4]="";
char label_ToP[17]="";
char label_poste[65]="";
char balshey_nf[5]="";
char DateT[9]="";
char DateTime[18]="";



/**************************************************************************/
/*** Nom : main                                                         ***/
/*** Parametres:                                                        ***/
/***    i argc : nombre de parametres                                   ***/
/***    i argv : tableau de pointeurs sur les parametres                ***/
/*** Retour:                                                            ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int main( int argc, char *argv[] )
{
    pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));

    /* Initialisation des signaux */
    InitSig();

    if (n_BeginPgm(argc, argv) == ERR)                                          ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");

    strcpy(DateT,psz_GetCharArgv(1));
    strcpy(DateTime,psz_GetCharArgv(2));


    /* Connexion Sybase                 */
    if (n_SetGlobalUtctlib  (&bd_utctlib) == ERR)                               ExitPgm(ERR_XX , "Erreur appel fonction n_SetGlobalUtctlib");
    if (n_LocalConnect      (&bd_utctlib) != CS_SUCCEED)                        ExitPgm(ERR_XX , "Erreur appel fonction n_LocalConnect");

    if (n_InitCalend        (&bd_utctlib) != CS_SUCCEED)                        ExitPgm(ERR_XX , "Erreur appel fonction n_InitCalend");

    /* Ouverture des fichiers de sortie   */
    if (n_OpenFileAppl("ESTCVISMAA01_O1", "wt", &OutputFileGTA) == ERR)         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl OutputFileGTA");
    if (n_OpenFileAppl("ESTCVISMAA01_O2", "wt", &OutputFileVISMAA) == ERR)      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl OutputFileVISMAA");

    /* Initialisation de la structure de rupture */
    if (n_InitRupture(pbd_Rupture) == ERR)                                      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");

    /* Lancement du traitement du fichier maitre */
    if (n_ProcessingRuptureVar(pbd_Rupture) == ERR)                             ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");

    /* Fermeture des fichiers */
    if (n_CloseFileAppl("ESTCVISMAA01_I1", &(pbd_Rupture->pf_InputFil)) == ERR) ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl pf_InputFil");
    if (n_CloseFileAppl("ESTCVISMAA01_O1", &OutputFileGTA) == ERR)              ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl OutputFileGTA");
    if (n_CloseFileAppl("ESTCVISMAA01_O2", &OutputFileVISMAA) == ERR)           ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl OutputFileVISMAA");

    /* Déconnexion */
    if (n_LocalDisconnect   (&bd_utctlib) != CS_SUCCEED)                        ExitPgm(ERR_XX, "Erreur appel fonction n_LocalDisconnect");

    if (n_EndPgm() == ERR)                                                      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");

    free(pbd_Rupture);

  exit(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture                  ***/
/*** Nom :          n_InitRupture                                       ***/
/*** Parametres:    i pbd_Rupture : pointeur sur la structure de rupture***/
/*** Retour:        OK si pas d'erreur, ERR si erreur.                  ***/
/**************************************************************************/
int n_InitRupture( T_RUPTURE_VAR *pbd_Rupture )
{
    DEBUT_FCT("n_InitRupture");

    memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

    /* Ouverture du fichier maitre */
    if (n_OpenFileAppl("ESTCVISMAA01_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR)
        RETURN_VAL(ERR);

    pbd_Rupture->n_NbRupture=0;
    pbd_Rupture->n_ActionLigne=n_ActionLigne;
    pbd_Rupture->c_Separ= '~';

  RETURN_VAL(OK);
}



/**************************************************************************/
/*** Objet :    fonction lancee pour chaque ligne du fichier maitre     ***/
/*** Nom :      n_ActionLigne                                           ***/
/*** Parametres:i ptsz_LigneCour : pointeur sur la ligne courante       ***/
/*** Retour:    OK si pas d'erreur, ERR si erreur.                      ***/
/**************************************************************************/
int n_ActionLigne(char **ptb_InRec_Cur)
{
  CS_BOOL Ligne_a_envoyer=FALSE;
  
  int accounting_year=0;
  char err_msg[256]="";
  static int numero_ligne=1;

    
    DEBUT_FCT("n_ActionLigne");

    n_InitVariables();
    
    if (n_InitClosingDate(ptb_InRec_Cur) != CS_SUCCEED)
        ExitPgm(ERR_XX , "Erreur appel fonction n_InitClosingDate");

    // 1.Select only transaction codes ending with 0 (no estimates).
    if(strlen(ptb_InRec_Cur[GT_TRNCOD_CF])!=8)
    {
        sprintf(err_msg, "problème TRNCOD_CF:[%s] ne fait pas 8 caractères\n", ptb_InRec_Cur[GT_TRNCOD_CF]);
        ExitPgm(ERR_XX, err_msg);
    }
    else
    if(ptb_InRec_Cur[GT_TRNCOD_CF][7]=='0')
    {
        Ligne_a_envoyer=TRUE;
        accounting_year=atoi(ptb_InRec_Cur[GT_ACY_NF]);
    }



    //3. Calculate Visma Balance sheet year : as the annual reporting ends up in February for Sweden,
    //   and in December for France, the technical items booked in January and February,
    //   for past accounting years,  will have to feed the previous balance sheet year in Visma. 
    //   If balance_sheet_month <= 2 and accounting_year < Omega_balance_sheet_year, 
    //   then Visma_balance_sheet_year = Omega_balance_sheet_year - 1
    //   else Visma_balance_sheet_year = Omega_balance_sheet_year.
    if( Ligne_a_envoyer==TRUE )
    {
        if( atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]) <= 2 && accounting_year < atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) )
            sprintf(balshey_nf, "%d", atoi(ptb_InRec_Cur[GT_BALSHEY_NF])-1);
        else
            strcpy(balshey_nf, ptb_InRec_Cur[GT_BALSHEY_NF]);
    }



    // 4.   Select only information for the current Visma_balance_sheet_year.
    //      The change of year will be done on March closing date
    //      (to be defined as a parameter, in case we need to change it). 
    //      If treatment date < march_closing_date (from TCALEND)
    //      Then select lines where Visma_balance_sheet_year = treatment year -1
    //      else select lines where Visma_balance_sheet_year = treatment year
    //
    //	    Note : Using this condition, incoming reserves will be sent to Visma from March on,
    //             even though they are generated in Omega earlier, at the same time as the outgoing reserves.
    if( Ligne_a_envoyer==TRUE )
    {
        treatment_date=atoi(DateT);
        treatment_year=(int)(treatment_date/10000);
                        
        // Then select lines where Visma_balance_sheet_year = treatment year -1
        if( treatment_date < March_closing_date )
        {
            if( atoi(balshey_nf) == treatment_year-1 )
                Ligne_a_envoyer=TRUE;
            else
                Ligne_a_envoyer=FALSE;
        }
        else
        // else select lines where Visma_balance_sheet_year <= treatment year
        {
            if( atoi(balshey_nf) <= treatment_year )
                Ligne_a_envoyer=TRUE;
            else
                Ligne_a_envoyer=FALSE;
        } 
    }


    // Dans le cas d'une ligne à envoyer à VISMA :
    if(Ligne_a_envoyer==TRUE)
    {

        // 3. Add missing fields and labels : see §2.2. File format and lay-out.
        if (n_RecupereLabels(&bd_utctlib, ptb_InRec_Cur) !=1)      ExitPgm ( ERR_XX , "Error on n_RecupereLabels" );

#ifdef TRACE_1
printf("%s %d~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
    DateTime,                           //  0               // 2. Add a line identifier to each record, with date and time of run + a counter starting at 1. This line id will enable Visma to control the lines received (not insert twice the same items). 
    numero_ligne++,                     //  0   line_id     // 2. Add a line identifier to each record, with date and time of run + a counter starting at 1. This line id will enable Visma to control the lines received (not insert twice the same items). 
    ptb_InRec_Cur[GT_SSD_CF],           //  1   subsidiary_id
    ptb_InRec_Cur[GT_ESB_CF],           //  2   establishment_id
    ptb_InRec_Cur[GT_CED_NF],           //  3   cedent_number
    label_cedente,                      //  4   cedent_label
    ptb_InRec_Cur[GT_CTR_NF],           //  5   treaty_number
    ptb_InRec_Cur[GT_SEC_NF],           //  6   section_number
    ptb_InRec_Cur[GT_ACY_NF],           //  7   Accouning Year 
    type_traite,                        //  8   treaty_type_label
    label_type_traite,                  //  9   treaty_type_label
    label_pays,                         // 10   country
    LOB_CF,                             // 11   Lob
    label_Lob,                          // 12   Lob_label
    GAR_CF,                             // 13   guarantee
    label_guarantie,                    // 14   guarantee_label
    TOP_CF,                             // 15   ToP
    label_ToP,                          // 16   ToP_label
    balshey_nf,                         // 17   balance_sheet_year
    ptb_InRec_Cur[GT_TRNCOD_CF],        // 18   accounting_code
    label_poste,                        // 19   accounting_label
    ptb_InRec_Cur[GT_BALSHEY_NF],       // 20   balance_sheet_year
    ptb_InRec_Cur[GT_BALSHRMTH_NF],     // 21   balance_sheet_month
    ptb_InRec_Cur[GT_BALSHRDAY_NF],     // 22   balance_sheet_day
    ptb_InRec_Cur[GT_CUR_CF],           // 23   currency
    ptb_InRec_Cur[GT_AMT_M]);           // 24   amount
#endif

        // Créée ligne d'entête
        n_EnteteVISMAA();

        // Fichier au format VISMA
        //                          0  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
        fprintf(OutputFileVISMAA, "%s %d~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                        DateTime,                           //  0               // 2. Add a line identifier to each record, with date and time of run + a counter starting at 1. This line id will enable Visma to control the lines received (not insert twice the same items). 
                        numero_ligne++,                     //  0   line_id     // 2. Add a line identifier to each record, with date and time of run + a counter starting at 1. This line id will enable Visma to control the lines received (not insert twice the same items). 
                        ptb_InRec_Cur[GT_SSD_CF],           //  1   subsidiary_id
                        ptb_InRec_Cur[GT_ESB_CF],           //  2   establishment_id
                        ptb_InRec_Cur[GT_CED_NF],           //  3   cedent_number
                        label_cedente,                      //  4   cedent_label
                        ptb_InRec_Cur[GT_CTR_NF],           //  5   treaty_number
                        ptb_InRec_Cur[GT_SEC_NF],           //  6   section_number
                        ptb_InRec_Cur[GT_ACY_NF],           //  7   Accouning Year 
                        type_traite,                        //  8   treaty_type_label
                        label_type_traite,                  //  9   treaty_type_label
                        label_pays,                         // 10   country
                        LOB_CF,                             // 11   Lob
                        label_Lob,                          // 12   Lob_label
                        GAR_CF,                             // 13   guarantee
                        label_guarantie,                    // 14   guarantee_label
                        TOP_CF,                             // 15   ToP
                        label_ToP,                          // 16   ToP_label
                        balshey_nf,                         // 17   balance_sheet_year
                        ptb_InRec_Cur[GT_TRNCOD_CF],        // 18   accounting_code
                        label_poste,                        // 19   accounting_label
                        ptb_InRec_Cur[GT_BALSHEY_NF],       // 20   balance_sheet_year
                        ptb_InRec_Cur[GT_BALSHRMTH_NF],     // 21   balance_sheet_month
                        ptb_InRec_Cur[GT_BALSHRDAY_NF],     // 22   balance_sheet_day
                        ptb_InRec_Cur[GT_CUR_CF],           // 23   currency
                        ptb_InRec_Cur[GT_AMT_M]);           // 24   amount

    }
    else    // Dans le cas contraire, on réécrit le fichier en GTA
    {
        //Réécriture du fichier GTA
        //                       0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
        fprintf(OutputFileGTA, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                        ptb_InRec_Cur[GT_SSD_CF],           //  0
                        ptb_InRec_Cur[GT_ESB_CF],           //  1
                        ptb_InRec_Cur[GT_BALSHEY_NF],       //  2
                        ptb_InRec_Cur[GT_BALSHRMTH_NF],     //  3
                        ptb_InRec_Cur[GT_BALSHRDAY_NF],     //  4
                        ptb_InRec_Cur[GT_TRNCOD_CF],        //  5
                        ptb_InRec_Cur[GT_DBLTRNCOD_CF],     //  6
                        ptb_InRec_Cur[GT_CTR_NF],           //  7
                        ptb_InRec_Cur[GT_END_NT],           //  8
                        ptb_InRec_Cur[GT_SEC_NF],           //  9
                        ptb_InRec_Cur[GT_UWY_NF],           // 10
                        ptb_InRec_Cur[GT_UW_NT],            // 11
                        ptb_InRec_Cur[GT_OCCYEA_NF],        // 12
                        ptb_InRec_Cur[GT_ACY_NF],           // 13
                        ptb_InRec_Cur[GT_SCOSTRMTH_NF],     // 14
                        ptb_InRec_Cur[GT_SCOENDMTH_NF],     // 15
                        ptb_InRec_Cur[GT_CLM_NF],           // 16
                        ptb_InRec_Cur[GT_CUR_CF],           // 17
                        ptb_InRec_Cur[GT_AMT_M],            // 18
                        ptb_InRec_Cur[GT_CED_NF],           // 19
                        ptb_InRec_Cur[GT_BRK_NF],           // 20
                        ptb_InRec_Cur[GT_PAY_NF],           // 21
                        ptb_InRec_Cur[GT_KEY_NF],           // 22
                        ptb_InRec_Cur[GT_RETCTR_NF],        // 23
                        ptb_InRec_Cur[GT_RETEND_NT],        // 24
                        ptb_InRec_Cur[GT_RETSEC_NF],        // 25
                        ptb_InRec_Cur[GT_RTY_NF],           // 26
                        ptb_InRec_Cur[GT_RETUW_NT],         // 27
                        ptb_InRec_Cur[GT_RETOCCYEA_NF],     // 28
                        ptb_InRec_Cur[GT_RETACY_NF],        // 29
                        ptb_InRec_Cur[GT_RETSCOSTRMTH_NF],  // 30
                        ptb_InRec_Cur[GT_RETSCOENDMTH_NF],  // 31
                        ptb_InRec_Cur[GT_RCL_NF],           // 32
                        ptb_InRec_Cur[GT_RETCUR_CF],        // 33
                        ptb_InRec_Cur[GT_RETAMT_M],         // 34
                        ptb_InRec_Cur[GT_PLC_NT],           // 35
                        ptb_InRec_Cur[GT_RTO_NF],           // 36
                        ptb_InRec_Cur[GT_INT_NF],           // 37
                        ptb_InRec_Cur[GT_RETPAY_NF],        // 38
                        ptb_InRec_Cur[GT_RETKEY_CF],        // 39
                        ptb_InRec_Cur[GT_RETINTAMT_M]);     // 40
    }


  RETURN_VAL(OK);
}



/**************************************************************************
 *** Objet :  Initialisation des Variables Globales
 ***    CS_SUCCEED si pas d'erreur,
 ***    CS_FAIL     si erreur
 **************************************************************************/
int n_InitVariables()
{

    DEBUT_FCT("n_InitVariables");

    strcpy(label_cedente,   "");
    strcpy(label_pays,      "");
    strcpy(LOB_CF,          "");
    strcpy(label_Lob,       "");
    strcpy(GAR_CF,          "");
    strcpy(label_guarantie, "");
    strcpy(TOP_CF,          "");
    strcpy(label_ToP,       "");
    strcpy(balshey_nf,      "");
    strcpy(label_poste,     "");

  RETURN_VAL(OK);
}



/**************************************************************************
 *** Objet :  Initialisation de TCALEND
 **************************************************************************/
CS_RETCODE n_InitCalend(T_UTCTLIB *dom_utctlib)
{
  CS_RETCODE retcode;

    DEBUT_FCT("n_InitCalend");

#ifdef TRACE_1
printf("Appel : BEST..PsCALENDVISMA_01\n");
#endif

    // Fonction de traitement d'une ligne résultat du SELECT de la procédure
    dom_utctlib->n_RowFetchData = n_calend;

	retcode = n_ProcessingProc(dom_utctlib, 0, "BEST..PsCALENDVISMA_01");

    if (retcode != CS_SUCCEED)
        ExitPgm ( ERR_XX , "n_ProcessingProc : erreur appel de BEST..PsCALENDVISMA_01\n" );

  RETURN_VAL(CS_SUCCEED);
}

/**************************************************************************
 *** Objet :  Récupération des données de la proc
 **************************************************************************/
CS_RETCODE n_calend(T_UTCTLIB *dom_utctlib)
{
  char err_msg[256]="";

    DEBUT_FCT("n_calend");

#ifdef TRACE_1
printf("Avant malloc\n");
#endif

    if((str_tcalend[taille_tcalend]=(struct_tcalend *)malloc(sizeof(struct_tcalend)))==NULL)
    {
        sprintf(err_msg, "impossible d'allouer str_tcalend[%d]\n", taille_tcalend);
        ExitPgm(ERR_XX, err_msg);
    }
#ifdef TRACE_1
printf("=> OK\n");
#endif

    str_tcalend[taille_tcalend]->BLCSHTYEA_NF=s_GetSmallintValue(dom_utctlib,0);
    str_tcalend[taille_tcalend]->BLCSHTMTH_NF=c_GetTinyintValue(dom_utctlib,1);
    strcpy(str_tcalend[taille_tcalend]->ACCOUNT_D,pc_GetStringValue(dom_utctlib,2));
    str_tcalend[taille_tcalend]->CLOSING_B=c_GetBitValue(dom_utctlib,3);

#ifdef TRACE_1
printf("CS_RETCODE n_calend(T_UTCTLIB *dom_utctlib)\n");
printf("n_calend: [%d][%d][%s][%d]\n",
    str_tcalend[taille_tcalend]->BLCSHTYEA_NF,
    str_tcalend[taille_tcalend]->BLCSHTMTH_NF,
    str_tcalend[taille_tcalend]->ACCOUNT_D,
    str_tcalend[taille_tcalend]->CLOSING_B);
#endif

    taille_tcalend++;

  RETURN_VAL(CS_SUCCEED);
}


/**************************************************************************
 *** Objet :  Initialisation des Closing dates
 **************************************************************************/
int n_InitClosingDate(char **ptb_InRec_Cur)
{
  int i;

    DEBUT_FCT("n_InitClosingDate");


    December_closing_date=0;

    booking_date = (atoi(ptb_InRec_Cur[GT_BALSHEY_NF])*10000) +
                   (atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF])*100) +
                   (atoi(ptb_InRec_Cur[GT_BALSHRDAY_NF]));

    annee_booking_date=atoi(ptb_InRec_Cur[GT_BALSHEY_NF]);
    mois_booking_date=atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]);

#ifdef TRACE_1
printf("booking_date:%d:\n", booking_date);
printf("annee_booking_date:%d:\n", annee_booking_date);
printf("mois_booking_date:%d:\n", mois_booking_date);
#endif

    for(i=0;i<taille_tcalend;i++)
    {
        if(annee_booking_date-1==str_tcalend[i]->BLCSHTYEA_NF && str_tcalend[i]->BLCSHTMTH_NF==12)
        {
            December_closing_date=atoi(str_tcalend[i]->ACCOUNT_D);
        }

        if(annee_booking_date==str_tcalend[i]->BLCSHTYEA_NF && str_tcalend[i]->BLCSHTMTH_NF==3)
        {
            March_closing_date=atoi(str_tcalend[i]->ACCOUNT_D);
        }
    }
#ifdef TRACE_1
printf("==> December_closing_date:%d:\n", December_closing_date);
printf("==> March_closing_date:%d:\n", March_closing_date);
printf("\n");
#endif

  RETURN_VAL(CS_SUCCEED);
}


/**************************************************************************
 *** Objet :  Recherche des Labels
 **************************************************************************/
CS_RETCODE n_RecupereLabels(T_UTCTLIB *dom_utctlib, char **ptb_InRec_Cur)
{
  CS_RETCODE    retcode;
  CS_CHAR       s_CTR_NF[10];
  CS_CHAR       s_TRNCOD_CF[9];
  CS_INT        n_CED_NF;
  CS_SMALLINT   n_UWY_NF;
  CS_TINYINT    n_UW_NT;
  CS_TINYINT    n_END_NT;
  CS_TINYINT    n_SEC_NF;

    DEBUT_FCT("n_RecupereLabels");

    strcpy(s_CTR_NF,    ptb_InRec_Cur[GT_CTR_NF]);
    strcpy(s_TRNCOD_CF, ptb_InRec_Cur[GT_TRNCOD_CF]);
    n_CED_NF = atoi(ptb_InRec_Cur[GT_CED_NF]);
    n_UWY_NF = atoi(ptb_InRec_Cur[GT_UWY_NF]);
    n_UW_NT  = atoi(ptb_InRec_Cur[GT_UW_NT]);
    n_END_NT = atoi(ptb_InRec_Cur[GT_END_NT]);
    n_SEC_NF = atoi(ptb_InRec_Cur[GT_SEC_NF]);

    
#ifdef TRACE_1
printf("exec BEST..PsLABELVISMA_01 %d, '%s', %d, %d, %d, %d, '%s'\n",
    (int)n_CED_NF,
    s_CTR_NF,
    (int)n_UWY_NF,
    (int)n_UW_NT,
    (int)n_END_NT,
    (int)n_SEC_NF,
    s_TRNCOD_CF);
#endif
    dom_utctlib->n_RowFetchData = n_labels;
    retcode = n_CallProc( dom_utctlib, 7, "BEST..PsLABELVISMA_01",
                          "@p_CED_NF",    CS_INPUTVALUE, CS_INT_TYPE,     &n_CED_NF,    sizeof(CS_INT),      0,
                          "@p_CTR_NF",    CS_INPUTVALUE, CS_CHAR_TYPE,     s_CTR_NF,    9,                   0,
                          "@p_UWY_NF",    CS_INPUTVALUE, CS_SMALLINT_TYPE,&n_UWY_NF,    sizeof(CS_SMALLINT), 0,
                          "@p_UW_NT",     CS_INPUTVALUE, CS_TINYINT_TYPE, &n_UW_NT,     sizeof(CS_TINYINT),  0,
                          "@p_END_NT",    CS_INPUTVALUE, CS_TINYINT_TYPE, &n_END_NT,    sizeof(CS_TINYINT),  0,
                          "@p_SEC_NF",    CS_INPUTVALUE, CS_TINYINT_TYPE, &n_SEC_NF,    sizeof(CS_TINYINT),  0,
                          "@p_TRNCOD_CF", CS_INPUTVALUE, CS_CHAR_TYPE,     s_TRNCOD_CF, 8,                   0 );
    if (retcode != CS_SUCCEED)
        ExitPgm ( ERR_XX , "n_CallProc : erreur appel de BEST..PsLABELVISMA_01\n" );

#ifdef TRACE_1
printf("=> OK\n");
#endif


  RETURN_VAL(CS_SUCCEED);
}


/**************************************************************************
 *** Objet :  Récupération des données de la proc
 **************************************************************************/
CS_RETCODE n_labels(T_UTCTLIB *dom_utctlib)
{
  DEBUT_FCT("n_labels");

    strcpy(label_cedente,pc_GetStringValue(dom_utctlib,0));         // label_cedente
    strcpy(label_pays,pc_GetStringValue(dom_utctlib,1));            // label_pays
    strcpy(LOB_CF,pc_GetStringValue(dom_utctlib,2));                // LOB_CF
    strcpy(label_Lob,pc_GetStringValue(dom_utctlib,3));             // label_Lob
    strcpy(GAR_CF,pc_GetStringValue(dom_utctlib,4));                // GAR_CF
    strcpy(label_guarantie,pc_GetStringValue(dom_utctlib,5));       // label_guarantie
    strcpy(TOP_CF,pc_GetStringValue(dom_utctlib,6));                // TOP_CF
    strcpy(label_ToP,pc_GetStringValue(dom_utctlib,7));             // label_ToP
    strcpy(label_poste,pc_GetStringValue(dom_utctlib,8));           // label_poste
    
#ifdef TRACE_1
printf("label_poste:%s:", label_poste);         // label_cedente
#endif

  RETURN_VAL(CS_SUCCEED);
}




/**************************************************************************
 *** Objet : Création de l'entête du fichier VISMAA
 **************************************************************************/
CS_RETCODE n_EnteteVISMAA()
{
  static CS_BOOL b_entete=TRUE;

    DEBUT_FCT("n_EnteteVISMAA");

#ifdef TRACE_1
#endif

    if(b_entete==TRUE)
    {
        // Fichier au format VISMA
        //                          0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
        fprintf(OutputFileVISMAA, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                        "line_id",                      //  0
                        "subsidiary_id",                //  1
                        "establishment_id",             //  2
                        "cedent_number",                //  3
                        "cedent_label",                 //  4
                        "treaty_number",                //  5
                        "section_number",               //  6
                        "Accounting_Year",              //  7
                        "treaty_type",                  //  8
                        "treaty_type_label",            //  9
                        "country",                      // 10
                        "Lob",                          // 11
                        "Lob_label",                    // 12
                        "guarantee",                    // 13
                        "guarantee_label",              // 14
                        "ToP",                          // 15
                        "ToP_label",                    // 16
                        "Visma_balance_sheet_year",     // 17
                        "accounting_code",              // 18
                        "accounting_label",             // 19
                        "balance_sheet_year",           // 20
                        "balance_sheet_month",          // 21
                        "balance_sheet_day",            // 22
                        "currency",                     // 23
                        "amount");                      // 24
        b_entete=FALSE;
    }

  RETURN_VAL(CS_SUCCEED);
}


