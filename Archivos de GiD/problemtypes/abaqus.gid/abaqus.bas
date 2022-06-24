*tcl(abaqus::writefile)
*loop materials
**ELSET,ELSET=*Matprop(0)_Set
*loop elems
*if(elemsmat==matnum())
*format "%i,"
*ElemsNum
*endif
*end elems
*end materials
*loop elems
*if(elemsmat==0)
*WarningBox Warning: Not all mesh elements are related with a material
*break
*endif
*end elems
*loop localaxes 
**ORIENTATION,NAME=Axes_system_*LocalAxesNum
*set var x1 =LocalAxesDef(1)
*set var x2 =LocalAxesDef(4)
*set var x3 =LocalAxesDef(7)
*set var y1 =LocalAxesDef(2)
*set var y2 =LocalAxesDef(5)
*set var y3 =LocalAxesDef(8)
*format "%10.4lg,%10.4lg,%10.4lg,%10.4lg,%10.4lg,%10.4lg" 
*x1 *x2 *x3 *y1 *y2 *y3
*end localaxes