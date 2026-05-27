/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Prise en compte des données du dernier exercice
nom du source                 : ESTC2041.c
revision                      : $Revision:   1.3  $
date de creation              : 23/10/1997
auteur                        : P. LOUVEAU
references des specifications : ESIIV011
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Prise en compte des données du dernier exercice

------------------------------------------------------------------------------
historique des modifications :
   22/08/2001  O.GIRAUX   On teste en dur si PCPCUR fait partie des 12 devises IN, 
   			  si oui, on la met en EUR.   
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           20/01/2011
Version:        10.2
Description:    ESTVIE20627 estimation sur des traités de rattachement en 'terminé comptable'
[...] 13/03/2012 R.Cassis   :spot:yyyyy retour version de Prod
==============================================================================*/

//--------------------------------------------------
// inclusion des interfaces des composants importes 
//--------------------------------------------------
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"
        
//----------------------
// variables de travail 
//----------------------

FILE    *Kp_PeriInFil;          // pointeur sur les perimetres
FILE    *Kp_PeriOutFil;         // pointeur sur les perimetres
FILE    *Kp_Cours;              // pointeur sur le fichier des taux
FILE    *Kp_LogSecaccstsFil;    //[002]

T_RUPTURE_VAR   bd_RuptPeri;    // gestion rupture sur le perimetre

int n_InitPeri              (T_RUPTURE_VAR *);
int n_ActionLignePeri       (char **);
int n_IsR1Peri              (char **, char **);
int n_ActionFirstRuptPeri   (char **);

char Ksz_pcpcur[5];             // devise pris en compte pour un contrat/section
char Ksz_secaccsts[2];          // etat comptable

char Ksz_uwgrp[5];              // unite de gestion
char Ksz_anlcty[4];             // pays d'analyse
char Ksz_liftrttyp[3];          // caracterisation vie
char Ksz_accadmtyp[2];          // type comptable
char Ksz_estctr[10];            // infos relatives au contrat de
char Ksz_estsec[5];             // rattachement
char Ksz_seg[11];               // segment d'analyse



/*==============================================================================
objet : point d'entree du programme
retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    // Initialisation des signaux
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )      ExitPgm ( ERR_XX , "" );

    /* Ouverture des fichiers en sortie */
    if ( n_OpenFileAppl ("ESTC2041_O1","wt",&Kp_PeriOutFil) == ERR )            ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2041_O2","wt",&Kp_LogSecaccstsFil) == ERR )       ExitPgm ( ERR_XX , "" );            //[002]


    // Initialisation de la varible bd_RuptPeri
    if ( n_InitPeri(&bd_RuptPeri) )             ExitPgm ( ERR_XX , "" );

    // Lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptPeri) == ERR )                         ExitPgm ( ERR_XX , "" );

    // Fermeture fichier
    if (n_CloseFileAppl ("ESTC2041_I1",&(bd_RuptPeri.pf_InputFil)))             ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2041_O1",&Kp_PeriOutFil))                         ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2041_O2",&Kp_LogSecaccstsFil))                    ExitPgm ( ERR_XX , "" );            //[002]

    if ( n_EndPgm () == ERR )                   ExitPgm ( ERR_XX , "" );

  exit(0) ;
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du 
        fichier maitre.
