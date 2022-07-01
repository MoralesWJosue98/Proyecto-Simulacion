#include <stdio.h>
#include <string.h>
#include "gidpost.h"

//I have probably to include the library in header files


//LS-DYNA->GID MESH IMPORTER PROGRAM+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//Now factor is set to 1 but it should be entered by the user

int ReplaceCommasBySpaces(char* buffer){
  char* pchar=buffer;
  while(*pchar){
    if(*pchar==',')*pchar=' ';
    pchar++;
  }
  return 0;
}

int main(int argc,char** argv) {

  FILE *fp;

  char buffer[1024], meshname[1024];
  int nodeid, end, elementid;
  int nodemesh_num=0, linearmesh_num=0, trimesh_num=0, quadmesh_num=0, hexamesh_num=0, tetmesh_num=0; 
  int shell_vector[5], linear_vector[3], solid_vector[9], dimension=0;
  double x[3];  
  float TC,RC;//translational and rotational constraint of the node
  int PID,RT1,RR1,TR2,RR2,LOCAL;//property id, release conditions for transalation and rotation of nodes and coordinate system
  int nmatch;

  if(argc!=3){
    printf("Error, usage %s input_file output_file\n",argv[0]);
    return 1;
  }
  fp=fopen(argv[1], "r");
  if (!fp) {
    printf("Error, input_file '%s' not found\n",argv[1]);
    return 1;
  }
  //IMPORTANT: PROGRAM CODE COULD BE REPROGRAMED WITH ONE FILE LECTURE ONLY

  //We initialize gid mesh writing  

  //BINARY OR ASCII OUPUT SETTING
  //I HAVE PROBLEMS SETTING IT TO THE BINARY
  int fail=GiD_OpenPostMeshFile(argv[2],GiD_PostAscii);
  if(fail){
    fclose(fp);
    printf("Error, opening output_file '%s'\n",argv[2]);
    return 1;
  }
  //GiD_OpenPostMeshFile(argv[2],GiD_PostBinary);
  GiD_BeginMeshGroup("LS-DYNA mesh");

  ///+++++++++++++++++++WE OBTAIN DATA FROM .DYN FILE+++++++++++++++++++++++++++++++

 
  //First we read all nodes (from all element types) ++++++++++++++++++++++++++++++

  

  fgets(buffer,1024,fp);	

  while(!feof(fp) || strncmp(buffer,"*END",4)){
    //We read each *NODE card
    if(!strncmp(buffer,"*NODE",5)) {
      //We open a new mesh, quadrilateral elements have been chosen abitrary				
      nodemesh_num++;
      sprintf(meshname,"Nodemesh%d", nodemesh_num);
      //meshname is different each step
      GiD_BeginMesh(meshname,GiD_3D,GiD_Quadrilateral,4);

      //Writing mesh coordinates				
      GiD_BeginCoordinates();	
      end=0;
      while(!end && !feof(fp)) {
        fgets(buffer,1024, fp);	        
        if (buffer[0]=='$')
          continue; //WE SKIP COMMENTARIES
        if(buffer[0]=='*') {
          end=1;
        } else {
          //Reading a line of node (it could have one,two or three coordinates)
          //It must have problems when rc or tc are defined (or node format not respected)
          ReplaceCommasBySpaces(buffer);//some file has data separated by commas instead spaces
          nmatch=sscanf(buffer,"%d %lf %lf %lf %f %f",&nodeid,&x[0],&x[1],&x[2],&TC,&RC);
          if(nmatch<2){
            printf("Node definition format not supported, %s\n",buffer);
            return 1;
          } else if(nmatch==2){
            x[1]=x[2]=0.0;
          } else if(nmatch==3){
            x[2]=0.0;
          }        
          GiD_WriteCoordinates(nodeid,x[0],x[1],x[2]);
        }        
      }
      GiD_EndCoordinates();	

      //It has no elements defined
      GiD_BeginElements();
      GiD_EndElements();
      GiD_EndMesh();
    } else {
      //line inside an unknown keyword is just skiped
      fgets(buffer,1024, fp);
    }
  }

  rewind(fp);
  //We read LINEAR elements+++++++++++++++++++++++++++++++++++	
  
  fgets(buffer,1024,fp);

  while(!feof(fp) || strncmp(buffer,"*END",4)){

    //We read element_beam command
    if(!strncmp(buffer,"*ELEMENT_BEAM",13)) {	

      linearmesh_num++;
      sprintf(meshname,"Linearmesh%d", linearmesh_num);

      GiD_BeginMesh(meshname,GiD_3D,GiD_Linear,2);

      //It has no nodes defined
      GiD_BeginCoordinates();	
      GiD_EndCoordinates();	

      //Writing beam elements			
      GiD_BeginElements();						
      end=0;
      while(!end && !feof(fp)) {		
        fgets(buffer,1024, fp);
        if (buffer[0]=='$')
          continue; //WE SKIP COMMENTARIES
        if(buffer[0]=='*') {
          end=1;
        } else {
          //Reading a line of elements
          ReplaceCommasBySpaces(buffer);//some file has data separated by commas instead spaces
          nmatch=sscanf(buffer,"%d %d %d %d %d %d %d %d %d %d",&elementid,&PID,
            &linear_vector[0],&linear_vector[1],&linear_vector[2],&RT1,&RR1,&TR2,&RR2,&LOCAL);
          if(nmatch>=4){
            //avoid the quadratic node, stored in linear_vector[2]
            linear_vector[2]=PID;//append to end the material number (really is a property number)
            GiD_WriteElementMat(elementid,linear_vector);					
          }
        }        
      }
      GiD_EndElements();			
    } else {
      //line inside an unknown keyword is just skiped
      fgets(buffer,1024, fp);
    }
  }	
  
  GiD_EndMesh();

  //We read TRIANGULAR elements)++++++++++++++++++++++++++++++

  rewind(fp);

  fgets(buffer,1024,fp);

  while(!feof(fp) || strncmp(buffer,"*END",4)){

    //We read element_shell command
    if(!strncmp(buffer,"*ELEMENT_SHELL",14)) {	
      trimesh_num++;
      sprintf(meshname,"Trimesh%d", trimesh_num);

      GiD_BeginMesh(meshname,GiD_3D,GiD_Triangle,3);

      //It has no nodes defined
      GiD_BeginCoordinates();	
      GiD_EndCoordinates();

      //Writing shell elements			
      GiD_BeginElements();						
      end=0;
      while(!end && !feof(fp)) {		
        fgets(buffer,1024, fp);
        if (buffer[0]=='$')
          continue; //WE SKIP COMMENTARIES
        if(buffer[0]=='*') {
          end=1;
        } else {
          //Reading a line of elements (first we now how many numbers they're written)
          ReplaceCommasBySpaces(buffer);//some file has data separated by commas instead spaces          
          nmatch=sscanf(buffer,"%d %d %d %d %d %d",&elementid,&PID,&shell_vector[0],&shell_vector[1],&shell_vector[2],&shell_vector[3]);
          //then we write it if needed
          if (nmatch==5) {                
            shell_vector[3]=PID;
            GiD_WriteElementMat(elementid,shell_vector);
          }          
        }
      }
      GiD_EndElements();			
    } else {
      //line inside an unknown keyword is just skiped
      fgets(buffer,1024, fp);
    }
  }	
  
  GiD_EndMesh();

  //We read QUADRILATERAL elements++++++++++++++++++++++++++++++

  rewind(fp);

  fgets(buffer,1024,fp);

  while(!feof(fp) || strncmp(buffer,"*END",4)){		

    //We read element_shell command
    if(!strncmp(buffer,"*ELEMENT_SHELL",14)) {
      quadmesh_num++;
      sprintf(meshname,"Quadmesh%d", quadmesh_num);	

      GiD_BeginMesh(meshname,GiD_3D,GiD_Quadrilateral,4);

      //It has no nodes defined
      GiD_BeginCoordinates();	
      GiD_EndCoordinates();	

      //Writing shell elements			
      GiD_BeginElements();						
      end=0;
      while(!end && !feof(fp)) {		
        fgets(buffer,1024, fp);
        if (buffer[0]=='$')
          continue; //WE SKIP COMMENTARIES
        if(buffer[0]=='*') {
          end=1;
        } else {
          //Reading a line of elements (first we now how many numbers they're written)
          ReplaceCommasBySpaces(buffer);//some file has data separated by commas instead spaces          
          nmatch=sscanf(buffer,"%d %d %d %d %d %d",&elementid,&PID,&shell_vector[0],&shell_vector[1],&shell_vector[2],&shell_vector[3]);
          //then we write it if needed
          if (nmatch==6) {
            shell_vector[4]=PID;
            GiD_WriteElementMat(elementid,shell_vector);
          }
        }
      }
      GiD_EndElements();			
    } else {
      //line inside an unknown keyword is just skiped
      fgets(buffer,1024, fp);
    }
  }	
  
  GiD_EndMesh();

  //We read TET elements (degenerated LS-DYNA hexahedras)++++++++++++++++++++++++++++++

  rewind(fp);

  fgets(buffer,1024,fp);

  while(!feof(fp) || strncmp(buffer,"*END",4)){		

    //We read element_solid command
    if(!strncmp(buffer,"*ELEMENT_SOLID",14)) {	
      tetmesh_num++;
      sprintf(meshname,"Tetmesh%d", tetmesh_num);	

      GiD_BeginMesh(meshname,GiD_3D,GiD_Tetrahedra,4);

      //It has no nodes defined
      GiD_BeginCoordinates();	
      GiD_EndCoordinates();

      //Writing solid elements			
      GiD_BeginElements();						
      end=0;
      while(!end && !feof(fp)) {		
        fgets(buffer,1024, fp);
        if (buffer[0]=='$')
          continue; //WE SKIP COMMENTARIES
        if(buffer[0]=='*') {
          end=1;
        } else {
          //Reading a line of elements
          ReplaceCommasBySpaces(buffer);//some file has data separated by commas instead spaces          
          nmatch=sscanf(buffer,"%d %d %d %d %d %d %d %d %d %d",&elementid,&PID,
            &solid_vector[0],&solid_vector[1],&solid_vector[2],&solid_vector[3],
            &solid_vector[4],&solid_vector[5],&solid_vector[6],&solid_vector[7]);
          if (solid_vector[3]==solid_vector[4]) {
            solid_vector[4]=PID;
            GiD_WriteElementMat(elementid,solid_vector);
          }          
        }
      }
      GiD_EndElements();			
    } else {
      //line inside an unknown keyword is just skiped
      fgets(buffer,1024, fp);
    }
  }	
  
  GiD_EndMesh();

  //We read HEXAHEDRA elements ++++++++++++++++++++++++++++++

  rewind(fp);

  fgets(buffer,1024,fp);

  while(!feof(fp) || strncmp(buffer,"*END",4)){	

    //We read element_solid command
    if(!strncmp(buffer,"*ELEMENT_SOLID",14)) {	
      hexamesh_num++;
      sprintf(meshname,"Hexamesh%d", hexamesh_num);

      GiD_BeginMesh(meshname,GiD_3D,GiD_Hexahedra,8);

      //It has no nodes defined
      GiD_BeginCoordinates();	
      GiD_EndCoordinates();

      //Writing solid elements			
      GiD_BeginElements();						
      end=0;
      while(!end && !feof(fp)) {		
        fgets(buffer,1024, fp);
        if (buffer[0]=='$')
          continue; //WE SKIP COMMENTARIES
        if(buffer[0]=='*') {
          end=1;
        } else {
          //Reading a line of elements
          ReplaceCommasBySpaces(buffer);//some file has data separated by commas instead spaces
          nmatch=sscanf(buffer,"%d %d %d %d %d %d %d %d %d %d",&elementid,&PID,
            &solid_vector[0],&solid_vector[1],&solid_vector[2],&solid_vector[3],
            &solid_vector[4],&solid_vector[5],&solid_vector[6],&solid_vector[7]);
          if (solid_vector[3]!=solid_vector[4]) {
            solid_vector[8]=PID;
            GiD_WriteElementMat(elementid,solid_vector);
          }          
        }
      }
      GiD_EndElements();			
    } else {
      //line inside an unknown keyword is just skiped
      fgets(buffer,1024, fp);
    }
  }	

  fclose(fp);
  GiD_EndMesh();

  GiD_EndMeshGroup();
  GiD_ClosePostMeshFile();
  return 0;

}
