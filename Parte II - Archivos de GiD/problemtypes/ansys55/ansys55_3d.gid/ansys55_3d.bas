/FILNAME,*GenData(2)
/PREP7
/NOPR
/COM -----------------------------------------------------------
/COM    Copyright @CIMNE 2000 GiD to ANSYS TransLator
/COM    Written by: rgyarmati@cantv.net
/COM    Version:  6.1
/COM -----------------------------------------------------------
/COM
/TITLE,*GenData(2)
/VIEW,1,0.0,0.0,1.0
ANTYPE,*GenData(1),NEW
OUTPR,ALL,ALL
OUTRES,ALL,ALL
CSYS,0
*loop nodes
*format "%8i,%10.6g,%10.6g,%10.6g"
N,*NodesNum *NodesCoord
*end nodes
CSYS,0
*loop materials
MPTEMP,,,,,,,,  
MPTEMP,*matnum(),22 
*format "%i%10.2E"
MPDATA,EX,*matnum(),,*MatProp(YOUNG_(Ex))
*format "%i%10.2E"
MPDATA,PRXY,*matnum(),,*MatProp(POISSON_(NUXY))
*format "%i%10.2E"
MPDATA,ALPX,*matnum(),,*MatProp(ALPX)
*format "%i%10.2E"
MPDATA,DENS,*matnum(),,*MatProp(DENSIDAD_(DENS))
*end materials
*set elems(tetrahedra)>0)
*if((IsQuadratic(int)==0)&&(nelem(tetrahedra)>0))
*loop materials
MAT,*matnum()
REAL,*matnum()
ET,*matnum(),SOLID72,,,,,2
TYPE,1
*loop elems
*format "EN,%i,%i,%i,%i,%i"
*ElemsNum*ElemsConec
*end elems
*end materials
*elseif((IsQuadratic(int)==1)&&(nelem(tetrahedra)>0))
*loop materials
MAT,*matnum()
REAL,*matnum()
ET,*matnum(),SOLID92,,,,,2
TYPE,1
*loop elems
*format "EN,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i"
*ElemsNum*ElemsConec
*end elems
*end materials
*endif
*set elems(Hexahedra)
*if((IsQuadratic(int)==0)&&(nelem(Hexahedra)>0))
*loop materials
MAT,*matnum()
REAL,*matnum()
ET,*matnum(),SOLID73,,,,,2
TYPE,1
*loop elems
*format "EN,%i,%i,%i,%i,%i,%i,%i,%i,%i"
*ElemsNum*ElemsConec
*end elems
*end materials
*elseif((IsQuadratic(int)==1)&&(nelem(Hexahedra)>0))
*loop materials
MAT,*matnum()
REAL,*matnum()
ET,*matnum(),SOLID95,,,,,2
TYPE,1
*loop elems
*format "EN,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i"
*ElemsNum*ElemsConec
*end elems
*end materials
*endif
*Set Cond Point-Constraints *nodes *or(1,int) *or(2,int) *or(3,int)
*Add Cond Line-Constraints *nodes *or(1,int) *or(2,int) *or(3,int)
*Add Cond Surface-Constraints *nodes *or(1,int) *or(2,int) *or(3,int)
*loop nodes *OnlyInCond
*if(cond(1,int)==1)
D,*NodesNum,UX,0.0 
*endif
*if(cond(2,int)==1)
D,*NodesNum,UY,0.0
*endif
*if(cond(3,int)==1)
D,*NodesNum,UZ,0.0
*endif
*if(cond(4,int)==1)
*if(IsQuadratic(int)==1)
*messagebox - Ansys Cuadratic Elements does not have rotational DOF - Process finished with error
*else
D,*NodesNum,ROTX,0.0
*endif
*endif
*if(cond(5,int)==1)
*if(IsQuadratic(int)==1)
*messagebox - Ansys Cuadratic Elements does not have rotational DOF - Process finished with error
*else
D,*NodesNum,ROTY,0.0
*endif
*endif
*if(cond(6,int)==1)
*if(IsQuadratic(int)==1)
*messagebox - Ansys Cuadratic Elements does not have rotational DOF - Process finished with error
*else
D,*NodesNum,ROTZ,0.0
*endif
*endif
*end nodes
*Set Cond Point-Force-Load *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*format "F,%i,FX,%10.3g"
*NodesNum*cond(1)
*format "F,%i,FY,%10.3g"
*NodesNum*cond(2)
*format "F,%i,FZ,%10.3g"
*NodesNum*cond(3)
*end nodes
*endif
*Set Cond Point-Moment-Load *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*format "F,%i,MX,%10.3g"
*NodesNum*cond(1)
*format "F,%i,MY,%10.3g"
*NodesNum*cond(2)
*format "F,%i,MZ,%10.3g"
*NodesNum*cond(3)
*end nodes
*endif
*Set elems(tetrahedra)
*Set Cond Surface-Load *elems *CanRepeat
*loop elems *OnlyInCond
*if(CondNumEntities(int)>0)
*if(GlobalNodes(1,int)==ElemsConec(1,int))
*format "SFE,%i,1,PRES,,%f"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(4,int))
*format "SFE,%i,2,PRES,,%f"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(3,int))
*format "SFE,%i,4,PRES,,%f"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(2,int))
*format "SFE,%i,3,PRES,,%f"
*ElemsNum*cond(1)
*endif
*endif
*end elems
*Set elems(hexahedra)
*Set Cond Surface-Load *elems *CanRepeat
*loop elems *OnlyInCond
*if(CondNumEntities(int)>0)
*if(GlobalNodes(2,int)==ElemsConec(2,int))
*format "SFE,%i,1,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(2,int)==ElemsConec(5,int))
*format "SFE,%i,2,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(2,int))
*format "SFE,%i,3,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(3,int))
*format "SFE,%i,4,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(2,int)==ElemsConec(4,int))
*format "SFE,%i,5,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if(GlobalNodes(1,int)==ElemsConec(5,int))
*format "SFE,%i,6,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*endif
*end elems
/GOPR
FINISH
/SOLU
*if(strcmp(Gendata(5),"Lowest")==0)
EQSLV,ITER,1
*elseif(strcmp(Gendata(5),"Low")==0)
EQSLV,ITER,2
*elseif(strcmp(Gendata(5),"Normal")==0)
EQSLV,ITER,3
*elseif(strcmp(Gendata(5),"High")==0)
EQSLV,ITER,4
*elseif(strcmp(Gendata(5),"Highest")==0)
EQSLV,ITER,5
*endif
SOLVE
FINISH
/POST1
*if(strcmp(Gendata(6),"GiD")==0)
/GRAPHICS,FULL
PLNSOL, U,SUM, 0,1.0
FINISH
*endif



















