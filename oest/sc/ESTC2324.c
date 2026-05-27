/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Rapprochement (job ESID2531.cmd)
nom du source                 : ESTC2324.c
revision                      : $Revision:   1.0  $
date de creation              : 13/10/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Rapprochement : ECARTS DE VERSEMENT, DE PLACEMENT ET DE CHANGE SUR 
        REJETS D'ESTIMATIONS/D'ACTUALISATIONS ET DE SERVICE

        Ce programme calcule la difference ligne a ligne entre les montants
        du fichier d'entree; 

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
#define M1_M 13
#define M2_M 14

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_Init(T_RUPTURE_VAR  *);
static int n_ActionLigne(char **);
static char * sz_PrintFormat(char *);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_Out;

static T_RUPTURE_VAR   Kbd_Rupt;       

char * Ksz_format;
double Kd_signe;   /* permet de controler le sens de la difference */
char MsgAno[50];

/*==============================================================================
objet :
   point d'entre du programme

retour :
   En cas de problme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

        /* recuperation du parametre d'entree du programme */
        /* qui indique dans quelle colonne doit etre ecrit */
        /* l'ecart calcule */
        Ksz_format=sz_PrintFormat(psz_GetCharArgv(1));

        if(strcmp(Ksz_format,"")==0)
        {
             sprintf(MsgAno,"INVALID INPUT PARAMETER : %s",psz_GetCharArgv(1));
             ExitPgm( ERR_XX , MsgAno );
        }

        if ( n_OpenFileAppl ("ESTC2324_O1","wt",&Kp_Out) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_Rupt  */
	if ( n_Init(&Kbd_Rupt)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier */
	if ( n_ProcessingRuptureVar(&Kbd_Rupt) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2324_O1",&Kp_Out)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2324_I1",&(Kbd_Rupt.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;

}


/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture

retour :
	0K ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_Init(T_RUPTURE_VAR  *pbd_Rupt)
{
	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2324_I1","rt",&(pbd_Rupt->pf_InputFil))==ERR)
		return ERR;

	pbd_Rupt->n_NbRupture =0;    
	pbd_Rupt->n_ActionLigne     = n_ActionLigne;

        pbd_Rupt->c_Separ=SEPARATEUR;

	return OK ;
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement                          */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigne(char * tpsz_ReadBuffer[])
{
        fprintf(Kp_Out,Ksz_format,tpsz_ReadBuffer[FRAPP_SSD_CF],
                                 tpsz_ReadBuffer[FRAPP_ESB_CF],
                                 tpsz_ReadBuffer[FRAPP_CTR_NF],
                                 tpsz_ReadBuffer[FRAPP_END_NT],
                                 tpsz_ReadBuffer[FRAPP_SEC_NF],
                                 tpsz_ReadBuffer[FRAPP_UWY_NF],
                                 tpsz_ReadBuffer[FRAPP_UW_NT],
                                 tpsz_ReadBuffer[FRAPP_RETCTR_NF],
                                 tpsz_ReadBuffer[FRAPP_RETEND_NT],
                                 tpsz_ReadBuffer[FRAPP_RETSEC_NF],
                                 tpsz_ReadBuffer[FRAPP_RTY_NF],
                                 tpsz_ReadBuffer[FRAPP_RETUW_NT],
                                 tpsz_ReadBuffer[FRAPP_RETCUR_CF],
                                 Kd_signe * (atof(tpsz_ReadBuffer[M1_M]) - atof(tpsz_ReadBuffer[M2_M])));
   
        return OK;  
}

char * sz_PrintFormat(char * sz_Col)
{
  if( strcmp(sz_Col,"AMT8_M") == 0 )
    {
       Kd_signe=-1.;
       return("%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~~~~~~%.3lf~~~~\n");
    }
 
  if( strcmp(sz_Col,"AMT9_M") == 0 )
   {
       Kd_signe=1.;
       return("%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~%.3lf~~~\n");
   }

  if( strcmp(sz_Col,"AMT10_M") == 0 )
    {
       Kd_signe=1.;
       return("%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~~%.3lf~~\n");
    }
       
    return "";
}
