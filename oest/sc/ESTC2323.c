/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

 /*==============================================================================
nom de l'application          : Job ESID2531.cmd (Rapprochement retrocession)
nom du source                 : ESTC2323.c
revision                      : $Revision:   1.0  $
date de creation              : 13/10/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Synchronisation du fichier des mouvements de rachat         
        TCMUSPLI avec le perimetre retrocession -
	Selection des postes rapprochables -

	Synchronisation du fichier des mouvements de rachat temporaires 
        TCMUSPLIT avec le perimetre retrocession - 
	Selection des postes rapprochables -

        Les mouvements selectionnes sont ecrits dans un fichier au
        format du fichier de rapprochement - 
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
static int n_InitPER(T_RUPTURE_VAR  *);
static int n_InitTCMUSPLIT(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneTCMUSPLIT(char **,char**);
static int n_ConditionSyncTCMUSPLIT(char **,char **);
static int n_ActionLignePER(char **);
static int n_InitTCMUSPLI(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneTCMUSPLI(char **,char**);
static int n_ConditionSyncTCMUSPLI(char **,char **);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_Out;
static FILE *Kp_Dettrs;

static T_RUPTURE_VAR   Kbd_RuptPER;       
static T_RUPTURE_SYNC_VAR  Kbd_RuptTCMUSPLI;  
static T_RUPTURE_SYNC_VAR  Kbd_RuptTCMUSPLIT;  

char Ksz_AnneeBilan[5];

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

        sprintf(Ksz_AnneeBilan,"%s",psz_GetCharArgv(1));

        if ( n_OpenFileAppl ("ESTC2323_O1","wt",&Kp_Out) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2323_I4","rb",&Kp_Dettrs) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptPER  */
	if ( n_InitPER(&Kbd_RuptPER)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptTCMUSPLIT */
	if ( n_InitTCMUSPLIT(&Kbd_RuptTCMUSPLIT)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptTCMUSPLI */
	if ( n_InitTCMUSPLI(&Kbd_RuptTCMUSPLI)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptPER) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2323_O1",&Kp_Out)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2323_I1",&(Kbd_RuptPER.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2323_I2",&(Kbd_RuptTCMUSPLIT.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2323_I3",&(Kbd_RuptTCMUSPLI.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2323_I4",&Kp_Dettrs)==ERR )
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
static int n_InitPER(T_RUPTURE_VAR  *pbd_RuptPER)
{
	memset(pbd_RuptPER,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2323_I1","rt",&(pbd_RuptPER->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptPER->n_NbRupture =0;    
	pbd_RuptPER->n_ActionLigne     = n_ActionLignePER;

        pbd_RuptPER->c_Separ=SEPARATEUR;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree 
==============================================================================*/
static int n_InitTCMUSPLIT(T_RUPTURE_SYNC_VAR  *pbd_RuptTCMUSPLIT)
{

	memset( pbd_RuptTCMUSPLIT,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2323_I2","rt",&(pbd_RuptTCMUSPLIT->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptTCMUSPLIT->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptTCMUSPLIT->ConditionEndSync	= n_ConditionSyncTCMUSPLIT;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptTCMUSPLIT->n_ActionLigne   	= n_ActionLigneTCMUSPLIT;
	
        pbd_RuptTCMUSPLIT->c_Separ=SEPARATEUR;

        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLigneTCMUSPLIT(
	char *tpsz_ReadBufferPER[] ,
	char *tpsz_ReadBufferTCMUSPLIT[]
)
{
    char MsgAno[200];
    int n_ret;
    short n_type;

/* Modif du 1/12/98 (Y.Bourdaillet)    */
/* Rajout du test: n_TypePoste         */
/* Il permet de filtrer les provisions */
           if ( 
               ((n_ret=b_PosteRappro(tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_TRNCOD_CF],Kp_Dettrs) ) == TRUE)
               &&
               ((n_type = n_TypePoste(tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_TRNCOD_CF],Kp_Dettrs)) != 3)
               &&
               (n_type != 0)
              )
           {

             fprintf(Kp_Out,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~~~~~%.3lf~~~~~\n", 
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_SSD_CF], 
                      tpsz_ReadBufferPER[PER_ACCESB_CF],
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_CTR_NF], 
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_END_NT], 
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_SEC_NF], 
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_UWY_NF], 
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_UW_NT], 
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_RETCTR_NF], 
                      "0", /* RETEND_NT */
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_RETSEC_NF], 
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_RTY_NF], 
                      "1",  /* RETUW_NT */
                      tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_CNVCUR_CF], 
                      (-1) * atof(tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_CNVAMT_M])) ;

             }  /* fin du if poste rapprochable */

     /*------------------------------------------------------------*/
     /* si la fonction b_PosteRappro a renvoye -1, ca signifie que */
     /* le poste passe en parametre n'a pas ete trouve dans DETTRS */
     /* et dans ce cas une anomalie est generee                    */
     /*------------------------------------------------------------*/
    
      if (n_ret == -1)
      {
         sprintf(MsgAno,"The transaction code %s could not be found in table TDETTRS",tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_TRNCOD_CF]);
         n_WriteAno(MsgAno);
      } 
     /*------------------------------------------------------------*/
     /* si le type de poste renvoye par la fonction n_TypePoste    */
     /* est 0 , ca signifie que                                    */
     /* le poste passe en parametre n'a pas ete trouve dans DETTRS */
     /* et dans ce cas une anomalie est generee                    */
     /*------------------------------------------------------------*/

      if (n_type == 0)
      {
         sprintf(MsgAno,"The transaction code %s could not be found in table TDETTRS",tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_TRNCOD_CF]);
         n_WriteAno(MsgAno);
      }
               

        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0       ---> pbd_InRecOwner = pbd_InRecChild 
	> 0   	---> pbd_InRecOwner > pbd_InRecChild 
	< 0   	---> pbd_InRecOwner < pbd_InRecChild 
