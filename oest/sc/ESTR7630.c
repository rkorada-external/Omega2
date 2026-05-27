/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Etat de balance technique
nom du source                 : ESTR2802.c
revision                      : $Revision: 1.2 $
date de creation              : 10/1997
auteur                        : KUHNA  (C.G.I.)
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Le fichier GT en partie simple est en entree
      Ne figurent dans ce fichier que les champs : filiale, etablissement
      annee bilan, poste comptable, monnaie acceptation, montant
      acceptation et retrocession. Il a ete prealablement mis sous cette forme.
      On lui a ajoute les lignes cumuls devant figurer sur l'etat.
      Il est sous format bcp (avec des separateurs).
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
/* Definition du code (stockes dans le poste comptable)
   identifiant les lignes cumuls */
#define CODE_PC_CUM_PC    "00000001"
#define CODE_PC_CUM_BIL   "00000002"
#define CODE_PC_CUM_ET    "00000003"
#define CODE_PC_CUM_FIL   "00000004"

/* Position de champs dans le GT simplifie converti */
#define GTSIMP_SSD_CF         0
#define GTSIMP_ESB_CF         1
#define GTSIMP_BALSHEY_NF     2
#define GTSIMP_TRNCOD_CF      3
#define GTSIMP_CUR_CF         4
#define GTSIMP_AMT_M          5
#define GTSIMP_RETAMT_M       6

/* Definition de codes masques pour l'edition */
#define MASQ_STRING	1 /* chaine */
#define MASQ_INT	2 /* int */
#define MASQ_MT		3 /* Masques de tous les montants pour
			     cette edition particuliere */
#define MASQ_CHAR	4 /* char */
#define MASQ_DAT	5 /* date */
#define MASQ_TOT_PC	6 /* libelle total poste comptable */
#define MASQ_TOT_BIL	7 /* libelle total bilan */
#define MASQ_TOT_ET	8 /* libelle total etablissement */
#define MASQ_TOT_FIL	9 /* libelle total filiale */

#define MT_MAX          999999999999999.999
#define NB_SSD_MAX      150	/*Nbre max de filiales*/

#define NB_COL_MAX_PAGE 200     /*Nbre max de colonnes dans une page*/
#define NB_LIGNE_MAX_PAGE 36   /*Nbre max de lignes dans une page*/

#define COL1	1
#define COL2    15
#define COL3    34
#define COL4	70

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
char    sz_Page[NB_LIGNE_MAX_PAGE  * (NB_COL_MAX_PAGE + 1) +2];

int	Kn_page=1,               /* Numero de page */
	Kn_ligne=1,              /* Numero de ligne */

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
                                /*    0 -> pas de rupture
                                      1 -> rupture */

