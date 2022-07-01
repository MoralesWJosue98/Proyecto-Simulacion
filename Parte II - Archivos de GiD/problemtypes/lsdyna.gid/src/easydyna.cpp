#include <stdio.h>
#include <string.h>
#include "gidpost.h"

//These constants could change in next LS-DYNA version
#define header_length 41
#define nodes_length 47

int main(int argc,char** argv) {

  FILE *fp;
  FILE *fp2;
  FILE *fp3;

  int dyna_nnode, gid_nnode=0, i=0, j=0, k=0, m=0, end=0, extent_place=0, row_values=0, aux[4], length, nnode;
  double x[6], aux_real[3], time, factor=1.0;
  char buffer[1024], postname[1024], avsname[1024], buffer_aux[1024];	

  struct extent {
    int vtype;
    int comp; 
  } database[76]; 

  //Inicializing database variable
  while (i<76) {
    database[i].vtype=5;
    database[i].comp=0;
    i++;
  }

  ///+++++++++++++++++++WE OBTAIN DATA FROM .DYN FILE+++++++++++++++++++++++++++++++
 
  fp2=fopen(argv[1], "r");
  if (!fp2) return 1;

  fgets(buffer,1024,fp2);

  while(!feof(fp2)){

    //IF WE FIND A COMMAND, WE GUESS IF IT IS INTERESTING OR NOT

    if(!strncmp(buffer,"*",1)) {

      if(!strncmp(buffer,"*DATABASE_AVSFLT",16)) {

        //SEARCHING STEP TIME
        //IT SHOULD BE CHANGED TO IMPORT DATA FROM LS-DYNA

        end=0;
        while (!end) {
          fgets(buffer,1024, fp2);
          if(!strncmp(buffer,"*",1)) end=1;
          else {
            if(strncmp(buffer,"$",1)) sscanf(buffer, "%lf", &time);
          }
        }

      } else if(!strncmp(buffer,"*DATABASE_EXTENT_AVS",20)) {

        //LOOKING FOR DATABASE_EXTENT_AVS CARDS
        //IT SHOULD BE CHANGED IF WE WANT TO IMPORT AVSFLT FILES WITHOUT .DYN FILES

        end=0;
        while (!end) {
          fgets(buffer,1024, fp2);
          if(!strncmp(buffer,"*",1)) end=1;
          else {
            if(strncmp(buffer,"$",1)) {
              sscanf(buffer, "%d,%d", &database[extent_place].vtype, &database[extent_place].comp);
              extent_place++;
            }
          }
        }
      } else if(!strncmp(buffer,"*NODE",5)) {
        //SEARCHING GID_NNODE
        end=0;
        while (end==0) {
          fgets(buffer,1024, fp2);	
          //WE SKIP COMMENTARIES
          if (!strncmp(buffer,"$",1) && strncmp(buffer,"$ Joint Nodes",13)) {
            //we do nothing
          } else {
            if(!strncmp(buffer,"*",1) || !strncmp(buffer,"$ Joint Nodes",13)) {	
              end=1;
            } else {
              gid_nnode++;
            }
          }
        }
      } else {
        //IF IT IS NOT A KNOWN KEYWORD WE JUST READ THE NEXT LINE
        fgets(buffer,1024, fp2);
      }

    } else if (!strncmp(buffer,"$",1)) {

      //We consider the special case of mesh factor comment (useful for deformed in GiD)
      //we suppose that it couldnt be inside a *NODE or a *DATABASE card
      if(!strncmp(buffer,"$ Mesh factor",13)) {
        sscanf(buffer, "$ Mesh factor: %lf", &factor);
        factor=1/factor;
        end=0;
      } 

      //we just skip the rest of comments
      fgets(buffer,1024, fp2);

    } else {
      //line inside an unknown keyword (not a comment) is just skiped
      fgets(buffer,1024, fp2);
    }
  }

  //+++++++++++++++++++WE OBTAIN DYNA_NNODE FROM AVSFLT FILE+++++++++++++++++++++++++++

  strcpy(avsname,argv[1]);
  strcat(avsname,"\\");
  strcat(avsname,"avsflt");

  fp=fopen(avsname, "r");
  if (!fp) return 1;

  fgets(buffer,1024, fp);
  length=(int)strlen(buffer);

  while (length!=header_length) {
    fgets(buffer,1024, fp);
    length=(int)strlen(buffer);
  }

  sscanf(buffer,"%d %d %d %d %d",&dyna_nnode,&aux[0],&aux[1],&aux[2],&aux[3]);

  end=0;

  while (!feof(fp) && !end){
    fgets(buffer,1024, fp);
    if(!strncmp(buffer,"state",5)) 
      end=1;
  }

  //+++++++++++++++++++++WE READ AVSFLT FILE AND WE PRINT THE RESULTS+++++++++++++++++++++++++++

  j=0;
  i=1;
  end=0;

  strcpy(postname,argv[1]);
  strcat(postname,"\\");
  strcat(postname,argv[2]); 
  strcat(postname,".post.res");

  //BINARY OR ASCII OUPUT SETTING
  //GiD_OpenPostResultFile(postname,GiD_PostAscii);
  GiD_OpenPostResultFile(postname,GiD_PostBinary);	

  while (!feof(fp) && !end){

    k=0;

    //FOR EACH ACTIVATED FIELD WE READ AVSFLT FILE (IN FUNCTION OF VTYPE)

    while (k<extent_place) {

      //READING NODAL PROPERTIES++++++++++++++++++++++++++++++++++++++++++++++
      if (database[k].vtype==0) {
        switch (database[k].comp) {
          case 1:
            GiD_BeginResult("Displacements","Nodal",j*time,GiD_Vector,GiD_OnNodes,NULL,NULL,0,NULL);
            break;
          case 2:
            GiD_BeginResult("Velocities","Nodal",j*time,GiD_Vector,GiD_OnNodes,NULL,NULL,0,NULL);
            break;
          case 3:
            GiD_BeginResult("Accelerations","Nodal",j*time,GiD_Vector,GiD_OnNodes,NULL,NULL,0,NULL);
            break;
          default:
            return 1;
        }

        //We find each node number from avs with fp3 (first we put it in first node line)
        fp3=fopen(avsname, "r");
        if (!fp3) return 1;

        fgets(buffer_aux,1024, fp3);
        length=(int)strlen(buffer_aux);

        while (length!=nodes_length) {
          fgets(buffer_aux,1024, fp3);
          length=(int)strlen(buffer_aux);
        }

        i=1;

        while (!feof(fp) && i<=dyna_nnode){
          fgets(buffer,1024, fp);
          //WE ONLY WRITE NODES FROM 1 TO GID_NNODE
          if (i<=gid_nnode) {
            //first we find vector components
            sscanf(buffer,"%lf %lf %lf",&x[0],&x[1],&x[2]);
            //now we find node number
            sscanf(buffer_aux,"%lf %lf %lf %d",&aux_real[0],&aux_real[1],&aux_real[2],&nnode);
            fgets(buffer_aux,1024, fp3);
            //IN DISPLACEMENTS, FACTOR TERM IS NEEDED
            if (database[k].comp==1) {
              GiD_WriteVector(nnode,factor*x[0],factor*x[1],factor*x[2]);
            }
            else {
              GiD_WriteVector(nnode,x[0],x[1],x[2]);
            }
          }
          i++;
        }
        fclose(fp3);
      }

      //READING SURFACE AND BRICK ELEMENT MAGNITUDES+++++++++++++++++++++++++++++++++++++++++++
      if (database[k].vtype==3 || database[k].vtype==1) {
        //READING SURFACE MAGNITUDES+++++++++++++++
        if (database[k].vtype==3) {
          switch (database[k].comp) {
            //MID SURFACE STRESS DATA
            case 1:
              GiD_BeginResult("X_Stress_Midsurface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 2:
              GiD_BeginResult("Y_Stress_Midsurface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 3:
              GiD_BeginResult("Z_Stress_Midsurface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 4:
              GiD_BeginResult("XY_Stress_Midsurface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 5:
              GiD_BeginResult("YZ_Stress_Midsurface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 6:
              GiD_BeginResult("XZ_Stress_Midsurface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 46:
              GiD_BeginResult("Effective_Stress_Midsurface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //MID SURFACE STRAIN DATA
            case 7:
              GiD_BeginResult("Effective_plastic_Strain_Midsurface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 49:
              GiD_BeginResult("Max._principal_Strain_Midsurface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 51:
              GiD_BeginResult("Min._principal_Strain_Midsurface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //INNER SURFACE STRESS DATA
            case 8:
              GiD_BeginResult("X_Stress_Inner_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 9:
              GiD_BeginResult("Y_Stress_Inner_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 10:
              GiD_BeginResult("Z_Stress_Inner_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 11:
              GiD_BeginResult("XY_Stress_Inner_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 12:
              GiD_BeginResult("YZ_Stress_Inner_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 13:
              GiD_BeginResult("XZ_Stress_Inner_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 47:
              GiD_BeginResult("Effective_Stress_Inner_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //INNER SURFACE STRAIN DATA
            case 33:
              GiD_BeginResult("X_Strain_Inner_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 34:
              GiD_BeginResult("Y_Strain_Inner_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 35:
              GiD_BeginResult("Z_Strain_Inner_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 36:
              GiD_BeginResult("XY_Strain_Inner_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 37:
              GiD_BeginResult("YZ_Strain_Inner_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 38:
              GiD_BeginResult("XZ_Strain_Inner_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 14:
              GiD_BeginResult("Effective_plastic_Strain_Inner_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //OUTER SURFACE STRESS DATA
            case 15:
              GiD_BeginResult("X_Stress_Outer_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 16:
              GiD_BeginResult("Y_Stress_Outer_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 17:
              GiD_BeginResult("Z_Stress_Outer_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 18:
              GiD_BeginResult("XY_Stress_Outer_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 19:
              GiD_BeginResult("YZ_Stress_Outer_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 20:
              GiD_BeginResult("XZ_Stress_Outer_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 48:
              GiD_BeginResult("Effective_Stress_Outer_Surface","Shell Stresses",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //OUTER SURFACE STRAIN DATA
            case 39:
              GiD_BeginResult("X_Strain_Outer_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 40:
              GiD_BeginResult("Y_Strain_Outer_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 41:
              GiD_BeginResult("Z_Strain_Outer_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 42:
              GiD_BeginResult("XY_Strain_Outer_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 43:
              GiD_BeginResult("YZ_Strain_Outer_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 44:
              GiD_BeginResult("XZ_Strain_Outer_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 21:
              GiD_BeginResult("Effective_plastic_Strain_Outer_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //4-Node SHELL DATA
            case 22:
              GiD_BeginResult("Bending_Moment-mxx","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 23:
              GiD_BeginResult("Bending_Moment-myy","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 24:
              GiD_BeginResult("Bending_Moment-mxy","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 25:
              GiD_BeginResult("Shear_resultant-qxx","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 26:
              GiD_BeginResult("Shear_resultant-qyy","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 27:
              GiD_BeginResult("Normal_resultant-nxx","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 28:
              GiD_BeginResult("Normal_resultant-nyy","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 29:
              GiD_BeginResult("Normal_resultant-nxy","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 30:
              GiD_BeginResult("Thickness","4-Node Shells",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //LOWER SURFACE STRAIN DATA
            case 52:
              GiD_BeginResult("Effective_Strain_Lower_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 53:
              GiD_BeginResult("Max._Principal_Strain_Lower_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 55:
              GiD_BeginResult("Min._Principal_Strain_Lower_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //UPPER SURFACE STRAIN DATA
            case 57:
              GiD_BeginResult("Max._Principal_Strain_Upper_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 59:
              GiD_BeginResult("Min._Principal_Strain_Upper_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 60:
              GiD_BeginResult("Effective_Strain_Upper_Surface","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
              //THROUGH THICKNESS STRAIN DATA
            case 54:
              GiD_BeginResult("Through_Thickness_Min._Strain","Shell Strains",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            default:
              return 1;
          }
        }
        if (database[k].vtype==1) {
          switch (database[k].comp) {
            //BRICK ELEMENT STRESS DATA
            case 1:
              GiD_BeginResult("X_Stress_Brick_Elements","Brick Elements",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 2:
              GiD_BeginResult("Y_Stress_Brick_Elements","Brick Elements",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 3:
              GiD_BeginResult("Z_Stress_Brick_Elements","Brick Elements",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 4:
              GiD_BeginResult("XY_Stress_Brick_Elements","Brick Elements",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 5:
              GiD_BeginResult("YZ_Stress_Brick_Elements","Brick Elements",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 6:
              GiD_BeginResult("XZ_Stress_Brick_Elements","Brick Elements",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
            case 7:
              GiD_BeginResult("Effective_Plastic_Strain_Brick_Elements","Brick Elements",j*time,GiD_Scalar,GiD_OnNodes,NULL,NULL,0,NULL);
              break;
          }
        }

        //We find each node number from avs with fp3 (first we put it in first node line)
        fp3=fopen(avsname, "r");
        if (!fp3) return 1;

        fgets(buffer_aux,1024, fp3);
        length=(int)strlen(buffer_aux);

        while (length!=nodes_length) {
          fgets(buffer_aux,1024, fp3);
          length=(int)strlen(buffer_aux);
        }

        i=1;
        while (!feof(fp) && i<=dyna_nnode){
          fgets(buffer,1024, fp);

          //first we guess how many values have this row
          if (dyna_nnode-i<6) row_values=dyna_nnode-i+1;
          else row_values=6;

          sscanf(buffer,"%lf %lf %lf %lf %lf %lf",&x[0],&x[1],&x[2],&x[3],&x[4],&x[5]);

          //We compute only row_values nodes, and we write only nodes<gid_nnode
          for (m=0;m<row_values;m++) {
            if (i<=gid_nnode) {
              //we guess node number
              sscanf(buffer_aux,"%lf %lf %lf %d",&aux_real[0],&aux_real[1],&aux_real[2],&nnode);
              fgets(buffer_aux,1024, fp3);
              //we write the element
              GiD_WriteScalar(nnode,x[m]);
            }
            i++;
          }	
        }

        fclose(fp3);
      }

      GiD_EndResult();	
      k++;
    }

    j++;

    fgets(buffer,1024, fp);

    if(strncmp(buffer,"state",5)) 
      end=1;
  }

  fclose(fp);
  fclose(fp2);

  GiD_ClosePostResultFile();

  return 0;
}
