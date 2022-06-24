
namespace eval SteelSections {
    variable dblclick
    variable tree
    variable imglabel
    variable text
    variable IsDataRead 0
    variable DataTypes "" ;# includes CustomSteelSections
    variable CustomSteelSections ""
    variable Data
    variable Units
    variable Description
    variable Id
    variable Images
    variable material
    variable path
}

proc SteelSections::PrepareToReloadData {} {
    variable IsDataRead

    set IsDataRead 0
}

proc SteelSections::ReadData { file { iscustom no } } {
    variable DataTypes
    variable CustomSteelSections
    variable Description
    variable Data
    variable Units
    variable Comments
    variable IsDataRead

    set descs [list name A Iy Iz Iyz J Wy Wz Aty Atz Yg Zg Comments]
    set units [list - m2 m4 m4 m4 m4 m3 m3 m2 m2 m m]

    set f [open $file r]
    while { ![eof $f] } {
	gets $f aa
	set list [split $aa ";\t"]
	if { [llength $list] != [llength $descs] } { continue }
	if { [string equal -nocase [lindex $list 0] [lindex $descs 0]] } { continue }
	set rname [lindex $list 0]
	set name [split $rname -]
	set sname [lindex $name 0]
	set Description($sname) $descs
	if { [lsearch -exact $DataTypes $sname] == -1 } {
	    lappend DataTypes $sname
	}
	if { $iscustom eq "iscustom" && [lsearch -exact $CustomSteelSections $rname] == -1 } {
	    lappend CustomSteelSections $rname
	}
	set Data($name) $list
	set Units($sname) $units
    }
    set CustomSteelSections [lsort $CustomSteelSections]
    set IsDataRead 1
}

