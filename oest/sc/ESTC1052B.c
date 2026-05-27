/*==============================================================================
 Nom de l'application          : RETRO
 Nom du source                 : ESTC1052B.c
 Revision                      :
 Date de creation              : 11/08/2022
 Auteur                        : HR
 References des specifications : copie du ESTC1052 pour fichier FTECLEDA
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :

------------------------------------------------------------------------------
 Historique des modifications :
[01] 11/08/2022 HR : SPIRA 105449 INI RTO Missing (RA View)
[02] 29/08/2022 MZM : SPIRA 105449 INI RTO Missing (RA View) Replace ESTC1052 par ESTC1052B 
[03] 17/03/2023 MZM :Spira:107134 Incorrect allocation of retro ITD amounts between placements :Variabilisation FPLATXCUM/ALL
[04] 30/05/2023 MZM :Spira:109906 I17 - Regression on retro P IFRS4 cancel : Correction Ventilation RETAMT_M
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>

/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1052B.h"

static char VERSION_ESTC1052B_C[150] = "__version__: ESTC1052B.c version [04] 30/05/2023 : Correction Ventilation RETAMT_M\n";

typedef struct {
  char            RETCTR_NF[10];
  int             RETSEC_NF;
  int             RTY_NF;
  char            PLC_NT[10];
  double          RETSIGSHA_TOT_R;
  double          RETSIGSHA_INT_R;
  double          RETSIGSHA_QOT_R;
  char            RTO_NF[10];
  int             NBLIGNES;
} T_FPLATXCUM;

enum { MAX_PLATXCUM=10000 };

T_FPLATXCUM Ktb_platxcum[MAX_PLATXCUM];

int Kn_nbplatxcum=0;

int n_RecherchePlacement    (char **);
int n_IsR1FPLATXCUM         (char **, char **);
int n_ActionFirstFPLATXCUM  (char **);
int n_ActionLastFPLATXCUM   (char **);

char  Ksz_TypeFPLATCUM[5] ;       //  FICHIER FPLATCUM CUM ou FPLATCUMALL ALL


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

	printf("Running with %s ;\n", VERSION_ESTC1052B_C);

  if (n_BeginPgm(argc, argv) == ERR)                  ExitPgm(ERR_XX, "");
  	
  strcpy(Ksz_TypeFPLATCUM, psz_GetCharArgv(1));   // Fichier Placement CUM ou CUMALL ; par défaut c'est le FPLATCUM
  
  printf(" Type fichier  Ksz_TypeFPLATCUM = [ FPLATXCUM%s ] \n", Ksz_TypeFPLATCUM) ;


  // Initialisation des variables de gestion de ruptures
  if (n_InitFPLATXCUM(&Kbd_ruptFPLATXCUM))            ExitPgm(ERR_XX, "");
  if (n_InitFACCTRTGT(&Kbd_ruptFACCTRTGT))            ExitPgm(ERR_XX, "");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC1052B_O1", "wt", &Kp_OutputFileGT) == ERR)               ExitPgm(ERR_XX, "");

  // Lancement du traitement du fichier Maitre
  if (n_ProcessingRuptureVar(&Kbd_ruptFPLATXCUM) == ERR)                          ExitPgm(ERR_XX, "");

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC1052B_I1", &(Kbd_ruptFPLATXCUM.pf_InputFil)) == ERR)    ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC1052B_I2", &(Kbd_ruptFACCTRTGT.pf_InputFil)) == ERR)    ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC1052B_O1", &Kp_OutputFileGT))                           ExitPgm(ERR_XX, "");

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
int n_InitFPLATXCUM(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC1052B_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;                                  //[001] 0;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1FPLATXCUM;          //[001]
  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstFPLATXCUM;   //[001]
  pbd_Rupt->n_ActionLigne         = n_ActionLigneFPLATXCUM;
  pbd_Rupt->n_ActionLast[0]       = n_ActionLastFPLATXCUM;    //[001]
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
objet :     fonction de test de rupture de niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1FPLATXCUM(char **ptb_InRecChild, char **ptb_InRecChild_Cur)
{
  DEBUT_FCT("n_IsR1Prev");

  if (strcmp(ptb_InRecChild[PLA_RETCTR_NF],ptb_InRecChild_Cur[PLA_RETCTR_NF])!=0)       RETURN_VAL(1);
  if (strcmp(ptb_InRecChild[PLA_RTY_NF],ptb_InRecChild_Cur[PLA_RTY_NF])!=0)             RETURN_VAL(1);
  if (strcmp(ptb_InRecChild[PLA_RETSEC_NF],ptb_InRecChild_Cur[PLA_RETSEC_NF])!=0)       RETURN_VAL(1);

  RETURN_VAL (0);
}


//[001]
//==============================================================================
// Objet :    A chaque rupture première sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionFirstFPLATXCUM(char **ptb_InRecChild_Cur)
{
  // Initialisation
  memset(Ktb_platxcum,0,MAX_PLATXCUM*sizeof(T_FPLATXCUM));
  Kn_nbplatxcum=0;
  return OK;
}

/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneFPLATXCUM(char **ptb_InRecChild_Cur)
{
  strcpy(Ktb_platxcum[Kn_nbplatxcum].RETCTR_NF, ptb_InRecChild_Cur[PLA_RETCTR_NF]);
  Ktb_platxcum[Kn_nbplatxcum].RETSEC_NF = atoi(ptb_InRecChild_Cur[PLA_RETSEC_NF]);
  Ktb_platxcum[Kn_nbplatxcum].RTY_NF = atoi(ptb_InRecChild_Cur[PLA_RTY_NF]);
  strcpy(Ktb_platxcum[Kn_nbplatxcum].PLC_NT, ptb_InRecChild_Cur[PLA_PLC_NT]);
  Ktb_platxcum[Kn_nbplatxcum].RETSIGSHA_TOT_R = atof(ptb_InRecChild_Cur[PLA_RETSIGSHA_TOT_R]);
  Ktb_platxcum[Kn_nbplatxcum].RETSIGSHA_INT_R = atof(ptb_InRecChild_Cur[PLA_RETSIGSHA_INT_R]);
  Ktb_platxcum[Kn_nbplatxcum].RETSIGSHA_QOT_R = atof(ptb_InRecChild_Cur[PLA_RETSIGSHA_QOT_R]);
  strcpy(Ktb_platxcum[Kn_nbplatxcum].RTO_NF, ptb_InRecChild_Cur[PLA_RTO_NF]);
  Ktb_platxcum[Kn_nbplatxcum].NBLIGNES = atoi(ptb_InRecChild_Cur[PLA_NBLIGNES]);
  Kn_nbplatxcum++;

  return OK;
}

//[001]
//==============================================================================
// Objet :    En rupture Dernière sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionLastFPLATXCUM(char **ptb_InRecChild_Cur)
{
  n_ProcessingRuptureSyncVar(&Kbd_ruptFACCTRTGT, ptb_InRecChild_Cur);
  return OK;
}

/*==============================================================================
 Objet :    Initialisation de la variable de gestion de synchronisation (Esclave)
 Parametre(s) : Pointeur sur une structure T_RUPTURE_SYNC_VAR
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_InitFACCTRTGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC1052B_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncFACCTRTGT;
  pbd_Rupt->n_FilsSansPere   = n_ActionFsPFACCTRTGT;
  pbd_Rupt->n_ActionLigne    = n_ActionLigneSyncFACCTRTGT;
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :    Fonction de test de synchronisation avec la Maitre
 Parametre(s) :
   Pointeur sur la ligne du maitre
   Pointeur sur la ligne de l'esclave
 Retour :
   0 --> Pas de synchro
   1--> Situation de synchro
==============================================================================*/
int n_ConditionSyncFACCTRTGT(char **ptb_InRecChildPLATXCUM, char **ptb_InRecChild)
{
  int ret;

  if ((ret = strcmp(ptb_InRecChildPLATXCUM[PLA_RETCTR_NF],       ptb_InRecChild[FTTECLEDA_RETCTR_NF]))  != 0)  return(ret);
  if ((ret = strcmp(ptb_InRecChildPLATXCUM[PLA_RTY_NF],          ptb_InRecChild[FTTECLEDA_RTY_NF]))  != 0)  return(ret);
  if ((ret = (atoi(ptb_InRecChildPLATXCUM[PLA_RETSEC_NF]) - atoi(ptb_InRecChild[FTTECLEDA_RETSEC_NF]))) != 0)  return(ret);
  //[001] et Si le placement existe dans le fichier des placements
  if (( ret = n_RecherchePlacement(ptb_InRecChild) !=0)) return(ret);

  return 0;
}

