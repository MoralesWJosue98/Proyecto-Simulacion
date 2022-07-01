namespace eval ComplexExample {
    variable _dir
    variable _lista_ogl
    variable _id_func_ogl
    variable _has_deletelists_bug
    variable _images
    variable _pnt_text
    variable _text
    variable _lst_coords

    proc GetImage { nombre} {
	variable _dir
	variable _images
	if { ![ info exist _images($nombre)]} {
	    set _images($nombre) [ image create photo -file \
					 [file join $_dir imagenes $nombre]]
	} 
    }

    proc delete_ogl_lists_and_registration { } {
	variable _lista_ogl
	variable _id_func_ogl
	variable _has_deletelists_bug
	variable _images
	variable _pnt_text
	variable _text
	variable _lst_coords
	
	# Unregister GiD event related to Zoom Frame
	if { [info procs ::GiD_Event_GetBoundingBox] != "" } {
	    rename ::GiD_Event_GetBoundingBox ""
	}
	foreach t "nodes elements" {
	    if { $_lista_ogl($t,id) >= 0} {
		if { $_has_deletelists_bug} {
		    GiD_OpenGL draw -deletelists "$_lista_ogl($t,id) 1"
		} else {
		    GiD_OpenGL draw -deletelists $_lista_ogl($t,id) 1
		}
	    }
	    set _lista_ogl($t,id) -1
	}
	set _pnt_text [ list 0 0 0]
	set _text "Nothing read"

	if { $_id_func_ogl != -1} {
	    GiD_OpenGL unregister $_id_func_ogl
	}
	set _id_func_ogl -1
	
	foreach { idx_array img_id} [ array get _images] {
	    image delete $img_id
	}
	set _lst_coords {}
    }

    proc Ini { dir} {
	variable _dir
	variable _lista_ogl
	variable _id_func_ogl
	variable _has_deletelists_bug

	set _dir $dir
	set colores [ list "0.0 0.66666667 0.0" "0.69841 0.190464 0.69841"]
	foreach t "nodes elements" c $colores {
	    set _lista_ogl($t,id) -1
	    set _lista_ogl($t,color) $c
	}
	set _id_func_ogl -1

	set VersionRequired "7.5.2b" 
	set comp -1
	catch { 
	    set comp [ GiDVersionCmp $VersionRequired]
	}
	set _has_deletelists_bug 0
	if { $comp < 0 } {
	    set _has_deletelists_bug 1
	}
    }

    proc End { } {
	delete_ogl_lists_and_registration
    }

    proc WaitState { } {
	::GidUtils::WaitState .gid
    }
    
    proc EndWaitState { } {
	::GidUtils::EndWaitState .gid
    }

    proc DrawList { } {
	variable _lista_ogl
	variable _pnt_text
	variable _lst_coords
	variable _text

	foreach t "nodes elements" {
	    if { $_lista_ogl($t,id) >= 0} {
		GiD_OpenGL draw -color $_lista_ogl($t,color)
		GiD_OpenGL draw -calllist $_lista_ogl($t,id)
	    }
	}

	# example of printing a text
	GiD_OpenGL pgffont pushfont legendfont
	# GiD_OpenGL pgffont pushfont pmfont
	GiD_OpenGL pgffont foreground 0.0 0.0 0.0 1.0
	GiD_OpenGL draw -rasterpos $_pnt_text
	GiD_OpenGL pgffont print "$_text"
	GiD_OpenGL pgffont popfont

	GiD_OpenGL pgffont pushfont labelfont
	GiD_OpenGL pgffont foreground 0.6 0.3 0.0 1.0
	foreach n $_lst_coords {
	    GiD_OpenGL draw -rasterpos $n
	    GiD_OpenGL pgffont print "( $n)"
	}
	GiD_OpenGL pgffont popfont
    }

    proc ChangeColor { que} {
	variable _lista_ogl
	
	if { ( $que != "nodes") && ( $que != "elements")} {
	    return
	}

	set r [ expr int( 0.5 + 255.0 * [ lindex $_lista_ogl($que,color) 0])]
	set g [ expr int( 0.5 + 255.0 * [ lindex $_lista_ogl($que,color) 1])]
	set b [ expr int( 0.5 + 255.0 * [ lindex $_lista_ogl($que,color) 2])]
	set color_viejo [ format "#%02x%02x%02x" $r $g $b]
	::GidUtils::ChangeWidgetColor "" color_viejo
	set n [ scan $color_viejo "#%2x%2x%2x" r g b]
	if { $n == 3} {
	    set r [ expr double( $r) / 255.0]
	    set g [ expr double( $g) / 255.0]
	    set b [ expr double( $b) / 255.0]
	    set _lista_ogl($que,color) [ list $r $g $b]
	}
	.gid.central.s render
    }

    proc ReadMeshAndCreateOpenGLObject { } {
	variable _lista_ogl
	variable _id_func_ogl
	variable _has_deletelists_bug
	variable _lst_coords
	variable _pnt_text
	variable _text
	set types [list \
		       [list [_ "GiD ASCII mesh"] ".msh"] \
		       [list [_ "All files"] "*"] \
		      ]
	set fname [ Browser-ramR postfile read .gid [_ "Import mesh"] "" $types "" 0 {}]

	if { $fname ne ""} {
	    WaitState
	    set n_char [ file size $fname]
	    set i_char 0
	    set i_bar 0
	    set fi [ open $fname]
	    set lst_idx_points {}
	    set lst_element_types {}
	    set MESH(type) ""
	    set n_elems 0
	    set max_x -1e38
	    set max_y -1e38
	    set max_z -1e38
	    set min_x 1e38
	    set min_y 1e38
	    set min_z 1e38
	    AdvanceBar $i_char $n_char $i_char [= "Tcl OpenGL example"] [= "reading $fname"]
	    while { [ set len [ gets $fi linea]] >= 0} {
		incr i_char $len
		incr i_char
		incr i_bar
		if { $i_bar == 10000} {
		    AdvanceBar $i_char $n_char [ expr int( 100.0 * $i_char / $n_char)]
		    set i_bar 0
		}
		if { [ regexp -nocase {^ *MESH .*dimension *=? *[2,3] *Elemtype *=? *([^ ]*) *nnode *=? *([0-9]+)} $linea dum type_elem n_nodes]} {
		    set lst_elem [ string tolower "Point Line Triangle Quadrilateral Tetrahedra Hexahedra Prism"]
		    set type_elem [ string tolower $type_elem]
		    set lst_nnodes {{1} {2 3} {3 6} {4 8 9} {4 10} {8 20 27} {6 15}}
		    set idx [ lsearch $lst_elem $type_elem]
		    if { ( $idx != -1) && ( [ lsearch [ lindex $lst_nnodes $idx] $n_nodes] != -1)} {
			set MESH(type) [ list $type_elem $n_nodes]
			lappend lst_element_types $MESH(type)
			if { ![ info exist MESH($MESH(type))]} {
			    set MESH($MESH(type)) {}
			}
		    }
		} elseif { [ regexp -nocase {^ *coordinates.*} $linea]} {
		    while { ( [ set len [ gets $fi linea]] >= 0) && ![regexp -nocase {^ *end *coordinates.*} $linea]} {
			incr i_char $len
			incr i_char
			incr i_bar
			if { $i_bar == 10000} {
			    AdvanceBar $i_char $n_char [ expr int( 100.0 * $i_char / $n_char)]
			    set i_bar 0
			}
			if { [ regexp {^ *\#.*} $linea] } {
			    continue
			}
			if { [ llength $linea] == 4} {
			    set idx [ lindex $linea 0]
			    lappend lst_idx_points $idx
			    set points($idx) "[ lindex $linea 1] [ lindex $linea 2] [ lindex $linea 3]"
			    set x [ lindex $linea 1]
			    set y [ lindex $linea 2]
			    set z [ lindex $linea 3]
			    if { $x < $min_x} { set min_x $x}
			    if { $x > $max_x} { set max_x $x}
			    if { $y < $min_y} { set min_y $y}
			    if { $y > $max_y} { set max_y $y}
			    if { $z < $min_z} { set min_z $z}
			    if { $z > $max_z} { set max_z $z}
			}
		    }
		    if { $len >= 0} {
			incr i_char $len
			incr i_char
			incr i_bar
			if { $i_bar == 10000} {
			    AdvanceBar $i_char $n_char [ expr int( 100.0 * $i_char / $n_char)]
			    set i_bar 0
			}
		    }
		    # break
		    # no break, may be there are more coordinates in another MESH block
		} elseif { [ regexp -nocase {^ *elements.*} $linea]} {
		    if { $MESH(type) == ""} {
			continue
		    }
		    set nnodes [ lindex $MESH(type) 1]
		    set n_fields_1 [ expr $nnodes + 1]
		    set n_fields_2 [ expr $nnodes + 2]
		    while { ( [ gets $fi linea] >= 0) && ![regexp -nocase {^ *end *elements.*} $linea]} {
			incr i_char $len
			incr i_char
			incr i_bar
			if { $i_bar == 10000} {
			    AdvanceBar $i_char $n_char [ expr int( 100.0 * $i_char / $n_char)]
			    set i_bar 0
			}
			if { [ regexp {^ *\#.*} $linea] } {
			    continue
			}
			set nc [ llength $linea] 
			if { ( $nc == $n_fields_1) || ( $nc == $n_fields_2) } {
			    lappend MESH($MESH(type)) [ lrange $linea 1 $nnodes]
			    incr n_elems
			}
		    }
		    if { $len >= 0} {
			incr i_char $len
			incr i_char
			incr i_bar
			if { $i_bar == 10000} {
			    AdvanceBar $i_char $n_char [ expr int( 100.0 * $i_char / $n_char)]
			    set i_bar 0
			}
		    }
		}
	    }
	    close $fi
	    AdvanceBar $n_char $n_char 100
	    set n [ llength $lst_idx_points]
	    WarnWin "Read $n points and $n_elems elements."

	    set _list_ogl -1
	    if { $n > 1} {
		# first we delete the list if it exists, and the function
		delete_ogl_lists_and_registration

		# ask opengl for an id for the new list
		foreach t "nodes elements" {
		    set _lista_ogl($t,id) [ GiD_OpenGL draw -genlists 1]
		}

		# let's create the list for the nodes
		GiD_OpenGL draw -newlist $_lista_ogl(nodes,id) compile
	    
		# first we draw the nodes with some thickness
		GiD_OpenGL draw -pointsize 3.0
		GiD_OpenGL draw -begin points 
		for { set i 0} { $i < $n} { incr i} {
		    set idx [ lindex $lst_idx_points $i]
		    GiD_OpenGL draw -vertex $points($idx)
		    lappend _lst_coords $points($idx)
		}
		GiD_OpenGL draw -end
		GiD_OpenGL draw -pointsize 1.0
		# end of list
		GiD_OpenGL draw -endlist

		# let's create the list for the elements
		GiD_OpenGL draw -newlist $_lista_ogl(elements,id) compile

		foreach mesh_type $lst_element_types {
		    # "Point Line Triangle Quadrilateral Tetrahedra Hexahedra Prism"
		    set type [ lindex $mesh_type 0]
		    set nnodes [ lindex $mesh_type 1] 
		    if { $type == "point"} {
			continue
		    } else {
			GiD_OpenGL draw -begin lines 
			if { ( $type == "linear") || ( $type == "line") } {
			    if { $nnodes == 2} {
				foreach elem $MESH($mesh_type) {
				    foreach idx $elem {
					GiD_OpenGL draw -vertex $points($idx)
				    }
				}
			    } else {
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n2)
				}
			    }

			} elseif { $type == "triangle" } {
			    if { $nnodes == 3} {
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n1)
				}
			    } else { # 6 nodes
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    set n5 [ lindex $elem 4]
				    set n6 [ lindex $elem 5]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n1)
				}
			    }

			} elseif { $type == "quadrilateral" } {
			    if { $nnodes == 4} {
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n1)
				}
			    } else { # 8 or 9 nodes
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    set n5 [ lindex $elem 4]
				    set n6 [ lindex $elem 5]
				    set n7 [ lindex $elem 6]
				    set n8 [ lindex $elem 7]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n1)
				}
			    }

			} elseif { $type == "tetrahedra" } {
			    if { $nnodes == 4} {
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n3)
				}
			    } else { # 10 nodes
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    set n5 [ lindex $elem 4]
				    set n6 [ lindex $elem 5]
				    set n7 [ lindex $elem 6]
				    set n8 [ lindex $elem 7]
				    set n9 [ lindex $elem 8]
				    set n10 [ lindex $elem 9]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n9)
				    GiD_OpenGL draw -vertex $points($n9)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n10)
				    GiD_OpenGL draw -vertex $points($n10)
				    GiD_OpenGL draw -vertex $points($n3)
				}
			    }

			} elseif { $type == "hexahedra" } {
			    if { $nnodes == 8} {
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    set n5 [ lindex $elem 4]
				    set n6 [ lindex $elem 5]
				    set n7 [ lindex $elem 6]
				    set n8 [ lindex $elem 7]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n8)
				}
			    } else { # 20 or 27 nodes
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    set n5 [ lindex $elem 4]
				    set n6 [ lindex $elem 5]
				    set n7 [ lindex $elem 6]
				    set n8 [ lindex $elem 7]
				    set n9 [ lindex $elem 8]
				    set n10 [ lindex $elem 9]
				    set n11 [ lindex $elem 10]
				    set n12 [ lindex $elem 11]
				    set n13 [ lindex $elem 12]
				    set n14 [ lindex $elem 13]
				    set n15 [ lindex $elem 14]
				    set n16 [ lindex $elem 15]
				    set n17 [ lindex $elem 16]
				    set n18 [ lindex $elem 17]
				    set n19 [ lindex $elem 18]
				    set n20 [ lindex $elem 19]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n9)
				    GiD_OpenGL draw -vertex $points($n9)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n10)
				    GiD_OpenGL draw -vertex $points($n10)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n11)
				    GiD_OpenGL draw -vertex $points($n11)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n12)
				    GiD_OpenGL draw -vertex $points($n12)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n17)
				    GiD_OpenGL draw -vertex $points($n17)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n18)
				    GiD_OpenGL draw -vertex $points($n18)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n19)
				    GiD_OpenGL draw -vertex $points($n19)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n20)
				    GiD_OpenGL draw -vertex $points($n20)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n13)
				    GiD_OpenGL draw -vertex $points($n13)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n14)
				    GiD_OpenGL draw -vertex $points($n14)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n15)
				    GiD_OpenGL draw -vertex $points($n15)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n16)
				    GiD_OpenGL draw -vertex $points($n16)
				    GiD_OpenGL draw -vertex $points($n8)
				}
			    }

			} elseif { ( $type == "prisma") || ( $type == "prism") } {
			    if { $nnodes == 6} {
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    set n5 [ lindex $elem 4]
				    set n6 [ lindex $elem 5]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n6)
				}
			    } else { # 15 nodes
				foreach elem $MESH($mesh_type) {
				    set n1 [ lindex $elem 0]
				    set n2 [ lindex $elem 1]
				    set n3 [ lindex $elem 2]
				    set n4 [ lindex $elem 3]
				    set n5 [ lindex $elem 4]
				    set n6 [ lindex $elem 5]
				    set n7 [ lindex $elem 6]
				    set n8 [ lindex $elem 7]
				    set n9 [ lindex $elem 8]
				    set n10 [ lindex $elem 9]
				    set n11 [ lindex $elem 10]
				    set n12 [ lindex $elem 11]
				    set n13 [ lindex $elem 12]
				    set n14 [ lindex $elem 13]
				    set n15 [ lindex $elem 14]
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n7)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n8)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n9)
				    GiD_OpenGL draw -vertex $points($n9)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n13)
				    GiD_OpenGL draw -vertex $points($n13)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n14)
				    GiD_OpenGL draw -vertex $points($n14)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n6)
				    GiD_OpenGL draw -vertex $points($n15)
				    GiD_OpenGL draw -vertex $points($n15)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n1)
				    GiD_OpenGL draw -vertex $points($n10)
				    GiD_OpenGL draw -vertex $points($n10)
				    GiD_OpenGL draw -vertex $points($n4)
				    GiD_OpenGL draw -vertex $points($n2)
				    GiD_OpenGL draw -vertex $points($n11)
				    GiD_OpenGL draw -vertex $points($n11)
				    GiD_OpenGL draw -vertex $points($n5)
				    GiD_OpenGL draw -vertex $points($n3)
				    GiD_OpenGL draw -vertex $points($n12)
				    GiD_OpenGL draw -vertex $points($n12)
				    GiD_OpenGL draw -vertex $points($n6)
				}
			    }
			} else {
			    WarnWinText "Unknow element type: $type with $nnodes nodes"
			}
			GiD_OpenGL draw -end
		    }
		}

		# end of elements list
		GiD_OpenGL draw -endlist

		# mini legend
		set _pnt_text [ list $min_x [ expr $min_y - 10.0] $min_z]
		set _text $fname

		# define bounding box of what we've read so that GiD's zoom frame takes it into account
		set bounding_box [ list $min_x $min_y $min_z $max_x $max_y $max_z]
		# view_mode is one of {"GEOMETRYUSE" "MESHUSE" "POSTUSE" "GRAPHUSE} but here it's unused
		proc ::GiD_Event_GetBoundingBox { view_mode} [ list return $bounding_box]

		set _id_func_ogl [ GiD_OpenGL register ::ComplexExample::DrawList]
		
		unset lst_idx_points
		unset lst_element_types
		unset MESH
		unset points
	    }
	    EndWaitState
	    # Zoom frame on what we've read and draw it
	    GiD_Process 'Zoom Frame
	}
    }
}

