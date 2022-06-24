*if(nmats(int)==0)
*MessageBox Error: materials must be applied.
*endif
*if(strcmp(Gendata(Behavior),"Solid")==0)
*if(nelem(Tetrahedra,int)<=0 && nelem(Hexahedra,int)<=0)
*MessageBox Error: General data behaviour is set as solid but there are not any hexahedra or tetrahedra.
*endif
*else
*if(nelem(Triangle,int)<=0 && nelem(Quadrilateral,int)<=0)
*MessageBox Error: General data behaviour is set as shell, membrane or blate but there are not any triangle or quadrilateral.
*endif
*endif
TABLE:  "ANALYSIS OPTIONS"
   Solver=Advanced SolverProc=Auto Force32Bit=No StiffCase=None GeomMod=No

TABLE:  "COORDINATE SYSTEMS"
   Name=GLOBAL Type=Cartesian X=0 Y=0 Z=0 AboutZ=0 AboutY=0 AboutX=0

TABLE:  "DATABASE FORMAT TYPES"
   UnitsCurr=Yes OverrideE=No

TABLE:  "MASSES 1 - MASS SOURCE"
   MassFrom=Elements

TABLE:  "PREFERENCES - DIMENSIONAL"
   MergeTol=0.0000001 FineGrid=0.25 Nudge=0.25 SelectTol=3 SnapTol=12 SLineThick=1 PLineThick=4 MaxFont=8 MinFont=3 AutoZoom=10 ShrinkFact=70 TextFileLen=240

TABLE:  "ACTIVE DEGREES OF FREEDOM"
   UX=*GenData(Degree_of_freedom_DX) UY=*GenData(Degree_of_freedom_DY) UZ=*GenData(Degree_of_freedom_DZ) RX=*GenData(Degree_of_freedom_ROTX) RY=*GenData(Degree_of_freedom_ROTY) RZ=*GenData(Degree_of_freedom_ROTZ)
 
TABLE:  "PROGRAM CONTROL"
   ProgramName=SAP2000 Version=*Gendata(SAP2000_Version) CurrUnits= *\
*if(strcmp(Gendata(Units),"lb-in-F")==0)
"lb, in, F"*\
*elseif(strcmp(Gendata(Units),"lb-ft-F")==0)
"lb, ft, F" *\
*elseif(strcmp(Gendata(Units),"lb-in-F")==0)
"lb, in, F"*\
*elseif(strcmp(Gendata(Units),"Kip-in-F")==0)
"Kip, in, F" *\
*elseif(strcmp(Gendata(Units),"Kip-ft-F")==0)
"Kip, ft, F"*\
*elseif(strcmp(Gendata(Units),"KN-mm-C")==0)
"KN, mm, C"*\
*elseif(strcmp(Gendata(Units),"KN-m-C")==0)
"KN, m, C"*\
*elseif(strcmp(Gendata(Units),"Kgf-mm-C")==0)
"Kgf, mm, C"*\
*elseif(strcmp(Gendata(Units),"Kgf-m-C")==0)
"Kgf, m, C"*\
*elseif(strcmp(Gendata(Units),"N-mm-C")==0)
"N, mm, C"*\
*elseif(strcmp(Gendata(Units),"N-m-C")==0)
"N, m, C"*\
*elseif(strcmp(Gendata(Units),"Ton-mm-C")==0)
*\
*if(strcmp(Gendata(SAP2000_Version),"15.0.0") == 0)
"Tonf,mm,C"*\
*else
"Ton,mm,C"*\
*endif
*\
*elseif(strcmp(Gendata(Units),"Ton-m-C")==0)
*\
*if(strcmp(Gendata(SAP2000_Version),"15.0.0") == 0)
"Tonf,m,C" *\
*else
"Ton,m,C"*\
*endif
*\
*elseif(strcmp(Gendata(Units),"KN-cm-C")==0)
"KN, cm, C"*\
*elseif(strcmp(Gendata(Units),"Kgf-cm-C")==0)
"Kgf, cm, C"*\
*elseif(strcmp(Gendata(Units),"N-cm-C")==0)
"N, cm, C"*\
*else
*\
*if(strcmp(Gendata(SAP2000_Version),"15.0.0") == 0)
"Tonf,cm,C" *\
*else
"Ton,cm,C"*\
*endif
*\
*endif
   SteelCode=AISC-LRFD93 ConcCode="ACI 318-05/IBC2003" AlumCode="AA-ASD 2000" ColdCode=AISI-ASD96 BridgeCode="AASHTO LRFD 2007" RegenHinge=Yes

