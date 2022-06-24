
namespace eval NasComposite {
    
    variable edit_data {
        R0lGODlhGAAYAOMAAAICBK2tmo2NgOXlztXVvzY2MlxcWfLy2///////////
        /////////////////////yH5BAEKAAgALAAAAAAYABgAAAR/EMlJq704awu2
        BkDQeRVIDERBTibhnuPWuugwiLLw7vagfj4XoGcDHGIX46FAMBWHzcxwKQD1
        QIej9GAQDozgrDYJoA3PRzGO8/p+08pstERrFrPxw7x0HaT/R0gUZUR+Ygdf
        GwY2h2JVHlOGWYkreSiCMgRyBpiQep2VoCujEQA7
    }
    variable edit [image create photo -data [set edit_data]]
    
    
    
    variable delete_data {
        R0lGODlhDwAPAKEAAP8AAICAgAAAAP///yH+Dk1hZGUgd2l0aCBHSU1QACH5
        BAEKAAMALAAAAAAPAA8AAAIxnI+AAxDbXJIstnesvlOLj2XWJyzVWEKNYIUi
        wEbu+RnyW4vhmk4p3IOkcqYBsWgqAAA7
    }
    variable delete [image create photo -data [set delete_data]]
    
    variable t
    variable ang 
    variable matlist 
    variable lamlist 
    variable lamindex 
    variable cbdatamat
    variable failure
    variable z0 
    variable stressbon 
    variable tref
    variable damp
    variable nomass
    variable lamadd
    variable lammodify
    variable lamcancel
    variable lamclear
    variable useangle 
    variable numlayers
    variable can
    variable lamtable
    variable gidmatnum
    variable matidlist 
    
}
proc NasComposite::Initvars  { } {
    
    variable t ""
    variable ang ""
    variable matlist ""
    variable lamlist ""
    variable lamindex -1
    variable z0 ""
    variable stressbon ""
    variable tref ""
    variable damp ""
    variable nomass ""
    variable useangle 1 
    variable numlayers 1
    variable failure None
    variable matidlist 
    array unset matidlist
    
}
##############################################################
#Comunitaction with GiD                             #
##############################################################
proc NasComposite::ComunicateWithGiD { op args } {
    variable lamtable
    variable lamlist
    variable failure
    variable z0 
    variable stressbon 
    variable tref
    variable damp
    variable nomass
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set f [frame $PARENT.f]
            NasComposite::InitWindow $f 
            NasComposite::Initvars
            grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
            grid columnconf $f 0 -weight 1
            grid rowconf $f 0 -weight 1
            grid rowconf $PARENT $ROW -weight 1
            grid columnconf $PARENT 0 -weight 1
            upvar \#0 $GDN GidData
            if {  [base64::decode $GidData($STRUCT,VALUE,4)] != "void" } {
                NasComposite::getvalues [base64::decode $GidData($STRUCT,VALUE,3)] \
                    [base64::decode $GidData($STRUCT,VALUE,4)]  [base64::decode $GidData($STRUCT,VALUE,5)] 
            }
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            set aux [base64::encode -wrapchar "" [NasComposite::void_value $lamlist]]
            DWLocalSetValue $GDN $STRUCT "laminate_seq" $aux
            set aux ""
            foreach var {z0 stressbon failure tref damp nomass} {
                lappend aux [NasComposite::void_value [set $var]] 
            }
            set aux [base64::encode -wrapchar "" $aux]
            DWLocalSetValue $GDN $STRUCT "laminate_prop" $aux
            set aux [base64::encode -wrapchar "" [NasComposite::void_value $NasComposite::matlist]]
            DWLocalSetValue $GDN $STRUCT "matlist" $aux
            set aux [base64::encode -wrapchar "" [NasComposite::void_value [NasComposite::nastran]]]
            DWLocalSetValue $GDN $STRUCT "nastran" $aux
            return ""
        }
    }
}
proc NasComposite::void_value { value } {
    switch $value {
        "" {
            return void
        }
        "void" {
            return ""
        }
        default {
            return $value
        }   
    }         
    #     if { $value == "" } {
        #         return void
        #     } else {
        #         return $value
        #     }
}
proc NasComposite::InitWindow { top }  {
    variable cbdatamat
    variable lamadd
    variable lammodify
    variable lamcancel
    variable lamclear
    variable can
    variable lamtable 
    variable values ""
    
    ##############################################################
    #creating the page for laminate information "Laminate"       #
    ##############################################################
    
    set pw [PanedWindow $top.pw -side top ]
    set pane1 [$pw add -weight 1]
    
    set title1 [TitleFrame $pane1.data -relief groove -bd 2 \
            -text [= "Data Entry"] -side left]
    set f1 [$title1 getframe]
    set ldatamat [label $f1.ldatamat -text [= "Material"] -justify left ]
    set cbdatamat [ComboBox $f1.cb -textvariable NasComposite::matname  \
            -values "" -editable 0 -postcommand NasComposite::creatematlist]
    set ldataspin [label $f1.ldataspin -text [= "Number of layers"]: -justify left]
    set spin [SpinBox $f1.spdata -textvariable NasComposite::numlayers \
            -range "1 1000 1" -width 2 -takefocus 1]
    set ldatat [label $f1.ldatat -text [= "Thickness"] -justify left ]
    set edatat [entry $f1.edatat -textvariable NasComposite::t -width 3 \
            -justify left -bd 2 -relief sunken]
    set edataang [entry $f1.edataang -textvariable NasComposite::ang -width 6 \
            -justify left -bd 2 -relief sunken -state normal -bg white]
    set bgcolor [$f1 cget -background]
    set check [checkbutton $f1.chdata -variable NasComposite::useangle \
            -takefocus 0 -text [= "Fiber Angle"]]
    set title11 [TitleFrame $pane1.data1 -relief groove -bd 2 \
            -text [= "Laminate Properties"] -side left]
    set f11 [$title11 getframe]
    set NasComposite::failure None
    set lfailure [label $f11.lfailure -text [= "Failure Theory"] -justify left]
    set cbfailure [ComboBox $f11.cbfailure -textvariable NasComposite::failure  \
            -values [list "None" "Hill" "Hoffman" "Tsai-Wu" "Stress" "Strain"] \
            -editable 0 -width 6]
    set lz0 [Label $f11.lz0 -text [= "Distance Bottom"] \
            -helptext [= "Distance to the reference plane to the bottom surface"] -justify left]
    set ez0 [entry $f11.ez0 -textvariable NasComposite::z0 -width 6 \
            -justify left -bd 2 -relief sunken] 
    set lstressbon [Label $f11.lstressbon -text [= "Allow. Stress Bon."] \
            -helptext [= "Allowable shear stress of the bonding material"] -justify left]
    set estressbon [entry $f11.estressbon -textvariable NasComposite::stressbon -width 6 \
            -justify left -bd 2 -relief sunken] 
    set ltref [Label $f11.ltref -text [= "Temp. Ref"] \
            -helptext [= "It will override values supplied on material entries for individual plies"]. -justify left]
    set etref [entry $f11.etref -textvariable NasComposite::tref -width 6 \
            -justify left -bd 2 -relief sunken] 
    set ldamp [Label $f11.ldamp -text [= "Damping"] \
            -helptext [= "Structural element damping coefficient"]. -justify left]
    set edamp [entry $f11.edamp -textvariable NasComposite::damp -width 6 \
            -justify left -bd 2 -relief sunken] 
    set lnomass [Label $f11.lnomass -text [= "Non Struc./Area"] \
            -helptext [= "Nonstructural mass per unit area"]. -justify left]
    set enomass [entry $f11.enomass -textvariable NasComposite::nomass -width 6 \
            -justify left -bd 2 -relief sunken] 
    NasComposite::update $edataang $bgcolor
    set command "NasComposite::update [list $edataang $bgcolor];#"
    trace variable NasComposite::useangle w $command
    bind $f1.chdata <Destroy> [list trace vdelete NasComposite::useangle w $command]
    
    grid $pw  -sticky nsew 
    grid columnconf $pw  1 -weight 1
    grid rowconf $pw 0 -weight 1
    grid columnconf $pane1  0 -weight 1
    grid rowconf $pane1 2 -weight 1
    grid $title1 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
    grid rowconf $f1 4 -weight 1
    grid columnconf $f1  3 -weight 1
    grid $ldatamat -column 0 -row 0 -sticky nw
    grid $cbdatamat -column 1 -row 0 -columnspan 3 -sticky nwse
    grid $ldataspin -column 0 -row 1 -sticky nw
    grid $spin -column 1 -row 1 -sticky nswe
    grid $ldatat -column 2 -row 1 -sticky nw
    grid $edatat -column 3 -row 1 -sticky nswe
    grid $check -column 0 -row 2 -sticky nw
    grid $edataang -column 1 -row 2 -sticky nw
    grid $title11 -column 0 -row 1 -sticky nsew -padx 2 -pady 2
    grid columnconf $f11 1 -weight 1
    grid columnconf $f11 3 -weight 1
    grid $lfailure -column 0 -row 0 -sticky nw
    grid $cbfailure -column 1 -row 0 -sticky nsew
    grid $lz0 -column 0 -row 1 -sticky nw 
    grid $ez0 -column 1 -row 1 -sticky nsew 
    grid $lstressbon -column 0 -row 2 -sticky nw 
    grid $estressbon -column 1 -row 2 -sticky nsew 
    grid $ltref -column 2 -row 0 -sticky nw 
    grid $etref -column 3 -row 0 -sticky nsew 
    grid $ldamp -column 2 -row 1 -sticky nw 
    grid $edamp -column 3 -row 1 -sticky nsew 
    grid $lnomass -column 2 -row 2 -sticky nw 
    grid $enomass -column 3 -row 2 -sticky nsew 
    set pane2 [$pw add -weight 1]
    set title2 [TitleFrame $pane2.table -relief groove -bd 2 -text [= "Laminate Composition"] \
            -side left ]
    set f2 [$title2 getframe]
    set sw [ScrolledWindow $f2.scroll -scrollbar both ]
    set lamtable [tablelist::tablelist $sw.table \
            -columns [list  0 [= "Material"] 0 [= "Angle"] 0 [= "Thick"] 0 [= "Layers"]] \
            -height 40 -width 30 -stretch all -background white \
            -listvariable NasComposite::lamlist -selectmode extended]
    $sw setwidget $lamtable
    
    set bbox [ButtonBox $f2.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $NasComposite::edit -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Edit layer"] -command "NasComposite::lamedit $lamtable"
    $bbox add -image $NasComposite::delete -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Delete layer"] -command "NasComposite::lamdelete $lamtable $cbdatamat"
    
    set lamadd [button $f1.badd -text [= "Add"]  -underline 1 -width 10 \
            -command "NasComposite::lamadd $lamtable $cbdatamat"]
    set lamclear [button $f1.bclear -text [= "Clear All"] -width 10 -underline 2 \
            -command "NasComposite::lamclear $lamtable"]
    set lammodify [button $f1.bmodify -text [= "Modify"]  -width 10 -underline 1 \
            -command "NasComposite::lamadd $lamtable $cbdatamat"]
    set lamcancel [button $f1.bcancel -text [= "Cancel"]  -width 10 -underline 2 \
            -command "NasComposite::lamcancel $lamtable $cbdatamat"]
    bind $lamadd <ButtonRelease> {
        if { $NasComposite::matname == "" } {
            WarnWin [= "Select a material"]
            catch { vwait $NasComposite::matname }
        }
        if { $NasComposite::useangle == 0 } { 
            set NasComposite::values "2 $NasComposite::t " 
            NasComposite::errorcntrl $NasComposite::values $NasComposite::can
        } else {
            set NasComposite::values "3 $NasComposite::t  $NasComposite::ang" 
            NasComposite::errorcntrl $NasComposite::values $NasComposite::can
        }
    }
    grid $lamadd -column 0 -row 3 -padx 6 -pady 6 -columnspan 2
    grid $lamclear -column 2 -row 3 -columnspan 2 -pady 6 -sticky nw
    grid $lammodify -column 0 -row 3 -columnspan 2 -pady 6 -sticky nw -padx 6
    grid $lamcancel -column 2 -row 3 -columnspan 2 -pady 6 -sticky nw
    grid remove $lammodify
    grid remove $lamcancel
    bind $top <Alt-KeyPress-d> "tkButtonInvoke $lamadd"                
    bind $top <Alt-KeyPress-o> "tkButtonInvoke $lammodify"
    bind $top <Alt-KeyPress-n> "tkButtonInvoke $lamcancel"
    bind $top <Alt-KeyPress-e> "tkButtonInvoke $lamclear"  
    bind [$lamtable bodypath] <Double-ButtonPress-1> { NasComposite:::lamedit $NasComposite:::lamtable }
    bind [$lamtable bodypath] <ButtonPress-3> "NasComposite::popupmenu $lamtable %X %Y"         
    
    grid columnconf $pane2  0 -weight 1
    grid rowconf $pane2 0 -weight 1
    grid columnconf $pane2  0 -weight 1
    
    grid $title2 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $f2  0 -weight 1
    grid rowconf $f2 0 -weight 1
    
    
    grid $sw -column 0 -row 0 -sticky nsew
    grid $bbox -column 0 -row 1 -sticky nw
    ##############################################################
    #creating canvas                                             #
    ##############################################################
    set title3 [TitleFrame $pane1.canvas -relief groove -bd 2 -text [= "Visual Description"] \
            -side left ]
    set f3 [$title3 getframe]
    set can [canvas $f3.can -relief flat -bd 1 -width 300 -height 100 -bg white \
            -highlightbackground black]
    grid $title3 -column 0 -row 2 -sticky nsew
    grid columnconf $f3 0 -weight 1
    grid rowconf $f3 0 -weight 1
    grid $can -column 0 -row 0 -sticky nsew
    bind $can <Configure> "NasComposite::refresh $can"
}                
##############################################################
#           Delete a row intro tablelist of laminate         #
##############################################################
proc NasComposite::lamdelete { table widget} {
    variable can
    variable matlist
    
    set entry [$table curselection]
    set mataux [lindex [$table get $entry] 0]
    if { $entry != "" } {
        $table delete [lindex $entry 0] [lindex $entry end]
        $table see [lindex $entry 0]
    }  
    set matlistaux ""
    foreach mat $matlist {
        if { $mat != $mataux } {
            lappend matlistaux $mat
        }
    }
    set matlist $matlistaux
    eval [NasComposite::refresh $can ]
    focus $widget
}
##############################################################
#         Dump result intro tablelist of laminate            #
##############################################################
proc NasComposite::lamadd { table entry } {
    variable matlist 
    variable t         
    variable ang         
    variable matname         
    variable numlayers  
    variable useangle
    variable lamindex
    variable can   
    if { $lamindex == -1 } {
        if { $useangle == 1 } {
            set t [expr double($t)]
            set ang [expr double($ang)]
            $table insert end "{$matname} [format %5.2f $ang] [format %5.3f $t] \
                $numlayers"
        } else {  
            set t [expr double($t)]
            $table insert end "{$matname} undef [format %5.3f $t] \
                $numlayers"
        }
        if { [lsearch $matlist "$matname"]==-1} {
            lappend matlist "$matname"
        }
        $table see end
    } 
    if { $lamindex != -1 } {
        $table delete $lamindex
        if { $useangle == 1 } {
            set t [expr double($t)]
            set ang [expr double($ang)]
            $table insert $lamindex "{$matname} [format %5.2f $ang] [format %5.3f $t] \
                $numlayers"
            
        } else {  
            set t [expr double($t)]
            $table insert $lamindex "{$matname} undef [format %5.3f $t] \
                $numlayers"
            
        }
        if { [lsearch $matlist "$matname"]==-1} {
            lappend matlist "$matname"
        }
        $table see $lamindex
        set lamindex -1
        #         set t ""        
        #         set ang ""        
        #         set matname ""        
        #         set numlayers 1
        #        eval [NasComposite::refresh $can ]
        #        focus $entry
        grid remove $NasComposite::lammodify
        grid remove $NasComposite::lamcancel
        grid $NasComposite::lamadd
        grid $NasComposite::lamclear
    }
    set t ""        
    set ang ""        
    set matname ""        
    set numlayers 1
    eval [NasComposite::refresh $can ]
    focus $entry
}                
##############################################################
#       Edit a row into tabellist of laminate                #
##############################################################
proc NasComposite::lamedit { table } {
    variable matname          
    variable t         
    variable ang         
    variable numlayers         
    variable useangle         
    variable lamindex    
    set lamindex [$table curselection]
    if { $lamindex != "" } {
        set entry [$table get $lamindex]
        set matname [lindex $entry 0]
        set t [lindex $entry 2]
        set ang [lindex $entry 1]
        set numlayers [lindex $entry 3]
        grid $NasComposite::lammodify
        grid $NasComposite::lamcancel
        grid remove $NasComposite::lamadd
        grid remove $NasComposite::lamclear
    }
} 
##############################################################
#        Cancel edit process into tablelist laminate         #
##############################################################
proc NasComposite::lamcancel { table entry } {
    variable matname
    variable t         
    variable ang         
    variable numlayers         
    variable useangle         
    variable lamindex         
    
    $table see end
    set matname ""
    set t ""        
    set ang ""        
    set numlayers 1        
    set lamindex -1
    set useangle 1
    grid remove $NasComposite::lammodify
    grid remove $NasComposite::lamcancel 
    grid $NasComposite::lamadd
    grid $NasComposite::lamclear
    focus $entry
}
##############################################################
#              update Fiber angle entry                      #
##############################################################
proc NasComposite::update { entry bgcolor } {
    variable useangle         
    
    if { $useangle == 1 } {
        $entry configure -bg white -state normal
    } else {
        $entry configure -bg $bgcolor -state disabled
    }
}
##############################################################
#               Clear all values into laminate page          #
##############################################################
proc NasComposite::lamclear { table } {
    variable can
    variable stressbon ""
    variable z0 ""
    variable failure None
    $table delete 0 end
    eval [NasComposite::refresh $can]
}
##############################################################
#          Draw visual description of sandwich               #
##############################################################
proc NasComposite::refresh { can } {
    variable lamlist       
    variable matlist 
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set y [expr $y-16.0]
    set thick ""
    set t 0
    set matnames ""
    set ipos 0
    set aux ""
    set lamcolors ""
    set colors "moccasin green blue yellow pink gold azure orange violet \
        brown darkgreen darkblue red cyan magenta DeepPink gray firebrick honeydew \
        HotPink ivory IndianRed khaki lavender LawnGreen LightSalmon LightSeaGreen \
        linen maroon MistyRose navy PaleGoldenrod peru plum purple SeaGreen SkyBlue \
        thistle tomato turquoise wheat YellowGreen"
    if { $matlist == "void"} { 
        return 
    }
    foreach mat $matlist {
        lappend aux $mat
        lappend aux [lindex $colors $ipos]
        set ipos [expr $ipos+1]
    }
    array set matcolors $aux
    foreach mat $lamlist {
        set numlayer [lindex $mat 3]
        set t [expr $t+[lindex $mat 2]*$numlayer]
        if { $numlayer > 0 } {
            for { set j 0 } { $j < $numlayer } { incr j } {
                lappend thick [lindex $mat 2]
                lappend matnames [lindex $mat 0]
                lappend lamcolors $matcolors([lindex $mat 0])
            }
        }
    }
    set yi 8.0
    set ipos 0
    foreach ti $thick {
        lappend yi [expr [lindex $yi $ipos]+($y*$ti)/$t]
        set ipos [expr $ipos+1]
    }
    
    set x0 25.0
    set x1 [expr $x-125.0]
    
    set n [expr [llength $yi]-1]
    for { set i 0 } { $i < $n } {incr i 1 } {
        $can create rectangle $x0 [lindex $yi $i] $x1 [lindex $yi [expr $i+1]] \
            -fill [lindex $lamcolors $i]
    }
    if { $lamlist == "" } {
        $can delete all
    } else {
        set yleg [font metrics current -linespace]
        set xleg [expr $x1+8] 
        set ipos 0
        foreach mat $matlist {
            $can create rectangle $xleg [expr [lindex $yi 0]+$ipos*$yleg] [expr $xleg+10] \
                [expr [lindex $yi 0]+($ipos+1)*$yleg] -fill $matcolors($mat)
            $can create text [expr $xleg+14] [expr [lindex $yi 0]+$ipos*$yleg] \
                -text $mat -justify right -anchor nw
            set ipos [expr $ipos+1] 
        }
    }    
}
proc NasComposite::errorcntrl { values window} {
    set message ""
    if {[llength $values] != [lindex $values 0]  } {
        set message [= "Some entries are blank. Please check for errors"]
    }
    set values [string range $values 1 end]
    foreach elem $values {
        if { ! [string is double -strict $elem ] } {
            append message [= "%s is not a valid input" $elem]\n
        }
    }
    if  { $message != "" } {
        WarnWin $message $window
        #tk_messageBox -message $message -type ok        
        return 1
    }
    return 0
}
##############################################################
#      Create list of availble materilas in ComboBox        #
##############################################################
proc NasComposite::creatematlist {  } {
    variable cbdatamat 
    set materials ""
    foreach mat [GiD_Info materials] {
        if { [GiD_Info materials $mat BOOK]=="Material" } {
            lappend materials [DWUnder2Space $mat]
        }
    }
    $cbdatamat configure -values $materials
}
##############################################################################
#   Comunication with GiD: get the values of sandwich to show intro window    #
##############################################################################
proc NasComposite::getvalues { prop values mat} {
    variable lamlist
    variable matlist
    variable can
    variable z0
    variable stressbon
    variable failure
    variable tref
    variable damp
    variable nomass
    
    set z0 [NasComposite::void_value [lindex $prop 0]]
    set stressbon [NasComposite::void_value [lindex $prop 1]]
    set failure [NasComposite::void_value [lindex $prop 2]]
    set tref [NasComposite::void_value [lindex $prop 3]]
    set damp [NasComposite::void_value [lindex $prop 4]]
    set nomass [NasComposite::void_value [lindex $prop 5]]
    
    set lamlist $values
    set matlist $mat
    eval [NasComposite::refresh $can]
} 
##############################################################################
#   Nastran.bas : dump the values of sandwich to nastran file in mat file    #
##############################################################################
proc NasComposite::nastran { } {
    variable lamlist
    variable z0
    variable stressbon
    variable failure
    variable tref
    variable damp
    variable nomass
    
    if {$lamlist == "void"} {
        return void
    } else {
        set values ""
        set numlayer 0
        foreach layer $lamlist {
            set numlayer [expr $numlayer+[lindex $layer 3]]
        }
        
        switch $failure {
            "None" {
                set failureaux void
            }
            "Hill" {
                set failureaux HILL
            }
            "Hoffman" {
                set failureaux HOFF
            }
            "Tsai-Wu" {
                set failureaux TSAI
            }
            "Stress" {
                set failureaux STRESS
            }
            "Strain" {
                set failureaux STRAIN
            }
        }
        lappend values $numlayer [NasComposite::void_value $z0] [NasComposite::void_value $nomass] \
            [NasComposite::void_value $stressbon] "[NasComposite::void_value $failureaux]" [NasComposite::void_value $tref] \
            [NasComposite::void_value $damp]
        foreach layer $lamlist {
            for { set i 1 } { $i <= [lindex $layer 3] } { incr i } {
                lappend values [DWSpace2Under [lindex $layer 0]] [lindex $layer 2] [lindex $layer 1] YES
            }
        }
        return $values
    }
}

##############################################################################
#   Nastran.bas : get the ID of the composite material use in .bas file    #
##############################################################################
proc NasComposite::getmatnum { input } {
    variable gidmatnum
    set gidmatnum $input
    return ""
}

##############################################################################
#   Nastran.bas : write Nastran output    #
##############################################################################

proc NasComposite::writenastran { input} {
    
    variable gidmatnum
    variable matidlist
    
    set input [base64::decode $input]
    set gendata [ lrange [ GiD_Info gendata ] 1 end ]
    foreach { name value } $gendata {
        if { [regexp Format_File* $name] } {
            set format $value
            break
        }
    }
    set layout [list \
            1 1 1 1 1 1 1 0 ]
    set type [list \
            i r r r c r r 0]
    set values $gidmatnum
    append values " [lrange $input 1 end]"
    foreach name [array names matidlist] {
        set indexs [lsearch -all $values $name]
        if {  $indexs!=-1} {
            foreach index $indexs {
                set values [lreplace $values $index $index $matidlist($name)]
            }
        }
    }
    
    set numlayers [lindex $input 0]
    for {set i 1} {$i<=$numlayers} {incr i} {
        lappend layout 1 1 1 1
        lappend type i r r c
    }
    set result [NasComposite::writecard $format PCOMP $layout $type $values]
    return $result
    
}
##############################################################################
#   Nastran.bas : Write in the bas the materials use in the laminate     #
##############################################################################
proc NasComposite::writemats { matnames } {
    variable matidlist
    
    set matnames [base64::decode $matnames]
    set output ""
    foreach name $matnames {
        set name [DWSpace2Under $name]
        if { ![info exists matidlist($name)] } { 
            set matid [expr $BasWriter::currentmatid+1]
            set BasWriter::currentmatid $matid
            BasWriter::getmatnum $matid
            append output [BasWriter::matnastran $name]\n
            set matidlist($name) $matid
        }
    }
    return $output
}
proc NasComposite::writecard {format card layout type values} {
    
    if {$format=="Small" } {
        set card [string trim $card]
        set card_length [string length $card]
        set tofill [expr 8-$card_length ]
        for {set i 1} {$i<=$tofill} {incr i} {
            append card " "
        }
        set output $card
        set card [string trim $card]
        set statment_num 1
        set line_num 1
        foreach statment $layout {
            if {$statment==1} {
                append output  [nasmat_orthotropicshell::outputformat [lindex $values 0]  s [lindex $type 0]]
                set values [lrange $values 1 end]
                set type [lrange $type 1 end]
            } else {
                append output "        "
                set type [lrange $type 1 end]
            }
            if { $statment_num==8 && $values != ""} {
                append output "+\n+       "
                incr line_num
                set statment_num 0
            }
            incr statment_num
        }
    } else {
        set card [string trim $card]
        append card *
        set card_length [string length $card]
        set tofill [expr 8-$card_length ]
        for {set i 1} {$i<=$tofill} {incr i} {
            append card " "
        }
        set output $card
        set card [string trim $card]
        set statment_num 1         
        set line_num 1
        foreach statment $layout {
            if {$statment==1} {
                append output  [nasmat_orthotropicshell::outputformat [lindex $values 0]  l [lindex $type 0]]
                set values [lrange $values 1 end] 
                set type [lrange $type 1 end]
            } else {
                append output "                "
            }
            if { $statment_num==4 && $values != ""} {
                append output "*\n*       "
                incr line_num
                set statment_num 0
            }
            incr statment_num
        }
    }
    return "$output"
}
proc NasComposite::outputformat { value formattype numbertype} { 
    
    if { $formattype == "s" } {
        set freal %#8.5g
        set fint %8i
        set blank "        "
    } else {
        set freal %#16.6g
        set fint %16i
        set blank "                "
    }
    switch $numbertype {
        "i" {
            if { [string is integer -strict [string trim $value]] } {
                set output [format $fint $value ]
            } else {
                set output "$blank"
            }
        }
        "r" {
            if { [string is double -strict [string trim $value]] } {
                set output [GiD_FormatReal $freal $value forcewidthnastran]
            } else {
                set output "$blank"
            }
        } 
        "c" {
            if { $formattype == "s" } {
                set output [format %8s $value]
            } else {
                set output [format %16s $value]
            }
        }
    }
    return $output
}

##############################################################################
#   
# 
#                              Pop up menu of laminate table    #
# 
# 
# #############################################################################

proc NasComposite::popupmenu { parent x y } {
    variable lamtable 
    catch { destroy $parent.menu }
    set menu [menu $parent.menu -type normal ]
    $menu add command -label Paste -command NasComposite::poppaste
    $menu add command -label Sym+Paste -command NasComposite::popsympaste
    $menu add command -label Delete -command "NasComposite::lamdelete $lamtable {}"
    tk_popup $menu $x $y
    
} 

proc NasComposite::poppaste { } {
    variable lamtable 
    variable can
    set indexs [$lamtable curselection ]
    foreach index $indexs {
        $lamtable insert end [$lamtable get $index]
    }
    NasComposite::refresh $can
}

proc NasComposite::popsympaste { } {
    variable lamtable 
    variable can
    set indexs ""
    for { set i [expr [llength [$lamtable curselection ]]-1] } { $i >=0 } { incr i -1} {
        lappend indexs [ lindex [$lamtable curselection ] $i]
    }  
    foreach index $indexs {
        $lamtable insert end [$lamtable get $index]
    }
    NasComposite::refresh $can
}
