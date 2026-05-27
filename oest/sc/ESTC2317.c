/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION - lot 23 (rapprochement)
nom du source                 : ESTC2317.c
revision                      : $Revision:   1.1  $
date de creation              : 08/10/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Calcul du resultat theorique

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
[01] 06/07/2022 S.Behague :spira:105553 ESID2530 job in error
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitGTAR(T_RUPTURE_VAR  *);
static int n_ActionLigneGTAR(char **);
int n_ConditionRupture1GTAR(char **, char **);
int n_ConditionRupture2GTAR(char **, char **);
static int n_ActionLast2GTAR(char ** );  
static int n_ActionFirst1GTAR(char ** );  
static int n_ActionFirst2GTAR(char ** );  

/*----------------------*/
/* variables de travail */
/*----------------------*/
BOOL Kb_Rappro;
double Kd_Ma;
double Kd_Mr;

static FILE *Kp_OutGtar100;   
static FILE *Kp_Dettrs;

static T_RUPTURE_VAR   Kbd_RuptGTAR;       


/*==============================================================================
objet :
   point d'entre du programme

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

        if ( n_OpenFileAppl ("ESTC2317_O1","wt",&Kp_OutGtar100) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2317_I2","rb",&Kp_Dettrs) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptGTAR  */
	if ( n_InitGTAR(&Kbd_RuptGTAR)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier */
	if ( n_ProcessingRuptureVar(&Kbd_RuptGTAR) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2317_O1",&Kp_OutGtar100)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2317_I1",&(Kbd_RuptGTAR.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2317_I2",&Kp_Dettrs)==ERR )
                ExitPgm ( ERR_XX , "" );
        
	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;

}


/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture du fichier
    maitre.

retour :
	0K ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitGTAR(T_RUPTURE_VAR  *pbd_RuptGTAR)
{
	memset(pbd_RuptGTAR,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2317_I1","rt",&(pbd_RuptGTAR->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptGTAR->n_NbRupture =2;    
	pbd_RuptGTAR->n_ActionLigne     = n_ActionLigneGTAR;
        pbd_RuptGTAR->n_ConditionRupture[0] = n_ConditionRupture1GTAR;
        pbd_RuptGTAR->n_ConditionRupture[1] = n_ConditionRupture2GTAR;
        pbd_RuptGTAR->n_ActionLast[1] = n_ActionLast2GTAR;
        pbd_RuptGTAR->n_ActionFirst[0] = n_ActionFirst1GTAR;
        pbd_RuptGTAR->n_ActionFirst[1] = n_ActionFirst2GTAR;

        pbd_RuptGTAR->c_Separ=SEPARATEUR;

	return OK ;
}

/*==============================================================================
objet :
        Test de rupture sur TRNCOD_CF

retour :
        0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
int n_ConditionRupture1GTAR(char ** tpsz_ReadBufferGTAR,
                           char ** tpsz_ReadBufferGTAR_Cur)
{
        DEBUT_FCT("n_ConditionRupture1GTAR");

	if ((strcmp(tpsz_ReadBufferGTAR[GT_TRNCOD_CF],tpsz_ReadBufferGTAR_Cur[GT_TRNCOD_CF]))!=0)
	return(1);
       
       RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Test de rupture sur  TRNCOD_CF
			 ---- SSD_CF/ESB_CF/ ----
                            CTR_NF/END_NT/SEC_NF/UWY_NF/UW_NT/
                            OCCYEA_NF/CLM_NF/
                            ACY_NF/SCOSTRMTH_NF/SCOENDMTH_NF/
                            CUR_CF/
                            RETCTR_NF/RETEND_NT/RETSEC_NF/RTY_NF/RETUW_NT/
                            RETCUR_CF 

retour :
        0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
int n_ConditionRupture2GTAR(char ** tpsz_ReadBufferGTAR,
                           char ** tpsz_ReadBufferGTAR_Cur)
{
	DEBUT_FCT("n_ConditionRupture2GTAR");

        if ((strcmp(tpsz_ReadBufferGTAR[GT_TRNCOD_CF],tpsz_ReadBufferGTAR_Cur[GT_TRNCOD_CF]))!=0)
           return(1);

/*        if((strcmp(tpsz_ReadBufferGTAR[GT_SSD_CF],tpsz_ReadBufferGTAR_Cur[GT_SSD_CF]))!=0)
           return(1);

        if((strcmp(tpsz_ReadBufferGTAR[GT_ESB_CF],tpsz_ReadBufferGTAR_Cur[GT_ESB_CF]))!=0)
           return(1);
*/
        if ((strcmp(tpsz_ReadBufferGTAR[GT_CTR_NF],tpsz_ReadBufferGTAR_Cur[GT_CTR_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_END_NT],tpsz_ReadBufferGTAR_Cur[GT_END_NT]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_SEC_NF],tpsz_ReadBufferGTAR_Cur[GT_SEC_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_UWY_NF],tpsz_ReadBufferGTAR_Cur[GT_UWY_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_UW_NT],tpsz_ReadBufferGTAR_Cur[GT_UW_NT]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_OCCYEA_NF],tpsz_ReadBufferGTAR_Cur[GT_OCCYEA_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_CLM_NF],tpsz_ReadBufferGTAR_Cur[GT_CLM_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_ACY_NF],tpsz_ReadBufferGTAR_Cur[GT_ACY_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_SCOSTRMTH_NF],tpsz_ReadBufferGTAR_Cur[GT_SCOSTRMTH_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_SCOENDMTH_NF],tpsz_ReadBufferGTAR_Cur[GT_SCOENDMTH_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_CUR_CF],tpsz_ReadBufferGTAR_Cur[GT_CUR_CF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_RETCTR_NF],tpsz_ReadBufferGTAR_Cur[GT_RETCTR_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_RETEND_NT],tpsz_ReadBufferGTAR_Cur[GT_RETEND_NT]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_RETSEC_NF],tpsz_ReadBufferGTAR_Cur[GT_RETSEC_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_RTY_NF],tpsz_ReadBufferGTAR_Cur[GT_RTY_NF]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_RETUW_NT],tpsz_ReadBufferGTAR_Cur[GT_RETUW_NT]))!=0)
           return(1);

        if ((strcmp(tpsz_ReadBufferGTAR[GT_RETCUR_CF],tpsz_ReadBufferGTAR_Cur[GT_RETCUR_CF]))!=0)
           return(1);

       RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Fonction lancee en rupture derniere 
        pour le fichier perimetre

