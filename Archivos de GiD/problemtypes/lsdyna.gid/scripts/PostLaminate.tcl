# NOTE: Library is only loaded when needed. Additionally, it is stored now
# in new directory exec at the same level of rambshell.gid
#load [file join $ProblemTypePriv(problemtypedir) Laminate[info shared]]


namespace eval RamSeriesLaminateResults {
    variable sentmaterials ""
    variable doc
    variable LastLam 0
}

proc RamSeriesLaminateResults::_WriteHeader { fout resname anal step res_type ngauss \
		                                  ComponentNames } {


    foreach "name elemtype ngauss_in" [list Triangles Triangle 3 Triangles1 Triangle 1 \
		                           Quadrilaterals Quadrilateral 4 \
		                           Quadrilaterals1 Quadrilateral 1] {
	if { $ngauss == $ngauss_in } {
	    puts $fout "GaussPoints \"$name\" ElemType $elemtype"
	    puts $fout "Number Of Gauss Points: $ngauss"
	    puts $fout "Natural Coordinates: internal"
	    puts $fout "end gausspoints"
	    break
	}
    }
    puts $fout "Result \"$resname\" \"$anal\" $step $res_type OnGaussPoints \"$name\""
    puts $fout "ComponentNames $ComponentNames"
    puts $fout "Values"
}

