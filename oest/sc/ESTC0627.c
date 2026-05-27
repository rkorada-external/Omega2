/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC0627.c
révision                      : $Revision: 1.0 $
date de création              : 20/01/2015
auteur                        : F.MARAGNES
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Positionement du champs sinistralite dans ESTC1005_IADPERICASE_O2.dat. 
   Parcours du  fichier _SORT_PERICASESEG_O.dat 
   si le champ PER_SEG_NF est renseigné  dans SORT_PERICASESEG_O.dat
   et le montant de sinistralite , S_SEGEST2.Sa_M pour la cle (Segment, année d'exercice) != 0 dans ESTC0625_SEGESTEST   
   on positionne PER_SINISTRALITE à  1 IADPERICASE_O2
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
   20/01/2015    F.Maragnes   :spot:28140 Creation 
  ==============================================================================*/



/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <string.h>
#include <util.h>
#include <stdarg.h>

#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------------*/
/* strcture contenant lignes esclaves cumulees */
/*---------------------------------------------*/
//#define TEST
#ifdef TEST
typedef struct 
 {
 		char *ctr;
 		char *end;
 		char *sec;
 		char *uwy;
 }XXXX;
 #define NB_TEST 26
 XXXX tabTest[ NB_TEST]= {
 		{"10T003040","0","3","2008"},
 		{"10T011854","0","1","2008"},
 		 {"10T011854","0","2","2008"},
		{"10T014728","0","1","2008"},
	  {"10T014880","0","1","2008"},
		{"10T014880","0","2","2008"},
    {"10T015136","0","1","2008"},
    {"10T015136","0","2","2008"},
    {"10T015136","0","3","2008"},
		{"10T017208","0","1","2008"},
		{"10T009433","0","1","2003"},
		{"10T017283","0","1","2009"},
		{"10T017283","0","1","2010"},
		{"10T018153","0","1","2011"},
		{"10T009855","0","1","2004"},
 		{"10T009855","0","1","2005"},
 		{"10T011704","0","1","2010"},
 		{"10T011704","0","1","2009"},
 		{"10T011704","0","1","2008"},
 		{"10T011704","0","1","2007"},
 		{"10T004614","0","2","2004"},
 		{"10T004614","0","2","2003"},
 		{"10F134037","1","1","2008"},
 		{"10T011555","0","1","2006"},
 		{"10T011591","0","2","2010"},
 		{"10T011854","0","1","2008"},
	};

#endif
/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_InputFilPericase ; /* pointeur sur le fichier d'entree ESTC1005_IADPERICASE_O2.dat */
FILE 		*Kp_InputFilPericaseSeseg; /* pointeur sur le fichier d'entree FSEGEST */
FILE     *Kp_OutputFilPericase;

T_RUPTURE_VAR  	 bd_RuptPericaseSeseg    	 ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptPericase; /* variable de gestion de la synchronisation avec
						le fichier sinsitre segment  */
						
						
typedef struct {
char seg_nf[30];
int  uwy_nf;
double Sa_M;
} 
S_SEGEST2;

S_SEGEST2 *ptrSeg;
int nbSegAlloue;
int nbSeg;

int n_InitPericaseSeseg		( T_RUPTURE_VAR *pbd_Rupt ) ;
int n_IsR1PericaseSeseg		( char **ptb_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptPericaseSeseg	( char **ptb_InRec_Cur ) ;
int n_ActionLignePericaseSeseg		( char **pbd_InRec_Cur ) ;

int n_InitPericase	 		( T_RUPTURE_SYNC_VAR  *pbd_Rupt ) ;

int n_ActionLignePericase		  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPericase		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1Pericase	(	char **pbd_InRec ,  	char **pbd_InRec_Cur  ) ;
int n_ActionFirstRuptPericase	(char **pbd_InRecOwner ,  char **pbd_InRecChild  ) ;
int n_ActionLastRuptPericase	(char **pbd_InRecOwner ,  char **pbd_InRecChild  );
int n_ActionLigneAbsente(char **pbd_InRec_Cur );

int n_initSeg(char *nomFic);
static int compareSeg(const void *elt1 , const void *elt2);
int n_VerifieSinistrailte( char *seg_nf, int uwy_nf );
void libereSeg();

long nbLigne ,nbLigneAbsente ;



/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;
	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;
       if ( n_OpenFileAppl ( "ESTC0627_I1","rb",&Kp_InputFilPericaseSeseg ) == ERR )
                ExitPgm ( ERR_XX , "" );        

        if ( n_OpenFileAppl (  "ESTC0627_I2","rb",&Kp_InputFilPericase ) == ERR )
                ExitPgm ( ERR_XX , "" );
     
 

	/* ouverture du fichier resultat */
	if ( n_OpenFileAppl ( "ESTC0627_O1","wt",&Kp_OutputFilPericase ) == ERR )
		ExitPgm( ERR_XX , "" ) ;
		
	/* Chargement des segments estimation en mémoire*/
	if(n_initSeg("ESTC0627_I3") == 1)
		 ExitPgm( ERR_XX , "" ) ;
		 
	/* Initialisation de la variable bd_RuptPericase */
	if ( n_InitPericase( &bd_RuptPericase ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerPrmd */
	if ( n_InitPericaseSeseg( &bd_RuptPericaseSeseg ) )
		ExitPgm( ERR_XX , "" ) ;

	
	if ( n_ProcessingRuptureVar( &bd_RuptPericaseSeseg ) == ERR )
			ExitPgm( ERR_XX , "" ) ;
    
fclose(Kp_InputFilPericase);		
fclose(Kp_OutputFilPericase);
fclose( Kp_InputFilPericaseSeseg);
libereSeg();
/***********/

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
}



/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitPericaseSeseg( T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT( __FUNCTION__ ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription 
	if ( n_OpenFileAppl( "ESTC1005_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		RETURN_VAL(  ERR ) ;*/
pbd_Rupt->pf_InputFil=Kp_InputFilPericaseSeseg;
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePericaseSeseg ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1PericaseSeseg ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPericaseSeseg ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1PericaseSeseg(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( __FUNCTION__ ) ;
   if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] )  != 0) ||
   	( ret = strcmp( pbd_InRec[PER_SEC_NF], pbd_InRec_Cur[PER_SEC_NF]  ) != 0 ) ||  
    (ret = strcmp( pbd_InRec[PER_UWY_NF], pbd_InRec_Cur[PER_UWY_NF] )  != 0 ) ||
     (ret = strcmp( pbd_InRec[PER_END_NT], pbd_InRec_Cur[PER_END_NT] )  != 0 )) return ret ;	
   	

		 			RETURN_VAL (0) ;


}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPericaseSeseg(
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
	DEBUT_FCT(__FUNCTION__ ) ;
   
	
 
	/* synchronisation avec le fichier des Comptes complets */
	n_ProcessingRuptureSyncVar( &bd_RuptPericase, ptb_InRec_Cur ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePericaseSeseg( char **ptb_InRec_Cur )
{
  DEBUT_FCT( __FUNCTION__ ) ;

 
   n_ProcessingRuptureSyncVar( &bd_RuptPericase, ptb_InRec_Cur );
  	

 
  /* ecriture dans le Perimetre de souscription en sortie */
  /*if (Kb_cond) n_WriteCols( Kp_OutputFilPericase, ptb_InRec_Cur, '~', 0 );

  if (Kb_condRI) n_WriteCols( Kp_OutputFilPericaseRI, ptb_InRec_Cur, '~', 0 );*/

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Sinnistre»
	avec l’esclave « Perimetre de souscriptio,»

retour :
	OK
==============================================================================*/
int n_InitPericase( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitPericaseSeseg" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  
pbd_Rupt->pf_InputFil=Kp_InputFilPericase;
  /* nombre de rupture a gerer sur le fichier de travail */
  pbd_Rupt->n_NbRupture = 1 ;

  /* gestion de la rupture de niveau 1 (GtRI) */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Pericase ;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPericase  ;
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPericase  ;
  pbd_Rupt->n_FilsSansPere = n_ActionLigneAbsente;
  

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPericase  ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePericase  ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPericase (
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;
  
	DEBUT_FCT( __FUNCTION__ ) ;



	if ((ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PER_CTR_NF] ))  != 0 )
				return ret;
	if((ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PER_END_NT] ))  != 0 )
			 return ret;
	if( (ret =  strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PER_SEC_NF] ))  != 0 ) 
			return ret;  
  if( (ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PER_UWY_NF] ))  != 0 )
  		return ret;
  
  nbLigne++;
	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/

