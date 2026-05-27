/*==============================================================================
nom de l'application          : Creation des complements previsionnels
nom du source                 : ESTCLiberation.c
revision                      : $Revision: 1.25 $
date de creation              : 27/08/2014
auteur                        : A. Ben Jeddou
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Creation des constites vides apartir de liberation.


------------------------------------------------------------------------------
[001] 28/08/2014 ABJ  spot:25773 changement de l ACY et de la UWY 
[002] 05/09/2014 ABJ  spot:25773 Creation des sorties P/F a 0 pour les entrees 
[003] 09/09/2014 ABJ  spot:25773  Correction de DETTRNCOD pour la constit crée
[004] 13/09/2014 ABJ  spot:25773  Recuperation du bon ACCADM_TYP
[005] 01/09/2015 SAS  spot 29286  modification de la recuperation des dettrncod1, de la creation des entrees à partir de retraits et les retraits à partir des entrees
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
FILE    *Kp_OutFile;            /* pointeur sur les Liberations */
FILE    *Kp_SubTRSAssoFile;          /* pointeur sur les pilotages */

T_SUBTRSASSO Kbd_SubTRSASSO[10000];


T_SUBTRSASSO SubTrsAssoLigne;
T_RUPTURE_VAR           bd_RuptPrev;    /* gestion rupture sur pilotage */

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePrev(char **pbd_InRec_Cur);
int n_IsRPrev(char **ptb_InRec, char **ptb_InRec_Cur);
void init_SubTrsAssoLigne();

int exercice;
T_RUPTURE_SYNC_VAR bd_RuptPerim; /* gestion synchro perimetre-previsions */ //[004]


