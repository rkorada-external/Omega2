/*==============================================================================
nom de l'application          : Creation des complements previsionnels
nom du source                 : ESTCLiberation.c
revision                      : $Revision: 1.25 $
date de creation              : 12/03/2014
auteur                        : A. Ben Jeddou
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Creation du fichier des Liberations.


------------------------------------------------------------------------------
[001] 20/06/2014 JBG :spot:25773 - Modify DETTRNCOD control
[002] 27/06/2014 JBG :spot:25773 - Amounts format modified and calls suppress
[003] 09/07/2014 ABJ :spot:25773 Modification of init_SubTrsAssoLigne()
[004] 10/07/2014 ABJ :spot:25773  correction du type du montant ( double au lieu de float)
[005] 21/07/2014 ABJ :spot:25773  Modification du DETRNCOD et Exercice lorsqu on a une constite sans liberation.
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


FILE    *Kp_PrevFile;           /* pointeur sur les previsions */
FILE    *Kp_LibFile;            /* pointeur sur les Liberations */
FILE    *Kp_OutLibFile;      /* pointeur sur les complements pour les traites cribles */
FILE    *Kp_SubTRSFile;
FILE    *Kp_SubTRSAssoFile;          /* pointeur sur les pilotages */

T_RUPTURE_VAR           bd_RuptPrev;    /* gestion rupture sur pilotage */
T_RUPTURE_SYNC_VAR      bd_RuptLib;     /* gestion rupture sur prev */

T_SUBTRS SubtrsLigne;
T_SUBTRSASSO SubTrsAssoLigne;
int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePrev(char **pbd_InRec_Cur);
int n_IsRPrev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptb_InRec_Cur);