retour :
        OK --->
        ERR --->
==============================================================================*/
static int n_ActionLast2GTAR(char ** tpsz_ReadBufferGTAR)
{   
	char    sz_Amt[21] ;    /* zone de travail: montant acceptation */
	char    sz_RetAmt[21] ; /* zone de travail: montant retrocession */

	DEBUT_FCT("n_ActionLast2GTAR");
 
       if ( Kb_Rappro == 1)
       {
                sprintf( sz_RetAmt, "%-.3f", Kd_Mr) ;
                sprintf( sz_Amt, "%-.3f", Kd_Ma) ;

                tpsz_ReadBufferGTAR[GT_RETAMT_M] = sz_RetAmt ;
                tpsz_ReadBufferGTAR[GT_AMT_M] = sz_Amt ;
                tpsz_ReadBufferGTAR[GT_TRNCOD_CF] = "99999999" ;
                tpsz_ReadBufferGTAR[GT_DBLTRNCOD_CF] = "" ;

                n_WriteCols( Kp_OutGtar100, tpsz_ReadBufferGTAR, SEPARATEUR, 0 ) ;

       }
       RETURN_VAL(OK);

}

/*==============================================================================
objet :
        Fonction lancee en rupture premiere

retour :
        OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirst1GTAR(char ** tpsz_ReadBufferGTAR)
{    
	DEBUT_FCT("n_ActionFirst1GTAR");

	/* Initialisation du flag qui indique si au moins un des postes */
	/* de la cle de rupture courante est rapprochable */
	Kb_Rappro = 0;

        if (b_PosteRappro(tpsz_ReadBufferGTAR[GT_TRNCOD_CF],Kp_Dettrs) == TRUE) 
        {
           Kb_Rappro = 1;
        }


       RETURN_VAL(OK);
}
 
/*==============================================================================
objet :
        Fonction lancee en rupture premiere

retour :
        OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirst2GTAR(char ** tpsz_ReadBufferGTAR)
{
	DEBUT_FCT("n_ActionFirst2GTAR");

	/* Initialisation des montants cumules */
	Kd_Ma=0.;
	Kd_Mr=0.;

       RETURN_VAL(OK);
}

                  
/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement                          */
/* Si le poste est rapprochable, les montants de la ligne                   */
/* sont ajoutes aux montants cumules                                        */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigneGTAR(char *tpsz_ReadBufferGTAR[])
{
	DEBUT_FCT("n_ActionLigneGTAR");

        if ( Kb_Rappro == 1 ) 
        {
           Kd_Ma = Kd_Ma + atof(tpsz_ReadBufferGTAR[GT_AMT_M]);
           Kd_Mr = Kd_Mr + atof(tpsz_ReadBufferGTAR[GT_RETAMT_M]);
        }

       RETURN_VAL(OK);
}