int n_InitPerim (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePerim  (char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPerim(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_IsR1PrevisionEx(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrevisionEx(char **ptb_InRec_Cur);
int     Kn_TypeComptable=0;
static int n_ReturnDett(int, int, char*);
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
    if ( n_OpenFileAppl ("ESTC2166_O","wt",&Kp_OutFile) == ERR )
        ExitPgm ( ERR_XX , "" );
    
    if ( n_OpenFileAppl ("ESTC2166_I2","rb",&Kp_SubTRSAssoFile) == ERR )
                ExitPgm ( ERR_XX , "" );  
                
    n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile);  
    /* Initialisation de la varible bd_RuptPrev */
    if ( n_InitPrev(&bd_RuptPrev) )
        ExitPgm ( ERR_XX , "" );

         /* Initialisation de la varible bd_RuptPerim */
    if ( n_InitPerim(&bd_RuptPerim) )    //[004]
                ExitPgm ( ERR_XX , "" );

    
        /* Lancement du traitement du fichier */
    if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Fermeture fichier */
    if (n_CloseFileAppl ("ESTC2166_I",&(bd_RuptPrev.pf_InputFil)) == ERR)
        ExitPgm ( ERR_XX , "" );

   
    
    if (n_CloseFileAppl ("ESTC2166_O",&Kp_OutFile) == ERR)
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2166_I2",&Kp_SubTRSAssoFile) == ERR)
        ExitPgm ( ERR_XX , "" );
        
    if (n_CloseFileAppl ("ESTC2166_I3",&(bd_RuptPerim.pf_InputFil)))
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

    if ( n_OpenFileAppl("ESTC2166_I","rt",&(pbd_Rupt->pf_InputFil)) == ERR )
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
objet : fonction lancee pour chaque ligne des previsions synchronisee
        avec les Liberations
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec)          /* adresse de la ligne de l'esclave */
{

     char sz_Mnt[10];

	int j,reslt = 0, ret =0;
    int Dettrncodconstit;
   char DETTRNCOD[6]="";

   	 n_WriteCols(Kp_OutFile,ptb_InRec,'~',0);
   	 
    char *psz_lignePRE[PRE_NBCOL+1];
   
		for (j=0;j<PRE_NBCOL;j++)
		{
		psz_lignePRE[j]=ptb_InRec[j];
		}
		psz_lignePRE[PRE_NBCOL]=0;
		Dettrncodconstit=0;
		
	
	  sprintf(psz_lignePRE[PRE_ACCADMTYP_CT],"%d",Kn_TypeComptable);  // [004]
	  
	  
		if ( psz_lignePRE[PRE_ACMTRS_NT][3]=='4')
			{
					psz_lignePRE[PRE_BATCH_B]="1";
	
	
	
		  sprintf(sz_Mnt,"%d",0);
      strcpy(psz_lignePRE[PRE_ESTMNT_M],sz_Mnt); 
    
      sprintf(sz_Mnt,"%d",0);
      strcpy(psz_lignePRE[PRE_GAAPDIFF_M],sz_Mnt);   
		
	    psz_lignePRE[PRE_ACMTRS_NT][3] = '3';
	  
	
 
   	  Dettrncodconstit=n_FindTsubTRSAssoCons(1, 1,psz_lignePRE[PRE_DETTRNCOD_CF]); 
   	   if (Dettrncodconstit==-1)    //[003]
    	   { 
    	 	Dettrncodconstit = atoi(psz_lignePRE[PRE_DETTRNCOD_CF]) -100;
    	   	
    	   }		
      sprintf(psz_lignePRE[PRE_DETTRNCOD_CF],"%d",Dettrncodconstit);
      psz_lignePRE[PRE_ADJCOD_CT]="1";
      
		
	
			n_WriteCols(Kp_OutFile,psz_lignePRE,'~',0);
      }  
      
      //[005]
    if ( psz_lignePRE[PRE_ACMTRS_NT][3]=='1')
	 {
				psz_lignePRE[PRE_BATCH_B]="1";
 	  	
	     	sprintf(sz_Mnt,"%d",0);
        strcpy(psz_lignePRE[PRE_ESTMNT_M],sz_Mnt); 
    
        sprintf(sz_Mnt,"%d",0);
        strcpy(psz_lignePRE[PRE_GAAPDIFF_M],sz_Mnt);   
		
	       psz_lignePRE[PRE_ACMTRS_NT][3] = '2';
	  
	
        init_SubTrsAssoLigne();
        sprintf(DETTRNCOD,"%s",psz_lignePRE[PRE_DETTRNCOD_CF]);	
         DETTRNCOD[5]=0; 	 
    		 	 
        reslt=n_FindTsubTRSAssoCons(5, 1, psz_lignePRE[PRE_DETTRNCOD_CF]);
    
        if (reslt!=(-1))
    	  {
    	  ret = n_ReturnDett(5, 1, psz_lignePRE[PRE_DETTRNCOD_CF]);
    	  sprintf(DETTRNCOD,"%d",ret);
    	  }
    	  else
    	   { 
    	 	 if (DETTRNCOD[2] != '9') DETTRNCOD[2]--;
    	 	 DETTRNCOD[5]=0; 	 
    	   	
    	   }		
       sprintf(psz_lignePRE[PRE_DETTRNCOD_CF],"%s",DETTRNCOD);
       psz_lignePRE[PRE_ADJCOD_CT]="1";
      
		
	
			n_WriteCols(Kp_OutFile,psz_lignePRE,'~',0);
      }  		


 //[002] //[005]
if ( psz_lignePRE[PRE_ACMTRS_NT][3]=='2')
    {
                psz_lignePRE[PRE_BATCH_B]="1";
        
            sprintf(sz_Mnt,"%d",0);
        strcpy(psz_lignePRE[PRE_ESTMNT_M],sz_Mnt); 
    
        sprintf(sz_Mnt,"%d",0);
        strcpy(psz_lignePRE[PRE_GAAPDIFF_M],sz_Mnt);   
        
           psz_lignePRE[PRE_ACMTRS_NT][3] = '1';
      
    
        init_SubTrsAssoLigne();
        sprintf(DETTRNCOD,"%s",psz_lignePRE[PRE_DETTRNCOD_CF]); 
         DETTRNCOD[5]=0;     
                 
        reslt=n_FindTsubTRSAsso(&SubTrsAssoLigne, 5, 1, psz_lignePRE[PRE_DETTRNCOD_CF]);
    
        if (reslt!=(-1))
          {
          sprintf(DETTRNCOD,"%s",SubTrsAssoLigne.DETTRNCOD2_CF);
          }
          else
           { 
             if (DETTRNCOD[2] != '9') DETTRNCOD[2]++;
             DETTRNCOD[5]=0;     
            
           }        
        sprintf(psz_lignePRE[PRE_DETTRNCOD_CF],"%s",DETTRNCOD);
        psz_lignePRE[PRE_ADJCOD_CT]="1";
      
        
    
        n_WriteCols(Kp_OutFile,psz_lignePRE,'~',0);
    } 

   	
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
//[004]

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
        RETURN_VAL (OK); 
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
        Initialisation de la synchronisation du maitre avec l'esclave Perim

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl("ESTC2166_I3","rt",&(pbd_Rupt->pf_InputFil)) == ERR )
          RETURN_VAL (ERR);
        
        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPerim ;
        
        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLignePerim ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL (OK);
}

/*==========================================================================
     Objet :    Recuperer le code détail (contre partie) d'un poste donné (pour un DETTRNCOD)
     à partir de la structure T_SUBTRSASSO grace a l association et le context

     Nom:       n_ReturnDett

     Parametres:
                pointeur sur stucture TRSASSO
                Association
                context
                DETTRNCOD lib

     Retour:    DETTRNCOD/-1
===========================================================================*/
int n_ReturnDett(int Asso, int contx, char *DETRNCOD)
{
  int i;

  for (i = 0; i < sizeof(T_SUBTRSASSO); i++)
  { if ((Asso == atoi(Kbd_SubTRSASSO[i].ASSOTYP_CT)) && (contx == Kbd_SubTRSASSO[i].CTX_NT) && ((strcmp(DETRNCOD, Kbd_SubTRSASSO[i].DETTRNCOD2_CF) == 0)))
    {
      return atoi(Kbd_SubTRSASSO[i].DETTRNCOD1_CF);
    }
  }
  return -1 ;
}



/*==========================================================================*/