proc SteelSections::ReadData_old { file } {
    variable DataTypes
    variable Data
    variable Units
    variable Description
    variable Id

    catch { unset Description Units Data DataTypes Id }

    set f [open $file r]
    set line 1
    while { ![eof $f] } {
	gets $f aa
	if { [regexp {^[ ]*$} $aa] } { continue }
	if { [regexp {^[ ]*#} $aa] } { continue }
	if { [string match Description* $aa] } {
	    set Description([lindex $aa 1]) [lrange $aa 2 end]
	    lappend DataTypes [lindex $aa 1]
	} elseif { [string match Units* $aa] } {
	    set Units([lindex $aa 1]) [lrange $aa 2 end]
	} elseif { [string match Id* $aa] } {
	    if { ![info exists Description([lindex $aa 1])] } {
		set type [lindex $aa 1]
		tk_messageBox -message \
		        [= "type '%s' has no Description when reading Id. Line=%s" $type $line]
		exit
	    }
	    set pos ""
	    foreach i [lrange $aa 2 end] {
		lappend pos [lsearch $Description([lindex $aa 1]) $i]
	    }
	    set Id([lindex $aa 1]) $pos
	} else {
	    set type [lindex $aa 0]
	    if { ![info exists Description($type)] } {
		tk_messageBox -message [= "type '%s' has no Description. Line=%s" $i $line]
		exit
	    }
	    if { ![info exists Id($type)] } {
		tk_messageBox -message [= "type '%s' has no Id. Line=%s" $i $line]
		exit
	    }
	    set name ""
	    foreach i $Id($type) {
		lappend name [lindex $aa $i]
	    }
	    set Data($name) $aa
	}
	incr line
    }
    close $f
}

proc SteelSections::SortData { idp data1 data2 } {

    set c 0
    foreach i $idp {
	if { [lindex $data1 $c] < [lindex $data2 $c] } { return -1 }
	if { [lindex $data1 $c] > [lindex $data2 $c] } { return 1 }
	incr c
    }
    return 0
}

proc SteelSections::ConvertValuesToSI { val unit } {
    
    if { $val == 0.0 || $val == 1} {
	return 1.0
    } else {
	switch -- $unit {
	    m - m2 - m3 - m4 - m6 { return $val }
	    cm { return [expr $val*1e-2] }
	    mm { return [expr $val*1e-3] }
	    mm2 { return [expr $val*1e-6] }
	    mm3 { return [expr $val*1e-9] }
	    cm2 - cm² { return [expr $val*1e-4] }
	    cm3 { return [expr $val*1e-6] }
	    cm4 { return [expr $val*1e-8] }
	    cm6 { return [expr $val*1e-12] }
	    mm4 { return [expr $val*1e-12] }
	    kp/m { return [expr $val*9.8] }
	    - { return $val }
	    default {
		error "Unknown unit '$unit' (val=$val)"
		exit
	    }
	}
    }
}

proc SteelSections::ConvertValuesFromSI { val unit } {

    if { $val == 0.0 || $val == 1} {
	return 1.0
    } else {
	switch $unit {
	    cm { return [expr $val*1e2] }
	    mm { return [expr $val*1e3] }
	    cm2 { return [expr $val*1e4] }
	    cm3 { return [expr $val*1e6] }
	    cm4 { return [expr $val*1e8] }
	    kp/m { return [expr $val/9.8] }
	    default {
		error "Unknown unit '$unit' "
		#tk_messageBox -message "Unknown unit '$unit' "
		exit
	    }
	}
    }
}

proc SteelSections::ConvertValuesWithUnits { val unitfrom unitto } {
    return [ConvertValuesFromSI [ConvertValuesToSI $val $unitfrom] $unitto]
}


proc SteelSections::ChangeColumn { datatype oldname newname { expr "" } } {
    variable Units
    variable Description
    variable Data
    
    set ipos [lsearch $Description($datatype) $oldname]
    if { $ipos == -1 } { return }

    set Description($datatype) [lreplace $Description($datatype) $ipos $ipos $newname]
    if { $expr == "" } { return }

    foreach j [array names Data "$datatype *"] {
	foreach "{} var" [regexp -inline -all {[$]([a-zA-Z_]+)} $expr] {
	    if { $var == $oldname } {
		set jpos [lsearch $Description($datatype) $newname]
	    } else {
		set jpos [lsearch $Description($datatype) $var]
	    }
	    if { $jpos == -1 } {
		error "error ChangeColumn var=$var Description($datatype)=$Description($datatype)"
	    }
	    set $var [ConvertValuesWithUnits [lindex $Data($j) $jpos] \
		    [lindex $Units($datatype) $jpos] [lindex $Units($datatype) $ipos]]
	}
	set Data($j) [lreplace $Data($j) $ipos $ipos [expr $expr]]
    }
}


proc SteelSections::WriteTxtData { file } {
    variable DataTypes
    variable Data
    variable Units
    variable Description
    variable Id

    foreach i $DataTypes {
	switch $i {
	    UPN {
		ChangeColumn UPN c Yg
	    }
	    L {
		ChangeColumn L c Yg {$b-$c}
	    }
	    LD {
		ChangeColumn LD cy Yg {$b-$cy}
		ChangeColumn LD cz Zg {$h-$cz}
	    }
	    T {
		ChangeColumn T z Zg {$h-$z}
	    }
	}
    }

    set f [open $file w]
    foreach i $DataTypes {
	puts $f "Description $i $Description($i)"
	puts $f "Units $i $Units($i)"
	puts -nonewline $f "Id $i "
	foreach j $Id($i) {
	    puts -nonewline $f "[lindex $Description($i) $j] "
	}
	puts $f ""
    }
    foreach i $DataTypes {
	set idp ""
	foreach j $Id($i) {
	    lappend idp [lindex $Description($i) $j]
	}
	foreach j [lsort -command [list SteelSections::SortData $idp] [array names Data "$i *"]] {
	    puts $f $Data($j)
	}
    }
    close $f
}


proc SteelSections::Create { frame } {
    variable tree
    variable imglabel
    variable text
    variable zposition
    variable to_h_button

    set pw    [PanedWindow $frame.pw -side top]

    set pane  [$pw add -weight 1]
    set title [TitleFrame $pane.lf -text [= "steel sections"]]
    set sw    [ScrolledWindow [$title getframe].sw \
		  -relief sunken -borderwidth 2]
    set tree  [Tree $sw.tree \
	    -relief flat -borderwidth 0 -width 15 -highlightthickness 0\
	    -redraw 0 -dropenabled 1 -dragenabled 1 \
	    -dragevent 3 \
	    -droptypes { \
	    TREE_NODE    {copy {} move {} link {}} \
	    LISTBOX_ITEM {copy {} move {} link {}} \
	} \
	-opencmd   "SteelSections::ModTree 1" \
	-closecmd  "SteelSections::ModTree 0"]
    $sw setwidget $tree

    if {[string equal "unix" $::tcl_platform(platform)]} {
	bind [winfo toplevel $sw.tree] <4> "$sw.tree yview scroll -5 units"
	bind [winfo toplevel $sw.tree] <5> "$sw.tree yview scroll  5 units"
    }

    set title2 [TitleFrame $pane.lf2 -text [= "material"]]
    tk_optionMenu [$title2 getframe].om SteelSections::material A37 A42 A52
    set SteelSections::material A42
    
    pack $sw    -side top  -expand yes -fill both
    pack [$title2 getframe].om -side top  -expand yes -fill x
    pack $title2 -fill x
    pack $title -fill both -expand yes
    
    set pane [$pw add -weight 2]
    set lf   [labelframe $pane.lf -text [= "visual description"]]
    set imglabel [Label $lf.l -bd 2 -relief raised]
    set hlp [= "Position of the center (related to the natural center)"]
    Label $lf.l2 -text [= "Z axe position:"] -helptext $hlp
    spinbox $lf.sp1 -from 0 -to 1e4 -increment .5 -textvariable \
	SteelSections::zposition -width 4
    Label $lf.l3 -text cm -helptext $hlp
    Button $lf.b1 -text [= "Reset"] -helptext \
	[= "Sets 'Z axe position' equal to 0"] -command \
	[list set SteelSections::zposition 0.0] -width 8 -bd 1 -relief link
    set to_h_button [Button $lf.b2 -text "h/2"  -width 8 -bd 1  -relief link \
	    -helptext [= "Sets 'Z axe position' equal to h/2"] -state disabled]

    set zposition 0.0

    set cmd "[list SteelSections::UpdateZposition $tree] ;#"
    trace add variable SteelSections::zposition write $cmd
    bind $lf.sp1 <Destroy> [list trace remove variable \
	    SteelSections::zposition write $cmd]

    set lf2 [TitleFrame $pane.lf2 -text [= "properties"]]
    set sw    [ScrolledWindow [$lf2 getframe].sw]
    set text [text $sw.t -height 3 -width 10 -highlightthickness 0 -state disabled -wrap none]
    set textfam [font actual [$text cget -font] -family]
    set textsize [font actual [$text cget -font] -size]
    set stextsize [expr {$textsize-2}]
    
    if { [font actual [list $textfam $stextsize]] eq \
	[font actual [list $textfam $textsize]] } {
	set smallfont [list Helvetica $stextsize]
    } else {
	set smallfont [list $textfam $stextsize]
    }
    
    $text tag conf superindex -offset [expr [font metrics [$text cget -font] \
		-linespace]/3] -font $smallfont
    $text tag conf bold -font [list $textfam $textsize bold]
    
    $sw setwidget $text
    pack $sw -fill both -expand yes
    bind $text <1> "focus %W"

    pack $lf -fill x -expand 0
    pack $lf2 -fill both -expand yes
    grid $imglabel - - - - -sticky n
    grid $lf.l2 $lf.sp1 $lf.l3 $lf.b1 $to_h_button -sticky nw -padx 2 -pady 3
    #pack $text -fill both -expand 1
    grid columnconf $lf 4 -weight 1

    pack $pw -fill both -expand yes

    $tree bindText  <ButtonPress-1>        "SteelSections::Select 1"
    $tree bindText  <Double-ButtonPress-1> "SteelSections::Select 2"
    $tree bindImage  <ButtonPress-1>        "SteelSections::Select 1"
    $tree bindImage  <Double-ButtonPress-1> "SteelSections::Select 2"
    # dirty trick
#     foreach i [bind $tree.c] {
#         bind $tree.c $i "+ [list after idle [list SteelSections::Select 0 {}]]"
#     }
#      set bbox [ButtonBox $frame.bb -spacing 3 -padx 12 -pady 0 -homogeneous 1]
#      $bbox add -text [= Apply] -underline 0
#      $bbox add -text [= Close] -command "exit" -underline 0
#      $bbox setfocus 0
#      pack $bbox -pady 3

#      bind [winfo toplevel $frame] <Alt-a> "$bbox invoke 0"
#      bind [winfo toplevel $frame] <Alt-c> "$bbox invoke 1"

   SteelSections::Init
}

proc SteelSections::InsertPropertyInText { text name val units } {

    if { $val == "-" } { return }
    $text ins end $name bold
    $text ins end "="
    $text ins end "$val" [list name=$name]
    if { $units ne "-" } {
	for { set j 0 } { $j < [string length $units] } { incr j } {
	    set char [string index $units $j]
	    if { [string is digit $char] } {
		$text ins end $char superindex
	    } else {
		$text ins end $char
	    }
	}
    }
    $text ins end " "
}

# in m or cm
proc SteelSections::_getvalue { name property } {
    variable Description
    variable Data
    variable Units

    set type [lindex $name 0]
    set pos [lsearch $Description($type) $property]
    if { $pos == -1 } { return ""}
    if { ![info exists Data($name)] } { return }
    set val [lindex $Data($name) $pos]
    set unit  [lindex $Units($type) $pos]
    set ipos [lsearch [list m m2 m3 m4] $unit]
    if { $ipos != -1 } {
	set unit [lindex [list cm cm2 cm3 cm4] $ipos]
	set val [format "%.4g" [ConvertValuesFromSI $val $unit]]
    }
    return [list $val $unit]
}

proc SteelSections::UpdateZposition { tree } {
    variable zposition
    variable text

    if { ![winfo exists $tree] } { return }
    set node [$tree selection get]
    if { [llength $node] != 1 } { return }
    set name [split $node -]
    set type [lindex $name 0]

    foreach i [list A Iy Wy] {
	set $i ""
	foreach "$i -" [_getvalue $name $i] break
	if { [set $i] eq "" } { return }
    }
    set zg [expr {1.0*$Iy/$Wy}]
    set Iy [expr {$Iy+$zposition*$zposition*$A}]
    set Wy [expr {$Iy/($zg+abs($zposition))}]
    set "Z axe position" $zposition

    $text conf -state normal
    foreach i [list "Z axe position" Iy Wy] {
	set i1 ""
	foreach "i1 i2" [$text tag nextrange name=$i 1.0] break
	if { $i1 eq "" } { continue }
	$text delete $i1 $i2
	$text insert $i1 [format %.4g [set $i]] [list name=$i]
    }
    $text conf -state disabled
}

proc SteelSections::Select { num node } {
    variable dblclick
    variable Images
    variable tree
    variable imglabel
    variable text
    variable Data
    variable Description
    variable Units
    variable zposition
    variable to_h_button
    variable material

    set zposition 0.0

    if { $num == 0 } {
	#if { ![winfo exists $node] } { return }
	set node [$tree selection get]
	if { [llength $node] != 1 } { return }
    } elseif { ![$tree exists $node] } {
	TryToCreateNode $node
    }
    set dblclick 1
    if { $num == 1 || $num == 0 } {
       if { $num == 1 && [lsearch [$tree selection get] $node] != -1 } {
	    unset dblclick
	   # it can be used to let the user modify on value in the tree
	   #after 500 "SteelSections::Edit $node"
	   return
	}
	$tree selection set $node
	$tree see $node
	set parent [$tree parent $node]
	while { $parent != "root" } {
	    if { [$tree itemcget $parent -open] == 0 } {
		$tree itemconfigure $parent -open 1
	    }
	    set parent [$tree parent $parent]
	}
	#update
	set name [split $node -]
	set type [lindex $name 0]

	CreateImages $type

	$imglabel configure -image $Images($type) \
		-width [image width $Images($type)]
	$text conf -state normal
	$text del 1.0 end

	if { [info exists Data($name)] } {
	    set infostiffval [list jarenau]
	    set infostiffunits [list jarenau]
	    set stiffcomments [list jarenau]
	    set icount 0
	    foreach i $Description($type) {
		if { [regexp {^(char|int|name)} $i] } { continue }
		set pos [lsearch $Description($type) $i]
		if { $i eq "Comments" } {
		    $text insert end "\n"
		    InsertPropertyInText $text [= "Z axe position"] 0.0 cm
		    $text insert end "\n\n"
		    foreach j [split [lindex $Data($name) $pos]] {
		        if { [regexp {=} $j] } {
		            foreach "name val" [split $j =] {
		                if { [regexp {(.*)(m\d?)} $val {} val unit] } {
		                    lappend stiffcomments $name
		                    lappend stiffcomments $val
		                    set ipos [lsearch [list m m2 m3 m4] $unit]
		                    if { $ipos != -1 } {
		                        set unit [lindex [list cm cm2 cm3 cm4] $ipos]
		                        set val [format "%.4g" [ConvertValuesFromSI $val $unit]]
		                    }
		                } else { set unit - }
		                InsertPropertyInText $text $name $val $unit
		                if { $name eq "h" } {
		                    set h_value $val
		                }
		            }
		            incr icount
		        } else {
		            $text insert end "$j "
		        }
		        if { $icount == 3 } { 
		            $text ins end "\n"
		            set icount 0
		        }
		    }
		} else {
		    set val [lindex $Data($name) $pos]
		    if { $val eq "" || $val eq "-" } { continue }
		    set unit  [lindex $Units($type) $pos]
		    set ipos [lsearch [list m m2 m3 m4] $unit]
		    if { $ipos != -1 } {
		        set unit [lindex [list cm cm2 cm3 cm4] $ipos]
		        if { $val ne "" } {
		            set val [format "%.4g" [ConvertValuesFromSI $val $unit]]
		        }
		    }
		    lappend infostiffval [lindex $Data($name) $pos]
		    lappend infostiffunits [lindex $Units($type) $pos]
		    InsertPropertyInText $text $i $val $unit
		    if { $i eq "Zg" } { set Zg_value $val }
		}
		incr icount
		if { $icount == 3 } { 
		    $text ins end "\n"
		    set icount 0
		}
	    }
	    SteelSections::choosestifflabel $node $infostiffval $infostiffunits $stiffcomments $material
	}

	

	$text conf -state disabled

	if { ![info exists h_value] } {
	    $to_h_button configure -state disabled
	} else {
	    if { [info exists Zg_value] } {
		if { $h_value-$Zg_value > $Zg_value } {
		    set val [expr {$h_value-$Zg_value}]
		} else { set val $Zg_value }
		set txt Zg
	    } else {
		set txt h/2
		set val [expr {.5*$h_value}]
	    }
	    set val [format "%.4g" $val]
	    $to_h_button configure -state normal -text $txt -command \
		[list set SteelSections::zposition $val]
	}
    } else {
	if { [$tree itemcget $node -open] == 0 } {
	    $tree itemconfigure $node -open 1
	    set idx 1
	} else {
	    $tree itemconfigure $node -open 0
	    set idx 0
	}
	ModTree $idx $node
    }
}

proc SteelSections::choosestifflabel { node infostiffval infostiffunits stiffcomments material } {
    
    set stiffmat $material
    set stiffname $node
    set valsSI $infostiffval
    #         set morevals $stiffcomments
    for {set i 1} {$i <= [llength $stiffcomments]} {incr i 1} {
	lappend valsSI [lindex $stiffcomments $i]
    }
    return
}


proc SteelSections::Edit { node } {
    variable dblclick
    variable tree

    if { [info exists dblclick] } {
	return
    }
    if { [lsearch [$tree selection get] $node] != -1 } {
	set res [$tree edit $node [$tree itemcget $node -text]]
	if { $res != "" } {
	    $tree itemconfigure $node -text $res
	    if { [$list exists $node] } {
		$list itemconfigure $node -text $res
	    }
	    $tree selection set $node
	}
	return
    }
}

proc SteelSections::SortIndices { idx1 idx2 } {

    if { [lindex $idx1 1] < [lindex $idx2 1] } { return -1 }
    if { [lindex $idx1 1] > [lindex $idx2 1] } { return 1 }
    if { [lindex $idx1 2] < [lindex $idx2 2] } { return -1 }
    if { [lindex $idx1 2] > [lindex $idx2 2] } { return 1 }
    return 0
}

proc SteelSections::CreateImages { datatype } {
    variable Images
    variable path

    if { [info exists Images($datatype)] } { return }

    set imgname profile_$datatype.gif
    if { [string match profile_HE* $imgname] } {
	set imgname profile_HE.gif
    }
    if { [string match profile_NavalT $imgname] } {
	set imgname profile_NAVALT.gif
    }
    set dir [file join $path images steelsections]
    if { ![file exists $dir] } {
	set dir [file join $path images]
    }
    if { [catch {
	set Images($datatype) [image create photo -file [file join $dir $imgname]]
    }] } {
	if { ![info exists Images(profile_blank.gif)] } {
	    set Images(blank) [image create photo -file [file join $dir \
		                                             profile_blank.gif]]
	}
	set Images($datatype) $Images(blank)
    }
    set imgname icon_$datatype.gif

    if { [string match icon_*F.gif $imgname] } {
	regexp {icon_(.*)F} $imgname {} img
	set imgname icon_$img.gif
    }
    if { $imgname == "icon_U.gif" } {
	set imgname icon_UPN.gif
    }
     if { [string match icon_HE* $imgname] } {
	set imgname icon_H.gif
    }
    if { [string match icon_IP* $imgname] } {
	set imgname icon_IP.gif
    }
    if { [string match icon_L* $imgname] } {
	set imgname icon_L.gif
    }
    if { [catch {
	set Images(icon,$datatype) [image create photo -file [file join $dir $imgname]]
    }] } {
	if { ![info exists Images(icon_blank.gif)] } {
	    set Images(icon,blank) [image create photo -file [file join $dir \
		                                                  icon_blank.gif]]
	}
	set Images(icon,$datatype) $Images(icon,blank)
    }
}

proc SteelSections::Init { args } {
    variable DataTypes
    variable CustomSteelSections
    variable Data
    variable Units
    variable Description
    #variable Id
    variable Images
    variable tree
    variable path
    variable IsDataRead

    if { [info exists ::lsdynaPriv(problemtypedir)] } {
	set path $::lsdynaPriv(problemtypedir)
    } else {
	set path $::ProblemTypePriv(problemtypedir)
    }
    if { !$IsDataRead } {
	catch { unset Description Id Units Data }
	set DataTypes ""
	set CustomSteelSections ""
	ReadData [file join $path scripts steelsections.csv]
	ReadData [file join $path scripts steelsections-custom.csv] iscustom
    }
    if { ![info exists tree] || ![winfo exists $tree] } { return }

    foreach i $DataTypes {
	$tree insert end root $i -text $i -open 0 \
		-image [Bitmap::get folder] -drawcross allways -data $i
    }
    Select 1 [lindex $DataTypes 0]
    $tree configure -redraw 1
}

proc SteelSections::TryToCreateNode { node } {
    variable DataTypes
    variable Data
    variable Images
    variable tree

    foreach i $DataTypes {
	foreach j [lsort -command SortIndices [array names Data "$i *"]] {
	    if { $node == [join $j -] } {
		CreateImages $i
		$tree insert end $i [join $j -] -text [lrange $j 1 end] -open 0 \
		    -image $Images(icon,$i)
		return 1
	    }
	}
    }
    return 0
}

proc SteelSections::ModTree { idx node } {
    variable tree
    variable Data
    variable Images

    if { $idx && [$tree itemcget $node -drawcross] == "allways" } {
	set data [$tree itemcget $node -data]
	CreateImages $data
	foreach j [lsort -command SortIndices [array names Data "$data *"]] {
	    $tree insert end $data [join $j -] -text [lrange $j 1 end] -open 0 \
		-image $Images(icon,$data)
	}
	$tree itemconfigure $node -drawcross auto
    }
    if { [llength [$tree nodes $node]] } {
	if { $idx } {
	    $tree itemconfigure $node -image [Bitmap::get openfold]
	} else {
	    $tree itemconfigure $node -image [Bitmap::get folder]
	}
    }
}

proc SteelSections::GiveSelectedValues {} {
    variable tree
    variable material
    variable zposition

    set node [$tree selection get]
    if { [llength $node] != 1 } { return "" }

    if { [$tree itemcget $node -drawcross] == "allways" } {
	# to update non filled nodes
	ModTree 1 $node
	ModTree 0 $node
    }

    if { [$tree nodes $node] != "" } { return "" }
    return [list $node $material $zposition]
}

proc SteelSections::ComunicateWithGiD { op args } {
    variable path

    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar      [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]

	    set f [frame $PARENT.f]
	    if { [info exists ::lsdynaPriv(problemtypedir)] } {
		set path $::lsdynaPriv(problemtypedir)
	    } else {
		set path $::ProblemTypePriv(problemtypedir)
	    }

	    SteelSections::Create $f 

	    # not sure if can be commented
	    #update

	    if { $GDN eq "dict" } {
		foreach i [list steel_section_name steel_material Z_axe_position] {
		    set $i [dict get $STRUCT $i]
		}
	    } else {
		set steel_section_name [DWLocalGetValue $GDN $STRUCT SteelName]
		set steel_material [DWLocalGetValue $GDN $STRUCT SteelType]
		set Z_axe_position [DWLocalGetValue $GDN $STRUCT Z_axe_position]
	    }
	    if { $steel_section_name ne "-" && $steel_section_name ne "" } {
		SteelSections::Select 1 $steel_section_name
	    }
	    if { $steel_material ne "-" && $steel_material ne "" } {
		set SteelSections::material $steel_material
	    }
	    if { $Z_axe_position != 0.0 } {
		set SteelSections::zposition $Z_axe_position
	    }

	    GidHelpRecursive $f [= "Select one steel section and one material here following\
		     the EA-95 regulations. Note that the section will be oriented with its\
		     y axe pointing to the beam local y' axe"]
	    grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
	    grid rowconf $PARENT $ROW -weight 1
	    grid columnconf $PARENT 1 -weight 1
	    return ""
	}
	"SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]

	    foreach "steel_section_name steel_material Z_axe_position" [GiveSelectedValues] break
	    if { ![info exists steel_section_name] || $steel_section_name == "" } {
		return [list ERROR [= "It is necessary to select one steel section"]]
	    } elseif { $GDN eq "dict" } {
		set d ""
		foreach i [list steel_section_name steel_material Z_axe_position] {
		    dict set d $i [set $i]
		}
		return $d
	    } else {
		DWLocalSetValue $GDN $STRUCT SteelName $steel_section_name
		DWLocalSetValue $GDN $STRUCT SteelType $steel_material
		DWLocalSetValue $GDN $STRUCT Z_axe_position $Z_axe_position
	    }
	    return ""
	}
    }
}