==============================================================================*/
static int n_ConditionSyncTCMUSPLIT(
	char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferTCMUSPLIT[]  /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSyncTCMUSPLIT");

        if((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_RETSEC_NF]))!=0)
           RETURN_VAL (ret);
                
        if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferTCMUSPLIT[TCMUSPLIT_RTY_NF]))!=0)
           RETURN_VAL (ret);
        
        RETURN_VAL( OK ) ;
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLignePER(char *tpsz_ReadBufferPER[])
{
     /* lancement de la 1ere synchro */
     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptTCMUSPLIT,tpsz_ReadBufferPER) == ERR)
           return ERR;
     
     /* lancement de la 2eme synchro */
     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptTCMUSPLI,tpsz_ReadBufferPER) == ERR)
           return ERR;

        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree 
==============================================================================*/
static int n_InitTCMUSPLI(T_RUPTURE_SYNC_VAR  *pbd_RuptTCMUSPLI)
{

	memset( pbd_RuptTCMUSPLI,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2323_I3","rt",&(pbd_RuptTCMUSPLI->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptTCMUSPLI->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptTCMUSPLI->ConditionEndSync	= n_ConditionSyncTCMUSPLI;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptTCMUSPLI->n_ActionLigne   	= n_ActionLigneTCMUSPLI;
	
        pbd_RuptTCMUSPLI->c_Separ=SEPARATEUR;

        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLigneTCMUSPLI(
	char *tpsz_ReadBufferPER[] ,
	char *tpsz_ReadBufferTCMUSPLI[]
)
{
    int n_ret;
    short n_type;
    
    char sz_accyear[5];

    sprintf(sz_accyear,"%4.4s",tpsz_ReadBufferTCMUSPLI[TCMUSPLI_ACC_D]);

/* Modif du 1/12/98 (Y.Bourdaillet)    */
/* Rajout du test: n_TypePoste         */
/* Il permet de filtrer les provisions */

    if ( atoi(sz_accyear) == atoi(Ksz_AnneeBilan) )
    {        
           if ( 
               ((n_ret=b_PosteRappro(tpsz_ReadBufferTCMUSPLI[TCMUSPLI_TRNCOD_CF],Kp_Dettrs) ) == TRUE)
               &&
               ((n_type = n_TypePoste(tpsz_ReadBufferTCMUSPLI[TCMUSPLI_TRNCOD_CF],Kp_Dettrs)) != 3)
               &&
               (n_type != 0)
              )
           {
             fprintf(Kp_Out,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~~~~~%.3lf~~~~~\n", 
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_SSD_CF], 
                      tpsz_ReadBufferPER[PER_ACCESB_CF],
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_CTR_NF], 
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_END_NT], 
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_SEC_NF], 
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_UWY_NF], 
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_UW_NT], 
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_RETCTR_NF], 
                      "0", /* RETEND_NT */
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_RETSEC_NF], 
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_RTY_NF], 
                      "1",  /* RETUW_NT */
                      tpsz_ReadBufferTCMUSPLI[TCMUSPLI_CNVCUR_CF], 
                      (-1) * atof(tpsz_ReadBufferTCMUSPLI[TCMUSPLI_CNVAMT_M]) * atof(tpsz_ReadBufferTCMUSPLI[TCMUSPLI_TOTCMU_R]));

               }  /* fin du if poste rapprochable */
     } /* fin du if ACC_D = annee bilan */


        RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0       ---> pbd_InRecOwner = pbd_InRecChild 
	> 0   	---> pbd_InRecOwner > pbd_InRecChild 
	< 0   	---> pbd_InRecOwner < pbd_InRecChild 
==============================================================================*/
static int n_ConditionSyncTCMUSPLI(
	char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferTCMUSPLI[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSync");

        if((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferTCMUSPLI[TCMUSPLI_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferTCMUSPLI[TCMUSPLI_RETSEC_NF]))!=0)
           RETURN_VAL (ret);
                
        if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferTCMUSPLI[TCMUSPLI_RTY_NF]))!=0)
           RETURN_VAL (ret);
        
        RETURN_VAL( OK ) ;
}


