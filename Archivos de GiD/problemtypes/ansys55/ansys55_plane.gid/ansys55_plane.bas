/FILNAME,*GenData(3)
/PREP7
/NOPR
/COM -----------------------------------------------------------
/COM    Copyright @CIMNE 2000 GiD to ANSYS TransLator
/COM    Written by: rgyarmati@cantv.net
/COM    Version:  6.1
/COM -----------------------------------------------------------
/COM
/TITLE,*GenData(3)
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
*format "%i%10.3g"
MPDATA,EX,*matnum(),,*MatProp(YOUNG_(Ex))
*format "%i%10.3g"
MPDATA,PRXY,*matnum(),,*MatProp(POISSON_(NUXY))
*format "%i%10.3g"
MPDATA,ALPX,*matnum(),,*MatProp(ALPX)
*format "%i%10.3g"
MPDATA,DENS,*matnum(),,*MatProp(DENSIDAD_(DENS))
*end materials
*set elems(triangle)
*if((IsQuadratic(int)==0)&&(nelem(triangle)>0))
*messagebox - Ansys does not work with Triangular Linear Elements - Process finished with error
*endif
*set elems(quadrilateral)
*if((IsQuadratic(int)==0)&&(nelem(quadrilateral)>0))
*loop materials
MAT,*matnum()
REAL,*matnum()
*if((strcmp(GenData(2),"Plane_Strain")==0))
ET,1,PLANE42,,,2
TYPE,1
*else
ET,1,PLANE42,,,3
R,1,*Gendata(8)
TYPE,1
*endif
*loop elems
*format "EN,%i,%i,%i,%i,%i"
*ElemsNum*ElemsConec
*end elems
*end materials
*endif
*set elems(triangle)
*if((IsQuadratic(int)==1)&&(nelem(triangle)>0))
*loop materials
MAT,*matnum()
REAL,*matnum()
*if((strcmp(GenData(2),"Plane_Strain")==0))
ET,1,PLANE2,,,2
TYPE,1
*else
ET,1,PLANE2,,,3
R,1,*Gendata(8)
TYPE,1
*endif
*set elems(triangle)
*loop elems
*format "EN,%i,%i,%i,%i,%i,%i,%i"
*ElemsNum*ElemsConec
*end elems
*end materials
*endif
*set elems(quadrilateral)
*if((IsQuadratic(int)==1)&&(nelem(quadrilateral)>0))
*loop materials
MAT,*matnum()
REAL,*matnum()
*if((strcmp(GenData(2),"Plane_Strain")==0))
ET,1,PLANE82,,,0
TYPE,1
*else
ET,1,PLANE82,,,3
R,1,*Gendata(8)
TYPE,1
*endif
*set elems(quadrilateral)
*loop elems
*format "EN,%i,%i,%i,%i,%i,%i,%i,%i,%i"
*ElemsNum*ElemsConec
*end elems
*end materials
*endif
*Set Cond Point-Constraints *nodes *or(1,int) *or(2,int)
*Add Cond Line-Constraints *nodes *or(1,int) *or(2,int)
*loop nodes *OnlyInCond
*if(cond(1,int)==1)
D,*NodesNum,UX,0.0
*endif
*if(cond(2,int)==1)
D,*NodesNum,UY,0.0
*endif
*end nodes
*Set Cond Point-Force-Load *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*format "F,%i,FX,%10.3g"
*NodesNum*cond(1)
*format "F,%i,FY,%10.3g"
*NodesNum*cond(2)
*end nodes
*endif
*Set Cond Point-Moment-Load *nodes *CanRepeat
*if(CondNumEntities(int)>0)
*loop nodes *OnlyInCond
*format "F,%i,MX,%10.3g"
*NodesNum*cond(1)
*format "F,%i,MY,%10.3g"
*NodesNum*cond(2)
*end nodes
*endif
*Set Elems(triangle)
*Set Cond Line-Load *elems *CanRepeat
*loop elems *OnlyInCond
*if(CondNumEntities(int)>0)
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(2,int)))
*format "SFE,%i,1,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if((GlobalNodes(1,int)==ElemsConec(2,int))&&(GlobalNodes(2,int)==ElemsConec(3,int)))
*format "SFE,%i,2,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if((GlobalNodes(1,int)==ElemsConec(3,int))&&(GlobalNodes(2,int)==ElemsConec(1,int)))
*format "SFE,%i,3,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*endif
*end elems
*Set Elems(quadrilateral)
*Set Cond Line-Load *elems *CanRepeat
*loop elems *OnlyInCond
*if(CondNumEntities(int)>0)
*if((GlobalNodes(1,int)==ElemsConec(1,int))&&(GlobalNodes(2,int)==ElemsConec(2,int)))
*format "SFE,%i,1,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if((GlobalNodes(1,int)==ElemsConec(2,int))&&(GlobalNodes(2,int)==ElemsConec(3,int)))
*format "SFE,%i,2,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if((GlobalNodes(1,int)==ElemsConec(3,int))&&(GlobalNodes(2,int)==ElemsConec(4,int)))
*format "SFE,%i,3,PRES,,%10.3g"
*ElemsNum*cond(1)
*endif
*if((GlobalNodes(1,int)==ElemsConec(4,int))&&(GlobalNodes(2,int)==ElemsConec(1,int)))
*format "SFE,%i,4,PRES,,%10.3g"
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
*if(strcmp(Gendata(7),"GiD")==0)
/GRAPHICS,FULL
PLNSOL, U,SUM, 0,1.0
FINISH
*endif
