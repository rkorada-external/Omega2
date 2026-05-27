/*==============================================================================
nom de l'application          : MAJ Flag compte complet pour les Traité non criblés
nom du source                 : ESTC2050.c
revision                      : 
date de creation              : 24/03/2015
auteur                        : S. Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :   Mise à jour du flag compte complet dans FLIFDRI pour les traités non criblés
                Prend en entrée un fichier GT
                Ecrit en sortie un fichier binaire LIFDRI
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
 28/03/2015	    SBE			Création : Spot 28585
 [001] 26/10/2015 M.MECHRI :spot:29574 Modification de condition de rupture.
 [002] 07/06/2016 SBE :spot:30300 EST39 
 [038] 12/02/2019 S.Behague     :REQ.L.02.05: Evolution quarterly
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

#define GT_ACM_NF 74

/* Variables de travail */
FILE       *Kp_PilotIFil,                   // Pointeur sur le fichier pilotage en entree
           *Kp_PilotOFil,                   // Pointeur sur le fichier pilotage en sortie
           *Kp_AscPilotOFil;                // Pointeur sur le fichier Ascii

T_LIFDRI_ALL_QUARTER    Kbd_PILOTD[NB_MAX_PILOT];    // Fichier pilotage charge en memoire
int             Kn_NbLigPilot,              // Nombre de lignes dans le fichier pilotage
                Kn_SyncPilot,               // =-1 si le fichier pilotage n'est pas synchronise,
                ksz_indexPilot = 0;         // Index pour RechPilot5000

T_RUPTURE_VAR   bd_RuptGTPere;              // gestion rupture sur GT

char Ksz_DateJour[11];           				// Date de traitement
int  Kn_BalYear,
     Kn_BalMonth;
     
char Ksz_Balshey[6],
     Ksz_Balshtmth[6];

T_LIFDRI_ALL_QUARTER    *Kpbd_CPPILOT=NULL;	        // Tableau des complement PILOT
int             Kn_NbLigCPPilot=0;          // nombre de complement PILOT


// Fonctions de synchronisation
int n_InitGT (T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1GT (char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionLastRuptGT ( char **ptb_InRec_Cur);

// Fonctions utilitaires
int n_AddCPLIFDRI(T_LIFDRI_ALL_QUARTER *pbd_new) ;
int n_EcrireCPLLIFDRI();
int n_EcrireASCCPLLIFDRI();

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    // Initialisation des signaux
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )                                 ExitPgm ( ERR_XX , "" );

    // Recuperation des parametres
    strcpy(Ksz_DateJour, psz_GetCharArgv(1));
    strcpy(Ksz_Balshey,  psz_GetCharArgv(2));
    strcpy(Ksz_Balshtmth, psz_GetCharArgv(3));
  
    Kn_BalYear  = atoi(Ksz_Balshey);
    Kn_BalMonth = atoi(Ksz_Balshtmth);

    // ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2050_I2","rb",&Kp_PilotIFil) == ERR )        ExitPgm ( ERR_XX , "" );

    if ( n_OpenFileAppl ("ESTC2050_O1","wb",&Kp_PilotOFil) == ERR )        ExitPgm ( ERR_XX , "" );
        
    if ( n_OpenFileAppl ("ESTC2050_O2","wb",&Kp_AscPilotOFil) == ERR )        ExitPgm ( ERR_XX , "" );
    // Chargement Fichier LIFDRI
    if ( n_ChargerPilot7000(Kp_PilotIFil) == -1 )
		ExitPgm ( ERR_XX , "" ); 

    // Initialisation de la varible bd_RuptGT
    if ( n_InitGT(&bd_RuptGTPere) )                                        ExitPgm ( ERR_XX , "" );

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptGTPere) == ERR )                  ExitPgm ( ERR_XX , "" );

    n_EcrireASCCPLLIFDRI();
    // Ecriture de LIFDRI + le complement en binaire
    n_EcrireCPLLIFDRI();

    if (n_CloseFileAppl ("ESTC2050_I2",&Kp_PilotIFil))                     ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2050_O1",&Kp_PilotOFil))                     ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2050_O2",&Kp_AscPilotOFil))                  ExitPgm ( ERR_XX , "" );
    if ( n_EndPgm () == ERR )                                              ExitPgm ( ERR_XX , "" );

    exit(0) ;
}
/*************** Fin Main ****************/

/*============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier GT
retour :    0
============================================================================================*/
int n_InitGT (T_RUPTURE_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitGT");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2050_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 1;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;
    pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptGT;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);	
}