T_LIB_SSD	Kbd_Lib[NB_SSD_MAX];	/* Libelles
		        	               (indice issu de Kpn_ind) */

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int n_InitEdit(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneEdit(char **ptb_InRec_Cur);
int n_ActionFirstRuptPage(char **ptb_InRec_Cur);
int n_ActionLastRuptPage(char **ptb_InRec_Cur);
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
  sz_Page[n_MaxLig*(n_MaxCol+1)+1] = 0 ;

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
  char *pc_Titre;

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
               strcpy(sz_Buff,"       xxxxxxxxxx");

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

			default  : ReformatDate('E',
						(char *) val,
						sz_Date);

		  }
		sprintf(sz_Buff, "%s",sz_Date);
		break ;

      case 6 :  /* libelle total Poste comptable */
              switch(c_Langue)
		  {
			case 'F' : strcpy(sz_Buff,"Total poste :");
				     break;

			default  : strcpy(sz_Buff,"Trans. Code Total:");
				     break;
		  }
		break ;

      case 7 :  /* libelle total bilan */
              switch(c_Langue)
		  {
			case 'F' : strcpy(sz_Buff,"Total bilan :");
				     break;

			default  : strcpy(sz_Buff,"Balance Sheet Total:");
				     break;
		  }
		break ;

      case 8 :  /* libelle total etablissement */
              switch(c_Langue)
		  {
			case 'F' : strcpy(sz_Buff,"Total etablissement :");
				     break;

			default  : strcpy(sz_Buff,"Subs. Ledger Total:");
				     break;
		  }
		break ;

      case 9 :  /* libelle total filiale */
              switch(c_Langue)
		  {
			case 'F' : strcpy(sz_Buff,"Total filiale :");
				     break;

			default  : strcpy(sz_Buff,"Susidiary Total:");
				     break;
		  }
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

  /* Ouverture du fichier en sortie */
  if (n_OpenFileAppl("ESTR7630_O1","wt",&Kp_OutFil) == ERR )
  ExitPgm ( ERR_XX , "" );

  /* Chargement des libelles */
  if (n_ChargLib() == ERR)
    exit(ERR);

  /* Traitement principal */
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX,"");

  /* fermeture des fichiers */
  if (n_CloseFileAppl("ESTR7630_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX,"");

  if (n_CloseFileAppl("ESTR7630_O1",&Kp_OutFil) == ERR)
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

  if (n_OpenFileAppl ("ESTR7630_I2","rt",&p_Libelle))
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
  if (n_CloseFileAppl("ESTR7630_I2",&p_Libelle) == ERR)
    RETURN_VAL(ERR);

  RETURN_VAL(OK);
}

/*=============================================================================
 objet: Initialisation Rupture : 1 rupture sur Page (la page est pleine)

=============================================================================*/
int n_InitEdit(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitEdit");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTR7630_I1","rt",&(pbd_Rupt->pf_InputFil)))
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
  char *pc_PC,                  /* Pointeur sur le poste comptable */
       sz_PCFormate[11];        /* PC formate = 2 espaces ajoutes */

  static char pc_OldPC[9] = {'\0'};  /* Chaine ou est stockee l'ancien PC */

  double d_MtOrig,d_MtConvert;   /* Montant monnaie origine et convertie */

  DEBUT_FCT("n_ActionLigneEdit");

                                   /* Init pointeur sur Poste comptable */
  pc_PC = ptb_InRec_Cur[GTSIMP_TRNCOD_CF];

                                   /* Conversion montant converti */
  d_MtConvert = atof(ptb_InRec_Cur[GTSIMP_RETAMT_M]);

  /* Traitement different si ligne cumul (PC, Annee bilan, Etablissement,
     filiale) ou ligne "normale" */
  if (strcmp(pc_PC,CODE_PC_CUM_PC) == 0)           /* ligne cumul PC */
    {
      n_Print_Cellule(sz_Page,Kn_ligne,COL3,0,MASQ_TOT_PC,Kc_Lang);
      n_Print_Cellule(sz_Page,Kn_ligne,COL4,&d_MtConvert,MASQ_MT,Kc_Lang);
      Kn_ligne ++;            /* saut de ligne */
    }
  else
    if (strcmp(pc_PC,CODE_PC_CUM_BIL) == 0)        /* ligne cumul bilan */
      {
        n_Print_Cellule(sz_Page,Kn_ligne,COL3,0,MASQ_TOT_BIL,Kc_Lang);
        n_Print_Cellule(sz_Page,Kn_ligne,COL4,&d_MtConvert,MASQ_MT,Kc_Lang);
      }
    else
      if (strcmp(pc_PC,CODE_PC_CUM_ET) == 0)     /* ligne cumul Etablissement */
        {
          n_Print_Cellule(sz_Page,Kn_ligne,COL3,0,MASQ_TOT_ET,Kc_Lang);
          n_Print_Cellule(sz_Page,Kn_ligne,COL4,&d_MtConvert,MASQ_MT,Kc_Lang);
        }
      else
        if (strcmp(pc_PC,CODE_PC_CUM_FIL) == 0)    /* ligne cumul filiale */
          {
            n_Print_Cellule(sz_Page,Kn_ligne,COL3,0,MASQ_TOT_FIL,Kc_Lang);
            n_Print_Cellule(sz_Page,Kn_ligne,COL4,&d_MtConvert,MASQ_MT,Kc_Lang);
          }
        else                                 /* ligne normale */
          {
                                             /* Conversion des montants */
            d_MtOrig = atof(ptb_InRec_Cur[GTSIMP_AMT_M]);

                                        /* si on change de poste comptable */
                                        /* On affiche le nouveau PC formate*/
            if (strcmp(pc_PC,pc_OldPC)  != 0)
              {
                                        /* Formatage PC */
		/* Modif par Mehdi le 07/08/1998 */
		if ( strlen( pc_PC ) < 7 )
			*sz_PCFormate = 0 ;
		else
		/* fin de la modif */
              	  sprintf(sz_PCFormate,"%.2s %.5s %s",
                        pc_PC,
                        pc_PC + 2,
                        pc_PC + 7);

                n_Print_Cellule(sz_Page,Kn_ligne,COL1,
                                sz_PCFormate,MASQ_STRING,' ');
              }
		                             /* Affichage Monnaie originale */
            n_Print_Cellule(sz_Page,Kn_ligne,COL2,
                            ptb_InRec_Cur[GTSIMP_CUR_CF],MASQ_STRING,' ');

		                       /* Affichage Mt Monnaie originale */
            n_Print_Cellule(sz_Page,Kn_ligne,COL3,
                                    &d_MtOrig,MASQ_MT,Kc_Lang);

		                       /* Affichage Mt Monnaie convertie */
            n_Print_Cellule(sz_Page,Kn_ligne,COL4,
                                    &d_MtConvert,MASQ_MT,Kc_Lang);

          }

  /* Le PC courant devient OldPC */
  strcpy(pc_OldPC,pc_PC);

  /* ligne suivante */
  Kn_ligne++;
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
  int ret;

  DEBUT_FCT("n_IsR1Page");
  Kc_NewSsd = 0;                  /* pas de rupture sur filiale */
                                  /* Rupture sur Filiale */
  ret = strcmp(ptb_InRec[GTSIMP_SSD_CF],ptb_InRec_Cur[GTSIMP_SSD_CF]);
  if (ret != 0)
    {
      Kc_NewSsd = 1;              /* Rupture sur fililale */
      return ret;
    }
                                 /* Etablissement */
  ret = strcmp(ptb_InRec[GTSIMP_ESB_CF],ptb_InRec_Cur[GTSIMP_ESB_CF]);
  if (ret != 0)
    return ret;
                                 /* Annee bilan */
  ret = strcmp(ptb_InRec[GTSIMP_BALSHEY_NF],ptb_InRec_Cur[GTSIMP_BALSHEY_NF]);
  if (ret != 0)
    return ret;
					/* Test rupture page pleine */
  if (Kn_ligne >= NB_LIGNE_MAX_PAGE)
    RETURN_VAL(1);

  RETURN_VAL (0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture premiere de niveau 1
        En rupture 1ere : stockage de l'entete page dans Page
==============================================================================*/
int n_ActionFirstRuptPage (char **ptb_InRec_Cur)
{
  int  n_SSD_CF,                    /* Filiale */
       n_indSsd;		    /* Indice libelle filiale */

  char c_Slash,
       sz_MoisSur2Pos[3],
       sz_FilSur2Pos[3];

  char *pc_LibSsd,			/* Libelle filiale */
       *pc_LibCur;                  /* Monnaie filiale */

  DEBUT_FCT("n_ActionFirstRuptPage");

  c_Slash = '/';

  /*Rafraichissement de la page, initialisation du numero de ligne*/
  n_CleanPage(sz_Page,NB_LIGNE_MAX_PAGE,NB_COL_MAX_PAGE);


  /* Initialisation libelle filiale, monnaie filiale, code langue */
  /* qui garderont cette valeur si  la fililale n'est pas trouvee */
  pc_LibSsd = "";
  pc_LibCur = "";
  Kc_Lang = ' ';

  /* Recherche filiale */
  n_SSD_CF = atoi(ptb_InRec_Cur[GTSIMP_SSD_CF]);

  /* Recherche indice pour cette filiale */
  n_indSsd = Kpn_ind[n_SSD_CF];
                                 /* Si filiale existe */
                                 /* Recherche de tous les libelles */
   if (n_indSsd>=0)
    {
      Kc_Lang   = Kbd_Lib[n_indSsd].LAG;
      pc_LibSsd = Kbd_Lib[n_indSsd].LIBSSD;
      pc_LibCur = Kbd_Lib[n_indSsd].LIBCUR;
    }


   /* La filiale est sur 2 positions avec 0 a gauche si necessaire */
   sprintf(sz_FilSur2Pos,"%.2d",n_SSD_CF);

   /* Le mois est sur 2 positions avec 0 a gauche si necessaire */
   sprintf(sz_MoisSur2Pos,"%.2d",Kn_Mois);

     					/* Stockage de l'entete dans Page */
  n_Print_Cellule(sz_Page,1,1,&Kc_Lang,MASQ_CHAR,' ');
  n_Print_Cellule(sz_Page,1,3,sz_FilSur2Pos,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,1,6,"1",MASQ_STRING,' ');

  n_Print_Cellule(sz_Page,2,1,Ksz_inv,MASQ_DAT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,12,Ksz_arr,MASQ_DAT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,23,Ksz_date,MASQ_DAT,Kc_Lang);

  n_Print_Cellule(sz_Page,2,34,sz_MoisSur2Pos,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,2,36,&c_Slash,MASQ_CHAR,' ');
  n_Print_Cellule(sz_Page,2,37,&Kn_Annee,MASQ_INT,' ');
  n_Print_Cellule(sz_Page,2,45,&Kn_page,MASQ_INT,' ');

  n_Print_Cellule(sz_Page,3,1,pc_LibSsd,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,3,26,ptb_InRec_Cur[GTSIMP_ESB_CF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,3,40,ptb_InRec_Cur[GTSIMP_BALSHEY_NF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,4,1,pc_LibCur,MASQ_STRING,' ');

  Kn_ligne += 5;

  RETURN_VAL(0);
}

/*===========================================================================
objet :
	Fonction lancee a chaque rupture derniere de niveau 1
	En rupture derniere :

			      Ecriture de la page dans fichier en sortie
===========================================================================*/
int n_ActionLastRuptPage (char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLastRuptPage");

   /* Ecriture dans fichier */
  n_PrintPage(Kp_OutFil,sz_Page,NB_LIGNE_MAX_PAGE,NB_COL_MAX_PAGE);
  fputc('\n',Kp_OutFil);
  fputc('\f',Kp_OutFil);

  /* Saut de page ou mise a 1 si rupture sur filiale */
  if (Kc_NewSsd == 1)
    Kn_page = 1;
  else
    Kn_page++;

  /* Initialisation ligne */
  Kn_ligne = 1;

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

   RETURN_VOID ();
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
    char sz_Mt[21],
         sz_MtEntier[21];

   char c_Virgule = '.';


  DEBUT_FCT("ReformatMontant");

                  /* valeur de la virgule varie en fct du code langue */
  if  (c_Lag == 'F') c_Virgule = ',';

			/* Formatage : mt sur 18 caracteres dont 3 decimales*/
                  /* + eventuellement le signe (si negatif) + virgule*/
  sprintf(sz_Mt,"%20.3lf",d_Mt);

			/* Ajout d'un espace tous les 3 chiffres
                     uniquement sur la partie non decimale du nombre*/
  sprintf(sz_MtEntier,
          "%.4s %.3s %.3s %.3s %.3s",
	  sz_Mt,&(sz_Mt[4]),&(sz_Mt[7]),
	  &(sz_Mt[10]),&(sz_Mt[13]));

			/* Ajout des separateurs '.' ou ',' si code
			   langue est respec. francais ou anglais
                     (toujours sur la partie entiere du nombre) */
  o_AjoutSeparateurMt(c_Lag,sz_MtEntier);

                  /* On reconstitue le nombre i.e; on lui recolle sa
                     partie decimale */
  sprintf(sz_MtFormate,"%.20s%c%s",
          sz_MtEntier,          /* partie entiere */
          c_Virgule,            /* virgule */
          &(sz_Mt[17]));        /* partie decimale */
 RETURN_VOID();
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
