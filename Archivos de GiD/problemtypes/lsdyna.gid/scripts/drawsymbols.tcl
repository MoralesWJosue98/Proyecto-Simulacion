
namespace eval lsdyna {
    variable constraints_objs
    variable constraints_images
}

proc lsdyna::_give_gravity_vec {} {
    
    set gravity_vec ""
    foreach i [list X Y Z] {
        set xp "/*/blockdata\[@n='General data'\]/container\[@n='Gravity'\]/value\[@n='Gravity_$i'\]"
        set node [gid_groups_conds::give_node_xpath $xp]
        lappend gravity_vec [get_domnode_attribute $node v]
    }
    set err [catch { m::unitLengthVector $gravity_vec } gravity_vec]
    if { $err } { set gravity_vec "0 0 -1" }

    return $gravity_vec
}

proc lsdyna::_give_value_and_unit { valuesList prop } {
    set ipos [lsearch -index 0 $valuesList $prop]
    set elm [lindex $valuesList $ipos]
    return [lrange $elm 1 2]
}

proc lsdyna::_calc_yz_beam { xvec } {
    
    set epsilon 1e-11
    if { abs([lindex $xvec 0]) > $epsilon || abs([lindex $xvec 1]) } {
        if { abs([lindex $xvec 0]) > $epsilon } {
            set yvec [list [expr {-1*[lindex $xvec 1]/double([lindex $xvec 0])}] 1.0 0.0]
        } else {
            set yvec [list 1.0 0.0 0.0]
        }
        set yvec [m::unitLengthVector $yvec]
        set zvec [m::vectorprod3 $xvec $yvec]
        if { abs([lindex $zvec 2]) < $epsilon } {
            set yvec [m::scale -1.0 $yvec]
            set zvec [m::vectorprod3 $xvec $yvec]
        }
    } else {
        set yvec [list 1.0 0.0 0.0]
        set zvec [m::vectorprod3 $xvec $yvec]
    }
    return [list $yvec $zvec]
}

proc lsdyna::_give_OpenGL_mat { xvec yvec zvec } {
    # mat is 4x4 = 16 in column order (OpenGL matrix)
    set mat [concat $xvec 0.0]
    eval lappend mat $yvec 0.0
    eval lappend mat $zvec 0.0
    lappend mat 0.0 0.0 0.0 1.0
    return $mat
}

proc lsdyna::_give_LA_mat { mat } {
    
    set ret ""
    foreach "c1 c2 c3" $mat { 
        lappend ret [list $c1 $c2 $c3]
    }
    return $ret
}