retour : 0
==============================================================================*/
int n_InitPeri(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPeri");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2041_I1","rt",&(pbd_Rupt->pf_InputFil)))          RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 1 ;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Peri;
    pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRuptPeri;
    pbd_Rupt->n_ActionLigne         = n_ActionLignePeri ;
    pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture de niveau 1 sur Contrat/Section
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Peri(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1Peri");

    if (strcmp(ptb_InRec[PER_CTR_NF],ptb_InRec_Cur[PER_CTR_NF])!=0)             RETURN_VAL(1);
    if (strcmp(ptb_InRec[PER_SEC_NF],ptb_InRec_Cur[PER_SEC_NF])!=0)             RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptPeri (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptPeri");

    // Memorisation apres correction eventuelle des donnees a reporter
    strcpy (Ksz_pcpcur, ptb_InRec_Cur[PER_PCPCUR_CF]);

    strcpy (Ksz_secaccsts, ptb_InRec_Cur[PER_SECACCSTS_CT]);

    strcpy (Ksz_uwgrp, ptb_InRec_Cur[PER_UWGRP_CF]);
    strcpy (Ksz_anlcty, ptb_InRec_Cur[PER_ANLCTY_CF]);
    strcpy (Ksz_liftrttyp, ptb_InRec_Cur[PER_LIFTRTTYP_CF]);

   // if ( (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT]," ") != 0)    &&
   if ( (strcmp(ptb_InRec_Cur[PER_SEGTYP_CT],"") != 0)    &&                // utiliser SEGTYP pour distinguer Accept et Retro, si vide = Retro
         (strcmp(ptb_InRec_Cur[PER_SECSTS_CT],"19") == 0)   &&
         (strcmp(ptb_InRec_Cur[PER_ACCADMTYP_CT],"1") == 0) )
        strcpy (ptb_InRec_Cur[PER_ACCADMTYP_CT],"4");

   // if ( (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT]," ") != 0)    &&
   if ( (strcmp(ptb_InRec_Cur[PER_SEGTYP_CT],"") != 0)    &&
         (strcmp(ptb_InRec_Cur[PER_SECSTS_CT],"19") == 0)   &&
         (strcmp(ptb_InRec_Cur[PER_ACCADMTYP_CT],"3") == 0) )
        strcpy (ptb_InRec_Cur[PER_ACCADMTYP_CT],"5");

   // if ( (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT]," ") == 0)    &&
   if ( (strcmp(ptb_InRec_Cur[PER_SEGTYP_CT],"") == 0)    &&
         (strcmp(ptb_InRec_Cur[PER_CTRSTS_CT],"19") == 0)   &&
         (strcmp(ptb_InRec_Cur[PER_ACCADMTYP_CT],"1") == 0) )
        strcpy (ptb_InRec_Cur[PER_ACCADMTYP_CT],"4");

   // if ( (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT]," ") == 0)    &&
   if ( (strcmp(ptb_InRec_Cur[PER_SEGTYP_CT],"") == 0)    &&
         (strcmp(ptb_InRec_Cur[PER_CTRSTS_CT],"19") == 0)   &&
         (strcmp(ptb_InRec_Cur[PER_ACCADMTYP_CT],"3") == 0) )
        strcpy (ptb_InRec_Cur[PER_ACCADMTYP_CT],"5");

    strcpy (Ksz_accadmtyp, ptb_InRec_Cur[PER_ACCADMTYP_CT]);
    strcpy (Ksz_estctr, ptb_InRec_Cur[PER_ESTCTR_NF]);
    strcpy (Ksz_estsec, ptb_InRec_Cur[PER_ESTSEC_NF]);
    strcpy (Ksz_seg, ptb_InRec_Cur[PER_SEG_NF]);

  RETURN_VAL(0);
}


/*==============================================================================
objet : Fonction lancee a chaque ligne du perimetre
==============================================================================*/
int n_ActionLignePeri ( char **ptb_InRec_Cur )
{
    DEBUT_FCT("n_ActionLigneGT");

    // Report de la valeur du dernier exercice pour certaines donnees
    ptb_InRec_Cur[PER_PCPCUR_CF] = Ksz_pcpcur;								  

    if(strcmp(ptb_InRec_Cur[PER_SECACCSTS_CT], Ksz_secaccsts) != 0 )
    {
        //[002] entete
        //[002] On écrit une log quand le secaccsts_ct est différent de celui de l'exercice max
        int i=0;
        if(i++==0)
        //                          0  1   2   3         4   5      6         7
        fprintf(Kp_LogSecaccstsFil,"~ctr~uwy~sec~secaccsts~lib~estCRB~secaccsts\n");
        //                                  0  1  2  3  4                        5  6  7
        fprintf(Kp_LogSecaccstsFil,"PERIMETRE~%s~%s~%s~%s~NOUVEAU_STATUT_COMPTABLE~%s~%s\n",
                ptb_InRec_Cur[PER_CTR_NF],          // 01
                ptb_InRec_Cur[PER_UWY_NF],          // 02
                ptb_InRec_Cur[PER_SEC_NF],          // 03
                ptb_InRec_Cur[PER_SECACCSTS_CT],    // 04
                ptb_InRec_Cur[PER_ESTCRB_CT],       // 06
                Ksz_secaccsts);                     // 07
    }

    ptb_InRec_Cur[PER_SECACCSTS_CT] = Ksz_secaccsts; 
    ptb_InRec_Cur[PER_UWGRP_CF]     = Ksz_uwgrp; 
    ptb_InRec_Cur[PER_ANLCTY_CF]    = Ksz_anlcty; 
    ptb_InRec_Cur[PER_LIFTRTTYP_CF] = Ksz_liftrttyp; 

    if (Ksz_accadmtyp[0] == '4')
        Ksz_accadmtyp[0] = '1';
 
    if (Ksz_accadmtyp[0] == '5')
        Ksz_accadmtyp[0] = '3';

    // if ( (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT]," ") != 0)    &&
    if ( (strcmp(ptb_InRec_Cur[PER_SEGTYP_CT],"") != 0)    &&    	
         (strcmp(ptb_InRec_Cur[PER_SECSTS_CT],"19") != 0)   )
        strcpy (ptb_InRec_Cur[PER_ACCADMTYP_CT],Ksz_accadmtyp);

    // if ( (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT]," ") == 0)    &&
    if ( (strcmp(ptb_InRec_Cur[PER_SEGTYP_CT],"") == 0)    &&
         (strcmp(ptb_InRec_Cur[PER_CTRSTS_CT],"19") != 0)   )
        strcpy (ptb_InRec_Cur[PER_ACCADMTYP_CT],Ksz_accadmtyp);


    // Initialisation du segment d'analyse
    ptb_InRec_Cur[PER_SEG_NF] = "001"; 

    // Initialisation du traité de rattachement pour LVR 1 (temporaire)
    /*if ((strcmp(ptb_InRec_Cur[PER_SSD_CF],"6") == 0)    &&
        (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT],"N") == 0) )
        ptb_InRec_Cur[PER_ESTCTR_NF] = "T001865"; 

    // Initialisation du traité de rattachement pour LVR 2 (temporaire)
    if ((strcmp(ptb_InRec_Cur[PER_SSD_CF],"6") == 0)    &&
        (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT],"O") == 0) )
        ptb_InRec_Cur[PER_ESTCTR_NF] = "       "; */

    /* Si la devise principale fait partie des devises IN, on la remplace par EUR 
	   - pour qu'ensuite dans ESTC2035, on ne remplace pas l'ancien montant estime
	   provenant de TLIFEST en EURO par un nouveau montant en devise IN
	   - pour qu'ensuite dans ESTC2034, lorsqu'on remplace l'estimation par de la compta 
	     en devise IN, on convertisse bien en devise principale ( donc EUR). 
	     car on se refere dans les 2 cas à la devise principale.
	----------------------------------------------------------------------------*/
	if ( (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"BEF") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"DEM") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"GRD") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"ESP") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"FRF") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"IEP") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"ITL") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"LUF") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"NLG") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"ATS") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"PTE") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"FIM") == 0 ) ||
         (strcmp(ptb_InRec_Cur[PER_PCPCUR_CF],"XEU") == 0 ) )
        strcpy(ptb_InRec_Cur[PER_PCPCUR_CF],"EUR");

    // Reconduire le perimetre
    n_WriteCols(Kp_PeriOutFil,ptb_InRec_Cur,SEPARATEUR,0);

  RETURN_VAL(OK);
}    


 
