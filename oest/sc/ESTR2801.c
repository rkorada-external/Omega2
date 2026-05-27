/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Edition des ecritures acceptation et retro
                                par acceptation
nom du source                 : ESTR2801.c
revision                      : $Revision:   1.0  $
date de creation              : 10/1997
auteur                        : KUHNA  (C.G.I.)
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Le fichier  GTAR par filiale est en entree
      Le but est de formater les donnees en vue de l'impression des
      ecritures acceptation et retros par acceptation.
      Le fichier est sous format bcp (avec des separateurs). 
      Ce programme va modifier le format afin de realiser une impression 
      avec Starjet.

      Chacune des pages de l'edition est stockee dans un tableau de caracteres
      avant d'etre copiee dans le fichier de sortie.
	

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
------------------------------------------------------------------------------
12/07/2013 Ashish Modified the code to fix warning for Phase1b
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
#define MASQ_CHAR		4 /* char */
#define MASQ_DAT		5 /* date */
#define MASQ_MT_G		6 /* montant cadre a gauche*/
#define MASQ_CONST_TOT_A	7 /* libelle total acc */
#define MASQ_CONST_TOT_R        8 /* libelle total retro */
#define MASQ_INT_G		9 /* int cadre a gauche*/		

#define MT_MAX          999999999999.999
/**#define ENT_MAX         2147483648 **/ /** Commented for Phase1b migration **/  /* 2^31   Modif M.NAJI 12/01/1998 */
#define ENT_MAX         2147483648u       /** Added for Phase1b miration  **/
#define LON_MAX         999999999999LL

#define MAX_NB_LIGNE_ED    11      /* Nbre de lignes-edition  max dans 1 page
                                   1 ligne-edition = 2 lignes dans page */ 

#define NB_SSD_MAX      150	/*Nbre max de filiales*/

#define NB_COL_MAX_PAGE 200     /*Nbre max de colonnes dans une page*/
#define NB_LIGNE_MAX_PAGE 30    /*Nbre max de lignes dans une page*/

                                /* Position de chaque colonne dans page */
#define COL1	1
#define COL2    15      
#define COL3	40
#define COL4	45
#define COL5    60    
#define COL6	65
#define COL6_BIS 68	
#define COL7	71
#define COL8    95         
#define COL9	110
#define COL10	125
#define COL11	140
#define COL12	155

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

typedef struct {
                  unsigned char SSD;         /* filiale */
                  char          LAG;         /* Langue filiale */
	          char		LIBSSD[17];  /* Libelle Filiale */
		  char		LIBCUR[4];   /* Libelle monnaie */
	       } T_LIB_SSD;


/*----------------------*/
/* variables de travail */
/*----------------------*/

T_RUPTURE_VAR Kbd_Rupt;          /* variable de rupture */

FILE	*Kp_OutFil;		 /* Fichier en sortie */
				 /* Page a alimenter et a copier 
                                    dans le fic en sortie */
char    sz_Page[NB_LIGNE_MAX_PAGE  * (NB_COL_MAX_PAGE + 1) +1];

int	Kn_page=1,               /* Numero de page */
	Kn_ligne=0,              /* Numero de ligne */
        Kn_NbLigne=0,            /* Nbre de lignes */

				 /* Tableau dont l'indice est la filiale et
                                    fournissant l'indice pour les libelles */
	Kpn_ind[NB_SSD_MAX],

	Kn_Annee,		 /* Annee et mois de la periode */
	Kn_Mois;

char	 Ksz_date[11],		/* Date du jour*/
	 Ksz_inv[11],		/* Libelle d'inventaire */
	 Ksz_arr[11],		/* Date d'arrete */
	 Kc_Lang;		/* Code langue */


unsigned char Kc_NewSsd ,       /* Indicateur de rupture sur filiale */
              Kc_PagePleine=0;  /* Indicateur page pleine sans "vraie" rupture
                                   sur filiale/Etablissement/Poste comptable
                                   Poste contre-partie/monnaie Acc et retro */

double Kd_CumA,                  /* Cumul montants acceptation */
       Kd_CumR;                  /* Cumul montants retro */

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