proc lsdyna::draw_symbol_constraints { what valuesList } {
    variable constraints_objs
    variable constraints_images

    foreach "ndesp nrot desp_vec rot_vec" [list 0 0 "" ""] break
    foreach i [list X Y Z] {
        set c [lindex [_give_value_and_unit $valuesList ${i}_Constraint] 0]
        if { $c == 0 } { incr ndesp }
        if { ![string is boolean -strict $c] } { set c 1 }
        lappend desp_vec [expr {!$c}]
    }
    foreach i [list theta_x theta_y theta_z] {
        set c [lindex [_give_value_and_unit $valuesList ${i}_Constraint] 0]
        if { $c == 0 } { incr nrot }
        if { ![string is boolean -strict $c] } { set c 1 }
        lappend rot_vec [expr {!$c}]
    }

    switch $nrot {
        0 {
            switch $ndesp {
                0 { set symbol constraints_3D_nomov }
                default { set symbol constraints_3D_rotate }
            }
        }
        1 {
            switch $ndesp {
                0 { set symbol constraints_2D_rotate }
                1 { set symbol constraints_2D_rotate_desp }
                default { set symbol constraints_3D_rotate }
            } 
        }
        default {
            switch $ndesp {
                0 { set symbol constraints_3D_rotate }
                1 { set symbol constraints_2D_rotate_desp }
                default { set symbol constraints_3D_rotate }
            } 
        }
    }
    # not used by now: constraints_3D_rotate_desp
    set xvec [m::scale -1 [_give_gravity_vec]]

    foreach "yvec zvec" [list "" ""] break
    switch $nrot {
        0 { # nothing }
        1 {
            switch $ndesp {
                0 {
                    set zvec $rot_vec
                    set yvec [m::vectorprod3 $zvec $xvec]
                    if { [m::norm $yvec] < 1e-11 } {
                        set symbol constraints_3D_rotate
                        set yvec ""
                    } else {
                        set xvecN [m::vectorprod3 $yvec $zvec]
                        if { [m::dotproduct $xvec $xvecN] < 0.0 } {
                            set xvec [m::scale -1 $xvecN]
                            set yvec [m::vectorprod3 $zvec $xvec]
                        } else {
                            set xvec $xvecN
                        }
                    }
                }
                1 {
                    set yvec $desp_vec
                    set zvec $rot_vec
                    set xvecN [m::vectorprod3 $yvec $zvec]
                    if { [m::norm $xvecN] < 1e-11 } {
                        set symbol constraints_3D_rotate
                        set yvec ""
                    } else {
                        if { [m::dotproduct $xvec $xvecN] < 0.0 } {
                            set xvec [m::scale -1 $xvecN]
                            set zvec [m::vectorprod3 $xvec $yvec]
                        } else {
                            set xvec $xvecN
                        }
                    }
                }
            } 
        }
        default {
            switch $ndesp {
                0 { # nothing }
                1 {
                    set yvec $desp_vec
                    set zvec [m::vectorprod3 $xvec $yvec]
                    if { [m::norm $zvec] < 1e-11 } {
                        set symbol constraints_3D_rotate
                        set yvec ""
                    } else {
                        set xvecN [m::vectorprod3 $yvec $zvec]
                        if { [m::dotproduct $xvec $xvecN] < 0.0 } {
                            set xvec [m::scale -1 $xvecN]
                            set zvec [m::vectorprod3 $xvec $yvec]
                        } else {
                            set xvec $xvecN
                        }
                    }
                }
            } 
        }
    }
    if { $yvec eq "" } {
        foreach "yvec zvec" [_calc_yz_beam $xvec] break
    }
    set mat [_give_OpenGL_mat $xvec $yvec $zvec]

    if { ![info exists constraints_objs($symbol)] } {
        set symbols_dir [file join $::lsdynaPriv(problemtypedir) symbols]
        set file [file join $symbols_dir $symbol.msh]

        set constraints_objs($symbol) [drawopengl draw -genlists 1]
        drawopengl draw -newlist $constraints_objs($symbol) compile
        gid_groups_conds::import_gid_mesh_as_openGL $file black blue
        drawopengl draw -endlist
    }
    if { $what eq "elastic" && ![info exists constraints_objs(elastic_constraints)] } {
        set symbols_dir [file join $::lsdynaPriv(problemtypedir) symbols]
        set file [file join $symbols_dir elastic_constraints.msh]

        set constraints_objs(elastic_constraints) [drawopengl draw -genlists 1]
        drawopengl draw -newlist $constraints_objs(elastic_constraints) compile
        gid_groups_conds::import_gid_mesh_as_openGL $file black blue
        drawopengl draw -endlist
    }
    
    set l [drawopengl draw -genlists 1]
    drawopengl draw -newlist $l compile
    drawopengl draw -pushmatrix -multmatrix $mat

    set c [lindex [_give_value_and_unit $valuesList Local_axes] 0]
    if { $c == "" } {
        set c 0
    }
    if { $c } {
        if { ![info exists constraints_images(constraints_local)] } {
            set img [image create photo -width 20 -height 20]
            $img put #bbbbff -to 0 0 20 20
            $img put blue -to 10 4 11 16
            $img put blue -to 10 3 18 4
            set constraints_images(constraints_local) $img
        }
        drawopengl draw -rasterpos "0 0 0"
        drawopengl draw -drawpixels $constraints_images(constraints_local) 
    }
    drawopengl draw -call $constraints_objs($symbol)
    if { $what eq "elastic" } {
        drawopengl draw -call $constraints_objs(elastic_constraints)
    }
    drawopengl draw -popmatrix
    drawopengl draw -endlist
    return $l
}

proc lsdyna::draw_symbol_punctual_load { valuesList } {
    variable load_objs

    foreach "ndesp nrot desp_vec rot_vec" [list 0 0 "" ""] break
    foreach i [list X Y Z] {
        set c [lindex [_give_value_and_unit $valuesList ${i}_Force] 0]
        if { $c != 0 } { incr ndesp }
        if { ![string is double -strict $c] } { set c 1 }
        lappend desp_vec $c
    }
    foreach i [list Mx My Mz] {
        set c [lindex [_give_value_and_unit $valuesList ${i}_Force] 0]
        if { $c != 0 } { incr nrot }
        if { ![string is double -strict $c] } { set c 1 }
        lappend rot_vec $c
    }
    switch $nrot {
        0 {
            switch $ndesp {
                0 { return "" }
                default { set symbol puntual_force }
            }
        }
        default {
            switch $ndesp {
                0 { set symbol puntual_moment }
                default { set symbol puntual_force_moment }
            } 
        }
    }

    if { $ndesp > 0 } {
        set xvec [m::unitLengthVector $desp_vec]
    } elseif { $nrot > 0 } {
        set xvec [m::unitLengthVector $rot_vec]
    }
    foreach "yvec zvec" [_calc_yz_beam $xvec] break
    set mat [_give_OpenGL_mat $xvec $yvec $zvec]

    if { ![info exists load_objs($symbol)] } {
        set symbols_dir [file join $::lsdynaPriv(problemtypedir) symbols]
        set file [file join $symbols_dir $symbol.msh]
        set load_objs($symbol) [drawopengl draw -genlists 1]
        drawopengl draw -newlist $load_objs($symbol) compile
        gid_groups_conds::import_gid_mesh_as_openGL $file black blue
        drawopengl draw -endlist
    }
    set l [drawopengl draw -genlists 1]
    drawopengl draw -newlist $l compile
    drawopengl draw -pushmatrix -multmatrix $mat
    drawopengl draw -call $load_objs($symbol)
    drawopengl draw -popmatrix
    drawopengl draw -endlist
    return $l
}

proc lsdyna::draw_symbol_self_weight { valuesList } {

    set xvec [m::scale -1 [_give_gravity_vec]]
    foreach "yvec zvec" [_calc_yz_beam $xvec] break
    set mat [_give_OpenGL_mat $xvec $yvec $zvec]

    set l [drawopengl draw -genlists 1]
    drawopengl draw -newlist $l compile
    drawopengl draw -pushmatrix -multmatrix $mat

    set symbols_dir [file join $::lsdynaPriv(problemtypedir) symbols]
    set file [file join $symbols_dir self_weight.msh]
    gid_groups_conds::import_gid_mesh_as_openGL $file orange orange
    drawopengl draw -popmatrix
    drawopengl draw -endlist
    return $l
}

proc lsdyna::draw_symbol_temperature { valuesList } {
    set xvec [m::scale -1 [_give_gravity_vec]]
    foreach "yvec zvec" [_calc_yz_beam $xvec] break
    set mat [_give_OpenGL_mat $xvec $yvec $zvec]
    
    set l [drawopengl draw -genlists 1]
    drawopengl draw -newlist $l compile
    drawopengl draw -pushmatrix -multmatrix $mat
    
    set symbols_dir [file join $::lsdynaPriv(problemtypedir) symbols]
    set file [file join $symbols_dir temp_load.msh]
    gid_groups_conds::import_gid_mesh_as_openGL $file orange orange
    drawopengl draw -popmatrix
    drawopengl draw -endlist
    return $l
}

proc lsdyna::draw_symbol_waveLoads { valuesList } {
    set xvec [m::scale -1 [_give_gravity_vec]]
    foreach "yvec zvec" [_calc_yz_beam $xvec] break
    set mat [_give_OpenGL_mat $xvec $yvec $zvec]
    
    set l [drawopengl draw -genlists 1]
    drawopengl draw -newlist $l compile
    drawopengl draw -pushmatrix -multmatrix $mat
    
    set symbols_dir [file join $::lsdynaPriv(problemtypedir) symbols]
    set file [file join $symbols_dir wave_load.msh]
    gid_groups_conds::import_gid_mesh_as_openGL $file orange orange
    drawopengl draw -popmatrix
    drawopengl draw -endlist
    return $l
}

proc lsdyna::draw_symbol_stiffShell { valuesList } {
}

proc lsdyna::draw_symbol_solid_properties { valuesList } {

    set l [drawopengl draw -genlists 1]
    drawopengl draw -newlist $l compile

    set symbols_dir [file join $::lsdynaPriv(problemtypedir) symbols]
    set file [file join $symbols_dir solid_properties.msh]
    gid_groups_conds::import_gid_mesh_as_openGL $file orange orange
    drawopengl draw -endlist
    return $l
}


proc lsdyna::draw_symbol_loads_lines { valuesList geom_mesh ov num pnts \
    points ent_type center scale } {

    foreach "p1 p2" $points break
    set vec ""
    foreach i [list X_Pressure Y_Pressure Z_Pressure] {
        set ipos [lsearch -index 0 $valuesList $i]
        lappend vec [lindex $valuesList $ipos 1]
    }
    set err [catch { m::unitLengthVector $vec } yvec]
    if { $err } { set yvec "0 0 1" }


    switch $geom_mesh GEOMETRYUSE { set gm geometry } MESHUSE { set gm mesh }
    regsub {s$} $ov {} ovL
    set ret [GiD_Info conditions -localaxesmat ${ovL}_Local_axes \
            $gm $num]
    set m [lindex $ret 0 3]
    if { $m ne "" } {
        set yvec [m::matmul [_give_LA_mat $m] $yvec]
    }
    set sec_x [expr {2*$scale}]
    set sec_y [expr {2*$scale}]

    set ipos [lsearch -index 0 $valuesList load_type]
    set load_type [lindex $valuesList $ipos 1]

    switch $load_type {
        "global" { set color [list 0 0 0] }
        "global projected" { set color  [list 0 1 0] }
        "local" { set color  [list 0 1 1] }
    }

    set delta .1
    for { set t $delta } { $t <= 1.0+.5*$delta } { set t [expr {$t+$delta}] } {
        if { $ent_type != "STLINE" && $ent_type != "ELEMENT" } {
            set p2 [GiD_Info parametric line $num coord $t]
        }
        
        set xvecT [m::sub $p2 $p1]
        set xvec_norm [m::norm $xvecT]
        set xvec [m::scale [expr {1.0/$xvec_norm}] $xvecT]
        set zvec [m::vectorprod3 $xvec $yvec]
        if { [m::norm $zvec] < 1e-10 } {
            set zvec [list 0 0 1]
        }
        set mat [_give_OpenGL_mat $xvec $yvec $zvec]

        drawopengl draw -pushmatrix -translate $p1 -multmatrix \
            $mat -scale [list $xvec_norm $sec_x $sec_y] \
            -color $color

        if { $load_type eq "global projected" } {
            drawopengl draw -rasterpos "0 0 0"
            drawopengl drawtext "Proj"
        }

        set comm "drawopengl draw -begin lines "
        for { set i 0 } { $i < 5 } { incr i } {
            set x [expr {$i/4.0}]
            append comm "-vertex {$x -1 0} -vertex {$x 0 0} "
            append comm "-vertex {[expr {$x-.025}] -.2 0} -vertex {$x 0 0} "
            append comm "-vertex {[expr {$x+.025}] -.2 0} -vertex {$x 0 0} "
        }
        append comm "-vertex {0 -1 0} -vertex {1 -1 0} "
        append comm "-end"
        eval $comm

        drawopengl draw -popmatrix
        if { $ent_type == "STLINE" || $ent_type == "ELEMENT" } { break }
        set p1 $p2
    }
}

proc lsdyna::draw_symbol_loads_surfaces { valuesList geom_mesh ov num lines \
    points ent_type center scale } {

    if { $geom_mesh eq "GEOMETRYUSE" } {
        foreach i $lines {
            foreach "line or" $i break
            set list_ent [GiD_Info list_entities Lines $line]
            regexp {^\S+} $list_ent ent_typeL
            
            regexp {Points:\s+([0-9]+)\s+([0-9]+)} $list_ent {} P1 P2
            set points ""
            foreach j "P1 P2" {
                set list_pnt [GiD_Info list_entities Points [set $j]]
                regexp {Coord:\s+([^\n]+)} $list_pnt {} coords
                lappend points $coords
            }
            draw_symbol_loads_lines $valuesList $geom_mesh lines $line "" \
                $points $ent_typeL $center $scale
        }
    } else {
        set idx 1
        foreach node $lines {
            set n($idx) [lrange [GiD_Info Mesh Nodes $node] 1 end]
            incr idx
        }
        foreach i [rangeF 1 [llength $lines]] {
            set P1 $n($i)
            if { [info exists n([expr {$i+1}])] } {
                set P2 $n([expr {$i+1}])
            } else { set P2 $n(1) }
            
            draw_symbol_loads_lines $valuesList $geom_mesh lines "" "" \
               [list $P1 $P2] ELEMENT $center $scale
        }
    }
}

proc lsdyna::draw_symbol_sections_lines { cnd_name valuesList geom_mesh ov \
    num pnts points ent_type center scale } {

    foreach "p1 p2" $points break

    set sectype ipn
    switch $cnd_name {
        Rectangular_Section {
            set sectype rectangular
            set color [list .5 0 0]
            set sec_x [eval gid_groups_conds::convert_value_to_mesh_unit \
                    [_give_value_and_unit $valuesList WidthY]]
            set sec_y [eval gid_groups_conds::convert_value_to_mesh_unit \
                    [_give_value_and_unit $valuesList WidthZ]]
        }
        Generic_section - Sections_library - naval_stiffeners {
            set color [list .2 .8 .2]
            set name [lindex [_give_value_and_unit $valuesList Name] 0]
            if { $name eq "" } {
                set name [lindex [_give_value_and_unit $valuesList steel_section_name] 0]
            }
            switch -glob -- $name {
                R-* {
                    set sectype rectangular
                    foreach "- width height" [split $name -] break
                    set err [catch {
                            set sec_x [gid_groups_conds::convert_value_to_mesh_unit \
                                    $width mm]
                            set sec_y [gid_groups_conds::convert_value_to_mesh_unit \
                                    $height mm]
                        }]
                    if { $err } {
                        set sec_x [gid_groups_conds::convert_value_to_mesh_unit \
                                200 mm]
                        set sec_y [gid_groups_conds::convert_value_to_mesh_unit \
                                200 mm]
                    }
                }
                TUBE* - O* {
                    set sectype tube
                    set r [lindex [split $name -] 1]
                    set err [catch {
                            set sec_x [gid_groups_conds::convert_value_to_mesh_unit \
                                    $r mm]
                            set sec_y [gid_groups_conds::convert_value_to_mesh_unit \
                                    $r mm]
                        }]
                    if { $err } {
                        set sec_x [gid_groups_conds::convert_value_to_mesh_unit \
                                200 mm]
                        set sec_y [gid_groups_conds::convert_value_to_mesh_unit \
                                200 mm]
                    }
                }
                default {
                    set l [lrange [split $name -] 1 end]
                    foreach "width height" [list 200 200] break
                    if { [string is double -strict [lindex $l 0]] } {
                        set height [lindex $l 0]
                        if { [string is double -strict [lindex $l 1]] } {
                            set width [lindex $l 1]
                        } else { set width $height }
                    }
                    set sec_x [gid_groups_conds::convert_value_to_mesh_unit \
                            $width mm]
                    set sec_y [gid_groups_conds::convert_value_to_mesh_unit \
                            $height mm]
                }
            }
        }
    }
    set delta .1
    for { set t $delta } { $t <= 1.0+.5*$delta } { set t [expr {$t+$delta}] } {
        if { $ent_type != "STLINE" && $ent_type != "ELEMENT" } {
            set p2 [GiD_Info parametric line $num coord $t]
        }

        set xvecT [m::sub $p2 $p1]
        set xvec_norm [m::norm $xvecT]
        set xvec [m::scale [expr {1.0/$xvec_norm}] $xvecT]

        switch $geom_mesh {
            GEOMETRYUSE { set gm geometry }
            MESHUSE { set gm mesh }
        }
        set ret [GiD_Info conditions -localaxesmat Line_Local_axes \
                $gm $num]
        set LAmat [lindex $ret 0 3]
        if { $LAmat ne "" } {
            foreach "yvec zvec" [list "" ""] break
            foreach "c1 c2 c3" $LAmat { 
                lappend yvec $c2
                lappend zvec $c3
            }
        } else {
            foreach "yvec zvec" [_calc_yz_beam $xvec] break
        }
        set mat [_give_OpenGL_mat $xvec $yvec $zvec]

        drawopengl draw -pushmatrix -translate $p1 -multmatrix \
            $mat -scale [list $xvec_norm $sec_x $sec_y] \
            -color $color

        switch $sectype {
            ipn { _draw_ipn }
            tube { _draw_tube }
            rectangular { _draw_rectangular $color "0 0 0" }
        }
        drawopengl draw -popmatrix
        if { $ent_type == "STLINE" || $ent_type == "ELEMENT" } { break }
        set p1 $p2
    }
}

proc lsdyna::_draw_symbol_sections_surfaces_lines { num or points n1 nA nB \
    ent_type } {

    foreach "p1 p2" $points break
    if { $ent_type ne "ELEMENT" } {
        set t1 [GiD_Info parametric line $num deriv_t 0.0]
        if { $or eq "DIFF1ST" } { set t1 [m::scale -1 $t1] }
        set t2 [GiD_Info parametric line $num deriv_t 1.0]
        if { $or eq "DIFF1ST" } { set t2 [m::scale -1 $t2] }
    } else {
        set t1 [m::sub $p2 $p1]
        set t2 $t1
    }
    set p1_normal [m::unitLengthVector [m::vectorprod3 $t1 $n1]]
    set p2_normal [m::unitLengthVector [m::vectorprod3 $t2 $n1]]

    set pnts [list $p1]
    set normals [list $p1_normal]
    
    set delta .1
    for { set t $delta } { $t <= 1.0+.5*$delta } { set t [expr {$t+$delta}] } {
        if { $ent_type != "STLINE" && $ent_type ne "ELEMENT" } {
            switch $or {
                SAME1ST { set tP $t }
                DIFF1ST { set tP [expr {1.0-$t}] }
            }
            set p2 [GiD_Info parametric line $num coord $tP]
            set t2 [GiD_Info parametric line $num deriv_t $tP]
            if { $or eq "DIFF1ST" } { set t2 [m::scale -1 $t2] }
            set p2_normal [m::unitLengthVector [m::vectorprod3 $t2 $n1]]
        }
        lappend pnts $p2
        lappend normals $p2_normal
        if { $ent_type == "STLINE" || $ent_type == "ELEMENT" } { break }
        set p1 $p2
        set p1_normal $p2_normal
    }
    drawopengl draw -begin quadstrip
    foreach "p_prev n_prev" [list "" ""] break
    foreach p $pnts n $normals {
        if { $p_prev ne "" } {
            drawopengl draw -normal $n_prev -vertex [m::add $p_prev $nA]
            drawopengl draw -normal $n_prev -vertex [m::add $p_prev $nB]
            drawopengl draw -normal $n -vertex [m::add $p $nA]
            drawopengl draw -normal $n -vertex [m::add $p $nB]
        }
        foreach "p_prev n_prev" [list $p $n] break
        
    }
    drawopengl draw -end
}

proc lsdyna::draw_symbol_sections_surfaces { valuesList geom_mesh ov \
    num lines points ent_type center scale } {

    if { $geom_mesh eq "GEOMETRYUSE" } {
        set list_ent [GiD_Info list_entities Surfaces $num]
        regexp {Normal:\s+(\S+)\s+(\S+)\s+(\S+)} $list_ent {} x y z
        set n1 [m::unitLengthVector "$x $y $z"]
    } else {
        set idx 1
        foreach node $lines {
            set n($idx) [lrange [GiD_Info Mesh Nodes $node] 1 end]
            incr idx
        }
        set normal [m::vectorprod3 [m::sub $n(2) $n(1)] \
                [m::sub $n(3) $n(1)]]
        set n1 [m::unitLengthVector $normal]
    }

    set err [catch { eval gid_groups_conds::convert_value_to_mesh_unit \
            [_give_value_and_unit $valuesList Thickness] } thickness]
    if { $err } {
        set thickness [gid_groups_conds::convert_value_to_mesh_unit \
                200 mm]
    }
    
    drawopengl draw -color [gid_groups_conds::_OpenGL_color brown]

    set nA [m::scale [expr {.5*$thickness}] $n1]
    set nB [m::scale [expr {-.5*$thickness}] $n1]

    switch $geom_mesh {
        "GEOMETRYUSE" { set etype surface }
        "MESHUSE" { set etype element }
    }

    drawopengl draw -pushmatrix -translate $nA
    drawopengl drawentity -mode filled $etype $num
    drawopengl draw -popmatrix

    drawopengl draw -pushmatrix -translate $nB
    drawopengl drawentity -mode filled $etype $num
    drawopengl draw -popmatrix

    if { $geom_mesh eq "GEOMETRYUSE" } {
        foreach i $lines {
            foreach "line or" $i break
            set list_ent [GiD_Info list_entities Lines $line]
            regexp {^\S+} $list_ent ent_typeL
            
            regexp {Points:\s+([0-9]+)\s+([0-9]+)} $list_ent {} P1 P2
            if { $or eq "DIFF1ST" } { foreach "P1 P2" [list $P2 $P1] break }
            set points ""
            foreach j "P1 P2" {
                set list_pnt [GiD_Info list_entities Points [set $j]]
                regexp {Coord:\s+([^\n]+)} $list_pnt {} coords
                lappend points $coords
            }
            _draw_symbol_sections_surfaces_lines $line $or $points $n1 \
                $nA $nB $ent_typeL
        }
    } else {
        foreach i [rangeF 1 [llength $lines]] {
            set P1 $n($i)
            if { [info exists n([expr {$i+1}])] } {
                set P2 $n([expr {$i+1}])
            } else { set P2 $n(1) }

            _draw_symbol_sections_surfaces_lines "" "" [list $P1 $P2] $n1 \
                $nA $nB ELEMENT
        }
    }
}

proc lsdyna::_draw_ipn {} {

    drawopengl draw -begin quads \
        -normal {0 0 1} \
        -vertex {1 1 1}     -vertex {0 1 1}     -vertex {0 -1 1}    -vertex {1 -1 1} \
        -normal {0 -1 0} \
        -vertex {1 -1 1}    -vertex {0 -1 1}    -vertex {0 -1 .9}   -vertex {1 -1 .9} \
    -normal {0 0 -1} \
        -vertex {1 -1 .9}   -vertex {0 -1 .9}   -vertex {0 -.1 .9}  -vertex {1 -.1 .9} \
    -normal {0 -1 0} \
        -vertex {1 -.1 .9}  -vertex {0 -.1 .9}  -vertex {0 -.1 -.9} -vertex {1 -.1 -.9} \
    -normal {0 0 1} \
        -vertex {1 -.1 -.9} -vertex {0 -.1 -.9} -vertex {0 -1 -.9}  -vertex {1 -1 -.9} \
    -normal {0 -1 0} \
        -vertex {1 -1 -.9}  -vertex {0 -1 -.9}  -vertex {0 -1 -1}   -vertex {1 -1 -1} \
    -normal {0 0 -1} \
        -vertex {1 -1 -1}   -vertex {0 -1 -1}   -vertex {0 1 -1}    -vertex {1 1 -1} \
    -normal {0 1 0} \
        -vertex {1 1 -1}    -vertex {0 1 -1}    -vertex {0 1 -.9}   -vertex {1 1 -.9} \
    -normal {0 0 1} \
        -vertex {1 1 -.9}   -vertex {0 1 -.9}   -vertex {0 .1 -.9}  -vertex {1 .1 -.9} \
    -normal {0 1 0} \
        -vertex {1 .1 -.9}  -vertex {0 .1 -.9}  -vertex {0 .1 .9}   -vertex {1 .1 .9} \
    -normal {0 0 -1} \
        -vertex {1 .1 .9}   -vertex {0 .1 .9}   -vertex {0 1 .9}    -vertex {1 1 .9} \
    -normal {0 1 0} \
        -vertex {1 1 .9}    -vertex {0 1 .9}    -vertex {0 1 1}     -vertex {1 1 1} \
    \
        -normal {1 0 0} \
    -vertex {0 1 1}     -vertex {0 -1 1}    -vertex {0 -1 .9}   -vertex {0 1 .9} \
        -vertex {0 .1 .9}   -vertex {0 -.1 .9}  -vertex {0 -.1 -.9} -vertex {0 .1 -.9} \
    -vertex {0 1 -1}    -vertex {0 1 -.9}   -vertex {0 -1 -.9}  -vertex {0 -1 -1} \
        \
    -normal {-1 0 0} \
        -vertex {1 1 1}     -vertex {1 1 .9}    -vertex {1 -1 .9}   -vertex {1 -1 1}  \
    -vertex {1 .1 .9}   -vertex {1 .1 -.9}  -vertex {1 -.1 -.9} -vertex {1 -.1 .9} \
        -vertex {1 1 -1}    -vertex {1 -1 -1}   -vertex {1 -1 -.9}  -vertex {1 1 -.9} \
    -end
}

proc lsdyna::_draw_rectangular { fill_color lines_color } {

    drawopengl draw -color $fill_color

    drawopengl draw -begin quads \
        -normal {1 0 0} \
        -vertex {0 1 1} -vertex  {0 -1 1} -vertex  {0 -1 -1} -vertex {0 1 -1} \
        -vertex {1 1 1} -vertex  {1 -1 1} -vertex  {1 -1 -1} -vertex {1 1 -1} \
        -normal {0 0 1} \
        -vertex {0 1 1} -vertex  {0 -1 1} -vertex  {1 -1 1} -vertex   {1 1 1} \
        -vertex {0 1 -1} -vertex {0 -1 -1} -vertex {1 -1 -1} -vertex  {1 1 -1} \
        -normal {0 -1 0} \
        -vertex {0 1 1} -vertex  {0 1 -1} -vertex  {1 1 -1} -vertex   {1 1 1} \
        -vertex {0 -1 1} -vertex {0 -1 -1} -vertex {1 -1 -1} -vertex  {1 -1 1} \
        -end


    drawopengl draw -color $lines_color

    drawopengl doscrzoffset 1

    drawopengl draw -begin lineloop \
        -vertex {0 1 1} -vertex  {0 -1 1} -vertex  {0 -1 -1} -vertex {0 1 -1} \
        -end -begin lineloop \
        -vertex {1 1 1} -vertex  {1 -1 1} -vertex  {1 -1 -1} -vertex {1 1 -1} \
        -end -begin lines \
        -vertex {0 1 1} -vertex   {1 1 1} \
        -vertex {0 1 -1}  -vertex  {1 1 -1} \
        -vertex {0 -1 1} -vertex   {1 -1 1} \
        -vertex {0 -1 -1} -vertex  {1 -1 -1} \
        -end
    drawopengl doscrzoffset 0
}

proc lsdyna::_draw_tube {} {
    
    set comm "drawopengl draw "
    set n 8
    set pi [expr {atan2(0,-1)}]
    
    append comm "-begin quads "
    for { set i 0 } { $i < $n }  { incr i } {
        set angle1 [expr {$i*$pi*2.0/$n}]
        set angle2 [expr {($i+1)*$pi*2.0/$n}]
        set angle_m [expr {.5*($angle1+$angle2)}]
        append comm "-normal {0 [format %.3g [expr {-1*cos($angle_m)}]] \
           [format %.3g [expr {-1*sin($angle_m)}]]} "
        set y1 [format %.3g [expr {.5*cos($angle1)}]]
        set y2 [format %.3g [expr {.5*cos($angle2)}]]
        set z1 [format %.3g [expr {.5*sin($angle1)}]]
        set z2 [format %.3g [expr {.5*sin($angle2)}]]
        append comm "-normal {0 [format %.3g [expr {-1*cos($angle1)}]] \
           [format %.3g [expr {-1*sin($angle1)}]]} "
        append comm "-vertex {0 $y1 $z1} -vertex {1 $y1 $z1} "
        append comm "-normal {0 [format %.3g [expr {-1*cos($angle2)}]] \
           [format %.3g [expr {-1*sin($angle2)}]]} "
        append comm "-vertex {1 $y2 $z2} -vertex {0 $y2 $z2} "
    }
    append comm "-end -begin triangles "
    for { set i 0 } { $i < $n }  { incr i } {
        set angle1 [expr {$i*$pi*2.0/$n}]
        set angle2 [expr {($i+1)*$pi*2.0/$n}]
        set angle_m [expr {.5*($angle1+$angle2)}]
        append comm "-normal {1 0 0} "
        set y1 [format %.3g [expr {.5*cos($angle1)}]]
        set y2 [format %.3g [expr {.5*cos($angle2)}]]
        set z1 [format %.3g [expr {.5*sin($angle1)}]]
        set z2 [format %.3g [expr {.5*sin($angle2)}]]
        append comm "-vertex {0 0 0} -vertex {0 $y1 $z1} -vertex {0 $y2 $z2} "
        append comm "-normal {-1 0 0} "
        append comm "-vertex {1 0 0} -vertex {1 $y2 $z2} -vertex {1 $y1 $z1} "
    }
    append comm "-end"
    eval $comm
}


