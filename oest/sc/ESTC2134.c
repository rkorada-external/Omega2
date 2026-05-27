/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Determination des previsions intermediaires
nom du source                 : ESTC2134.c
revision                      : $Revision:   1.0  $
date de creation              : 03/09/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Cumul des taux tous placements confondus
                sur chaque lien acceptation/retrocession

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    13/03/03       J. Ribot       ajout champs DEPORI_B
    19/09/05       J.Ribot        ajout champs PLA1_PLCSTS_CT (SPOT 11167)
    07/03/2016     R.BEN EZZINE : spot:29579 Impacts Retro EST
    29/03/2018     HH Huynh :spira 62073: ajout des champs BLCSHTSTR_D et BLCSHTEND_D	
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/


FILE            *Kp_PlaceIFile;           /* pointeur sur les placements en entree */
FILE            *Kp_PlaceOFile;          /* pointeur sur les placements en sortie */

T_RUPTURE_VAR           bd_RuptPlc;    /* gestion rupture sur pilotage */

int n_InitPlc(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePlc(char **pbd_InRec_Cur);
int n_IsR1Plc(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPlc(char **ptb_InRec_Cur);
int n_ActionLastRuptPlc(char **ptb_InRec_Cur);


/* variables de cumuls */
double  S_OVRCOM, S_RETSIGSHA;
double  S_CLMFUN, S_CLMFUNINT;
double  S_URRFUN, S_URRFUNINT;
int    Ind_DEPORI;


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2134_O1","wt",&Kp_PlaceOFile) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPlc */
        if ( n_InitPlc(&bd_RuptPlc) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPlc) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2134_I1",&(bd_RuptPlc.pf_InputFil)) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2134_O1",&Kp_PlaceOFile) == ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(0);
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :
        0
==============================================================================*/
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPlc");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2134_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 1 ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Plc;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPlc;
        pbd_Rupt->n_ActionLast[0]  = n_ActionLastRuptPlc;

        pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice de retrocession

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Plc(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Plc");

        if (strcmp(ptb_InRec[PLA1_RETCTR_NF],ptb_InRec_Cur[PLA1_RETCTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_RETSEC_NF],ptb_InRec_Cur[PLA1_RETSEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_RTY_NF],ptb_InRec_Cur[PLA1_RTY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_CTR_NF],ptb_InRec_Cur[PLA1_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_SEC_NF],ptb_InRec_Cur[PLA1_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_UWY_NF],ptb_InRec_Cur[PLA1_UWY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_UW_NT],ptb_InRec_Cur[PLA1_UW_NT])!=0)
                RETURN_VAL(1);

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptPlc (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptPlc");

    /* mise a zero des variables de cumuls */
    S_OVRCOM = 0;
    S_RETSIGSHA = 0;
    S_CLMFUN = 0;
    S_CLMFUNINT = 0;
    S_URRFUN = 0;
    S_URRFUNINT = 0;

    Ind_DEPORI = 0;

    RETURN_VAL(0);
}



/*==============================================================================
objet :
        Fonction lancee a chaque rupture derniere
==============================================================================*/
int n_ActionLastRuptPlc (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptPlc");

    /* mise au format */
    /* JR 13/03/03  ajout champs DEPORI_B */
	/* 29/03/2018     HH Huynh :spira 62073: ajout des champs BLCSHTSTR_D et BLCSHTEND_D	 */
fprintf(Kp_PlaceOFile,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%.8lf~%s~%s~%s~%s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%.8lf~%.8lf~%.8lf~%.8lf~%s~%s~%s~%s~%s~%d~%s~%s\n",
                ptb_InRec_Cur[PLA1_SSD_CF],
                ptb_InRec_Cur[PLA1_ESB_CF],
                ptb_InRec_Cur[PLA1_RETCTR_NF],
                "0",                            /* numero d'avenant retro */
                ptb_InRec_Cur[PLA1_RETSEC_NF],
                ptb_InRec_Cur[PLA1_RTY_NF],
                ptb_InRec_Cur[PLA1_RETUW_NT],
                "",                             /* numero placement */
                ptb_InRec_Cur[PLA1_PLCSTS_CT],
                S_OVRCOM,
                ptb_InRec_Cur[PLA1_RTO_NF],
                ptb_InRec_Cur[PLA1_INT_NF],
                ptb_InRec_Cur[PLA1_PAY_NF],
                ptb_InRec_Cur[PLA1_KEY_CF],
                ptb_InRec_Cur[PLA1_ORICUR_B],
                ptb_InRec_Cur[PLA1_SSDRTO_B],
                S_RETSIGSHA,
                ptb_InRec_Cur[PLA1_LOB_CF],
                ptb_InRec_Cur[PLA1_RAICOM_B],
                ptb_InRec_Cur[PLA1_RETOVRCOM_B],
                ptb_InRec_Cur[PLA1_CTR_NF],
                "0",                            /* avenant a 0 */
                ptb_InRec_Cur[PLA1_SEC_NF],
                ptb_InRec_Cur[PLA1_UWY_NF],
                ptb_InRec_Cur[PLA1_UW_NT],
                ptb_InRec_Cur[PLA1_CUR_CF],
                ptb_InRec_Cur[PLA1_CESSH_R],
                S_CLMFUN,
                S_URRFUN,
                S_CLMFUNINT,
                S_URRFUNINT,
                ptb_InRec_Cur[PLA1_CONRETCTR_B],
                ptb_InRec_Cur[PLA1_OVRBASIS_NT],
                ptb_InRec_Cur[PLA1_ACCFAM_CT],
                ptb_InRec_Cur[PLA1_ACCTYP_CT],
                ptb_InRec_Cur[PLA1_CTRNAT_CT],
                Ind_DEPORI,                 	/*ptb_InRec_Cur[PLA1_DEPORI_B]);  */
				ptb_InRec_Cur[PLA1_BLCSHTSTR_D],	/* :spira 62073: */
				ptb_InRec_Cur[PLA1_BLCSHTEND_D]		/* :spira 62073: */
				);
    RETURN_VAL(0);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc(char **ptb_InRec_Cur)
{

    DEBUT_FCT("n_ActionLignePlc");

    S_OVRCOM    += atof(ptb_InRec_Cur[PLA1_OVRCOM_R]) * atof(ptb_InRec_Cur[PLA1_RETSIGSHA_R]);
    S_RETSIGSHA += atof(ptb_InRec_Cur[PLA1_RETSIGSHA_R]);
    S_CLMFUN    += atof(ptb_InRec_Cur[PLA1_CLMFUN_R]) * atof(ptb_InRec_Cur[PLA1_RETSIGSHA_R]);
    S_CLMFUNINT += atof(ptb_InRec_Cur[PLA1_CLMFUNINT_R]) * atof(ptb_InRec_Cur[PLA1_CLMFUN_R]) * atof(ptb_InRec_Cur[PLA1_RETSIGSHA_R]);
    S_URRFUN    += atof(ptb_InRec_Cur[PLA1_URRFUN_R]) * atof(ptb_InRec_Cur[PLA1_RETSIGSHA_R]);
    S_URRFUNINT += atof(ptb_InRec_Cur[PLA1_URRFUNINT_R]) * atof(ptb_InRec_Cur[PLA1_URRFUN_R]) * atof(ptb_InRec_Cur[PLA1_RETSIGSHA_R]);

    if ((ptb_InRec_Cur[PLA1_DEPORI_B]!= NULL) &&(strcmp(ptb_InRec_Cur[PLA1_DEPORI_B],"1")==0))
       {
             Ind_DEPORI = 1;
       }
    RETURN_VAL (0);
}