void ReformatDate(char c_Lag,char sz_DateInput[9], char sz_DateOutput[11]);
void ReformatMontant(char c_Lag,double n_Mt, char *sz_Mt);
void o_AjoutSeparateurMt(char c_Lag,char *sz_MtFormate);
int n_Print_Cellule(char *sz_Page,int n_Lig,int n_col,void *val,int n_Masque,char c_Langue);
int n_PrintPage(FILE *pf,char *sz_Page,int n_MaxLig,int n_MaxCol);
int n_CleanPage(char *sz_Page,int n_MaxLig,int n_MaxCol);
char *pc_CadreAGauche(char *sz_chaine);
static int n_ChargLib(void);

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
  char *pc_Titre, *pc_Tmp;

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
                if (   (*((int *)val) > ENT_MAX) 
                    || (*((int *)val) < ((-1) * ENT_MAX))   ) /* M.NAJI ce test est superflu pour les int */
                   strcpy(sz_Buff,"       xxxxxxxxxx"); 
                else
		   sprintf(sz_Buff, "%12ld",*(int *)val );
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

	case 6 :   /* total */
                   /* montant format %15.3lf (format de tous les montants) */
                   /* CADRE A GAUCHE */
            if (   (*((double *)val) > MT_MAX) 
                || (*((double *)val) < ((-1) * MT_MAX))   )
               strcpy(sz_Buff,"xxxxxxxxxx"); 

                                          /* On refomate le nombre 
                                             avant de le copier dans page */
            else
             {
		switch(c_Langue)           /* en fonction de la langue */
		  {
			case 'F' : ReformatMontant('F',
				        	   *((double *)val),
						   sz_Buff);
				   break;

			default  : ReformatMontant('E',
						   *((double *)val),
						   sz_Buff);
		  }
                                           /* Cadrage a gauche */
                pc_Tmp = pc_CadreAGauche(sz_Buff);
                strcpy(sz_Buff,pc_Tmp);
             }
	   break ;

	case 7 :  /* Libelle total acceptation */
		  switch(c_Langue) 
		  {
			case 'F' : strcpy(sz_Buff,"Total Acceptation : ");
				   break;

			default  : strcpy(sz_Buff,"Acceptance Total: ");
		  }
		break ;


	case 8 :  /* Libelle total retrocession */
		  switch(c_Langue) 
		  {
			case 'F' : strcpy(sz_Buff,"Total Retrocession : ");
				   break;

			default  : strcpy(sz_Buff,"Retrocession Total: ");
		  }
		break ;

	case 9 :  /* int cadre a gauche*/
		  sprintf(sz_Buff, "%ld",*(int *)val );
		  break ;
	case 10 :  /* long long */
                if (   (*((long long *)val) > LON_MAX) 
                    || (*((long long *)val) < ((-1LL) * LON_MAX))   )
                   strcpy(sz_Buff,"       xxxxxxxxxx"); 
                else
		   sprintf(sz_Buff, "%12ld",*(long *)val );
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
  if (n_OpenFileAppl("ESTR2801_O1","wt",&Kp_OutFil) == ERR )
  ExitPgm ( ERR_XX , "" );
  
  /* Chargement des libelles */
  if (n_ChargLib() == ERR)
    exit(ERR);

  /* Traitement principal */
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX,"");

  /* fermeture des fichiers */
  if (n_CloseFileAppl("ESTR2801_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX,"");

  if (n_CloseFileAppl("ESTR2801_O1",&Kp_OutFil) == ERR)
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
static int n_ChargLib(void)
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

  if (n_OpenFileAppl ("ESTR2801_I2","rt",&p_Libelle))
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
  if (n_CloseFileAppl("ESTR2801_I2",&p_Libelle) == ERR)
    RETURN_VAL(ERR);

  RETURN_VAL(OK);
}

/*=============================================================================
 objet: Initialisation Rupture : rupture sur chacun des elemnts de l'entete :
         filiale/etablissement/postes comptable et contre-partie/Monnaies
         acceptation et retrocession   -> "vraie" rupture
      + rupture si la page est pleine

        Chaque rupture correspond a l'edititon d'une page nouvelle 
=============================================================================*/
int n_InitEdit(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitEdit");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));
  
  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTR2801_I1","rt",&(pbd_Rupt->pf_InputFil)))
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
         - Affichage dans la Page d'une ligne-edition (=1 ligne acceptation +
           1 ligne retro)
         - cumul des montants
=============================================================================*/
int n_ActionLigneEdit(char **ptb_InRec_Cur)
{

  int    n_ligneA,      /* ligne Acceptation : 1ere ligne */
         n_ligneR;      /* ligne Retrocession : 2eme ligne */

  char sz_AffAcc[24],   /* Ct/Ex/No/av/No Acceptation */
       sz_AffRetro[24], /* Ct/Ex/No/av/No Retro */
       sz_DateBilan[9], /* Date bilan */
       sz_MoisDebPCSur2Pos[3],
       sz_MoisFinPCSur2Pos[3];

  double d_MtA,d_MtR;   /* Montant A/R*/
  int    n_NumSinA, 
         n_NumSinR, 
         n_NumCed,
         n_CodPlac,
         n_Retro,
         n_CourtierA,
         n_CourtierR ,
         n_PayeurA,
         n_PayeurR;


  DEBUT_FCT("n_ActionLigneEdit");
  n_ligneA = Kn_ligne;
  n_ligneR = Kn_ligne + 1;


                        /* Si contrat Acceptation renseigne */
  if (*(ptb_InRec_Cur[GT_CTR_NF]) != '\0')
  {
                        /* Composition du contrat/ex... A */
				/* identificateur Acceptation */
  sprintf(sz_AffAcc,"%s\\%.2d\\%.2d\\%s\\%.2d",
          ptb_InRec_Cur[GT_CTR_NF],
          atoi(ptb_InRec_Cur[GT_END_NT]),
          atoi(ptb_InRec_Cur[GT_SEC_NF]),
          ptb_InRec_Cur[GT_UWY_NF],
          atoi(ptb_InRec_Cur[GT_UW_NT]));

		                       /* Affichage ligne : Affaire A*/
  n_Print_Cellule(sz_Page,n_ligneA,COL2,sz_AffAcc,MASQ_STRING,' ');
  }


                        /* Si contrat Retro renseigne */
  if (*(ptb_InRec_Cur[GT_RETCTR_NF]) != '\0')
  {
                        /* Composition du contrat/ex... R */
			 /* identificateur Retro */
  sprintf(sz_AffRetro,"%s\\%.2d\\%.2d\\%s\\%.2d",
          ptb_InRec_Cur[GT_RETCTR_NF],
          atoi(ptb_InRec_Cur[GT_RETEND_NT]),
          atoi(ptb_InRec_Cur[GT_RETSEC_NF]),
          ptb_InRec_Cur[GT_RTY_NF],
          atoi(ptb_InRec_Cur[GT_RETUW_NT]));

		                       /* Affichage ligne : Affaire R*/
  n_Print_Cellule(sz_Page,n_ligneR,COL2,sz_AffRetro,MASQ_STRING,' ');
  }
	
  if (*(ptb_InRec_Cur[GT_BALSHEY_NF]) != '\0')
  {
                                      /* Composition de la date bilan */
  sprintf(sz_DateBilan,"%s%.2d%.2d",
          ptb_InRec_Cur[GT_BALSHEY_NF],
          atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]),
          atoi(ptb_InRec_Cur[GT_BALSHRDAY_NF])); 
  			                 /* Affichage ligne : Date bilan */
  n_Print_Cellule(sz_Page,n_ligneA,COL1,sz_DateBilan,MASQ_DAT,Kc_Lang);
  }

			               /* Affichage Exercice survenance A */
  n_Print_Cellule(sz_Page,n_ligneA,COL3,
                  ptb_InRec_Cur[GT_OCCYEA_NF],MASQ_STRING,' ');
			               /* Affichage Exercice survenance R */
  n_Print_Cellule(sz_Page,n_ligneR,COL3,
                  ptb_InRec_Cur[GT_RETOCCYEA_NF],MASQ_STRING,' ');

  if (*(ptb_InRec_Cur[GT_CLM_NF]) != '\0')
  {
  n_NumSinA = atoi(ptb_InRec_Cur[GT_CLM_NF]);
				          /* Affichage Num Sinistre A */
  n_Print_Cellule(sz_Page,n_ligneA,COL4,&n_NumSinA,MASQ_INT,' ');
  }

  if (*(ptb_InRec_Cur[GT_RCL_NF]) != '\0')
  {
  n_NumSinR = atoi(ptb_InRec_Cur[GT_RCL_NF]);
				          /* Affichage Num Sinistre R */
  n_Print_Cellule(sz_Page,n_ligneR,COL4,&n_NumSinR,MASQ_INT,' ');
  }

				          /* Affichage Annee compte A/R */
  n_Print_Cellule(sz_Page,n_ligneA,COL5,
                  ptb_InRec_Cur[GT_ACY_NF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,n_ligneR,COL5,
                  ptb_InRec_Cur[GT_RETACY_NF],MASQ_STRING,' ');

  if (*(ptb_InRec_Cur[GT_SCOSTRMTH_NF]) != '\0')
  {
                                          /* Mois sur 2 positions (ajout 0
                                             si necessaire) */
  sprintf(sz_MoisDebPCSur2Pos,
          "%.2d",
          atoi(ptb_InRec_Cur[GT_SCOSTRMTH_NF]));

                                 /* Affichage Periode compte A/R*/
  n_Print_Cellule(sz_Page,n_ligneA,COL6,
                  sz_MoisDebPCSur2Pos,MASQ_STRING,' ');
  }

  if (*(ptb_InRec_Cur[GT_SCOENDMTH_NF]) != '\0')
  {
                                          /* Mois sur 2 positions (ajout 0
                                             si necessaire) */
   sprintf(sz_MoisFinPCSur2Pos,
           "%.2d",
           atoi(ptb_InRec_Cur[GT_SCOENDMTH_NF]));
                                 /* Affichage Periode compte A/R*/
  n_Print_Cellule(sz_Page,n_ligneA,COL6_BIS,
                  sz_MoisFinPCSur2Pos,MASQ_STRING,' ');
  }

  n_Print_Cellule(sz_Page,n_ligneR,COL6,
                  ptb_InRec_Cur[GT_RETSCOSTRMTH_NF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,n_ligneR,COL6_BIS,
                  ptb_InRec_Cur[GT_RETSCOENDMTH_NF],MASQ_STRING,' ');

  if (*(ptb_InRec_Cur[GT_AMT_M]) != '\0')
  {
  d_MtA = atof(ptb_InRec_Cur[GT_AMT_M]);
                                          /* Cumul */
  Kd_CumA += d_MtA;
				          /* Affichage Montant  A */
  n_Print_Cellule(sz_Page,n_ligneA,COL7,&d_MtA,MASQ_MT,Kc_Lang);
  }

  if (*(ptb_InRec_Cur[GT_RETAMT_M]) != '\0')
  {
  d_MtR = atof(ptb_InRec_Cur[GT_RETAMT_M]);
                                          /* Cumul */
  Kd_CumR += d_MtR;
				          /* Affichage Montant  R */
  n_Print_Cellule(sz_Page,n_ligneR,COL7,&d_MtR,MASQ_MT,Kc_Lang);
  }

  if (*(ptb_InRec_Cur[GT_CED_NF]) != '\0')
  {
  n_NumCed = atoi(ptb_InRec_Cur[GT_CED_NF]);
				          /* Affichage Num cedante */
  n_Print_Cellule(sz_Page,n_ligneA,COL8,&n_NumCed,MASQ_INT,' ');
  }

  if (*(ptb_InRec_Cur[GT_PLC_NT]) != '\0')
  {
  n_CodPlac = atoi(ptb_InRec_Cur[GT_PLC_NT]);
				          /* Affichage Code placement*/
  n_Print_Cellule(sz_Page,n_ligneR,COL8,&n_CodPlac,MASQ_INT,' ');
  }

  if (*(ptb_InRec_Cur[GT_RTO_NF]) != '\0')
  {
  n_Retro = atoi(ptb_InRec_Cur[GT_RTO_NF]);
				          /* Affichage Retro*/
  n_Print_Cellule(sz_Page,n_ligneR,COL9,&n_Retro,MASQ_INT,' ');
  }

  if (*(ptb_InRec_Cur[GT_BRK_NF]) != '\0')
  {
  n_CourtierA = atoi(ptb_InRec_Cur[GT_BRK_NF]);
				          /* Affichage Courtier A */
  n_Print_Cellule(sz_Page,n_ligneA,COL10,&n_CourtierA,MASQ_INT,' ');
  }

  if (*(ptb_InRec_Cur[GT_INT_NF]) != '\0')
  {
  n_CourtierR = atoi(ptb_InRec_Cur[GT_INT_NF]);
				          /* Affichage Courtier R */
  n_Print_Cellule(sz_Page,n_ligneR,COL10,&n_CourtierR,MASQ_INT,' ');
  }

  if (*(ptb_InRec_Cur[GT_PAY_NF]) != '\0')
  {
  n_PayeurA = atoi(ptb_InRec_Cur[GT_PAY_NF]);
				          /* Affichage Payeur A */
  n_Print_Cellule(sz_Page,n_ligneA,COL11,&n_PayeurA,MASQ_INT,' ');
  }

  if (*(ptb_InRec_Cur[GT_RETPAY_NF]) != '\0')
  {
  n_PayeurR = atoi(ptb_InRec_Cur[GT_RETPAY_NF]);
				          /* Affichage Payeur R */
  n_Print_Cellule(sz_Page,n_ligneR,COL11,&n_PayeurR,MASQ_INT,' ');
  }

				          /* Affichage Ordre Payeur A/R */
  n_Print_Cellule(sz_Page,n_ligneA,COL12,
                  ptb_InRec_Cur[GT_KEY_NF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,n_ligneR,COL12,
                  ptb_InRec_Cur[GT_RETKEY_CF],MASQ_STRING,' ');

  /* MaJ position ligne dans page et nbre de lignes-edition */
  Kn_ligne+=2;
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

				/* Test rupture sur filiale */
  if (strcmp(ptb_InRec[GT_SSD_CF],ptb_InRec_Cur[GT_SSD_CF])!=0)
    {
      Kc_NewSsd = 1;
      RETURN_VAL(1);
    }
				/* Test rupture sur etablissement */
  if (strcmp(ptb_InRec[GT_ESB_CF],ptb_InRec_Cur[GT_ESB_CF])!=0)
    RETURN_VAL(1);

				/* Test rupture sur poste comptable */
  if (strcmp(ptb_InRec[GT_TRNCOD_CF],ptb_InRec_Cur[GT_TRNCOD_CF])!=0)
    RETURN_VAL(1);
    
				/* Test rupture sur monnaie acceptation */
  if (strcmp(ptb_InRec[GT_CUR_CF],ptb_InRec_Cur[GT_CUR_CF])!=0)
    RETURN_VAL(1);

				/* Test rupture sur monnaie retro */
  if (strcmp(ptb_InRec[GT_RETCUR_CF],ptb_InRec_Cur[GT_RETCUR_CF])!=0)
    RETURN_VAL(1);

				/* Test rupture sur poste contre-partie */
  if (strcmp(ptb_InRec[GT_DBLTRNCOD_CF],ptb_InRec_Cur[GT_DBLTRNCOD_CF])!=0)
    RETURN_VAL(1);


  /* plus de place sur la page */
  if (Kn_NbLigne == MAX_NB_LIGNE_ED) 
    {
       Kc_PagePleine = 1;  /* La page est pleine sans "vraie" rupture */
       RETURN_VAL(1);
    }

  RETURN_VAL (0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture premiere de niveau 1
        En rupture 1ere : 
          - stockage de l'entete page dans Page
          - Initialisation du cumul si "vraie" rupture
==============================================================================*/
int n_ActionFirstRuptPage (char **ptb_InRec_Cur)
{
  int  n_SSD_CF,                    /* Filiale */
       n_indSsd;		    /* Indice libelle filiale */

  char c_Slash,
       sz_MoisSur2Pos[3],
       sz_FilSur2Pos[3];

  char *sz_LibSsd;			/* Libelle filiale */

  DEBUT_FCT("n_ActionFirstRuptPage");

  /*Rafraichissement de la page */
  n_CleanPage(sz_Page,NB_LIGNE_MAX_PAGE,NB_COL_MAX_PAGE);
  c_Slash = '/';

  if (Kc_PagePleine != 1)  /* "vraie" rupture */
    {
      Kd_CumA = 0;
      Kd_CumR = 0;
    }
  else Kc_PagePleine = 0;
  
  /* Initialisation libelle filiale, monnaie filiale, code langue */
  /* qui garderont cette valeur si  la fililale n'est pas trouvee */
  sz_LibSsd = "";
  Kc_Lang = ' ';

  /* Recherche filiale */
  n_SSD_CF = atoi(ptb_InRec_Cur[GT_SSD_CF]);

  /* Recherche indice pour cette filiale */
  n_indSsd = Kpn_ind[n_SSD_CF];
                                 /* Si filiale existe */
                                 /* Recherche de tous les libelles */
   if (n_indSsd>=0)
    {  
      Kc_Lang   = Kbd_Lib[n_indSsd].LAG;
      sz_LibSsd = Kbd_Lib[n_indSsd].LIBSSD;
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
  n_Print_Cellule(sz_Page,2,37,&Kn_Annee,MASQ_INT_G,' ');
  n_Print_Cellule(sz_Page,2,45,&Kn_page,MASQ_INT_G,' ');

  n_Print_Cellule(sz_Page,3,1,sz_LibSsd,MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,3,26,ptb_InRec_Cur[GT_ESB_CF],MASQ_STRING,' ');

  n_Print_Cellule(sz_Page,4,1,ptb_InRec_Cur[GT_TRNCOD_CF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,4,12,ptb_InRec_Cur[GT_CUR_CF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,4,17,ptb_InRec_Cur[GT_RETCUR_CF],MASQ_STRING,' ');
  n_Print_Cellule(sz_Page,4,22,ptb_InRec_Cur[GT_DBLTRNCOD_CF],MASQ_STRING,' ');

  /* MaJ position de ligne dans page */
  Kn_ligne += 6;

  RETURN_VAL(0);
}

/*===========================================================================
objet :
	Fonction lancee a chaque rupture derniere de niveau 1
	En rupture derniere : 
			      Stockage du pied de page dans Page
			      Ecriture de la page dans fichier en sortie
===========================================================================*/
int n_ActionLastRuptPage (char **ptb_InRec_Cur)
{
  char sz_Total[21];

  DEBUT_FCT("n_ActionLastRuptPage");

  if (Kc_PagePleine != 1)  /* si "vraie" rupture */
    {                      /* Affichage cumuls */
      n_Print_Cellule(sz_Page,4,COL5,0,MASQ_CONST_TOT_A,Kc_Lang);
      n_Print_Cellule(sz_Page,4,COL9,0,MASQ_CONST_TOT_R,Kc_Lang);
      n_Print_Cellule(sz_Page,4,COL5+22,&Kd_CumA,MASQ_MT_G,Kc_Lang);
      n_Print_Cellule(sz_Page,4,COL9+22,&Kd_CumR,MASQ_MT_G,Kc_Lang);
    }

  /* Ecriture dans fichier */
  n_PrintPage(Kp_OutFil,sz_Page,NB_LIGNE_MAX_PAGE,NB_COL_MAX_PAGE);
  fputc('\n',Kp_OutFil);
  fputc('\f',Kp_OutFil);
	
  /* Initialisation ou saut de page suivant que la filiale change ou pas */
  if (Kc_NewSsd == 1) 
    Kn_page = 1;
  else 
    Kn_page++;

  /* Initialisations pour traitement d'une nouvelle page */
  Kn_ligne = 0;
  Kn_NbLigne = 0;

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
/*==========================================================================
objet : elimine tous les caracteres ' ' places avant le premier caractere
        non-blanc de la chaine passee en parametre

renvoie un pointeur sur ce premier caractere
============================================================================*/
char *pc_CadreAGauche(char *sz_chaine)
{
  while (*sz_chaine == ' ') sz_chaine ++;
  return sz_chaine;
}
