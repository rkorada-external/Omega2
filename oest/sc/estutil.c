/* estutil.c
==============================================================================
[001] 03/10/2012 Florent       :spot:24041 - Création
[002] 02/01/2013 Roger         :spot:24041 - modif code retour a 0 de n_GetNormeTRN.
[XXX] 02/06/2014 JBG :spot:25773 Warnings suppress in compile
==============================================================================*/
#ifndef __ESTUTIL
#define __ESTUTIL

const short PRS_EBS_INVENT_ACCEP = 730;

typedef struct { char *psz_NORME_CF; short i_TRN; } T_TRN_NORMES;
static T_TRN_NORMES gtbl_TRN_NORMES[] = { { "SII", 1 }, { "IFRSI", 2 }, { "GIM", 3 }, { "EV", 4 }, { "ALLNO", 1 }, { "", -1 } };

#define MAX_TBL_TRSLNK 5000    // poste PRS_CF à rechercher dans le fichier binaire TRSLNK
static T_TRSLNK gtbl_TRSLNK[MAX_TBL_TRSLNK];
int gn_LignesTRSLNK = 0;

int n_RechPosteTRSLNK(short n_prs, short n_acmtrs, char *psz_DETTRS_CF);
int n_ChargerTRSLNK(short n_prs, FILE *Kp_InputTRSLNK );
short n_GetNormeTRN(char *psz_NORME_CF);

char**  split(char* chaine, const char* delim, int vide);

/*==============================================================================
objet :
	fonction de recherche suivant NORME_CF
retour :
 >= 0 ok, c'est le chiffre pour la norme
  et 5 pas trouvé
==============================================================================*/
short n_GetNormeTRN(char *psz_NORME_CF)
{
	DEBUT_FCT("n_GetNormeTRN");

	T_TRN_NORMES *ptbl; /* Added for Phase1b Migration */
	/**for (T_TRN_NORMES *ptbl = gtbl_TRN_NORMES; ptbl->psz_NORME_CF[0] != 0; ptbl++)**/
	for (ptbl = gtbl_TRN_NORMES; ptbl->psz_NORME_CF[0] != 0; ptbl++)  /* Updated for Phase1b Migration */
	 {  
		if (strcmp(ptbl->psz_NORME_CF, psz_NORME_CF) == 0)
	  	RETURN_VAL( ptbl->i_TRN );
	}
	//Valeur autre - [002] -> retour 0 au lieu de 5
	RETURN_VAL( 0 );
}

/*==============================================================================
objet:
	Lit le fichier binaire des postes et les met en memoire
retour :
 >= 0 ok, c'est le nombre d'élément cahrgé dans le tableau
 < 0 pas trouvé
==============================================================================*/
int n_ChargerTRSLNK( short n_prs, FILE *Kp_InputTRSLNK )
{
	DEBUT_FCT("n_ChargerTRSLNK");

	char  MsgAno[300];

	gn_LignesTRSLNK = 0;
	while (fread(&gtbl_TRSLNK[gn_LignesTRSLNK], sizeof(T_TRSLNK), 1, Kp_InputTRSLNK) == 1 )
	{
		if (gtbl_TRSLNK[gn_LignesTRSLNK].PRS_CF == n_prs)
			gn_LignesTRSLNK += 1 ;
		if (gn_LignesTRSLNK > MAX_TBL_TRSLNK)
		{
			sprintf(MsgAno,"la taille du tableau(%d) gtbl_TRSLNK dépasse la taille allouee %d",MAX_TBL_TRSLNK,gn_LignesTRSLNK);
			n_WriteAno(MsgAno);
			RETURN_VAL( -1 );
		}
	}

	RETURN_VAL( gn_LignesTRSLNK );
}