/*==============================================================================
objet :     fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1GT");
	
	if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)           		RETURN_VAL(1);
	if (strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF])!=0)           		RETURN_VAL(1);
    // [001]
	if (strcmp(ptb_InRec[GT_ACY_NF],ptb_InRec_Cur[GT_ACY_NF])!=0)           		RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_ACM_NF],ptb_InRec_Cur[GT_ACM_NF])!=0)       RETURN_VAL(1);


	RETURN_VAL (0);
}

/*==============================================================================
objet :     Fonction lancee a chaque rupture derniere sur contrat/sec/uwy/ACY
==============================================================================*/
int n_ActionLastRuptGT ( char **ptb_InRec_Cur)
{
    T_LIFDRI_ALL_QUARTER bd_new;
    char sz_new_cre[20];
    
	DEBUT_FCT("n_ActionLastRuptGT");

    Kn_SyncPilot = -1;
    
    if ( strcmp(ptb_InRec_Cur[GT_ESTCRB_CT],"N") == 0 && strcmp(ptb_InRec_Cur[GT_COMACC_B],"1") == 0 )
    {
        Kn_SyncPilot = n_RechPilot7000 ( ptb_InRec_Cur,GT_CTR_NF ,GT_SEC_NF, GT_ACY_NF, GT_ACM_NF, &ksz_indexPilot);
        bd_new=Kbd_PILOTD[Kn_SyncPilot];
        
        if ( Kn_SyncPilot >= 0 )
        {
            bd_new=Kbd_PILOTD[Kn_SyncPilot];
            sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:10");
            
            if (bd_new.COMACC_B != 1)
            {
                bd_new.COMACC_B=1;
                bd_new.UPD_NF='U';
                strcpy(bd_new.CRE_D,sz_new_cre);
                bd_new.BALSHEY_NF=Kn_BalYear;
                bd_new.BALSHTMTH_NF=Kn_BalMonth;
			    strcpy(bd_new.CREUSR_CF, "dbo");
		        strcpy(bd_new.LSTUPDUSR_CF, "dbo");
                strcpy(bd_new.LSTUPD_D, sz_new_cre);
                n_AddCPLIFDRI(&bd_new);
            }
        }
        else    // Sinon, creation de toute piece de l'enregistrement 
        {
            sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:10");
            bd_new.UPD_NF='I';
            sprintf(bd_new.CTR_NF,"%.9s",ptb_InRec_Cur[GT_CTR_NF]);
            bd_new.END_NT=atoi(ptb_InRec_Cur[GT_END_NT]);
            bd_new.SEC_NF=atoi(ptb_InRec_Cur[GT_SEC_NF]);
            bd_new.UWY_NF=atoi(ptb_InRec_Cur[GT_ACY_NF]);
            bd_new.UW_NT=atoi(ptb_InRec_Cur[GT_UW_NT]);
            bd_new.ACY_NF=atoi(ptb_InRec_Cur[GT_ACY_NF]);
            bd_new.SSD_CF=atoi(ptb_InRec_Cur[GT_SSD_CF]);
            bd_new.ACM_NF=atoi(ptb_InRec_Cur[GT_ACM_NF]);
            bd_new.BALSHEY_NF=Kn_BalYear;
            bd_new.BALSHTMTH_NF=Kn_BalMonth;
            bd_new.AUTUPD_B=1;
            bd_new.COMACC_B=1;
            bd_new.SEGUPD_B=0;
            bd_new.PROPAG_RES_B=0;
            strcpy(bd_new.CRE_D,sz_new_cre);
            bd_new.CMT_NT=0;          //  bd_new.CMT_NT=2;  JR  11/03/03 
            strcpy(bd_new.CREUSR_CF, "dbo");
            strcpy(bd_new.LSTUPDUSR_CF, "dbo");
            strcpy(bd_new.LSTUPD_D, sz_new_cre);
            n_AddCPLIFDRI(&bd_new);
        }            
    }
    
	RETURN_VAL(0);
}


/*=============================================================================
objet:
        ajoute une ligne dans le tableau Kpbd_CPPILOT et la remplie avec *pb_new
Parametre:
        la nouvelle ligne*pb_new
Retour:
        -> OK
=============================================================================*/

