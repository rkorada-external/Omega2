/*==============================================================================
Nom de l'application          : Creation des fichier parametre 
                                champ SECINC_D aux autres contrats/avenants
Nom du source                 : ESCX0001.c
Revision                      : $Revision:   1.1  $
Date de creation              : 21/09/1997
Auteur                        : M.NAJI
References des specifications : 
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
	Des tabels BEST..TREQJOB et BCTA.TBLSHTD on extrait les libelles d'inventaires
	et les dates pour les stocker dans les fichiers parametres
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#define NB_INVENTAIRES 4

int 	Knb_param = 0 ;
CS_CHAR	Ksz_SSDs  [NB_INVENTAIRES  + 1][100];
CS_CHAR	Ksz_VRSs  [NB_INVENTAIRES  + 1][100];
CS_CHAR	Ksz_CLODAT[NB_INVENTAIRES  + 1][  9];
CS_CHAR	Ksz_CRE_D    [  9];

/*----------------------*/
/* Variables de travail */
/*----------------------*/

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/
CS_RETCODE n_FetchRowREQJOB (T_UTCTLIB *pbd_utctlib);

int n_CreerPrm(
  FILE        *p_FilePrm ,              /* Fichier parametres comun*/
  CS_CHAR     *sz_CLODAT_D,
  CS_CHAR     *sz_DBCLO_D,
  CS_CHAR     *sz_SPCEND_D,
  CS_SMALLINT s_BALSHEYEA,
  CS_TINYINT  c_BALSHEMTH,
  CS_CHAR   *sz_ACCOUNT_D,
  CS_CHAR   *sz_PERTYP_CT,
  CS_CHAR   *sz_CLODATMAX_D,
  CS_CHAR   *sz_SSDACC_LL,
  CS_CHAR   *sz_SSDULT_LL
);

int n_CreerPrmX(
  FILE        *p_FilePrm ,              /* Fichier parametres comun*/
  int           i ,
  CS_CHAR     *sz_CLODAT_D,
  CS_CHAR     *sz_DBCLO_D,
  CS_CHAR     *sz_SPCEND_D,
  CS_SMALLINT s_BALSHEYEA,
  CS_TINYINT  c_BALSHEMTH,
  CS_CHAR *sz_SSDDEL_LL,
  CS_CHAR *sz_LSTCLODAT_D
);


/**************************************************************************/
/*** Objet : main														***/
/***																	***/
/*** Nom : main		     												***/
/***																	***/
/*** Parametres:														***/
/***															***/
/*** Retour:													***/
/***	OK si pas d'erreur,										***/
/***	ERR si erreur.											***/
/**************************************************************************/

int main(
   int argc,
   char *argv[]
)
{

	T_UTCTLIB	 bd_UTCTLIB;       /* Structure d'appel des procs */
	FILE        *p_FilePrm; 		/* Fichier paramètres comun*/
	FILE        *p_FilePrm1; 		/* Fchier paramètre du premier  inventaire*/
	FILE        *p_FilePrm2; 		/* Fchier paramètre du deuxieme inventaire*/
	FILE        *p_FilePrm3; 		/* Fchier paramètre du trosieme inentaire*/
	FILE        *p_FilePrm4; 		/* Fchier paramètre du quatrieme inentaire*/

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }


/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESCX0001_O1", "wt", &p_FilePrm1) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl ESCX0001_O1");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESCX0001_O2", "wt", &p_FilePrm2) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl ESCX0001_O2");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESCX0001_O3", "wt", &p_FilePrm3) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl ESCX0001_O3");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESCX0001_O4", "wt", &p_FilePrm4) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl ESCX0001_O4");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESCX0001_O5", "wt", &p_FilePrm) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl ESCX0001_O5");
   }


/* Connexion a la base */
   if (n_LocalConnect (&bd_UTCTLIB) != CS_SUCCEED) {
     ExitPgm (ERR_XX, "Erreur appel fonction n_LocalConnect");
   }

