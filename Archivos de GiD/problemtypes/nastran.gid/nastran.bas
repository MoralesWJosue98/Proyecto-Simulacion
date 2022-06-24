$---------------------------File Info-----------------------------------------
$       Created: *tcl(clock format [clock seconds] -format "%a %b %D %T") 
$       Num of Nodes:*\ 
*format "%6i" 
*npoin
$       Num of Properties:*\  
*format "%2i" 
*nmats
$       Num. elems:*\  
*format "%6i" 
*nelem
$       Analysis Type: *GenData(Analysis_Type)  
$---------------------------File Info-----------------------------------------
*#----------------------------------------------------------------------------------
*#
*#                        EXECUTIVE CONTROL
*#
*#----------------------------------------------------------------------------------
*#setFormatForceWidth
*SetFormatNastran
*if(strcmp(GenData(NASTRAN_type),"MI/NASTRAN")==0)
*include includes/execntrlmi.h
*endif
*if(strcmp(GenData(NASTRAN_type),"MSC/NASTRAN")==0)
*include includes/execntrlmsc.h
*endif
*if(strcmp(GenData(NASTRAN_type),"NE/NASTRAN")==0)
*include includes/execntrlne.h
*endif
*#----------------------------------------------------------------------------------
*#
*#                        CASE CONTROL
*#
*#----------------------------------------------------------------------------------
  ECHO = *GenData(ECHO)
  TITLE= *GenData(Title)
  SUBTITLE= *GenData(Subtitle)
  LABEL= *GenData(Label)
  LINE= *GenData(Lines_per_printed_page)
*if(strcmp(GenData(NASTRAN_type),"MI/NASTRAN")==0)  
  MAXLINES= *GenData(Maximum_number_of_output_lines)
*endif
*#--------------------output requests-----------------------------------------------
*if(strcmp(GenData(Analysis_Type),"MODES")==0)
SUBCASE 1
  LABEL = NORMAL MODES  
  SPC = 1
  METHOD = 1  
