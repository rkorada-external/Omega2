/*==============================================================================
Application name : ESTIMATES
Source name      : ESTC1055.c
Version
Creation date    : 2014/11/25
Author           : C. DESPRET
------------------------------------------------------------------------------
  Description : Compute acceptation ratio for GTAR contracts
________________
MODIFICATION    [
[000]  13/11/2014   C. DESPRET            :spot:26391 - Creation
[001]  07/11/2019   JYP - PERSEE : spira : bugfix division 0
[002]  27/01/2019   KBAGWE	: spira 79904 : EBS - TNR - Funds Held discrepancies
[003]  08/10/2024   HR	    : spira 111708 : FWH retro - RATECSII - Underlying assumed allocation
==============================================================================*/


/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>

/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1055.h"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC1055_C[150] = "__version__: ESTC1055.c version [001] 06/11/2019 bugfix division 0 ";




/*==============================================================================
Objet :    Point d'entree du programme
Parametre(s) :
    int argc    : Nombre d'arguments sur la ligne de commande;
    char **argv : parametres
Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
                // Initialisation des signaux
                InitSig ();

                if (n_BeginPgm(argc, argv) == ERR)                ExitPgm(ERR_XX, "");

       		printf("Running with %s \n", VERSION_ESTC1055_C);

                // Initialisation des variables de gestion de ruptures
                if (n_InitFGTAR(&Kbd_ruptFGTAR))            ExitPgm(ERR_XX, "");

                // Ouverture des fichiers binaires et des fichiers de sortie
                if (n_OpenFileAppl("ESTC1055_O1", "wt", &Kp_OutputFGTAR_REPARTITION) == ERR)
                                ExitPgm(ERR_XX, "");

                // Lancement du traitement du fichier Maitre
                if (n_ProcessingRuptureVar(&Kbd_ruptFGTAR) == ERR)
                                ExitPgm(ERR_XX, "");

                // Fermeture des fichiers ouverts
                if (n_CloseFileAppl("ESTC1055_I1", &(Kbd_ruptFGTAR.pf_InputFil)) == ERR)
                                ExitPgm(ERR_XX, "");
                if (n_CloseFileAppl("ESTC1055_O1", &Kp_OutputFGTAR_REPARTITION))
                                ExitPgm(ERR_XX, "");


                if (n_EndPgm() == ERR)  ExitPgm(ERR_XX, "");

                exit(OK);
}


/*==============================================================================
Objet :    Initialisation de la variable de gestion de rupture (Maitre)
Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR
Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitFGTAR(T_RUPTURE_VAR  *pbd_Rupt)
{
                memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

                if (n_OpenFileAppl("ESTC1055_I1","rt", &(pbd_Rupt->pf_InputFil)))
                                return ERR;

                pbd_Rupt->n_NbRupture           = 1;
                pbd_Rupt->n_ConditionRupture[0] = n_IsR1FGTAR;
                pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstFGTAR;
                pbd_Rupt->n_ActionLigne         = n_ActionLigneFGTAR;
                pbd_Rupt->n_ActionLast[0]       = n_ActionLastFGTAR;
                pbd_Rupt->c_Separ               = SEPARATOR;

                return OK;
}


/*==============================================================================
objet :     fonction de test de rupture de niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture

Rupture sur le contrat de retro pour le fichier GTAR
==============================================================================*/
int n_IsR1FGTAR(char **ptb_InRec, char **ptb_InRec_Cur)
{
                DEBUT_FCT("n_IsR1FGTAR");

                if (strcmp(ptb_InRec[GTSII_RETCTR_NF],ptb_InRec_Cur[GTSII_RETCTR_NF])!=0) RETURN_VAL(1);
                if (strcmp(ptb_InRec[GTSII_RETSEC_NF],ptb_InRec_Cur[GTSII_RETSEC_NF])!=0) RETURN_VAL(1);
                if (strcmp(ptb_InRec[GTSII_RTY_NF],   ptb_InRec_Cur[GTSII_RTY_NF])   !=0) RETURN_VAL(1);
                if (strcmp(ptb_InRec[GTSII_RETUW_NT], ptb_InRec_Cur[GTSII_RETUW_NT]) !=0) RETURN_VAL(1);
								if (strcmp(ptb_InRec[GTSII_ACMCUR_CF],ptb_InRec_Cur[GTSII_ACMCUR_CF])!=0) RETURN_VAL(1);
									
                RETURN_VAL (0);
}

