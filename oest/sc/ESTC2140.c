/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Ventilation des complements previsionnels
nom du source                 : ESTC2140.c
revision                      : $Revision:   1.5  $
date de creation              : 16/09/1997
auteur                        : P. LOUVEAU
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Traitements effectues sur les rapprochements dont le mode de ventilation
        est 3 ou 4.

                        -  ETAPE 2,3  -

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

    29/01/2003  J. Ribot  ajout un champs retro pour reto interne.
    11/07/2003	JR	ne plus faire ex +1 sur liberations depots postes 1303 2303 1323 2323
[003] Florent  06/09/2011 :spot:22315 corrections gestion des libérations
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
#define TAILLE_MAX_TAB          1000

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE            *Kp_Comp34Fil;          /* pointeur sur les complements modes 3 et 4 */
FILE            *Kp_Cours;              /* pointeur sur le fichier des taux */

T_RUPTURE_VAR           bd_RuptRapp;    /* gestion rupture sur les rapprochements */


double  Kd_SommeAliment;
double  Kd_SommeAffAliment;
int     Kn_NbCumul;     /* nbre d'element dans le tableau cumul */
int     Kn_NbAffBro;    /* nbre d'affaires courtees */
int     Kn_annee;       /* Annee Bilan */
int     Kn_annee1;       /* Annee Bilan +1*/
char    Ksz_CloDat[9];          /* Libelle d'inventaire : parametre */
char    Annee_bilan[5] ;
char    Mois_bilan[3] ;
char    Jour_bilan[3] ;


