/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Edition de l'etat des ecarts entre resultats
                                theoriques et comptables (a partir du fichier
                                des rapprochements)
nom du source                 : ESTR2301.c
revision                      : $Revision: 1.2 $
date de creation              : 09/1997
auteur                        : KUHNA  (C.G.I.)
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Le fichier des rapprochements auquel a et ajoute des lignes cumul
      est en entree. Il est sous format bcp (avec des separateurs).
      Ce programme va modifier le format afin de realiser une impression
      avec Starjet.

	Chacune des pages de l'edition est stockee dans un tableau de caracteres
	avant d'etre copiee dans le fichier de sortie.


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>


/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/* Code pour lignes de cumuls */
#define CODE_CTR_CUM_PSUP10    "1"
#define CODE_CTR_CUM_P         "2"
#define CODE_TOP_CUM_P         "C"      /*    "O" */
#define CODE_TOP_CUM_N         "B"      /*  "M" */
#define CODE_TOP_CUM_GLOB      "A"

/* Definition de codes masques pour l'edition */
#define MASQ_STRING		1 /* chaine */
#define MASQ_INT		2 /* int */
#define MASQ_MT		        3 /* Masques de tous les montants pour
			             cette edition particuliere */
#define MASQ_CHAR		4 /* char */
#define MASQ_DAT		5 /* date */

#define MT_MAX          999999999999.999
#define NB_SSD_MAX      150	/*Nbre max de filiales*/

#define NB_COL_MAX_PAGE 200     /*Nbre max de colonnes dans une page*/
#define NB_LIGNE_MAX_PAGE 30    /*Nbre max de lignes dans une page*/

#define COL1	1
#define COL2    25
#define COL3	50
#define COL4	55
#define COL5    75
#define COL6	95
#define COL7	115
#define COL8    135
#define COL9	155
#define COL10	175

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

typedef struct {
                  unsigned char SSD;
                  char          LAG;
	            char		LIBSSD[17];  /* Libelle Filiale */
		      char		LIBCUR[4];   /* Libelle monnaie */
	       } T_LIB_SSD;


/*----------------------*/
/* variables de travail */
/*----------------------*/

T_RUPTURE_VAR Kbd_Rupt;

FILE	*Kp_OutFil;		 /* Fichier en sortie */
				 /* Page a copier dans le fic en sortie */
char    sz_Page[NB_LIGNE_MAX_PAGE  * (NB_COL_MAX_PAGE + 1) +1];

int	Kn_page=1,               /* Numero de page */
	Kn_ligne=1,              /* Numero de ligne */
        Kn_NbLigne=0,              /* Nbre de lignes */

				 /* Tableau dont l'indice est la filiale et
                                    fournissant l'indice pour les libelles */
	Kpn_ind[NB_SSD_MAX],

	Kn_Annee,		 /* Annee et mois de la periode */
	Kn_Mois;

char	 Ksz_date[11],		/* Date du jour*/
	 Ksz_inv[11],		/* Libelle d'inventaire */
	 Ksz_arr[11],		/* Date d'arrete */
	 Kc_Lang;		/* Code langue */

unsigned char Kc_NewSsd;        /* Indicateur de rupture sur filiale */