proc SteelSections::create_window { wp dict dict_units } {

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Sections library"] \
	    ]
    set f [$w giveframe]

    if { [dict get $dict_units Z_axe_position] ne "cm" } {
	set v [gid_groups_conds::convert_unit_value L \
		[dict get $dict Z_axe_position] \
		[dict get $dict_units Z_axe_position] cm]
	dict set dict Z_axe_position $v
    }

    set row 0
    SteelSections::ComunicateWithGiD INIT $f row dict $dict

    bind $w <Return> [list $w invokeok]
    set action [$w createwindow]
    while 1 {
	if { $action <= 0 } { 
	    destroy $w
	    return ""
	}
	set d [SteelSections::ComunicateWithGiD SYNC dict]
	if { [dict exists $d ERROR] } {
	    snit_messageBox -message [dict get $d ERROR] \
		-parent $w
	} else {
	    destroy $w
	    dict set dict_units Z_axe_position cm
	    return [list $d $dict_units]
	}
	set action [$w waitforwindow]
    }
}

proc SteelSections::give_values_tree {} {
    variable DataTypes
    variable CustomSteelSections
    variable Data
    variable Units
    variable Description
    #variable Id
    variable Images
    variable tree
    variable path
    variable IsDataRead

    if { [info exists ::lsdynaPriv(problemtypedir)] } {
	set path $::lsdynaPriv(problemtypedir)
    } else {
	set path $::ProblemTypePriv(problemtypedir)
    }
    if { !$IsDataRead } {
	catch { unset Description Id Units Data }
	set DataTypes ""
	set CustomSteelSections ""
	ReadData [file join $path scripts steelsections.csv]
	ReadData [file join $path scripts steelsections-custom.csv] iscustom
    }

    set l ""
    foreach i $DataTypes {
	lappend l [list 0 $i $i "" 0]
	CreateImages $i
	foreach j [lsort -command SortIndices [array names Data "$i *"]] {
	    set name [lrange $j 1 end]
	    set fname [join $j -]
	    lappend l [list 1 $name $fname $Images(icon,$i) 1]
	}
    }
    return [join $l ,]
}


