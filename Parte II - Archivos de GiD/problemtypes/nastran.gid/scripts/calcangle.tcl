namespace eval calcangle {
    
}
proc calcangle::CalcAngleTria { ielem x1 x2 x3 } {
    #only triangles, returns angle from -180 to +180 degrees
    set elems [GiD_Info mesh elements triangle $ielem]
    set p1 [lindex [GiD_Info coordinates [lindex $elems 1] mesh] 0]
    set p2 [lindex [GiD_Info coordinates [lindex $elems 2] mesh] 0]
    set p3 [lindex [GiD_Info coordinates [lindex $elems 3] mesh] 0]
    
    set xmat [MathUtils::VectorNormalized [list $x1 $x2 $x3]]
    set xl [MathUtils::VectorNormalized [MathUtils::VectorDiff $p1 $p2]]
    set yl [MathUtils::VectorNormalized [MathUtils::VectorDiff $p2 $p3]]
    #yl is not set to be normal to xl, but it's not used
    set zl [MathUtils::VectorNormalized [MathUtils::VectorVectorialProd $xl $yl]]
    set xmatn [MathUtils::ScalarByVectorProd [MathUtils::VectorDotProd $xmat $zl] $zl]
    set xmatt [MathUtils::VectorDiff $xmatn $xmat]
    set anglerad [expr {acos([MathUtils::VectorDotProd $xl $xmatt])}]
    #acos return anglerad from 0 to pi
    if { [MathUtils::VectorDotProd [MathUtils::VectorVectorialProd $xl $xmatt] $zl] < 0 } {
        set anglerad [expr {-$anglerad}]
    }
    set angle [MathUtils::FromRadToDegree $anglerad] 
    #la linea siguiente solo vale para las versiones >= 7.4.7b
    set angle [GiD_FormatReal "%#8.5g" $angle forcewidthnastran]
    return $angle
}

proc calcangle::CalcAngleQuad { ielem x1 x2 x3 } {
    #only quadrilateral, returns angle from -180 to +180 degrees
    set elems [GiD_Info mesh elements quadrilateral $ielem]
    set p1 [lindex [GiD_Info coordinates [lindex $elems 1] mesh] 0]
    set p2 [lindex [GiD_Info coordinates [lindex $elems 2] mesh] 0]
    set p3 [lindex [GiD_Info coordinates [lindex $elems 3] mesh] 0]
    set p4 [lindex [GiD_Info coordinates [lindex $elems 4] mesh] 0]
    
    set xmat [MathUtils::VectorNormalized [list $x1 $x2 $x3]]
    
    set xl [MathUtils::VectorNormalized [MathUtils::VectorDiff $p1 $p2]]
    set yl [MathUtils::VectorNormalized [MathUtils::VectorDiff $p2 $p3]]
    #yl is not set to be normal to xl, but it's not used
    set zl [MathUtils::VectorNormalized [MathUtils::VectorVectorialProd $xl $yl]]    
    #must verify than zl is not null (for example if p2==p3: quadrilateral degenerated to triangle)
    
    set xmatn [MathUtils::ScalarByVectorProd [MathUtils::VectorDotProd $xmat $zl] $zl]
    set xmatt [MathUtils::VectorDiff $xmatn $xmat]
    set anglerad [expr {acos([MathUtils::VectorDotProd $xl $xmatt])}]
    #acos return anglerad from 0 to pi
    if { [MathUtils::VectorDotProd [MathUtils::VectorVectorialProd $xl $xmatt] $zl] < 0 } {
        set anglerad [expr {-$anglerad}]
    }
    set angle [MathUtils::FromRadToDegree $anglerad] 
    #la linea siguiente solo vale para las versiones >= 7.4.7b
    set angle [GiD_FormatReal "%#8.5g" $angle forcewidthnastran]
    return $angle
}