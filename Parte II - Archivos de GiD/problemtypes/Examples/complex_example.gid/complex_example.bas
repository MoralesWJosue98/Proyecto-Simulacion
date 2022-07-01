*RealFormat "%g"
*IntFormat "%4i"
GiD Post Results File 1.0

*for(istep=1.0;istep<=GenData(Number_of_iterations,int);istep=istep+1)
Result "Height" "geometry" *istep Vector OnNodes
Values
*loop nodes
  *NodesNum *NodesCoord(1) *NodesCoord(2) *NodesCoord(3)
*end
End Values

*set Cond Layer_Scalar_result *nodes
*add Cond Volume_Scalar_result *nodes
*add Cond Surface_Scalar_result *nodes
*add Cond Line_Scalar_result *nodes
*add Cond Point_Scalar_result *nodes
*if(CondNumEntities(int)!=0)
Result "Scalar result" "geometry" *istep Scalar OnNodes
Values
*loop nodes *OnlyInCond
  *NodesNum *cond(Value,real)
*end nodes
End Values
*endif

*set Cond Layer_Vector_result *nodes
*add Cond Volume_Vector_result *nodes
*add Cond Surface_Vector_result *nodes
*add Cond Line_Vector_result *nodes
*add Cond Point_Vector_result *nodes
*if(CondNumEntities(int)!=0)
Result "Vector result" "geometry" *istep Vector OnNodes
Values
*loop nodes *OnlyInCond
  *NodesNum *cond(Value_X,real) *cond(Value_Y,real) *cond(Value_Z,real)
*end nodes
End Values
*endif

*# para las dos condiciones de evaluacion de funciones
*# to debug tcl(proc evaluateConditionFunction { fnc x y z t} { W "expr $fnc = [ expr $fnc]";expr $fnc})*\
*tcl(proc evaluateConditionFunction { fnc x y z t} { expr $fnc})*\
*tcl(proc evaluateElementConditionFunction { fnc i n t} { expr $fnc})*\
*tcl(proc quitaDollar { fnc} { regsub -all {\$} $fnc {}})*\
*#
*set Cond Volume_Scalar_function *nodes
*add Cond Surface_Scalar_function *nodes
*if(CondNumEntities(int)!=0)
*# truco para poner la formula como nombre de resultado
*loop nodes *OnlyInCond
Result "*tcl(quitaDollar *cond(UserFunction))" "geometry" *istep Scalar OnNodes
*break
*end nodes
Values
*loop nodes *OnlyInCond
*NodesNum *tcl(evaluateConditionFunction *cond(UserFunction) *NodesCoord(1) *NodesCoord(2) *NodesCoord(3) *istep)
*end nodes
End Values
*endif

*set Cond Volume_Vector_function *nodes
*add Cond Surface_Vector_function *nodes
*if(CondNumEntities(int)!=0)
Result "Vector function" "geometry" *istep Vector OnNodes
*# truco para poner la formula como nombre de componente
*loop nodes *OnlyInCond
ComponentNames "Vx = *tcl(quitaDollar *cond(Ux))", "Vy = *tcl(quitaDollar *cond(Uy))", "Vz = *tcl(quitaDollar *cond(Uz))"
*break
*end nodes
Values
*loop nodes *OnlyInCond
*#  *NodesNum *cond(Value_X,real) *cond(Value_Y,real) *cond(Value_Z,real)
*#  *NodesNum *cond(Ux) *cond(Uy) *cond(Uz) 
*#  *NodesNum *Operation(cond(Ux,real))) *Operation(cond(Uy)) *Operation(cond(Uz)) 
*#*tcl(expr 2+*NodesCoord(1))
*NodesNum *tcl(evaluateConditionFunction *cond(Ux) *NodesCoord(1) *NodesCoord(2) *NodesCoord(3) *istep)*\
 *tcl(evaluateConditionFunction *cond(Uy) *NodesCoord(1) *NodesCoord(2) *NodesCoord(3) *istep)*\
 *tcl(evaluateConditionFunction *cond(Uz) *NodesCoord(1) *NodesCoord(2) *NodesCoord(3) *istep)
