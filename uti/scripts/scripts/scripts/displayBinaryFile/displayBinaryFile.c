#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

typedef struct {
short           PRS_CF;
short           ACMTRS_NT;
char            DETTRS_CF[9];
} T_TRSLNK;


#define SHORT 0 ;
#define INT 1 ;
#define CHAR 2;

int sizes[100]  ;
int types[100]  ;
int adresses[100]  ;

int nb_cols = 0 ;


int TAILLE_BUF  = 0;



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

 int IndexCurquotSize ;  
   
int main(int argc, char *argv[])

{
    FILE* fic ;
    void *buffer; /* ce tableau mÃ©morisera les valeurs lues dans le fichier */
    short int i, nb_val_lues  ;
    /* Ouverture du fichier (en lecture binaire) : */

	IndexCurquotSize = sizeof( T_INDXCURQUOT) * 1000 ;
	
	getDescription(argv[1]) ;

	//displayStruct( argv[2] ) ;
	//printf("\n");

    fic = fopen( argv[2],"rt") ;

	
    if ( fic==NULL )
    {
        printf("Ouverture du fichier impossible !");
        return(0);
    }
    /* Lecture dans le fichier : */
    /*Remplissage du buffer et traitement, autant de fois que nÃ©cessaire jusqu'Ã  la fin fichier : */
   
	
	buffer =(void *)  malloc(TAILLE_BUF) ;
	nb_val_lues = TAILLE_BUF; 
	

	//return 0 ;
	int j=0 ;
	if ( strcmp(argv[3],"T_CURCVSN") == 0 ) 
	{
		fseek( fic,IndexCurquotSize,SEEK_SET) ;
		printf("sizeof(T_CURCVSN)=%d\n" , sizeof(T_CURCVSN) );
		printf("sizeof(T_CURQUOT)=%d\n" , sizeof(T_CURQUOT) );
	}
    while ( nb_val_lues == TAILLE_BUF ) /* vrai tant que fin du fichier non atteinte */
    {
        nb_val_lues = fread( buffer, 1, TAILLE_BUF, fic);
        /* Traitement des valeurs stockÃ©es dans le buffer (ici, un simple affichage) : */
		char * p = buffer ;
		for ( i=0 ; i< nb_cols; i++) 
			switch (types[i] )
			{
				case 0 : // short
					 p = buffer + adresses[i];
					 printf( "%d;",*( short *)p);
					break ;
				case 1 : //int
					 p = buffer + adresses[i];
					 printf( "%d;", *(int *)p);
					break;
				case 2 : // char
					 p = buffer + adresses[i];
					 
					 if ( sizes[i] == 1) 
						 printf( "%u;",  (int )*p);
					 else
						printf( "%.*s;",  sizes[i], p); 
					break;
				case 3 : // unsigned char
					 p = buffer + adresses[i];
					 printf( "%u;",  (int )*p);
					break;
				case 4 : // float
					 p = buffer + adresses[i];
					 printf( "%f;",*( float *)p);
					break ;
				case 5 : // double
					 p = buffer + adresses[i];
					 printf( "%lf;",*( double *)p);
					break ;
				case 6 : // double
					 p = buffer + adresses[i];
					 printf( "%lf;",*( double *)p);
					break ;
				case 7 : // long
					 p = buffer + adresses[i];
					 printf( "%ld;",*( long *)p);
					break ;
			}
		printf( "\n");
		if ( argc > 4 &&  j++ > atoi(argv[4] )) return 0;
    }
    /* Fermeture du fichier : */
    fclose( fic ) ;
	free (buffer ) ;
	
	//printf( "%d %s %s %s %s" , argc, argv[0], argv[1], argv[2], argv[3] ) ;
	return 0 ;
}


int getDescription( char * filename)
{
   FILE *file = fopen ( filename, "r" );
   int i ;
   if ( file != NULL )
   {
    char line [ 128 ]; /* or other suitable maximum line size */
	
	char tab[10][100] ;	
	char*  header ; 
    int adresse = 0 ;
	int pad = 1 ;
    nb_cols = 0 ;
	int taille = 0 ;
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
			printf("%s;", tab[1] ) ;
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
	
	printf("\n");
	//printf("\ntaille=%d\n", TAILLE_BUF) ;

	//printf(" nb_cols= %d ; TAILLE_BUF= %d  \n", nb_cols , TAILLE_BUF ) ;
	
    fclose ( file );
   }
   else
   {
      perror ( filename ); /* why didn't the file open? */
   }
   return 0;
}



int displayStruct( char * filename)
{
   FILE *fic = fopen ( filename, "rb" );
   int i ;
   
 typedef struct	{
			unsigned char BLOCK_NF;
			char  DETTRNCOD_CF[6];
			short RANKORDER_NT;
			char  LSTUPD_D[50];
			char  LSTUPDUSR_CF[5];
} T_SUBTRSBLOCKLIFEST;
	T_SUBTRSBLOCKLIFEST v ;
	
	printf("sizeof =%d\n" , sizeof(T_SUBTRSBLOCKLIFEST) );
   if ( fic != NULL )
   {
		char line [ 128 ]; /* or other suitable maximum line size */
		

		
		int j = 0 ;	
		int nb_val_lues = sizeof(v) ;
		while ( nb_val_lues == sizeof(v) ) /* vrai tant que fin du fichier non atteinte */
		{
			nb_val_lues = fread( &v, 1, sizeof(v), fic);

			printf("%u;%s;%d;%s;%s\n",
					v.BLOCK_NF             ,
					v.DETTRNCOD_CF	         ,
					v.RANKORDER_NT 		,  
					v.LSTUPD_D 		,  
					v.LSTUPDUSR_CF 		
					);
			if ( j++ > 10 )  return 0 ;
		}
   }
	fclose(fic) ;


	
   return 0;
}