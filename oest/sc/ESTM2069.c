/*==============================================================================
 Nom de l'application          : OMEGA/Estimations
 Nom du source                 : ESTM2069.c
 Revision                      : $Revision: 1.9 $
 Date de creation              : 09/12/2008
 Auteur                        : J. Ribot
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Generation de lignes IFRS MGTA   SPOT16593
   on ecrit en sortie que les lignes generees annulation non IFRS et IFRS

------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
     04/03/09 - J. Ribot   SPOT16990 ajout parametre clodat_d pour la generation mvts IFRS
    05/11/2009  JF VDV     [18258] - Revoir le traitement de transformation des postes omega en postes IFRS
[003] 23/08/2012 R. Cassis :spot:24149 - Les mouvements générés sur mois suivant doivent avoir des attributs OneGL vides.
[004] 11/09/2012 R. Cassis :spot:24175 - Les mouvements générés sur mois suivant doivent avoir des attributs OneGL vides.
[005] 31/10/2014 ABJ    spot:25773  Modification du nombre de poste
[006] 09/05/2022 JYP    spira 104348 : gaap_code and product_code should be empty
[007] 09/07/2024 S.Behague    :spira 111624/111626 : IAS39- Revue mapping/IAS39 IFRS9 OMEGA Process within IFRS17 - Need for fine tuning
[008] 16/10/2024 S.Behague    :spira 112275 IAS39- Revue mapping - FWH LIC and LRC
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <estserv.h>
#include "struct.h"


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/

#include "ESTM2069.h"


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
char Ksz_Trncod2[3];    /* recherche trslnk sur 2 positions */
char Ksz_Trncod3[4];    /* recherche trslnk sur 3 positions */
char Ksz_Trncod4[5];    /* recherche trslnk sur 4 positions */     // [18258]
char Ksz_Trncod5[6];    /* recherche trslnk sur 5 positions */

char Ksz_CLODAT_D[9];        /* Date de libelle inventaire*/

char sz_an[5];
char sz_mois[3];
char sz_jour[3];

#define Kn_MaxPostes  50000    //[005]

char Ksz_vide[1];               /* Chaine vide pour initialisation */

char MsgAno[300];

T_TRSLNK Kbd_TRSLNK[Kn_MaxPostes];
T_TRSLNK Kbd_TRSLNK_IFRS[Kn_MaxPostes];
int Kn_NbLigTrslnk;
int Kn_NbLigTrslnk_IFRS;

int n_InitMGTA_SORT(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
T_RUPTURE_SYNC_VAR bd_RuptTrslnk; /* gestion synchro trslnk-perimetre */
int n_ChargerTRSLNK ();
int n_RechPoste(char *sz_poste);
int n_RechPoste_IFRS(char *sz_poste);
/*---------------------------------------------*/

/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  /* Initialisation des signaux */
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

 /* Recuperation du parametre correspondant a la date libelle inventaire*/
  strcpy(Ksz_CLODAT_D,psz_GetCharArgv(1));

			sz_an[4] = '\0';
			strncpy(sz_mois,Ksz_CLODAT_D+4,2);
			sz_mois[2] = '\0';
			strncpy(sz_jour,Ksz_CLODAT_D+6,2);
			sz_jour[2] = '\0';
			strncpy(sz_an,Ksz_CLODAT_D,4);

  /* Initialisation des variables de gestion de ruptures */
  if (n_InitIADVPERICASE(&Kbd_ruptIADVPERICASE)) ExitPgm(ERR_XX, "");
  if (n_InitMGTA_SORT(&Kbd_ruptMGTA_SORT)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTM2069_O1", "wt", &Kp_OutputFileMGTA) == ERR) ExitPgm(ERR_XX ,"");
  if (n_OpenFileAppl("ESTM2069_I3","rb",&Kp_TrslnkFil) == ERR ) ExitPgm ( ERR_XX , "" );

/* Chargement des postes en memoire (PRS_CF ==500 )*/
/* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
  if(n_ChargerTRSLNK () == ERR )
                  ExitPgm( ERR_XX , "" ) ;

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptIADVPERICASE) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTM2069_I1", &(Kbd_ruptIADVPERICASE.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTM2069_I2", &(Kbd_ruptMGTA_SORT.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTM2069_I3", &(Kp_TrslnkFil)) == ERR ) ExitPgm(ERR_XX, "" );

  if (n_CloseFileAppl("ESTM2069_O1", &Kp_OutputFileMGTA)) ExitPgm(ERR_XX, "");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

  exit(OK);
}


/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de rupture (Maitre)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitIADVPERICASE(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTM2069_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneIADVPERICASE;
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneIADVPERICASE(char **ptb_InRec_Cur)
{
  /* ... */

  /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptMGTA_SORT, ptb_InRec_Cur);

  return OK;
}