#  proc WriteHeader {} {
#      lappend ::auto_path /tcltk/bwidget-1.3.1
#      package require BWidget
#      pack [frame .f]  -fill both -expand 1
#      set SteelSections::path .
#      SteelSections::Create .f
#      SteelSections::WriteCData [file join $SteelSections::path SteelSections.h]
#      exit
#  }

#  proc WriteTextFile {} {
#      lappend ::auto_path /tcltk/bwidget-1.3.1
#      package require BWidget
#      pack [frame .f]  -fill both -expand 1
#      set SteelSections::path .
#      SteelSections::Create .f
#      SteelSections::WriteTxtData [file join $SteelSections::path SteelSections-new.txt]
#      exit
#  }

proc SteelSections::OutputCustomSteelSectionsTable {} {
    variable CustomSteelSections
    variable Data

    set list ""
    set isinit 0
    foreach i [GiD_Info Conditions Steel_section mesh] {
	if  { !$isinit } {
	    Init
	    set isinit 1
	}
	set ct [lindex $i 4]
	if { [lsearch -exact -sorted $CustomSteelSections $ct] != -1 } {
	    lappend list $ct
	}
    }
    set list [lsort -unique $list]

    if { ![llength $list] } { return "" }
    return [OutputCustomSteelSectionsTable_do $list]
}

