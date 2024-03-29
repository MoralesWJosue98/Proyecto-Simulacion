==================================================================
                        General Data File
==================================================================
Units:
length *Units(length) mass *Units(mass)
Number of elements and nodes:
*nelem *npoin

.................................................................

Coordinates:
Node        X *Units(length)        Y *Units(length)
*set elems(all)
*loop nodes
*NodesNum *NodesCoord(1) *NodesCoord(2)
*end nodes

.................................................................

Connectivities:
Element    Node(1)   Node(2)   Node(3)     Material
*loop elems
*ElemsNum *ElemsConec *ElemsMat 
*end elems

.................................................................

Materials:
*nmats
Material      Surface density *Units(surface_density)
*loop materials
*MatNum *MatProp(Superficial_density,real)
*end materials

.................................................................

*Set Cond Point-Weight *nodes
Concentrated Weights:
*CondNumEntities(int)
Node   Mass *Units(mass)
*loop nodes *OnlyInCond
*NodesNum     *Cond(Weight)
*end nodes