/*==============================================================================
objet :
	fonction de recherche du poste
retour :
 >= 0 ok, c'est l'index dans le tableau
 < 0 pas trouvé
==============================================================================*/
int n_RechPosteTRSLNK(short n_prs, short n_acmtrs, char *psz_DETTRS_CF)
{
	DEBUT_FCT("n_RechPosteTRSLNK");

	int n_indice;
	char MsgAno[300];

	n_indice=0;
	while (1)
	{
		/* Comparaison des codes */
		if (gtbl_TRSLNK[n_indice].PRS_CF == n_prs && gtbl_TRSLNK[n_indice].ACMTRS_NT == n_acmtrs)
		{
			/* S'ils sont egaux, retourner l'indice */
			strcpy(psz_DETTRS_CF,gtbl_TRSLNK[n_indice].DETTRS_CF);
			RETURN_VAL( n_indice );
		}

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if (n_indice >= gn_LignesTRSLNK)
		{
			sprintf(MsgAno,"Valeur PRS_CF %d, ACMTRS_NT %d, DETTRS_CF %s inconnue de gtbl_TRSLNK",n_prs,n_acmtrs,psz_DETTRS_CF);
			n_WriteAno(MsgAno);
			RETURN_VAL( -1 );
		}
	}
}

/*==============================================================================
Retour dans un tableau des chaines séparées par un délimiteur. Terminé par NULL.
	chaine : chaine à splitter
	delim  : delimiteur qui sert à la decoupe
	vide   : 0 : on n'accepte pas les chaines vides
	         1 : on accepte les chaines vides
==============================================================================*/
char** split(char* chaine,const char* delim,int vide)
{
    
	char** Tableau=NULL;           //tableau de chaine, tableau resultat
	char *ptr;                     //pointeur sur une partie de
	int sizeStr;                   //taille de la chaine à recupérer
	int sizeTab=0;                 //taille du tableau de chaine
	char* largestring;             //chaine à traiter

	int sizeDelim=strlen(delim);   //taille du delimiteur
	largestring = chaine;          //comme ca on ne modifie pas le pointeur d'origine

	while( (ptr=strstr(largestring, delim))!=NULL )
	{
		sizeStr=ptr-largestring;
		
		//si la chaine trouvé n'est pas vide ou si on accepte les chaine vide                   
		if(vide==1 || sizeStr!=0)
		{
			//on alloue une case en plus au tableau de chaines
			sizeTab++;
			Tableau= (char**) realloc(Tableau,sizeof(char*)*sizeTab);
			               
			//on alloue la chaine du tableau
			Tableau[sizeTab-1]=(char*) malloc( sizeof(char)*(sizeStr+1) );
			strncpy(Tableau[sizeTab-1],largestring,sizeStr);
			Tableau[sizeTab-1][sizeStr]='\0';
		}
		
		//on decale le pointeur largestring  pour continuer la boucle apres le premier elément traiter
		ptr=ptr+sizeDelim;
		largestring=ptr;
	}
	
	//si la chaine n'est pas vide, on recupere le dernier "morceau"
	if(strlen(largestring)!=0)
	{
		sizeStr=strlen(largestring);
		sizeTab++;
		Tableau= (char**) realloc(Tableau,sizeof(char*)*sizeTab);
		Tableau[sizeTab-1]=(char*) malloc( sizeof(char)*(sizeStr+1) );
		strncpy(Tableau[sizeTab-1],largestring,sizeStr);
		Tableau[sizeTab-1][sizeStr]='\0';
	}
	else if(vide==1)
	{
		//si on fini sur un delimiteur et si on accepte les mots vides,on ajoute un mot vide
		sizeTab++;
		Tableau= (char**) realloc(Tableau,sizeof(char*)*sizeTab);
		Tableau[sizeTab-1]=(char*) malloc( sizeof(char)*1 );
		Tableau[sizeTab-1][0]='\0';          
	}
    
	//on ajoute une case à null pour finir le tableau
	sizeTab++;
	Tableau= (char**) realloc(Tableau,sizeof(char*)*sizeTab);
	Tableau[sizeTab-1]=NULL;
	
	return Tableau;
}

#endif /* __ESTUTIL */
