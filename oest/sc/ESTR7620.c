/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Edition de l'etat synthetique de controle
			        d'inventaire retrocession
nom du source                 : ESTR7620.c
revision                      : $Revision: 1.2 $
date de creation              : 09/1997
auteur                        : KUHNA  (C.G.I.)
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Le fichier controle inventaire retrocession en entree est sous
      format bcp (avec des separateurs). Ce programme va modifier le
	format afin de realiser une impression avec Starjet.

	Chacune des pages de l'edition est stockee dans un tableau de caracteres
	avant d'etre copiee dans le fichier de sortie.


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    12/06/1998  Y.Bourdaillet prise en compte d une LOB = 98, Libelle indetermin
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>


/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/* Definition de codes masques pour l'edition */
#define MASQ_STRING		1 /* chaine */
#define MASQ_INT		2 /* int */
#define MASQ_MT		        3 /* Masques de tous les montants pour
			             cette edition particuliere */
#define MASQ_LONG		4 /* long */
#define MASQ_DOUBLE_19_3	5 /* double 19.3 */
#define MASQ_DOUBLE_10_8	6 /* double 10.8 */
#define MASQ_RATIO		7 /* Masques de tous les ratios pour
			             cette edition particuliere */
#define MASQ_RATIO_PB		8 /* Masques de tous les ratios
				     non calculables (div par 0) */
#define MASQ_CHAR		9 /* char */
#define MASQ_DAT		10 /* date */


#define ESB_MAX        "256"	/*Valeur max pour un etablissement */
#define LOB_MAX         "ZZ"	/*Valeur max pour une lob */

#define NB_SSD_MAX      100	/*Nbre max de filiales*/
#define NB_LOB_MAX      100	/*Nbre max de lob*/

#define NB_COL_MAX_PAGE 200     /*Nbre max de colonnes dans une page*/
#define NB_LIGNE_MAX_PAGE 30    /*Nbre max de lignes dans une page*/

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

typedef struct {
                  unsigned char SSD;
		  char          LOB[3];
                  char          LAG;
	          char		LIBSSD[17];  /* Libelle Filiale */
		  char		LIBCUR[4];   /* Libelle monnaie */
		  char		LIBLOB[17];  /* Libelle lob */
	       } T_LIB_SSD_LOB;


/*----------------------*/
/* variables de travail */
/*----------------------*/

T_UTCTLIB Kbd_utctlib;
T_RUPTURE_VAR Kbd_Rupt;

FILE	*Kp_OutFil;		 /* Fichier en sortie */
				 /* Page a copier dans le fic en sortie */
char    sz_Page[NB_LIGNE_MAX_PAGE  * (NB_COL_MAX_PAGE + 1) +1];

int	Kn_page=1,               /* Numero de page */
				 /* Tableau dont l'indice est la filiale et
                                    fournissant l'indice pour les libelles */
	Kpn_ind[NB_SSD_MAX * NB_LOB_MAX],

	Kn_Annee,		 /* Annee et mois de la periode */
	Kn_Mois;

double   Kd_Cum_AMT10000_M,	 /* Cumuls a editer en pied de page */
         Kd_Cum_AMT10030_M,
         Kd_Cum_PrimAc,
	 Kd_Cum_AMT10100_M,
	 Kd_Cum_AMT10200_M,
	 Kd_Cum_Particip,
	 Kd_Cum_ChargAc,
	 Kd_Cum_AMT20000_M,
	 Kd_Cum_ProvSin,
	 Kd_Cum_Sinistralite,
	 Kd_Cum_Resu;

char	 Ksz_date[11],		/* Date du jour*/
	 Ksz_inv[11],		/* Libelle d'inventaire */
	 Ksz_arr[11],		/* Date d'arrete */
	 Kc_Lang;		/* Code langue */

unsigned char Kc_NewSsd;        /* Indicateur de rupture sur filiale */