proc MyWarnWin { msg } {
    tk_messageBox -message "$msg" -icon warning -type ok
}

proc MyNewBarShowHelp { } {
    MyWarnWin "help [ lindex [GiD_Info Project] 4]"
}

proc MyTestWindowDoIt { w} {
    global MtwPriv
    
    set cmd_line "GiD_Result get "
    if { ![ string eq ::MtwPriv(suboption) ""]} {
	append cmd_line "$::MtwPriv(suboption) "
    }

    append cmd_line [ list [ list $::MtwPriv(result) $::MtwPriv(analysis) $::MtwPriv(step)]]
    set res [ tk_messageBox -parent $w -message "Execute '$cmd_line'?" -type yesno]
    if { [ string eq $res yes]} {
	switch "$::MtwPriv(output)" {
	    "WarnWin" {
		WarnWin [ eval $cmd_line] $w
	    }
	    "WarnWinText" {
		WarnWinText [ eval $cmd_line]
	    }
	    "File" {
		if { ![ info exist ::MtwPriv(outputfile)] || [ string eq $::MtwPriv(outputfile) ""]} {
		    MyTestWindowGetFile
		}
		if { [ info exist ::MtwPriv(outputfile)] && ![ string eq $::MtwPriv(outputfile) ""]} {
		    set fo [ open $::MtwPriv(outputfile) w]
		    puts $fo [ eval $cmd_line]
		    close $fo
		}
	    }
	}
    }
}

