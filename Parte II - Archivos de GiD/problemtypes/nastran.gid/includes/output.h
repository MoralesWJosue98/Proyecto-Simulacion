*set var disps=0
*set var spcfs=0
*set var vels=0
*set var accls=0
*set var loads=0
*set Cond Output_Set_Nodes *nodes *CanRepeat
*loop nodes *OnlyInCond
*if(strcmp(cond(Kind_of_Output),"DISPLACEMENT")==0)
*set var disps=disps+1
*endif
*if(strcmp(cond(Kind_of_Output),"SPCFORCES")==0)
*set var spcfs=spcfs+1
*endif
*if(strcmp(cond(Kind_of_Output),"VELOCITY")==0)
*set var vels=vels+1
*endif
*if(strcmp(cond(Kind_of_Output),"ACCELERATION")==0)
*set var accls=accls+1
*endif
*if(strcmp(cond(Kind_of_Output),"LOAD")==0)
*set var loads=loads+1
*endif
*end nodes
*if(disps>0)  
SET 1 =*\
*set var cntrl=1
*loop nodes *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"DISPLACEMENT")==0 && cntrl<16 && disps!=1)
*format "%i"
*NodesNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"DISPLACEMENT")==0 && cntrl==16 && disps!=1)

*format "%i"
*NodesNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"DISPLACEMENT")==0 && disps==1)
*format "%i"
*NodesNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"DISPLACEMENT")==0)
*set var cntrl=cntrl+1
*set var disps=disps-1
*endif
*end nodes  
  
  DISPLACEMENT(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = 1
*else
*if(strcmp(GenData(Displacement),"1")==0)  
  DISPLACEMENT(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = ALL
*endif
*endif
*if(spcfs>0)  
SET 2 =*\
*set var cntrl=1
*loop nodes *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"SPCFORCES")==0 && cntrl<16 && spcfs!=1)
*format "%i"
*NodesNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"SPCFORCES")==0 && cntrl==16 && spcfs!=1)

*format "%i"
*NodesNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"SPCFORCES")==0 && spcfs==1)
*format "%i"
*NodesNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"SPCFORCES")==0)
*set var cntrl=cntrl+1
*set var spcfs=spcfs-1
*endif
*end nodes  
  
  SPCFORCES(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = 2
*else
*if(strcmp(GenData(Constraint_Force),"1")==0)  
  SPCFORCES(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = ALL
*endif
*endif
*if(vels>0)  
SET 3 =*\
*set var cntrl=1
*loop nodes *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"VELOCITY")==0 && cntrl<16 && vels!=1)
*format "%i"
*NodesNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"VELOCITY")==0 && cntrl==16 && vels!=1)

*format "%i"
*NodesNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"VELOCITY")==0 && vels==1)
*format "%i"
*NodesNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"VELOCITY")==0)
*set var cntrl=cntrl+1
*set var vels=vels-1
*endif
*end nodes  
  
  VELOCITY(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = 3
*else
*if(strcmp(GenData(Velocity),"1")==0)  
  VELOCITY(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = ALL
*endif
*endif
*if(accls>0)  
SET 4 =*\
*set var cntrl=1
*loop nodes *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"ACCELERATION")==0 && cntrl<16 && accls!=1)
*format "%i"
*NodesNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"ACCELERATION")==0 && cntrl==16 && accls!=1)

*format "%i"
*NodesNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"ACCELERATION")==0 && accls==1)
*format "%i"
*NodesNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"ACCELERATION")==0)
*set var cntrl=cntrl+1
*set var accls=accls-1
*endif
*end nodes  
  
  ACCELERATION(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = 4
*else
*if(strcmp(GenData(Acceleration),"1")==0)  
  ACCELERATION(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = ALL
*endif
*endif
*if(loads>0)  
SET 9 =*\
*set var cntrl=1
*loop nodes *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"LOAD")==0 && cntrl<16 && loads!=1)
*format "%i"
*NodesNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"LOAD")==0 && cntrl==16 && loads!=1)

*format "%i"
*NodesNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"LOAD")==0 && loads==1)
*format "%i"
*NodesNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"LOAD")==0)
*set var cntrl=cntrl+1
*set var loads=loads-1
*endif
*end nodes  
  
  OLOAD(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = 9
*else
*if(strcmp(GenData(Applied_Load),"1")==0)  
  OLOAD(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = ALL
*endif
*endif
*set var eses=0
*set var fors=0
*set var strs=0
*set var stress=0
*set elems(All)
*set Cond Output_Set_Lines *elems *CanRepeat
*Add Cond Output_Set_Surfaces *elems *CanRepeat
*loop elems *OnlyInCond
*if(strcmp(cond(Kind_of_Output),"ESE")==0)
*set var eses=eses+1
*endif
*if(strcmp(cond(Kind_of_Output),"FORCE")==0)
*set var fors=fors+1
*endif
*if(strcmp(cond(Kind_of_Output),"STRAIN")==0)
*set var strs=strs+1
*endif
*if(strcmp(cond(Kind_of_Output),"STRESS")==0)
*set var stress=stress+1
*endif
*end elems
*if(eses>0)  
SET 5 =*\
*set var cntrl=1
*loop elems *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"ESE")==0 && cntrl<16 && eses!=1)
*format "%i"
*elemsNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"ESE")==0 && cntrl==16 && eses!=1)