/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de synchronisation (Esclave)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_SYNC_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitMGTA_SORT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTM2069_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncMGTA_SORT;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncMGTA_SORT;

  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :
   Fonction de test de synchronisation avec la Maitre

 Parametre(s) :
   Pointeur sur la ligne du maitre
   Pointeur sur la ligne de l'esclave

 Retour :
   0 --> Pas de synchro
   1--> Situation de synchro
==============================================================================*/
int n_ConditionSyncMGTA_SORT(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	int ret;

	if ((ret = strcmp(ptb_InRecOwner[PER_CTR_NF], ptb_InRecChild[GT_CTR_NF])) != 0) return(ret);
	if ((ret = strcmp(ptb_InRecOwner[PER_END_NT], ptb_InRecChild[GT_END_NT])) != 0) return(ret);
	if ((ret = strcmp(ptb_InRecOwner[PER_SEC_NF], ptb_InRecChild[GT_SEC_NF])) != 0) return(ret);
	if ((ret = strcmp(ptb_InRecOwner[PER_UWY_NF], ptb_InRecChild[GT_UWY_NF])) != 0) return(ret);
	if ((ret = strcmp(ptb_InRecOwner[PER_UW_NT], ptb_InRecChild[GT_UW_NT])) != 0) return(ret);

	return 0;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne synchronisee avec le Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncMGTA_SORT(char **ptb_InRecOwner, char **ptb_InRecChild)
{

	char sz_trncod[9];
	char sz_trncod_b[9];
	double VAR_AMT;
	char sz_tmp[30];
	int i =0;
	int flag_trouve =0;
	char sz_gaap_code[11];
	char sz_prod_code[11];	
	

	DEBUT_FCT("n_ActionLigneSyncMGTA_SORT");

	/* Initialisation des parametres*/
	VAR_AMT= 0;
	strcpy(sz_gaap_code,"");
	strcpy(sz_prod_code,"");	
	memset(sz_trncod,0,sizeof(sz_trncod));
	strcpy(sz_trncod, ptb_InRecChild[GT_TRNCOD_CF]);
	memset(sz_trncod_b,0,sizeof(sz_trncod_b));
	strcpy(sz_trncod_b, ptb_InRecChild[GT_TRNCOD_CF]);

	if (atoi(ptb_InRecOwner[PER_ASSFINANCE_CT]) != 2 )
	{
		return OK;
	}

	// ---------------------------------------------------
	// Vérifie si on est déjà en IFRS, alors on fait rien:
	if (ptb_InRecChild[GT_TRNCOD_CF][1] < '0' || ptb_InRecChild[GT_TRNCOD_CF][1] > '9' )
	{
		return OK;
	}
	if (n_RechPoste_IFRS(ptb_InRecChild[GT_TRNCOD_CF])==1 )
	{
		return OK;
	}
	// ---------------------------------------------------

	ptb_InRecChild[GT_BALSHEY_NF] = sz_an ;
	ptb_InRecChild[GT_BALSHRMTH_NF] = sz_mois ;
	ptb_InRecChild[GT_BALSHRDAY_NF] = sz_jour ;

	if ((strncmp(ptb_InRecChild[GT_TRNCOD_CF] +7,"0",1)==0)  &&
	    (strncmp(ptb_InRecChild[GT_DBLTRNCOD_CF] +2,"80300",5)!=0))
	{
		sz_trncod[7]= '2';
		sz_trncod_b[7]= '2';
	}


	/* on ecrit en sortie que les lignes generees annulation non IFRS et IFRS   */

	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"1",1)==0)
	{
		sz_trncod_b[1]= 'Z';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"4",1)==0)
	{
		sz_trncod_b[1]= 'V';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"7",1)==0)
	{
		sz_trncod_b[1]= 'W';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"5",1)==0)
	{
		sz_trncod_b[1]= 'X';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"6",1)==0)
	{
		sz_trncod_b[1]= 'Y';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"9",1)==0)
	{
		sz_trncod_b[1]= 'U';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"2",1)==0)
	{
		sz_trncod_b[1]= 'M';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"3",1)==0)
	{
		sz_trncod_b[1]= 'F';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"8",1)==0)
	{
		sz_trncod_b[1]= 'N';
	}

	strncpy(sz_trncod_b +2,"82320",5);

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"2",1)==0)
	{
		strncpy(sz_trncod_b +2,"81620",5);
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"5",1)==0)
	{
		strncpy(sz_trncod_b +2,"81620",5);
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"8",1)==0)
	{
		strncpy(sz_trncod_b +2,"81620",5);
	}
	// Spira 111624 -----------------------------------------------------------------------------------------------------
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +2,"85100",5)==0 || strncmp(ptb_InRecChild[GT_TRNCOD_CF] +2,"85200",5)==0  )
	{
		strncpy(sz_trncod_b +2,"85130",5);
	}
	// Spira 111624 -----------------------------------------------------------------------------------------------------
	
 	ptb_InRecChild[GT_TRNCOD_CF]= sz_trncod_b;

	// [004]
	for (i=GT_BUKRS_CF;i<GT_TRN_NT;i++)
		ptb_InRecChild[i] = "";


    ptb_InRecChild[GT_GAAPCOD_NT] = sz_gaap_code;
    ptb_InRecChild[GT_I17PRDCOD_CT] = sz_prod_code;
	  
	/* ecriture de la ligne IFRS */
	n_WriteCols(Kp_OutputFileMGTA, ptb_InRecChild, '~', 0);


	/* Generation ecritures annulation non IFRS */

 	VAR_AMT= -atof(ptb_InRecChild[GT_AMT_M]);
 	sprintf(sz_tmp,"%-.3lf",VAR_AMT);
 	ptb_InRecChild[GT_AMT_M]= sz_tmp;
 	
 	ptb_InRecChild[GT_TRNCOD_CF]= sz_trncod;
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"1",1)==0)
	{
		sz_trncod[1]= 'Z';
	}

 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"4",1)==0)
	{
		sz_trncod[1]= 'V';
	}
 	
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"7",1)==0)
	{
		sz_trncod[1]= 'W';
	}
 	
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"5",1)==0)
	{
		sz_trncod[1]= 'X';
	}
 	
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"6",1)==0)
	{
		sz_trncod[1]= 'Y';
	}
 	
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"9",1)==0)
	{
		sz_trncod[1]= 'U';
	}
 	
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"2",1)==0)
	{
		sz_trncod[1]= 'M';
	}
 	
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"3",1)==0)
	{
		sz_trncod[1]= 'F';
	}
 	
 	if (strncmp(ptb_InRecChild[GT_TRNCOD_CF] +1,"8",1)==0)
	{
		sz_trncod[1]= 'N';
	}

	/* Synchronisation du fichier trslnk afin de recuperer DETTRS_CF */

	/* init du sz_trncod au cas ou non trouve dans tdettrs */
	/**  strncpy(sz_trncod +4,"000",3);                         en commentaire [18258]  **/

	flag_trouve = 0;
	Ksz_Trncod2[0] =  ptb_InRecChild[GT_TRNCOD_CF][2];
	Ksz_Trncod2[1] =  ptb_InRecChild[GT_TRNCOD_CF][3];

	Ksz_Trncod3[0] =  ptb_InRecChild[GT_TRNCOD_CF][2];
	Ksz_Trncod3[1] =  ptb_InRecChild[GT_TRNCOD_CF][3];
	Ksz_Trncod3[2] =  ptb_InRecChild[GT_TRNCOD_CF][4];

	Ksz_Trncod4[0] =  ptb_InRecChild[GT_TRNCOD_CF][2];        // [18258]
	Ksz_Trncod4[1] =  ptb_InRecChild[GT_TRNCOD_CF][3];        // [18258]
	Ksz_Trncod4[2] =  ptb_InRecChild[GT_TRNCOD_CF][4];        // [18258]
	Ksz_Trncod4[3] =  ptb_InRecChild[GT_TRNCOD_CF][5];        // [18258]

	Ksz_Trncod5[0] =  ptb_InRecChild[GT_TRNCOD_CF][2];
	Ksz_Trncod5[1] =  ptb_InRecChild[GT_TRNCOD_CF][3];
	Ksz_Trncod5[2] =  ptb_InRecChild[GT_TRNCOD_CF][4];
	Ksz_Trncod5[3] =  ptb_InRecChild[GT_TRNCOD_CF][5];
	Ksz_Trncod5[4] =  ptb_InRecChild[GT_TRNCOD_CF][6];

	i = n_RechPoste(Ksz_Trncod2);
	if (i!=-1)
	{
		sz_trncod[2]=Kbd_TRSLNK[i].DETTRS_CF[2];
		sz_trncod[3]=Kbd_TRSLNK[i].DETTRS_CF[3];
		sz_trncod[4]=Kbd_TRSLNK[i].DETTRS_CF[4];
		sz_trncod[5]=Kbd_TRSLNK[i].DETTRS_CF[5];
		sz_trncod[6]=Kbd_TRSLNK[i].DETTRS_CF[6];
		flag_trouve = 1;
	}
	
	i = n_RechPoste(Ksz_Trncod3);
	if (i!=-1)
	{
		sz_trncod[2]=Kbd_TRSLNK[i].DETTRS_CF[2];
		sz_trncod[3]=Kbd_TRSLNK[i].DETTRS_CF[3];
		sz_trncod[4]=Kbd_TRSLNK[i].DETTRS_CF[4];
		sz_trncod[5]=Kbd_TRSLNK[i].DETTRS_CF[5];
		sz_trncod[6]=Kbd_TRSLNK[i].DETTRS_CF[6];
		flag_trouve = 1;
	}

	i = n_RechPoste(Ksz_Trncod4);
	if (i!=-1)
	{
		sz_trncod[2]=Kbd_TRSLNK[i].DETTRS_CF[2];         // [18258]
		sz_trncod[3]=Kbd_TRSLNK[i].DETTRS_CF[3];         // [18258]
		sz_trncod[4]=Kbd_TRSLNK[i].DETTRS_CF[4];         // [18258]
		sz_trncod[5]=Kbd_TRSLNK[i].DETTRS_CF[5];         // [18258]
		sz_trncod[6]=Kbd_TRSLNK[i].DETTRS_CF[6];         // [18258]
		flag_trouve = 1;
	}
	
	i = n_RechPoste(Ksz_Trncod5);
	if (i!=-1)
	{
		sz_trncod[2]=Kbd_TRSLNK[i].DETTRS_CF[2];
		sz_trncod[3]=Kbd_TRSLNK[i].DETTRS_CF[3];
		sz_trncod[4]=Kbd_TRSLNK[i].DETTRS_CF[4];
		sz_trncod[5]=Kbd_TRSLNK[i].DETTRS_CF[5];
		sz_trncod[6]=Kbd_TRSLNK[i].DETTRS_CF[6];
		flag_trouve = 1;
	}

	ptb_InRecChild[GT_TRNCOD_CF]= sz_trncod;
	
	// Spira 111626 --------------------
	if (strncmp(Ksz_Trncod2, "15",2)==0)
	{
		sz_trncod[3]= '5';
	}
	if (strncmp(Ksz_Trncod2, "14",2)==0)
	{
		sz_trncod[3]= '4';
	}	
	// Spira 111626 --------------------
	
	// Spira 111624 -------------------------------------------------------------
	if (strncmp(Ksz_Trncod5, "85100",5)==0 || strncmp(Ksz_Trncod5, "85200",5)==0)
	{
		strncpy(sz_trncod +2,"85100",5);
	}
 	if (strncmp(Ksz_Trncod5, "80300",5)==0 )
	{
		strncpy(sz_trncod +2,"80300",5);
	}
	if (strncmp(Ksz_Trncod5, "80400",5)==0 )
	{
		strncpy(sz_trncod +2,"80400",5);
	}
	// Spira 111624 -------------------------------------------------------------

  // Spira 112275 -------------------------------------------------------------
	if (strncmp(Ksz_Trncod3, "814",3)==0 || strncmp(Ksz_Trncod3, "815",3)==0 )
	{
		sz_trncod[4]= '4';
	}	
  // Spira 112275 -------------------------------------------------------------

		if (flag_trouve == 0)
	{
		/* correspondance non trouve */
		sprintf(MsgAno,"correspondance non trouve (611 /TRNCOD_CF %s) dans TRSLNK",
		                ptb_InRecChild[GT_TRNCOD_CF]);
		n_WriteAno(MsgAno);
	}

	// [003]
	for (i=GT_BUKRS_CF;i<GT_TRN_NT;i++)
		ptb_InRecChild[i] = "";

	/* ecriture de la ligne annulation non IFRS */
	n_WriteCols(Kp_OutputFileMGTA, ptb_InRecChild, '~', 0);

	return OK;
}