int n_AddCPLIFDRI(T_LIFDRI_ALL_QUARTER *pbd_new)
{
	int i;


	DEBUT_FCT("n_AddCPLIFDRI");
	for(i=0;i<Kn_NbLigCPPilot;i++)
	{
		if (strcmp(pbd_new->CTR_NF,Kpbd_CPPILOT[i].CTR_NF)==0 &&
			pbd_new->SEC_NF == Kpbd_CPPILOT[i].SEC_NF	  &&
			pbd_new->ACY_NF == Kpbd_CPPILOT[i].ACY_NF)

				RETURN_VAL(OK);
	}

	Kn_NbLigCPPilot++ ;
	Kpbd_CPPILOT = (T_LIFDRI_ALL_QUARTER *)realloc(Kpbd_CPPILOT,sizeof(T_LIFDRI_ALL_QUARTER)*Kn_NbLigCPPilot);
	Kpbd_CPPILOT[Kn_NbLigCPPilot-1]=*pbd_new ;

	RETURN_VAL(OK)	;

}


/*=============================================================================
objet:
        Ecrit le tableau lifdri(Kbd_PILOTD) et le tableau (Kpbd_CPPILOT) des
        complement dans le fichier de sortie binaire CPLIFDRI.

Retour:
        -> OK
=============================================================================*/
int n_EcrireCPLLIFDRI()
{
	DEBUT_FCT("n_EcrireCPLLIFDRI");

    fwrite(Kbd_PILOTD	,sizeof(T_LIFDRI_ALL_QUARTER),Kn_NbLigPilot		,Kp_PilotOFil);
    fwrite(Kpbd_CPPILOT	,sizeof(T_LIFDRI_ALL_QUARTER),Kn_NbLigCPPilot	,Kp_PilotOFil);

	if ( Kpbd_CPPILOT ) free(Kpbd_CPPILOT), Kpbd_CPPILOT=NULL;

	RETURN_VAL(OK)	;
}
/*=============================================================================
objet:
        Ecrit le tableau lifdri(Kbd_PILOTD) et le tableau (Kpbd_CPPILOT) des
        complement dans le fichier de sortie AASCII ASCCPLIFDRI.

Retour:
        -> OK
=============================================================================*/
int n_EcrireASCCPLLIFDRI()
{
    int i ;

    DEBUT_FCT("n_EcrireASCCPLLIFDRI");

    for(i=0;i<Kn_NbLigPilot;i++)
        fprintf(Kp_AscPilotOFil,
                "%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%d~%d~%s~%s~%s\n",
                Kbd_PILOTD[i].CTR_NF,
                (int)Kbd_PILOTD[i].END_NT,
                (int)Kbd_PILOTD[i].SEC_NF,
                (int)Kbd_PILOTD[i].UWY_NF,
                (int)Kbd_PILOTD[i].UW_NT,
                Kbd_PILOTD[i].CRE_D,
                (int)Kbd_PILOTD[i].BALSHEY_NF,
                (int)Kbd_PILOTD[i].BALSHTMTH_NF,
                (int)Kbd_PILOTD[i].ACY_NF,
                (int)Kbd_PILOTD[i].SSD_CF,
                (int)Kbd_PILOTD[i].AUTUPD_B,
                (int)Kbd_PILOTD[i].COMACC_B,
                (int)Kbd_PILOTD[i].SEGUPD_B,
                (int)Kbd_PILOTD[i].PROPAG_RES_B,
                (int)Kbd_PILOTD[i].CMT_NT,
                Kbd_PILOTD[i].CREUSR_CF,
                Kbd_PILOTD[i].LSTUPD_D,
                Kbd_PILOTD[i].LSTUPDUSR_CF);

    for(i=0;i<Kn_NbLigCPPilot;i++)
        fprintf(Kp_AscPilotOFil,
                "%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%d~%d~%s~%s~%s\n",
                Kpbd_CPPILOT[i].CTR_NF,
                (int)Kpbd_CPPILOT[i].END_NT,
                (int)Kpbd_CPPILOT[i].SEC_NF,
                (int)Kpbd_CPPILOT[i].UWY_NF,
                (int)Kpbd_CPPILOT[i].UW_NT,
                Kpbd_CPPILOT[i].CRE_D,
                (int)Kpbd_CPPILOT[i].BALSHEY_NF,
                (int)Kpbd_CPPILOT[i].BALSHTMTH_NF,
                (int)Kpbd_CPPILOT[i].ACY_NF,
                (int)Kpbd_CPPILOT[i].SSD_CF,
                (int)Kpbd_CPPILOT[i].AUTUPD_B,
                (int)Kpbd_CPPILOT[i].COMACC_B,
                (int)Kpbd_CPPILOT[i].SEGUPD_B,
                (int)Kpbd_CPPILOT[i].PROPAG_RES_B,
                (int)Kpbd_CPPILOT[i].CMT_NT,
                Kpbd_CPPILOT[i].CREUSR_CF,
                Kpbd_CPPILOT[i].LSTUPD_D,
                Kpbd_CPPILOT[i].LSTUPDUSR_CF);


    RETURN_VAL(OK);

}
