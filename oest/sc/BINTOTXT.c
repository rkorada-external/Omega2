#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <util.h>
//#include "structA.h"
#include "struct.h"
#include "estserv.h"



#define SHORT 0 ;
#define INT 1 ;
#define CHAR 2;




int sizes[100]  ;
int types[100]  ;
int adresses[100]  ;

int nb_cols = 0 ;


int TAILLE_BUF  = 0;

char separatorF[2] = "~" ;


/*
typedef struct {
short           PRS_CF;
short           ACMTRS_NT;
char            DETTRS_CF[9];
} T_TRSLNK;

typedef struct
   {
    char   c_ssd;
    char   sz_cur[4];
    short  s_uwy;
    double d_quot;
   } T_CURQUOT;

typedef struct {
char         ACPCUR_CF[4];
unsigned char      SSD_CF;
char         RETCTR_NF[10];
short     RTY_NF;
int          PLC_NT;
char         ACCCUR_CF[4];
} T_CURCVSN   ;

typedef struct
   {
    char   sz_cur[4];
    long   l_Pos;
    int    n_Nbr;
    T_CURQUOT* ptbd_Cur ;
   } T_INDXCURQUOT;

*/
int IndexCurquotSize ;  

int getDescription(FILE *file);
int displayStruct( char * filename);   
int main(int argc, char *argv[])

{
	FILE* fDesc ,*fData,*fOut;
	void *buffer; /* ce tableau mÃ©morisera les valeurs lues dans le fichier */
	short int i, nb_val_lues  ;
	char typeName[50] ;
	
	InitSig () ;


    InitSig () ;

	if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

  
    /* Ouverture des fichiers binaires et des fichiers de sortie */
	if (n_OpenFileAppl("BINTOTXT_I1", "rt", &fDesc) == ERR) ExitPgm(ERR_XX ,"");
	if (n_OpenFileAppl("BINTOTXT_I2", "rb", &fData) == ERR) ExitPgm(ERR_XX ,"");
	if (n_OpenFileAppl("BINTOTXT_O1", "wt", &fOut) == ERR) ExitPgm(ERR_XX ,"");


	
	IndexCurquotSize = sizeof( T_INDXCURQUOT) * 1000 ;

	getDescription(fDesc) ;

	//displayStruct( argv[2] ) ;
	//printf("\n");

	//fDesc = fopen( argv[2],"rt") ;


	if ( fDesc==NULL )
	{
		printf("Ouverture du fichier de description impossible  !");
		return(0);
	}
	/* Lecture dans le fichier : */
	/*Remplissage du buffer et traitement, autant de fois que nÃ©cessaire jusqu'Ã  la fin fichier : */


	buffer =(void *)  malloc(TAILLE_BUF) ;
	nb_val_lues = TAILLE_BUF; 

	strcpy(typeName,psz_GetCharArgv(1));
	
	//return 0 ;
	int j=0 ;
	if ( strcmp(typeName,"T_CURCVSN") == 0 || strcmp(typeName,"T_CURQUOT") == 0  ) 
	{
		fseek( fData,IndexCurquotSize,SEEK_SET) ;
		//printf("sizeof(T_CURCVSN)=%d\n" , sizeof(T_CURCVSN) );
		//printf("sizeof(T_CURQUOT)=%d\n" , sizeof(T_CURQUOT) );
	}
	while ( nb_val_lues == TAILLE_BUF && TAILLE_BUF > 0 ) /* vrai tant que fin du fichier non atteinte */
	{
		nb_val_lues = fread( buffer, 1, TAILLE_BUF, fData);
		/* Traitement des valeurs stockÃ©es dans le buffer (ici, un simple affichage) : */
		char * p = buffer ;
		for ( i=0 ; i< nb_cols; i++) 
		{
			char * separator = (i  < (nb_cols - 1)) ? separatorF:"";
			switch (types[i] )
			{
				case 0 : // short
					 p = buffer + adresses[i];
					 fprintf(fOut,   "%d%s",*( short *)p,separator);
					break ;
				case 1 : //int
					 p = buffer + adresses[i];
					 fprintf(fOut,   "%d%s", *(int *)p, separator);
					break;
				case 2 : // char
					 p = buffer + adresses[i];
					 
					 if ( sizes[i] == 1) 
						 fprintf(fOut,   "%u%s",  (int )*p,separator);
					 else
						//fprintf(fOut,   "%.*s;",  sizes[i], p); 
						fprintf(fOut,   "%s%s",  p,separator); 
					break;
				case 3 : // unsigned char
					 p = buffer + adresses[i];
					 fprintf(fOut,   "%u%s",  (int )*p,separator);
					break;
				case 4 : // float
					 p = buffer + adresses[i];
					 fprintf(fOut,   "%.10f%s",*( float *)p,separator);
					break ;
				case 5 : // double
					 p = buffer + adresses[i];
					 fprintf(fOut,   "%.10lf%s",*( double *)p,separator);
					break ;
				case 6 : // double
					 p = buffer + adresses[i];
					 fprintf(fOut,   "%.10lf%s",*( double *)p,separator);
					break ;
				case 7 : // long
					 p = buffer + adresses[i];
					 fprintf(fOut,   "%ld%s",*( long *)p,separator);
					break ;
			}
		}
		fprintf(fOut,   "\n");
		if ( argc > 4 &&  j++ > atoi(argv[4] )) return 0;
	}
	/* Fermeture du fichier : */
	//fclose( fDesc ) ;
	free (buffer ) ;
	if (n_CloseFileAppl("BINTOTXT_I1", &fDesc ) == ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("BINTOTXT_I2", &fData) == ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("BINTOTXT_O1", &fOut) == ERR) ExitPgm(ERR_XX, "");

	//fprintf(fOut,   "%d %s %s %s %s" , argc, argv[0], argv[1], argv[2], argv[3] ) ;
	return 0 ;
}