proc RamSeriesLaminateResults::LoadResultforLayer { type layer } {
    variable sentmaterials
    variable doc
    variable LastLam

    
    set doc $gid_groups_conds::doc
    set root [$doc documentElement]



    set file [file join [lsdyna::RamTempDir] tmp.res]
    set fout [open $file w]
    puts $fout "GiD Post Results File 1.0"

    if {$LastLam == 1} {
	set layer "Last"
    }
    
    switch $type {
	FS {
	    set resname "Laminate Security factor $layer"
	    set res_type Scalar
	    set ComponentNames "\"Security factor\""
	}
	stresses {
	    set resname "Laminate layer stresses $layer"
	    set res_type Vector
	    set ComponentNames "\"S11\",\"S22\",\"T12\""
	}
	strains {
	    set resname "Laminate layer strains $layer"
	    set res_type Vector
	    set ComponentNames "\"Eps11\",\"Eps22\",\"Eps12\""
	}
	default {
	    error "error in RamSeriesLaminateResults::LoadResultforLayer"
	}
    }

    set cur_anal [.central.s info post get cur_analisis]
    set cur_step [.central.s info post get cur_step]


    set isinit 0
    
    set xp {container[@n='Properties']/container[@n='Shells']/condition[@n='Laminate_shell']/group}
    
    foreach gNode [$root selectNodes $xp] {
	set formats ""
	set elmList ""
	
	dict set formats [$gNode @n] "%d\n"
	set lamProps [$gNode selectNodes {string(value[@n='laminate_properties']/@v)}] 
		
	set elmList [GiD_WriteCalculationFile elements -return $formats]
	set elmList [split $elmList \n] 
	set elmListaux ""
	
	foreach num $elmList { 
	    if {$num != ""} {
		lappend elmListaux $num
	    }
	}        
	set elmList $elmListaux
	
	foreach elm $elmList {
#             set matname "laminate"
	    set matname [lindex $formats 0]
	    
	    if { [lsearch $sentmaterials $matname] == -1 } {
		laminate_material $matname $lamProps
		lappend sentmaterials $matname
	    }

	    if {$LastLam == 1} {
		set layer [last_layer $matname]
	    }
	    
	    set momentus [GiD_Info list_entities results $cur_anal $cur_step Momentus $elm]
	    set axial_force [GiD_Info list_entities results $cur_anal $cur_step Axial_Force $elm]
	    if {$type == "FS"} {
		set ngauss 1
	    } elseif {$type == "stresses" || $type == "strains" } {
		set ngauss [llength $momentus]
	    }
	    if { !$isinit } {
		_WriteHeader $fout $resname $cur_anal $cur_step $res_type $ngauss $ComponentNames
		set isinit 1
	    }
	    set elem_init 0
	    for { set igauss 0 } { $igauss < $ngauss } { incr igauss } {
		set global_strengths [lrange [lindex $axial_force $igauss] 0 2]
		eval lappend global_strengths [lrange [lindex $momentus $igauss] 0 2]
		# WARNING: one laminate out of range now raises and error. It should permmit
		# some out of range
		set result [laminate_results $type $matname $layer $global_strengths]
		if {$result != "" } {
		    if {!$elem_init} {
		        puts -nonewline $fout "$elm "
		        set elem_init 1
		    }
		    puts $fout $result
		}
	    }
	}
    }
    
    if { $isinit } { puts $fout "End Values" }
    close $fout
    
    # to recreate the Results menu
    catch { unset ::BarresPriv(problemtype) }

    .central.s process escape escape escape escape Files Add $file
    lsdyna::DisplayContourFill [string map [list " " _] $resname] \
	[string map [list " " _] [string trim [lindex [split $ComponentNames ,] 0] \"]]
}

proc RamSeriesLaminateResults::LoadNewResult {} {
    variable LastLam

    load [file join $::lsdynaPriv(problemtypedir) exec Laminate[info shared]]

    if { ![info exists ::RamSeriesLaminateResults::NewResultLayer] } {
	set ::RamSeriesLaminateResults::NewResultLayer 1
    }
    if { ![info exists ::RamSeriesLaminateResults::NewResult] } {
	set ::RamSeriesLaminateResults::NewResult [= "Layer Stresses"]
    }

    set w .gid.loadnewresult
    InitWindow $w [= "More laminate results"] PostMoreLaminateResultsWindowGeom "" "" 1
    wm withdraw $w
    label $w.l1 -text [= "Result:"] -grid "0 py5"
    ComboBox $w.cb1 -textvariable RamSeriesLaminateResults::NewResult -values \
	[list [= "Security coef."] [= "Layer Stresses"] [= "Layer Strains"]] \
	-editable 0 -grid "1 px3" -width 30
    label $w.l2 -text [= "Layer:"] -grid "0 py5"
    SpinBox $w.sp -textvariable RamSeriesLaminateResults::NewResultLayer \
	-width 3 -range "1 1000 1" -grid "1 w px3" -state normal

    checkbutton $w.chkLast -variable RamSeriesLaminateResults::LastLam \
	    -takefocus 0 -text [= "Last Layer"] -grid "2 w px3"
    RamSeriesLaminateResults::LastLamCom $w.sp
    set command "RamSeriesLaminateResults::LastLamCom $w.sp  ;#"
    trace variable RamSeriesLaminateResults::LastLam w $command
    bind $w.chkLast <Destroy> [list trace vdelete RamSeriesLaminateResults::LastLam w $command]

    frame $w.buts -bg [CCColorActivo [$w cget -bg]] -grid "0 2 ew"

    button $w.buts.b1 -text [= OK] -und 0 -width 8 -grid "0 px3 e" \
	-command "set RamSeriesLaminateResults::data(action) ok"
    button $w.buts.b2 -text [= Cancel] -und 0 -width 8 -grid "1 px3 py3 w" -command \
	"set RamSeriesLaminateResults::data(action) cancel"

    update idletasks ;# I do not know why, but necessary
    supergrid::go $w
    grid columnconf $w.buts "0 1" -weight 1
    grid columnconf $w.buts "2 3 4" -weight 0

    update idletasks
    wm deiconify $w
    bind $w <Escape> "tkButtonInvoke $w.buts.b2"
    bind $w.buts.b2 <Return> "tkButtonInvoke $w.buts.b2"
    bind $w <Return> "tkButtonInvoke $w.buts.b1"
    bind $w <Alt-o> "tkButtonInvoke $w.buts.b1"
    bind $w <Alt-c> "tkButtonInvoke $w.buts.b2"
    focus $w.buts.b1
    wm protocol $w WM_DELETE_WINDOW "tkButtonInvoke $w.buts.b2"

    while 1 {
	vwait RamSeriesLaminateResults::data(action)
	
	if { $RamSeriesLaminateResults::data(action) == "cancel" } {
	    destroy $w
	    return
	}
	switch $RamSeriesLaminateResults::NewResult \
	    [= "Security coef."] { set res FS } \
	    [= "Layer Stresses"] { set res stresses } \
	    [= "Layer Strains"]  { set res strains }

	set err [catch { LoadResultforLayer $res $RamSeriesLaminateResults::NewResultLayer } \
		     errstring]
	if { $err } {
	    WarnWin $errstring $w
	} else { destroy $w }
    }
}
#RamSeriesLaminateResults::LoadNewResult
proc RamSeriesLaminateResults::get_valuePostLam { name } {  
    variable doc
    set file [file join $::lsdynaPriv(problemtypedir) "ramseries_default.spd"]
    set aux1 [tDOM::xmlReadFile $file]
    set doc [dom parse $aux1]
    
    set node [$doc selectNodes [format_xpath {//value[@n=%s]} $name]]
    return [get_domnode_attribute $node v]

}


proc RamSeriesLaminateResults::LastLamCom {spinB} {
variable LastLam

    if {$LastLam ==0} {
	$spinB configure -bg white -state normal
    } else {
	$spinB configure -state disabled 
    }
   
}