int n_InitRapp(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneRapp(char **pbd_InRec_Cur);
int n_IsR1Rapp(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptRapp(char **ptb_InRec_Cur);
int n_ActionLastRuptRapp(char **ptb_InRec_Cur);


typedef struct{
    char        SSD_CF[3];
    char        ESB_CF[3];
    char        BALSHEY_NF[5];
    char        BALSHRMTH_NF[3];
    char        BALSHRDAY_NF[3];
    char        TRNCOD_CF[9];
    char        DBLTRNCOD_CF[9];
    char        CTR_NF[10];
    char        END_NT[2];
    char        SEC_NF[3];
    char        UWY_NF[5];
    char        UW_NT[2];
    char        OCCYEA_NF[5];
    char        ACY_NF[5];
    char        SCOSTRMTH_NF[3];
    char        SCOENDMTH_NF[3];
    char        CLM_NF[10];
    char        CUR_CF[4];
    char        AMT_M[22];
    char        CED_NF[6];
    char        BRK_NF[6];
    char        PAY_NF[6];
    char        KEY_NF[5];
    char        ESTCUR_CF[4];
    char        ESTAMT_M[22];
    char        NAT_CF[3];
    char        ACMTRS_NT[5];
    char        ESTCTR_NF[10];
    char        ESTSEC_NF[3];
    char        LOB_CF[3];
    char        SCOEGP_M[22];
    char        ESTCRB_CT[2];
    char        LIFTRTTYP_CF[3];
    char        ACCADMTYP_CT[2];
    char        SECSTS_CT[5];
    char        PRD_NF[5];
    char        SEG_NF[11];
    char        COMACC_B[2];
    char        ADJCOD_CT[10];
    char        ORICOD_CF[10];
    char        DETTRS_CF[10];
    char        ACCRET_B[2];
    char        ESTUWY_NF[5];
    char        LSTENDMTH_NF[3];
    char        PROPER_N[10];
    char        RTOCTY_CF[10];
    char        SIGMOD_CT[10];
    char        BRKSCOEGP_M[22];
    char        SPIMOD_CT[10];
    char        GAAP_NF[10];
} TMouvement;

TMouvement  Tab_Cumul[TAILLE_MAX_TAB];


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
        char    sz_annee[5];

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Recuperation de l'annee bilan */
        strcpy (sz_annee, psz_GetCharArgv(1));
        Kn_annee = atoi(sz_annee);
		Kn_annee1 = atoi(sz_annee)+1;

	/* Recuperation du libelle d'inventaire en parametre */
        strcpy( Ksz_CloDat, psz_GetCharArgv( 2 ) ) ;

        /* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
        sscanf( Ksz_CloDat, "%4s%2s%2s", Annee_bilan, Mois_bilan, Jour_bilan ) ;

        /* Ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2140_O1","wt",&Kp_Comp34Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_OpenFileAppl("ESTC2140_I2", "rb", &Kp_Cours) == ERR)
                ExitPgm(ERR_XX , "");

        /* Initialisation de la varible bd_RuptRapp */
        if ( n_InitRapp(&bd_RuptRapp) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptRapp) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2140_I1",&(bd_RuptRapp.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2140_I2", &Kp_Cours) == ERR)
                ExitPgm(ERR_XX , "");

        if (n_CloseFileAppl ("ESTC2140_O1",&Kp_Comp34Fil))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(0) ;
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        0
==============================================================================*/
int n_InitRapp(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitRapp");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2140_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 1 ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Rapp;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptRapp;
        pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptRapp;

        pbd_Rupt->n_ActionLigne = n_ActionLigneRapp ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction de test de rupture de niveau 1
        sur Contrat/Section de ratt./Exercice/Accumulation Transaction

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Rapp(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Rapp");

        if (strcmp(ptb_InRec[GT_ESTCTR_NF],ptb_InRec_Cur[GT_ESTCTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[GT_ESTSEC_NF],ptb_InRec_Cur[GT_ESTSEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[GT_ESTUWY_NF],ptb_InRec_Cur[GT_ESTUWY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[GT_ACMTRS_NT],ptb_InRec_Cur[GT_ACMTRS_NT])!=0)
                RETURN_VAL(1);

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptRapp (char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionFirstRuptRapp");

        Kd_SommeAliment = 0;
        Kd_SommeAffAliment = 0;
        Kn_NbCumul=0;
	Kn_NbAffBro = 0 ;

        RETURN_VAL(0);
}




/*==============================================================================
objet :
        Fonction lancee a chaque rupture derniere de niveau 1
==============================================================================*/
int n_ActionLastRuptRapp (char **ptb_InRec_Cur)
{
    double      montant;
    int         type_poste;
    int         i;
    int 	exercice, poste_cumule, poste_comptable;

    DEBUT_FCT("n_ActionLastRuptRapp");

    for (i=0; i<Kn_NbCumul; i++)
    {
        /* Calcul du montant */
        type_poste = atoi(Tab_Cumul[i].ACMTRS_NT) % 1000;

        if ( (type_poste != 123) && (type_poste != 124) )
	{
        	/* cas ou la somme des aliments est nulle */
		if ( Kd_SommeAliment == 0 )
			montant = atof(ptb_InRec_Cur[GT_AMT_M]) * (atof(Tab_Cumul[i].SCOEGP_M) ) / Kn_NbCumul ;
		else	montant = atof(ptb_InRec_Cur[GT_AMT_M]) * (atof(Tab_Cumul[i].SCOEGP_M) ) / Kd_SommeAliment ;
	}
        else
	{
		/* cas ou la somme des aliments (affaires courtees) est nulle */
		if ( Kd_SommeAffAliment == 0 )
			montant = ( Kn_NbAffBro == 0 ? 0 : ( atof(ptb_InRec_Cur[GT_AMT_M]) * (atof(Tab_Cumul[i].BRKSCOEGP_M) ) / Kn_NbAffBro ) ) ;
		else	montant = atof(ptb_InRec_Cur[GT_AMT_M]) * (atof(Tab_Cumul[i].BRKSCOEGP_M) ) / Kd_SommeAffAliment;
	}

        /* Modif ANB le 6/10/98 : plus de conversion */

        /*d_taux = d_GetTaux (  Kp_Cours,
                                (unsigned char) atoi(Tab_Cumul[i].SSD_CF),
                                (short) Kn_annee,
                                Tab_Cumul[i].ESTCUR_CF,
                                Tab_Cumul[i].CUR_CF );

		if ( d_taux < 0 )
		{
		sprintf( MsgAno, "The conversion between %s and %s failed for the fictitious contract ( CTR %s - SEC %s ) and the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s )\n",
			Tab_Cumul[i].ESTCUR_CF, Tab_Cumul[i].CUR_CF,
			Tab_Cumul[i].ESTCTR_NF, Tab_Cumul[i].ESTSEC_NF,
			Tab_Cumul[i].CTR_NF, Tab_Cumul[i].END_NT,
                	Tab_Cumul[i].SEC_NF, Tab_Cumul[i].UWY_NF,
               		Tab_Cumul[i].UW_NT ) ;
		n_WriteAno( MsgAno ) ;

		montant = 0 ;
		}

		montant *= d_taux;*/

		/* Modifs du 30/03/98 - M.HA-THUC */
        /* Ecriture en sortie si montant > 1 unité en valeur absolue */

	if ( montant > 1 || montant < -1 )
	{
        fprintf(Kp_Comp34Fil, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~%s\n",
                Tab_Cumul[i].SSD_CF,
                Tab_Cumul[i].ESB_CF,
                Annee_bilan,
                Mois_bilan,
                Jour_bilan,
                Tab_Cumul[i].TRNCOD_CF,
                Tab_Cumul[i].DBLTRNCOD_CF,
                Tab_Cumul[i].CTR_NF,
                Tab_Cumul[i].END_NT,
                Tab_Cumul[i].SEC_NF,
                Tab_Cumul[i].UWY_NF,
                Tab_Cumul[i].UW_NT,
                Tab_Cumul[i].OCCYEA_NF,
                Tab_Cumul[i].ACY_NF,
                Tab_Cumul[i].SCOSTRMTH_NF,
                Tab_Cumul[i].SCOENDMTH_NF,
                Tab_Cumul[i].CLM_NF,
                Tab_Cumul[i].ESTCUR_CF,
                montant,
                Tab_Cumul[i].CED_NF,
                Tab_Cumul[i].BRK_NF,
                Tab_Cumul[i].PAY_NF,
                Tab_Cumul[i].KEY_NF,
                "",  "",  "", "", "",            /* partie retrocessionnaire */
                "",  "",  "", "", "",
                "",  "",  "", "", "",
                "", "", "",                      /* ajout un champs retro pour reto interne JR 29 01 03 */
                Tab_Cumul[i].ESTCUR_CF,
                montant,
                Tab_Cumul[i].NAT_CF,
                Tab_Cumul[i].ACMTRS_NT,
                Tab_Cumul[i].ESTCTR_NF,
                Tab_Cumul[i].ESTSEC_NF,
                Tab_Cumul[i].LOB_CF,
                Tab_Cumul[i].SCOEGP_M,
                Tab_Cumul[i].ESTCRB_CT,
                Tab_Cumul[i].LIFTRTTYP_CF,
                Tab_Cumul[i].ACCADMTYP_CT,
                Tab_Cumul[i].SECSTS_CT,
                Tab_Cumul[i].PRD_NF,
                Tab_Cumul[i].SEG_NF,
                Tab_Cumul[i].COMACC_B,
                Tab_Cumul[i].ADJCOD_CT,
                Tab_Cumul[i].ORICOD_CF,
                Tab_Cumul[i].DETTRS_CF,
                Tab_Cumul[i].ACCRET_B,
                Tab_Cumul[i].ESTUWY_NF,
                Tab_Cumul[i].LSTENDMTH_NF,
                Tab_Cumul[i].PROPER_N,
                Tab_Cumul[i].RTOCTY_CF,
                Tab_Cumul[i].GAAP_NF,               
                Tab_Cumul[i].BRKSCOEGP_M,
                Tab_Cumul[i].SPIMOD_CT
                );
	}

	/****************************************************************/
	/* Modifs du 15/04/98 - M.HA-THUC et G.BUISSON			*/
	/* On ne genere pas de liberation quand l'annee de compte est	*/
	/* superieure ou egale au bilan + 1 				*/
	/****************************************************************/
	/* pour chaque constitution  on genere la liberation correspondante */
        if ( Tab_Cumul[i].ACMTRS_NT[3] == '3' && atoi(Tab_Cumul[i].ACY_NF) <=  Kn_annee1 )
        {

					poste_cumule=atoi(Tab_Cumul[i].ACMTRS_NT) + 1;
					poste_comptable=atoi(Tab_Cumul[i].TRNCOD_CF) + 1000;
				  exercice = atoi(Tab_Cumul[i].UWY_NF) + i_LiberationExeP1( atoi(Tab_Cumul[i].ACMTRS_NT) , atoi(Tab_Cumul[i].ACCADMTYP_CT) ) ; //[003]
				if ( montant > 1 || montant < -1 )
				{
        fprintf(Kp_Comp34Fil, "%s~%s~%s~%s~%s~%d~%s~%s~%s~%s~%d~%s~%s~%d~%s~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%s~%d~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~%s\n",
                Tab_Cumul[i].SSD_CF,
                Tab_Cumul[i].ESB_CF,
                Annee_bilan,
                Mois_bilan,
                Jour_bilan,
                poste_comptable,
                Tab_Cumul[i].DBLTRNCOD_CF,
                Tab_Cumul[i].CTR_NF,
                Tab_Cumul[i].END_NT,
                Tab_Cumul[i].SEC_NF,
                exercice,
                Tab_Cumul[i].UW_NT,
                Tab_Cumul[i].OCCYEA_NF,
                atoi(Tab_Cumul[i].ACY_NF) + 1,
                Tab_Cumul[i].SCOSTRMTH_NF,
                Tab_Cumul[i].SCOENDMTH_NF,
                Tab_Cumul[i].CLM_NF,
                Tab_Cumul[i].ESTCUR_CF,
                montant* (-1.),
                Tab_Cumul[i].CED_NF,
                Tab_Cumul[i].BRK_NF,
                Tab_Cumul[i].PAY_NF,
                Tab_Cumul[i].KEY_NF,
                "",  "",  "", "", "",            /* partie retrocessionnaire */
                "",  "",  "", "", "",
                "",  "",  "", "", "",
                "", "", "",                      /* ajout un champs retro pour reto interne JR 29 01 03 */
                Tab_Cumul[i].ESTCUR_CF,
                montant* (-1.),
                Tab_Cumul[i].NAT_CF,
                poste_cumule,
                Tab_Cumul[i].ESTCTR_NF,
                Tab_Cumul[i].ESTSEC_NF,
                Tab_Cumul[i].LOB_CF,
                Tab_Cumul[i].SCOEGP_M,
                Tab_Cumul[i].ESTCRB_CT,
                Tab_Cumul[i].LIFTRTTYP_CF,
                Tab_Cumul[i].ACCADMTYP_CT,
                Tab_Cumul[i].SECSTS_CT,
                Tab_Cumul[i].PRD_NF,
                Tab_Cumul[i].SEG_NF,
                Tab_Cumul[i].COMACC_B,
                Tab_Cumul[i].ADJCOD_CT,
                Tab_Cumul[i].ORICOD_CF,
                Tab_Cumul[i].DETTRS_CF,
                Tab_Cumul[i].ACCRET_B,
                Tab_Cumul[i].ESTUWY_NF,
                Tab_Cumul[i].LSTENDMTH_NF,
                Tab_Cumul[i].PROPER_N,
                Tab_Cumul[i].RTOCTY_CF,
                Tab_Cumul[i].GAAP_NF,               
                Tab_Cumul[i].BRKSCOEGP_M,
                Tab_Cumul[i].SPIMOD_CT
                );
				}
			}
    }
        RETURN_VAL(0);
}



/*==============================================================================
objet :
        Fonction lancee pour chaque ligne : cumul et stockage ligne
==============================================================================*/
int n_ActionLigneRapp ( char **ptb_InRecCur )
{
    char        MsgAno[300];

    DEBUT_FCT("n_ActionLigneGT");

    /* calcul du nombre d'affaires courtees */
    if ( atof(ptb_InRecCur[GT_BRKSCOEGP_M]) != 0 )
	Kn_NbAffBro += 1 ;

    Kd_SommeAliment    += atof(ptb_InRecCur[GT_SCOEGP_M]);
    Kd_SommeAffAliment += atof(ptb_InRecCur[GT_BRKSCOEGP_M]);

    /* memorisation dans le tableau cumul */
    if ( Kn_NbCumul >= TAILLE_MAX_TAB )
    {
            /* depassement tableau */
            sprintf(MsgAno,"The number of contrats by fictitious contract (/CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program's storage capacity",
                      ptb_InRecCur[GT_CTR_NF],
                      ptb_InRecCur[GT_END_NT],
                      ptb_InRecCur[GT_SEC_NF],
                      ptb_InRecCur[GT_UWY_NF],
                      ptb_InRecCur[GT_UW_NT] );
            n_WriteAno(MsgAno);
            RETURN_VAL(0);
    }

        /* memorisation dans le tableau cumul */
        strcpy(Tab_Cumul[Kn_NbCumul].SSD_CF , ptb_InRecCur[GT_SSD_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].ESB_CF , ptb_InRecCur[GT_ESB_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].BALSHEY_NF , ptb_InRecCur[GT_BALSHEY_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].BALSHRMTH_NF , ptb_InRecCur[GT_BALSHRMTH_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].BALSHRDAY_NF , ptb_InRecCur[GT_BALSHRDAY_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].TRNCOD_CF , ptb_InRecCur[GT_TRNCOD_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].DBLTRNCOD_CF , ptb_InRecCur[GT_DBLTRNCOD_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].CTR_NF , ptb_InRecCur[GT_CTR_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].END_NT , ptb_InRecCur[GT_END_NT]);
        strcpy(Tab_Cumul[Kn_NbCumul].SEC_NF , ptb_InRecCur[GT_SEC_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].UWY_NF , ptb_InRecCur[GT_UWY_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].UW_NT , ptb_InRecCur[GT_UW_NT]);
        strcpy(Tab_Cumul[Kn_NbCumul].OCCYEA_NF , ptb_InRecCur[GT_OCCYEA_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].ACY_NF , ptb_InRecCur[GT_ACY_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].SCOSTRMTH_NF , ptb_InRecCur[GT_SCOSTRMTH_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].SCOENDMTH_NF , ptb_InRecCur[GT_SCOENDMTH_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].CLM_NF , ptb_InRecCur[GT_CLM_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].CUR_CF , ptb_InRecCur[GT_CUR_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].AMT_M , ptb_InRecCur[GT_AMT_M]);
        strcpy(Tab_Cumul[Kn_NbCumul].CED_NF , ptb_InRecCur[GT_CED_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].BRK_NF , ptb_InRecCur[GT_BRK_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].PAY_NF , ptb_InRecCur[GT_PAY_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].KEY_NF , ptb_InRecCur[GT_KEY_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].ESTCUR_CF , ptb_InRecCur[GT_ESTCUR_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].ESTAMT_M , ptb_InRecCur[GT_ESTAMT_M]);
        strcpy(Tab_Cumul[Kn_NbCumul].NAT_CF , ptb_InRecCur[GT_NAT_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].ACMTRS_NT , ptb_InRecCur[GT_ACMTRS_NT]);
        strcpy(Tab_Cumul[Kn_NbCumul].ESTCTR_NF , ptb_InRecCur[GT_ESTCTR_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].ESTSEC_NF , ptb_InRecCur[GT_ESTSEC_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].LOB_CF , ptb_InRecCur[GT_LOB_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].SCOEGP_M , ptb_InRecCur[GT_SCOEGP_M]);
        strcpy(Tab_Cumul[Kn_NbCumul].ESTCRB_CT , ptb_InRecCur[GT_ESTCRB_CT]);
        strcpy(Tab_Cumul[Kn_NbCumul].LIFTRTTYP_CF , ptb_InRecCur[GT_LIFTRTTYP_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].ACCADMTYP_CT , ptb_InRecCur[GT_ACCADMTYP_CT]);
        strcpy(Tab_Cumul[Kn_NbCumul].SECSTS_CT , ptb_InRecCur[GT_SECSTS_CT]);
        strcpy(Tab_Cumul[Kn_NbCumul].PRD_NF , ptb_InRecCur[GT_PRD_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].SEG_NF , ptb_InRecCur[GT_SEG_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].COMACC_B , ptb_InRecCur[GT_COMACC_B]);
        strcpy(Tab_Cumul[Kn_NbCumul].ADJCOD_CT , ptb_InRecCur[GT_ADJCOD_CT]);
        strcpy(Tab_Cumul[Kn_NbCumul].ORICOD_CF , ptb_InRecCur[GT_ORICOD_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].DETTRS_CF , ptb_InRecCur[GT_DETTRS_CF]); 
        strcpy(Tab_Cumul[Kn_NbCumul].ACCRET_B , ptb_InRecCur[GT_ACCRET_B]);
        strcpy(Tab_Cumul[Kn_NbCumul].ESTUWY_NF , ptb_InRecCur[GT_UWY_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].LSTENDMTH_NF , ptb_InRecCur[GT_LSTENDMTH_NF]);
        strcpy(Tab_Cumul[Kn_NbCumul].PROPER_N , ptb_InRecCur[GT_PROPER_N]);
        strcpy(Tab_Cumul[Kn_NbCumul].RTOCTY_CF , ptb_InRecCur[GT_RTOCTY_CF]);
        strcpy(Tab_Cumul[Kn_NbCumul].SPIMOD_CT , ptb_InRecCur[GT_SPIMOD_CT]);
        strcpy(Tab_Cumul[Kn_NbCumul].BRKSCOEGP_M , ptb_InRecCur[GT_BRKSCOEGP_M]);
        strcpy(Tab_Cumul[Kn_NbCumul].GAAP_NF , ptb_InRecCur[GT_GAAP_NF]);
        Kn_NbCumul++;

        RETURN_VAL (0);
}



