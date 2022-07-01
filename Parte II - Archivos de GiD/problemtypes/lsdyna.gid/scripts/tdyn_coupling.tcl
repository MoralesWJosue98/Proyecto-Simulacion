

package require snit
package require tile
package require dialogwin
package require customLib_utils

if { [package vcompare 8.5 [package present Tcl]] > 0 } {
    package require dict
}
package require tooltip
namespace import -force tooltip::tooltip

namespace eval tdyn_coupling {
    variable defaultdir ""
}
# for auto_load
proc tdyn_coupling::win { args } {}

snit::widgetadaptor tdyn_coupling::win {
    option -doc ""
    option -boundary_conds ""
    option -item ""

    delegate method * to hull
    delegate option * to hull

    variable filename ""
    variable analysis ""
    variable analysisList
    variable analysisDict ""
    variable result ""
    variable resultList
    variable save_analysis ""
    variable save_result ""
    variable timestepList
    variable alpha
    variable alpha_units
    variable num_timesteps 10
    variable groupName ""
    variable groupNameList ""
    variable message ""
    
    constructor args {

	destroy $win
	set w [dialogwin_snit $win -title [= "Tdyn coupling"] \
		-callback [mymethod create_do] -grab 0 \
		-morebuttons [list [_ Clear]]]
	set f [$w giveframe]
	installhull $win

	ttk::label $f.l1 -text [= File]:
	ttk::entry $f.e1 -textvariable [myvar filename] -width 60
	ttk::button $f.b1 -image [icon_chooser::giveimage fileopen-16] \
	    -style Toolbutton -command [mymethod open_file]

	ttk::label $f.l2 -text [= Analysis]:
	cu::combobox $f.cb1 -textvariable [myvar analysis] \
	    -valuesvariable [myvar analysisList] -state readonly
	
	ttk::label $f.l3 -text [= Result]:
	cu::combobox $f.cb2 -textvariable [myvar result] \
	    -valuesvariable [myvar resultList] -state readonly

	ttk::label $f.l4 -text \u03B1:
	gid_groups_conds::register_popup_help $f.l4 [= "Thermal expansion"]
	
	gid_groups_conds::entry_units $f.sw -unit_magnitude 1/DeltaTemp \
	    -value 0.00001 -unit "1/\u0394\u00B0C" \
	    -value_variable [myvar alpha] \
	    -units_variable [myvar alpha_units]

	ttk::label $f.l5 -text [= "Number of load cases"]:
	spinbox $f.sb1 -textvariable [myvar num_timesteps] -from 1 -to 1000 \
	    -width 4

	ttk::label $f.l6 -text [= Group]:
	cu::combobox $f.cb3 -textvariable [myvar groupName] \
	    -valuesvariable [myvar groupNameList] -state readonly

	ttk::label $f.l7 -textvariable [myvar message]

	grid $f.l1 $f.e1 $f.b1 -sticky w -pady 1
	grid $f.l2 $f.cb1  -   -sticky w -pady 1
	grid $f.l3 $f.cb2  -   -sticky w -pady 1
	grid $f.l4 $f.sw   -   -sticky w -pady 1
	grid $f.l5 $f.sb1  -   -sticky w -pady 1
	grid $f.l6 $f.cb3  -   -sticky w -pady 1
	grid $f.l7    -    -   -sticky w -pady 1
	grid configure $f.e1 $f.cb1 $f.cb2 $f.cb3 $f.sw -sticky ew

	grid columnconfigure $f 1 -weight 1
	grid rowconfigure $f 6 -weight 1

	set cmd "[mymethod changed_filename] ;#"
	trace add variable [myvar filename] write $cmd
	bind $f.e1 <Destroy> [list trace remove variable \
		[myvar filename] write $cmd]

	set cmd "[mymethod _update_resultList] ;#"
	trace add variable [myvar analysis] write $cmd
	bind $f.cb1 <Destroy> [list trace remove variable \
		[myvar analysis] write $cmd]
	
	tk::TabToWindow $f.e1
	bind $w <Return> [list $w invokeok]
	$w createwindow
	$self configurelist $args
    }
    destructor {}
    onconfigure -doc {value} {
	set options(-doc) $value
	$self update_from_xml
    }
    method update_from_xml {} {

	set xp0 {/*/blockdata[@n="General data"]/blockdata[@n='Advanced']/}
	append xp0 {container[@n='Tdyn_coupling']}
	foreach i [list filename analysis result timesteps] {
	    set xp "$xp0/value\[@n='Tdyn_$i'\]"
	    set valueNode [$options(-doc) selectNodes $xp]
	    set $i [get_domnode_attribute $valueNode v]
	}
	set num_timesteps [llength [split $timesteps ,]]
	if { $num_timesteps < 1 } { set num_timesteps 10 }

	set xp {/*/container[@n='loadcases']/blockdata[@n='loadcase'][1]//}
	append xp {condition[@n="Temperature_solid"]/group}
	set groupNode [$options(-doc) selectNodes $xp]
	if { $groupNode ne "" } {
	    set groupName [$groupNode @n]
	    set alpha [$groupNode selectNodes {string(value[@n="alpha"]/@v)}]
	}
	set groupNameList ""
	foreach g [$options(-doc) selectNodes {/*/groups/group}] {
	    lappend groupNameList [$g @n]
	}
	set groupNameList [lsort -dictionary $groupNameList]
	if { [lsearch -exact $groupNameList $groupName] == -1 } {
	    set groupName [lindex $groupNameList 0]
	}
    }
    method update_to_xml {} {
	set filename [string trim $filename]
	
	if { $filename eq "" } {
	    set xp0 {/*/blockdata[@n="General data"]/blockdata[@n='Advanced']/}
	    append xp0 {container[@n='Tdyn_coupling']}
	    
	    gid_groups_conds::setAttributes $xp0 [list active 0]
	    
	    foreach i [list filename analysis result timesteps] {
		set xp "$xp0/value\[@n='Tdyn_$i'\]"
		gid_groups_conds::setAttributes $xp \
		    [list v ""]
	    }
	    $options(-boundary_conds) actualize
	    return
	}
	
	if { ![file exists $filename] } {
	    error [= "File %s is not correct" $filename]
	}
	if { [llength $timestepList] < 1 } {
	    error [= "Time steps are not correct"]
	}
	if { $num_timesteps < 1 } {
	    error [= "Number of load cases is not correct"]
	}

	if { $num_timesteps > [llength $timestepList] } {
	    error [= "Number of load cases must be less or equal than number of timesteps"]
	}
	set t1 [lindex $timestepList 0]
	set t2 [lindex $timestepList end]
	set len [llength $timestepList]
	set posVec ""
	set ipos 0
	foreach i [range 0 $num_timesteps] {
	    set t [expr {($num_timesteps-$i-1)/double($num_timesteps-1)*$t1+
		    $i/double($num_timesteps-1)*$t2}]
	    while 1 {
		set min_delta ""
		set min_delta_ipos ""
		foreach j [range $ipos $len] {
		    set d [expr {abs($t-[lindex $timestepList $j])}]
		    if { $min_delta eq "" || $d < $min_delta } {
		        set min_delta $d
		        set min_delta_ipos $j
		    }
		}
		if { $min_delta ne "" } {
		    lappend posVec $min_delta_ipos
		    set ipos [expr {$min_delta_ipos+1}]
		    break
		}
		foreach j [range [expr {[llength $posVec]-1}] 0 -1] {
		    if { [lindex $posVec $j] > [lindex $posVec [expr {$j-1}]]+1 } {
		        foreach k [range $j [llength $posVec]] {
		            lset posVec $k [expr {[lindex $posVec $k]-1}]
		        }
		        incr ipos -1
		        break
		    }
		}
	    }
	}
	set loadcases ""
	set timesteps ""
	foreach i $posVec {
	    lappend loadcases [= "Loadcase step %s" [lindex $timestepList $i]]
	    lappend timesteps [lindex $timestepList $i]
	}
	set xp {/*/container[@n='loadcases']/blockdata[@n='loadcase']}
	set bdNodes [$options(-doc) selectNodes $xp]

	if { [llength $bdNodes] < [llength $loadcases] } {
	    set t [= "Do you want to create/update loadcases (Create %d loadcases)?" \
		    [expr {[llength $loadcases]-[llength $bdNodes]}]]
	    set ret [snit_messageBox -type okcancel -default ok \
		    -message $t -parent $win]
	    if { $ret == "cancel" } { error "" }

	    set n [lindex $bdNodes 0]
	    foreach l [lrange $loadcases [llength $bdNodes] end] {
		$options(-boundary_conds) copy_block_data -domNode $n \
		    -copy_cond_groups -newname $l
	    }
	} elseif { [llength $bdNodes] > [llength $loadcases] } {
	    set t [= "Do you want to update loadcases (Delete %d loadcases)?" \
		    [expr {[llength $bdNodes]-[llength $loadcases]}]]
	    set ret [snit_messageBox -type okcancel -default ok \
		    -message $t -parent $win]
	    if { $ret == "cancel" } { error "" }
	 
	    foreach n [lrange $bdNodes [llength $loadcases] end] {
		gid_groups_conds::delete [gid_groups_conds::nice_xpath $n]   
	    }
	}

	set xp {/*/container[@n='loadcases']/blockdata[@n='loadcase']}
	set bdNodes [$options(-doc) selectNodes $xp]
	foreach n $bdNodes l $loadcases {
	    if { $n eq "" } { break }
	    gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $n] \
		[list name $l]
	    set cndNode [$n selectNodes {.//condition[@n="Temperature_solid"]}]
	    set group [$cndNode selectNodes group]
	    if { [llength $group] > 1 } {
		foreach i $group { $i delete }
		set group ""
	    }
	    set alpha_unitsV [gid_groups_conds::nice_units_to_units $alpha_units]
	    
	    if { [llength $group] == 0 } {
		set g [gid_groups_conds::add [gid_groups_conds::nice_xpath $cndNode] \
		        group [list n $groupName]]

		foreach i [list alpha deltaT] value [list $alpha 0.0] units \
		    [list $alpha_unitsV "\u0394\u00B0C"] {
		    set v [$cndNode selectNodes "value\[@n='$i'\]"]
		    set attDict [eval eval dict create [$v selectNodes @*]]
		    dict set attDict v $value
		    dict set attDict units $units
		    set v [gid_groups_conds::add [gid_groups_conds::nice_xpath $g] \
		            value $attDict]
		}
	    } else {
		if { [$group @n] ne $groupName } {
		    gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $group] \
		        [list n $groupName]
		}
		foreach i [list alpha deltaT] value [list $alpha 0.0] units \
		    [list $alpha_unitsV "\u0394\u00B0C"] {
		    set v [$group selectNodes "value\[@n='$i'\]"]
		    if { [$v @v] ne $value } {
		        gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $v] \
		            [list v $value]
		    }
		    if { [$v @units ""] ne $units } {
		        gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $v] \
		            [list units $units]
		    }
		    if { $i eq "deltaT" && [$v @state normal] ne "disabled" } {
		        gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $v] \
		            [list state disabled]
		    }
		}
	    }
	}

	set xp {/*/container[@n='loadcases']/container[@n='combined_loadcases']}
	set cld [$options(-doc) selectNodes $xp]
	set bdNodes [$cld selectNodes blockdata]
	if { [llength $bdNodes] < [llength $loadcases] } {
	    set n [lindex $bdNodes 0]
	    foreach l [lrange $loadcases [llength $bdNodes] end] {
		if { $n eq "" } {
		    set n [gid_groups_conds::add [gid_groups_conds::nice_xpath $cld] \
		            blockdata [list n combined_loadcase name $l \
		                sequence 1 sequence_type non_void_deactivated \
		                active 1 editable_name unique comb_type ELU]]
		} else {
		    $options(-boundary_conds) copy_block_data -domNode $n \
		    -newname $l
		}
	    }
	} elseif { [llength $bdNodes] > [llength $loadcases] } {
	    foreach n [lrange $bdNodes [llength $loadcases] end] {
		gid_groups_conds::delete [gid_groups_conds::nice_xpath $n]   
	    }
	}
	combined_loadcases::update $options(-doc) $options(-boundary_conds)

	set bdNodes [$cld selectNodes blockdata]
	set idx 0
	foreach n $bdNodes l $loadcases {
	    if { $n eq "" } { break }
	    gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $n] \
		[list name $l comb_type ELU]
	    set idx_in 0
	    foreach v [$n selectNodes value] {
		set name [lindex $loadcases $idx_in]
		if { [$v @name] ne $name } {
		    gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $v] \
		        [list name $name]
		}
		if { $idx == $idx_in } { set value 1.0 } else { set value 0.0 }
		if { [$v @v] ne $value } {
		    gid_groups_conds::setAttributes [gid_groups_conds::nice_xpath $v] \
		        [list v $value]
		}
		incr idx_in
	    }
	    incr idx
	}

	set timesteps [join $timesteps ,]
	set xp0 {/*/blockdata[@n="General data"]/blockdata[@n='Advanced']/}
	append xp0 {container[@n='Tdyn_coupling']}
	
	gid_groups_conds::setAttributes $xp0 [list active 1]
	
	foreach i [list filename analysis result timesteps] {
	    set xp "$xp0/value\[@n='Tdyn_$i'\]"
	    gid_groups_conds::setAttributes $xp \
		[list v [set $i]]
	}
	$options(-boundary_conds) actualize
    }
    method open_file {} {
	set dir $::tdyn_coupling::defaultdir
	set file [tk_getOpenFile -defaultextension .flavia.res -filetypes \
		[list [list [_ "GiD res files"] [list ".flavia.res"]] \
		    [list [_ "GiD res files"] [list ".res"]] \
		    [list [_ "All files"] [list "*"]]] \
		-initialdir $dir \
		-parent $win -title [_ "Open GiD result file"]]
	if { $file == "" } { return }
	set ::tdyn_coupling::defaultdir [file dirname $file]
	set filename $file
    }
    method changed_filename {} {
	after cancel [mymethod changed_filename_do]
	after 300 [mymethod changed_filename_do]
    }
    method changed_filename_do {} {

	foreach "analysisList resultList timestepList analysisDict" \
	    [list "" "" "" ""] break
	if { $analysis ne "" } { set save_analysis $analysis }
	if { $result ne "" } { set save_result $result }

	if { ![file exists $filename] } {
	    foreach "analysis result message" [list "" "" ""] break
	    return
	}

	$win configure -cursor watch
	update

	set fin [open $filename r]
	set data [read $fin]
	close $fin

	foreach i [regexp -inline -all -line {^Result.*$} $data] {
	    foreach "- r a t" $i break
	    lappend analysisList $a
	    dict lappend analysisDict $a $r
	    if { $t != 0 } {
		lappend timestepList $t
	    }
	}
	dict for "n v" $analysisDict {
	    dict set analysisDict $n [lsort -dictionary -unique $v]
	}
	set analysisList [lsort -dictionary -unique $analysisList]
	set timestepList [lsort -real -unique $timestepList]

	if { $analysis eq "" } { set analysis $save_analysis }

	if { [lsearch -exact $analysisList $analysis] == -1 } {
	    set analysis [lindex $analysisList 0]
	} else {
	    $self _update_resultList
	}
	set message [= "There are %d timesteps from %g to %g" \
		[llength $timestepList] [lindex $timestepList 0] \
		[lindex $timestepList end]]

	if { [llength $timestepList] > 0 && $num_timesteps > [llength $timestepList] } {
	    set num_timesteps [llength $timestepList]
	}
	$win configure -cursor ""
    }
    method _update_resultList {} {
	
	if { [dict exists $analysisDict $analysis] } {
	    set resultList [dict get $analysisDict $analysis]
	} else { set resultList "" }
	if { $result eq "" } { set result $save_result }
	if { [lsearch -exact $resultList $result] == -1 } {
	    set result [lindex $resultList 0]
	}
    }
    method create_do { w } {
	if { [$w giveaction] < 1 } {
	    destroy $w
	    return
	}

	switch [$w giveaction] {
	    1 {
		set err [catch { $self update_to_xml } ret]
		if { !$err } {
		    destroy $w
		    return
		} elseif { $ret ne "" } {
		    snit_messageBox -parent $win -message $ret
		}
	    }
	    2 {
		set filename ""
	    }
	}
    }
}

