proc MyTestWindowGetFile { w} {
    set types {
	{ {Text files} {.txt}}
	{ {All files} {*}}
    }
    set res [ tk_getSaveFile -parent $w -title "Save output to..." -defaultextension ".txt" -filetypes $types]
    if { ![ string eq $res ""]} {
	set ::MtwPriv(outputfile) $res
    }
}

proc MyTestWindowViewFile { } {
    if { [ file exists $::MtwPriv(outputfile)]} {
	set ::MtwPriv(ViewID) [ gidproc exec "c:/emacs-21.3/bin/runemacs.exe" "$::MtwPriv(outputfile)"]
    }
}

proc MyTestWindowClose { w} {
    if { [ info exist ::MtwPriv(ViewID)]} {
	gidproc kill $::MtwPriv(ViewID)
    }
    destroy $w
}

proc MyTextWindowProc { { w .gid.mtw}} {
    global MtwPriv

    toplevel $w 
    wm title $w "My test window"
    set def_back [ $w cget -background]

    set f [ frame $w.top -bd 0]
    #-relief flat
    label $f.l -text "Test window" -font BigFont


    set ft [ frame $f.ftest -bd 2 -relief ridge]
    label $ft.l1 -text "Result:"
    entry $ft.e1 -width 16 -textvariable ::MtwPriv(result)
    label $ft.l2 -text "Analysis:"
    entry $ft.e2 -width 16 -textvariable ::MtwPriv(analysis)
    label $ft.l3 -text "Step:"
    entry $ft.e3 -width 16 -textvariable ::MtwPriv(step)
    grid $ft.l1 $ft.e1 -sticky ew
    grid $ft.l2 $ft.e2 -sticky ew
    grid $ft.l3 $ft.e3 -sticky ew
    grid columnconfigure $ft 1 -weight 1
    grid rowconfigure $ft 0 -weight 1
    grid rowconfigure $ft 1 -weight 1
    grid rowconfigure $ft 2 -weight 1
    
    set ft2 [ frame $f.ftest2 -bd 2 -relief ridge]
    radiobutton $ft2.r1 -text "All info" -value "" -variable ::MtwPriv(suboption)
    radiobutton $ft2.r2 -text "Comp Max" -value "-compmax" -variable ::MtwPriv(suboption)
    radiobutton $ft2.r3 -text "Comp Min" -value "-compmin" -variable ::MtwPriv(suboption)
    radiobutton $ft2.r4 -text "Maximum" -value "-max" -variable ::MtwPriv(suboption)
    radiobutton $ft2.r5 -text "Minimum" -value "-min" -variable ::MtwPriv(suboption)
    set ::MtwPriv(suboption) ""

    grid $ft2.r1 -sticky ewns
    grid $ft2.r2 -sticky ewns
    grid $ft2.r3 -sticky ewns
    grid $ft2.r4 -sticky ewns
    grid $ft2.r5 -sticky ewns
    grid columnconfigure $ft2 0 -weight 1
    grid rowconfigure $ft2 0 -weight 1
    grid rowconfigure $ft2 1 -weight 1
    grid rowconfigure $ft2 2 -weight 1
    grid rowconfigure $ft2 3 -weight 1
    grid rowconfigure $ft2 4 -weight 1

    set ft3 [ frame $f.ftest3 -bd 2 -relief ridge]
    label $ft3.l -text Output:
    radiobutton $ft3.r1 -text "WarnWin" -value "WarnWin" -variable ::MtwPriv(output)
    radiobutton $ft3.r2 -text "WarnWinText" -value "WarnWinText" -variable ::MtwPriv(output)
    radiobutton $ft3.r3 -text "To File:" -value "File" -variable ::MtwPriv(output)
    set ::MtwPriv(output) "WarnWinText"
    set ft3f [ frame $ft3.ff -bd 0]
    entry $ft3f.e -width 16 -textvariable ::MtwPriv(outputfile)
    button $ft3f.b1 -image [ ::ComplexExample::GetImage "new.gif"] -command "MyTestWindowGetFile $w"
    button $ft3f.b2 -image [ ::ComplexExample::GetImage "view.gif"] -command MyTestWindowViewFile
    grid $ft3f.e -sticky ew
    grid $ft3f.b1 -row 0 -column 1 -sticky e
    grid $ft3f.b2 -row 0 -column 2 -sticky e
    grid rowconfigure $ft3f 0 -weight 1
    grid columnconfigure $ft3f 0 -weight 1
    grid columnconfigure $ft3f 1 -weight 1
    grid columnconfigure $ft3f 2 -weight 1

    grid $ft3.r1 $ft3.r2 -sticky w
    grid $ft3.r3 -row 1 -column 0 -sticky w
    grid $ft3.ff -row 1 -column 1 -sticky we
    grid columnconfigure $ft3 1 -weight 1
    grid rowconfigure $ft3 0 -weight 1
    grid rowconfigure $ft3 1 -weight 1

    grid $f.l -sticky new -padx 5 -pady 6
    grid $f.ftest -sticky news
    grid $f.ftest2 -sticky news
    grid $f.ftest3 -sticky news
    grid columnconfigure $f 0 -weight 1
    grid rowconfigure $f 1 -weight 1
    grid rowconfigure $f 2 -weight 1
    grid rowconfigure $f 3 -weight 1
    
    frame $w.but -bd 0 -background [ CCColorActivo $def_back] 
    #-relief flat
    
    button $w.but.doit -text "Do it" -command "MyTestWindowDoIt $w"
    button $w.but.close -text "Close" -command "MyTestWindowClose $w"
    grid $w.but.doit $w.but.close -sticky ews -padx 5 -pady 6
    
    grid $w.top -sticky news
    grid $w.but -sticky ews
	
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 0 -weight 1
}