int getDescription(FILE *file)
{
//   FILE *file = fopen ( filename, "r" );
   int i ;
   if ( file != NULL )
   {
    char line [ 128 ]; /* or other suitable maximum line size */
	
	char tab[10][100] ;	
	int pad = 1 ;
    nb_cols = 0 ;
    while ( fgets ( line, sizeof line, file ) != NULL ) /* read a line */
    {
		//printf ( line) ;
		int j=0,ctr=0;
		char *str1 = line;
		strcpy(tab[2],"1") ;
		for(i=0;i<=(strlen(line));i++)
		{
        // if space or NULL found, assign NULL into tab[ctr]
			if(str1[i]==';'||str1[i]=='\0' ||str1[i]=='\n')
			{
				tab[ctr][j]='\0';
				ctr++;  //for next word
				j=0;    //for next word, init index to 0
			}
			else
			{
				tab[ctr][j]=str1[i];
				j++;
			}
		}      
	
		//printf ( "tarce 2 %s %s %s \n", tab[0] , tab[1] , tab[2]) ;

		

		
		int isItem = 0 ;
		int size_type = 0 ;
		if ( strcmp(tab[0],"short") == 0 ) 
		{
			types[nb_cols] = 0 ;
			sizes[nb_cols] = size_type =2	 ;
			isItem = 1 ;
		}
		if ( strcmp(tab[0],"int") == 0 )
		{
			types[nb_cols] = 1 ;
			sizes[nb_cols] = size_type=4 ;
			isItem = 1 ;
		}
		if ( strcmp(tab[0],"char") == 0 )
		{
			types[nb_cols] = 2 ;
			size_type = 1 ;
			sizes[nb_cols] = atoi(tab[2]) ;
			isItem = 1 ;
		}

		if ( strcmp(tab[0],"unsigned char") == 0 ) 
		{
			types[nb_cols] = 3 ;
			sizes[nb_cols] = size_type= 1 ;
			isItem = 1 ;
		}
		if ( strcmp(tab[0],"float") == 0 ) 
		{
			types[nb_cols] = 4 ;
			sizes[nb_cols] = size_type =sizeof(float)	 ;
			isItem = 1 ;
		}
		if ( strcmp(tab[0],"double") == 0 ) 
		{
			types[nb_cols] = 5 ;
			sizes[nb_cols] = size_type =sizeof(double)	 ;
			isItem = 1 ;
		}
		if ( strcmp(tab[0],"long") == 0 ) 
		{
			types[nb_cols] = 5 ;
			sizes[nb_cols] = size_type =sizeof(long)	 ;
			isItem = 1 ;
		}


		if ( isItem )
		{			
			pad = pad>=size_type?pad:size_type,pad ;
			//printf("%s;", tab[1] ) ;
			if ( nb_cols == 0 ) adresses[nb_cols] = 0 ;
			else 
			{
				if (  TAILLE_BUF % size_type == 0 )
					adresses[nb_cols] = TAILLE_BUF ;
				else
					adresses[nb_cols] =((int)(TAILLE_BUF /size_type )+ 1) * size_type ;
			}
			TAILLE_BUF = adresses[nb_cols] + sizes[nb_cols] ;
			//printf("  nb_cols= %d taille= %d  adresse= %d ; TAILLE_BUF= %d  \n", nb_cols ,sizes[nb_cols] , adresses[nb_cols] , TAILLE_BUF ) ;
	
			nb_cols++ ;
		}
	}

	if (  TAILLE_BUF % pad != 0 )
		TAILLE_BUF = ((int)((TAILLE_BUF + pad)  /pad)) * pad;
	
	//printf("\n");
	//printf("\ntaille=%d\n", TAILLE_BUF) ;

	//printf(" nb_cols= %d ; TAILLE_BUF= %d  \n", nb_cols , TAILLE_BUF ) ;
	
    //fclose ( file );
   }
   return 0;
}


