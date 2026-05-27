/*==============================================================================
nom de l'application          : Exclusion de la partie RETRO interne
nom du source                 : ESTC2145.c
revision                      : $Revision:   1.4  $
date de creation              : 01/07/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :

        Exclusion la retro interne du GT

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
		09/05/2007    J. Ribot SPOT13867 reconduire si ptb_InRecOwner[PER_CED_NF] = "91670" && ptb_InRecOwner[PER_ACCESB_CF] = "1"
           ...           ...            ...              ...
[001] 12/06/2014 JBG :spot:25773 Warning suppress
[002] 22/07/2014 R. Cassis :spot:26948 Omit filter on cedant 91670
[003] 17/07/2014 ABJ :spot:25773 Suppression des lignes avec deux montants =0
[004] 16/03/2015 ASA :spot 28465 EST29a, Ajout de la ligne 222 
[005] 20/03/2015 ABJ  spot:28511  Ecriture des complement pour SRV dans le cas poste cash et pas de calcul complement GT
[006] 16/04/2015 Paul Garnier spot:28559   
[008] 29/07/2015 MMECHRI  spot:29150 Annulation de Commision sur CARE, Traités plan dans le closing
[009] 16/12/2015 RBE  :spot:29894   Correction du filtre sur les echanges internes (gaap 1 et 2)
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

/*----------------------------------*/
 
/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_GTOutFil;                    /* pointeurs sur les fichiers en sortie */
FILE    *Kp_AnoOutFil; 
FILE    *Kp_SubTRSEsbPropFile;  

T_RUPTURE_VAR bd_RuptPeri;            /* gestion rupture sur le perimetre */
T_RUPTURE_SYNC_VAR  bd_RuptGT;        /* gestion synchro avec le GT */

T_SUBTRSESBPROP     SubTrsEsbPropLigne;