*endif  
*if(strcmp(GenData(Analysis_Type),"DIRECT_FREQUENCY_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"MODAL_FREQUENCY_RESPONSE")==0)
  FREQ = 1  
  DLOAD = 1
  SPC = 1
*if(strcmp(GenData(NASTRAN_type),"NE/NASTRAN")==0)
  METHOD = 1
*endif
*endif  
*if(strcmp(GenData(Analysis_Type),"DIRECT_TRANSIENT_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"MODAL_TRANSIENT_RESPONSE")==0))
  TSTEP = 1  
  DLOAD = 1
  SPC = 1
*if(strcmp(GenData(NASTRAN_type),"NE/NASTRAN")==0)
  METHOD = 1
*endif
*endif  
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_TRANSIENT")==0)
  TSTEPNL = 1  
  DLOAD = 1
  SPC = 1
*endif
*set elems(all)
*set Cond Surface_Pressure_Freq_Type1 *elems
*add Cond Surface_Pressure_Freq_Type2 *elems
*add cond Surface_Pressure_Time_Type1 *elems
*add Cond Surface_Pressure_Time_Type2 *elems 
*add Cond Line_Pressure_Freq_Type1 *elems
*add Cond Line_Pressure_Freq_Type2 *elems
*add cond Line_Pressure_Time_Type1 *elems
*add Cond Line_Pressure_Time_Type2 *elems
*if(CondNumEntities(int)>0)
  LOADSET= 1
*endif
*set cond Point_Initial_Conditions *nodes *CanRepeat
*Add cond Line_Initial_Conditions *nodes *CanRepeat
*Add cond Surface_Initial_Conditions *nodes *CanRepeat
*Add cond Volume_Initial_Conditions *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*if(strcmp(GenData(NASTRAN_type),"NE/NASTRAN")!=0) 
  TIC = 1
*else
  IC = 1
*endif  
*endif  
*if(strcmp(GenData(Analysis_Type),"STEADY_STATE_HEAT_TRANSFER")==0)
*tcl(writebasfile_loadcases STATIC)
  TEMPERATURE(INITIAL) = 1
*endif
*if(strcmp(GenData(Analysis_Type),"STATIC")==0)
*tcl(writebasfile_loadcases STATIC)
*endif
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_STATIC")==0)
*tcl(writebasfile_loadcases STATIC)
  NLPARM = 1
*endif
*if(strcmp(GenData(Analysis_Type),"BUCKLING")==0)
*tcl(writebasfile_loadcases STATIC)
  STRESS = ALL
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_BUCKLING")==0)
  NLSTRESS = ALL
  NLPARM = 1
*endif
SUBCASE 2
  LABEL = MODES BUCKLING
*if(strcmp(GenData(Analysis_Type),"BUCKLING")==0)
  STRESS = NONE
*endif
  METHOD = 1
  SPC = 1
*endif
*if(strcmp(GenData(Analysis_Type),"PRESTRESS_STATIC")==0)
*tcl(writebasfile_loadcases PRESTRESS_STATIC)
*endif
*if(strcmp(GenData(Analysis_Type),"PRESTRESS_MODES")==0)
*tcl(writebasfile_loadcases STATIC)
SUBCASE 2
  LABEL = MODAL
  SPC = 1
  METHOD = 1
*endif
*include includes/output.h
*if(strcmp(GenData(Select_Range),"1")==0)
  SET 7 =*\  
*for(i=0;i<=GenData(Output_Number_of_frequency_increments,int);i=i+1)
*if(i==GenData(Output_Number_of_frequency_increments,int))
*set var aux=GenData(From(Hz),real)+GenData(Frequency_increment,real)*i
*format "%#g"
*aux
*else
*set var aux=GenData(From(Hz),real)+GenData(Frequency_increment,real)*i
*format "%#g"
*aux,*\
*endif  
*end for
  OFREQUENCY = 7
*endif
BEGIN BULK  
$ -----------------------------------------------------------------------------
$    GiD-NASTRAN Interface    
$    Copyright @ COMPASS Ingenieria y Sistemas S.A. March 2005 
$    Comments: www.compassis.com ## info@compassis.com
$    Written by AVT    Version:    3.0
$ -----------------------------------------------------------------------------
*Set var SID=1
*Set var IDN1=-1
*Set var ID0=0
*Set var ID1=1
*Set var ID2=2
*Set var ID3=3
*#----------------------------------------------------------------------------------
*#
*#                        PARAM
*#
*#----------------------------------------------------------------------------------
*if(strcmp(GenData(NASTRAN_Type),"MSC/NASTRAN")==0)
*if(strcmp(GenData(MULTBC),"1")==0 )
PARAM,MULTBC,YES
*else
PARAM,MULTBC,NO
*endif
*if(strcmp(GenData(BODYLOAD),"1")==0 )
PARAM,BODYLOAD,YES
*else
PARAM,BODYLOAD,NO
*endif
*if(strcmp(GenData(GPFORCE),"1")==0 )
PARAM,GPFORCE,YES
*else
PARAM,GPFORCE,NO
*endif
*if(strcmp(GenData(MPCFORCE),"1")==0 )
PARAM,MPCFORCE,YES
*else
PARAM,MPCFORCE,NO
*endif
*if(strcmp(GenData(INRELF),"1")==0 )
PARAM,INRELF,YES
*else
PARAM,INRELF,NO
*endif
*if(strcmp(GenData(PELMCHK),"1")==0 )
PARAM,PELMCHK,YES
*else
PARAM,PELMCHK,NO
*endif
*if(strcmp(GenData(PRGPST),"1")==0 )
PARAM,PRGPST,YES
*else
PARAM,PRGPST,NO
*endif
*format "PARAM,K6ROT,%#5g"
*GenData(K6ROT,real)
*format "PARAM,MAXRATIO,%#8.2E"
*GenData(MAXRATIO,real)
*endif
*if(strcmp(GenData(AUTOSPC),"1")==0)
*if(strcmp(GenData(NASTRAN_Type),"MI/NASTRAN")==0)
PARAM,AUTOSPC,YES
*endif
*if(strcmp(GenData(NASTRAN_Type),"MSC/NASTRAN")==0)
PARAM,AUTOSPC,YES
*endif
*if(strcmp(GenData(NASTRAN_Type),"NE/NASTRAN")==0)
PARAM,AUTOSPC,ON
*endif
*endif
*if(strcmp(GenData(GRDPNT),"1")==0)
PARAM,GRDPNT,1
*endif
*format "%#f"
*if(strcmp(GenData(Overall_Structural_Damping),"0.0")!=0)
PARAM,G,*GenData(Overall_Structural_Damping,real)
*endif
*if(strcmp(GenData(Mass_formulation),"Coupled")==0)
PARAM,COUPMASS,1
*endif
*format "%#g"
*if(strcmp(GenData(Frequency_for_System_Damping),"0.0")!=0)
PARAM,W3,*GenData(Frequency_for_System_Damping,real)
*endif
*format "%#f"
*if(strcmp(GenData(Frequency_for_Element_Damping),"0.0")!=0)
PARAM,W4,*GenData(Frequency_for_Element_Damping,real)
*endif
*format "%#f"
*if(strcmp(GenData(WTMASS),"0.0")!=0)
PARAM,WTMASS,*GenData(WTMASS,real)
*endif
*if(strcmp(GenData(IRES),"1")==0)
PARAM,IRES,1
*endif
*format "%#.2f"
*if(strcmp(GenData(Analysis_Type),"MODAL_FREQUENCY_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"MODAL_TRANSIENT_RESPONSE")==0 )
PARAM,LFREQ,*GenData(First_frequency_(Hz),real)
*format "%#.2f"
PARAM,HFREQ,*GenData(Last_frequency_(Hz),real)
*endif
*if(strcmp(GenData(IRES),"1")==0)
PARAM,MODACC,1
*endif
*if(strcmp(GenData(PRTGPST),"0")==0)
PARAM,PRTGRST,NO
*endif
*if(strcmp(GenData(NASTRAN_Type),"NE/NASTRAN")!=0)
PARAM,SINGOPT,*GenData(SINGOPT)
*endif
*if(strcmp(GenData(BISECT),"1")==0)
PARAM,BISECT,ON
*endif
*if(strcmp(GenData(LANGLE),"GIMBAL")==0)
PARAM,LANGLE,1
*endif
*if(strcmp(GenData(LANGLE),"ROTATION")==0)
PARAM,LANGLE,2
*endif
*if(strcmp(GenData(LGDISP),"1")==0)
PARAM,LGDISP,1
*endif
*if(strcmp(GenData(NLINSOLACCEL),"1")==0)
PARAM,NLINSOLACCEL,4
*endif
*if(strcmp(GenData(Analysis_Type),"STEADY_STATE_HEAT_TRANSFER")==0)
*format "%#8.5g"
PARAM,SIGMA,*GenData(Stefan-Boltzmann)
PARAM,TABS,*GenData(Scale_Factor_Abs._Temperature)
*endif 
*#---------------------------------------------------------------------------------
*#
*#                        DYNAMIC EIGRVALUES EXTRACTION
*#
*#----------------------------------------------------------------------------------
*if(strcmp(GenData(Analysis_Type),"DIRECT_FREQUENCY_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"DIRECT_TRANSIENT_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"MODAL_FREQUENCY_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"MODAL_TRANSIENT_RESPONSE")==0)
*if(strcmp(GenData(NASTRAN_type),"NE/NASTRAN")==0) 
*if(GenData(First_frequency,real)==GenData(Last_frequency,real))
*format "EIGRL%11i                %8i     YES       9"        
*ID1*GenData(Desired,int)*\
*else
*format "EIGRL%11i%#8.5g%#8.5g%8i     YES       9"        
*ID1*GenData(First_frequency,real)*GenData(Last_frequency,real)*GenData(Desired,int)*\ 
*endif
*if(strcmp(GenData(Normalization),"MASS")==0)
            MASS+VAP   1
+VAP   1      30         
*endif
*if(strcmp(GenData(Normalization),"MAX")==0)
             MAX+VAP   1
+VAP   1      30         
*endif
*if(strcmp(GenData(Normalization),"POINT")==0)
*MessageBox error:POINT Noramlization Method not supported for NE/NASTRAN
*endif
*endif
*endif
*#---------------------------------------------------------------------------------
*#
*#                        BUCKLING
*#
*#----------------------------------------------------------------------------------
*if(strcmp(GenData(Analysis_Type),"BUCKLING")==0)
*if(strcmp(GenData(NASTRAN_type),"NE/NASTRAN")==0)
*format "EIGRL%11i%#8.5g%#8.5g%8i"
*ID1*GenData(Initial_eigenvalue,real)*GenData(Final_eigenvalue)*GenData(Number_of_roots_desired)*\
*if(strcmp(GenData(Sturm_sequence),"YES")==0)
     YES*\
*else
      NO*\
*endif
       9        
*format "%16i%#8.2g"
*GenData(Maximum_iterations,int)*GenData(Convergence_tolerance,real)
*else
*MessageBox error: BUCKLING analysis is not implemented for this NASTRAN type.
*endif
*endif
*#---------------------------------------------------------------------------------
*#
*#                        EIGRVALUES & EIGRVECTORS
*#
*#----------------------------------------------------------------------------------
*if(strcmp(GenData(Analysis_Type),"MODES")==0)
*if(strcmp(GenData(NASTRAN_type),"NE/NASTRAN")==0) 
*if(GenData(First_frequency,real)==GenData(Last_frequency,real))
*format "EIGRL%11i                %8i     YES       9"        
*ID1*GenData(Desired,int)*\
*else
*format "EIGRL%11i%#8.5g%#8.5g%8i     YES       9"        
*ID1*GenData(First_frequency,real)*GenData(Last_frequency,real)*GenData(Desired,int)*\
*endif
*if(strcmp(GenData(Normalization),"MASS")==0)
            MASS+VAP   1
+VAP   1      30         
*endif
*if(strcmp(GenData(Normalization),"MAX")==0)
             MAX+VAP   1
+VAP   1      30         
*endif
*if(strcmp(GenData(Normalization),"POINT")==0)
*MessageBox error:POINT Noramlization Method not supported for NE/NASTRAN
*endif 
*else
*if(strcmp(GenData(Method),"INV")==0 || strcmp(GenData(Method),"DET")==0 ||strcmp(GenData(Method),"GIV")==0 )
*format "EIGR%12i"
*ID1*\
     *GenData(Method)*\
*endif
*if(strcmp(GenData(Method),"MGIV")==0 || strcmp(GenData(Method),"UDET")==0 ||strcmp(GenData(Method),"UINV")==0 || strcmp(GenData(Method),"FEER")==0)
*format "EIGR%12i"
*ID1*\
    *GenData(Method)*\
*endif
*if(strcmp(GenData(Method),"FEER-Q")==0 || strcmp(GenData(Method),"FEER-X")==0)
*format "EIGR%12i"
*ID1*\
   *GenData(Method)*\
*endif
*format "%#8.5g%#8.5g%8i%8i%8i"
*GenData(First_frequency,real)*GenData(Last_frequency,real)*GenData(Estimate,int)*GenData(Desired,int)*ID0*\
*if(strcmp(GenData(Mass_orthogonality),"1")==0)
*format "%#8.1E+EIGR"
*GenData(Tolerance_for_Mass,real)
*else
     0.0+EIGR
*endif
*if(strcmp(GenData(Normalization),"MASS")==0)
+EIGR       MASS         
*endif
*if(strcmp(GenData(Normalization),"POINT")==0)
*format "+EIGR      POINT%8i%8i"         
*GenData(NodeID,int)*GenData(DOF_(integer_1-6),int)
*endif
*if(strcmp(GenData(Normalization),"MAX")==0)
+EIGR        MAX         
*endif
*endif
*endif
*#---------------------------------------------------------------------------------
*#
*#                        NONLINEAR SOLUTION
*#
*#----------------------------------------------------------------------------------
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_BUCKLING")==0)
*include includes/nonlinear.h
*endif
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_STATIC")==0)
*include includes/nonlinear.h
*endif
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_TRANSIENT")==0)
*include includes/nonlinear.h
*endif
*#----------------------------------------------------------------------------------
*#
*#                        STATIC LOADS
*#
*#----------------------------------------------------------------------------------
*tcl(writebasfile_combinedcases)
*loop intervals 
*set var SID=loopvar-1
*Set Cond Point-Force-Load *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*set var x1=cond(X-Force,real)*cond(X-Force,real)
*Set var x2=cond(Y-Force,real)*cond(Y-Force,real)
*set var x3=cond(Z-Force,real)*cond(Z-Force,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Force,real)/norma
*set var x2=cond(Y-Force,real)/norma
*set var x3=cond(Z-Force,real)/norma
*format "FORCE%11i%8i%8i%#8.5g%#8.5g%#8.5g%#8.5g"
*SID*NodesNum*ID0*norma*x1*x2*x3
*end nodes
*endif
*Set Cond Moment *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*set var x1=cond(Mx-Force,real)*cond(Mx-Force,real)
*Set var x2=cond(My-Force,real)*cond(My-Force,real)
*set var x3=cond(Mz-Force,real)*cond(Mz-Force,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(Mx-Force,real)/norma
*set var x2=cond(My-Force,real)/norma
*set var x3=cond(Mz-Force,real)/norma
*format "MOMENT%10i%8i%8i%#8.5g%#8.5g%#8.5g%#8.5g"
*SID*NodesNum*ID0*norma*x1*x2*x3
*end nodes
*endif
*set cond Point-Enforced-Displacement *nodes *CanRepeat
*Add cond Line-Enforced-Displacement *nodes *CanRepeat
*Add cond Surface-Enforced-Displacement *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*if(cond(X-Enforced_Displacement,real)!=0)
*format "SPCD%12i%8i       1%#8.5g"
*SID*NodesNum*cond(X-Enforced_Displacement,real)
*if(cond(X-Enforced_Displacement,real)<0)
*format "FORCE%11i%8i%8i%7i.     -1.%7i.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*else
*format "FORCE%11i%8i%8i%7i.      1.%7i.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*endif
*format "SPC%13i%8i       1%7i."
*SID*NodesNum*ID0
*endif
*if(cond(Y-Enforced_Displacement,real)!=0)
*format "SPCD%12i%8i       2%#8.5g"
*SID*NodesNum*cond(Y-Enforced_Displacement,real)
*if(cond(Y-Enforced_Displacement,real)<0)
*format "FORCE%11i%8i%8i%7i.%7i.     -1.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*else
*format "FORCE%11i%8i%8i%7i.%7i.      1.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*endif
*format "SPC%13i%8i       2%7i."
*SID*NodesNum*ID0
*endif
*if(cond(Z-Enforced_Displacement,real)!=0)
*format "SPCD%12i%8i       3%#8.5g"
*SID*NodesNum*cond(Z-Enforced_Displacement,real)
*if(cond(Z-Enforced_Displacement,real)<0)
*format "FORCE%11i%8i%8i%7i.%7i.%7i.     -1."
*SID*NodesNum*ID0*ID0*ID0*ID0
*else
*format "FORCE%11i%8i%8i%7i.%7i.%7i.      1."
*SID*NodesNum*ID0*ID0*ID0*ID0
*endif
*format "SPC%13i%8i       3%7i."
*SID*NodesNum*ID0
*endif
*if(cond(Mx-Enforced_Displacement,real)!=0)
*format "SPCD%12i%8i       4%#8.5g"
*SID*NodesNum*cond(Mx-Enforced_Displacement,real)
*if(cond(Mx-Enforced_Displacement,real)<0)
*format "MOMENT%10i%8i%8i%7i.     -1.%7i.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*else
*format "MOMENT%10i%8i%8i%7i.      1.%7i.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*endif
*format "SPC%13i%8i       4%7i."
*SID*NodesNum*ID0
*endif
*if(cond(My-Enforced_Displacement,real)!=0)
*format "SPCD%12i%8i       5%#8.5g"
*SID*NodesNum*cond(My-Enforced_Displacement,real)
*if(cond(My-Enforced_Displacement,real)<0)
*format "MOMENT%10i%8i%8i%7i.%7i.     -1.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*else
*format "MOMENT%10i%8i%8i%7i.%7i.      1.%7i."
*SID*NodesNum*ID0*ID0*ID0*ID0
*endif
*format "SPC%13i%8i       5%7i."
*SID*NodesNum*ID0
*endif
*if(cond(Mz-Enforced_Displacement,real)!=0)
*format "SPCD%12i%8i       6%#8.5g"
*SID*NodesNum*cond(Mz-Enforced_Displacement,real)
*if(cond(Mz-Enforced_Displacement,real)<0)
*format "MOMENT%10i%8i%8i%7i.%7i.%7i.     -1."
*SID*NodesNum*ID0*ID0*ID0*ID0
*else
*format "MOMENT%10i%8i%8i%7i.%7i.%7i.      1."
*SID*NodesNum*ID0*ID0*ID0*ID0
*endif
*format "SPC%13i%8i       6%7i."
*SID*NodesNum*ID0
*endif
*end nodes
*endif
*set elems(Linear)
*Set Cond Line-Pressure-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*if(strcmp(cond(1),"BASIC")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX      FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY      FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ      FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(1),"ELEMENT")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE      FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE      FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE      FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*end elems
*endif
*set elems(Linear)
*Set Cond Line-Projected-Pressure-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*if(strcmp(cond(1),"BASIC")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(1),"ELEMENT")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*end elems
*endif
*set elems(Linear)
*Set Cond Line-Triangular-Pressure-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*if(strcmp(cond(1),"BASIC")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX       FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(X-Pressure_Start_Point)*ID1*cond(X-Pressure_End_Point)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY        FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Y-Pressure_Start_Point)*ID1*cond(Y-Pressure_End_Point)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ        FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Z-Pressure_Start_Point)*ID1*cond(Z-Pressure_End_Point)
*endif
*endif
*if(strcmp(cond(1),"ELEMENT")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE       FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(X-Pressure_Start_Point)*ID1*cond(X-Pressure_End_Point)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE        FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Y-Pressure_Start_Point)*ID1*cond(Y-Pressure_End_Point)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE        FR%#7i.%#8.5g%#7i.%#8.5g"
*SID*ElemsNum*ID0*cond(Z-Pressure_Start_Point)*ID1*cond(Z-Pressure_End_Point)
*endif
*endif
*end elems
*endif
*set elems(triangle)
*Set Cond Surface-Pressure-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PLOAD4*%17i%16i%#16g                *P4%5i"
*SID*ElemsNum*norma*ElemsNum
*format "*P4%5i                                                                *P5%5i"
*ElemsNum*ElemsNum
*format "*P5%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PLOAD4%10i%8i%#8.5g                                        +P4%5i"
*SID*ElemsNum*norma*ElemsNum
*format "+P4%5i%8i%#8.5g%#8.5g%#8.5g"
*ElemsNum*ID0*x1*x2*x3
*endif
*end elems
*endif
*Set elems(quadrilateral)
*Set Cond Surface-Pressure-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PLOAD4*%17i%16i%#16g                *P4%5i"
*SID*ElemsNum*norma*ElemsNum
*format "*P4%5i                                                                *P5%5i"
*ElemsNum*ElemsNum
*format "*P5%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PLOAD4%10i%8i%#8.5g                                        +P4%5i"
*SID*ElemsNum*norma*ElemsNum
*format "+P4%5i%8i%#8.5g%#8.5g%#8.5g"
*ElemsNum*ID0*x1*x2*x3
*endif
*end elems
*endif
*set elems(triangle)
*Set Cond Normal-Surface-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "PLOAD4%10i%8i%#8.5g"
*SID*ElemsNum*cond(Normal_Inward,real)
*end elems
*endif
*Set elems(quadrilateral)
*Set Cond Normal-Surface-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "PLOAD4%10i%8i%#8.5g"
*SID*ElemsNum*cond(Normal_Inward,real)
*end elems
*endif
*Set elems(tetrahedra)
*Set Cond Normal-Surface-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*if(strcmp(GenData(Format_File),"Small")==0)
*if(GlobalNodes(1,int)==ElemsConec(1,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*ElemsConec(4)
*endif
*if(GlobalNodes(1,int)==ElemsConec(2,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*ElemsConec(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(3,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*ElemsConec(2)
*endif
*if(GlobalNodes(1,int)==ElemsConec(4,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*ElemsConec(3)
*endif
*endif
*if(strcmp(GenData(Format_File),"Large")==0)
*if(GlobalNodes(1,int)==ElemsConec(1,int))
*format "PLOAD4*%17i%16i%#16g                *PS%5i"
*SID*ElemsNum*cond(Normal_Inward)*ElemsNum
*format "*PS%5i                                %16i%16i"
*ElemsNum*Globalnodes(1)*ElemsConec(4)
*endif
*if(GlobalNodes(1,int)==ElemsConec(2,int))
*format "PLOAD4*%17i%16i%#16g                *PS%5i"
*SID*ElemsNum*cond(Normal_Inward)*ElemsNum
*format "*PS%5i                                %16i%16i"
*ElemsNum*Globalnodes(1)*ElemsConec(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(3,int))
*format "PLOAD4*%17i%16i%#16g                *PS%5i"
*SID*ElemsNum*cond(Normal_Inward)*ElemsNum
*format "*PS%5i                                %16i%16i"
*ElemsNum*Globalnodes(1)*ElemsConec(2)
*endif
*if(GlobalNodes(1,int)==ElemsConec(4,int))
*format "PLOAD4*%17i%16i%#16g                *PS%5i"
*SID*ElemsNum*cond(Normal_Inward)*ElemsNum
*format "*PS%5i                                %16i%16i"
*ElemsNum*Globalnodes(1)*ElemsConec(3)
*endif
*endif
*end elems
*endif
*Set elems(hexahedra)
*Set Cond  Normal-Surface-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*if((GlobalNodes(1,int)==ElemsConec(3,int))&&(GlobalNodes(2,int)==ElemsConec(7,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*Globalnodes(3)
*endif
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(4,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*Globalnodes(3)
*endif
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(2,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*Globalnodes(3)
*endif
*if((GlobalNodes(1,int)==ElemsConec(2,int))&&(GlobalNodes(2,int)==ElemsConec(6,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*Globalnodes(3)
*endif
*if((GlobalNodes(1,int)==ElemsConec(5,int))&&(GlobalNodes(2,int)==ElemsConec(8,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*Globalnodes(3)
*endif
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(5,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i"
*SID*ElemsNum*cond(Normal_Inward)*Globalnodes(1)*Globalnodes(3)
*endif
*end elems
*endif
*Set elems(tetrahedra)
*Set Cond Surface-Pressure-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if(GlobalNodes(1,int)==ElemsConec(1,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*ElemsConec(4)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(GlobalNodes(1,int)==ElemsConec(2,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*ElemsConec(1)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(GlobalNodes(1,int)==ElemsConec(3,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*ElemsConec(2)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(GlobalNodes(1,int)==ElemsConec(4,int))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*ElemsConec(3)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*end elems
*endif
*Set elems(hexahedra)
*Set Cond Surface-Pressure-Load *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if((GlobalNodes(1,int)==ElemsConec(3,int))&&(GlobalNodes(2,int)==ElemsConec(7,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*Globalnodes(3)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(4,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*Globalnodes(3)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(2,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*Globalnodes(3)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if((GlobalNodes(1,int)==ElemsConec(2,int))&&(GlobalNodes(2,int)==ElemsConec(6,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*Globalnodes(3)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if((GlobalNodes(1,int)==ElemsConec(5,int))&&(GlobalNodes(2,int)==ElemsConec(8,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*Globalnodes(3)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(5,int)))
*format "PLOAD4%10i%8i%#8.5g%32i%8i*P4%5i"
*SID*ElemsNum*norma*Globalnodes(1)*Globalnodes(3)*ElemsNum
*format "*P4%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*end elems
*endif
*end intervals
*if(strcmp(GenData(Consider_Acceleration),"YES")==0)
*set var SID=SID+1
*format "GRAV%12i%8i%#8.5g%#8.5g%#8.5g%#8.5g"
*SID*ID0*GenData(Modul_Acceleration)*GenData(X-Acceleration_Vector)*GenData(Y-Acceleration_Vector)*GenData(z-Acceleration_Vector)
*endif
*#----------------------------------------------------------------------------------
*#
*#                        DYNAMICS LOADS
*#
*#----------------------------------------------------------------------------------
*set var tablenum=0
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*if(strcmp(matprop(Value_type),"vs._Time")==0 || strcmp(matprop(Value_type),"vs._Frequency")==0 ) 
*set var tablenum=matnum(int)
*if(strcmp(matprop(Table_Interpolation_Values,1),"none")!=0)
*if(strcmp(matprop(Type_of_Interpolation),"TABLED1")==0)
*format "TABLED1%9i                                                        +T%6i"
*matnum*matnum         
*format "+T%6i"
*matnum*\
*endif
*if(strcmp(matprop(Type_of_Interpolation),"TABLED2")==0)
*format "TABLED2%9i%#8.5g                                                +S%6i"
*matnum*matprop(Table_parameter1)*matnum         
*format "+S%6i"
*matnum*\
*endif
*if(strcmp(matprop(Type_of_Interpolation),"TABLED3")==0)
*format "TABLED3%9i%#8.5g%#8.5g                                        +R%6i"
*matnum*matprop(Table_parameter1)*matprop(Table_parameter2)*matnum         
*format "+R%6i"
*matnum*\
*endif
*if(strcmp(matprop(Type_of_Interpolation),"TABLED4")==0)
*format "TABLED4%9i%#8.5g%#8.5g                               +M%6i"
*matnum*matprop(Table_parameter1)*matprop(Table_parameter2)*matprop(Table_parameter3)*matprop(Table_parameter4)*matnum       
*format "+M%6i"
*matnum*\
*endif
*set var line=0
*set var counter=0
*for(i=1;i<=matprop(Table_Interpolation_Values,int);i=i+1)
*if(strcmp(matprop(Table_Interpolation_Values,*i),"none")!=0 && line!=8)
*format "%#8.5g"
*matprop(Table_Interpolation_Values,*i,real)*\
*set var line=line+1
*endif
*if(strcmp(matprop(Table_Interpolation_Values,*i),"none")!=0 && line==8)
*set var counter=counter+1
*if(strcmp(matprop(Type_of_Interpolation),"TABLED1")==0)
*format "+T%3i%3i"
*matnum*counter
*format "+T%3i%3i"
*matnum*counter*\
*set var line=0
*endif
*if(strcmp(matprop(Type_of_Interpolation),"TABLED2")==0)
*format "+S%3i%3i"
*matnum*counter
*format "+S%3i%3i"
*matnum*counter*\
*set var line=0
*endif
*if(strcmp(matprop(Type_of_Interpolation),"TABLED3")==0)
*format "+R%3i%3i"
*matnum*counter
*format "+R%3i%3i"
*matnum*counter*\
*set var line=0
*endif
*if(strcmp(matprop(Type_of_Interpolation),"TABLED4")==0)
*format "+M%3i%3i"
*matnum*counter
*format "+M%3i%3i"
*matnum*counter*\
*set var line=0
*endif
*endif
*if(strcmp(matprop(Table_Interpolation_Values,*i),"none")==0)
*set var i = matprop(Table_Interpolation_Values,int)+1
    ENDT
*endif
*endfor
*endif
*endif
*endif
*end materials
*Set Cond Point_Freq_Dynamic_Type1 *nodes *CanRepeat
*add Cond Line_Freq_Dynamic_Type1 *nodes *CanRepeat
*add Cond Surface_Freq_Dynamic_Type1 *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*if(strcmp(cond(Degree_of_freedom),"1-X")==0)
*set var dof1=1
*endif
*if(strcmp(cond(Degree_of_freedom),"2-Y")==0)
*set var dof1=2
*endif
*if(strcmp(cond(Degree_of_freedom),"3-Z")==0)
*set var dof1=3
*endif
*if(strcmp(cond(Degree_of_freedom),"4-RX")==0)
*set var dof1=4
*endif
*if(strcmp(cond(Degree_of_freedom),"5-RY")==0)
*set var dof1=5
*endif
*if(strcmp(cond(Degree_of_freedom),"6-RZ")==0)
*set var dof1=6
*endif
*format "DAREA%11i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_C[f]))*NodesNum*dof1*cond(Scale_Factor(A),real)
*format "DELAY%11i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_C[f]))*NodesNum*dof1*cond(Time_Delay(T),real)
*format "DPHASE%10i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_C[f]))*NodesNum*dof1*cond(Phase_Lead(O),real)
*end nodes
*endif
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*set var cntrl=0
*set var cntrlT2=1
*loop nodes *OnlyInCond
*if(matnum(int)==matnum(cond(Table_Interpolation_Values_C[f]),int))
*set var cntrl=1
*set var T2=matnum(cond(Table_Interpolation_Values_D[f]),int)
*loop materials *NotUsed
*if( matnum(int)==T2)
*if(strcmp(matprop(Table_Interpolation_Values,1),"none")==0)
*set var cntrlT2=0
*endif
*endif
*end materials
*break
*endif
*end nodes
*if(cntrl==1 && cntrlT2==0)
*format "RLOAD1%10i%8i%8i%8i%8i"
*matnum*matnum*matnum*matnum*matnum 
*endif
*if(cntrl==1 && cntrlT2==1)
*format "RLOAD1%10i%8i%8i%8i%8i%8i"
*matnum*matnum*matnum*matnum*matnum*T2 
*endif
*endif
*end materials
*Set Cond Point_Freq_Dynamic_Type2 *nodes *CanRepeat
*add Cond Line_Freq_Dynamic_Type2 *nodes *CanRepeat
*add Cond Surface_Freq_Dynamic_Type2 *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*if(strcmp(cond(Degree_of_freedom),"1-X")==0)
*set var dof1=1
*endif
*if(strcmp(cond(Degree_of_freedom),"2-Y")==0)
*set var dof1=2
*endif
*if(strcmp(cond(Degree_of_freedom),"3-Z")==0)
*set var dof1=3
*endif
*if(strcmp(cond(Degree_of_freedom),"4-RX")==0)
*set var dof1=4
*endif
*if(strcmp(cond(Degree_of_freedom),"5-RY")==0)
*set var dof1=5
*endif
*if(strcmp(cond(Degree_of_freedom),"6-RZ")==0)
*set var dof1=6
*endif
*format "DAREA%11i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_B[f]))*NodesNum*dof1*cond(Scale_Factor(A),real)
*format "DELAY%11i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_B[f]))*NodesNum*dof1*cond(Time_Delay(T),real)
*format "DPHASE%10i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_B[f]))*NodesNum*dof1*cond(Phase_Lead(O),real)
*end nodes
*endif
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*set var cntrl=0
*set var cntrlT2=1
*loop nodes *OnlyInCond
*if(matnum(int)==matnum(cond(Table_Interpolation_Values_C[f]),int))
*set var cntrl=1
*set var T2=matnum(cond(Table_Interpolation_Values_D[f]),int)
*loop materials *NotUsed
*if( matnum(int)==T2)
*if(strcmp(matprop(Table_Interpolation_Values,1),"none")==0)
*set var cntrlT2=0
*endif
*endif
*end materials
*break
*endif
*end nodes
*if(cntrl==1 && cntrlT2==0)
*format "RLOAD1%10i%8i%8i%8i%8i"
*matnum*matnum*matnum*matnum*matnum 
*endif
*if(cntrl==1 && cntrlT2==1)
*format "RLOAD2%10i%8i%8i%8i%8i%8i"
*matnum*matnum*matnum*matnum*matnum*T2 
*endif
*endif
*end materials
*set Cond Point_Time_Dynamic_Type1 *nodes *CanRepeat
*add Cond Line_Time_Dynamic_Type1 *nodes *CanRepeat
*add Cond Surface_Time_Dynamic_Type1 *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*if(strcmp(cond(Degree_of_freedom),"1-X")==0)
*set var dof1=1
*endif
*if(strcmp(cond(Degree_of_freedom),"2-Y")==0)
*set var dof1=2
*endif
*if(strcmp(cond(Degree_of_freedom),"3-Z")==0)
*set var dof1=3
*endif
*if(strcmp(cond(Degree_of_freedom),"4-RX")==0)
*set var dof1=4
*endif
*if(strcmp(cond(Degree_of_freedom),"5-RY")==0)
*set var dof1=5
*endif
*if(strcmp(cond(Degree_of_freedom),"6-RZ")==0)
*set var dof1=6
*endif
*format "DAREA%11i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_F[t-T]))*NodesNum*dof1*cond(Scale_Factor(A),real)
*format "DELAY%11i%8i%8i%#8.5g"
*matnum(cond(Table_Interpolation_Values_F[t-T]))*NodesNum*dof1*cond(Time_Delay(T),real)
*end nodes
*endif
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*set var cntrl=0
*loop nodes *OnlyInCond
*if(matnum(int)==matnum(cond(Table_Interpolation_Values_F[t-T]),int))
*set var cntrl=1
*endif
*end nodes
*if(cntrl==1)
*format "TLOAD1%10i%8i%8i        %8i"
*matnum*matnum*matnum*matnum 
*endif
*endif
*end materials
*set var IDload=tablenum+1
*set Cond Point_Time_Dynamic_Type2 *nodes *CanRepeat
*add Cond Line_Time_Dynamic_Type2 *nodes *CanRepeat
*add Cond Surface_Time_Dynamic_Type2 *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*format "TLOAD2%10i%8i%8i        %#8.5g%#8.5g%#8.5g%#8.5g+T2%5i"
*IDload*IDload*IDload*cond(Inferior_Time_Limit(T1))*cond(Superior_Time_Limit(T2))*cond(Frequency)*cond(Phase)*IDload
*format "+T2%5i%#8.5g%#8.5g"
*IDload*cond(Exponential)*cond(Growth)
*if(strcmp(cond(Degree_of_freedom),"1-X")==0)
*set var dof1=1
*endif
*if(strcmp(cond(Degree_of_freedom),"2-Y")==0)
*set var dof1=2
*endif
*if(strcmp(cond(Degree_of_freedom),"3-Z")==0)
*set var dof1=3
*endif
*if(strcmp(cond(Degree_of_freedom),"4-RX")==0)
*set var dof1=4
*endif
*if(strcmp(cond(Degree_of_freedom),"5-RY")==0)
*set var dof1=5
*endif
*if(strcmp(cond(Degree_of_freedom),"6-RZ")==0)
*set var dof1=6
*endif
*format "DAREA%11i%8i%8i%#8.5g"
*IDload*NodesNum*dof1*cond(Scale_Factor(A),real)
*format "DELAY%11i%8i%8i%#8.5g"
*IDload*NodesNum*dof1*cond(Time_Delay(T),real)
*end nodes
*endif
*set Cond Point_cosine/sine_Load *nodes *CanRepeat
*add Cond Line_cosine/sine_Load *nodes *CanRepeat
*add Cond surface_cosine/sine_Load *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*set var IDload=IDload+1
*format "TLOAD2%10i%8i%8i        %8f%8f%#8.5g%#8.5g+T2%5i"
*IDload*IDload*IDload*cond(Inferior_Time_Limit(T1))*cond(Superior_Time_Limit(T2))*cond(Frequency)*cond(Phase)*IDload
*format "+T2%5i%7i.%7i."
*IDload*ID0*ID0
*if(strcmp(cond(Degree_of_freedom),"1-X")==0)
*set var dof1=1
*endif
*if(strcmp(cond(Degree_of_freedom),"2-Y")==0)
*set var dof1=2
*endif
*if(strcmp(cond(Degree_of_freedom),"3-Z")==0)
*set var dof1=3
*endif
*if(strcmp(cond(Degree_of_freedom),"4-RX")==0)
*set var dof1=4
*endif
*if(strcmp(cond(Degree_of_freedom),"5-RY")==0)
*set var dof1=5
*endif
*if(strcmp(cond(Degree_of_freedom),"6-RZ")==0)
*set var dof1=6
*endif
*format "DAREA%11i%8i%8i%#8.5g"
*IDload*NodesNum*dof1*cond(Amplitude(A),real)
*format "DELAY%11i%8i%8i%#8.5g"
*IDload*NodesNum*dof1*cond(Time_Delay(T),real)
*end nodes
*endif 
*set var IDpresurf=IDload
*set elems(all)
*set Cond Surface_Pressure_Freq_Type1 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpresurf*IDpresurf
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PLOAD4*%17i%16i%#16g                *P4%5i"
**IDpresurf*ElemsNum*norma*ElemsNum
*format "*P4%5i                                                                *P5%5i"
*ElemsNum*ElemsNum
*format "*P5%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PLOAD4%10i%8i%#8.5g                                        +P4%5i"
**IDpresurf*ElemsNum*norma*ElemsNum
*format "+P4%5i%8i%#8.5g%#8.5g%#8.5g"
*ElemsNum*ID0*x1*x2*x3
*endif
*set var T2=matnum(cond(Table_Interpolation_Values_D[f]),int)
*set var cntrlT2=1
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*if( matnum(int)==T2)
*if(strcmp(matprop(Table_Interpolation_Values,1),"none")==0)
*set var cntrlT2=0
*endif
*endif
*endif
*end materials
*if(cntrlT2==0)
*format "RLOAD1%10i%8i                %8i"
*IDpresurf*IDpresurf*matnum(cond(Table_Interpolation_Values_C[f]),int)
*endif
*if(cntrlT2==1)
*format "RLOAD1%10i%8i                %8i%8i"
*IDpresurf*IDpresurf*matnum(cond(Table_Interpolation_Values_C[f]),int)*T2 
*endif
*set var IDpresurf=IDpresurf+1
*end elems
*endif
*set Cond Surface_Pressure_Freq_Type2 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpresurf*IDpresurf
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PLOAD4*%17i%16i%#16g                *P4%5i"
*IDpresurf*ElemsNum*norma*ElemsNum
*format "*P4%5i                                                                *P5%5i"
*ElemsNum*ElemsNum
*format "*P5%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PLOAD4%10i%8i%#8.5g                                        +P4%5i"
*IDpresurf*ElemsNum*norma*ElemsNum
*format "+P4%5i%8i%#8.5g%#8.5g%#8.5g"
*ElemsNum*ID0*x1*x2*x3
*endif
*set var T2=matnum(cond(Table_Interpolation_Values_h[f]),int)
*set var cntrlT2=1
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*if( matnum(int)==T2)
*if(strcmp(matprop(Table_Interpolation_Values,1),"none")==0)
*set var cntrlT2=0
*endif
*endif
*endif
*end materials
*if(cntrlT2==0)
*format "RLOAD2%10i%8i                %8i"
*IDpresurf*IDpresurf*matnum(cond(Table_Interpolation_Values_B[f]),int)
*endif
*if(cntrlT2==1)
*format "RLOAD1%10i%8i                %8i%8i"
*IDpresurf*IDpresurf*matnum(cond(Table_Interpolation_Values_h[f]),int)*T2 
*endif
*set var IDpresurf=IDpresurf+1
*end elems
*endif
*set Cond Surface_Pressure_Time_Type1 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpresurf*IDpresurf
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PLOAD4*%17i%16i%#16g                *P4%5i"
**IDpresurf*ElemsNum*norma*ElemsNum
*format "*P4%5i                                                                *P5%5i"
*ElemsNum*ElemsNum
*format "*P5%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PLOAD4%10i%8i%#8.5g                                        +P4%5i"
**IDpresurf*ElemsNum*norma*ElemsNum
*format "+P4%5i%8i%#8.5g%#8.5g%#8.5g"
*ElemsNum*ID0*x1*x2*x3
*endif
*format "TLOAD1%10i%8i                %8i"
*IDpresurf*IDpresurf*matnum(cond(Table_Interpolation_Values_F[t-T]),int)
*set var IDpresurf=IDpresurf+1
*end elems
*endif
*set Cond Surface_Pressure_Time_Type2 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpresurf*IDpresurf
*set var x1=cond(X-Pressure,real)*cond(X-Pressure,real)
*Set var x2=cond(Y-Pressure,real)*cond(Y-Pressure,real)
*set var x3=cond(Z-Pressure,real)*cond(Z-Pressure,real)
*set var norma=sqrt(x1+x2+x3)
*set var x1=cond(X-Pressure,real)/norma
*set var x2=cond(Y-Pressure,real)/norma
*set var x3=cond(Z-Pressure,real)/norma
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PLOAD4*%17i%16i%#16g                *P4%5i"
**IDpresurf*ElemsNum*norma*ElemsNum
*format "*P4%5i                                                                *P5%5i"
*ElemsNum*ElemsNum
*format "*P5%5i%16i%#16g%#16g%#16g"        
*ElemsNum*ID0*x1*x2*x3
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PLOAD4%10i%8i%#8.5g                                        +P4%5i"
**IDpresurf*ElemsNum*norma*ElemsNum
*format "+P4%5i%8i%#8.5g%#8.5g%#8.5g"
*ElemsNum*ID0*x1*x2*x3
*endif
*format "TLOAD2%10i%8i                %#8.5g%#8.5g%#8.5g%#8.5g+T2%5i"
*IDpresurf*IDpresurf*cond(Inferior_Time_Limit(T1))*cond(Superior_Time_Limit(T2))*cond(Frequency)*cond(Phase)*IDpresurf
*format "+T2%5i%#8.5g%#8.5g"
*IDpresurf*cond(Exponential)*cond(Growth)
*set var IDpresurf=IDpresurf+1
*end elems
*endif
*set var IDpreline=IDpresurf
*set elems(Linear)
*Set Cond Line_Pressure_Freq_Type1 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpreline*IDpreline
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*set var T2=matnum(cond(Table_Interpolation_Values_D[f]),int)
*set var cntrlT2=1
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*if( matnum(int)==T2)
*if(strcmp(matprop(Table_Interpolation_Values,1),"none")==0)
*set var cntrlT2=0
*endif
*endif
*endif
*end materials
*if(cntrlT2==0)
*format "RLOAD1%10i%8i                %8i"
*IDpreline*IDpreline*matnum(cond(Table_Interpolation_Values_C[f]),int)
*endif
*if(cntrlT2==1)
*format "RLOAD1%10i%8i                %8i%8i"
*IDpreline*IDpreline*matnum(cond(Table_Interpolation_Values_C[f]),int)*T2 
*endif
*set var IDpreline=IDpreline+1
*end elems
*endif
*Set Cond Line_Pressure_Freq_Type2 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpreline*IDpreline
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*set var T2=matnum(cond(Table_Interpolation_Values_h[f]),int)
*set var cntrlT2=1
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*if( matnum(int)==T2)
*if(strcmp(matprop(Table_Interpolation_Values,1),"none")==0)
*set var cntrlT2=0
*endif
*endif
*endif
*end materials
*if(cntrlT2==0)
*format "RLOAD2%10i%8i                %8i"
*IDpreline*IDpreline*matnum(cond(Table_Interpolation_Values_B[f]),int)
*endif
*if(cntrlT2==1)
*format "RLOAD2%10i%8i                %8i%8i"
*IDpreline*IDpreline*matnum(cond(Table_Interpolation_Values_B[f]),int)*T2 
*endif
*set var IDpreline=IDpreline+1
*end elems
*endif
*Set Cond Line_Pressure_Time_Type1 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpreline*IDpreline
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*format "TLOAD1%10i%8i                %8i"
*IDpreline*IDpreline*matnum(cond(Table_Interpolation_Values_F[t-T]),int)
*set var IDpreline=IDpreline+1
*end elems
*endif
*Set Cond Line_Pressure_Time_Type2 *elems *CanRepeat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "LSEQ%12i%8i%8i"
*ID1*IDpreline*IDpreline
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"NORMAL")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE      FR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"BASIC")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FX    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i      FY    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i      FZ    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*if(strcmp(cond(Coord_System),"ELEMENT")==0 && strcmp(cond(Load_Type),"PROJECTED")==0)
*if(cond(X-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FXE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(X-Pressure)*ID1*cond(X-Pressure)
*endif
*if(cond(Y-Pressure,real)!=0)
*format "PLOAD1%10i%8i     FYE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Y-Pressure)*ID1*cond(Y-Pressure)
*endif
*if(cond(Z-Pressure,real)!=0 )
*format "PLOAD1%10i%8i     FZE    FRPR%#7i.%#8.5g%#7i.%#8.5g"
*IDpreline*ElemsNum*ID0*cond(Z-Pressure)*ID1*cond(Z-Pressure)
*endif
*endif
*format "TLOAD2%10i%8i                %#8.5g%#8.5g%#8.5g%#8.5g+T2%5i"
*IDpreline*IDpreline*cond(Inferior_Time_Limit(T1))*cond(Superior_Time_Limit(T2))*cond(Frequency)*cond(Phase)*IDpreline
*format "+T2%5i%#8.5g%#8.5g"
*IDpreline*cond(Exponential)*cond(Growth)
*set var IDpreline=IDpreline+1
*end elems
*endif
*set var first=1
*set var cntrl=0
*set var line=0
*loop materials *NotUsed
*if(matprop(Table,int)==1)
*set var cntrl=0
*Set Cond Point_Freq_Dynamic_Type1 *nodes *CanRepeat
*add Cond Line_Freq_Dynamic_Type1 *nodes *CanRepeat
*add Cond Surface_Freq_Dynamic_Type1 *nodes *CanRepeat
*loop nodes *OnlyInCond
*if(matnum(int)==matnum(cond(Table_Interpolation_Values_C[f]),int))
*set var cntrl=1
*break
*endif
*end nodes
*Set Cond Point_Freq_Dynamic_Type2 *nodes *CanRepeat
*add Cond Line_Freq_Dynamic_Type2 *nodes *CanRepeat
*add Cond Surface_Freq_Dynamic_Type2 *nodes *CanRepeat
*loop nodes *OnlyInCond
*if(matnum(int)==matnum(cond(Table_Interpolation_Values_B[f]),int))
*set var cntrl=1
*break
*endif
*end nodes
*set Cond Point_Time_Dynamic_Type1 *nodes *CanRepeat
*add Cond Line_Time_Dynamic_Type1 *nodes *CanRepeat
*add Cond Surface_Time_Dynamic_Type1 *nodes *CanRepeat
*loop nodes *OnlyInCond
*if(matnum(int)==matnum(cond(Table_Interpolation_Values_F[t-T]),int))
*set var cntrl=1
*break
*endif
*end nodes
*if(first==1 && cntrl==1)
*set var line=2
*format "DLOAD%11i%7i."
*ID1*ID1*\
*set var first=0
*endif
*if(line==8 && cntrl==1)
*format "+D%3i%3i"
*matnum(int)*matnum(int)
*format "+D%3i%3i"
*matnum(int)*matnum(int)*\
*set var line=0
*endif 
*if(line!=8 && cntrl==1)
*format "%7i.%8i"
*ID1*matnum(int)*\
*endif
*if(cntrl==1)
*set var line=line+2
*endif
*endif
*end materials

*set var IDload=tablenum
*set Cond Point_Time_Dynamic_Type2 *nodes *CanRepeat
*add Cond Line_Time_Dynamic_Type2 *nodes *CanRepeat
*add Cond Surface_Time_Dynamic_Type2 *nodes *CanRepeat
*add Cond Point_cosine/sine_Load *nodes *CanRepeat
*add Cond Line_cosine/sine_Load *nodes *CanRepeat
*add Cond surface_cosine/sine_Load *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*if(first==1)
*set var line=2
*format "DLOAD%11i%7i."
*ID1*ID1*\
*set var first=0
*endif
*if(line==8)
*format "+D%6i"
*NodesNum(int)
*format "+D%6i"
*NodesNum(int)*\
*set var line=0
*endif 
*if(line!=8) 
*set var IDload=IDload+1
*format "%7i.%8i"
*ID1*IDload*\
*endif
*set var line=line+2
*end nodes
*endif
*set var IDpresurf=IDload
*set elems(all)
*set Cond Surface_Pressure_Freq_Type1 *elems
*add Cond Surface_Pressure_Freq_Type2 *elems
*add cond Surface_Pressure_Time_Type1 *elems
*add Cond Surface_Pressure_Time_Type2 *elems 
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*if(first==1)
*set var line=2
*format "DLOAD%11i%7i."
*ID1*ID1*\
*set var first=0
*endif
*if(line==8)
*format "+D%6i"
*IDpresurf(int)
*format "+D%6i"
*IDpresurf(int)*\
*set var line=0
*endif 
*if(line!=8) 
*set var IDpresurf=IDpresurf+1
*format "%7i.%8i"
*ID1*IDpresurf*\
*endif
*set var line=line+2
*end elems
*endif
*set var IDpreline=IDpresurf
*set elems(linear)
*set Cond Line_Pressure_Freq_Type1 *elems
*add Cond Line_Pressure_Freq_Type2 *elems
*add cond Line_Pressure_Time_Type1 *elems
*add Cond Line_Pressure_Time_Type2 *elems 
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*if(first==1)
*set var line=2
*format "DLOAD%11i%7i."
*ID1*ID1*\
*set var first=0
*endif
*if(line==8)
*format "+D%6i"
*IDpresurf(int)
*format "+D%6i"
*IDpresurf(int)*\
*set var line=0
*endif 
*if(line!=8) 
*set var IDpresurf=IDpresurf+1
*format "%7i.%8i"
*ID1*IDpresurf*\
*endif
*set var line=line+2
*end elems
*endif
*#----------------------------------------------------------------------------------
*#
*#                        HEAT BOUNDRIES
*#
*#----------------------------------------------------------------------------------
*loop intervals
*set var propID=nmats+1
*set cond Point_Heat_Boundary *nodes
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*set var elemID= nelem+NodesNum
*format "CHBDYP%10i%8i   POINT                %8i                +HB%5i" 
*elemID*propID*NodesNum*elemID
*format "+HB%5i%8i                        %#8.5g%#8.5g%#8.5g"
*elemID*propID*cond(V_x)*cond(V_y)*cond(V_z)
*format "PHBDY%11i%#8.5g"
*propID*cond(Area_factor)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end nodes
*endif
*set elems(linear)
*set cond Line_Heat_Boundary *elems
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "CHBDYP%10i%8i    LINE                %8i%8i        +HB%5i" 
*elemID*propID*elemsConec(1)*elemsConec(2)*elemID
*format "+HB%5i%8i                        %#8.5g%#8.5g%#8.5g"
*elemID*propID*cond(V_x)*cond(V_y)*cond(V_z)
*format "PHBDY%11i%#8.5g"
*propID*cond(Area_factor)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end elems
*endif
*Set elems(triangle)
*set cond Line_Heat_Boundary *elems
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "CHBDYP%10i%8i    LINE                %8i%8i        +HB%5i" 
*elemID*propID*GlobalNodes(1)*GlobalNodes(2)*elemID
*format "+HB%5i%8i                        %#8.5g%#8.5g%#8.5g"
*elemID*propID*cond(V_x)*cond(V_y)*cond(V_z)
*format "PHBDY%11i%#8.5g"
*propID*cond(Area_factor)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end elems
*endif
*set cond Surface_Heat_Boundary *elems
*if(CondnumEntities(int)>0 && IsQuadratic(int)==0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "CHBDYG%10i           AREA3                %8i                +HB%5i" 
*elemID*propID*elemID
*format "+HB%5i%8i%8i%8i"
*elemID*elemsconec(1)*elemsconec(2)*elemsconec(3)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end elems
*endif
*Set elems(quadrilateral)
*set cond Line_Heat_Boundary *elems
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "CHBDYP%10i%8i    LINE                %8i%8i        +HB%5i" 
*elemID*propID*GlobalNodes(1)*GlobalNodes(2)*elemID
*format "+HB%5i%8i                        %#8.5g%#8.5g%#8.5g"
*elemID*propID*cond(V_x)*cond(V_y)*cond(V_z)
*format "PHBDY%11i%#8.5g"
*propID*cond(Area_factor)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end elems
*endif
*set cond Surface_Heat_Boundary *elems
*if(CondnumEntities(int)>0 && IsQuadratic(int)==0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "CHBDYG%10i           AREA4                %8i                +HB%5i" 
*elemID*propID*elemID
*format "+HB%5i%8i%8i%8i"
*elemID*elemsconec(1)*elemsconec(2)*elemsconec(3)*elemsconec(4)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end elems
*endif
*set elems(tetrahedra)
*set cond Surface_Heat_Boundary *elems
*if(CondnumEntities(int)>0 && IsQuadratic(int)==0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "CHBDYG%10i           AREA3                %8i                +HB%5i" 
*elemID*propID*elemID
*format "+HB%5i%8i%8i%8i"
*elemID*GlobalNodes(3)*GlobalNodes(2)*GlobalNodes(1)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end elems
*endif
*set elems(hexahedra)
*set cond Surface_Heat_Boundary *elems
*if(CondnumEntities(int)>0 && IsQuadratic(int)==0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "CHBDYG%10i           AREA4                %8i                +HB%5i" 
*elemID*propID*elemID
*format "+HB%5i%8i%8i%8i"
*elemID*GlobalNodes(4)*GlobalNodes(3)*GlobalNodes(2)*GlobalNodes(1)*\
*tcl(heatboundaries::setvarabsor *cond(Absorptivity)) *tcl(heatboundaries::setvaremiss *cond(Emissivity))
*tcl(heatboundaries::write2bas *propID)
*set var propID=propID+1
*end elems
*endif
*end intervals
*#----------------------------------------------------------------------------------
*#
*#                        THERMAL LOADS
*#
*#----------------------------------------------------------------------------------
*loop intervals 
*set var SID=loopvar
*set var ispoint=0
*set var ispointr=0
*set cond Point_Initial_Temperature *nodes 
*add cond  Surface_Initial_Temperature *nodes
*add cond Line_Initial_Temperature *nodes
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*format "TEMP%12i%8i%#8.5g"
*SID*NodesNum*cond(Initial_Temperature)
*end nodes
*endif
*if(strcmp(GenData(Analysis_Type),"STEADY_STATE_HEAT_TRANSFER")==0)
*format "TEMPD%11i%#8.5g"
*SID*GenData(Model_Initial_Temperature)
*endif
*set cond Point_Heat_Flux *nodes 
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*set var elemID= nelem+NodesNum
*format "QBDY1%11i%#8.5g%8i"
*SID*cond(Flux_Magnitude)*elemID
*end nodes
*endif
*set cond Point_Convection_Boundary
*if(CondNumEntities(int)>0)
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop nodes *OnlyInCond
*set var elemID= nelem+NodesNum
*format "CONV%12i%8i                 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end nodes
*endif
*set cond Point_Radiation_Boundary
*if(CondNumEntities(int)>0)
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop nodes *OnlyInCond
*set var elemID= nelem+NodesNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end nodes
*endif
*set elems(linear)
*set cond Line_Heat_Flux *elems 
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "QBDY1%11i%#8.5g%8i"
*SID*cond(Flux_Magnitude)*elemID
*end elems
*endif
*set cond Line_Convection_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "CONV%12i%8i                 1000001 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end elems
*endif
*set cond Line_Volumetric_Heat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "QVOL%12i%#8.5g        %8i"
*SID*cond(Power_input/volume)*elemsNum
*end elems
*endif
*set cond Line_Radiation_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end elems
*endif
*set elems(triangle)
*set cond Line_Convection_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "CONV%12i%8i                 1000001 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end elems
*endif
*set cond Line_Radiation_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end elems
*endif
*set cond Surface_Heat_Flux *elems 
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "QBDY1%11i%#8.5g%8i"
*SID*cond(Flux_Magnitude)*elemID
*end elems
*endif
*set cond Surface_Convection_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "CONV%12i%8i                 1000001 1000001 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end elems
*endif
*set cond Surface_Volumetric_Heat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "QVOL%12i%#8.5g        %8i"
*SID*cond(Power_input/volume)*elemsNum
*end elems
*endif
*set cond Surface_Radiation_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end elems
*endif
*set elems(quadrilateral)
*set cond Line_Convection_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "CONV%12i%8i                 1000001 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end elems
*endif
*set cond Line_Radiation_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end elems
*endif
*set cond Surface_Heat_Flux *elems 
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "QBDY1%11i%#8.5g%8i"
*SID*cond(Flux_Magnitude)*elemID
*end elems
*endif
*set cond Surface_Convection_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "CONV%12i%8i                 1000001 1000001 1000001 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end elems
*endif
*set cond Surface_Volumetric_Heat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "QVOL%12i%#8.5g        %8i"
*SID*cond(Power_input/volume)*elemsNum
*end elems
*endif
*set cond Surface_Radiation_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end elems
*endif
*set elems(tetrahedra)
*set cond Surface_Heat_Flux *elems 
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "QBDY1%11i%#8.5g%8i"
*SID*cond(Flux_Magnitude)*elemID
*end elems
*endif
*set cond Surface_Convection_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "CONV%12i%8i                 1000001 1000001 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end elems
*endif
*set cond Surface_Radiation_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end elems
*endif
*set cond Volume_Volumetric_Heat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "QVOL%12i%#8.5g        %8i"
*SID*cond(Power_input/volume)*elemsNum
*end elems
*endif
*set elems(hexahedra)
*set cond Surface_Heat_Flux *elems 
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*loop elems *OnlyInCond
*set var elemID= initialvalue+ElemsNum
*format "QBDY1%11i%#8.5g%8i"
*SID*cond(Flux_Magnitude)*elemID
*end elems
*endif
*set cond Surface_Convection_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispoint == 0)
SPOINT   1000001
*format "SPC%13i 1000001%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispoint=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "CONV%12i%8i                 1000001 1000001 1000001 1000001"
*elemID*elemID
*format "PCONV%11i%8i"
*elemID*elemID*\
*tcl(convection::setvarconv *cond(Convection_coef.))
*tcl(convection::write2bas *elemID)
*end elems
*endif
*set cond Surface_Radiation_Boundary
*if(CondNumEntities(int)>0)
*set var initialvalue= nelem+npoin
*if(ispointr == 0)
SPOINT   1000002
*format "SPC%13i 1000002%8i%#8.5g"
*SID*ID1*GenData(Ambient_Temp)
*endif
*set var ispointr=1
*loop elems *OnlyInCond
*set var elemID=initialvalue+ElemsNum
*format "RADBC    1000002%#8.5g        %8i"
*cond(Radiation_View_Factor)*elemID
*end elems
*endif
*set cond Volume_Volumetric_Heat
*if(CondNumEntities(int)>0)
*loop elems *OnlyInCond
*format "QVOL%12i%#8.5g        %8i"
*SID*cond(Power_input/volume)*elemsNum
*end elems
*endif
*end intervals
*#----------------------------------------------------------------------------------
*#
*#                        ADVANCED CONDITIONS
*#
*#----------------------------------------------------------------------------------
*set Cond Concentrated_Mass_Element *nodes 
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*if(strcmp(cond(Format),"CONM1")==0)
*format "CONM1%11i%8i%8i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g+1C%5i"
*NodesNum*NodesNum*ID0*cond(Symmetric,1)*cond(Symmetric,7)*cond(Symmetric,8)*cond(Symmetric,13)*cond(Symmetric,14)*NodesNum
*format "+1C%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g+1M%5i"
*NodesNum*cond(Symmetric,15)*cond(Symmetric,19)*cond(Symmetric,20)*cond(Symmetric,21)*cond(Symmetric,22)*cond(Symmetric,25)*cond(Symmetric,26)*cond(Symmetric,27)*NodesNum
*format "+1M%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g"
*NodesNum*cond(Symmetric,28)*cond(Symmetric,29)*cond(Symmetric,31)*cond(Symmetric,32)*cond(Symmetric,33)*cond(Symmetric,34)*cond(Symmetric,35)*cond(Symmetric,36)
*endif
*if(strcmp(cond(Format),"CONM2")==0)
*format "CONM2%11i%8i%8i%#8.5g%#8.5g%#8.5g%#8.5g        +2C%5i"
*NodesNum*NodesNum*ID0*cond(Mass_Value)*cond(Offset,1)*cond(Offset,2)*cond(Offset,3)*NodesNum
*format "+2C%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g"
*NodesNum*cond(Mass_moments,1)*cond(Mass_moments,4)*cond(Mass_moments,5)*cond(Mass_moments,7)*cond(Mass_moments,8)*cond(Mass_moments,9)
*endif
*end nodes
*endif
*set cond Point_Initial_Conditions *nodes *CanRepeat
*Add cond Line_Initial_Conditions *nodes *CanRepeat
*Add cond Surface_Initial_Conditions *nodes *CanRepeat
*Add cond Volume_Initial_Conditions *nodes *CanRepeat
*loop nodes *OnlyInCond
*if(strcmp(cond(Degree_of_freedom),"1-X")==0)
*set var dof1=1
*endif
*if(strcmp(cond(Degree_of_freedom),"2-Y")==0)
*set var dof1=2
*endif
*if(strcmp(cond(Degree_of_freedom),"3-Z")==0)
*set var dof1=3
*endif
*if(strcmp(cond(Degree_of_freedom),"4-RX")==0)
*set var dof1=4
*endif
*if(strcmp(cond(Degree_of_freedom),"5-RY")==0)
*set var dof1=5
*endif
*if(strcmp(cond(Degree_of_freedom),"6-RZ")==0)
*set var dof1=6
*endif
*format "TIC%13i%8i%8i%#8.5g%#8.5g"
*ID1*NodesNum*dof1*cond(Initial_displacement)*cond(Initial_velocity) 
*end nodes
*if(strcmp(GenData(Analysis_Type),"DIRECT_FREQUENCY_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"MODAL_FREQUENCY_RESPONSE")==0)
*format "FREQ1%11i%#8.5g%#8.5g%8i"
*ID1*GenData(Initial_Frequency,real)*GenData(Frequency_increment,real)*GenData(Number_of_frequency,int)
*endif
*if(strcmp(GenData(Analysis_Type),"DIRECT_TRANSIENT_RESPONSE")==0 || strcmp(GenData(Analysis_Type),"MODAL_TRANSIENT_RESPONSE")==0)
*format "TSTEP%11i%8i%8f%8i"
*ID1*GenData(Number_of_time_steps)*GenData(Time_increment)*GenData(Skip_factor_for_output)
*endif
*#----------------------------------------------------------------------------------
*#
*#                        CONSTRAINTS (spc)
*#
*#----------------------------------------------------------------------------------
*loop intervals
*set var CID=loopvar-1
*set cond Point_Fixed_Temperature 
*add cond Line_Fixed_Temperature
*add cond Surface_Fixed_Temperature
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*format "SPC%13i%8i%8i%#8.5g"
*CID*NodesNum*ID1*cond(Temperature)
*end nodes
*endif
*Set Cond  Surface-Constraints *nodes *or(1,int) *or(2,int) *or(3,int) *or(4,int) *or(5,int) *or(6,int) 
*Add Cond Line-Constraints *nodes *or(1,int) *or(2,int) *or(3,int) *or(4,int) *or(5,int) *or(6,int) 
*Add Cond Point-Constraints *nodes *or(1,int) *or(2,int) *or(3,int) *or(4,int) *or(5,int) *or(6,int) 
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*set var spc1=0
*set var spc2=0
*set var spc3=0
*set var spc4=0
*set var spc5=0
*set var spc6=0
*set var nspc=0
*if(cond(1,int)==1)
*Set var spc1=1
*set var nspc=nspc+1
*endif
*if(cond(2,int)==1)
*Set var spc2=2
*set var nspc=nspc+1
*endif
*if(cond(3,int)==1)
*Set var spc3=3
*set var nspc=nspc+1
*endif
*if(cond(4,int)==1)
*Set var spc4=4
*set var nspc=nspc+1
*endif
*if(cond(5,int)==1)
*Set var spc5=5
*set var nspc=nspc+1
*endif
*if(cond(6,int)==1)
*Set var spc6=6
*set var nspc=nspc+1
*endif
*set var first=1
*if(nspc==6)
*if(spc1==1)
*if(first==1)
*format "SPC%13i%8i%3i"
*CID*NodesNum*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "SPC%13i%8i%3i"
*CID*NodesNum*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "SPC%13i%8i%3i"
*CID*NodesNum*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "SPC%13i%8i%3i"
*CID*NodesNum*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "SPC%13i%8i%3i"
*CID*NodesNum*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "SPC%13i%8i%3i"
*CID*NodesNum*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*format "%7i."
*ID0
*endif
*if(nspc==5)
*if(spc1==1)
*if(first==1)
*format "SPC%13i%8i%4i"
*CID*NodesNum*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "SPC%13i%8i%4i"
*CID*NodesNum*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "SPC%13i%8i%4i"
*CID*NodesNum*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "SPC%13i%8i%4i"
*CID*NodesNum*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "SPC%13i%8i%4i"
*CID*NodesNum*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "SPC%13i%8i%4i"
*CID*NodesNum*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*format "%7i."
*ID0
*endif
*if(nspc==4)
*if(spc1==1)
*if(first==1)
*format "SPC%13i%8i%5i"
*CID*NodesNum*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "SPC%13i%8i%5i"
*CID*NodesNum*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "SPC%13i%8i%5i"
*CID*NodesNum*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "SPC%13i%8i%5i"
*CID*NodesNum*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "SPC%13i%8i%5i"
*CID*NodesNum*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "SPC%13i%8i%5i"
*CID*NodesNum*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*format "%7i."
*ID0
*endif
*if(nspc==3)
*if(spc1==1)
*if(first==1)
*format "SPC%13i%8i%6i"
*CID*NodesNum*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "SPC%13i%8i%6i"
*CID*NodesNum*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "SPC%13i%8i%6i"
*CID*NodesNum*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "SPC%13i%8i%6i"
*CID*NodesNum*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "SPC%13i%8i%6i"
*CID*NodesNum*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "SPC%13i%8i%6i"
*CID*NodesNum*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*format "%7i."
*ID0
*endif
*if(nspc==2)
*if(spc1==1)
*if(first==1)
*format "SPC%13i%8i%7i"
*CID*NodesNum*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "SPC%13i%8i%7i"
*CID*NodesNum*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "SPC%13i%8i%7i"
*CID*NodesNum*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "SPC%13i%8i%7i"
*CID*NodesNum*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "SPC%13i%8i%7i"
*CID*NodesNum*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "SPC%13i%8i%7i"
*CID*NodesNum*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*format "%7i."
*ID0
*endif
*if(nspc==1)
*if(spc1==1)
*format "SPC%13i%8i%8i"
*CID*NodesNum*spc1*\
*endif
*if(spc2==2)
*format "SPC%13i%8i%8i"
*CID*NodesNum*spc2*\
*endif
*if(spc3==3)
*format "SPC%13i%8i%8i"
*CID*NodesNum*spc3*\
*endif
*if(spc4==4)
*format "SPC%13i%8i%8i"
*CID*NodesNum*spc4*\
*endif
*if(spc5==5)
*format "SPC%13i%8i%8i"
*CID*NodesNum*spc5*\
*endif
*if(spc6==6)
*format "SPC%13i%8i%8i"
*CID*NodesNum*spc6*\
*endif
*format "%7i."
*ID0
*endif
*if(nspc==0)
*MessageBox error: -Boundaries conditions are not assigned-
*endif
*end nodes
*endif
*end intervals
*#----------------------------------------------------------------------------------
*#
*#                        RIGID BODY (RBE2)
*#
*#----------------------------------------------------------------------------------
*set elems(all)
*tcl(writebasfile_rigid_body *nelem)*\
*#----------------------------------------------------------------------------------
*#
*#                        MATERIALS 
*#
*#----------------------------------------------------------------------------------
$ ------------------------------------------------------------------------------
$                             MATERIALS
$ ------------------------------------------------------------------------------
*loop materials
*if(strcmp(matprop(Composition_Material),"-ANY-")!=0)
$ ----------------Material: *matprop(Composition_Material) -------*\
*tcl( BasWriter::getmatnum *matnum )
*tcl( BasWriter::matnastran { *matprop(Composition_Material) } )
*endif
*end materials
*loop materials
*if(strcmp(matprop(PROPERTY),"PLATE")==0)
$ ----------------Materials Use In *matprop(0)-------------
*tcl(plate::writemats { *matprop(matid) })
*endif 
*end materials
*loop materials
*if(strcmp(matprop(PROPERTY),"LAMINATE")==0)
$ ----------------Materials Use In *matprop(0) --------------
*tcl(NasComposite::writemats { *matprop(matlist) })
*endif 
*end materials
*tcl(nasmat::tabletemp)
$ --------------------------END MATERIALS---------------------------------------
*#----------------------------------------------------------------------------------
*#
*#                        PROPERTIES
*#
*#----------------------------------------------------------------------------------
$ ------------------------------------------------------------------------------
$                             PROPERTIES
$ ------------------------------------------------------------------------------
*loop materials
$ -------------------Property: *matprop(0)--
*if(strcmp(matprop(PROPERTY),"BAR")==0) 
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PBAR*%19i%16i%#16g%#16g*PB%5i"
*matnum()*matnum()*matprop(Area)*matprop(I1:)*matnum()
*format "*PB%5i%#16g%#16g%#16g                +PB%5i"
*matnum()*matprop(I2)*matprop(Torsional_C)*matprop(Nonstructural)*matnum()
*format "+PB%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g+PA%4iA"
*matnum()*matprop(Values,1)*matprop(Values,2)*matprop(Values,3)*matprop(Values,4)*matprop(Values,5)*matprop(Values,6)*matprop(Values,7)*matprop(Values,8)*matnum()
*format "+PA%4iA%#8.5g%#g%#8.5g"
*matnum()*matprop(Y_Shear)*matprop(Z_Shear)*matprop(I12)
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PBAR%12i%8i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g        +PB%5i"
*matnum()*matnum()*matprop(Area)*matprop(I1:)*matprop(I2)*matprop(Torsional_C)*matprop(Nonstructural)*matnum()
*format "+PB%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g+PA%5i"
*matnum()*matprop(Values,1)*matprop(Values,2)*matprop(Values,3)*matprop(Values,4)*matprop(Values,5)*matprop(Values,6)*matprop(Values,7)*matprop(Values,8)*matnum()
*format "+PA%5i%#8.5g%#g%#8.5g"
*matnum()*matprop(Y_Shear)*matprop(Z_Shear)*matprop(I12)
*endif
*endif
*if(strcmp(matprop(PROPERTY),"BEAM")==0) 
*if(strcmp(GenData(Format_File),"Large")==0)
*format "PBAR*%19i%16i%#16g%#16g*PB%5i"
*matnum()*matnum()*matprop(Area)*matprop(I1:)*matnum()
*format "*PB%5i%#16g%#16g%#16g                +PA%5i"
*matnum()*matprop(I2)*matprop(Torsional_C)*matprop(Nonstructural)*matnum()
*format "+PA%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g+PB%4iA"
*matnum()*matprop(Values,1)*matprop(Values,2)*matprop(Values,3)*matprop(Values,4)*matprop(Values,5)*matprop(Values,6)*matprop(Values,7)*matprop(Values,8)*matnum()
*format "+PB%4iA%#8.5g%#g%#8.5g"
*matnum()*matprop(Y_Shear)*matprop(Z_Shear)*matprop(I12)
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "PBAR%12i%8i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g        +PB%5i"
*matnum()*matnum()*matprop(Area)*matprop(I1:)*matprop(I2)*matprop(Torsional_C)*matprop(Nonstructural)*matnum()
*format "+PB%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g+PA%5i"
*matnum()*matprop(Values,1)*matprop(Values,2)*matprop(Values,3)*matprop(Values,4)*matprop(Values,5)*matprop(Values,6)*matprop(Values,7)*matprop(Values,8)*matnum()
*format "+PA%5i%#8.5g%#g%#8.5g"
*matnum()*matprop(Y_Shear)*matprop(Z_Shear)*matprop(I12)
*endif
*endif
*if(strcmp(matprop(PROPERTY),"CURVED_BEAM")==0) 
*format "PELBOW*%17i%16i%#16g%#16g*PB%5i"
*matnum()*matnum()*matprop(Area)*matprop(I1:)*matnum()
*format "*PB%5i%#16g%#16g%#16g                +PA%5i"
*matnum()*matprop(I2)*matprop(Torsional_C)*matprop(Nonstructural)*matnum()
*format "+PA%5i%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g%#8.5g+PB%4iA"
*matnum()*matprop(1Y)*matprop(1Z)*matprop(2Y)*matprop(2Z)*matprop(3Y)*matprop(3Z)*matprop(4Y)*matprop(4Z)*matnum()
*format "+PB%4iA%#8.5g%#8.5g                                %#8.5g"
*matnum()*matprop(Y_Shear)*matprop(Z_Shear)*matprop(Bend_Radius)
*endif
*if(strcmp(matprop(PROPERTY),"TUBE")==0) 
*format "PTUBE%11i%8i%#8.5g"
*matnum()*matnum()*matprop(Outside_diameter_of_tube)*\
*if(matprop(Solid_Circular_Rod,int)==1)
*format "%7i.%#8.5g"
*ID0*matprop(Nonstructural_mass)
*else
*format "%#8.5g%#8.5g"
*matprop(Thickness)*matprop(Nonstructural)
*endif
*endif
*if(strcmp(matprop(PROPERTY),"PIPE")==0) 
*format "PPIPE%11i%8i%#8.5g%#8.5g%#8.5g"
*matnum()*matnum()*matprop(Outside_diameter_of_pipe)*matprop(Pipe_wall_thickness)*matprop(Internal_pressure)*\
*if(strcmp(matprop(End_condition),"CLOSED")==0)
  CLOSED*\
*format "%#8.5g"
*matprop(Nonstructural_mass)
*else
    OPEN*\
*format "%#8.5g"
*matprop(Nonstructural_mass)
*endif 
*endif
*if(strcmp(matprop(PROPERTY),"CABLE")==0) 
*format "PCABLE%10i%8i"
*matnum()*matnum()*\
*if(strcmp(matprop(Initial_conditions),"cable_slack")==0)
*format "%#8.5g        %#8.5g%#8.5g%#8.5g"
*matprop(Slack_U0)*matprop(Area_cross_section)*matprop(Moment_of_Inertia)*matprop(Allowable_tensile)
*else
*format "        %#8.5g%#8.5g%#8.5g%#8.5g"
*matprop(Tension_T0)*matprop(Area_cross_section)*matprop(Moment_of_Inertia)*matprop(Allowable_tensile)  
*endif 
*endif
*if(strcmp(matprop(PROPERTY),"ROD")==0) 
*format "PROD%10i%8i%#8.5g%#8.5g%#8.5g%#8.5g"
*matnum()*matnum()*matprop(Area_Cross_Section)*matprop(Torsional_Constant)*matprop(Coeff._Torsional_Stress)*matprop(Nonstructural_mass/length)
*endif
*if(strcmp(matprop(PROPERTY),"SHEAR_PANEL")==0) 
*format "PSHEAR%10i%8i%#8.5g%#8.5g"
*matnum()*matnum()*matprop(Thickness)*matprop(Nonstructural)
*endif
*if(strcmp(matprop(PROPERTY),"PLATE")==0) 
*tcl(plate::writenastran *matnum() *matprop(nastran) )
*endif
*if(strcmp(matprop(PROPERTY),"TETRAHEDRON")==0) 
*if(strcmp(matprop(Coord_System),"ELEMENT")==0)
*format "PSOLID%10i%8i      -1"
*matnum()*matnum()
*endif
*if(strcmp(matprop(Coord_System),"BASIC")==0)
*format "PSOLID%10i%8i       0"
*matnum()*matnum()
*endif
*endif
*if(strcmp(matprop(PROPERTY),"HEXAHEDRON")==0) 
*if(strcmp(matprop(Coord_System),"ELEMENT")==0)
*format "PSOLID%10i%8i      -1"
*matnum()*matnum()
*endif
*if(strcmp(matprop(Coord_System),"BASIC")==0)
*format "PSOLID%10i%8i       0"
*matnum()*matnum()
*endif
*endif
*if(strcmp(matprop(PROPERTY),"VISCOUS_DAMPER")==0) 
*format "PVISC%11i%#8.5g%#8.5g"
*matnum()*matprop(Viscous_coefficient_extension)*matprop(Viscous_coefficient_rotation)
*endif
*if(strcmp(matprop(PROPERTY),"SPRING")==0) 
*format "MAT1%12i1000000.            0.25"
*matnum()
*format "PROD%12i%8i"
*matnum()*matnum()*\
*if(strcmp(matprop(Property_Values),"Axial")==0)
*set var scale=matprop(Stiffness_coefficient,real)*1.e-6
*format "%#8.2g"
*scale
*else
*set var scale=matprop(Stiffness_coefficient,real)*2.5e-6
*format "        %#8.2g"
*scale
*endif
*endif
*if(strcmp(matprop(PROPERTY),"LAMINATE")==0)
*tcl( NasComposite::getmatnum *matnum)
*tcl( NasComposite::writenastran { *matprop(nastran) } )
*endif
*end materials
$ -------------------END PROPERTIES---------------------------------------------
*#----------------------------------------------------------------------------------
*#
*#                        NODES
*#
*#----------------------------------------------------------------------------------
$ ------------------------------------------------------------------------------
$                             NODES 
$ ------------------------------------------------------------------------------
*loop nodes
*if(strcmp(GenData(Format_File),"Large")==0)
*format "GRID*%19i%16i%#16g%#16g*G%6i"
*NodesNum*ID0*NodesCoord(1,real)*NodesCoord(2,real)*NodesNum
*format "*G%6i%#16g%16i"
*NodesNum*NodesCoord(3,real)*ID0
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "GRID%12i%8i%#8g%#8g%#8g%8i"
*NodesNum*ID0*NodesCoord(1,real)*NodesCoord(2,real)*NodesCoord(3,real)*ID0
*endif
*end nodes
$ -----------------------------END NODES----------------------------------------
*#----------------------------------------------------------------------------------
*#
*#                        LINEAR ELEMENTS
*#
*#----------------------------------------------------------------------------------
*set elems(linear)
*loop elems
*loop materials
*if(elemsmat(int)==matnum(int) && strcmp(matprop(PROPERTY),"ROD")==0)
*format "CROD%12i%8i%8i%8i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)
*endif
*if(elemsmat(int)==matnum(int) && strcmp(matprop(PROPERTY),"TUBE")==0)
*format "CTUBE%11i%8i%8i%8i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)
*endif
*if(elemsmat(int)==matnum(int) && strcmp(matprop(PROPERTY),"PIPE")==0)
*format "CPIPE%11i%8i%8i%8i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)
*endif
*if(elemsmat(int)==matnum(int) && strcmp(matprop(PROPERTY),"CABLE")==0)
*format "CCABLE%10i%8i%8i%8i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)
*endif
*if(elemsmat(int)==matnum(int) && strcmp(matprop(PROPERTY),"VISCOUS_DAMPER")==0)
*format "CVISC%11i%8i%8i%8i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)
*endif
*if( elemsmat(int)==matnum(int) && strcmp(matprop(PROPERTY),"SPRING")==0)
*format "CROD%12i%8i%8i%8i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)
*endif
*if(elemsmat(int)== matnum(int) && strcmp(matprop(PROPERTY),"DOF_SPRING")==0) 
*set var dof1=1
*set var dof2=2
*set var dof3=3
*set var dof4=4
*set var dof5=5
*set var dof6=6
*if(matprop(Stiffness,real)==0.0)
*format "CDAMP2%10i%#8.5g%8i"
*elemsnum()*matprop(Damping)*elemsConec(1)*\
*if(strcmp(matprop(EndA),"X-Displacement")==0)
*format "%8i%8i"
*dof1*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"Y-Displacement")==0)
*format "%8i%8i"
*dof2*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"Z-Displacement")==0)
*format "%8i%8i"
*dof3*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"X-Rotation")==0)
*format "%8i%8i"
*dof4*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndA),"Y-Rotation")==0)
*format "%8i%8i"
*dof5*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndA),"Z-Rotation")==0)
*format "%8i%8i"
*dof6*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndB),"X-Displacement")==0)
*format "%8i"
*dof1
*endif
*if(strcmp(matprop(EndB),"Y-Displacement")==0)
*format "%8i"
*dof2
*endif
*if(strcmp(matprop(EndB),"Z-Displacement")==0)
*format "%8i"
*dof3
*endif
*if(strcmp(matprop(EndB),"X-Rotation")==0)
*format "%8i"
*dof4
*endif
*if(strcmp(matprop(EndB),"Y-Rotation")==0)
*format "%8i"
*dof5
*endif
*if(strcmp(matprop(EndB),"Z-Rotation")==0)
*format "%8i"
*dof6
*endif
*endif
*if(matprop(Damping,real)==0.0)
*format "CELAS2%10i%#8.5g%8i"
*elemsnum()*matprop(Stiffness)*elemsConec(1)*\
*if(strcmp(matprop(EndA),"X-Displacement")==0)
*format "%8i%8i"
*dof1*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"Y-Displacement")==0)
*format "%8i%8i"
*dof2*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"Z-Displacement")==0)
*format "%8i%8i"
*dof3*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"X-Rotation")==0)
*format "%8i%8i"
*dof4*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndA),"Y-Rotation")==0)
*format "%8i%8i"
*dof5*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndA),"Z-Rotation")==0)
*format "%8i%8i"
*dof6*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndB),"X-Displacement")==0)
*format "%8i"
*dof1
*endif
*if(strcmp(matprop(EndB),"Y-Displacement")==0)
*format "%8i"
*dof2
*endif
*if(strcmp(matprop(EndB),"Z-Displacement")==0)
*format "%8i"
*dof3
*endif
*if(strcmp(matprop(EndB),"X-Rotation")==0)
*format "%8i"
*dof4
*endif
*if(strcmp(matprop(EndB),"Y-Rotation")==0)
*format "%8i"
*dof5
*endif
*if(strcmp(matprop(EndB),"Z-Rotation")==0)
*format "%8i"
*dof6
*endif
*endif
*if(matprop(Stiffness,real)!=0.0 && matprop(Damping,real)!=0.0)
*format "CELAS2%10i%#8.5g%8i"
*elemsnum()*matprop(Stiffness)*elemsConec(1)*\
*if(strcmp(matprop(EndA),"X-Displacement")==0)
*format "%8i%8i"
*dof1*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"Y-Displacement")==0)
*format "%8i%8i"
*dof2*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"Z-Displacement")==0)
*format "%8i%8i"
*dof3*elemsConec(2)*\ 
*endif
*if(strcmp(matprop(EndA),"X-Rotation")==0)
*format "%8i%8i"
*dof4*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndA),"Y-Rotation")==0)
*format "%8i%8i"
*dof5*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndA),"Z-Rotation")==0)
*format "%8i%8i"
*dof6*elemsConec(2)*\ 
*end
*if(strcmp(matprop(EndB),"X-Displacement")==0)
*format "%8i%#8.5g"
*dof1*matprop(Damping)
*endif
*if(strcmp(matprop(EndB),"Y-Displacement")==0)
*format "%8i%#8.5g"
*dof2*matprop(Damping)
*endif
*if(strcmp(matprop(EndB),"Z-Displacement")==0)
*format "%8i%#8.5g"
*dof3*matprop(Damping)
*endif
*if(strcmp(matprop(EndB),"X-Rotation")==0)
*format "%8i%#8.5g"
*dof4*matprop(Damping)
*endif
*if(strcmp(matprop(EndB),"Y-Rotation")==0)
*format "%8i%#8.5g"
*dof5*matprop(Damping)
*endif
*if(strcmp(matprop(EndB),"Z-Rotation")==0)
*format "%8i%#8.5g"
*dof6*matprop(Damping)
*endif
*endif
*endif
*end materials
*end elems
*set elems(linear)
*set var nproperty=0
*loop elems
*loop materials
*if(matnum(int)==elemsmat(int) && (strcmp(matprop(PROPERTY),"BAR")==0) ) 
*set var nproperty=nproperty+1
*endif
*if(matnum(int)==elemsmat(int) && (strcmp(matprop(PROPERTY),"BEAM")==0) )
*set var nproperty=nproperty+1
*endif
*end materials
*end elems
*set cond Line-Local-Axes
*if(CondNumEntities(int)>nproperty(int))
*MessageBox error:-Some linear elements with Local Axes defined haven't got any property assigned.To obtain more information use "Verify Properties" option of Data Menu- 
*endif
*if(CondNumEntities(int)<nproperty(int))
*MessageBox error:-Some bars or beams haven't got Local Axes defined. To obtain more information use "Verify Properties" option of Data Menu-
*endif
*set elems(linear)
*set Cond Line-Local-Axes *elems
*loop elems *OnlyInCond
*loop materials
*if(elemsmat(int)==matnum(int) && (strcmp(matprop(PROPERTY),"BAR")==0 || strcmp(matprop(PROPERTY),"BEAM")==0) )
*set var Node1=elemsConec(1,int)
*set var Node2=elemsConec(2,int)
*if(strcmp(GenData(Format_File),"Large")==0)
*format "CBAR*%19i%16i%16i%16i*B%6i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)*elemsNum
*format "*B%6i%*%#16.5f%*%*%#16.5f%*%*%#16.5f%*%16i+A%6i"
*elemsNum*LocalAxesDef()*ID1*elemsNum
*endif
*if(strcmp(GenData(Format_File),"Small")==0)
*format "CBAR%12i%8i%8i%8i%*%#8.5f%*%*%#8.5f%*%*%#8.5f%*%8i+A%6i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)*LocalAxesDef()*ID1*elemsNum
*endif
*set var disc1=0
*set var disc2=0
*set Cond Point-Disconnect
*loop nodes *OnlyInCond 
*if(NodesNum(int)==Node1)
*set var disc1=1
*endif
*if(NodesNum(int)==Node2)
*set var disc2=1
*endif
*end nodes
*if(disc1==1 && disc2==0)
*loop nodes *OnlyInCond
*if(NodesNum(int)==Node1)
*format "+A%6i"
*elemsNum*\
*set var spc1=0
*set var spc2=0
*set var spc3=0
*set var spc4=0
*set var spc5=0
*set var spc6=0
*set var nspc=0
*if(cond(1,int)==1)
*Set var spc1=1
*set var nspc=nspc+1
*endif
*if(cond(2,int)==1)
*Set var spc2=2
*set var nspc=nspc+1
*endif
*if(cond(3,int)==1)
*Set var spc3=3
*set var nspc=nspc+1
*endif
*if(cond(4,int)==1)
*Set var spc4=4
*set var nspc=nspc+1
*endif
*if(cond(5,int)==1)
*Set var spc5=5
*set var nspc=nspc+1
*endif
*if(cond(6,int)==1)
*Set var spc6=6
*set var nspc=nspc+1
*endif
*set var first=1
*if(nspc==6)
*format "%3i%1i%1i%1i%1i%1i"
*spc1*spc2*spc3*spc4*spc5*spc6
*endif
*if(nspc==5)
*if(spc1==1)
*if(first==1)
*format "%4i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%4i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%4i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%4i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%4i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%4i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==4)
*if(spc1==1)
*if(first==1)
*format "%5i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%5i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%5i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%5i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%5i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%5i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==3)
*if(spc1==1)
*if(first==1)
*format "%6i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%6i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%6i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%6i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%6i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%6i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==2)
*if(spc1==1)
*if(first==1)
*format "%7i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%7i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%7i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%7i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%7i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%7i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==1)
*if(spc1==1)
*format "%8i"
*spc1*\
*endif
*if(spc2==2)
*format "%8i"
*spc2*\
*endif
*if(spc3==3)
*format "%8i"
*spc3*\
*endif
*if(spc4==4)
*format "%8i"
*spc4*\
*endif
*if(spc5==5)
*format "%8i"
*spc5*\
*endif
*if(spc6==6)
*format "%8i"
*spc6*\
*endif

*endif
*endif
*end nodes
*endif
*if(disc1==0 && disc2==1)
*loop nodes *OnlyInCond
*if(NodesNum(int)==Node2)
*format "+A%6i        "
*elemsNum*\
*set var spc1=0
*set var spc2=0
*set var spc3=0
*set var spc4=0
*set var spc5=0
*set var spc6=0
*set var nspc=0
*if(cond(1,int)==1)
*Set var spc1=1
*set var nspc=nspc+1
*endif
*if(cond(2,int)==1)
*Set var spc2=2
*set var nspc=nspc+1
*endif
*if(cond(3,int)==1)
*Set var spc3=3
*set var nspc=nspc+1
*endif
*if(cond(4,int)==1)
*Set var spc4=4
*set var nspc=nspc+1
*endif
*if(cond(5,int)==1)
*Set var spc5=5
*set var nspc=nspc+1
*endif
*if(cond(6,int)==1)
*Set var spc6=6
*set var nspc=nspc+1
*endif
*set var first=1
*if(nspc==6)
*format "%3i%1i%1i%1i%1i%1i"
*spc1*spc2*spc3*spc4*spc5*spc6
*endif
*if(nspc==5)
*if(spc1==1)
*if(first==1)
*format "%4i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%4i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%4i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%4i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%4i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%4i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==4)
*if(spc1==1)
*if(first==1)
*format "%5i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%5i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%5i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%5i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%5i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%5i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==3)
*if(spc1==1)
*if(first==1)
*format "%6i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%6i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%6i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%6i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%6i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%6i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==2)
*if(spc1==1)
*if(first==1)
*format "%7i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%7i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%7i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%7i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%7i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%7i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==1)
*if(spc1==1)
*format "%8i"
*spc1*\
*endif
*if(spc2==2)
*format "%8i"
*spc2*\
*endif
*if(spc3==3)
*format "%8i"
*spc3*\
*endif
*if(spc4==4)
*format "%8i"
*spc4*\
*endif
*if(spc5==5)
*format "%8i"
*spc5*\
*endif
*if(spc6==6)
*format "%8i"
*spc6*\
*endif

*endif
*endif
*end nodes
*endif
*if(disc1==1 && disc2==1)
*loop nodes *OnlyInCond
*if(NodesNum(int)==Node1)
*format "+A%6i"
*elemsNum*\
*set var spc1=0
*set var spc2=0
*set var spc3=0
*set var spc4=0
*set var spc5=0
*set var spc6=0
*set var nspc=0
*if(cond(1,int)==1)
*Set var spc1=1
*set var nspc=nspc+1
*endif
*if(cond(2,int)==1)
*Set var spc2=2
*set var nspc=nspc+1
*endif
*if(cond(3,int)==1)
*Set var spc3=3
*set var nspc=nspc+1
*endif
*if(cond(4,int)==1)
*Set var spc4=4
*set var nspc=nspc+1
*endif
*if(cond(5,int)==1)
*Set var spc5=5
*set var nspc=nspc+1
*endif
*if(cond(6,int)==1)
*Set var spc6=6
*set var nspc=nspc+1
*endif
*set var first=1
*if(nspc==6)
*format "%3i%1i%1i%1i%1i%1i"
*spc1*spc2*spc3*spc4*spc5*spc6*\
*endif
*if(nspc==5)
*if(spc1==1)
*if(first==1)
*format "%4i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%4i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%4i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%4i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%4i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%4i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*endif
*if(nspc==4)
*if(spc1==1)
*if(first==1)
*format "%5i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%5i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%5i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%5i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%5i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%5i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*endif
*if(nspc==3)
*if(spc1==1)
*if(first==1)
*format "%6i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%6i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%6i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%6i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%6i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%6i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*endif
*if(nspc==2)
*if(spc1==1)
*if(first==1)
*format "%7i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%7i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%7i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%7i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%7i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%7i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif
*endif
*if(nspc==1)
*if(spc1==1)
*format "%8i"
*spc1*\
*endif
*if(spc2==2)
*format "%8i"
*spc2*\
*endif
*if(spc3==3)
*format "%8i"
*spc3*\
*endif
*if(spc4==4)
*format "%8i"
*spc4*\
*endif
*if(spc5==5)
*format "%8i"
*spc5*\
*endif
*if(spc6==6)
*format "%8i"
*spc6*\
*endif
*endif
*endif
*end nodes
*loop nodes *OnlyInCond
*if(NodesNum(int)==Node2)
*set var spc1=0
*set var spc2=0
*set var spc3=0
*set var spc4=0
*set var spc5=0
*set var spc6=0
*set var nspc=0
*if(cond(1,int)==1)
*Set var spc1=1
*set var nspc=nspc+1
*endif
*if(cond(2,int)==1)
*Set var spc2=2
*set var nspc=nspc+1
*endif
*if(cond(3,int)==1)
*Set var spc3=3
*set var nspc=nspc+1
*endif
*if(cond(4,int)==1)
*Set var spc4=4
*set var nspc=nspc+1
*endif
*if(cond(5,int)==1)
*Set var spc5=5
*set var nspc=nspc+1
*endif
*if(cond(6,int)==1)
*Set var spc6=6
*set var nspc=nspc+1
*endif
*set var first=1
*if(nspc==6)
*format "%3i%1i%1i%1i%1i%1i"
*spc1*spc2*spc3*spc4*spc5*spc6
*endif
*if(nspc==5)
*if(spc1==1)
*if(first==1)
*format "%4i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%4i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%4i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%4i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%4i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%4i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==4)
*if(spc1==1)
*if(first==1)
*format "%5i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%5i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%5i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%5i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%5i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%5i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==3)
*if(spc1==1)
*if(first==1)
*format "%6i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%6i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%6i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%6i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%6i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%6i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==2)
*if(spc1==1)
*if(first==1)
*format "%7i"
*spc1*\
*endif
*if(first==0)
*format "%1i"
*spc1*\
*endif
*set var first=0
*endif
*if(spc2==2)
*if(first==1)
*format "%7i"
*spc2*\
*endif
*if(first==0) 
*format "%1i"
*spc2*\
*endif
*set var first=0
*endif
*if(spc3==3)
*if(first==1)
*format "%7i"
*spc3*\
*endif
*if(first==0)
*format "%1i"
*spc3*\
*endif
*set var first=0
*endif
*if(spc4==4)
*if(first==1)
*format "%7i"
*spc4*\
*endif
*if(first==0)
*format "%1i"
*spc4*\
*endif
*set var first=0
*endif
*if(spc5==5)
*if(first==1)
*format "%7i"
*spc5*\
*endif
*if(first==0)
*format "%1i"
*spc5*\
*endif
*set var first=0
*endif
*if(spc6==6)
*if(first==1)
*format "%7i"
*spc6*\
*endif
*if(first==0)
*format "%1i"
*spc6*\
*endif
*set var first=0
*endif

*endif
*if(nspc==1)
*if(spc1==1)
*format "%8i"
*spc1*\
*endif
*if(spc2==2)
*format "%8i"
*spc2*\
*endif
*if(spc3==3)
*format "%8i"
*spc3*\
*endif
*if(spc4==4)
*format "%8i"
*spc4*\
*endif
*if(spc5==5)
*format "%8i"
*spc5*\
*endif
*if(spc6==6)
*format "%8i"
*spc6*\
*endif

*endif
*endif
*end nodes
*endif
*if(disc1==0 && disc2==0)
*format "+A%6i                %7i.%7i.%7i.%7i.%7i.%7i."
*elemsNum*ID0*ID0*ID0*ID0*ID0*ID0
*endif
*set Cond Line-Local-Axes *elems
*endif
*end materials
*end elems
*set elems(linear)
*set cond Line-Local-Axes *elems
*loop elems *OnlyInCond
*loop materials
*if(elemsmat()==matnum())
*if(strcmp(matprop(PROPERTY),"CURVED_BEAM")==0)
*format "CELBOW*%17i%16i%16i%16i*CE%5i"
*elemsNum*elemsmat*elemsConec(1)*elemsConec(2)*elemsNum
*format "*CE%5i%*%#16.5f%*%*%#16.5f%*%*%#16.5f%*%16i"
*elemsNum*LocalAxesDef()*ID1
*endif
*endif
*end materials
*end elems
*if(strcmp(GenData(Auxiliary_Output_Points),"0")!=0)
*set var delta=1./(GenData(Auxiliary,real)+1.)
*set elems(linear)
*loop elems
*format "CBARAO%10i      FR%8i%#8.5g%#8.5g"
*elemsNum*GenData(Auxiliary,int)*delta*delta
*end elems
*endif 
*#----------------------------------------------------------------------------------
*#
*#                        SURFACE ELEMENTS
*#
*#----------------------------------------------------------------------------------
*Set elems(triangle)
*set cond Material_Axes *elems
*if(CondnumEntities(int)>0)
*loop elems *OnlyInCond
*if(IsQuadratic(int)==0)
*loop materials 
*if(elemsmat()==matnum()) 
*if(strcmp(matprop(PROPERTY),"SHEAR_PANEL")==0)
*MessageBox error: -SHEAR_PANEL does not work with Triangular Elements - NASTRAN input file finished with error
*endif
*if(strcmp(matprop(PROPERTY),"PLATE")==0) 
*format "CTRIA3%10i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec*tcl(calcangle::CalcAngleTria *elemsnum *LocalAxesDef(1) *LocalAxesDef(4) *LocalAxesDef(7))
*endif
*if(strcmp(matprop(PROPERTY),"LAMINATE")==0) 
*format "CTRIA3%10i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec*tcl(calcangle::CalcAngleTria *elemsnum *LocalAxesDef(1) *LocalAxesDef(4) *LocalAxesDef(7))
*endif
*endif
*end materials
*else
*MessageBox error: - NASTRAN Interface doesn't work with Triangular Quadratic Elements-Process finished with errors
*endif
*end elems
*else 
*if(IsQuadratic(int)==0)
*loop elems 
*if(strcmp(ElemsMatProp(PROPERTY),"PLATE")==0) 
*format "CTRIA3%10i%8i%8i%8i%8i"
*ElemsNum*ElemsMat*ElemsConec
*elseif(strcmp(ElemsMatProp(PROPERTY),"SHEAR_PANEL")==0)
*MessageBox error: -SHEAR_PANEL does not work with Triangular Elements - NASTRAN input file finished with error
*endif
*end elems
*else
*MessageBox error: - NASTRAN Interface doesn't work with Triangular Quadratic Elements-Process finished with errors
*endif
*endif
*Set elems(quadrilateral)
*set cond Material_Axes *elems
*if(CondnumEntities(int)>0)
*loop elems *OnlyInCond
*if(IsQuadratic(int)==0)
*loop materials 
*if(elemsmat()==matnum()) 
*if(strcmp(matprop(PROPERTY),"SHEAR_PANEL")==0)
*format "CSHEAR%10i%8i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec
*endif
*if(strcmp(matprop(PROPERTY),"PLATE")==0) 
*format "CQUAD4%10i%8i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec*tcl(calcangle::CalcAngleQuad *elemsnum *LocalAxesDef(1) *LocalAxesDef(4) *LocalAxesDef(7))
*endif
*if(strcmp(matprop(PROPERTY),"LAMINATE")==0) 
*format "CQUAD4%10i%8i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec*tcl(calcangle::CalcAngleQuad *elemsnum *LocalAxesDef(1) *LocalAxesDef(4) *LocalAxesDef(7))
*endif
*endif
*end materials
*endif
*if(IsQuadratic(int)==1)
*MessageBox error: -NASTRAN Interface doesn't work with Quadrilater Quadratic Elements-Process finished with errors
*endif
*end elems
*else
*loop elems 
*if(IsQuadratic(int)==0)
*loop materials 
*if(elemsmat()==matnum()) 
*if(strcmp(matprop(PROPERTY),"SHEAR_PANEL")==0)
*format "CSHEAR%10i%8i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec
*endif
*if(strcmp(matprop(PROPERTY),"PLATE")==0) 
*format "CQUAD4%10i%8i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec
*endif
*endif
*end materials
*endif
*if(IsQuadratic(int)==1)
*MessageBox error: -NASTRAN Interface doesn't work with Quadrilater Quadratic Elements-Process finished with errors
*endif
*end elems
*endif
*#----------------------------------------------------------------------------------
*#
*#                        VOLUME ELEMENTS
*#
*#----------------------------------------------------------------------------------
*set elems(tetrahedra)
*loop elems
*if(IsQuadratic(int)==0)
*format "CTETRA%10i%8i%8i%8i%8i%8i"
*ElemsNum*elemsmat()*ElemsConec
*endif
*if(IsQuadratic(int)==1)
*format "CTETRA%10i%8i%8i%8i%8i%8i%8i%8i+T%6i"
*ElemsNum*elemsmat()*ElemsConec(1)*ElemsConec(2)*ElemsConec(3)*ElemsConec(4)*ElemsConec(5)*ElemsConec(6)*elemsNum()
*format "+T%6i%8i%8i%8i%8i"
*elemsNum*ElemsConec(7)*ElemsConec(8)*ElemsConec(9)*ElemsConec(10)
*endif
*end elems
*set elems(hexahedra)
*loop elems
*if(IsQuadratic(int)==0)
*format "CHEXA%11i%8i%8i%8i%8i%8i%8i%8i+H%6i"
*ElemsNum*elemsmat()*ElemsConec(1)*ElemsConec(2)*ElemsConec(3)*ElemsConec(4)*ElemsConec(5)*ElemsConec(6)*ElemsNum
*format "+H%6i%8i%8i"
*ElemsNum*ElemsConec(7)*ElemsConec(8)
*elseif(IsQuadratic(int)==1)
*format "CHEXA%11i%8i%8i%8i%8i%8i%8i%8i+H%6i"
*ElemsNum*elemsmat()*ElemsConec(1)*ElemsConec(2)*ElemsConec(3)*ElemsConec(4)*ElemsConec(5)*ElemsConec(6)*elemsNum
*format "+H%6i%8i%8i%8i%8i%8i%8i%8i%8i+E%6i"
*elemsNum*ElemsConec(7)*ElemsConec(8)*ElemsConec(9)*ElemsConec(10)*ElemsConec(11)*ElemsConec(12)*ElemsConec(13)*ElemsConec(14)*ElemsNum
*format "+E%6i%8i%8i%8i%8i%8i%8i"
*ElemsNum*ElemsConec(15)*ElemsConec(16)*ElemsConec(17)*ElemsConec(18)*ElemsConec(19)*ElemsConec(20)
*endif
*end elems
*set elems(prism)
*loop elems
*if(IsQuadratic(int)==0)
*format "CPENTA%10i%8i%8i%8i%8i%8i%8i%8i"
*ElemsNum*elemsmat*ElemsConec
*else
*format "CPENTA%10i%8i%8i%8i%8i%8i%8i%8i+H%6i"
*ElemsNum*elemsmat*ElemsConec(1)*ElemsConec(2)*ElemsConec(3)*ElemsConec(4)*ElemsConec(5)*ElemsConec(6)*elemsNum
*format "+H%6i%8i%8i%8i%8i%8i%8i%8i%8i+E%6i"
*elemsNum*ElemsConec(7)*ElemsConec(8)*ElemsConec(9)*ElemsConec(10)*ElemsConec(11)*ElemsConec(12)*ElemsConec(13)*ElemsConec(14)*ElemsNum
*format "+E%6i%8i"
*ElemsNum*ElemsConec(15)
*endif
*end elems
*#--------------------------------------------------------------------------------
*#   Contacts
*#--------------------------------------------------------------------------------
*tcl( BasWriter::WriteContacts )
ENDDATA