//[001]
//==============================================================================
// Objet :    A chaque rupture première sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionFirstFGTAR(char **ptb_InRec_Cur)
{

  // Initialisation
  int i = 0;

  for(i=0 ;i<MAXSIZE ; i++)
  {								                								
			// Retro data
      memset(acceptLines[i].RETCTR_NF, 0, sizeof(acceptLines[i].RETCTR_NF));
      acceptLines[i].RETEND_NT = 0;
      acceptLines[i].RETSEC_NF = 0;
      acceptLines[i].RTY_NF = 0;
      acceptLines[i].RETUW_NT  = 0;
      acceptLines[i].PLC_NT  = 0;      
      memset(acceptLines[i].ACMCUR_CF, 0, sizeof(acceptLines[i].ACMCUR_CF));
      // Accept data
      memset(acceptLines[i].CTR_NF, 0, sizeof(acceptLines[i].CTR_NF));
      acceptLines[i].END_NT = 0;
      acceptLines[i].SEC_NF = 0;
      acceptLines[i].UWY_NF = 0;
      acceptLines[i].UW_NT  = 0;
			//
			acceptLines[i].AMT_M            = 0.0;
  }

	sumAmtAccept = 0.0;
  nbAcceptLines=0;

  return OK;
}


/*==============================================================================
Objet :    Fonction lancee pour chaque ligne du Maitre
Parametre(s) :     Pointeur sur la ligne courante
Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneFGTAR(char **ptb_InRec_Cur)
{

  //003 only 303
  if (strcmp(ptb_InRec_Cur[GTSII_ACMTRS_NT],"303")==0) {
  // Retro data (the key)
  strcpy(acceptLines[nbAcceptLines].RETCTR_NF, ptb_InRec_Cur[GTSII_RETCTR_NF]);
  acceptLines[nbAcceptLines].RETEND_NT = atoi(ptb_InRec_Cur[GTSII_RETEND_NT]);
  acceptLines[nbAcceptLines].RETSEC_NF = atoi(ptb_InRec_Cur[GTSII_RETSEC_NF]);
  acceptLines[nbAcceptLines].RTY_NF    = atoi(ptb_InRec_Cur[GTSII_RTY_NF]);
  acceptLines[nbAcceptLines].RETUW_NT  = atoi(ptb_InRec_Cur[GTSII_RETUW_NT]);
  acceptLines[nbAcceptLines].PLC_NT    = atoi(ptb_InRec_Cur[GTSII_PLC_NT]);                
	strcpy(acceptLines[nbAcceptLines].ACMCUR_CF, ptb_InRec_Cur[GTSII_ACMCUR_CF]);
	
  // Accept data
  strcpy(acceptLines[nbAcceptLines].CTR_NF, ptb_InRec_Cur[GTSII_CTR_NF]);
  acceptLines[nbAcceptLines].END_NT = atoi(ptb_InRec_Cur[GTSII_END_NT]);
  acceptLines[nbAcceptLines].SEC_NF = atoi(ptb_InRec_Cur[GTSII_SEC_NF]);
  acceptLines[nbAcceptLines].UWY_NF = atoi(ptb_InRec_Cur[GTSII_UWY_NF]);
  acceptLines[nbAcceptLines].UW_NT  = atoi(ptb_InRec_Cur[GTSII_UW_NT]);               
  
  // Le montant : attention en double et pas en string
  acceptLines[nbAcceptLines].AMT_M = atof(ptb_InRec_Cur[GTSII_ACMAMT_MC]);  
  
  // cumuls
  sumAmtAccept += acceptLines[nbAcceptLines].AMT_M;
	nbAcceptLines ++;
  }
	
  return OK;
}


//[001]
//==============================================================================
// Objet :    En rupture Dernière sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionLastFGTAR(char **ptb_InRec_Cur)
{

	int i;
  double acceptRatio = 0.0; 
  double sumRatio = 0.0;
  double precision = 100000000.0;
  	
	for(i=0;i<nbAcceptLines;i++)
	{					

		if (i == nbAcceptLines-1)
		{
			// As sum of ratio has to be equal to 1
			acceptRatio = 1.0 - (round(sumRatio * precision) / precision);	
											
		}
		else
		{
			// Montant au prorata
			// Attention a la division par 0
			if (fabs(sumAmtAccept) > 0.00001 )
			{
				acceptRatio = acceptLines[i].AMT_M / sumAmtAccept;								
				acceptRatio = round(acceptRatio * precision) / precision;								
				sumRatio += acceptRatio; 
			}
		}
	
		
		fprintf(Kp_OutputFGTAR_REPARTITION, "%s~%s~%s~%s~%s~%d~%d~%d~%d~0.0~0.0~0.0~%-.8lf~~~~~%s\n",
		ptb_InRec_Cur[GTSII_RETCTR_NF],	
		ptb_InRec_Cur[GTSII_RTY_NF],
		ptb_InRec_Cur[GTSII_RETSEC_NF],
		ptb_InRec_Cur[GTSII_SSD_CF],				
		acceptLines[i].CTR_NF,		
		acceptLines[i].UWY_NF,
		acceptLines[i].UW_NT,
		acceptLines[i].END_NT,
		acceptLines[i].SEC_NF,
		acceptRatio,
		acceptLines[i].ACMCUR_CF			/*MOD002*/
		);
		
	}


	return OK;
}