/*==============================================================================
objet:
        Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK ()
{
	int n_EOF = 0;
	T_TRSLNK bd_Lu;
	char MsgAno[300];
	DEBUT_FCT("n_ChargerTRSLNK");
	
	Kn_NbLigTrslnk=0;
	Kn_NbLigTrslnk_IFRS=0;
	
	/* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		if (fread(&bd_Lu,sizeof(T_TRSLNK),1,Kp_TrslnkFil)<=0)
		        n_EOF = 1;
		else
		{
		
			if ( Kn_NbLigTrslnk + 1 >= Kn_MaxPostes )
			{
				/* depassement tableau */
				sprintf(MsgAno,"The number of link (/PRS %d /ACMTRS %d /DETTRS %s) overflows the program's storage capacity",
				                bd_Lu.PRS_CF,
				                bd_Lu.ACMTRS_NT,
				                bd_Lu.DETTRS_CF);
				n_WriteAno(MsgAno);
				RETURN_VAL(ERR);
			}
			else
			if ( Kn_NbLigTrslnk_IFRS + 1 >= Kn_MaxPostes )
			{
				/* depassement tableau */
				sprintf(MsgAno,"The number of link IFRS (/PRS %d /ACMTRS %d /DETTRS %s) overflows the program's storage capacity",
				                bd_Lu.PRS_CF,
				                bd_Lu.ACMTRS_NT,
				                bd_Lu.DETTRS_CF);
				n_WriteAno(MsgAno);
				RETURN_VAL(ERR);
			}
			
			else
			{
				if (bd_Lu.PRS_CF == 611)
				{
					/* Enregistrement ecrit dans le tableau */
					Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
				}
				
				if (bd_Lu.PRS_CF == 610 && bd_Lu.ACMTRS_NT == 100)
				{
					/* Enregistrement ecrit dans le tableau */
					if (bd_Lu.DETTRS_CF[1] >= '0' || bd_Lu.DETTRS_CF[1] <= '9' )
					Kbd_TRSLNK_IFRS[Kn_NbLigTrslnk_IFRS++] = bd_Lu;
				}
			}
		}
	}
	RETURN_VAL(OK);
 }


