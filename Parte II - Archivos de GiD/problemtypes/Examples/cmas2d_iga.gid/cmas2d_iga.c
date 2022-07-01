#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

struct surface {
  int id;
  int Ncp;
  double* x;
  double* y;
  double* z;
  double area;
  double density;
}; 

char projname[ 1024];
int isurf,icond,Nsurfs,Nconds,icp;
struct surface *surfs;
double x_CG, y_CG, z_CG;
double *x_cond, *y_cond, *z_cond, *w_cond;


int input (void);
int calculate (void);
int output (void);
int free_memory (void);
int readonesurface (struct surface *s, FILE* fp);
void jumpline (FILE*); 

int main( int argc, char *argv[ ]) {
  int error = 1;
  if ( argc < 2) {
    printf( "Error: no projectname provided.\n");
    printf( "Usage: %s full_path_to_project\n", argv[ 0]);
    return 1;
  }  
  strcpy( projname, argv[ 1]);
  
  error = input();
  if ( !error) {
    error = calculate();
  }
  if ( !error) {
    output();
  }
  if ( !error) {
    error = free_memory();  
  }
  
  return error;
}

void write_error_file( const char *msg) {
  char fileerr[1024];
  FILE *ferr = NULL;
  strcpy( fileerr, projname);
  strcat( fileerr,".err");
  ferr = fopen( fileerr, "w");
  fprintf( ferr, "\n \n \n *****  ERROR ***** \n");
  fprintf( ferr, "%s\n", msg);
  fclose( ferr);
}

int if_null_report_not_enough_memory( const void *ptr, int n_items, const char *str_item) {
  int error = 0;
  if ( !ptr) {
    char buf[ 10240];
    error = 1;
    sprintf( buf, "Not enough memory to store %d %s", n_items, str_item);
    write_error_file( buf);
  }
  return error;
}

int input (void) {
  char filedat[ 1024];
  char buf[ 10240];
  FILE *fp = NULL;
  int n = 0;
  int error = 0;

  strcpy( filedat, projname);
  strcat( filedat,".dat");
  fp = fopen( filedat, "r");
  if ( !fp) {
    sprintf( buf, "File '%s' could not be opened for reading.", filedat);
    write_error_file( buf);
    return 1;
  }

  jumpline( fp);
  jumpline( fp);
  n = fscanf( fp, "%d", &Nsurfs);
  if ( n != 1) {
    sprintf( buf, "Error reading Nsurfs from '%s'.", filedat);
    fclose( fp);
    write_error_file( buf);
    return 1;
  }
  jumpline( fp);
  surfs=( struct surface *) malloc((Nsurfs+1)*sizeof(  struct surface )); 
  error = if_null_report_not_enough_memory( surfs, (Nsurfs+1), "surfaces");
  if ( error) return 1;
  jumpline( fp);
  for(isurf=0;isurf<Nsurfs;isurf++) {    
    error=readonesurface(&(surfs[isurf]),fp);
    if ( error) {
      sprintf( buf, "Error reading information about surface # %d from '%s'.", isurf, filedat);
      fclose( fp);
      write_error_file( buf);
      return 1;
      /* break; */
    }
  }
  jumpline( fp);
  /* reading conditions */
  n = fscanf( fp, "%d", &Nconds);
  if ( n != 1) {
    sprintf( buf, "Error reading Nconds from '%s'.", filedat);
    fclose( fp);
    write_error_file( buf);
    return 1;
  }
  jumpline( fp);

  jumpline( fp);
  x_cond=( double *) malloc(( Nconds+1)*sizeof( double));
  error = if_null_report_not_enough_memory( x_cond, ( Nconds+1), "x_cond's");
  if ( error) return 1;
  y_cond=( double *) malloc(( Nconds+1)*sizeof( double));
  error = if_null_report_not_enough_memory( y_cond, ( Nconds+1), "y_cond's");
  if ( error) return 1;
  z_cond=( double *) malloc(( Nconds+1)*sizeof( double));
  error = if_null_report_not_enough_memory( z_cond, ( Nconds+1), "z_cond's");
  if ( error) return 1;
  w_cond=( double *) malloc(( Nconds+1)*sizeof( double));
  error = if_null_report_not_enough_memory( w_cond, ( Nconds+1), "w_cond's");
  if ( error) return 1;
  for ( icond=0; icond<Nconds; icond++){
    n = fscanf( fp, "%lf %lf %lf %lf", &x_cond[ icond], &y_cond[ icond], &z_cond[ icond], &w_cond[ icond]);
    if ( n != 4) {
      sprintf( buf, "Error reading condition %d from '%s'.", icond, filedat);
      fclose( fp);
      write_error_file( buf);
      return 1;
    }
    jumpline( fp);
  }
  fclose( fp);
  return 0;
}