*# *NodesNum *Operation(tcl(set res [ eval 2.0 * NodesCoord(1)])))
*end nodes
End Values
*endif

*set Cond Layer_Scalar_SinCos *nodes
*add Cond Volume_Scalar_SinCos *nodes
*add Cond Surface_Scalar_SinCos *nodes
*add Cond Line_Scalar_SinCos *nodes
*add Cond Point_Scalar_SinCos *nodes
*if(CondNumEntities(int)!=0)
Result "Scalar sincos" "geometry" *istep Scalar OnNodes
Values
*loop nodes *OnlyInCond
  *NodesNum *cond(valorFuncion,real)
*end nodes
End Values
*endif

*set Cond Layer_Vector_Escalado *nodes
*add Cond Volume_Vector_Escalado *nodes
*add Cond Surface_Vector_Escalado *nodes
*add Cond Line_Vector_Escalado *nodes
*add Cond Point_Vector_Escalado *nodes
*if(CondNumEntities(int)!=0)
Result "Vector escalado" "geometry" *istep Vector OnNodes
Values
*loop nodes *OnlyInCond
  *NodesNum *cond(valorFuncionX,real) *cond(valorFuncionY,real) *cond(valorFuncionZ,real)
*end nodes
End Values
*endif

*set Cond Layer_Scalar_Poli *nodes
*add Cond Volume_Scalar_Poli *nodes
*add Cond Surface_Scalar_Poli *nodes
*add Cond Line_Scalar_Poli *nodes
*add Cond Point_Scalar_Poli *nodes
*if(CondNumEntities(int)!=0)
Result "Scalar poli" "geometry" *istep Scalar OnNodes
Values
*loop nodes *OnlyInCond
  *NodesNum *cond(valorFuncion,real)
*end nodes
End Values
*endif

*# Elemental conditions

*set Cond Volume_Element_Centre *elems
*if(CondNumEntities(int)!=0)
Result "Element's centre" "geometry" *istep Vector OnGaussPoints "*cond(GaussPointName)"
Values
*loop elems *OnlyInCond
*ElemsNum *ElemsCenter
*end elems
End Values
*endif

*set Cond Volume_Element_Scalar_function *elems
*# add should not be here as it uses another gauss point name!
*# *add Cond Surface_Element_Scalar_function *elems
*if(CondNumEntities(int)!=0)
*# truco para poner la formula como nombre de resultado
*loop elems *OnlyInCond
Result "*tcl(quitaDollar *cond(UserFunction))" "geometry" *istep Scalar OnGaussPoints "*cond(GaussPointName)"
*break
*end elems
Values
*loop elems *OnlyInCond
*ElemsNum *tcl(evaluateElementConditionFunction *cond(UserFunction) *elemsnum *nelem *istep)
*end elems
End Values
*endif

*set Cond Volume_Element_Vector_function *elems
*# add should not be here as it uses another gauss point name!
*#*add Cond Surface_Element_Vector_function *elems
*if(CondNumEntities(int)!=0)
Result "Vector Elem function" "geometry" *istep Vector OnGaussPoints "*cond(GaussPointName)"
*# truco para poner la formula como nombre de componente
*loop elems *OnlyInCond
ComponentNames "Vx = *tcl(quitaDollar *cond(Ux))", "Vy = *tcl(quitaDollar *cond(Uy))", "Vz = *tcl(quitaDollar *cond(Uz))"
*break
*end elems
Values
*loop elems *OnlyInCond
*ElemsNum *tcl(evaluateElementConditionFunction *cond(Ux) *elemsnum *nelem *istep)*\
 *tcl(evaluateElementConditionFunction *cond(Uy) *elemsnum *nelem *istep)*\
 *tcl(evaluateElementConditionFunction *cond(Uz) *elemsnum *nelem *istep)
*end elems
End Values
*endif

*# *for(istep=1.0;istep<=10.0;istep=istep+1)
*end for
