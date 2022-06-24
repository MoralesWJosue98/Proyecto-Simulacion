

package require snit
package require tile
package require dialogwin
package require fulltktree
package require customLib_utils

if { [package vcompare 8.5 [package present Tcl]] > 0 } {
    package require dict
}
package require tooltip
namespace import -force tooltip::tooltip

proc create_post_result { args } {} ;# for tclIndex

snit::widgetadaptor create_post_result {

    delegate method * to hull
    delegate option * to hull

    variable notebook
    variable comb_tree
    variable userdef_text
    variable userdef_tree
    variable delete_result_tree

    variable comb_types

    constructor args {

	set comb_types [dict create combined [_ combined] \
		maximum [_ maximum] minimum [_ minimum] \
		"maximum abs" [_ "maximum abs"]]

	destroy $win
	set w [dialogwin_snit $win -title [_ "Create result"] \
		-callback [mymethod create_do] -grab 0 \
		-okname [_ Apply] -cancelname [_ Close]]
	set f [$w giveframe]
	installhull $win

	set notebook [ttk::notebook $f.nb]

################################################################################
#    Combination table
################################################################################

	set f0 [ttk::labelframe $f.nb.f0 -text [_ "create result"]]
	$f.nb add $f0 -sticky nsew -text [_ "Combination table"]

	set anals [GiD_Info postprocess get all_analysis]
	set steps [GiD_Info postprocess get all_steps [lindex $anals 0]]

	set all_results [list [_ "ALL"]]
	foreach anal $anals {
	    foreach step [GiD_Info postprocess get all_steps $anal] {
		foreach result [GiD_Info postprocess get results_list Contour_Fill $anal $step] {
		    lappend all_results $result
		}
	    }
	}
	set comb_tree [fulltktree $f0.tree -expand 0 -showheader 1 \
		-bd 1 -relief raised -showbuttons 0 -showlines 0 \
		-sensitive_cols all \
		-editbeginhandler [mymethod combination_tree edit_begin] \
		-editaccepthandler [mymethod combination_tree edit] \
		-contextualhandler [mymethod combination_tree contextual] \
		-deletehandler [mymethod combination_tree delete_row] \
		]
	
	$self combination_tree add_cols

	set f2 [frame $f0.f2]
	ttk::label $f2.l -text [_ "Result"]:
	ttk::combobox $f2.cb -textvariable [$w give_uservar result] \
	    -values $all_results -state readonly

	$w set_uservar_value result [lindex $all_results 0]

	grid $f2.l $f2.cb -sticky w

	set f3 [frame $f0.f3]
	ttk::label $f3.l -text [_ "Time step"]:

	ttk::combobox $f3.cb1 -textvariable [$w give_uservar step] \
	    -values $steps -width 6 -state readonly

	$w set_uservar_value step [GiD_Info postprocess get cur_step]

	grid $f3.l $f3.cb1 -sticky w -padx 2

	grid $f0.tree  -sticky nswe -padx 2 -pady 2
	grid $f2 -sticky w -padx 2 -pady 2
	grid $f3 -sticky w -padx 2 -pady 2
	grid columnconfigure $f0 0 -weight 1
	grid rowconfigure $f0 0 -weight 1

################################################################################
#    User defined function
################################################################################

	set f1 [ttk::labelframe $f.nb.f1 -text [_ "create result"]]
	$f.nb add $f1 -sticky nsew -text [_ "User defined function"]

	set cols {
	    { 100 result left item 1 }
	}
	ttk::frame $f1.fr
	ttk::radiobutton $f1.fr.r1 -text [_ "Analysis"] -variable \
	    [$w give_uservar tree_type] \
	    -value analysis -command [mymethod fill_tree userdef]
	ttk::radiobutton $f1.fr.r2 -text [_ "Result"] -variable \
	    [$w give_uservar tree_type result] \
	    -value result -command [mymethod fill_tree userdef]
	grid $f1.fr.r1 $f1.fr.r2 -sticky w -padx 2 -pady 2
	set userdef_tree [fulltktree $f1.tree -columns $cols -expand 1 -showheader 0 \
		-bd 1 -relief sunken -height 100]
	
	$self fill_tree userdef

	set fre [ttk::frame $f1.fre]
	ttk::button $fre.b1 -text [_ Add] -command [mymethod add_result]
	ttk::label $fre.l1 -text [_ Factor:]
	ttk::entry $fre.e1 -textvariable [$w give_uservar factor 1.0] -width 6
	ttk::label $fre.l2 -text [_ Component:]
	ttk::combobox $fre.cb1 -textvariable [$w give_uservar component ""] \
	    -values "" -width 6

	grid $fre.b1 $fre.l1 $fre.e1 $fre.l2 $fre.cb1 -sticky w -padx 2 -pady 2

	set f2 [frame $f1.f2]
	ttk::label $f2.l -text [_ "New result"]:
	ttk::combobox $f2.cb -textvariable [$w give_uservar new_result \
		[_ "New result"]]
	grid $f2.l $f2.cb -sticky w

	set f3 [frame $f1.f3]
	ttk::label $f3.l -text [_ "Create in"]:

	set anals [GiD_Info postprocess get all_analysis]
	set steps [GiD_Info postprocess get all_steps [lindex $anals 0]]

	ttk::combobox $f3.cb1 -textvariable [$w give_uservar new_analysis] \
	    -values $anals
	ttk::combobox $f3.cb2 -textvariable [$w give_uservar new_step] \
	    -values $steps -width 6

	$w set_uservar_value new_analysis [GiD_Info postprocess get cur_analysis]
	$w set_uservar_value new_step [GiD_Info postprocess get cur_step]

	grid $f3.l $f3.cb1 $f3.cb2 -sticky w -padx 2


	set ft [ttk::labelframe $f1.ft -text [_ "TCL expression"]]
	ttk::radiobutton $ft.r1 -text [_ Scalar] -variable \
	    [$w give_uservar scalar_noscalar scalar] -value scalar
	ttk::radiobutton $ft.r2 -text [_ "As 1st result"] -variable \
	    [$w give_uservar scalar_noscalar] -value noscalar

	tooltip $ft.r2 [_ "Result will have the same components than the 1st result in the operation"]

	set userdef_text [text $ft.t -wrap word -width 60 -height 6 -bd 1]
	bind $userdef_text <3> [mymethod contextual_text %X %Y]

	$w add_trace_to_uservar scalar_noscalar [mymethod check_component $f2.cb $fre.cb1]
	$userdef_tree notify bind DontDelete <Selection> [mymethod check_component $f2.cb $fre.cb1]

	$w set_uservar_value scalar_noscalar noscalar

	grid $ft.r1 -sticky w -padx 2 -pady 2
	grid $ft.r2 -sticky w -padx 2 -pady 2
	grid $ft.t  -sticky nsew -padx 2 -pady 2
	grid columnconfigure $ft 0 -weight 1
	grid rowconfigure $ft 2 -weight 1
   
	grid $f1.fr     -    -sticky w -padx 2 -pady 2
	grid $f1.tree   -    -sticky wens -padx 2 -pady 2
	grid $f1.fre     -    -sticky w -padx 2 -pady 2
	grid $f2    -    -sticky w -padx 2 -pady 2
	grid $f3    -    -sticky w -padx 2 -pady 2
	grid $ft      -    -sticky nsew -padx 2 -pady 2
	grid columnconfigure $f1 1 -weight 1
	grid rowconfigure $f1 "1 5" -weight 1

################################################################################
#    Delete results
################################################################################

	set f4 [ttk::labelframe $f.nb.f4 -text [_ "delete result"]]
	$f.nb add $f4 -sticky nsew -text [_ "Delete results"]

	set cols {
	    { 100 result left item 1 }
	}
	ttk::frame $f4.fr
	ttk::radiobutton $f4.fr.r1 -text [_ "Analysis"] -variable \
	    [$w give_uservar tree_type] \
	    -value analysis -command [mymethod fill_tree delete_result]
	ttk::radiobutton $f4.fr.r2 -text [_ "Result"] -variable \
	    [$w give_uservar tree_type result] \
	    -value result -command [mymethod fill_tree delete_result]
	grid $f4.fr.r1 $f4.fr.r2 -sticky w -padx 2 -pady 2
	set delete_result_tree [fulltktree $f4.tree -columns $cols -expand 1 -showheader 0 \
		-bd 1 -relief sunken -height 100]
	
	$self fill_tree delete_result

	grid $f4.fr     -    -sticky w -padx 2 -pady 2
	grid $f4.tree   -    -sticky wens -padx 2 -pady 2
	grid columnconfigure $f4 0 -weight 1
	grid rowconfigure $f4 1 -weight 1


	grid $f.nb -sticky nsew
	grid columnconfigure $f 0 -weight 1
	grid rowconfigure $f 0 -weight 1
	
	tk::TabToWindow $userdef_tree
	bind $w <Return> [list $w invokeok]
	$w createwindow
	$self configurelist $args
    }
    destructor {}
    method restart {} {
	destroy $win
	create_post_result $win
    }
    method combination_tree { what args } {
	switch $what {
	    add_cols {
		set anals [GiD_Info postprocess get all_analysis]
		set steps [GiD_Info postprocess get all_steps [lindex $anals 0]]
		
		set all_results ""
		foreach anal $anals {
		    foreach step [GiD_Info postprocess get all_steps $anal] {
		        foreach result [GiD_Info postprocess get results_list Contour_Fill $anal $step] {
		            lappend all_results $result
		        }
		    }
		}
		set all_results [lsort -dictionary -unique $all_results]
		
		set cols ""
		lappend cols [list 17 [_ "New name"] left item 1]
		lappend cols [list 14 [_ "type"] left text 1]
		foreach anal $anals {
		    lappend cols [list 15 $anal left text 1]
		}
		$comb_tree configure -columns $cols
		$comb_tree item delete all
		$self combination_tree add_row
	    }
	    add_row {
		set fact 1.0
		foreach "fact" $args break
		set new_names ""
		foreach item [$comb_tree item children root] {
		    lappend new_names [$comb_tree item text $item 0]
		}
		set i 1
		set new_name [_ "New name %d" $i]
		while { [lsearch -exact $new_names $new_name] != -1 } {
		    set new_name [_ "New name %d" [incr i]]
		}
		set list [list $new_name [_ combined]]
		foreach col [lrange [$comb_tree cget -columns] 2 end] {
		    lappend list $fact
		}
		$comb_tree insert end $list
	    }
	    delete_row {
		foreach item [$comb_tree selection get] {
		    $comb_tree item delete $item
		}
	    }
	    selectall {
		$comb_tree selection add all
	    }
	    copy {
		set cols [$comb_tree cget -columns]
		set dataList ""
		set lineList ""
		foreach i $cols {
		    lappend lineList [lindex $i 1]
		}
		lappend dataList [join $lineList \t]
		set ncols [llength [$comb_tree cget -columns]]
		
		foreach item [$comb_tree selection get] {
		    set lineList ""
		    for { set col 0 } { $col < $ncols } { incr col } {
		        lappend lineList [$comb_tree item text $item $col]
		    }
		    lappend dataList [join $lineList \t]
		}
		clipboard clear
		clipboard append [join $dataList \n]
	    }
	    paste {
		set optional {
		    { -substitute "" 0 }
		}
		set compulsory ""
		parse_args -raise_compulsory_error 0 $optional $compulsory $args

		set err [catch { split [clipboard get] \n } dataList]
		if { $err } { return }
		if { $substitute } {
		    foreach item [$comb_tree item children root] {
		        $comb_tree item delete $item
		    }
		}
		foreach i $dataList {
		    set err [catch { split $i \t } lineList]
		    if { $err } { return }
		    set non_num 0
		    foreach j [lrange $lineList 2 end] {
		        if { ![string is double -strict $j] } { incr non_num }
		    }
		    if { [llength $lineList] > 2 && $non_num == 0 } {
		        $comb_tree insert end $lineList
		    }
		}
	    }
	    edit_begin {
		foreach "- item col" $args break
		switch $col {
		    0 {
		        return [list combo 1 [GiD_Info postprocess get all_analysis]]
		    }
		    1 {
		        return [list combo 0 [dict values $comb_types]]
		    }
		    default {
		        return 1
		    }
		}
	    }
	    edit {
		foreach "- item col txt" $args break
		$comb_tree item text $item $col $txt
	    }
	    contextual {
		foreach "x y" [lrange $args 2 3] break
		catch { destroy $comb_tree._cmenu }
		set menu [menu $comb_tree._cmenu -tearoff 0]
		
		$menu add command -label [_ "Add result (factor 1.0)"] \
		    -command [mymethod combination_tree add_row 1.0]
		$menu add command -label [_ "Add result (factor 0.0)"] \
		    -command [mymethod combination_tree add_row 0.0]
		$menu add separator
		$menu add command -label [_ "Select all"] \
		    -command [mymethod combination_tree selectall]
		$menu add command -label [_ "Copy"] \
		    -command [mymethod combination_tree copy]
		$menu add command -label [_ "Paste"] \
		    -command [mymethod combination_tree paste]
		$menu add command -label [_ "Paste (substitute)"] \
		    -command [mymethod combination_tree paste -substitute]
		$menu add separator

		$menu add command -label [_ "Delete"] \
		    -command [mymethod combination_tree delete_row]
		tk_popup $menu $x $y
		
	    }
	    default {
		error "error in combination_tree what=$what"
	    }
	}
    }
    method fill_tree { what } {
	switch $what {
	    userdef { set tree $userdef_tree }
	    delete_result { set tree $delete_result_tree }
	}
	set tree_type [$win give_uservar_value tree_type]
	$tree item delete all
	if { $tree_type eq "analysis" } {
	    foreach anal [GiD_Info postprocess get all_analysis] {
		set node [$tree insert end [list $anal] root]
		set steps [GiD_Info postprocess get all_steps $anal]
		foreach step $steps {
		    if { [llength $steps] == 1 } {
		        set parent $node
		    } else {
		        set parent [$tree insert end [list $step] $node]
		    }
		    set results [GiD_Info postprocess get results_list Contour_Fill $anal $step]
		    foreach result $results {
		        $tree insert end [list $result] $parent
		    }
		}
		$tree item collapse $node
	    }
	} else {
	    set resdict ""
	    foreach anal [GiD_Info postprocess get all_analysis] {
		set steps [GiD_Info postprocess get all_steps $anal]
		foreach step $steps {
		    set results [GiD_Info postprocess get results_list Contour_Fill $anal $step]
		    foreach result $results {
		        dict set resdict $result $step $anal ""
		    }
		}
	    }
	    foreach result [lsort -dictionary [dict keys $resdict]] {
		set node [$tree insert end [list $result] root]
		set d [dict get $resdict $result]
		set steps [lsort -dictionary [dict keys $d]]
		foreach step $steps {
		    if { [llength $steps] == 1 } {
		        set parent $node
		    } else {
		        set parent [$tree insert end [list $step] $node]
		    }
		    set d1 [dict get $d $step]
		    set results [dict keys $d1]
		    foreach result $results {
		        $tree insert end [list $result] $parent
		    }
		}
		$tree item collapse $node
	    }
	}
    }
    method check_component { combo_res combo_comp } {
	set scalar_noscalar [$win give_uservar_value scalar_noscalar]
	if { $scalar_noscalar eq "scalar" } {
	    $combo_comp state !disabled
	} else {
	    $combo_comp state disabled
	}
	if { [llength [$userdef_tree selection get]] } {
	    set item [lindex [$userdef_tree selection get] 0]
	    set l [$userdef_tree item_path_text $item]
	    while { [llength [$userdef_tree item children $item]] } {
		set item [lindex [$userdef_tree item children $item] 0]
		set v ""
		for { set i 0 } { $i < [$userdef_tree numcolumns] } { incr i } {
		    lappend v [$userdef_tree item text $item $i]
		}
		lappend l $v
	    }
	    set tree_type [$win give_uservar_value tree_type]
	    if { $tree_type eq "analysis" } {
		set anal [lindex $l 0]
		set result [lindex $l end]
	    } else {
		set result [lindex $l 0]
		set anal [lindex $l end]
	    }
	    if { [llength $l] == 3 } {
		set step [lindex $l 1]
	    } else {
		set step [lindex [GiD_Info postprocess get all_steps $anal] 0]
	    }
	    set components_list [GiD_Info postprocess get components_list \
		    Contour_Fill $result $anal $step]

	} else {
	   set components_list "" 
	}
	$combo_comp configure -values $components_list
	set component [$win give_uservar_value component]
	if { [lsearch -exact $components_list $component] == -1 } {
	    $win set_uservar_value component [lindex $components_list 0]
	}
	set tree_type [$win give_uservar_value tree_type]
	set results ""
	foreach l [$self give_selected_results_list userdef] {
	    if { $tree_type eq "analysis" } {
		set result [lindex $l end]
	    } else {
		set result [lindex $l 0]
	    }
	    lappend results $result
	}
	$combo_res configure -values [lsort -dictionary -unique $results]
    }
    method give_selected_results_list { what } {
	switch $what {
	    userdef { set tree $userdef_tree }
	    delete_result { set tree $delete_result_tree }
	}
	set resultList ""
	foreach item [$tree selection get] {
	    set l [$tree item_path_text $item]
	    if { ![llength [$tree item children $item]] } {
		lappend resultList $l
	    } else {
		foreach itemc [$tree item children $item] {
		    set lc $l
		    set v ""
		    for { set i 0 } { $i < [$tree numcolumns] } { incr i } {
		        lappend v [$tree item text $itemc $i]
		    }
		    lappend lc $v
		    if { ![llength [$tree item children $itemc]] } {
		        lappend resultList $lc
		    } else {
		        foreach itemd [$tree item children $itemc] {
		            set ld $lc
		            for { set i 0 } { $i < [$tree numcolumns] } { incr i } {
		                lappend v [$tree item text $itemd $i]
		            }
		            lappend ld $v
		            lappend resultList $ld
		        }
		    }
		}
	    }
	}
	return $resultList
    }
    method contextual_text { x y } {

	catch { destroy $userdef_text._cmenu }
	set menu [menu $userdef_text._cmenu -tearoff 0]

	$menu add command -label [_ "Clear"] \
	    -command [list $userdef_text delete 1.0 end]
	tk_popup $menu $x $y

    }
    method add_result {} {
	foreach l [$self give_selected_results_list userdef] {
	    set tree_type [$win give_uservar_value tree_type]
	    if { $tree_type eq "analysis" } {
		set anal [lindex $l 0]
		set result [lindex $l end]
	    } else {
		set result [lindex $l 0]
		set anal [lindex $l end]
	    }
	    if { [llength $l] == 3 } {
		set step [lindex $l 1]
	    } else {
		set step [lindex [GiD_Info postprocess get all_steps $anal] 0]
	    }
	    set components_list [GiD_Info postprocess get components_list \
		    Contour_Fill $result $anal $step]

	    catch { $userdef_text delete sel.first sel.last }
	    set scalar_noscalar [$win give_uservar_value scalar_noscalar]
	    set factor [$win give_uservar_value factor]
	    if { $scalar_noscalar eq "scalar" } {
		set component [$win give_uservar_value component]
		if { [lsearch -exact $components_list $component] == -1 } {
		    set component [lindex $components_list 0]
		}
		if { [$userdef_text get insert-1c] eq "\}" } {
		    $userdef_text insert insert "+"
		}
		$userdef_text insert insert "$factor*\${r\(\"$anal\",\"$step\",\"$result\",\"$component\"\)}"
	    } else {
		if { [$userdef_text get insert-1c] eq "\}" } {
		    $userdef_text insert insert "+"
		}
		$userdef_text insert insert "$factor*\${r\(\"$anal\",\"$step\",\"$result\"\)}"
	    }
	}
    }
    method create_do { w } {
	if { [$w giveaction] < 1 } {
	    destroy $w
	    return
	}
	switch [$notebook index current] {
	    0 {
		$self create_combination_table
	    }
	    1 {
		$self create_user_defined
	    }
	    2 {
		$self delete_results
	    }
	}
	catch { unset ::BarresPriv(problemtype) }
    }
    method delete_results {} {
	set results [$self give_selected_results_list delete_result]

	set ret [snit_messageBox -type okcancel -default ok \
		-message [_ "Are you sure to delete %d results?" \
		    [llength $results]] \
		-parent $win]
	if { $ret == "cancel" } { return }

	foreach l $results {
	    set tree_type [$win give_uservar_value tree_type]
	    if { $tree_type eq "analysis" } {
		set anal [lindex $l 0]
		set result [lindex $l end]
	    } else {
		set result [lindex $l 0]
		set anal [lindex $l end]
	    }
	    if { [llength $l] == 3 } {
		set step [lindex $l 1]
	    } else {
		set step [lindex [GiD_Info postprocess get all_steps $anal] 0]
	    }
	    GiD_Result delete [list $result $anal $step]
	}
	$self fill_tree userdef
	$self fill_tree delete_result
	$self combination_tree add_cols
	gid_groups_conds::actualize_post_window
    }
    method create_combination_table {} {
	set result [$win give_uservar_value result]
	set step [$win give_uservar_value step]

	set columns [$comb_tree cget -columns]
	set anals ""
	set idx 2
	foreach i [lrange $columns 2 end] {
	    set all_fac_zero 1
	    foreach item [$comb_tree item children root] {
		set fac [$comb_tree item text $item $idx]
		if { $fac != 0.0 } {
		    set all_fac_zero 0
		    break
		}
	    }
	    incr idx
	    if { $all_fac_zero } { continue }
	    lappend anals [lindex $i 1]
	}
	if { $result eq [_ "ALL"] } {
	    set anal [lindex $anals 0]
	    set results [GiD_Info postprocess get results_list Contour_Fill $anal $step]
	} else {
	    set results [list $result]
	}
	
	set new_combinedList ""
	foreach item [$comb_tree item children root] {
	    set v [$comb_tree item text $item]
	    set type_t [lindex $v 1]
	    set ipos [lsearch -exact [dict values $comb_types] $type_t]
	    set type [lindex [dict keys $comb_types] $ipos]
	    lset v 1 $type
	    lappend new_combinedList $v
	}
	
	GidUtils::CreateAdvanceBar [= "Creating results"] [= "Percentage"] ::advanceBar
	
	set num_results [llength $results]
	set num_anal [llength $anals]
	set num_combined [llength $new_combinedList]

	set delta_result [expr {100.0/$num_results}]
	set delta_anal [expr {1.0/$num_anal}]
	$self _create_result ini ""

	for { set iresult 0 } { $iresult < $num_results } { incr iresult } {
	    set result [lindex $results $iresult]
	    
	    set resultsList ""
	    for { set ianal 0 } { $ianal < $num_anal } { incr ianal } {
		set anal [lindex $anals $ianal]
		set ::advanceBar [expr {round(($iresult+$ianal*$delta_anal)*$delta_result)}]
		set header "\"$result\" $anal $step"
		set err [catch { GiD_Result get $header } r0]
		if { $err } { continue }
		if { [regexp {^GiD_Result:} $r0] } { continue }
		
		if { ![llength $resultsList] } {
		    foreach "- - - - rtype where GPname" [lindex $r0 0] break
		    set componentsList [GiD_Info postprocess get components_list \
		            Contour_Fill $result $anal $step]
		    
		    set len [llength $r0]
		    
		    if { [lindex $r0 1 0] eq "ComponentNames" } {
		        set i0 2
		    } else {
		        set i0 1
		    }
		    if { [llength [lindex $r0 $i0 1]] > 1 } {
		        set sublist 1
		        if { $where eq "OnGaussPoints" } {
		            set ngauss [expr {[llength [lindex $r0 $i0]]-1}]
		        } else {
		            set ngauss 1
		        }
		        set components [llength [lindex $r0 $i0 1]]
		        set delta_i 1
		    } else {
		        set sublist 0
		        set l1 [llength [lindex $r0 $i0]]
		        set ngauss 1
		        set ipos [expr {$i0+1}]
		        while { [llength [lindex $r0 $ipos]] < $l1 } {
		            incr ngauss
		            incr ipos
		            if { $ipos >= $len } { break }
		        }
		        set components [expr {$l1-1}]
		        set delta_i $ngauss
		    }

		    foreach combined $new_combinedList {
		        set new_anal [lindex $combined 0]
		        set resList ""
		        set res "Result \"$result\" \"$new_anal\" $step $rtype $where"
		        if { $GPname ne "" } { append res " \"$GPname\"" }
		        lappend resList $res "ComponentNames \"[join $componentsList \",\"]\""
		        for { set i $i0 } { $i < $len } { incr i $delta_i } {
		            set elm [lindex $r0 $i 0]
		            set res [list $elm [lrepeat $ngauss [lrepeat $components ""]]]
		            lappend resList $res
		        }
		        lappend resultsList $resList
		    }
		}
		for { set icombined 0 } { $icombined < $num_combined } { incr icombined } {
		    set combined [lindex $new_combinedList $icombined]
		    foreach "new_anal type" [lrange $combined 0 1] break
		    set factor [lindex $combined [expr {$ianal+2}]]

		    set irow 2
		    for { set i $i0 } { $i < $len } { incr i $delta_i } {
		        for { set igauss 0 } { $igauss < $ngauss } { incr igauss } {
		            for { set j 0 } { $j < $components } { incr j } {
		                set value [lindex $resultsList $icombined $irow 1 $igauss $j]
		               
		                if { $sublist } {
		                    set r [lindex $r0 $i [expr {$igauss+1}] $j]
		                } else {
		                    set ipos [expr {$i+$igauss}]
		                    if { $igauss == 0 } {
		                        set jpos [expr {$j+1}]
		                    } else { set jpos $j }
		                    set r [lindex $r0 $ipos $jpos]
		                }
		                if { $r eq "" } { continue }
		                if { $value eq "" } {
		                    set value [expr {$factor*$r}]
		                } elseif { $type eq "combined" } {
		                    set value [expr {$value+$factor*$r}]
		                } elseif { $type eq "maximum" } {
		                    set v0 [expr {$factor*$r}]
		                    if { $v0 > $value } { set value $v0 }
		                } elseif { $type eq "minimum" } {
		                    set v0 [expr {$factor*$r}]
		                    if { $v0 < $value } { set value $v0 }
		                } elseif { $type eq "maximum abs" } {
		                    set v0 [expr {$factor*$r}]
		                    if { abs($v0) > abs($value) } { set value $v0 }
		                } else {
		                    error "error in create_combination_table"
		                }
		                lset resultsList $icombined $irow 1 $igauss $j $value
		            }
		        }
		        incr irow
		    }
		}
	    }
	    for { set icombined 0 } { $icombined < $num_combined } { incr icombined } {
		set nrows [llength [lindex $resultsList $icombined]]
		for { set irow 2 } { $irow < $nrows } { incr irow } {
		    set elmList [lindex $resultsList $icombined $irow]
		    set elemString "[lindex $elmList 0] [join [lindex $elmList 1] \n]"
		    lset resultsList $icombined $irow $elemString
		}
		$self _create_result add [lindex $resultsList $icombined]
	    }
	}
	$self _create_result end ""
	$self restart
	gid_groups_conds::actualize_post_window
	set ::advanceBar 100
    }      

#     method create_combination_table {} {
#         set result [$win give_uservar_value result]
#         set step [$win give_uservar_value step]

#         set columns [$comb_tree cget -columns]
#         set anals ""
#         set idx 2
#         foreach i [lrange $columns 2 end] {
#             set all_fac_zero 1
#             foreach item [$comb_tree item children root] {
#                 set fac [$comb_tree item text $item $idx]
#                 if { $fac != 0.0 } {
#                     set all_fac_zero 0
#                     break
#                 }
#             }
#             incr idx
#             if { $all_fac_zero } { continue }
#             lappend anals [lindex $i 1]
#         }
#         if { $result eq [_ "ALL"] } {
#             set anal [lindex $anals 0]
#             set results [GiD_Info postprocess get results_list Contour_Fill $anal $step]
#         } else {
#             set results [list $result]
#         }
#         $self _create_result ini ""
#         foreach result $results {
#             foreach anal $anals {
#                 #set header [list $result $anal $step]
#                 set header "\"$result\" $anal $step"
#                 set err [catch { GiD_Result get $header } r0($anal,$step,$result)]
#                 if { $err } { continue }
#                 if { [regexp {^GiD_Result:} $r0($anal,$step,$result)] } { continue }
#                 foreach "- - - - rtype where GPname" \
#                     [lindex $r0($anal,$step,$result) 0] break
#                 set componentsList [GiD_Info postprocess get components_list \
#                         Contour_Fill $result $anal $step]

#                 set len [llength $r0($anal,$step,$result)]

#                 if { [lindex $r0($anal,$step,$result) 1 0] eq "ComponentNames" } {
#                     set i0 2
#                 } else {
#                     set i0 1
#                 }
#                 if { [llength [lindex $r0($anal,$step,$result) $i0 1]] > 1 } {
#                     set sublist 1
#                     if { $where eq "OnGaussPoints" } {
#                         set ngauss [expr {[llength [lindex $r0($anal,$step,$result) $i0]]-1}]
#                     } else {
#                         set ngauss 1
#                     }
#                     set components [llength [lindex $r0($anal,$step,$result) $i0 1]]
#                     set delta_i 1
#                 } else {
#                     set sublist 0
#                     set l1 [llength [lindex $r0($anal,$step,$result) $i0]]
#                     set ngauss 1
#                     set ipos [expr {$i0+1}]
#                     while { [llength [lindex $r0($anal,$step,$result) $ipos]] < $l1 } {
#                         incr ngauss
#                         incr ipos
#                         if { $ipos >= $len } { break }
#                     }
#                     set components [expr {$l1-1}]
#                     set delta_i $ngauss
#                 }
#             }
#             set anal_1 [lindex $anals 0]
#             set factors ""
#             foreach item [$comb_tree item children root] {
#                 set v ""
#                 for { set i 0 } { $i < [$comb_tree numcolumns] } { incr i } {
#                     lappend v [$comb_tree item text $item $i]
#                 }
#                 foreach "new_anal type_t" [lrange $v 0 1] break
#                 set ipos [lsearch -exact [dict values $comb_types] $type_t]
#                 set type [lindex [dict keys $comb_types] $ipos]
#                 set idx 2
#                 foreach anal $anals {
#                     lappend factors [lindex $v $idx]
#                     incr idx
#                 }
#                 set res "Result \"$result\" \"$new_anal\" $step $rtype $where"
#                 if { $GPname ne "" } { append res " \"$GPname\"" }
#                 set resList [list $res]
#                 lappend resList "ComponentNames \"[join $componentsList \",\"]\""
		
# #                 switch $rtype {
# #                     Scalar  { set components 1 }
# #                     Vector { set components 3 }
# #                     Matrix  { set components 6 }
# #                     PlainDeformationMatrix  { set components 4 } 
# #                     MainMatrix { set components 12 }
# #                     LocalAxes  { set components 3 }
# #                     default {
# #                         error "not implemented $rtype"
# #                     }
# #                 }
#                 for { set i $i0 } { $i < $len } { incr i $delta_i } {
#                     set elem [list [lindex $r0($anal_1,$step,$result) $i 0]]
#                     for { set igauss 1 } { $igauss <= $ngauss } { incr igauss } {
#                         for { set j 0 } { $j < $components } { incr j } {
#                             set value ""
#                             for { set k 0 } { $k < [llength $anals] } { incr k } {
#                                 set anal [lindex $anals $k]
#                                 set factor [lindex $factors $k]
#                                 if { $sublist } {
#                                     set r [lindex $r0($anal,$step,$result) $i $igauss $j]
#                                 } else {
#                                     set ipos [expr {$i+$igauss-1}]
#                                     if { $igauss == 1 } {
#                                         set jpos [expr {$j+1}]
#                                     } else { set jpos $j }
#                                     set r [lindex $r0($anal,$step,$result) $ipos $jpos]
#                                 }
#                                 if { $r eq "" } { continue }
#                                 if { $value eq "" } {
#                                     set value [expr {$factor*$r}]
#                                 } elseif { $type eq "combined" } {
#                                     set value [expr {$value+$factor*$r}]
#                                 } elseif { $type eq "maximum" } {
#                                     set v0 [expr {$factor*$r}]
#                                     if { $v0 > $value } { set value $v0 }
#                                 } elseif { $type eq "minimum" } {
#                                     set v0 [expr {$factor*$r}]
#                                     if { $v0 < $value } { set value $v0 }
#                                 } elseif { $type eq "maximum abs" } {
#                                     set v0 [expr {$factor*$r}]
#                                     if { abs($v0) > abs($value) } { set value $v0 }
#                                 } else {
#                                     error "error in create_combination_table"
#                                 }
#                             }
#                             append elem " $value"
#                         }
#                         append elem "\n   "
#                     }
#                     lappend resList $elem
#                 }
#                 $self _create_result add $resList
#             }
#         }
#         $self _create_result end ""

#         $self restart
#         gid_groups_conds::actualize_post_window
#     }
    variable _create_result_fout
    method _create_result { what resList } {

# not used now
#         if { $what eq "add" } {
#             eval GiD_Result create $resList
#         }
#         return

	
	switch $what {
	    ini {
		set file [file join $::env(TEMP) tmpfile.flavia.res]
		set fout [open $file w]
		puts $fout "GiD Post Results File 1.0"
		set _create_result_fout $fout
	    }
	    add {
		set fout $_create_result_fout
		puts $fout [lindex $resList 0]
		puts $fout [lindex $resList 1]
		puts $fout "Values"
		foreach i [lrange $resList 2 end] {
		    puts $fout $i
		}
		puts $fout "End Values"
	    }
	    end {
		set file [file join $::env(TEMP) tmpfile.flavia.res]
		set fout $_create_result_fout
		close $fout
		GiD_Process MEscape files add $file
		file delete $file
		unset _create_result_fout
	    }
	    all {
		$self _create_result ini ""
		$self _create_result add $resList
		$self _create_result end ""
	    }
	}
    }
    method create_user_defined {} {
	set data [string trim [$userdef_text get 1.0 end]]
	set scalar_noscalar [$win give_uservar_value scalar_noscalar]
	set fresults ""
	if { $scalar_noscalar eq "scalar" } {
	    set rex {\$\{r\(\"(.*?)\",\"(.*?)\",\"(.*?)\",\"(.*?)\"\)\}}
	    foreach "- anal step result component" [regexp -inline -all $rex $data] {
		lappend fresults [list $anal $step $result]
	    }
	} else {
	    set rex {\$\{r\(\"(.*?)\",\"(.*?)\",\"(.*?)\"\)\}}
	    foreach "- anal step result" [regexp -inline -all $rex $data] {
		lappend fresults [list $anal $step $result]
	    }
	}
	set fresults [lsort -unique $fresults]
	foreach "rtype where GPname" [list "" "" ""] break
	foreach f $fresults {
	    foreach "anal step result" $f break
	    #set header [list $result $anal $step]
	    set header "\"$result\" $anal $step"

	    set err [catch { GiD_Result get $header } r0($anal,$step,$result)]
	    if { $err } { continue }
	    if { $err || [regexp {^GiD_Result:} $r0($anal,$step,$result)] } {
		snit_messageBox -message [_ "Results not OK"] \
		    -parent $win
		return
	    }
	    foreach "- - - - new_rtype new_where new_GPname" \
		[lindex $r0($anal,$step,$result) 0] break
	    if { $scalar_noscalar eq "scalar" } { set new_rtype "Scalar" }
	    if { $rtype eq "" } {
		foreach "rtype where GPname" [list $new_rtype $new_where $new_GPname] break
		set componentsList [GiD_Info postprocess get components_list \
		        Contour_Fill $result $anal $step]
		set len [llength $r0($anal,$step,$result)]
		if { [lindex $r0($anal,$step,$result) 1 0] eq "ComponentNames" } {
		    set i0 2
		} else {
		    set i0 1
		}
		if { [llength [lindex $r0($anal,$step,$result) $i0 1]] > 1 } {
		    set sublist 1
		    if { $where eq "OnGaussPoints" } {
		        set ngauss [expr {[llength [lindex $r0($anal,$step,$result) $i0]]-1}]
		    } else {
		        set ngauss 1
		    }
		    set components [llength [lindex $r0($anal,$step,$result) $i0 1]]
		    set delta_i 1
		} else {
		    set sublist 0
		    set l1 [llength [lindex $r0($anal,$step,$result) $i0]]
		    set ngauss 1
		    set ipos [expr {$i0+1}]
		    while { [llength [lindex $r0($anal,$step,$result) $ipos]] < $l1 } {
		        incr ngauss
		        incr ipos
		        if { $ipos >= $len } { break }
		    }
		    set components [expr {$l1-1}]
		    set delta_i $ngauss
		}

	    } elseif { $rtype ne $new_rtype || $where ne $new_where || \
		$GPname ne $new_GPname  } {
		snit_messageBox -message [_ "Results are not compatible"] \
		    -parent $win
		return
	    }
	}
	if { $rtype eq "" } {
	    snit_messageBox -message [_ "There are no results in expression"] \
		-parent $win
	    return
	}

	foreach i [list new_analysis new_step] {
	    set $i [$win give_uservar_value $i]
	}
	set new_result [$win give_uservar_value new_result]
	set res "Result \"$new_result\" \"$new_analysis\" $new_step $rtype $where"
	if { $GPname ne "" } { append res " \"$GPname\"" }
	set resList [list $res]
	lappend resList "ComponentNames \"[join $componentsList \",\"]\""
	
#         switch $rtype {
#             Scalar  { set components 1 }
#             Vector { set components 3 }
#             Matrix  { set components 6 }
#             PlainDeformationMatrix  { set components 4 } 
#             MainMatrix { set components 12 }
#             LocalAxes  { set components 3 }
#             default {
#                 error "not implemented $rtype"
#             }
#         }
	foreach "anal_1 step_1 result_1" [lindex $fresults 0] break
	if { $scalar_noscalar eq "scalar" } {
	    foreach f $fresults {
		foreach "anal step result" $f break
		set components_list($f) [GiD_Info postprocess get components_list \
		        Contour_Fill $result $anal $step]
	    }
	    for { set i $i0 } { $i < $len } { incr i $delta_i } {
		set elem [list [lindex $r0($anal_1,$step_1,$result_1) $i 0]]
		for { set igauss 1 } { $igauss <= $ngauss } { incr igauss } {
		    foreach f $fresults {
		        foreach "anal step result" $f break
		        set j 0
		        foreach component $components_list($f) {
		            if { $sublist } {
		                set rv [lindex $r0($anal,$step,$result) $i $igauss $j]
		            } else {
		                set ipos [expr {$i+$igauss-1}]
		                if { $igauss == 1 } {
		                    set jpos [expr {$j+1}]
		                } else { set jpos $j }
		                set rv [lindex $r0($anal,$step,$result) $ipos $jpos]
		            }
		            set r(\"$anal\",\"$step\",\"$result\",\"$component\") $rv
		            incr j
		        }
		    }
		    set err [catch { eval expr $data } res]
		    if { $err } {
		        snit_messageBox -message [_ "Expression is not correct (%s)" $res] \
		            -parent $win
		        return
		    }
		    lappend elem $res
		}
		lappend resList $elem
	    }
	} else {
	    for { set i $i0 } { $i < $len } { incr i $delta_i } {
		set elem [list [lindex $r0($anal_1,$step_1,$result_1) $i 0]]
		for { set igauss 1 } { $igauss <= $ngauss } { incr igauss } {
		    for { set j 0 } { $j < $components } { incr j } {
		        foreach f $fresults {
		            if { $sublist } {
		                set rv [lindex $r0($anal,$step,$result) $i $igauss $j]
		            } else {
		                set ipos [expr {$i+$igauss-1}]
		                if { $igauss == 1 } {
		                    set jpos [expr {$j+1}]
		                } else { set jpos $j }
		                set rv [lindex $r0($anal,$step,$result) $ipos $jpos]
		            }
		            foreach "anal step result" $f break
		            set r(\"$anal\",\"$step\",\"$result\") $rv
		        }
		        set err [catch { eval expr $data } res]
		        if { $err } {
		            snit_messageBox -message [_ "Expression is not correct (%s)" $res] \
		                -parent $win
		            return
		        }
		        append elem " $res"
		    }
		    append elem "\n   "
		}
		lappend resList [string trim $elem]
	    }
	}
	$self _create_result all $resList
	gid_groups_conds::actualize_post_window
    }
}