T_LIB_SSD_LOB	Kbd_Lib[NB_SSD_MAX * NB_LOB_MAX];	/* Libelles
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
void ReformatRatio(char c_Lag,double d_Mt, char *sz_MtFormate);
int n_RechercheIndiceLob(int n_indSsd,int n_SSD_CF,char *sz_LOB_CF);
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

	case 3 :   /* montant format %15.0lf (format de tous les montants
                      autres que les ratios)*/
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
		break ;

	case 4 :   /*long */
		sprintf(sz_Buff, "%ld", *((long *)val));
		break ;

	case 5 :   /*double 19.3 */
		sprintf(sz_Buff, "%19.3lf",  *((double *)val) );
		break ;

	case 6 :   /*double 10.8 */
		sprintf(sz_Buff, "%10.8lf",  *((double *)val)  );
		break ;

	case 7 :   /*montant double 3.2 (format pour tous les ratios)*/

                                       /* On depasse du masque */
                if (   (*((double *)val) > 999.99)
                    || (*((double *)val) < -999.99)   )
                  strcpy(sz_Buff,"xxxxxxx");

                else                   /* Sinon, on formate */
                {
		switch(c_Langue)
		  {
			case 'F' : ReformatRatio('F',
			        	         *((double *)val),
						 sz_Buff);
				   break;

			case 'E' : ReformatRatio('E',
					         *((double *)val),
					         sz_Buff);
				   break;

			default  : ReformatRatio('E',
					         *((double *)val),
					         sz_Buff);

		  }
                }
		break ;

	case 8 :  /* Ratios non calculables -> affichage de "xxx" */
		sprintf(sz_Buff, "%s","xxxxxxx");
		break ;

	case 9 :  /* char */
		sprintf(sz_Buff, "%c",*(char *)val );
		break ;

	case 10 :  /* Date */
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
  Gbd_Tech.psz_PgmLabel = "Edition Synthese";

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
  if (n_OpenFileAppl("ESTR7620_O1","wt",&Kp_OutFil) == ERR )
  ExitPgm ( ERR_XX , "" );

  /* Chargement des libelles */
  if (n_ChargLib() == ERR)
    exit(ERR);

  /* Traitement principal */
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX,"");

  /* fermeture des fichiers */
  if (n_CloseFileAppl("ESTR7620_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX,"");

  if (n_CloseFileAppl("ESTR7620_O1",&Kp_OutFil) == ERR)
    ExitPgm (ERR_XX ,"");

  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "");

  exit(OK) ;
}

/*==============================================================================
objet :
   fonction d'extraction des donnees des tables TSUBSID et TLOBH
   Sont extraits le libelle (court) filiale, le code langue, la monnaie filiale
   ainsi que le libelle (court) de la lob

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static int n_ChargLib()
{
  T_LIB_SSD_LOB bd_lu,art;
  FILE          *p_Libelle;

  int n_indice1,i=0;
  unsigned char    c_SsdPrec,
                   c_Ssd;

  DEBUT_FCT ("n_ChargLib");

  /*Initialisation du tableau d'indices*/
  memset(Kpn_ind,-1,NB_SSD_MAX);

  /* Initialisation de l'indice courant et de la filiale precedente */
  n_indice1=0,
  c_SsdPrec=-1;

  if (n_OpenFileAppl ("ESTR7620_I2","rt",&p_Libelle))
    RETURN_VAL (ERR);

  for (;;)   /* pour tous les enregistrement du fichier des libelles */
    {
      if (   (fread(&bd_lu,sizeof(T_LIB_SSD_LOB),1,p_Libelle) != 1)
	  || (n_indice1 >= NB_SSD_MAX * NB_LOB_MAX)  )
        break;

      /*Filiale courante*/
      c_Ssd = bd_lu.SSD;

      /* Stockage dans le tableau numeros filiale et lob*/
      Kbd_Lib[n_indice1].SSD = c_Ssd;
      strcpy(Kbd_Lib[n_indice1].LOB,bd_lu.LOB);

      /* Stockage des libelles */
      Kbd_Lib[n_indice1].LAG = bd_lu.LAG;
      strcpy (Kbd_Lib[n_indice1].LIBSSD,bd_lu.LIBSSD);
      strcpy (Kbd_Lib[n_indice1].LIBCUR,bd_lu.LIBCUR);
      strcpy (Kbd_Lib[n_indice1].LIBLOB,bd_lu.LIBLOB);

      /* Stockage de l'indice dans le tableau "par filiale"
         si nouvelle filiale */
      if (c_Ssd != c_SsdPrec)
        Kpn_ind[c_Ssd] = n_indice1;

      /* On conserve la filiale */
      c_SsdPrec = c_Ssd;

      /* Indice suivant */
      n_indice1++;
  }

  /* Fermeture du fichier des libelles */
  if (n_CloseFileAppl("ESTR7620_I2",&p_Libelle) == ERR)
    RETURN_VAL(ERR);

  RETURN_VAL(OK);
}