/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne synchronisee avec le Maitre
 Parametre(s) :
   Pointeur sur la ligne courante
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncFACCTRTGT(char **ptb_InRecChildPLATXCUM, char **ptb_InRecChild)
{
  char Ksz_RETINTAMT_M[25];
  double d_RETINTAMT_M = 0;
  double d_RETAMT_M = 0;
  double d_AMT_M = 0;
  char Ksz_AMT_M[25];
  char Ksz_RETAMT_M[25];  
  int i=0;
  int j=0;
  //int l=0;
  int b_RETMIXTE = -1 ;
  
  int b_Liste = -1 ;

  double d_RETSIGSHA_TOT_R = Ktb_platxcum[0].RETSIGSHA_TOT_R ;    // Total Ration PLC Externe
  double d_RETSIGSHA_INT_R = 0 ;    // Cumul des ratio des PLC Interne 
  double d_RETSIGSHA_TOT_Ext = 0 ;  // Variable de calcul intermediaire des Part Externe 
  double d_RETSIGSHA_INT_R_V2 = 0 ;  // Variable de calcul intermediaire des Part Interne  

   //[03] Recherche si RETRO Mixte
   for(i=1;i<Kn_nbplatxcum;i++)
   { 
   	d_RETSIGSHA_INT_R += Ktb_platxcum[i].RETSIGSHA_INT_R ;
   } 
   
   if ( (d_RETSIGSHA_TOT_R != d_RETSIGSHA_INT_R ) && (d_RETSIGSHA_INT_R != 0) ) //[004]
   { 
   	  b_RETMIXTE = 1 ;
   	  
   	  //printf(" CAS MIXTE : RETCTR_NF;RETSEC_NF;RETRTY_NF : %s~%d~%d ; \n", ptb_InRecChildPLATXCUM[PLA_RETCTR_NF], atoi(ptb_InRecChildPLATXCUM[PLA_RETSEC_NF]), atoi(ptb_InRecChildPLATXCUM[PLA_RTY_NF]) );
   }
   
   if (
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110014",7)  || !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110015",7)  ||
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112014",7)  || !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112015",7)  ||
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112019",7)  || !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112016",7)  ||
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149431",7)  || !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2120071",7)  || 
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112128",7)  || 
						                                           
						 // et leur reclass                         
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110018",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110050",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110051",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110019",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112029",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112039",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149439",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2120079",7)  || 
						                                           
						 //DAC I17 :                                
						                                           
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2143060",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2143161",7)  || 
						 //  LC assumed  (LCC RPO INI) :            
						                                           
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149500",7)  || 
						 // des CSM/LC booking :                    
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149426",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149427",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149428",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149429",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149510",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149531",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149550",7)  || 
						                                           
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2449410",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2449450",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149558",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149559",7)  || 
						                                           
						 // o	AoC.9 (LCC RPO STD) :                 
						                                           
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149491",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2142791",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112491",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2149492",7)  ||  
						!strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2142792",7)  ||  !strncmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112492",7)  
	
	
					 ) 
				{ 
				  b_Liste = 1 ;	
				  
				//printf("UN CAS  ptb_InRecChild[FTTECLEDA_TRNCOD_CF] = %s ; d_AMT_M = %f ; d_RETAMT_M = %f ; d_RETSIGSHA_INT_R_V2 = %f ; d_RETSIGSHA_TOT_Ext =%f ; \n", ptb_InRecChild[FTTECLEDA_TRNCOD_CF],  d_AMT_M, d_RETAMT_M, d_RETSIGSHA_INT_R_V2, d_RETSIGSHA_TOT_Ext) ;                                                          
				}
				else
				{ 
				  b_Liste = 0 ;	
				  
				 //printf("UN CAS NON  ptb_InRecChild[FTTECLEDA_TRNCOD_CF] = %s ; d_AMT_M = %f ; d_RETAMT_M = %f ; d_RETSIGSHA_INT_R_V2 = %f ; d_RETSIGSHA_TOT_Ext =%f ; \n", ptb_InRecChild[FTTECLEDA_TRNCOD_CF],  d_AMT_M, d_RETAMT_M, d_RETSIGSHA_INT_R_V2, d_RETSIGSHA_TOT_Ext) ;                                                          
				}					

  //[001]
  if ( atoi(ptb_InRecChild[FTTECLEDA_PLC_NT]) == 0)
  {
    // Un seul placement interne
    if ( atoi(ptb_InRecChildPLATXCUM[PLA_NBLIGNES]) <= 2     &&
         atof(ptb_InRecChildPLATXCUM[PLA_RETSIGSHA_QOT_R]) == 1.0 )      //[001]
    {
      sprintf(Ksz_RETINTAMT_M, "%-.3lf",atof(ptb_InRecChild[FTTECLEDA_RETAMT_M]) * atof(ptb_InRecChildPLATXCUM[PLA_RETSIGSHA_QOT_R]) );
      ptb_InRecChild[FTTECLEDA_RETINTAMT_M]=Ksz_RETINTAMT_M;
      ptb_InRecChild[FTTECLEDA_PLC_NT]=Ktb_platxcum[1].PLC_NT;
      ptb_InRecChild[FTTECLEDA_RTO_NF]=Ktb_platxcum[1].RTO_NF;

      if ( fabs(atof(ptb_InRecChild[FTTECLEDA_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETINTAMT_M])) > 0.01 )
        n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);
    }
    else //[003] 
    {
    	
      d_RETAMT_M=(double)atof(ptb_InRecChild[FTTECLEDA_RETAMT_M]);
      d_AMT_M=(double)atof(ptb_InRecChild[FTTECLEDA_AMT_M]);
    	
     // Recherche si RETRO Mixte
       	
 
      d_RETSIGSHA_INT_R_V2 = 0 ; 	
    	
    	if ( ( b_RETMIXTE == 1) && (strcmp(Ksz_TypeFPLATCUM, "ALL") == 0) && ( b_Liste != 1 )  ) //  if (b_RETMIXTE == 1) // Calcul Ventilation avec fichier FPLATXCUMALL et PAs dans Liste 
    	{ 
    		//if (strcmp(ptb_InRecChild[FTTECLEDA_RETCTR_NF], "RP0002514") == 0 && atoi(ptb_InRecChild[FTTECLEDA_RTY_NF]) == 2022 && strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110000I") == 0 )
    	  //printf("VERIF d_AMT_M = %f ; d_RETAMT_M = %f ; d_RETSIGSHA_INT_R_V2 = %f ; d_RETSIGSHA_TOT_Ext =%f ; \n", d_AMT_M, d_RETAMT_M, d_RETSIGSHA_INT_R_V2, d_RETSIGSHA_TOT_Ext) ;
    		
    		for(i=1;i<Kn_nbplatxcum;i++)
      	{ 
      		d_RETSIGSHA_INT_R_V2 += Ktb_platxcum[i].RETSIGSHA_INT_R ;
      	}
      	
      	d_RETSIGSHA_TOT_Ext = Ktb_platxcum[0].RETSIGSHA_TOT_R - d_RETSIGSHA_INT_R_V2 ;
    		
      	for(i=0;i<Kn_nbplatxcum;i++)
      	{  
      			
    				if (d_RETSIGSHA_TOT_Ext != 0) 
    				{ 				
    						sprintf(Ksz_AMT_M, "%-.3lf", d_AMT_M * ( Ktb_platxcum[i].RETSIGSHA_TOT_R*Ktb_platxcum[i].RETSIGSHA_QOT_R )/d_RETSIGSHA_TOT_Ext);  
    						sprintf(Ksz_RETAMT_M, "%-.3lf", d_RETAMT_M * ( Ktb_platxcum[i].RETSIGSHA_TOT_R*Ktb_platxcum[i].RETSIGSHA_QOT_R )/d_RETSIGSHA_TOT_Ext);  //[00]
    				}
    				else
    				{ 
    					 sprintf(Ksz_AMT_M, "%-.3lf", d_AMT_M * ( 1.00 - Ktb_platxcum[i].RETSIGSHA_QOT_R )); // Ne devrait pas arriver
    					 sprintf(Ksz_RETAMT_M, "%-.3lf", d_RETAMT_M * ( 1.00 - Ktb_platxcum[i].RETSIGSHA_QOT_R )); // Ne devrait pas arriver  [004]  					 
    				}
    					 
       			if ( Ktb_platxcum[i].RETSIGSHA_INT_R != 0 ) ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = Ksz_AMT_M;        			 
        		
        		 if(i>0 && (Ktb_platxcum[i].RETSIGSHA_INT_R == 0))
        		{
        		
        		  //sprintf(Ksz_AMT_M, "%-.3lf", d_AMT_M * Ktb_platxcum[i].RETSIGSHA_QOT_R);     
        		  
        		  ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = "0.000"; 
        		          
        		  ptb_InRecChild[FTTECLEDA_AMT_M] = Ksz_AMT_M;  
        		  ptb_InRecChild[FTTECLEDA_RETAMT_M] = Ksz_RETAMT_M; //[004]                                                     
        		  ptb_InRecChild[FTTECLEDA_PLC_NT]=Ktb_platxcum[i].PLC_NT;
        		  ptb_InRecChild[FTTECLEDA_RTO_NF]=Ktb_platxcum[i].RTO_NF;
        		  
        		  if ( fabs(atof(ptb_InRecChild[FTTECLEDA_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETAMT_M])) > 0.01  )
        		    n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);
        		}
 
    				
    		}
    	}    	
    	
    	else // Calcul des montant de Retro Externe Interne Classique
    		
    	if ( ( ( b_RETMIXTE == 1) && (strcmp(Ksz_TypeFPLATCUM, "ALL") == 0) && ( b_Liste == 1 )  )  || ( b_RETMIXTE != 1)  ) // //[004]
    	{ 
      //memorisation montant avant écrasement.
      d_RETAMT_M=(double)atof(ptb_InRecChild[FTTECLEDA_RETAMT_M]);
      d_AMT_M=(double)atof(ptb_InRecChild[FTTECLEDA_AMT_M]);
      
    		//if (strcmp(ptb_InRecChild[FTTECLEDA_RETCTR_NF], "RP0002514") == 0 && atoi(ptb_InRecChild[FTTECLEDA_RTY_NF]) == 2022 && strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110000I") == 0 )
    	  // printf("VERIF DANS Liste d_AMT_M = %f ; d_RETAMT_M = %f ; d_RETSIGSHA_INT_R_V2 = %f ; d_RETSIGSHA_TOT_Ext =%f ; \n", d_AMT_M, d_RETAMT_M, d_RETSIGSHA_INT_R_V2, d_RETSIGSHA_TOT_Ext) ;
    		      

      //[001] Ici, on va boucler sur les placements du contrat/sec/UWY et générer une ligne pour chaque
      for(i=0;i<Kn_nbplatxcum;i++)
      {
        //montant de retro interne
        d_RETINTAMT_M = d_RETAMT_M * Ktb_platxcum[i].RETSIGSHA_QOT_R;

        if(i==0)
        {
          // Ecriture  du solde pour la retro externe pure
          // Montant de retro global - montant de retro interne
          sprintf(Ksz_RETINTAMT_M, "%-.3lf", d_RETAMT_M - d_RETINTAMT_M );
          ptb_InRecChild[FTTECLEDA_RETAMT_M] = Ksz_RETINTAMT_M;

          sprintf(Ksz_AMT_M, "%-.3lf", d_AMT_M * ( 1.00 - Ktb_platxcum[i].RETSIGSHA_QOT_R ));     //[001]
          ptb_InRecChild[FTTECLEDA_AMT_M] = Ksz_AMT_M;                                            //[001]

          ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = "0.000";
          ptb_InRecChild[FTTECLEDA_PLC_NT] = "";     // placement vide
          ptb_InRecChild[FTTECLEDA_RTO_NF] = "";     // rto_nf vide

          if ( fabs(atof(ptb_InRecChild[FTTECLEDA_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETINTAMT_M])) > 0.01 )
            n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);

        }
        else
        {
          sprintf(Ksz_RETINTAMT_M, "%-.3lf", d_RETINTAMT_M );
          ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = Ksz_RETINTAMT_M;
          ptb_InRecChild[FTTECLEDA_RETAMT_M]    = ptb_InRecChild[FTTECLEDA_RETINTAMT_M];

          sprintf(Ksz_AMT_M, "%-.3lf", d_AMT_M * Ktb_platxcum[i].RETSIGSHA_QOT_R);                //[001]
          ptb_InRecChild[FTTECLEDA_AMT_M] = Ksz_AMT_M;                                               //[001]
          ptb_InRecChild[FTTECLEDA_PLC_NT]=Ktb_platxcum[i].PLC_NT;
          ptb_InRecChild[FTTECLEDA_RTO_NF]=Ktb_platxcum[i].RTO_NF;

          if ( Ktb_platxcum[i].RETSIGSHA_INT_R == 0 ) ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = "0.000";  // [001]
          if ( fabs(atof(ptb_InRecChild[FTTECLEDA_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETINTAMT_M])) > 0.01 )
            n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);
        }
      }
    }
    else //
    	if ( ( b_RETMIXTE == 1) && (strcmp(Ksz_TypeFPLATCUM, "CUM") == 0)   )
    	{	
    		    if ( fabs(atof(ptb_InRecChild[FTTECLEDA_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETINTAMT_M])) > 0.01 )
      				n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);          
      }

    }
  }
  else  // Traitement classique
  {
    ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = "0.000" ;
    ptb_InRecChild[FTTECLEDA_RTO_NF]=Ktb_platxcum[0].RTO_NF;                   //[001]
    for(j=0;j<Kn_nbplatxcum;j++)                                      //[002]
    {
      if ( strcmp(ptb_InRecChild[FTTECLEDA_PLC_NT], Ktb_platxcum[j].PLC_NT) == 0 )
      {
        ptb_InRecChild[FTTECLEDA_RTO_NF]=Ktb_platxcum[j].RTO_NF;
        ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = ptb_InRecChild[FTTECLEDA_RETAMT_M] ;
      }
    }
    if ( Ktb_platxcum[j].RETSIGSHA_INT_R == 0 ) ptb_InRecChild[FTTECLEDA_RETINTAMT_M] = "0.000";  // [001]

    if ( fabs(atof(ptb_InRecChild[FTTECLEDA_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETINTAMT_M])) > 0.01 )
      n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);           //[001]
  }
  return OK;
}