int n_InitLib(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncLib (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneLib(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionPereSansFils(char **ptb_InRec);
int n_ActionFilsSansPere(char **ptb_InRec);

T_RUPTURE_SYNC_VAR bd_RuptPerim; /* gestion synchro perimetre-previsions */


int n_InitPerim (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePerim  (char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPerim(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_IsR1PrevisionEx(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrevisionEx(char **ptb_InRec_Cur);

void init_SubTrsAssoLigne();

char    Ksz_DateJour[11];           // Date de traitement
int  Annee_courant;
int  Acy_min;
char DETTRNCOD[6]="";
int exercice;
int     Kn_TypeComptable=0;
/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    /* Initialisation des signaux */
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )
        ExitPgm ( ERR_XX , "" );


    
       /* Ouverture des fichiers en sortie */
    if ( n_OpenFileAppl ("ESTC2165_O","wt",&Kp_OutLibFile) == ERR )
        ExitPgm ( ERR_XX , "" );
    
    if (n_OpenFileAppl ("ESTC2165_I3","rb",&Kp_SubTRSFile) == ERR )
                ExitPgm ( ERR_XX , "" );
     n_ChargerTsubTRS(Kp_SubTRSFile);
    
     if ( n_OpenFileAppl ("ESTC2165_I4","rb",&Kp_SubTRSAssoFile) == ERR )
                ExitPgm ( ERR_XX , "" );  
    n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile);  
    
   
     strcpy(Ksz_DateJour,  psz_GetCharArgv(1));   
     Annee_courant=n_GetIntArgv(2); 
      Acy_min= n_GetIntArgv(3); 
    /* Initialisation de la varible bd_RuptPrev */
    if ( n_InitPrev(&bd_RuptPrev) )
        ExitPgm ( ERR_XX , "" );
          /* Initialisation de la varible bd_RuptPerim */
    if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptMvt */
    if ( n_InitLib(&bd_RuptLib) )
        ExitPgm ( ERR_XX , "" );

   
    
        /* Lancement du traitement du fichier */
    if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Fermeture fichier */
    if (n_CloseFileAppl ("ESTC2165_I1",&(bd_RuptPrev.pf_InputFil)) == ERR)
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2165_I2",&(bd_RuptLib.pf_InputFil)) == ERR)
        ExitPgm ( ERR_XX , "" );

     if (n_CloseFileAppl ("ESTC2165_I3",&Kp_SubTRSFile) == ERR)
        ExitPgm ( ERR_XX , "" );
        
    if (n_CloseFileAppl ("ESTC2165_I4",&Kp_SubTRSAssoFile) == ERR)
        ExitPgm ( ERR_XX , "" );
        
     if (n_CloseFileAppl ("ESTC2165_I5",&(bd_RuptPerim.pf_InputFil)))
                ExitPgm ( ERR_XX , "" ); 
   
    
    if (n_CloseFileAppl ("ESTC2165_O",&Kp_OutLibFile) == ERR)
        ExitPgm ( ERR_XX , "" );

   

    if ( n_EndPgm () == ERR )
        ExitPgm ( ERR_XX , "" );

  exit(0);
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :    0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{

    DEBUT_FCT("n_InitPrev");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl("ESTC2165_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR )
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 2 ;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1PrevisionEx;
    pbd_Rupt->n_ConditionRupture[1] = n_IsRPrev;
    pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrevisionEx;
    pbd_Rupt->n_ActionLigne = n_ActionLignePrev ;
       

    pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave 
retour :    OK
==============================================================================*/
int n_InitLib(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitLib");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier esclave */
    n_OpenFileAppl ("ESTC2165_I2","rt",&(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 0;

    pbd_Rupt->ConditionEndSync      = n_ConditionSyncLib ;
    pbd_Rupt->n_ActionLigne         = n_ActionLigneLib ;
    pbd_Rupt->n_PereSansFils        = n_ActionPereSansFils;
    pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPere;

    pbd_Rupt->c_Separ               = '~' ;

  RETURN_VAL (OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave Perim

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl("ESTC2165_I5","rt",&(pbd_Rupt->pf_InputFil)) == ERR )
          RETURN_VAL (ERR);
        
        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPerim ;
        /* fonction d'actions si le perimetre ne participe pas */
        pbd_Rupt->n_PereSansFils      = n_ActionPereSansFils;
        /* fonction d'actions si pas de lignes dans les prévisions */
        pbd_Rupt->n_FilsSansPere      = n_ActionFilsSansPere;
        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLignePerim ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL (OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 2

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1PrevisionEx(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1PrevisionEx");

        /* Rupture seconde initialisee */
       
        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}
/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere sur exercice
==============================================================================*/
int n_ActionFirstRuptPrevisionEx ( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionFirstRuptPrevisionEx");
         n_ProcessingRuptureSyncVar (&bd_RuptPerim, ptb_InRec_Cur);

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwner > pbd_InRecChild
        < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPerim(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPerim");

        if( (ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],pbd_InRecChild[PER_CTR_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PRE_SEC_NF],pbd_InRecChild[PER_SEC_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PRE_UWY_NF],pbd_InRecChild[PER_UWY_NF])) != 0 )
                RETURN_VAL (ret);

        RETURN_VAL (0);
}

/*==============================================================================
objet : fonction de test de rupture niveau 1 sur
        Contrat/Section/Exercice/Annee de compte
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsRPrev(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsRPrev");

    if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF],ptb_InRec_Cur[PRE_DETTRNCOD_CF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_GAAP_NF],ptb_InRec_Cur[PRE_GAAP_NF])!=0)
        RETURN_VAL(1);    


  RETURN_VAL (0);
}


/*==============================================================================
objet :     fonction de test de synchro
retour :    0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
            > 0     ---> pbd_InRecOwne> > pbd_InRecChild
            < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncLib (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
  int ret;
  int reslt=0;
 
    

    DEBUT_FCT("n_ConditionSyncMvt");
    
   exercice = atoi(pbd_InRecOwner[PRE_UWY_NF]);
   exercice += i_LiberationExeP1( atoi(pbd_InRecOwner[PRE_ACMTRS_NT]) , atoi(pbd_InRecOwner[PRE_ACCADMTYP_CT]) );
  
     init_SubTrsAssoLigne();
    sprintf(DETTRNCOD,"%s",pbd_InRecOwner[PRE_DETTRNCOD_CF]);	
    DETTRNCOD[5]=0; 	 
    		 	 
        reslt=n_FindTsubTRSAsso(&SubTrsAssoLigne,1,1,DETTRNCOD);
    
       if (reslt!=(-1))
    	  {
    	   	
    	  sprintf(DETTRNCOD,"%s",SubTrsAssoLigne.DETTRNCOD2_CF);
    	  }
    	  else
    	   { 
    	 	 if (DETTRNCOD[2] != '9') DETTRNCOD[2]++;
    	 	 DETTRNCOD[5]=0; 	 
    	   	
    	   }		
 
    if( (ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],pbd_InRecChild[PRE_CTR_NF])) != 0 )
            RETURN_VAL (ret);
    if( (ret = strcmp(pbd_InRecOwner[PRE_SEC_NF],pbd_InRecChild[PRE_SEC_NF])) != 0 )
            RETURN_VAL (ret);
    if ((atoi(pbd_InRecOwner[PRE_ACY_NF])+1)!= atoi(pbd_InRecChild[PRE_ACY_NF]))
            RETURN_VAL (1);
            
    //Ajout de l exercice
    if (exercice != atoi(pbd_InRecChild[PRE_UWY_NF]))
 	         RETURN_VAL (1);
    
    //        
          
    if( (ret = strcmp(DETTRNCOD,pbd_InRecChild[PRE_DETTRNCOD_CF])) != 0 )
            RETURN_VAL (ret); 
    if( (ret = strcmp(pbd_InRecOwner[PRE_GAAP_NF],pbd_InRecChild[PRE_GAAP_NF])) != 0 )
            RETURN_VAL (ret);              

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePrev");
   

    memset(&SubtrsLigne,0,sizeof(T_SUBTRS)); 
    sprintf(DETTRNCOD,"%s","");
    exercice=0;
    n_FindTsubTRS(&SubtrsLigne,ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
    if (((SubtrsLigne.TRSTYPE_CT==3) || (SubtrsLigne.TRSTYPE_CT==4 )) && (ptb_InRec_Cur[PRE_ACMTRS_NT][3] == '3'))
       {            
       n_ProcessingRuptureSyncVar (&bd_RuptLib, ptb_InRec_Cur);
       }

  RETURN_VAL (0);
}



/*==============================================================================
objet : fonction lancee pour chaque ligne des previsions synchronisee
        avec les Liberations
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneLib(
        char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
        char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
	  char dACy[5];
    char dUwy[5];

	  char sz_Mnt[30];
	  int annee_compte;
    double montant;
    int j;

 
    char *psz_lignePRE[PRE_NBCOL+1],*psz_ligneLib[PRE_NBCOL+1];
   
		for (j=0;j<PRE_NBCOL;j++)
		{
		psz_lignePRE[j]=ptb_InRecOwner[j];
		psz_ligneLib[j]=ptb_InRecChild[j];
		}
		psz_lignePRE[PRE_NBCOL]=0;
		psz_ligneLib[PRE_NBCOL]=0;
		
		psz_lignePRE[PRE_BATCH_B]="1";
 	  psz_lignePRE[PRE_ADJCOD_CT]="0";
    psz_ligneLib[PRE_ADJCOD_CT]="0";
		
		annee_compte= atoi(psz_lignePRE[PRE_ACY_NF])+1;
		sprintf(dACy,"%d",annee_compte);
		dACy[4]=0;
		sprintf(psz_lignePRE[PRE_ACY_NF],"%s",dACy);
		
		montant= atof(psz_lignePRE[PRE_ESTMNT_M])*(-1); 
		sprintf(sz_Mnt,"%.3lf",montant);
		sprintf(psz_lignePRE[PRE_ESTMNT_M],"%s",sz_Mnt);  
		
	
		
		
		sprintf(dUwy,"%d",exercice);
		dUwy[4]=0;
		strcpy(psz_lignePRE[PRE_UWY_NF],dUwy);
		
		psz_lignePRE[PRE_ACMTRS_NT][3] = '4';
	
 	  sprintf(psz_lignePRE[PRE_CRE_D], "%s 23:59:31", Ksz_DateJour);
	  sprintf(psz_lignePRE[PRE_LSTUPD_D], "%s 23:59:31", Ksz_DateJour);
    psz_lignePRE[PRE_LSTUPDUSR_CF] = "dbo";
    sprintf(psz_lignePRE[PRE_DETTRNCOD_CF],"%s",DETTRNCOD);
   
 
      
		
		if ( montant!=atof(psz_ligneLib[PRE_ESTMNT_M]))
		{
			n_WriteCols(Kp_OutLibFile,psz_lignePRE,'~',0);
   	}
   	
   	else 	 /*on prends la ligne LifestLib */
   		 {
   	 	 n_WriteCols(Kp_OutLibFile,psz_ligneLib,'~',0);
   		 }

  RETURN_VAL (OK);
}



/*==============================================================================
objet :
        fonction lancee quand le fichier prevision participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{
 
    char dACy[5];
    char dUwy[5];
	  char sz_Mnt[10];
//	  char sz_newd[9]="";
//	  char sz_old[9];
//	  char sz_time[9];

	  int annee_compte;
    double montant;
    int j;
    int reslt=0;
 
   
    char *psz_ligne[PRE_NBCOL+1];
	
    for (j=0;j<PRE_NBCOL;j++)
	   {
	   	psz_ligne[j]=ptb_InRec[j];
	   }
     psz_ligne[PRE_NBCOL]=0;
     

    
    psz_ligne[PRE_BATCH_B]="1";
  
    psz_ligne[PRE_ADJCOD_CT]="0";
    
   exercice = atoi(psz_ligne[PRE_UWY_NF]);
   exercice += i_LiberationExeP1( atoi(psz_ligne[PRE_ACMTRS_NT]) , Kn_TypeComptable);
  
     init_SubTrsAssoLigne();
    sprintf(DETTRNCOD,"%s",psz_ligne[PRE_DETTRNCOD_CF]);	
    DETTRNCOD[5]=0; 	 
    		 	 
        reslt=n_FindTsubTRSAsso(&SubTrsAssoLigne,1,1,DETTRNCOD);
    
       if (reslt!=(-1))
    	  {
    	   	
    	  sprintf(DETTRNCOD,"%s",SubTrsAssoLigne.DETTRNCOD2_CF);
    	  }
    	  else
    	   { 
    	 	 if (DETTRNCOD[2] != '9') DETTRNCOD[2]++;
    	 	 DETTRNCOD[5]=0; 	 
    	   	
    	   }		
     
    /* L annee de compte +1 */
    annee_compte= atoi(psz_ligne[PRE_ACY_NF])+1;
    sprintf(dACy,"%d",annee_compte);
    dACy[4]=0;
    strcpy(psz_ligne[PRE_ACY_NF],dACy);
       
     /* Le Montant change de signe */  
    montant= atof(psz_ligne[PRE_ESTMNT_M])*(-1); 
    sprintf(sz_Mnt,"%.3lf",montant);
    strcpy(psz_ligne[PRE_ESTMNT_M],sz_Mnt);  

    /* modification eventuelle de l'exercice */
  
   sprintf(dUwy,"%d",exercice);
   dUwy[4]=0;
   strcpy(psz_ligne[PRE_UWY_NF],dUwy);
   
   /* L'ACMTRS se transforme en liberation */
   psz_ligne[PRE_ACMTRS_NT][3] = '4';
   
//   sprintf(sz_old,"%.8s",psz_ligne[PRE_CRE_D]);
//   sz_old[8]=0;
//   n_AddDays(sz_newd,1,'+',sz_old);
//   sz_newd[8]=0;
//   sprintf( sz_time,"%.8s",psz_ligne[PRE_CRE_D]+9);
//   sz_time[8]=0;
//   
//  // sprintf(psz_ligne[PRE_CRE_D], "%s 23:59:32", Ksz_DateJour);
//   sprintf(psz_ligne[PRE_CRE_D], "%s %s", sz_newd, sz_time);
//   sprintf(psz_ligne[PRE_LSTUPD_D], "%s 23:59:32", Ksz_DateJour);

 
   psz_ligne[PRE_LSTUPDUSR_CF] = "dbo";
    
   sprintf(psz_ligne[PRE_DETTRNCOD_CF],"%s",DETTRNCOD);
 
   n_WriteCols(Kp_OutLibFile,psz_ligne,'~',0); 

    RETURN_VAL (OK);
}
/*==============================================================================
objet :
        fonction lancee quand le fichier prevision participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec)
{
 
    /* L annee de compte +1 */
  if(atoi(ptb_InRec[PRE_ACY_NF]) == (Annee_courant-Acy_min)) 
  	{
    n_WriteCols(Kp_OutLibFile,ptb_InRec,'~',0);
    }

    RETURN_VAL (OK);
}
/*==============================================================================
objet :
        fonction lancee pour chaque ligne du perimetre synchronisee
        avec les previsions

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre 
==============================================================================*/
int n_ActionLignePerim(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
      

        DEBUT_FCT("n_ActionLignePerim");
           
        Kn_TypeComptable        = atoi(ptb_InRecChild[PER_ACCADMTYP_CT]);
       // sprintf(ptb_InRecOwner[PRE_ACCADMTYP_CT],"%d",Kn_TypeComptable);
         RETURN_VAL (OK); 
}       

/*==========================================================================
     Objet :    Initialisation de la structure TRSASSO

     Nom:       init_SubTrsAssoLigne 

     Parametres:
               

     Retour:    0
===========================================================================*/
//[003]
void init_SubTrsAssoLigne()
{
      
					strcpy(SubTrsAssoLigne.ASSOTYP_CT,"");
					SubTrsAssoLigne.CTX_NT=0;
					strcpy (SubTrsAssoLigne.DETTRNCOD1_CF,"");
					strcpy(SubTrsAssoLigne.CTX_LL,"");
					strcpy (SubTrsAssoLigne.DETTRNCOD2_CF,"");
					strcpy (SubTrsAssoLigne.DETTRNCOD3_CF,"");
					SubTrsAssoLigne.GUI_B=0;
					SubTrsAssoLigne.ACMTRS_NT=0;
					strcpy(SubTrsAssoLigne.CRE_D,"");
					strcpy(SubTrsAssoLigne.CREUSR_CF,"");
					strcpy(SubTrsAssoLigne.LSTUPD_D,"");
					strcpy(SubTrsAssoLigne.LSTUPDUSR_CF,"");
}