int n_IsR1Pericase (
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;


  DEBUT_FCT( __FUNCTION__ ) ;


 if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] )  != 0 )
 	|| (ret = strcmp( pbd_InRec[PER_END_NT], pbd_InRec_Cur[PER_END_NT] )  != 0 )
 	|| (ret = strcmp( pbd_InRec[PER_SEC_NF], pbd_InRec_Cur[PER_SEC_NF] )  != 0   )
 	|| (ret = strcmp( pbd_InRec[PER_UWY_NF], pbd_InRec_Cur[PER_UWY_NF] )  != 0 )
        )
			RETURN_VAL( ret ) ;

   RETURN_VAL( 0 ) ;
}





/*==============================================================================
objet :
	fonction lancee en rupture derniere GtRI (niveau 1)

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPericase (
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
 

  DEBUT_FCT( __FUNCTION__ ) ;
 
  
  
  RETURN_VAL ( OK ) ;
}



/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPericase (
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( __FUNCTION__) ;


  RETURN_VAL ( OK ) ;
}


/***
Objet:
Fonction d'action sur une ligne courante lu   
retour :	OK ---> traitement correctement effectue    
		ERR --> probleme rencontre 
**/
int n_ActionLignePericase (
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{	
 
 
 
	if(ptb_InRecOwner[PER_SEG_NF][0] != 0 ) 
	{	

		 
		if(n_VerifieSinistrailte(ptb_InRecOwner[PER_SEG_NF],atoi(ptb_InRecOwner[PER_UWY_NF])))
			strcpy(ptb_InRecChild[PER_SEGSA_B],"1"); 
		else 
		{
				strcpy(ptb_InRecChild[PER_SEGSA_B],"0");
		}	
		
}	
	n_WriteCols(Kp_OutputFilPericase, ptb_InRecChild,'~', 0);		  
  nbLigne++;
  
  RETURN_VAL( OK ) ;
}


/***                                                  
Objet:                                                
Fonction d'action sur une ligne fils sans pere          
retour :	OK ---> traitement correctement effectue    
		ERR --> probleme rencontre                        
**/                                                   

int n_ActionLigneAbsente(char **pbd_InRec_Cur )
{
	 DEBUT_FCT( __FUNCTION__) ; 
	
	strcpy(	pbd_InRec_Cur[PER_SEGSA_B],"0");
	 n_WriteCols(Kp_OutputFilPericase, pbd_InRec_Cur,'~', 0);
	 nbLigneAbsente++;
	 RETURN_VAL( 0 ) ;  
}



/***
 Fonction de chargement en memoire des sgements 
 @param nom logique du fichier 
 @return 1 KO O Ok
**/
int n_initSeg(char *nomFic)
{
	FILE *fp;
	
	char buf[256], *ptr,*ptr1;
	 if ( n_OpenFileAppl (nomFic,"rb",&fp) == ERR )
        return 1;
                
  if( (ptrSeg = ( S_SEGEST2 *)malloc(sizeof(S_SEGEST2)*2000)) == NULL)
  	 return 1;             
  nbSegAlloue=2000;
  
  while(fgets(buf,250,fp))
  {
  	
		if(nbSeg >= nbSegAlloue)
		{
			nbSegAlloue+=100;	
			if((ptrSeg = ( S_SEGEST2  *)realloc(ptrSeg,sizeof( S_SEGEST2)*nbSegAlloue)) == NULL)
					return 1;
		}	
  	ptr = strchr(buf,'~');
    *ptr=0;
    strcpy(ptrSeg[nbSeg].seg_nf , buf);
	  ptr++;
	  ptr1= strchr(ptr,'~');     
    *ptr1=0;
    ptrSeg[nbSeg].uwy_nf = atoi(ptr);
    ptr1++;
		ptr = strrchr(ptr1,'~');     
		ptr++;
		ptrSeg[nbSeg].Sa_M = atof(ptr);
    nbSeg++;
  }	
  fclose(fp);
  return 0;
                
}	


/***
Fonction de comparaison utilisee pour la recherchedes segments
@param  structure contenant un des elements a comparer  represente la cle de recherche
@parma  structure contenant un des elements a comparer  represente la cle de recherche
**/

static int compareSeg(const void *elt1 , const void *elt2)
{
	short ret;
	
	S_SEGEST2 * item1 =  (S_SEGEST2 *)elt1;
	S_SEGEST2 * item2 =  (S_SEGEST2 *)elt2;
	
	ret = strcmp(item1->seg_nf , item2->seg_nf);
	if(ret != 0)
		return ret;
	if(item1->uwy_nf != item2->uwy_nf)
		  return  item1->uwy_nf - item2->uwy_nf;
	else 
		return 0;	  
		 
}



int n_VerifieSinistrailte( char *seg_nf, int uwy_nf )
{
 S_SEGEST2 key;
 S_SEGEST2  *item;
 strcpy (key.seg_nf , seg_nf);
 key.uwy_nf = uwy_nf;

 
 if(ptrSeg == NULL)
 		return 0;
 if(nbSeg == 0)
 			return 0;	
 item = ( S_SEGEST2 *)bsearch((const void *)&key,(const void *)ptrSeg,nbSeg, sizeof(S_SEGEST2),compareSeg);
 
 if(item != NULL)
 {
	if(item->Sa_M != 0.0)
	{
	
		return 1;
	}	
 }
 return 0;	 	
 	  
}	
/***
liberation de ptrSeg;
**/
void libereSeg()
{
		free(ptrSeg);
		ptrSeg=NULL;
}	