//[001]
int n_RecherchePlacement(char **ptb_InRecChild)
{
  int trouve = -1;
  int i=0;

  for(i=0;i<Kn_nbplatxcum;i++)
  {
      if ( strcmp(ptb_InRecChild[FTTECLEDA_RETCTR_NF] , Ktb_platxcum[i].RETCTR_NF)==0   &&
           atoi(ptb_InRecChild[FTTECLEDA_RTY_NF]) == Ktb_platxcum[i].RTY_NF          &&
           atoi(ptb_InRecChild[FTTECLEDA_RETSEC_NF]) == Ktb_platxcum[i].RETSEC_NF       &&
           atoi(ptb_InRecChild[FTTECLEDA_PLC_NT])    == atoi(Ktb_platxcum[i].PLC_NT)    )
      {
        trouve=0;
        break;
    }
  }
//  return trouve;
  return 0;
}

/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne du fils non synchronisee avec le pere
 Parametre(s) :
   Pointeur sur la ligne courante (Esclave)
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionFsPFACCTRTGT(char **ptb_InRecChild)
{
  ptb_InRecChild[FTTECLEDA_RETINTAMT_M]= "0.000";
  if ( fabs(atof(ptb_InRecChild[FTTECLEDA_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[FTTECLEDA_RETINTAMT_M])) > 0.01 )
    n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);
  return OK;
}