int readonesurface (struct surface *s, FILE* fp) {
  int error = 0;
  int n = 0;
  n = fscanf( fp, "%d", &(s->id));
  if ( n != 1) {
    return 1;
  }
  jumpline( fp);
  n = fscanf( fp, "%d", &(s->Ncp));   
  if ( n != 1) {
    return 1;
  }
  jumpline( fp);
  s->x=( double *) malloc(( s->Ncp+1)*sizeof( double)); 
  error = if_null_report_not_enough_memory( s->x, ( s->Ncp+1), "x cp's");
  if ( error) return 1;
  s->y=( double *) malloc(( s->Ncp+1)*sizeof( double)); 
  error = if_null_report_not_enough_memory( s->y, ( s->Ncp+1), "y cp's");
  if ( error) return 1;
  s->z=( double *) malloc(( s->Ncp+1)*sizeof( double)); 
  error = if_null_report_not_enough_memory( s->z, ( s->Ncp+1), "z cp's");
  if ( error) return 1;
  for ( icp=0; icp<s->Ncp; icp++){
    n = fscanf( fp, "%lf %lf %lf", &(s->x[ icp]), &(s->y[ icp]), &(s->z[ icp]));
    if ( n != 3) {
      return 1;
    }
    jumpline( fp);
  }
  n = fscanf( fp, "%lf %lf", &(s->area), &(s->density));
  if ( n != 2) {
    return 1;
  }
  jumpline( fp);
  return error;
}

int calculate (void) {
  int error = 0;
  double weight_per_cp = 0.0;
  double weight_total = 0.0;

  x_CG=0;
  y_CG=0;
  z_CG=0;

  for (isurf=0; isurf<Nsurfs; isurf++) {
    weight_per_cp=(surfs[isurf].density*surfs[isurf].area)/surfs[isurf].Ncp;
    for ( icp=0; icp<surfs[isurf].Ncp; icp++) {
      weight_total+=weight_per_cp;
      x_CG += (surfs[isurf].x)[icp] * weight_per_cp;
      y_CG += (surfs[isurf].y)[icp] * weight_per_cp;
      z_CG += (surfs[isurf].z)[icp] * weight_per_cp;
    }
  }

  for ( icond=0; icond<Nconds; icond++) {    
    weight_total+=w_cond[icond];
    x_CG += x_cond[icond] * w_cond[icond];
    y_CG += y_cond[icond] * w_cond[icond];
    z_CG += z_cond[icond] * w_cond[icond];    
  }

  x_CG = x_CG / weight_total;
  y_CG = y_CG / weight_total;
  z_CG = z_CG / weight_total;
  return error;
}

int output (void) {
  int error = 0;
  char filedat[ 1024];
  char buf[ 10240];
  FILE *fp = NULL, *fplog = NULL;
  double dist = 0.0;

  /* writing .log */
  strcpy(filedat, projname);
  strcat(filedat,".log");
  fplog = fopen(filedat, "w");
  if ( !fplog) {
    sprintf( buf, "File '%s' could not be opened for writting.", filedat);
    write_error_file( buf);
    return 1;
  }
  fprintf (fplog, "FILE: %s\n", projname);
  fprintf (fplog, "CMAS IGA\nroutine to calculate the mass center of an NURBS surfaces.\n");
  fprintf (fplog, "\n\n\t====> mass center: %f %f %f \n", x_CG, y_CG, z_CG);
  fclose (fplog);   

  /* writing .post.res */
  strcpy(filedat, projname);
  strcat(filedat,".post.res");
  fp = fopen(filedat, "w");
  if ( !fp) {
    sprintf( buf, "File '%s' could not be opened for writting.", filedat);
    write_error_file( buf);
    return 1;
  }
  fprintf (fp, "GiD Post Results File 1.2\n");
  fprintf (fp, "\n");
  fprintf (fp, "Result \"Distance to center\" \"Sample analysis\" 1 Scalar OnNurbsSurface\n");
  fprintf (fp, "Values\n");

  for (isurf=0; isurf<Nsurfs; isurf++) {
    fprintf (fp, "%6d\n", surfs[isurf].id);    
    for ( icp=0; icp<surfs[isurf].Ncp; icp++) {
      dist= sqrt ( pow( (x_CG - (surfs[isurf].x)[icp]) , 2 )
		   + pow( (y_CG - (surfs[isurf].y)[icp]) , 2 )
		   + pow( (z_CG - (surfs[isurf].z)[icp]) , 2 ) );
      fprintf (fp, "%14.6f\n", dist);      
    }
  }
  fprintf (fp, "End Values\n");

  fclose (fp);
  return error;
}

int free_memory (void) {  
  for(isurf=0;isurf<Nsurfs;isurf++) {    
    free(surfs[isurf].x); free(surfs[isurf].y); free(surfs[isurf].z);
  }
  free(surfs);
  free(x_cond); free(y_cond); free(z_cond); free(w_cond);
  return 0;
}

/* newline function */
void jumpline (FILE* filep) {
  char buffer[ 10240];
  fgets( buffer, 10240, filep);
}