proc MyColorSubMenu { w} {
    $w delete 0 end
    $w add command -label "Colour nodes" -command "::ComplexExample::ChangeColor nodes"
    $w add command -label "Colour elements" -command "::ComplexExample::ChangeColor elements"
}

proc MyNewBarProc { { what DEFAULT} { img_dir ""}} {
    global MyNewBarBitmapsNames MyNewBarBitmapsCommands MyNewBarBitmapsHelp
    global MyNewBarImgDir

    set MyNewBarBitmapsNames(0) "new.gif open2.gif save.gif --- color.gif win_vacia24.png --- help.gif"
    
    set MyNewBarBitmapsCommands(0) [ list {-np- MyWarnWin new} {-np- ::ComplexExample::ReadMeshAndCreateOpenGLObject} \
					 {-np- MyWarnWin save} ""  \
					 {-np- MyColorSubMenu %W} {-np- MyTextWindowProc } "" \
					 {-np- MyNewBarShowHelp} ]
    set MyNewBarBitmapsHelp(0) [ list "New" "Read and draw ASCII mesh" \
				     "Save" "" \
				     "Change color of nodes or elements" "Window example" "" \
				     "Help status"]

    set MyNewBarBitmapsNames(0,4) {}
    set MyNewBarBitmapsCommands(0,4) {}
    set MyNewBarBitmapsHelp(0,4) {}
    
    CreateOtherBitmaps MyNewBar "Z My new Bar" MyNewBarBitmapsNames MyNewBarBitmapsCommands \
	MyNewBarBitmapsHelp "$::MyNewBarImgDir" MyNewBarBitmaps $what PrePost

    AddNewToolbar "Z My new bar" PrePostMyNewBarWindowGeom MyNewBarProc "My new bar title"
}

proc modifyGiDmenus { } {

    GiDMenu::Create "Complex example" "PREPOST"
    GiDMenu::InsertOption "Complex example" {"Read ASCII mesh"} 0 "PREPOST" "::ComplexExample::ReadMeshAndCreateOpenGLObject"
    GiDMenu::InsertOption "Complex example" {"Colour nodes"} 1 "PREPOST" "::ComplexExample::ChangeColor nodes"
    GiDMenu::InsertOption "Complex example" {"Colour elements"} 2 "PREPOST" "::ComplexExample::ChangeColor elements"
    GiDMenu::InsertOption "Complex example" {"Test window"} 3 "POST" "MyTextWindowProc"
    # with GiD 14/15 debug mode it triggers an exception without this after
    after 1000 GiDMenu::UpdateMenus
}

proc GiD_Event_InitProblemtype { dir} {
    global MyNewBarImgDir

    set MyNewBarImgDir [ file join $dir imagenes]
    ::ComplexExample::Ini $dir

    # modify menus
    modifyGiDmenus

    # Create a new toolbar
    MyNewBarProc
}

proc GiD_Event_EndProblemtype { } {
    ::ComplexExample::End
}
