/*==============================================================================
nom de l'application          : Verification des Poste analytique afin de les écarter
nom du source                 : ESTC8701.c
revision                      : 
date de creation              : 30/08/2016
auteur                        : MMA
references des specifications : SPOT : 31161 => SPIRA 053727 & 053733 
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
_________________


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
           *Kp_TecledaOFil,              // Pointeur sur le fichier de sortie de gaap
           *Kp_EsBpropIFil,             // Pointeur sur le fichier TRSESBPROP
           *Kp_TecledaErrFil,            // Pointeur sur le fichier de ligne en erreur de gaap diff
		   *Kp_SubTRSFil;          		// pointeur sur le fichier SUBTRS

T_RUPTURE_VAR       bd_RuptPrevision;   // Gestion rupture fichier prevision


T_SUBTRSESBPROP SubTrsEsBprop;					// Structure EsBprop
T_SUBTRS        SubTrsLigne;                    // Strucutre SubTrs

// Fonctions de synchronisation
int n_InitPrev (T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLIgne ( char **ptb_InRec_Cur);
int n_IsR0Prev (char **ptb_InRec,char **ptb_InRec_Cur);

// Fonctions utilitaires
void init_SubTrsEsBprop();
void init_SubTrsLigne();


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
    if ( n_OpenFileAppl ("ESTC8701_O1","wt",&Kp_TecledaOFil) == ERR )         ExitPgm ( ERR_XX , "" );

    if ( n_OpenFileAppl ("ESTC8701_O2","wt",&Kp_TecledaErrFil) == ERR )       ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptPrevision
    if ( n_InitPrev(&bd_RuptPrevision) )                                     ExitPgm ( ERR_XX , "" );

    // Chargement fichier T_SUBTRSBPROP
    if (n_OpenFileAppl ("ESTC8701_I2","rb",&Kp_EsBpropIFil) == ERR )         ExitPgm ( ERR_XX , "" );
    if ( n_ChargerSUBTRSESBPROP(Kp_EsBpropIFil) == ERR ) 			         ExitPgm( ERR_XX , "" ); 
    
    // initialisation de la structure retour
    init_SubTrsEsBprop();

    // Chargement fichier T_SUBTRS
    if (n_OpenFileAppl ("ESTC8701_I3","rb",&Kp_SubTRSFil) == ERR )           ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR ) 					         ExitPgm( ERR_XX , "" ); 

    // initialisation de la structure retour
    init_SubTrsLigne();

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptPrevision) == ERR )                 ExitPgm ( ERR_XX , "" );
    
    // Fermeture des fichiers
    if (n_CloseFileAppl ("ESTC8701_I1",&(bd_RuptPrevision.pf_InputFil)))     ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC8701_O1",&Kp_TecledaOFil))                      ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC8701_O2",&Kp_TecledaErrFil))                    ExitPgm ( ERR_XX , "" );

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

    if ( n_OpenFileAppl ("ESTC8701_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 0;

    pbd_Rupt->n_ActionLigne = n_ActionLIgne;
    
    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);	
}

/*==============================================================================
objet : Fonction lancee a chaque rupture première sur contrat/sec/uwy
        
==============================================================================*/
int n_ActionLIgne ( char **ptb_InRec_Cur)
{

    char   c_dettrncod[6];
    int    result_bprop = 0, result_subtrs = 0;

    DEBUT_FCT("n_ActionFirstRuptPrev");
/*
    printf("%s\n", ptb_InRec_Cur[GT_TRNCOD_CF]);*/

    memset(c_dettrncod, '\0', sizeof(c_dettrncod));

    strncpy(c_dettrncod, (ptb_InRec_Cur[GT_TRNCOD_CF])+2,5);

    // Appel fonction pour vérifier le paramètrage
    result_subtrs = n_FindTsubTRS(&SubTrsLigne,c_dettrncod);
    
    //si il existe un paramétrage
    if ( result_subtrs != (-1))
    {
        //si c'est un poste analytique
        if ( SubTrsLigne.TRSNATURE_CT == 2 )
        {
            //pour le poste/Filiale/Etablissement on vérifie le paramètrage d'alimentation du GLT
            result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, c_dettrncod, ptb_InRec_Cur[GT_SSD_CF], ptb_InRec_Cur[GT_ESB_CF]);
            if (result_bprop !=(-1))
            {
                if ( SubTrsEsBprop.GLTFEEDING_B != 0 )
                    n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);
                else
                    n_WriteCols(Kp_TecledaErrFil,ptb_InRec_Cur,SEPARATEUR,0);
            }
            else
                n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);
        }
        else 
            n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);
    }
    else
        n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);

    RETURN_VAL (0);
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