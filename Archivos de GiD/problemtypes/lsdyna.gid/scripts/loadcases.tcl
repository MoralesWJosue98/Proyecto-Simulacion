

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

namespace eval combined_loadcases {}
# for auto_load
proc combined_loadcases::win { args } {}

proc combined_loadcases::update { doc boundary_conds } {

    set loadcases ""
    set xp {/*/container[@n='loadcases']/blockdata[@n='loadcase']}
    foreach n [$doc selectNodes $xp] {
	lappend loadcases [$n @name]
    }

    set xp {/*/container[@n='loadcases']/container[@n='combined_loadcases']/blockdata}
    set nrows 0
    foreach blockNode [$doc selectNodes $xp] {
	set values [$blockNode selectNodes value]
	if { [llength $loadcases] == [llength $values] } {
	    set icol 0
	    foreach loadcase $loadcases {
		gid_groups_conds::setAttributes \
		    [gid_groups_conds::nice_xpath [lindex $values $icol]] \
		    [list name $loadcase]
		incr icol
	    }
	} else {
	    set d ""
	    foreach value $values {
		dict set d [$value @name] [$value @v]
		$value delete
	    }
	    foreach loadcase $loadcases {
		if { [dict exists $d $loadcase] } {
		    set factor [dict get $d $loadcase]
		} else { set factor 0.0 }
		if { $factor eq "" } { set factor 0.0 }
		gid_groups_conds::add [gid_groups_conds::nice_xpath $blockNode] \
		    value [list n "combined_loadcase_lc" name $loadcase v $factor]
	    }
	}
    }

    set xp {/*/container[@n='loadcases']/container[@n='combined_loadcases']}
    set d [$doc selectNodes $xp]
    if { $boundary_conds ne "" } { $boundary_conds actualize_domNode $d }
}

snit::widgetadaptor combined_loadcases::win {
    option -doc ""
    option -boundary_conds ""
    option -item ""

    delegate method * to hull
    delegate option * to hull

    variable comb_tree
    variable comb_types
    
    constructor args {

	set comb_types [dict create ELU [= ELU] ELS [= ELS]]

	destroy $win
	set w [dialogwin_snit $win -title [= "Combined loadcases"] \
		-callback [mymethod create_do] -grab 0 \
		-morebuttons [list [_ Apply]]]
	set f [$w giveframe]
	installhull $win

	set comb_tree [fulltktree $f.tree -expand 0 -showheader 1 -width 600 \
		-bd 1 -relief raised -showbuttons 0 -showlines 0 \
		-sensitive_cols all \
		-returnhandler [mymethod combination_tree return] \
		-editbeginhandler [mymethod combination_tree edit_begin] \
		-editaccepthandler [mymethod combination_tree edit] \
		-contextualhandler [mymethod combination_tree contextual] \
		-deletehandler [mymethod combination_tree delete_row] \
		]

	grid $f.tree -sticky nswe -padx 2 -pady 2
	grid columnconfigure $f 0 -weight 1
	grid rowconfigure $f 0 -weight 1

	tk::TabToWindow $comb_tree
	bind $w <Return> [list $w invokeok]
	$w createwindow
	$self configurelist $args
    }
    destructor {}
    onconfigure -doc {value} {
	set options(-doc) $value
	$self combination_tree add_cols
    }
    method update {} {

	set doc [dom parse {<ramseries_data>
		<container n='loadcases' pn='Loadcases'>
		<container n='combined_loadcases'>
		</container></container></ramseries_data>}]
	$self combination_tree update_rows_to_doc $doc
	$self combination_tree add_cols
	$comb_tree item delete all
	$self combination_tree add_rows_from_doc $doc
	$doc delete
    }
    method combination_tree { what args } {
	switch $what {
	    add_cols {
		set loadcases ""
		set xp {/*/container[@n='loadcases']/blockdata[@n='loadcase']}
		foreach n [$options(-doc) selectNodes $xp] {
		    lappend loadcases [$n @name]
		}                
		set cols ""
		lappend cols [list 17 [_ "New combined"] left item 1]
		lappend cols [list 14 [_ "type"] left text 1]
		foreach loadcase $loadcases {
		    lappend cols [list 15 $loadcase left text 1]
		}
		$comb_tree configure -columns $cols
		$comb_tree item delete all
		set nrows [$self combination_tree add_rows_from_doc]
		if { $nrows == 0 } {
		    $self combination_tree add_row
		}
	    }
	    add_rows_from_doc {
		set doc [lindex $args 0]
		if { $doc eq "" } { set doc $options(-doc) }
		set xp {/*/container[@n='loadcases']/container[@n='combined_loadcases']/blockdata}
		set nrows 0
		foreach n [$doc selectNodes $xp] {
		    set list [list [$n @name] [$n @comb_type]]
		    set cols [lrange [$comb_tree cget -columns] 2 end]
		    set values [$n selectNodes value]
		    set icol 0
		    foreach col $cols {
		        if { [llength $cols] == [llength $values] } {
		            set factor [[lindex $values $icol] @v]
		        } else {
		            set name [lindex $col 1]
		            set xpi [format_xpath {string(value[@name=%s]/@v)} $name]
		            set factor [$n selectNodes $xpi]
		        }
		        if { $factor eq "" } { set factor 0.0 }
		        lappend list $factor
		        incr icol
		    }
		    $comb_tree insert end $list
		    incr nrows
		}
		return $nrows
	    }
	    update_rows_to_doc {
		set doc [lindex $args 0]
		if { $doc eq "" } { set doc $options(-doc) }
		set xp {/*/container[@n='loadcases']/container[@n='combined_loadcases']}
		set domNode [$doc selectNodes $xp]
		foreach node [$domNode selectNodes blockdata] {
		    if { $doc eq $options(-doc) } {
		        gid_groups_conds::delete [gid_groups_conds::nice_xpath \
		                $node]
		    } else {
		        $node delete
		    }
		}
		set cols ""
		foreach col [lrange [$comb_tree cget -columns] 2 end] {
		    lappend cols [lindex $col 1]
		}
	     
		foreach item [$comb_tree item children root] {
		    set list [$comb_tree item text $item]
		    if { $doc eq $options(-doc) } {
		        set blockNode [gid_groups_conds::add \
		                [gid_groups_conds::nice_xpath $domNode] \
		                blockdata \
		                [list n "combined_loadcase" name [lindex $list 0] \
		                    sequence 1 sequence_type non_void_deactivated \
		                    active 1 editable_name unique \
		                    comb_type [lindex $list 1]]]
		    } else {
		        set blockNode [$domNode appendChildTag blockdata \
		                [list attributes() n "combined_loadcase" name [lindex $list 0] \
		                    sequence 1 sequence_type non_void_deactivated \
		                    active 1 editable_name unique \
		                    comb_type [lindex $list 1]]]
		    }
		    foreach i [lrange $list 2 end] col $cols {
		        if { $doc eq $options(-doc) } {
		            gid_groups_conds::add [gid_groups_conds::nice_xpath \
		                    $blockNode] value \
		                [list n "combined_loadcase_lc" name $col v $i]
		        } else {
		            $blockNode appendChildTag value \
		                [list attributes() n "combined_loadcase_lc" name $col v $i]
		        }
		    }
		}
		if { $options(-boundary_conds) ne "" } {
		    $options(-boundary_conds) actualize $options(-item)
		}
	    }
	    add_row {
		set fact 1.0
		foreach "fact" $args break
		set new_names ""
		foreach item [$comb_tree item children root] {
		    lappend new_names [$comb_tree item text $item 0]
		}
		set i 1
		set new_name [= "New combined %d" $i]
		while { [lsearch -exact $new_names $new_name] != -1 } {
		    set new_name [= "New combined %d" [incr i]]
		}
		set list [list $new_name [= ELU]]
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
	    one_row_per_result {
		set fact 1.0
		foreach "fact" $args break
		$comb_tree item delete all
		foreach col1 [lrange [$comb_tree cget -columns] 2 end] {
		    set new_name [lindex $col1 1]
		    set list [list $new_name [= ELU]]
		    foreach col2 [lrange [$comb_tree cget -columns] 2 end] {
		        if { $col1 == $col2 } {
		            lappend list $fact
		        } else {
		            lappend list 0.0
		        }
		    }
		    $comb_tree insert end $list
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
		        set names ""
		        foreach item [$comb_tree item children root] {
		            lappend names [$comb_tree item text $item 0]
		        }
		        return [list combo 1 $names]
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
		$menu add command -label [_ "One combined per results"] \
		    -command [mymethod combination_tree one_row_per_result]
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
	    return {
		set item [$comb_tree item id "active below"]
		$comb_tree selection clear all
		if { $item eq "" } {
		    $self combination_tree add_row
		    set item [$comb_tree item id "active below"]
		}
		$comb_tree selection add $item
		$comb_tree activate $item
	    }
	    default {
		error "error in combination_tree what=$what"
	    }
	}
    }
    method create_do { w } {
	if { [$w giveaction] < 1 } {
	    destroy $w
	    return
	}
	$self combination_tree update_rows_to_doc

	if { [$w giveaction] == 1 } {
	    destroy $w
	    return
	}
    }
}

