int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPeri(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPeri(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePerimetre(char **ptb_InRec_Cur);
int n_ActionFilsSansPere( char **ptb_InRec_Cur );
void init_SubTrsEsBprop();


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{

     /* Initialisation des signaux */
     InitSig();

    if (n_BeginPgm(argc, argv) == ERR)
        ExitPgm(ERR_XX, "" );

    /* ouverture des fichiers en sortie */
    if (n_OpenFileAppl("ESTC2146_O1", "wt", &Kp_GTOutFil) == ERR)
        ExitPgm(ERR_XX, "");
                
    if (n_OpenFileAppl("ESTC2146_O2", "wt", &Kp_AnoOutFil) == ERR)
        ExitPgm(ERR_XX, "");  
                      

    if (n_OpenFileAppl("ESTC2146_I3", "rb", &Kp_SubTRSEsbPropFile) == ERR)
        ExitPgm(ERR_XX, "");

    n_ChargerSUBTRSESBPROP(Kp_SubTRSEsbPropFile);         

     /* Initialisation de la varible bd_RuptPeri */
    if (n_InitPeri(&bd_RuptPeri))
        ExitPgm(ERR_XX, "");

    /* Initialisation de la varible bd_RuptGT */
    if (n_InitGT(&bd_RuptGT))
        ExitPgm(ERR_XX, "");

    /* lancement du traitement du fichier */
    if (n_ProcessingRuptureVar(&bd_RuptPeri) == ERR)
        ExitPgm(ERR_XX, "");

    /* Fermeture fichier */
    if (n_CloseFileAppl("ESTC2146_I1", &(bd_RuptPeri.pf_InputFil)))
        ExitPgm(ERR_XX, "");

    if (n_CloseFileAppl("ESTC2146_I2", &(bd_RuptGT.pf_InputFil)))
        ExitPgm(ERR_XX, "");
                
    if (n_CloseFileAppl("ESTC2146_I3", &Kp_SubTRSEsbPropFile))
        ExitPgm(ERR_XX, "");

    if (n_CloseFileAppl("ESTC2146_O1", &Kp_GTOutFil))
        ExitPgm(ERR_XX, "");
    
    if (n_CloseFileAppl("ESTC2146_O2", &Kp_AnoOutFil))
        ExitPgm(ERR_XX, "");
                

    if (n_EndPgm() == ERR)
        ExitPgm(ERR_XX, "");

    exit(OK);
}



/*==============================================================================
objet :
        Initialisation du maitre

retour :
        OK
==============================================================================*/
int n_InitPeri(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPeri");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2146_I1","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;
        pbd_Rupt->n_ActionLigne         = n_ActionLignePerimetre ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier GT.

retour :
        OK
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

        if ( n_OpenFileAppl ("ESTC2146_I2","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPeri;
        pbd_Rupt->n_ActionLigne         = n_ActionLigneGT ;
        pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPere ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne des previsions

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
    DEBUT_FCT("n_ActionLigneGT");
    //[001]
    int result=0;        
    char DetTRNCod[6];  

    //[003]
    if(atof(ptb_InRecChild[GT_AMT_M])!=0 )
    { 
	   strcpy(DetTRNCod,ptb_InRecChild[GT_TRNCOD_CF]+2);
       DetTRNCod[5]=0;

       init_SubTrsEsBprop();
	   result = n_RechSUBTRSESBPROP(&SubTrsEsbPropLigne,DetTRNCod, ptb_InRecChild[GT_SSD_CF], ptb_InRecChild[GT_ESB_CF]);

       /* Reconduction si pas rétro interne ou si rétro interne mais venant de Scor UK ou de
	      Scor US et si crible different de special et non crible */
		if (((*ptb_InRecOwner[PER_CTRRET_B] == '0') ||
			  (strcmp(ptb_InRecOwner[PER_CED_NF], "12040") == 0) ||
			  (strcmp(ptb_InRecOwner[PER_CED_NF], "70130") == 0) ||
			  (strcmp(ptb_InRecOwner[PER_CTR_NF], "04Z0U0191") == 0)) &&
			  (*ptb_InRecOwner[PER_ESTCRB_CT] != 'S') &&
        (*ptb_InRecOwner[PER_ESTCRB_CT] != 'D') &&  //[004]
		(*ptb_InRecOwner[PER_ESTCRB_CT] != 'N') &&
        (atof(ptb_InRecChild[GT_AMT_M]) != 0) ) //[005]
//[001]						
		{   

		    if ((result==0 && SubTrsEsbPropLigne.GLTFEEDING_B ==1) || (result == -1 ))
       	        n_WriteCols(Kp_GTOutFil, ptb_InRecChild,'~', 0);
       	    else
       	        n_WriteCols(Kp_AnoOutFil, ptb_InRecChild,'~', 0);   
		}


	  if (ptb_InRecOwner[PER_CTRRET_B][0] == '1')
	  {

	    if ((result==0 && SubTrsEsbPropLigne.GLTFEEDING_B ==1) || (result == -1 ))
        {
	        if (ptb_InRecChild[GT_TRNCOD_CF][7] == '2' || ptb_InRecChild[GT_TRNCOD_CF][7] == 'A')
	        {
	           n_WriteCols(Kp_AnoOutFil, ptb_InRecChild,'~', 0);
	        }
	        else
	           n_WriteCols(Kp_GTOutFil, ptb_InRecChild,'~', 0);
        }
        else
           n_WriteCols(Kp_AnoOutFil, ptb_InRecChild,'~', 0);
      }
      else
         n_WriteCols(Kp_AnoOutFil, ptb_InRecChild,'~', 0);

	}        
    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de synchro

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPeri(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPeri");

        if ( (ret = strcmp(pbd_InRecOwner[PER_CTR_NF],pbd_InRecChild[GT_CTR_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_END_NT],pbd_InRecChild[GT_END_NT])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_SEC_NF],pbd_InRecChild[GT_SEC_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UWY_NF],pbd_InRecChild[GT_UWY_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UW_NT],pbd_InRecChild[GT_UW_NT])) != 0 )
                RETURN_VAL(ret);

        RETURN_VAL(ret);
}



/*==============================================================================
objet :
        fonction lancee si le perimetre ne participe pas.
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere( char **ptb_InRec_Cur )
{
        DEBUT_FCT("n_ActionLignePerimetre");

	/****************************************/
	/* Modifs du 12/06/98 - M.HA-THUC	*/
	/* On ne reconduit plus le complement si l'affaire	*/
	/* n'existe pas dans le	perimetre				*/
	/****************************************/

        /* n_WriteCols(Kp_GTOutFil, ptb_InRec_Cur,'~', 0); */

        RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne du perimetre
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerimetre( char **ptb_InRec_Cur )
{
        DEBUT_FCT("n_ActionLignePerimetre");

        /* synchronisation du fichier des previsions */
        n_ProcessingRuptureSyncVar (&bd_RuptGT, ptb_InRec_Cur) ;

        RETURN_VAL(OK);
}
//[001]
/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsEsBprop

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsEsBprop()
{
            strcpy(SubTrsEsbPropLigne.DETTRNCOD_CF, "");
            SubTrsEsbPropLigne.SSD_CF=0;
            SubTrsEsbPropLigne.ESB_CF=0;
            SubTrsEsbPropLigne.GLTFEEDING_B=0;
            SubTrsEsbPropLigne.INTERNRETRO_B=0;
            SubTrsEsbPropLigne.SRVFEEDING_B=0;
            SubTrsEsbPropLigne.PREMIUMPNPEGPI_B=0;
            SubTrsEsbPropLigne.RETROAUTO_B=0;
            SubTrsEsbPropLigne.COMACIMPACT_B=0;
            SubTrsEsbPropLigne.CASHFLOWPOS_CT=0;
            SubTrsEsbPropLigne.GAAP1TRS_CT=0;
            SubTrsEsbPropLigne.GAAP2TRS_CT=0;
            SubTrsEsbPropLigne.GAAP3TRS_CT=0;
            SubTrsEsbPropLigne.GAAP4TRS_CT=0;
            SubTrsEsbPropLigne.GAAP5TRS_CT=0;
            strcpy(SubTrsEsbPropLigne.CRE_D,"");
			      strcpy(SubTrsEsbPropLigne.CREUSR_CF,"");
            strcpy(SubTrsEsbPropLigne.LSTUPD_D,"");
            strcpy(SubTrsEsbPropLigne.LSTUPDUSR_CF,"");
}