T_LIB_SSD	Kbd_Lib[NB_SSD_MAX];	/* Libelles
		        	               (indice issu de Kpn_ind) */

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int n_InitEdit(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneEdit(char **ptb_InRec_Cur);
int n_ActionFirstRuptPage (char **ptb_InRec_Cur);
int n_ActionLastRuptPage (char **ptb_InRec_Cur);
int n_IsR1Page(char **ptb_InRec,char **ptb_InRec_Cur);


static int n_ChargLib();


void ReformatDate(char c_Lag,char sz_DateInput[9], char sz_DateOutput[11]);
void ReformatMontant(char c_Lag,double n_Mt, char *sz_Mt);
void o_AjoutSeparateurMt(char c_Lag,char *sz_MtFormate);
int n_Print_Cellule(char *sz_Page,int n_Lig,int n_col,void *val,int n_Masque,char c_Langue);
int n_PrintPage(FILE *pf,char *sz_Page,int n_MaxLig,int n_MaxCol);
int n_CleanPage(char *sz_Page,int n_MaxLig,int n_MaxCol);

/*==========================================================================
objet : Initialisation de la page : tous les caracteres sont mis a ' '
        sauf les fin de lignes qui valent '\n' (caractere de saut de ligne)

        La page a n_MaxLig lignes et n_MaxCol colonnes

retour 0
===========================================================================*/
int n_CleanPage(char *sz_Page,int n_MaxLig,int n_MaxCol)
{
  int i ;
  					/* Mise a blanc des caracteres */
  memset(sz_Page,' ',n_MaxLig*(n_MaxCol+1)+1) ;

					/* RC en fin de ligne */
  for(i=1; i < n_MaxLig; i++)
   sz_Page[i*(n_MaxCol+1)] = '\n';

  return 0 ;
}

/*==========================================================================
objet : Ecriture dans le fichier en sortie de la page (de n_MaxLig lignes
        et n_MaxCol colonnes)

retour 0
===========================================================================*/
int n_PrintPage( FILE *pf, char *sz_Page, int n_MaxLig, int n_MaxCol)
{
  fwrite(sz_Page,n_MaxLig*(n_MaxCol+1),1,pf) ;

  return 0 ;
}

/*==========================================================================
objet : Ecriture d'une cellule dans Page

retour 0
===========================================================================*/
int n_Print_Cellule(
  char *sz_Page,      /* Adresse du debut de page */
  int  n_Lig,	      /* Ligne ou on ecrit dans la page */
  int  n_col,         /* Colonne ou on ecrit dans la page */
  void *val ,         /* Pointeur sur la valeur a ecrire dans la page */
  int  n_Masque,      /* Masque d'edition */
  char c_Langue)      /* Langue */

{
  char *p, *p1;
  int i ;
  char sz_Buff[500],sz_Date[11];

  p = sz_Page ;

  /* Recherche de la ligne */
  for(i=1 ; i< (n_Lig) && p ; i++)
    {
      p1 = strchr(p, '\n');
      if (p1) p = p1 + 1 ;
    }

  /* Si la ligne n'existe pas on sort en ERR */
  if (!p) return 1 ;

  /* Formatage de la cellule */
  switch(n_Masque)
    {

	case 1 :  /* chaine */
		sprintf(sz_Buff, "%s",(char *)val );
		break ;

	case 2 :  /* int */
		sprintf(sz_Buff, "%ld",*(int *)val );
		break ;

	case 3 :   /* montant format %15.3lf (format de tous les montants) */
                                            /* On depasse du masque */

            if (   (*((double *)val) > MT_MAX)
                || (*((double *)val) < ((-1) * MT_MAX))   )
               strcpy(sz_Buff,"         xxxxxxxxxx");

                                          /* On refomate le nombre
                                             avant de le copier dans page */
            else
             {
		switch(c_Langue)
		  {
			case 'F' : ReformatMontant('F',
				        	   *((double *)val),
						   sz_Buff);
				   break;

			case 'E' : ReformatMontant('E',
						   *((double *)val),
						   sz_Buff);
				   break;

			default  : ReformatMontant('E',
						   *((double *)val),
						   sz_Buff);
		  }
             }
	   break ;

	case 4 :  /* char */
		sprintf(sz_Buff, "%c",*(char *)val );
		break ;

	case 5 :  /* Date */
		  switch(c_Langue)
		  {
			case 'F' : ReformatDate('F',
						(char *) val,
						sz_Date);
				   break;

			case 'E' : ReformatDate('E',
						(char *) val,
							sz_Date);
				   break;

			default  : ReformatDate('E',
						(char *) val,
						sz_Date);

		  }
		sprintf(sz_Buff, "%s",sz_Date);
		break ;
    }  /*fin case*/

  /* Ecriture dans la cellule */
  strncpy( p + n_col - 1 , sz_Buff, strlen(sz_Buff));

  return 0 ;
}


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

  /* Alimentation du nom en clair du programme */
  Gbd_Tech.psz_PgmLabel = "Edition ecart resultats";

  /* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm(argc,argv) == ERR)
    ExitPgm (ERR_XX , "");

  /* Recuperation du libelle d'inventaire */
  strcpy(Ksz_inv,psz_GetCharArgv(1));

  /* Recuperation de la date du jour */
  strcpy(Ksz_date,psz_GetCharArgv(2));

  /* Recuperation des annees et mois de la periode */
  Kn_Annee=n_GetIntArgv(3);
  Kn_Mois=n_GetIntArgv(4);

  /* Recuperation de la date d'arrete */
  strcpy(Ksz_arr,psz_GetCharArgv(5));

  n_InitEdit(&Kbd_Rupt);

  /* ouverture du fichier en sortie */
  if (n_OpenFileAppl("ESTR2301_O1","wt",&Kp_OutFil) == ERR )
  ExitPgm ( ERR_XX , "" );

  /* Chargement des libelles */
  if (n_ChargLib() == ERR)
    exit(ERR);

  /* Traitement principal */
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX,"");

  /* fermeture des fichiers */
  if (n_CloseFileAppl("ESTR2301_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX,"");

  if (n_CloseFileAppl("ESTR2301_O1",&Kp_OutFil) == ERR)
    ExitPgm (ERR_XX ,"");

  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "");

  exit(OK) ;
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBSID de la base BREF
   Sont extraits le libelle (court) filiale, le code langue, la monnaie filiale


retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static int n_ChargLib()
{
  T_LIB_SSD     bd_lu,art;
  FILE          *p_Libelle;

  int n_indice,i;
  unsigned char    c_Ssd;

  DEBUT_FCT ("n_ChargLib");

  /*Initialisation du tableau d'indices*/
  memset(Kpn_ind,-1,NB_SSD_MAX);

  /* Initialisation de l'indice courant */
  n_indice=0;

  if (n_OpenFileAppl ("ESTR2301_I2","rt",&p_Libelle))
    RETURN_VAL (ERR);

  for (;;)   /* pour tous les enregistrement du fichier des libelles */
    {
      if (   (fread(&bd_lu,sizeof(T_LIB_SSD),1,p_Libelle) != 1)
	  || (n_indice >= NB_SSD_MAX)  )
        break;

      /*Filiale courante*/
      c_Ssd = bd_lu.SSD;

      /* Stockage dans le tableau numero filiale */
      Kbd_Lib[n_indice].SSD = c_Ssd;

      /* Stockage des libelles */
      Kbd_Lib[n_indice].LAG = bd_lu.LAG;
      strcpy (Kbd_Lib[n_indice].LIBSSD,bd_lu.LIBSSD);
      strcpy (Kbd_Lib[n_indice].LIBCUR,bd_lu.LIBCUR);

      /* Stockage de l'indice dans le tableau "par filiale" */
      Kpn_ind[c_Ssd] = n_indice;

      /* Indice suivant */
      n_indice++;
  }

  /* Fermeture du fichier des libelles */
  if (n_CloseFileAppl("ESTR2301_I2",&p_Libelle) == ERR)
    RETURN_VAL(ERR);

  RETURN_VAL(OK);
}

/*=============================================================================
 objet: Initialisation Rupture : 1 rupture sur filiale/etablissement
        Chaque rupture correspond a l'edititon d'une page nouvelle
=============================================================================*/
int n_InitEdit(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitEdit");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTR2301_I1","rt",&(pbd_Rupt->pf_InputFil)))
  RETURN_VAL (ERR);

  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Page;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPage;
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPage;

  /* Fonction executee pour chaque ligne : */
  pbd_Rupt->n_ActionLigne = n_ActionLigneEdit;

  /* Separateur utilise dans le fichier en entree */
  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL (0);
}