/* Recuperation de la date de filtre pour les facs */
   n_Processing (&bd_UTCTLIB,p_FilePrm,p_FilePrm1,p_FilePrm2,p_FilePrm3,p_FilePrm4);


/* Deconnexion de la base */
   if (n_LocalDisconnect (&bd_UTCTLIB) != CS_SUCCEED) {
      ExitPgm (ERR_XX, "Erreur appel fonction LocalDisconnect");
   }

   if (n_CloseFileAppl("ESCX0001_O1", &p_FilePrm1) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl ESCX0001_O1");
   }

   if (n_CloseFileAppl("ESCX0001_O1", &p_FilePrm2) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl ESCX0001_O2");
   }

   if (n_CloseFileAppl("ESCX0001_O1", &p_FilePrm3) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl ESCX0001_O3");
   }

   if (n_CloseFileAppl("ESCX0001_O1", &p_FilePrm4) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl ESCX0001_O4");
   }

   if (n_CloseFileAppl("ESCX0001_O1", &p_FilePrm) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl ESCX0001_O5");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   exit(OK);
}


/**************************************************************************/
/*** Objet : Lancement de la procédure d'extraction et traitements		***/
/***															***/
/*** Nom : n_Processing    									***/
/***															***/
/*** Parametres:												***/
/***										***/	
/*** Retour:								***/
/***										***/
/***	ERR si erreur.							***/
/**************************************************************************/
n_Processing(
	T_UTCTLIB	*pbd_UTCTLIB,       /* Structure d'appel des procs */
	FILE        *p_FilePrm, 		/* Fichier paramètres comun*/
	FILE        *p_FilePrm1, 		/* Fchier paramètre du premier  inventaire*/
	FILE        *p_FilePrm2, 		/* Fchier paramètre du deuxieme inventaire*/
	FILE        *p_FilePrm3, 		/* Fchier paramètre du trosieme inentaire*/
	FILE        *p_FilePrm4 		/* Fchier paramètre du quatrieme inentaire*/
)
{
   int 			i;
   CS_SMALLINT s_BALSHEYEA_NF;
   CS_TINYINT  c_BALSHEMTH_NF;
   CS_CHAR  sz_SPCEND_D[9];
   CS_CHAR  sz_ACCOUNT_D[9];
   CS_CHAR  sz_CLODAT_D[9];
   CS_CHAR  sz_DBCLO_D[9] ;
   CS_CHAR  sz_PERTYP_CT[2] ;
   CS_CHAR  sz_CLODATMAX_D[9] ;
   CS_CHAR  sz_SSDACC_LL[51] ; 
   CS_CHAR  sz_SSDULT_LL[51] ;
   CS_CHAR  sz_SSDDEL_LL[51] ;
   CS_CHAR  sz_LSTCLODAT_D[51];

   DEBUT_FCT("n_Processing");


   
/* Recuperation du parametre correspondant a la date de demande */
   strcpy(Ksz_CRE_D,psz_GetCharArgv(1)); 

   memset(Ksz_SSDs,0,sizeof(Ksz_SSDs)); 
   memset(Ksz_VRSs,0,sizeof(Ksz_VRSs)); 
   for(i=0;i<NB_INVENTAIRES  + 1;i++) Ksz_SSDs[i][0] = '_', Ksz_VRSs[i][0] = '_';

/* Recuperation de la date de filtre pour les facs */
   pbd_UTCTLIB->n_RowFetchData =  n_FetchRowREQJOB;

 n_ProcessingProc (pbd_UTCTLIB, 13,"BEST..PsREQJOB_04",
  "@p_BLCSHTYEA_NF", CS_RETURN,CS_SMALLINT_TYPE,&s_BALSHEYEA_NF,sizeof(s_BALSHEYEA_NF),0,
  "@p_BLCSHTMTH_NF", CS_RETURN,CS_TINYINT_TYPE, &c_BALSHEMTH_NF,sizeof(c_BALSHEMTH_NF),0,
  "@p_SPCEND_D"    , CS_RETURN,CS_CHAR_TYPE,    sz_SPCEND_D,   9,      0,
  "@p_ACCOUNT_D"   , CS_RETURN,CS_CHAR_TYPE,    sz_ACCOUNT_D,  9,      0,
  "@p_CLODAT_D"    , CS_RETURN,CS_CHAR_TYPE,    sz_CLODAT_D,   9,      0,
  "@p_DBCLO_D"     , CS_RETURN,CS_CHAR_TYPE,    sz_DBCLO_D,    9,      0,
  "@p_PERTYP_CT"   , CS_RETURN,CS_CHAR_TYPE,    sz_PERTYP_CT,  2,      0,
  "@p_CLODATMAX_D" , CS_RETURN,CS_CHAR_TYPE,    sz_CLODATMAX_D,9,      0,
  "@p_SSDACC_LL"   , CS_RETURN,CS_CHAR_TYPE,    sz_SSDACC_LL  ,51,      0,  
  "@p_SSDULT_LL"   , CS_RETURN,CS_CHAR_TYPE,    sz_SSDULT_LL  ,51,      0,   
  "@p_SSDDEL_LL"   , CS_RETURN,CS_CHAR_TYPE,    sz_SSDDEL_LL  ,51,      0,   
  "@p_LSTCLODAT_D" , CS_RETURN,CS_CHAR_TYPE,    sz_LSTCLODAT_D, 9,      0,
  "@p_CRE_D"       , CS_INPUTVALUE, CS_CHAR_TYPE, Ksz_CRE_D   ,9,      0);
 				                 
   n_CreerPrm (p_FilePrm , sz_CLODAT_D, sz_DBCLO_D, sz_SPCEND_D, s_BALSHEYEA_NF, c_BALSHEMTH_NF,sz_ACCOUNT_D, sz_PERTYP_CT,sz_CLODATMAX_D,sz_SSDACC_LL,sz_SSDULT_LL);
   n_CreerPrmX(p_FilePrm1,1 ,sz_CLODAT_D, sz_DBCLO_D, sz_SPCEND_D, s_BALSHEYEA_NF, c_BALSHEMTH_NF, sz_SSDDEL_LL, sz_LSTCLODAT_D );
   
 n_CreerPrmX(p_FilePrm2,2 ,sz_CLODAT_D, sz_DBCLO_D, sz_SPCEND_D, s_BALSHEYEA_NF, c_BALSHEMTH_NF, sz_SSDDEL_LL, sz_LSTCLODAT_D );

   n_CreerPrmX(p_FilePrm3,3 ,sz_CLODAT_D, sz_DBCLO_D, sz_SPCEND_D, s_BALSHEYEA_NF, c_BALSHEMTH_NF, sz_SSDDEL_LL, sz_LSTCLODAT_D );

   n_CreerPrmX(p_FilePrm4,4 ,sz_CLODAT_D, sz_DBCLO_D, sz_SPCEND_D, s_BALSHEYEA_NF, c_BALSHEMTH_NF, sz_SSDDEL_LL, sz_LSTCLODAT_D );
 


   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : Traitement d'une ligne courante de la procédure			***/
/***																	***/
/*** Nom : n_FetchRowREQJOB		     									***/
/***																	***/
/*** Parametres:														***/
/***																	***/
/*** Retour:															***/
/***	CS_SUCCEED pas d'erreur,		  		     					***/
/***	CS_FAIL    pour arrêté le traitement							***/
/**************************************************************************/
CS_RETCODE n_FetchRowREQJOB (T_UTCTLIB *pbd_UTCTLIB)
{
  char sz_ssd[NB_INVENTAIRES  + 1] ;
  char sz_vrs[NB_INVENTAIRES  + 1] ;

  if ( 	pbd_UTCTLIB->n_TotRea == 0 || 
    strcmp(Ksz_CLODAT[Knb_param-1],pc_GetStringValue (pbd_UTCTLIB ,1))!=0)
    {
       if(Knb_param == 4 )
       {
         n_WriteAno("Le nombre d'inventaire demande depasse 4 ");
			return CS_SUCCEED;
       } 

       Knb_param++ ;
       /* stocke les libelles d'inventaire dans un tableau */ 
       strcpy ( Ksz_CLODAT[Knb_param-1], pc_GetStringValue (pbd_UTCTLIB ,1) );
       
       /* stocke les version libelles d'inventaire dans un tableau */ 
    }

  sprintf(sz_ssd,"%d", (int)c_GetTinyintValue (pbd_UTCTLIB ,0)) ;
  sprintf(sz_vrs,"%d", (int)f_GetDecimalValue (pbd_UTCTLIB ,2) );

  /* Concatenation de la filiale pour tous les inventaires */
  if ( !strstr(Ksz_SSDs[4], sz_ssd )  )
  {
	sprintf(Ksz_SSDs[4]+strlen(Ksz_SSDs[4]), "%s_",sz_ssd) ;
	sprintf(Ksz_VRSs[4]+strlen(Ksz_VRSs[4]), "%s_",sz_vrs) ;
  }

  /* concatenation de la filiale pour l'inventaire (Knb_param)*/
  sprintf( Ksz_SSDs[Knb_param-1]+strlen(Ksz_SSDs[Knb_param-1]),"%s_",sz_ssd);
  sprintf( Ksz_VRSs[Knb_param-1]+strlen(Ksz_VRSs[Knb_param-1]),"%s_",sz_vrs);

  return CS_SUCCEED;
}

/**************************************************************************/
/*** Objet : Création du fichier paramètre commun à tous les inventaire	***/
/***																	***/
/*** Nom : n_CreerPrm		     										***/
/***																	***/
/*** Parametres:														***/
/***																	***/
/*** Retour:															***/
/***	OK 			  pas d'erreur,		  		    		 			***/
/***	ERR           en cas de problème								***/
/**************************************************************************/
int n_CreerPrm(	
  FILE        *p_FilePrm ,		/* Fichier paramètres comun*/
  CS_CHAR     *sz_CLODAT_D,
  CS_CHAR     *sz_DBCLO_D,
  CS_CHAR     *sz_SPCEND_D,
  CS_SMALLINT s_BALSHEYEA,
  CS_TINYINT  c_BALSHEMTH,
  CS_CHAR   *sz_ACCOUNT_D,
  CS_CHAR   *sz_PERTYP_CT,
  CS_CHAR   *sz_CLODATMAX_D,
  CS_CHAR   *sz_SSDACC_LL,
  CS_CHAR   *sz_SSDULT_LL
)
{
  int i ;
  DEBUT_FCT("n_CreerPrm");

  if( Knb_param == 0 ) 
    RETURN_VAL(OK);

  fprintf(p_FilePrm ,"ISSDCLO_LL %s\n",Ksz_SSDs[NB_INVENTAIRES]);
  fprintf(p_FilePrm,"BALSHEYEA %d \n",(int)s_BALSHEYEA);
  fprintf(p_FilePrm,"BALSHEMTH %d \n",(int)c_BALSHEMTH);
  fprintf(p_FilePrm,"CRE_D	 %s    \n",Ksz_CRE_D);
  fprintf(p_FilePrm,"DBCLO_D   %s \n",sz_DBCLO_D);
  fprintf(p_FilePrm,"CLODAT0_D %s \n",sz_CLODAT_D);
  fprintf(p_FilePrm,"SPCEND_D   %s\n",sz_SPCEND_D);
  fprintf(p_FilePrm,"SEGTYPCLO_CT   A\n");
  fprintf(p_FilePrm,"PERTYP_CT %s \n",sz_PERTYP_CT);
  fprintf(p_FilePrm,"ACCOUNT_D   %s\n",sz_ACCOUNT_D);
  for(i=9; i<= 99; i++)
  {
    switch(i)
    {
      case 22 :
        fprintf(p_FilePrm ,"CLODATMAX_D %s\n",sz_CLODATMAX_D);
        break;
	
      case 40 :
        fprintf(p_FilePrm,"UPDULTTYP_D Q \n");
        break;
	
      case 60 :
        fprintf(p_FilePrm,"SSDACC_LL %s\n",sz_SSDACC_LL);
        break;
	
      case 80 :
        fprintf(p_FilePrm,"SEGTYPULT_CT   E\n");
        break;
	
      case 81 :
        fprintf(p_FilePrm,"SSDULT_LL %s\n",sz_SSDULT_LL);
        break;
      
      case 82 :
        fprintf(p_FilePrm,"SSDVRS_LL %s\n",Ksz_VRSs[NB_INVENTAIRES]);
        break;
      
      default :
        fprintf(p_FilePrm,"%04d  _____ \n",i);
        break;
    }
  }

  	
  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : Creation du fichier parametre commun a tous les inventaire	***/
/***																	***/
/*** Nom : n_CreerPrm		     										***/
/***																	***/
/*** Parametres:														***/
/***																	***/
/*** Retour:															***/
/***	OK 			  pas d'erreur,		  		    		 			***/
/***	ERR           en cas de problème								***/
/**************************************************************************/
int n_CreerPrmX(	
  FILE        *p_FilePrm ,		/* Fichier paramètres comun*/
  int 		i ,
  CS_CHAR     *sz_CLODAT_D,
  CS_CHAR     *sz_DBCLO_D,
  CS_CHAR     *sz_SPCEND_D,
  CS_SMALLINT s_BALSHEYEA,
  CS_TINYINT  c_BALSHEMTH,
  CS_CHAR *sz_SSDDEL_LL, 
  CS_CHAR *sz_LSTCLODAT_D 
)
{
   DEBUT_FCT("n_CreerPrmX");

	if( i > Knb_param ) 
	   RETURN_VAL(OK);

	fprintf(p_FilePrm ,"SSDCLO_LL %s 	   \n",Ksz_SSDs[4]);
	fprintf(p_FilePrm ,"ISSDCLO_LL %s \n",Ksz_SSDs[i-1]);
	fprintf(p_FilePrm,"BALSHTYEA_NF %d \n",(int)s_BALSHEYEA);
	fprintf(p_FilePrm,"BALSHTMTH_NF %d \n",(int)c_BALSHEMTH);
	fprintf(p_FilePrm,"CRE_D %s \n",Ksz_CRE_D);
	fprintf(p_FilePrm,"DBCLO_D   %s \n",sz_DBCLO_D);
	fprintf(p_FilePrm,"ICLODAT_D %s \n",sz_CLODAT_D);
	fprintf(p_FilePrm,"CLODAT_D  %s \n",Ksz_CLODAT[i-1]);
	fprintf(p_FilePrm,"SPEND_D   %s \n",sz_SPCEND_D);
	fprintf(p_FilePrm,"CLOTYP_CT %c \n",strcmp(Ksz_CLODAT[i-1],sz_CLODAT_D)== 0 ? 'P': 'A');
	fprintf(p_FilePrm,"SEGTYP_CT   A\n");
	fprintf(p_FilePrm ,"SSDDEL_LL %s  \n",sz_SSDDEL_LL);
	fprintf(p_FilePrm,"LSTCLODAT_D  %s\n",sz_LSTCLODAT_D);
	fprintf(p_FilePrm,"SSDVRS_LL  %s",Ksz_VRSs[i-1]);

   RETURN_VAL(OK);
}
