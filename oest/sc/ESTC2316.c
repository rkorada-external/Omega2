/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION - lot 23 (rapprochement)
nom du source                 : ESTC2316.c
revision                      : $Revision:   1.0  $
date de creation              : 08/10/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Calcul du resultat comptable

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
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
int n_ConditionRuptureGTAR(char **, char **);
static int n_ActionLastGTAR(char ** );  
static int n_ActionFirstGTAR(char ** );  

/*----------------------*/
/* variables de travail */
/*----------------------*/
BOOL Kb_Rappro;
double Kd_Rc;

static FILE *Kp_FRAPP;   
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

        if ( n_OpenFileAppl ("ESTC2316_O1","wt",&Kp_FRAPP) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2316_I2","rb",&Kp_Dettrs) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptGTAR  */
	if ( n_InitGTAR(&Kbd_RuptGTAR)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier */
	if ( n_ProcessingRuptureVar(&Kbd_RuptGTAR) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2316_O1",&Kp_FRAPP)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2316_I1",&(Kbd_RuptGTAR.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2316_I2",&Kp_Dettrs)==ERR )
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

	if ( n_OpenFileAppl ("ESTC2316_I1","rt",&(pbd_RuptGTAR->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptGTAR->n_NbRupture =1;    
	pbd_RuptGTAR->n_ActionLigne     = n_ActionLigneGTAR;
        pbd_RuptGTAR->n_ConditionRupture[0] = n_ConditionRuptureGTAR;
        pbd_RuptGTAR->n_ActionLast[0] = n_ActionLastGTAR;
        pbd_RuptGTAR->n_ActionFirst[0] = n_ActionFirstGTAR;

        pbd_RuptGTAR->c_Separ=SEPARATEUR;

	return OK ;
}

/*==============================================================================
objet :
        Test de rupture sur SSD_CF/ESB_CF/
                            CTR_NF/END_NT/SEC_NF/UWY_NF/UW_NT/
                            RETCTR_NF/RETEND_NT/RETSEC_NF/RTY_NF/RETUW_NT/
                            RETCUR_CF 

retour :
        0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
int n_ConditionRuptureGTAR(char ** tpsz_ReadBufferGTAR,
                           char ** tpsz_ReadBufferGTAR_Cur)
{

        if((strcmp(tpsz_ReadBufferGTAR[GT_SSD_CF],tpsz_ReadBufferGTAR_Cur[GT_SSD_CF]))!=0)
           return(1);

        if((strcmp(tpsz_ReadBufferGTAR[GT_ESB_CF],tpsz_ReadBufferGTAR_Cur[GT_ESB_CF]))!=0)
           return(1);

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

      return(0);
}

/*==============================================================================
objet :
        Fonction lancee en rupture derniere 
        pour le fichier perimetre

retour :
        OK --->
        ERR --->
==============================================================================*/
static int n_ActionLastGTAR(char ** tpsz_ReadBufferGTAR)
{    
       if ( Kb_Rappro == 1)
       {
          fprintf(Kp_FRAPP,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~%.3lf~~~~~~~~~~~~~\n", 
                               tpsz_ReadBufferGTAR[GT_SSD_CF],
                               tpsz_ReadBufferGTAR[GT_ESB_CF],
                               tpsz_ReadBufferGTAR[GT_CTR_NF],
                               tpsz_ReadBufferGTAR[GT_END_NT],
                               tpsz_ReadBufferGTAR[GT_SEC_NF],
                               tpsz_ReadBufferGTAR[GT_UWY_NF],
                               tpsz_ReadBufferGTAR[GT_UW_NT],
                               tpsz_ReadBufferGTAR[GT_RETCTR_NF],
                               tpsz_ReadBufferGTAR[GT_RETEND_NT],
                               tpsz_ReadBufferGTAR[GT_RETSEC_NF],
                               tpsz_ReadBufferGTAR[GT_RTY_NF],
                               tpsz_ReadBufferGTAR[GT_RETUW_NT],
                               tpsz_ReadBufferGTAR[GT_RETCUR_CF],
                               Kd_Rc);
       }
       return OK;

}

/*==============================================================================
objet :
        Fonction lancee en rupture premiere

retour :
        OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirstGTAR(char ** tpsz_ReadBufferGTAR)
{    
     /* Initialisation du resultat comptable */
     Kd_Rc=0.;

     /* Initialisation du flag qui indique si au moins un des postes */
     /* de la cle de rupture courante est rapprochable */
     Kb_Rappro = 0;

   return OK;
}
                   
/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement                          */
/* Si le poste est rapprochable, le montant retro de la ligne               */
/* est ajoute au resultat comptable courant.                                */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigneGTAR(char *tpsz_ReadBufferGTAR[])
{
        if (b_PosteRappro(tpsz_ReadBufferGTAR[GT_TRNCOD_CF],Kp_Dettrs) == TRUE) 
        {
           Kb_Rappro = 1;
           Kd_Rc = Kd_Rc + atof(tpsz_ReadBufferGTAR[GT_RETAMT_M]);
        }

      return OK;  
}