/*==============================================================================
objet :
        fonction de recherche du poste
retour :
        0       ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
	int n_indice, ret;
	char sz_ACMTRS[5];
	DEBUT_FCT("n_RechPoste");
	
	Ksz_vide[0]=0;
	n_indice=0;
	while (1==1)
	{
		/* Comparaison des codes */
		/** ret=strcmp(sz_poste,Kbd_TRSLNK[n_indice].DETTRS_CF);   en commmentaire [18258] */
		sprintf(sz_ACMTRS,"%d",(int)Kbd_TRSLNK[n_indice].ACMTRS_NT);  // [18258] ajout
		ret=strcmp(sz_poste,sz_ACMTRS);                               // [18258] ajout
	
		/* S'ils sont egaux, retourner l'indice */
		if (ret==0) RETURN_VAL(n_indice);
		
		/* Si la ligne est passee, retourner -1 (echec) */
		/* if (ret<0) RETURN_VAL(-1);     en commmentaire [18258] */
		
		/* Ligne suivante */
		n_indice++;
		
		/* Si on est a la fin du tableau, echec */
		if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
	}
}


/*==============================================================================
objet :
        fonction de recherche du poste
retour :
        0       ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste_IFRS(char *sz_poste)
{
	int i, is_IFRS=0;
	
	DEBUT_FCT("n_RechPoste_IFRS");
	
	for(i=0;i<Kn_NbLigTrslnk_IFRS;i++)
	{
		if(strcmp(sz_poste,Kbd_TRSLNK[i].DETTRS_CF)==0)
			is_IFRS=1;
	}
	
	return is_IFRS;
}