/*=============================================================================
 objet: Initialisation Rupture : 1 rupture sur filiale/etablissement/Lob
        Chaque rupture correspond a l'edititon d'une page nouvelle
=============================================================================*/
int n_InitEdit(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitEdit");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTR7620_I1","rt",&(pbd_Rupt->pf_InputFil)))
  RETURN_VAL (ERR);

  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Page;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPage;
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPage;

  /* Fonction executee pour chaque ligne : */
  pbd_Rupt->n_ActionLigne = n_ActionLigneEdit;

  /* Separateur utilise dans le fichier en entree */
  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL (0);
}

/*=============================================================================
 objet: Action sur chacune des lignes  :
         - Calcul des montants a afficher
         - Affichage dans la Page
         - Calcul des culmuls a afficher en pied de page
=============================================================================*/
int n_ActionLigneEdit(char **ptb_InRec_Cur)
{
  unsigned char c_PbRatio13,  /* Booleen indiquant edition erreur dans le
                             cas ou le denominateur des ratio 1 et 3 est nul
			         1 -> denominateur nul, 0 sinon */
                c_PbRatio245; /* Meme chose pour ratio 2,4 et 5 */

  int	   n_Num_Ligne;		/* Numero de la ligne de Page ou on ecrit */
  double   d_AMT10000_M,
	   d_AMT10030_M,
	   d_AMT10031_M,
	   d_AMT10100_M,
	   d_AMT10130_M,
	   d_AMT10200_M,
	   d_AMT10430_M,
	   d_AMT20000_M,
	   d_AMT20030_M,
	   d_AMT20031_M,
	   d_AMT22000_M,
	   d_AMT24030_M,
	   d_AMT24031_M,
	   d_PrimAc,
	   d_Particip,
	   d_ChargAc,
	   d_ProvSin,
	   d_Sinistralite,
	   d_Resu,
           d_Ratio1,
	   d_Ratio2,
	   d_Ratio3,
	   d_Ratio4,
	   d_Ratio5,
	   d_RatioComb;

  DEBUT_FCT("n_ActionLigneEdit");

  c_PbRatio13 = 0;            /* Initialisation  : Pas de probleme */
  c_PbRatio245 = 0;

  /*Calcul du numero de la ligne dans page ou vont etre copiees les cellules*/
  /* Ce numero depend de la nature (PROP, NPROP WK, NPROP CAT, FAC)*/

  n_Num_Ligne = 0;		/*Initialisation num ligne*/

  /* Choix du numero de ligne ou afficher en fonction de la nature du contrat*/
  switch (*ptb_InRec_Cur[SYNR_CTRNAT_CT])
	{
  	  case 'P' : n_Num_Ligne = 5;			/*Prop*/
		     break;

	  case 'N' : n_Num_Ligne = 9;			/*Non Prop*/
		     break;

	  case 'F' : n_Num_Ligne = 13;			/*Fac*/
		     break;

	  case 'C' : n_Num_Ligne = 17;			/*Couverture*/
		     break;

	  case 'X' : n_Num_Ligne = 21;			/*Non Affecte*/
		     break;
	}

  if (n_Num_Ligne != 0)
					/* Conversions des montants */
    {
      d_AMT10000_M = atof(ptb_InRec_Cur[SYNR_AMT10000_M]) / 1000 ;
      d_AMT10030_M = atof(ptb_InRec_Cur[SYNR_AMT10030_M]) / 1000 ;
      d_AMT10031_M = atof(ptb_InRec_Cur[SYNR_AMT10031_M]) / 1000 ;
      d_AMT10100_M = atof(ptb_InRec_Cur[SYNR_AMT10100_M]) / 1000 ;
      d_AMT10130_M = atof(ptb_InRec_Cur[SYNR_AMT10130_M]) / 1000 ;
      d_AMT10200_M = atof(ptb_InRec_Cur[SYNR_AMT10200_M]) / 1000 ;
      d_AMT10430_M = atof(ptb_InRec_Cur[SYNR_AMT10430_M]) / 1000 ;

      d_AMT20000_M = atof(ptb_InRec_Cur[SYNR_AMT20000_M]) / 1000 ;
      d_AMT20030_M = atof(ptb_InRec_Cur[SYNR_AMT20030_M]) / 1000 ;
      d_AMT20031_M = atof(ptb_InRec_Cur[SYNR_AMT20031_M]) / 1000 ;
      d_AMT22000_M = atof(ptb_InRec_Cur[SYNR_AMT22000_M]) / 1000 ;
      d_AMT24030_M = atof(ptb_InRec_Cur[SYNR_AMT24030_M]) / 1000 ;
      d_AMT24031_M = atof(ptb_InRec_Cur[SYNR_AMT24031_M]) / 1000 ;


				     /*Calcul des montants a afficher*/
      d_PrimAc =  d_AMT10000_M
 	        + d_AMT10030_M
		+ d_AMT10031_M;


      d_Particip =  d_AMT22000_M;

      d_ChargAc =   d_AMT10100_M
		  + d_AMT10200_M
		  + d_Particip
		  + d_AMT10130_M
		  + d_AMT10430_M;

      d_ProvSin =   d_AMT20030_M
		  + d_AMT24030_M;

      d_Sinistralite =  d_AMT20000_M
		      + d_ProvSin
		      + d_AMT20031_M
		      + d_AMT24031_M;

      d_Resu = d_PrimAc + d_ChargAc + d_Sinistralite;

				     /*Calcul des ratios*/
      if (d_AMT10000_M != 0)
        {
          d_Ratio1 = (d_AMT10030_M) / (d_AMT10000_M);
          d_Ratio3 = (d_ProvSin) / (d_AMT10000_M);
        }
      else c_PbRatio13 = 1;         /* Pb : division par 0 */

      if (d_PrimAc != 0)
        {
          d_Ratio2 = (d_ChargAc) / (d_PrimAc);
          d_Ratio4 = (d_Sinistralite) / (d_PrimAc);
          d_Ratio5 = (d_Resu) / (d_PrimAc);
          d_RatioComb = 1 - d_Ratio5;
        }
      else c_PbRatio245 = 1;       /* Pb : division par 0 */

				    /* Affichage 1ere ligne */
   n_Print_Cellule(sz_Page,n_Num_Ligne,1,&d_AMT10000_M,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne,25,&d_AMT10030_M,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne,50,&d_PrimAc,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne,85,&d_AMT10100_M,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne,110,&d_AMT10200_M,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne,135,&d_Particip,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne,160,&d_ChargAc,MASQ_MT,Kc_Lang);

				    /* Affichage 2eme ligne */
   n_Print_Cellule(sz_Page,n_Num_Ligne+2,1,&d_AMT20000_M,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne+2,25,&d_ProvSin,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne+2,50,&d_Sinistralite,MASQ_MT,Kc_Lang);
   n_Print_Cellule(sz_Page,n_Num_Ligne+2,110,&d_Resu,MASQ_MT,Kc_Lang);

				   /* Affichage Ratios 1 et 3*/
   if (c_PbRatio13 != 1)	   /* Affichage normal */
    {
       n_Print_Cellule(sz_Page,n_Num_Ligne,75,&d_Ratio1,MASQ_RATIO,Kc_Lang);
       n_Print_Cellule(sz_Page,n_Num_Ligne+2,75,&d_Ratio3,MASQ_RATIO,Kc_Lang);
    }
   else				   /* Affichage erreur */
    {
      n_Print_Cellule(sz_Page,n_Num_Ligne,75,&d_Ratio1,MASQ_RATIO_PB,Kc_Lang);
      n_Print_Cellule(sz_Page,n_Num_Ligne+2,75,&d_Ratio3,MASQ_RATIO_PB,Kc_Lang);
    }


				   /* Affichage Ratios 2,4 et 5*/
   if (c_PbRatio245 != 1)	   /* Affichage normal */
    {
    n_Print_Cellule(sz_Page,n_Num_Ligne,185,&d_Ratio2,MASQ_RATIO,Kc_Lang);
    n_Print_Cellule(sz_Page,n_Num_Ligne+2,95,&d_Ratio4,MASQ_RATIO,Kc_Lang);
    n_Print_Cellule(sz_Page,n_Num_Ligne+2,145,&d_Ratio5,MASQ_RATIO,Kc_Lang);
    n_Print_Cellule(sz_Page,n_Num_Ligne+2,170,&d_RatioComb,MASQ_RATIO,Kc_Lang);
    }
   else				  /* Affichage erreur */
    {
    n_Print_Cellule(sz_Page,n_Num_Ligne,185,&d_Ratio2,MASQ_RATIO_PB,Kc_Lang);
    n_Print_Cellule(sz_Page,n_Num_Ligne+2,95,&d_Ratio4,MASQ_RATIO_PB,Kc_Lang);
    n_Print_Cellule(sz_Page,n_Num_Ligne+2,145,&d_Ratio5,MASQ_RATIO_PB,Kc_Lang);
    n_Print_Cellule(sz_Page,n_Num_Ligne+2,170,&d_RatioComb,MASQ_RATIO_PB,Kc_Lang);
    }

			          /* Calcul cumuls : 1ere ligne */
      Kd_Cum_AMT10000_M += d_AMT10000_M;
      Kd_Cum_AMT10030_M += d_AMT10030_M;
      Kd_Cum_PrimAc += d_PrimAc;
      Kd_Cum_AMT10100_M += d_AMT10100_M;
      Kd_Cum_AMT10200_M += d_AMT10200_M;
      Kd_Cum_Particip += d_Particip;
      Kd_Cum_ChargAc += d_ChargAc;

			          /* Calcul cumuls : 2eme ligne */
      Kd_Cum_AMT20000_M += d_AMT20000_M;
      Kd_Cum_ProvSin += d_ProvSin;
      Kd_Cum_Sinistralite += d_Sinistralite;
      Kd_Cum_Resu += d_Resu;
    }

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

  if (strcmp(ptb_InRec[SYNR_SSD_CF],ptb_InRec_Cur[SYNR_SSD_CF])!=0)
    {
      Kc_NewSsd = 1;
      RETURN_VAL(1);
    }

  if (strcmp(ptb_InRec[SYNR_ESB_CF],ptb_InRec_Cur[SYNR_ESB_CF])!=0)
    RETURN_VAL(1);

  if (strcmp(ptb_InRec[SYNR_LOB_CF],ptb_InRec_Cur[SYNR_LOB_CF])!=0)
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
  int  n_SSD_CF	;			/* Filiale */
  char sz_LOB_CF[3];			/* Lob */

  int n_indSsd,				/* Indice libelle filiale */
      n_indLob;				/* Indice libelle lob */

  int n_Lob_A_Afficher,			/* Booleen si 1 -> libelle lob
					   a afficher 0 sinon*/
      n_Esb_A_Afficher;			/* Booleen si 1 -> libelle etablissement
					   a afficher, 0 sinon */
  char c_Slash,
       sz_MoisSur2Pos[3],
       sz_FilSur2Pos[3];

  char sz_LibSsd[17];			/* Libelle filiale */
  char sz_LibCur[4];			/* Libelle monnaie */
  char sz_LibLob[17];			/* Libelle lob */

  DEBUT_FCT("n_ActionFirstRuptPage");

  c_Slash = '/';
  Kc_Lang = ' ';

  /* Initialisation des Cumuls a editer en pied de page*/
  /* 1ere ligne */
  Kd_Cum_AMT10000_M = 0;
  Kd_Cum_AMT10030_M = 0;
  Kd_Cum_PrimAc = 0;
  Kd_Cum_AMT10100_M = 0;
  Kd_Cum_AMT10200_M = 0;
  Kd_Cum_Particip = 0;
  Kd_Cum_ChargAc = 0;

  /* 2eme ligne */
  Kd_Cum_AMT20000_M = 0;
  Kd_Cum_ProvSin = 0;
  Kd_Cum_Sinistralite = 0;
  Kd_Cum_Resu = 0;

  /* Lob (repec. etablissement)a afficher ssi on n'est pas sur une ligne
    de cumul toute lob (etablissement) confondue (lob = LOB_MAX)*/
  n_Lob_A_Afficher = strcmp(ptb_InRec_Cur[SYNR_LOB_CF],LOB_MAX);
  n_Esb_A_Afficher = strcmp(ptb_InRec_Cur[SYNR_ESB_CF],ESB_MAX);

  /*Rafraichissement de la page*/
  n_CleanPage(sz_Page,NB_LIGNE_MAX_PAGE,NB_COL_MAX_PAGE);

  /* Initialisation libelle filiale, monnaie filiale, lob, libelle lob*/
  /* qui garderont cette valeur si  la fililale n'est pas trouvee */
  strcpy(sz_LibSsd,"");
  strcpy(sz_LibCur,"");
  strcpy(sz_LibLob,"");
  strcpy(sz_LOB_CF,"");

  /* Recherche filiale */
  n_SSD_CF = atoi(ptb_InRec_Cur[SYNR_SSD_CF]);

  /* Recherche libelles filiale, langue et libelle monnaie */
  n_indSsd = Kpn_ind[n_SSD_CF];
                                 /* Si filiale existe */
                                 /* Recherche de tous les libelles */
  if (n_indSsd>=0)
    {
      Kc_Lang   = Kbd_Lib[n_indSsd].LAG;
      strcpy(sz_LibSsd,Kbd_Lib[n_indSsd].LIBSSD);
      strcpy(sz_LibCur,Kbd_Lib[n_indSsd].LIBCUR);

     /* Initialisation Lob (la filiale a ete identifiee)*/
     if (Kc_Lang == 'F')
       strcpy(sz_LibLob,"");
     else
       strcpy(sz_LibLob,"Unknown lob");

     /* Recherche lob et libelle lob*/
     if (n_Lob_A_Afficher != 0)
       {
         strcpy(sz_LOB_CF,ptb_InRec_Cur[SYNR_LOB_CF]);
         n_indLob = n_RechercheIndiceLob(n_indSsd,n_SSD_CF,sz_LOB_CF);
         if (n_indLob >= 0)
           strcpy(sz_LibLob,Kbd_Lib[n_indLob].LIBLOB);
       }
    }

  /* Le mois est sur 2 positions avec 0 a gauche si necessaire */
  sprintf(sz_MoisSur2Pos,"%.2d",Kn_Mois);

  /* La filiale est sur 2 positions avec 0 a gauche si necessaire */
  sprintf(sz_FilSur2Pos,"%.2d",n_SSD_CF);
					/* Stockage de l'entete dans Page */
  n_Print_Cellule(sz_Page,1,1,&Kc_Lang,MASQ_CHAR,Kc_Lang);
  n_Print_Cellule(sz_Page,1,3,sz_FilSur2Pos,MASQ_STRING,Kc_Lang);
  n_Print_Cellule(sz_Page,1,6,"1",MASQ_STRING,Kc_Lang);

  n_Print_Cellule(sz_Page,2,1,Ksz_inv,MASQ_DAT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,12,Ksz_arr,MASQ_DAT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,23,Ksz_date,MASQ_DAT,Kc_Lang);

  n_Print_Cellule(sz_Page,2,34,sz_MoisSur2Pos,MASQ_STRING,Kc_Lang);
  n_Print_Cellule(sz_Page,2,36,&c_Slash,MASQ_CHAR,Kc_Lang);
  n_Print_Cellule(sz_Page,2,37,&Kn_Annee,MASQ_INT,Kc_Lang);
  n_Print_Cellule(sz_Page,2,45,&Kn_page,MASQ_INT,Kc_Lang);

  n_Print_Cellule(sz_Page,3,1,sz_LibSsd,MASQ_STRING,Kc_Lang);
  n_Print_Cellule(sz_Page,3,20,sz_LibCur,MASQ_STRING,Kc_Lang);

  if (n_Esb_A_Afficher != 0)
    n_Print_Cellule(sz_Page,3,26,ptb_InRec_Cur[SYNR_ESB_CF],MASQ_STRING,Kc_Lang);

  if (n_Lob_A_Afficher != 0)
    if (strcmp(sz_LOB_CF , "98" ) != 0)
    {
      n_Print_Cellule(sz_Page,3,31,sz_LOB_CF,MASQ_STRING,Kc_Lang);
      n_Print_Cellule(sz_Page,3,36,sz_LibLob,MASQ_STRING,Kc_Lang);
    }
    else
      n_Print_Cellule(sz_Page,3,36,sz_LibLob,MASQ_STRING,Kc_Lang);


  RETURN_VAL(0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture derniere de niveau 1
	En rupture derniere : Calcul des quotients de cumuls
			      Stockage du pied de page dans Page
			      Ecriture de la page dans fichier en sortie
==============================================================================*/
int n_ActionLastRuptPage (char **ptb_InRec_Cur)
{
  unsigned char c_PbRatio13_Cum,  /* Booleen indiquant edition erreur dans le
                             cas ou le denominateur des ratio 1 et 3 est nul
			         1 -> denominateur nul, 0 sinon */
                c_PbRatio245_Cum; /* Meme chose pour ratio 2,4 et 5 */

  int    n_Num_Ligne;
  double d_Ratio1_Cum,
         d_Ratio2_Cum,
         d_Ratio3_Cum,
         d_Ratio4_Cum,
         d_Ratio5_Cum,
         d_RatioComb_Cum;

  DEBUT_FCT("n_ActionLastRuptPage");

  c_PbRatio13_Cum = 0;            /* Initialisation  : Pas de probleme */
  c_PbRatio245_Cum = 0;

				     /*Calcul des ratios de cumuls*/
      if (Kd_Cum_AMT10000_M != 0)
        {
          d_Ratio1_Cum = (Kd_Cum_AMT10030_M) / (Kd_Cum_AMT10000_M);
          d_Ratio3_Cum = (Kd_Cum_ProvSin) / (Kd_Cum_AMT10000_M);
        }
      else c_PbRatio13_Cum = 1;         /* Pb : division par 0 */

      if (Kd_Cum_PrimAc != 0)
        {
          d_Ratio2_Cum = (Kd_Cum_ChargAc) / (Kd_Cum_PrimAc);
          d_Ratio4_Cum = (Kd_Cum_Sinistralite) / (Kd_Cum_PrimAc);
          d_Ratio5_Cum = (Kd_Cum_Resu) / (Kd_Cum_PrimAc);
          d_RatioComb_Cum  = 1 - d_Ratio5_Cum ;
        }
      else c_PbRatio245_Cum = 1;       /* Pb : division par 0 */


  n_Num_Ligne = 26;

  /* Copie dans Page du pied de page compose
  des cumuls des montants colonnes ou des ratios de cumuls */
n_Print_Cellule(sz_Page,n_Num_Ligne,1,&Kd_Cum_AMT10000_M,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne,25,&Kd_Cum_AMT10030_M,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne,50,&Kd_Cum_PrimAc,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne,85,&Kd_Cum_AMT10100_M,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne,110,&Kd_Cum_AMT10200_M,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne,135,&Kd_Cum_Particip,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne,160,&Kd_Cum_ChargAc,MASQ_MT,Kc_Lang);

					    /* Affichage 2eme ligne */
n_Print_Cellule(sz_Page,n_Num_Ligne+2,1,&Kd_Cum_AMT20000_M,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,25,&Kd_Cum_ProvSin,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,50,&Kd_Cum_Sinistralite,MASQ_MT,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,110,&Kd_Cum_Resu,MASQ_MT,Kc_Lang);

				   /* Affichage Ratios Cumuls 1 et 3 */
if (c_PbRatio13_Cum != 1)	   /* Affichage normal */
{
n_Print_Cellule(sz_Page,n_Num_Ligne,75,&d_Ratio1_Cum,MASQ_RATIO,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,75,&d_Ratio3_Cum,MASQ_RATIO,Kc_Lang);
}
else				  /* Affichage Erreur */
{
n_Print_Cellule(sz_Page,n_Num_Ligne,75,&d_Ratio1_Cum,MASQ_RATIO_PB,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,75,&d_Ratio3_Cum,MASQ_RATIO_PB,Kc_Lang);
}
				   /* Affichage Ratios Cumuls 2,4 et 5*/
if (c_PbRatio245_Cum != 1)   	   /* Affichage normal */
{
n_Print_Cellule(sz_Page,n_Num_Ligne,185,&d_Ratio2_Cum,MASQ_RATIO,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,95,&d_Ratio4_Cum,MASQ_RATIO,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,145,&d_Ratio5_Cum,MASQ_RATIO,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,170,&d_RatioComb_Cum,MASQ_RATIO,Kc_Lang);
}
else				   /* Affichage Erreur */
{
n_Print_Cellule(sz_Page,n_Num_Ligne,185,&d_Ratio2_Cum,MASQ_RATIO_PB,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,95,&d_Ratio4_Cum,MASQ_RATIO_PB,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,145,&d_Ratio5_Cum,MASQ_RATIO_PB,Kc_Lang);
n_Print_Cellule(sz_Page,n_Num_Ligne+2,170,&d_RatioComb_Cum,MASQ_RATIO_PB,Kc_Lang);
}

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
void ReformatMontant(char c_Lag,double n_Mt, char *sz_MtFormate)
{
  char sz_Mt[17];

  DEBUT_FCT("ReformatMontant");

			/* Formatage : mt sans decimales sur 15 caracteres */
                        /* + eventuellement le signe (si negatif) */
  sprintf(sz_Mt,"%16.0lf",n_Mt);

			/* Ajout d'un espace tous les 3 chiffres */
  sprintf(sz_MtFormate,
          "%.4s %.3s %.3s %.3s %.3s",
	  sz_Mt,&(sz_Mt[4]),&(sz_Mt[7]),
	  &(sz_Mt[10]),&(sz_Mt[13]));

			/* Ajout des separateurs '.' ou ',' si code
			   langue est respec. francais ou anglais */
  o_AjoutSeparateurMt(c_Lag,sz_MtFormate);
}

/*=============================================================================
 objet:
  Genere en sortie un montant formate (double sur 5 positions dont 2 decimales)
  en fonction du code langue:
	8,23 si code langue=F
	8.23 sinon
  parametres:
	c_Lag	        	code langue
	d_Mt			montant en entree
	sz_MtFormat		montant formate en sortie
=============================================================================*/
void ReformatRatio(char c_Lag,double d_Mt, char *sz_MtFormate)
{
  char sz_Mt[8];
  char c_Virgule = '.';

  DEBUT_FCT("ReformatRatio");

  if  (c_Lag == 'F') c_Virgule = ',';

			/* Formatage : mt avec 2 decimales sur 7 caracteres
                             signe + 3 caracteres avant virgule
			   + 1 caractere pour la virgule + 2 decimales*/
  sprintf(sz_MtFormate,"%7.2lf",d_Mt);

  if (c_Virgule != '.')
    {
      strcpy(sz_Mt,sz_MtFormate);
      sprintf(sz_MtFormate,
              "%.4s%c%.2s",
   	      sz_Mt,c_Virgule,&(sz_Mt[5]));
    }
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
/*==========================================================================
objet : recherche dans le tableau des libelles l'indice de la ligne
        dont le numero de filiale est n_SSD_CF et dont le numero de
        LOB est sz_LOB_CF a partir de la ligne n_indSsd

retourne -1 si cette ligne n'a pas ete trouvee
==========================================================================*/
int n_RechercheIndiceLob(int n_indSsd,int n_SSD_CF,char *sz_LOB_CF)
{
  int n_ind;

  n_ind = n_indSsd;
  while (   (Kbd_Lib[n_ind].SSD == n_SSD_CF)
         && strcmp(Kbd_Lib[n_ind].LOB,sz_LOB_CF) < 0  )
    n_ind++;

  if (   (Kbd_Lib[n_ind].SSD == n_SSD_CF)
      && strcmp(Kbd_Lib[n_ind].LOB,sz_LOB_CF) == 0)
    return n_ind;
  else return -1;
}