proc SteelSections::OutputCustomSteelSectionsTable_do { list } {
    variable CustomSteelSections
    variable Data
   
    set _ "steel_sections\n"
    append _ [format "%14s%14s%14s%14s%14s%14s%14s%14s%14s%14s\n" Name A Iy Iz Iyz J \
	    Wy Wz Aty Atz]
    set f "%14s%14.7g%14.7g%14.7g%14.7g%14.7g%14.7g%14.7g%14.7g%14.7g"
    foreach i $list {
	set name [split $i -]
	set auxlist [lrange $Data($name) 0 9]
	set countaux 0
	foreach vali $auxlist {
	    if {$vali == 0.0} {
		set auxlist [lreplace $auxlist $countaux $countaux 1.0]
#                 set vali 1.0
	    }
	    incr countaux
	}
	append _ [eval [list format $f] $auxlist]\n
#         append _ [eval [list format $f] [lrange $Data($name) 0 9]]\n
    }
    append _ "end steel_sections\n"
    return $_
}
    
proc SteelSections::OutputCustomSteelSectionsTable_dom { root } {
    variable CustomSteelSections
    variable Data

    set list ""
    set isinit 0
    set xp {container[@n="Properties"]/container[@n="Beams"]/}
    append xp {condition[@n="Sections_library"]/group}
    foreach gNode [$root selectNodes $xp] {
	if  { !$isinit } {
	    Init
	    set isinit 1
	}
	set Name [$gNode selectNodes {string(value[@n="Name"]/@v)}]
	if { [lsearch -exact -sorted $CustomSteelSections $Name] != -1 } {
	    lappend list $Name
	}
    }
    set list [lsort -unique $list]

    if { ![llength $list] } { return "" }
    return [OutputCustomSteelSectionsTable_do $list]
}





