TABLE:  "JOINT COORDINATES"
*loop nodes
   Joint=*NodesNum CoordSys=GLOBAL CoordType=Cartesian XorR=*NodesCoord(1) Y=*NodesCoord(2) Z=*NodesCoord(3) SpecialJt=No
*end nodes

TABLE:  "JOINT RESTRAINT ASSIGNMENTS"
*Set Cond Point_Restraints *nodes
*Add Cond Line_Restraints *nodes
*Add Cond Surface_Restraints *nodes
*if(CondNumEntities(int)==0)
*MessageBox Warning: constraints must be assigned.
*endif
*loop nodes *OnlyInCond
   Joint=*NodesNum U1=*cond(X-Translation) U2=*cond(Y-Translation) U3=*cond(Z-Translation) R1=*cond(X-Rotation) R2=*cond(Y-Rotation) R3=*cond(Z-Rotation)
*end nodes

TABLE:  "MATERIAL PROPERTIES 01 - GENERAL"
*loop materials
   Material="*MatProp(0)" Type=Concrete SymType=Isotropic TempDepend=No Color=Blue Notes="Nothing"
*end materials
 
TABLE:  "MATERIAL PROPERTIES 02 - BASIC MECHANICAL PROPERTIES"
*loop materials
   Material=*MatProp(0) Unitweight=*MatProp(Weight)*\
   UnitMass=*MatProp(Mass) E1=*MatProp(E) U12=*MatProp(Poisson's_ratio) A1=0.00
*end materials

*if(strcmp(Gendata(Behavior),"Solid")==0)
TABLE:  "SOLID PROPERTY DEFINITIONS"
*loop materials
  Solidprop=SOLID*matnum Material="*MatProp(0)" MatAngleA=0 MatAngleB=0 MatAngleC=0 InComp=Yes Color=Magenta Notes="Nothing"
*end materials

TABLE:  "SOLID PROPERTY ASSIGNMENTS"
*loop elems
  Solid=*elemsnum SolidProp=SOLID*elemsmat
*end elems

TABLE:  "CONNECTIVITY - SOLID"
*Set elems(Hexahedra)
*loop elems
  Solid=*elemsnum Joint1=*elemsconec(1) Joint2=*elemsconec(2) Joint3=*elemsconec(4) Joint4=*elemsconec(3) Joint5=*elemsconec(5) Joint6=*elemsconec(6) Joint7=*elemsconec(8) Joint8=*elemsconec(7) 
*end elems
*Set elems(Tetrahedra)
*loop elems
  Solid=*elemsnum Joint1=*elemsconec(1) Joint2=*elemsconec(2) Joint3=*elemsconec(3) Joint4=*elemsconec(3) Joint5=*elemsconec(4) Joint6=*elemsconec(4) Joint7=*elemsconec(4) Joint8=*elemsconec(4) 
*end elems
*set elems(All)

*else
TABLE:  "AREA SECTION PROPERTIES"
*if(strcmp(Gendata(Behavior),"Shell")==0)
*loop materials
  Section=Plate*matnum Material="*MatProp(0)" AreaType=Shell Type=Shell-Thick Thickness=*MatProp(Thickness) BendThick=*MatProp(Thickness) Color=Green Notes="Nothing"
*end materials
*elseif(strcmp(Gendata(Behavior),"Membrane")==0)
*loop materials
  Section=Plate*matnum Material="*MatProp(0)" AreaType=Shell Type=Membrane Thickness=*MatProp(Thickness) BendThick=*MatProp(Thickness) Color=Green Notes="Nothing"
*end materials
*elseif(strcmp(Gendata(Behavior),"Plate")==0)
*loop materials
  Section=Plate*matnum Material="*MatProp(0)" AreaType=Shell Type=Plate-Thick Thickness=*MatProp(Thickness) BendThick=*MatProp(Thickness) Color=Green Notes="Nothing"
*end materials
*else
*MessageBox *Gendata(Behavior) must be Shell, Membrane or Plate
*endif

TABLE:  "AREA SECTION ASSIGNMENTS"
*loop elems
   Area=*elemsnum  Section=Plate*elemsmat  MatProp=Default   
*end elems

TABLE:  "CONNECTIVITY - AREA"
*set elems(Triangle)
*loop elems
  Area=*elemsnum Joint1=*elemsconec(1) Joint2=*elemsconec(2) Joint3=*elemsconec(3)
*end elems
*set elems(Quadrilateral)
*loop elems
  Area=*elemsnum Joint1=*elemsconec(1) Joint2=*elemsconec(2) Joint3=*elemsconec(3) Joint4=*elemsconec(4)
*end elems
*set elems(All)
*endif solid

TABLE:  "LOAD PATTERN DEFINITIONS"
*Set Cond point_Load *nodes
*Add Cond point_Momentum *nodes
*if(strcmp(Gendata(Self_weight),"Active")==0 && CondNumEntities(int)>0)
   LoadPat=PP+CM  DesignType=DEAD SelfWtMult=1
*elseif(strcmp(Gendata(Self_weight),"Active")==0 && CondNumEntities(int)==0)
   LoadPat=PP  DesignType=DEAD SelfWtMult=1
*elseif(strcmp(Gendata(Self_weight),"Deactive")==0 && CondNumEntities(int)>0)
   LoadPat=CM  DesignType=DEAD SelfWtMult=0
*else
   LoadPat=Unloaded DesignType=DEAD SelfWtMult=0 
*endif

TABLE:  "LOAD CASE DEFINITIONS"
*if(strcmp(Gendata(Self_weight),"Active")==0 && CondNumEntities(int)>0)
   Case=PP+CM Type=LinStatic InitialCond=Zero DesTypeOpt="Prog Det" DesignType=DEAD AutoType=None RunCase=Yes
*elseif(strcmp(Gendata(Self_weight),"Active")==0 && CondNumEntities(int)==0)
   Case=PP Type=LinStatic InitialCond=Zero DesTypeOpt="Prog Det" DesignType=DEAD AutoType=None RunCase=Yes
*elseif(strcmp(Gendata(Self_weight),"Deactive")==0 && CondNumEntities(int)>0)
   Case=CM Type=LinStatic InitialCond=Zero DesTypeOpt="Prog Det" DesignType=DEAD AutoType=None RunCase=Yes
*else
   Case=Unloaded Type=LinStatic InitialCond=Zero DesTypeOpt="Prog Det" DesignType=DEAD AutoType=None RunCase=Yes 
*endif

TABLE:  "CASE - STATIC 1 - LOAD ASSIGNMENTS"
*if(strcmp(Gendata(Self_weight),"Active")==0 && CondNumEntities(int)>0)
   Case=PP+CM LoadType="Load pattern" LoadName=PP+CM   LoadSF=1
*elseif(strcmp(Gendata(Self_weight),"Active")==0 && CondNumEntities(int)==0)
   Case=PP LoadType="Load pattern" LoadName=PP   LoadSF=1
*elseif(strcmp(Gendata(Self_weight),"Deactive")==0 && CondNumEntities(int)>0)
   Case=CM LoadType="Load pattern" LoadName=CM   LoadSF=1
*else
   Case=Unloaded LoadType="Load pattern" LoadName=Unloaded  LoadSF=1
*endif

TABLE:  "JOINT LOADS - FORCE"
*if(strcmp(Gendata(Self_weight),"Active")==0)
*Set Cond point_Load *nodes
*loop nodes *OnlyInCond
   Joint=*NodesNum LoadPat=PP+CM CoordSys=GLOBAL F1=*cond(X-Force) F2=*cond(Y-Force) F3=*cond(Z-Force)
*end nodes
*Set Cond point_Momentum *nodes
*loop nodes *OnlyInCond
   Joint=*NodesNum LoadPat=PP+CM CoordSys=GLOBAL M1=*cond(X-Moment) M2=*cond(Y-Moment) M3=*cond(Z-Moment)
*end nodes
*else
*Set Cond point_Load *nodes
*loop nodes *OnlyInCond
   Joint=*NodesNum LoadPat=CM CoordSys=GLOBAL F1=*cond(X-Force) F2=*cond(Y-Force) F3=*cond(Z-Force)
*end nodes
*Set Cond point_Momentum *nodes
*loop nodes *OnlyInCond
   Joint=*NodesNum LoadPat=CM CoordSys=GLOBAL M1=*cond(X-Moment) M2=*cond(Y-Moment) M3=*cond(Z-Moment)
*end nodes
*endif

TABLE:  "GROUPS 1 - DEFINITIONS"
*Loop Layers
   GroupName=*LayerName Selection=Yes SectionCut=Yes Steel=Yes Concrete=Yes Aluminum=Yes ColdFormed=Yes Stage=Yes Bridge=Yes AutoSeismic=No AutoWind=No SelDesSteel=No SelDesAlum=No SelDesCold=No   MassWeight=Yes Color=Red
*End Layers

TABLE:  "GROUPS 2 - ASSIGNMENTS"
*Set elems(Hexahedra)
*Add elems(Tetrahedra)
*Loop Elems
   GroupName=*ElemsLayerName ObjectType=Solid ObjectLabel=*ElemsNum
*End Elems
*Set elems(Triangle)
*Add elems(Quadrilateral)
*Loop Elems
   GroupName=*ElemsLayerName ObjectType=Area ObjectLabel=*ElemsNum
*End Elems

END TABLE DATA