/*=============================================================================
 objet: Action sur chacune des lignes  :
         - Affichage dans la Page
=============================================================================*/
int n_ActionLigneEdit(char **ptb_InRec_Cur)
{
 /**************************************************************/
  char sz_LibCur[4];
  int n_SSD_CF;
  int n_indSsd;/* Indice libelle filiale */


  /**************************************************************/

  int    n_ligne1,
         n_ligne2,      /* Kn_ligne + 2 */
         n_ligne3;      /* Kn_ligne + 3 */

  char sz_AffAcc[24],   /* Ct/Ex/No/av/No Acceptation */
       sz_AffRetro[24]; /* Ct/Ex/No/av/No Retro */
  char *pc_Ctr,*pc_Top;

  double   d_ACRES_M,
           d_THRES_M,
           d_AMT1_M,
           d_AMT2_M,
           d_AMT3_M,
           d_AMT4_M,
           d_AMT5_M,
           d_AMT6_M,
           d_AMT7_M,
           d_AMT8_M,
           d_AMT9_M,
           d_AMT10_M,
           d_AMT11_M,
           d_AMT12_M;

  DEBUT_FCT("n_ActionLigneEdit");
  n_SSD_CF= atoi(ptb_InRec_Cur[FRAPP_SSD_CF]);
  n_indSsd= Kpn_ind[n_SSD_CF];

  n_ligne1 = Kn_ligne;
  n_ligne2 = Kn_ligne + 2;
  n_ligne3 = Kn_ligne + 4;

					/* Conversions des montants */
  d_ACRES_M = atof(ptb_InRec_Cur[FRAPP_ACRES_M]);
  d_THRES_M = atof(ptb_InRec_Cur[FRAPP_THRES_M]);
  d_AMT1_M = atof(ptb_InRec_Cur[FRAPP_AMT1_M]);
  d_AMT2_M = atof(ptb_InRec_Cur[FRAPP_AMT2_M]);
  d_AMT3_M = atof(ptb_InRec_Cur[FRAPP_AMT3_M]);
  d_AMT4_M = atof(ptb_InRec_Cur[FRAPP_AMT4_M]);
  d_AMT5_M = atof(ptb_InRec_Cur[FRAPP_AMT5_M]);
  d_AMT6_M = atof(ptb_InRec_Cur[FRAPP_AMT6_M]);
  d_AMT7_M = atof(ptb_InRec_Cur[FRAPP_AMT7_M]);
  d_AMT8_M = atof(ptb_InRec_Cur[FRAPP_AMT8_M]);
  d_AMT9_M = atof(ptb_InRec_Cur[FRAPP_AMT9_M]);
  d_AMT10_M = atof(ptb_InRec_Cur[FRAPP_AMT10_M]);
  d_AMT11_M = atof(ptb_InRec_Cur[FRAPP_AMT11_M]);
  d_AMT12_M = atof(ptb_InRec_Cur[FRAPP_AMT12_M]);


  /* Initialisations */
  pc_Ctr = ptb_InRec_Cur[FRAPP_CTR_NF];
  pc_Top = ptb_InRec_Cur[FRAPP_RETNAT_CF];
  sz_AffRetro[0] = '\0';

  /* Affichage du contrat/ex... sauf si ligne cumul */

                                             /* si Cumul prop >= 10 */
  if (   (strcmp(pc_Ctr,CODE_CTR_CUM_PSUP10) == 0)
      && (strcmp(pc_Top,CODE_TOP_CUM_P)  == 0)  )
    if (Kc_Lang == 'F' )  /* message francais  */
     {
      sprintf(sz_AffAcc,"Cumul Prop >= 10");
      if(n_indSsd >=0)
      strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
     }
    else                                /* autre langue */
     {
      sprintf(sz_AffAcc,"Prop. Acc. >= 10");
      if(n_indSsd >=0)
      strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
     }
  else                                       /* sinon */
                                             /* si Cumul prop */
    if (   (strcmp(pc_Ctr,CODE_CTR_CUM_P) == 0)
        && (strcmp(pc_Top,CODE_TOP_CUM_P)  == 0)  )
      if (Kc_Lang == 'F' ) /* message francais */
        {
        sprintf(sz_AffAcc,"Cumul Prop");
        if(n_indSsd >=0)
        strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
        }
      else                                   /* autre langue */
        {
        sprintf(sz_AffAcc,"Prop. Acc.");
        if(n_indSsd >=0)
        strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
        }
    else                                     /* sinon */
      if (strcmp(pc_Top,CODE_TOP_CUM_N) == 0)     /* si cumul non prop */
       if (Kc_Lang == 'F' )/* message francais */
        {
        sprintf(sz_AffAcc,"Cumul Non Prop");
        if(n_indSsd >=0)
        strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
        }
        else                                 /* autre langue */
        {
        sprintf(sz_AffAcc,"Non-Prop. Acc.");
        if(n_indSsd >=0)
        strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
        }
      else                                   /* sinon */
        if (strcmp(pc_Top,CODE_TOP_CUM_GLOB) == 0)   /* si cumul global */
          if (Kc_Lang == 'F' )                /* message francais */
           {
            sprintf(sz_AffAcc,"Cumul Prop et Non Prop");
            if(n_indSsd >=0)
            strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
           }
          else                               /* autre langue */
           {
            sprintf(sz_AffAcc,"Prop. and Non-Prop. Acc.");
            if(n_indSsd >=0)
            strcpy(sz_LibCur, Kbd_Lib[n_indSsd].LIBCUR);
           }
        else                    /* Sinon : Ligne "normale" */
          {
				/* identificateur Accepation */
            sprintf(sz_AffAcc,"%s\\%.2d\\%.2d\\%s\\%.2d",
                    pc_Ctr,
                    atoi(ptb_InRec_Cur[FRAPP_END_NT]),
                    atoi(ptb_InRec_Cur[FRAPP_SEC_NF]),
                    ptb_InRec_Cur[FRAPP_UWY_NF],
                    atoi(ptb_InRec_Cur[FRAPP_UW_NT]));

				/* identificateur Retro */
           sprintf(sz_AffRetro,"%s\\%.2d\\%.2d\\%s\\%.2d",
                    ptb_InRec_Cur[FRAPP_RETCTR_NF],
                    atoi(ptb_InRec_Cur[FRAPP_RETEND_NT]),
                    atoi(ptb_InRec_Cur[FRAPP_RETSEC_NF]),
                    ptb_InRec_Cur[FRAPP_RTY_NF],
                    atoi(ptb_InRec_Cur[FRAPP_RETUW_NT]));

                       /*identificateur monnaie retro*/
           strcpy(sz_LibCur,ptb_InRec_Cur[FRAPP_RETCUR_CF]);

           }
				/* Affichage ligne : Affaire Acceptation */
  n_Print_Cellule(sz_Page,n_ligne1,COL1,sz_AffAcc,MASQ_STRING,' ');
				/* Affichage ligne : Affaire Acceptation */
  n_Print_Cellule(sz_Page,n_ligne1,COL2,sz_AffRetro,MASQ_STRING,' ');
				/* Affichage monnaie retro */
  n_Print_Cellule(sz_Page,n_ligne1,COL3,sz_LibCur,MASQ_STRING,' ');
    				/* Affichage ligne : RESULTATS */
  n_Print_Cellule(sz_Page,n_ligne1,COL4,&d_ACRES_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne2,COL4,&d_THRES_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne3,COL4,&d_AMT1_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne2,COL7,&d_AMT2_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne3,COL7,&d_AMT3_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne2,COL8,&d_AMT4_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne3,COL8,&d_AMT5_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne1,COL9,&d_AMT6_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne2,COL9,&d_AMT7_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne1,COL6,&d_AMT8_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne2,COL6,&d_AMT9_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne3,COL6,&d_AMT10_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne1,COL10,&d_AMT11_M,MASQ_MT,Kc_Lang);
  n_Print_Cellule(sz_Page,n_ligne1,COL5,&d_AMT12_M,MASQ_MT,Kc_Lang);

  Kn_ligne+=6;
  Kn_NbLigne ++;

  RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction de test de rupture du niveau 1

retour :
	0   ---> Pas de rupture
	1   ---> rupture
==============================================================================*/
int n_IsR1Page(char **ptb_InRec,char **ptb_InRec_Cur)
{

  DEBUT_FCT("n_IsR1Page");

  Kc_NewSsd = 0;        /*Indicateur de rupture sur fililale
                            0 -> pas de rupture
                            1 -> rupture */

  if (strcmp(ptb_InRec[FRAPP_SSD_CF],ptb_InRec_Cur[FRAPP_SSD_CF])!=0)
    {
      Kc_NewSsd = 1;
      RETURN_VAL(1);
    }

  if (strcmp(ptb_InRec[FRAPP_ESB_CF],ptb_InRec_Cur[FRAPP_ESB_CF])!=0)
    RETURN_VAL(1);

  /* plus de place sur la page */
  if (Kn_NbLigne == 3)
     RETURN_VAL(1);

  /* saut de page pour la feuille de cumul*/
  if (( strcmp(ptb_InRec[FRAPP_CTR_NF],CODE_CTR_CUM_PSUP10) == 0)
       && (strcmp(ptb_InRec[FRAPP_RETNAT_CF],CODE_TOP_CUM_P)  == 0)  )
   RETURN_VAL(1);


  RETURN_VAL (0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture premiere de niveau 1
        En rupture 1ere :  initialisation des cumuls
			   stockage de l'entete dans Page
==============================================================================*/
int n_ActionFirstRuptPage (char **ptb_InRec_Cur)
{
  int  n_SSD_CF,                    /* Filiale */
       n_indSsd;		    /* Indice libelle filiale */

  char c_Slash,
       sz_MoisSur2Pos[3],
       sz_FilSur2Pos[3];

  char *sz_LibSsd,			/* Libelle filiale */
       *sz_LibCur;		        /* Libelle monnaie */

  DEBUT_FCT("n_ActionFirstRuptPage");

  c_Slash = '/';

  /*Rafraichissement de la page, initialisation du numero de ligne*/
  n_CleanPage(sz_Page,NB_LIGNE_MAX_PAGE,NB_COL_MAX_PAGE);
  Kn_ligne = 1;

  /* Initialisation libelle filiale, monnaie filiale, code langue */
  /* qui garderont cette valeur si  la fililale n'est pas trouvee */
  sz_LibSsd = "";
  sz_LibCur = "";
  Kc_Lang = ' ';

  /* Recherche filiale */
  n_SSD_CF = atoi(ptb_InRec_Cur[FRAPP_SSD_CF]);


  /* Recherche indice pour cette filiale */
  n_indSsd = Kpn_ind[n_SSD_CF];
                                 /* Si filiale existe */
                                 /* Recherche de tous les libelles */
   if (n_indSsd>=0)
    {
      Kc_Lang   = Kbd_Lib[n_indSsd].LAG;
      sz_LibSsd = Kbd_Lib[n_indSsd].LIBSSD;
      sz_LibCur = Kbd_Lib[n_indSsd].LIBCUR;
    }


   /* La filiale est sur 2 positions avec 0 a gauche si necessaire */
   sprintf(sz_FilSur2Pos,"%.2d",n_SSD_CF);

   /* Le mois est sur 2 positions avec 0 a gauche si necessaire */
   sprintf(sz_MoisSur2Pos,"%.2d",Kn_Mois);

     					/* Stockage de l'entete dans Page */
  n_Print_Cellule(sz_Page,1,1,&Kc_Lang,MASQ_CHAR,Kc_Lang);
  n_Print_Cellule(sz_Page,1,3,sz_FilSur2Pos,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,1,6,"1",MASQ_STRING,' ');

  n_Print_Cellule(sz_Page,2,1,Ksz_inv,MASQ_DAT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,12,Ksz_arr,MASQ_DAT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,23,Ksz_date,MASQ_DAT,Kc_Lang);

  n_Print_Cellule(sz_Page,2,34,sz_MoisSur2Pos,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,2,36,&c_Slash,MASQ_CHAR,Kc_Lang);
  n_Print_Cellule(sz_Page,2,37,&Kn_Annee,MASQ_INT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,45,&Kn_page,MASQ_INT,Kc_Lang);

  n_Print_Cellule(sz_Page,3,1,sz_LibSsd,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,3,20,sz_LibCur,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,3,26,ptb_InRec_Cur[FRAPP_ESB_CF],MASQ_STRING,' ');

  Kn_ligne += 4;

  RETURN_VAL(0);
}

/*===========================================================================
objet :
	Fonction lancee a chaque rupture derniere de niveau 1
	En rupture derniere : Calcul des quotients de cumuls
			      Stockage du pied de page dans Page
			      Ecriture de la page dans fichier en sortie
===========================================================================*/
int n_ActionLastRuptPage (char **ptb_InRec_Cur)
{

  DEBUT_FCT("n_ActionLastRuptPage");

  Kn_NbLigne = 0;

  /* Ecriture dans fichier */
  n_PrintPage(Kp_OutFil,sz_Page,NB_LIGNE_MAX_PAGE,NB_COL_MAX_PAGE);
  fputc('\n',Kp_OutFil);
  fputc('\f',Kp_OutFil);

  /* Saut de page */
  if (Kc_NewSsd == 1)
    Kn_page = 1;
  else
    Kn_page++;

  RETURN_VAL(0);
}

/*=============================================================================
 objet:
	Genere en sortie une date formatee en fonction du code langue:
	jj/mm/aaaa si code langue=F
	mm/jj/aaaa sinon
 parametres:
	c_Lag	code langue
	sz_DateInput	date en entree, qui doit etre au format aaaammjj
	sz_DateOutput	date formatee en sortie
=============================================================================*/
void ReformatDate(char c_Lag,char sz_DateInput[9], char sz_DateOutput[11])
{
  DEBUT_FCT("ReformatDate");

  if (c_Lag=='F')
    {
      sz_DateOutput[0]=sz_DateInput[6];
      sz_DateOutput[1]=sz_DateInput[7];
      sz_DateOutput[3]=sz_DateInput[4];
      sz_DateOutput[4]=sz_DateInput[5];
    }
  else
    {
      sz_DateOutput[0]=sz_DateInput[4];
      sz_DateOutput[1]=sz_DateInput[5];
      sz_DateOutput[3]=sz_DateInput[6];
      sz_DateOutput[4]=sz_DateInput[7];
    }
      sz_DateOutput[2]='/';
      sz_DateOutput[5]='/';
      sz_DateOutput[6]=sz_DateInput[0];
      sz_DateOutput[7]=sz_DateInput[1];
      sz_DateOutput[8]=sz_DateInput[2];
      sz_DateOutput[9]=sz_DateInput[3];
      sz_DateOutput[10]=0;
}

/*=============================================================================
 objet:
  Genere en sortie un montant formate (double sur 15 positions sans decimales)
  en fonction du code langue:
	100.000.000 si code langue=F
	100,000,000 sinon
  parametres:
	c_Lag	        code langue
	d_Mt			montant en entree
	sz_MtFormat		montant formate en sortie
=============================================================================*/
void ReformatMontant(char c_Lag,double d_Mt, char *sz_MtFormate)
{
    char sz_Mt[18],
         sz_MtEntier[17];

   char c_Virgule = '.';


  DEBUT_FCT("ReformatMontant");

                  /* valeur de la virgule varie en fct du code langue */
  if  (c_Lag == 'F') c_Virgule = ',';

			/* Formatage : mt sur 15 caracteres dont 3 decimales*/
                  /* + eventuellement le signe (si negatif) + virgule*/
  sprintf(sz_Mt,"%17.3lf",d_Mt);

			/* Ajout d'un espace tous les 3 chiffres
                     uniquement sur la partie non decimale du nombre*/
  sprintf(sz_MtEntier,
          "%.4s %.3s %.3s %.3s",
	  sz_Mt,&(sz_Mt[4]),&(sz_Mt[7]),
	  &(sz_Mt[10]));

			/* Ajout des separateurs '.' ou ',' si code
			   langue est respec. francais ou anglais
                     (toujours sur la partie entiere du nombre) */
  o_AjoutSeparateurMt(c_Lag,sz_MtEntier);

                  /* On reconstitue le nombre i.e; on lui recolle sa
                     partie decimale */
  sprintf(sz_MtFormate,"%.16s%c%s",
          sz_MtEntier,          /* partie entiere */
          c_Virgule,            /* virgule */
          &(sz_Mt[14]));        /* partie decimale */
}

/*=============================================================================
 objet:
  Ajoute un separateur (point ou virgule en fonction du code langue) pour
  separer les milliers
  parametres:
	c_Lag	        	code langue
	sz_MtFormat		chaine en entree/sortie
=============================================================================*/
void o_AjoutSeparateurMt(char c_Lag,char *sz_MtFormate)
{
  char c_Separateur;
  int  n_ind;

  c_Separateur = (c_Lag == 'F') ? '.' : ',';

  /* Parcours du nombre de la droite vers la gauche et on remplace
     l'espace delimitant les groupes de 3 chiffres par un separateur si
     le nombre continue sur la gauche */
  for (n_ind = strlen(sz_MtFormate)-4 ; n_ind > 0 ; n_ind -= 4)
    {
      if (sz_MtFormate[n_ind-1] == '-')
            {
			  		/* On recolle le signe au nombre */
              sz_MtFormate[n_ind]   = '-';
              sz_MtFormate[n_ind-1] = ' ';
            }

      if ((sz_MtFormate[n_ind-1] >= '0') && (sz_MtFormate[n_ind-1] <= '9'))
        sz_MtFormate[n_ind] = c_Separateur;
    }
}