*format "%i"
*elemsNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"ESE")==0 && eses==1)
*format "%i"
*elemsNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"ESE")==0)
*set var cntrl=cntrl+1
*set var eses=eses-1
*endif
*end elems  
*if(strcmp(GenData(Output_Device),"NOPRINT")==0)
  
  ESE = 5
*else
  ESE(*GenData(Output_Device)) = 5
*endif
*else
*if(strcmp(GenData(Strain_Energy),"1")==0)  
*if(strcmp(GenData(Output_Device),"NOPRINT")==0)
  ESE = ALL
*else
  ESE(*GenData(Output_Device)) = ALL
*endif
*endif
*endif
*if(fors>0)  
SET 6 =*\
*set var cntrl=1
*loop elems *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"FORCE")==0 && cntrl<16 && fors!=1)
*format "%i"
*elemsNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"FORCE")==0 && cntrl==16 && fors!=1)

*format "%i"
*elemsNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"FORCE")==0 && fors==1)
*format "%i"
*elemsNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"FORCE")==0)
*set var cntrl=cntrl+1
*set var fors=fors-1
*endif
*end elems  
 
  FORCE(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = 6
*else
*if(strcmp(GenData(Element_Force),"1")==0)  
  FORCE(*GenData(Output_Device),*GenData(Complex_Eigenvalue)) = ALL  
*endif
*endif
*if(strs>0)  
SET 7 =*\
*set var cntrl=1
*loop elems *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"STRAIN")==0 && cntrl<16 && strs!=1)
*format "%i"
*elemsNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"STRAIN")==0 && cntrl==16 && strs!=1)

*format "%i"
*elemsNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"STRAIN")==0 && strs==1)
*format "%i"
*elemsNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"STRAIN")==0)
*set var cntrl=cntrl+1
*set var strs=strs-1
*endif
*end elems  
*if(strcmp(GenData(Element_Corner_Output),"1")==0) 
  STRAIN(*GenData(Output_Device),CORNER,*GenData(Complex_Eigenvalue)) = 7
*else
  STRAIN(*GenData(Output_Device),CENTER,*GenData(Complex_Eigenvalue)) = 7
*endif
*else
*if(strcmp(GenData(Element_Strain),"1")==0)  
*if(strcmp(GenData(Element_Corner_Output),"1")==0) 
  STRAIN(*GenData(Output_Device),CORNER,*GenData(Complex_Eigenvalue)) = ALL
*else
  STRAIN(*GenData(Output_Device),CENTER,*GenData(Complex_Eigenvalue)) = ALL
*endif 
*endif
*endif
*if(stress>0)  
SET 8 =*\
*set var cntrl=1
*loop elems *OnlyInCond  
*if(strcmp(cond(Kind_of_Output),"STRESS")==0 && cntrl<16 && stress!=1)
*format "%i"
*elemsNum,*\
*endif
*if(strcmp(cond(Kind_of_Output),"STRESS")==0 && cntrl==16 && stress!=1)

*format "%i"
*elemsNum,*\
*set var cntrl=1
*endif
*if(strcmp(cond(Kind_of_Output),"STRESS")==0 && stress==1)
*format "%i"
*elemsNum*\
*endif
*if(strcmp(cond(Kind_of_Output),"STRESS")==0)
*set var cntrl=cntrl+1
*set var stress=stress-1
*endif
*end elems  

*if(strcmp(GenData(Element_Corner_Output),"1")==0)  
  STRESS(*GenData(Output_Device),CORNER,*GenData(Complex_Eigenvalue)) = 8
*else
  STRESS(*GenData(Output_Device),CENTER,*GenData(Complex_Eigenvalue)) = 8
*endif
*else
*if(strcmp(GenData(Element_Stress),"1")==0)  
*if(strcmp(GenData(Element_Corner_Output),"1")==0)  
  STRESS(*GenData(Output_Device),CORNER,*GenData(Complex_Eigenvalue)) =ALL
*else
  STRESS(*GenData(Output_Device),CENTER,*GenData(Complex_Eigenvalue)) = ALL
*endif
*endif
*endif
*if(strcmp(GenData(Temperature),"1")==0)
  THERMAL(*GenData(Output_Device),*GenData(Complex_Eigenvalue))  = ALL
*endif
*if(strcmp(GenData(Flux),"1")==0)
  FLUX(*GenData(Output_Device))  = ALL
*endif
