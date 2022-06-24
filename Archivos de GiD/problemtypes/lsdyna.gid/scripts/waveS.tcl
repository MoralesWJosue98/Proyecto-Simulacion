
package require ncgi

namespace eval wave {
    variable wavetype [= "Sinusoidal"]
    variable can ""
    variable length 0.0
    variable ampl 0.0
    variable xmax ""
    variable phase 0.0
    variable emer ""
    variable heel ""
    variable trim ""
    variable pi 3.1416
    variable buoyc ""
    variable activ 0
    variable refpoint 
    variable shiplength 0.0
    variable XW ""
    variable ZW ""
    variable stern 
    variable sag 0
    variable hog 0
    variable flag 0
    variable refunits ""
    variable ref0 ""
    variable ref1 ""
    variable ref2 ""
    variable st0 ""
    variable st1 ""
    variable st2 ""
    variable waveBendMomTotX 0.0
    variable waveResForceTotX 0.0
    variable waveBendMomTotY 0.0
    variable waveResForceTotY 0.0
    variable waveBendMomTotZ 0.0 
    variable waveResForceTotZ 0.0
    variable NumList ""
    variable PressList ""
    variable FpXList ""
    variable FpYList ""
    variable FpZList ""
    variable MpXList ""
    variable MpYList ""
    variable MpZList ""
    variable var
    variable units
    variable tclDataWave
    variable f
    variable doc
    variable progress


}


proc wave::Init { frame args } {
    variable wavetype [= "Sinusoidal"]
    variable can ""
    variable phase ""
    variable emer ""
    variable heel ""
    variable trim ""
    variable length 0.0
    variable ampl 0.0
    variable pi 3.1416
    variable buoyc ""
    variable activ ""
#     variable path 
    variable shiplength 0.0 
    variable refpoint {0.0 0.0 0.0} 
    variable stern {0.0 0.0 0.0} 
    variable flag 0
    variable refunits
    variable ref0 
    variable ref1 
    variable ref2 
    variable st0 
    variable st1 
    variable st2 
    variable waveBendMomTotX
    variable waveResForceTotX
    variable waveBendMomTotY
    variable waveResForceTotY
    variable waveBendMomTotZ
    variable waveResForceTotZ
    variable NumList ""
    variable PressList ""
    variable FpXList ""
    variable FpYList ""
    variable FpZList ""
    variable MpXList ""
    variable MpYList ""
    variable MpZList ""
    variable var

    variable w
       
    set f0 [frame $frame.f0 -borderwidth 2 -relief groove]
    set f00 [frame $frame.f00 -borderwidth 2 -relief groove]
    set ffmom [frame $frame.ffmom -borderwidth 2 -relief groove]

    set f1 [labelframe $f00.f1 -text [= "Wave Profile"] -borderwidth 2 -relief groove]
    set lbl1 [label $f1.lbl1 -text [= "Select profile"] -relief flat]
    set listprofile [list [= "Sinusoidal"] [= "Trochoidal"]]
    set cbprofile [ComboBox $f1.cbprofile \
            -textvariable wave::wavetype \
            -editable no -values $listprofile]
    $cbprofile configure -modifycmd "wave::profile"
  
    
    set fMom [labelframe $ffmom.fMom -text [= "Bending Moment Calculation"] -borderwidth 2 -relief groove]
    set lbMom [label $fMom.lbMom -text [= "Moment (N/m)"] -relief flat]
    set eMomX [entry $fMom.eMomX -state readonly -readonlybackground white -textvariable wave::waveBendMomTotX -width 12]
    set eMomY [entry $fMom.eMomY -state readonly -readonlybackground white -textvariable wave::waveBendMomTotY -width 12]
    set eMomZ [entry $fMom.eMomZ -state readonly -readonlybackground white -textvariable wave::waveBendMomTotZ -width 12]
#     set lbuMom [label $fMom.lbuMom -text [= "N.m"] -relief flat]
    set lbRes [label $fMom.lbRes -text [= "Resultant (N)"] -relief flat]
    set eResX [entry $fMom.eResX -state readonly -readonlybackground white -textvariable wave::waveResForceTotX -width 12]
    set eResY [entry $fMom.eResY -state readonly -readonlybackground white -textvariable wave::waveResForceTotY -width 12]
    set eResZ [entry $fMom.eResZ -state readonly -readonlybackground white -textvariable wave::waveResForceTotZ -width 12]
#     set lbuRes [label $fMom.lbuRes -text [= "N"] -relief flat]
    set momCalcB [Button $fMom.momCalcB -text [= "Calculate"] -helptext [= "Calculates Bending Moment\nreffered to \
                the first chosen point (X1),\nand the hydrostatic pressure forces resultant in that point"]]
    set printResB [Button $fMom.printResB -text [= "WriteResFile"] -helptext [= "Writes a GiD postprocess file \
                for wave pressures visualization on the hull.\nThe file is written in the same \
                path of the GiD model.\nAttention: the file name coincides with the calculation \
                result file,\nso in a previous calculation has been performed, you should rename \
                this file,\nto avoid overwritting."]]

    $momCalcB configure -command "wave::WavePreCalc $eMomX $eResX $eMomY $eResY $eMomZ $eResZ $momCalcB $printResB $frame" \
        -relief raised -overrelief raised
    $printResB configure -command "wave::WavePrintResults $momCalcB $printResB $frame" -relief raised -overrelief raised
    
    set f2 [labelframe $f0.f2 -text [= "Wave data"] -borderwidth 2 -relief groove]
    set lb21p [label $f2.e21p -text [= "Initial estimation"] -relief sunken]
    set lb21 [label $f2.lb21 -text [= "Emergence"] -relief flat]
    set e21 [entry $f2.e21 -relief sunken -width 4 -textvariable wave::emer]
    set lblu21 [label $f2.lblu21 -text "(m)" -relief flat]    
   
    set lb22 [label $f2.lb22 -text [= "Heel angle"] -relief flat]
    set e22 [entry $f2.e22 -relief sunken -width 4 -textvariable wave::heel]
    set lblu22 [label $f2.lblu22 -text "(rad)" -relief flat]    
    
   
    GidHelpRecursive $e22 [= "The values may be inserted as an expression of the kind:"] \
        [= " (\$pi*   ) or (\$pi/   ). Max value-->5*pi/18"]  

    set lb23 [label $f2.lb23 -text [= "Trim angle"] -relief flat]
    set e23 [entry $f2.e23 -relief sunken -width 4 -textvariable wave::trim]
    set lblu23 [label $f2.lblu23 -text "(rad)" -relief flat]    

    GidHelpRecursive $e23 [= "The values may be inserted as an expression of the kind:"] \
        [= " (\$pi*   ) or (\$pi/   ). Max value-->pi/18"]  

    set lb24 [label $f2.lb24 -text [= "Buoyancy center"] -relief flat]
    set e24 [entry $f2.e24 -relief sunken -width 4 -textvariable wave::buoyc]
    set lblu24 [label $f2.lblu24 -text "(m)" -relief flat]    

    set initb [button $f2.initb -text [= "Activate"] ]
    $initb configure -command "wave::rbsel $e21 $e22 $e23 $e24 $initb"

    set lb31p [label $f2.lb31p -text [= ""] -relief flat]
    set lb31 [label $f2.lb31 -text [= "Amplitude"] -relief flat]
    set e31 [Entry $f2.e31 -relief sunken -width 4 -textvariable wave::ampl \
            -helptext [= "Half the wave effective heigth (H/2)"] -width 8 ]
    set lblu31 [label $f2.lblu31 -text "(m)" -relief flat]    
   
    set lb32 [label $f2.lb32 -text [= "Length"] -relief flat]
    set e32 [entry $f2.e32 -relief sunken -width 4 -textvariable wave::length]
    set lblu32 [label $f2.lblu32 -text "(m)" -relief flat]    
    
    set lb33 [label $f2.lb33 -text [= "Phase angle"] -relief flat]
    set e33 [Entry $f2.e33 -relief sunken -width 4 -textvariable wave::phase \
            -helptext [= "Relative longitudinal position ship-wave.Right click for info"] -width 8]
    set lblu33 [label $f2.lblu33 -text "(rad)" -relief flat]  
    
    set lb55 [label $f2.lb55 -text [= "Ship Length"] -relief flat]
    set e55 [entry $f2.e55 -relief sunken -width 4 -textvariable wave::shiplength]
    set lblu55 [label $f2.lblu55 -text "(m)" -relief flat]      

    set lb44 [label $f2.lb44 -text [= "Reference point"] -relief flat]
    set e44 [label $f2.e44 -relief sunken ]    
    set seleccb [button $f2.seleccb -text [= "Select"] ]
    $seleccb configure -command "wave::seleccb $e44"
    set lblu44 [label $f2.lblu44 -text "Ref. height" -relief flat]    
  

    set bgcolor [$f2 cget -background]
   
    set f4 [frame $frame.f4 -borderwidth 2 -relief groove]
    set messb [label $f4.messb -textvar mensaje -relief sunken -width 10 ]
    
    set f5 [frame $frame.f5 -borderwidth 2 -relief groove]
    set can [canvas $f1.can -relief sunken -bd 2 -width 200\
            -height 150 -bg white]
 
    set f6 [labelframe $f0.f6 -text [= "Ship-wave reference"] -borderwidth 2 -relief groove]
    set labx1 [label $f6.labx1 -text [= "X1"] -relief flat ]
    set laby1 [label $f6.laby1 -text [= "Y1"] -relief flat ]
    set labz1 [label $f6.labz1 -text [= "Z1"] -relief flat ]
    
    set ref0 [lindex $refpoint 0] 
    set ref1 [lindex $refpoint 1] 
    set ref2 [lindex $refpoint 2] 
    set ex1 [entry $f6.ex1 -relief sunken -width 8 -textvariable wave::ref0]
    set ey1 [entry $f6.ey1 -relief sunken -width 8 -textvariable wave::ref1]
    set ez1 [entry $f6.ez1 -relief sunken -width 8 -textvariable wave::ref2]
    set pk1 [Button $f6.pk1 -text [= "Pick"] -helptext [= "First reference point. Right click for help"]]
    $pk1 configure -command "wave::pick1"
  
    set st0 [lindex $stern 0] 
    set st1 [lindex $stern 1] 
    set st2 [lindex $stern 2] 
    set labx2 [label $f6.labx2 -text [= "X2"] -relief flat ]
    set laby2 [label $f6.laby2 -text [= "Y2"] -relief flat ]
    set labz2 [label $f6.labz2 -text [= "Z2"] -relief flat ]
    set ex2 [entry $f6.ex2 -relief sunken -width 8 -textvariable wave::st0]
    set ey2 [entry $f6.ey2 -relief sunken -width 8 -textvariable wave::st1]
    set ez2 [entry $f6.ez2 -relief sunken -width 8 -textvariable wave::st2]    
    set pk2 [Button $f6.pk2 -text [= "Pick"] -helptext [= "Second reference point."]]
    $pk2 configure -command "wave::pick2"
    

    GidHelpRecursive $seleccb [= "The reference must be a point on the ship�s bow,\n
            \in the intersection between the\ndraught plane and the hull."]  
    GidHelpRecursive $e33 [= "The values may be inserted as an expression\n"] \
        [= "of the kind: (\$pi*   ) or (\$pi/   ). Max value -> pi. Min value -> -pi "]
    GidHelpRecursive $pk1 [= "Indicates the point where the wave will begin."]  
    
    grid $f0 -row 0 -column 0 -sticky news
    grid $f00 -row 1 -column 0 -sticky news
    grid $ffmom -row 2 -column 0 -sticky news

    grid rowconfigure $f0 0 -weight 1
    grid rowconfigure $f00 1 -weight 1
    grid columnconfigure $f0 0 -weight 1
    grid columnconfigure $f0 1 -weight 1
    grid rowconfigure $ffmom 0 -weight 1
    grid columnconfigure $ffmom 0 -weight 1
    
    grid columnconfigure $frame 0 -weight 1
    grid rowconfigure $frame 0 -weight 0
    grid rowconfigure $frame 1 -weight 1

    grid $f1 -row 0 -column 0 -sticky news
    grid columnconf $f1 0 -weight 1
    grid $cbprofile -row 0 -column 0 -sticky news
    grid $can -row 1 -column 0

    grid $fMom -row 0 -column 0 -sticky news
#     grid columnconf $fMom 0 -weight 1
    grid $lbMom -row 0 -column 0 -sticky nws
    grid $eMomX -row 0 -column 1 -sticky e -padx 2 -pady 1
    grid $eMomY -row 0 -column 2 -sticky w -padx 2 -pady 1
    grid $eMomZ -row 0 -column 3 -sticky e -padx 2 -pady 1
#     grid $lbuMom -row 0 -column 2 -sticky ns
    grid $lbRes -row 1 -column 0 -sticky nws
    grid $eResX -row 1 -column 1 -sticky e -padx 2 -pady 1
    grid $eResY -row 1 -column 2 -sticky w -padx 2 -pady 1
    grid $eResZ -row 1 -column 3 -sticky e -padx 2 -pady 1
#     grid $lbuRes -row 1 -column 2 -sticky ns
    grid $momCalcB -row 2 -column 0 -sticky nws
    grid $printResB -row 2 -column 1 -sticky w


    grid $f2 -row 0 -column 0 -sticky news
    grid columnconf $f2 1 -weight 1
    grid $lb31 -row 0 -column 0 -sticky nws
    grid $e31 -row 0 -column 1 -sticky e 
    grid $lblu31 -row 0 -column 2 -sticky e

#     foreach opt {hogging sagging user} {
#         set waveradb [radiobutton $f2.$opt -text [= "$opt"] \
#                 -variable wave::var(wprof) -value $opt \
#                 -command  "wave::_wprof \$wave::var(wprof) $e33"]
#         grid $waveradb    
#     }
    
    set wave::var(wprof) "hogging"
    set waveradbHog [radiobutton $f2.waveradbHog -text [= "Hogging"] \
                -variable wave::var(wprof) -value hogging \
            -command  "wave::_wprof \$wave::var(wprof) $e33"]
    grid $waveradbHog 
    set waveradbSag [radiobutton $f2.waveradbSag -text [= "Sagging"] \
                -variable wave::var(wprof) -value sagging \
            -command  "wave::_wprof \$wave::var(wprof) $e33"]
    grid $waveradbSag 
    set waveradbUser [radiobutton $f2.waveradbUser -text [= "User"] \
            -variable wave::var(wprof) -value user \
            -command  "wave::_wprof \$wave::var(wprof) $e33"]
#     grid $waveradbUser  
    
    #     grid $chksag $userb

    grid $waveradbUser -row 4 -column 0 -sticky nws
    grid $lb33 -row 4 -column 1 -sticky e
    grid $e33 -row 4 -column 2 -sticky w
    grid $lblu33 -row 4 -column 3 -sticky e 

    #     grid configure $e31 $chkhog $chksag $e33 -sticky news
#     grid configure $e31 $waveradb $e33 -sticky news



    grid $f6 -row 0 -column 1 -sticky news
    grid columnconf $f6 1 -weight 0
    grid $labx1 -row 0 -column 0 
    grid $ex1 -row 0 -column 1 
    grid $laby1 -row 1 -column 0 
    grid $ey1 -row 1 -column 1 
    grid $labz1 -row 2 -column 0 
    grid $ez1 -row 2 -column 1 
    grid $pk1 -row 3 -column 0
    grid $labx2 -row 0 -column 2 
    grid $ex2 -row 0 -column 3
    grid $laby2 -row 1 -column 2 
    grid $ey2 -row 1 -column 3
    grid $labz2 -row 2 -column 2 
    grid $ez2 -row 2 -column 3
    grid $pk2 -row 3 -column 2

   

    $e21 configure -state disabled  -relief raised
    $e22 configure -state disabled  -relief raised
    $e23 configure -state disabled  -relief raised
    $e24 configure -state disabled  -relief raised
    $e33 configure -state disabled  -relief raised
    set activ 0

    wave::sin
    #inicializaci�n "un poco m�s correcta"
    set initHog "hogging"
    wave::_wprof $initHog $e33
   

}

proc wave::_wprof { wproff e33} {
    variable phase 
    variable pi 3.1416
    variable wavetype
    variable flag
    
    if {$wproff == "hogging"} {
        set phase $pi
        set flag 1
        $e33 configure -state disabled  -relief raised -background grey
        if {$wavetype == [= "Trochoidal"]} {
            wave::troch
        } elseif {$wavetype == [= "Sinusoidal"]} {
            wave::sin
        } 
    } elseif {$wproff == "sagging"} {
        set phase 0.0
        set flag 1
        $e33 configure -state disabled  -relief raised -background grey
        if {$wavetype == [= "Trochoidal"]} {
            wave::troch
        } elseif {$wavetype == [= "Sinusoidal"]} {
            wave::sin
        } 
    } elseif {$wproff == "user"} {
        set phase ""
        $e33 configure -state normal  -relief sunken -background white
    }
}

proc wave::pick1 { } {
    variable refpoint 
    variable wavetype
    variable ref0 
    variable ref1 
    variable ref2 
    
    variable w

    if {$wavetype == [= "Trochoidal"]} {
        wave::troch
    } elseif {$wavetype == [= "Sinusoidal"]} {
        wave::sin
    }
 

    grab release $w   

    set refpoint [GidUtils::GetCoordinates [= "Enter point coordinates"] Join]
    set ref0 [lindex $refpoint 0]
    set ref1 [lindex $refpoint 1]
    set ref2 [lindex $refpoint 2]

    grab set $w
   
}

proc wave::pick2 { } {
    variable length
    variable refpoint
    variable stern
    variable shiplength
    variable length
    variable st0 
    variable st1 
    variable st2  

    variable w
   
    grab release $w   

    set stern [GidUtils::GetCoordinates [= "Enter point coordinates"] Join]
    set st0 [lindex $stern 0]
    set st1 [lindex $stern 1]
    set st2 [lindex $stern 2]    

    grab set $w

}

proc wave::profile { } {
    variable wavetype 
    variable can 
    variable phase 
    variable emer 
    variable heel 
    variable trim 
    variable length  
    variable ampl 
    variable pi 3.14159265358979323846
    variable flag 0
    
    
    if {$wavetype == [= "Sinusoidal"]} {
        wave::sin 
        return
    } elseif { $wavetype == [= "Trochoidal"] } {
        wave::troch 
        return
    }
}

proc wave::sin {  } {
    variable wavetype 
    variable can
    variable phase 
    variable emer 
    variable heel 
    variable trim 
    variable length 
    variable ampl 
    variable pi 3.1416
    variable flag 
    
    if {$flag != 1 } {
        $can delete all
        set x [ winfo width $can ]
        set y [ winfo height $can ]
        
        set as1 40
        set as2 170
        set bs1 100
        set bs2 50
        $can create rectangle $as1 $bs1 $as2 $bs2 -fill grey
        $can create text $as1 40 -text Pp
        $can create text $as2 40 -text Pr
        $can create line 105 100 105 50
        
       
        set xsin [list 0]
        set ysin [list 0]
        set h [expr 5*$pi/50] 

        for {set i 1 } {$i <= 50 } {incr i 1} {
            set xsini [expr $h*$i]
            set ysini [expr sin($xsini)/2]
            lappend xsin $xsini
            lappend ysin $ysini
        }
        
        for {set i 0 } {$i <= 50 } {incr i 1} { 
            if {$i <= 49} {
                set a1 [expr 10+20*[lindex $xsin $i]]
                set a2 [expr 10+20*[lindex $xsin [expr $i+1]]]
                set b1 [expr 75 - 20*[lindex $ysin $i]]
                set b2 [expr 75 - 20*[lindex $ysin [expr $i+1]]]
                $can create line $a1 $b1 $a2 $b2 -smooth true -fill blue -width 3    
            }
        }
    } else {
        $can delete all
        set as1 40
        set as2 170
        set bs1 100
        set bs2 50
        $can create rectangle $as1 $bs1 $as2 $bs2 -fill grey
        $can create text $as1 40 -text Pp
        $can create text $as2 40 -text Pr
        $can create line 105 100 105 50

        set xsin [list 0]
        set ysin [list 0]
        set h [expr 5*$pi/50]
        for {set i 1 } {$i <= 50 } {incr i 1} {
            set xsini [expr $h*$i ]
            set ysini [expr sin($xsini)/2]
            lappend xsin $xsini
            lappend ysin $ysini
        }
        
        for {set i 0 } {$i <= 50 } {incr i 1} { 
            if {$i <= 49} {
                set a1 [expr 10-20*$wave::phase +20*[lindex $xsin $i]]
                set a2 [expr 10-20*$wave::phase +20*[lindex $xsin [expr $i+1]]]
                set b1 [expr 75 - 20*[lindex $ysin $i]]
                set b2 [expr 75 - 20*[lindex $ysin [expr $i+1]]]
                $can create line $a1 $b1 $a2 $b2 -smooth true -fill blue -width 3    
            }
        }
    }
  
}

proc wave::troch {  } {
    variable wavetype 
    variable can
    variable phase 
    variable emer 
    variable heel 
    variable trim 
    variable length 
    variable ampl 
    variable pi 3.1416
    variable flag 
    
    if {$flag != 1 } {
        $can delete all
        set x [ winfo width $can ]
        set y [ winfo height $can ]
        

        set as1 40
        set as2 170
        set bs1 100
        set bs2 50
        $can create rectangle $as1 $bs1 $as2 $bs2 -fill grey
        $can create text $as1 40 -text Pp
        $can create text $as2 40 -text Pr
        $can create line 105 100 105 50
        

        set ytroc [list 0]
        set xtroc [list 0]
        set h [expr 5*$pi/50] 
        set R 15
        set r 8

        for {set i 1 } {$i <= 50 } {incr i 1} {
            set angtroci [expr $h*$i]
            set xtroci [expr $R*$angtroci-$r*sin($angtroci)]
            set ytroci [expr $R+$r*cos($angtroci)]
            lappend xtroc $xtroci
            lappend ytroc $ytroci
        }    
        for {set i 0 } {$i <= 50 } {incr i 1} { 
            if {$i <= 49} {
                set a1 [expr -36 + [lindex $xtroc $i]]
                set a2 [expr -36 + [lindex $xtroc [expr $i+1]]]
                set b1 [expr 85 - [lindex $ytroc $i]]
                set b2 [expr 85 - [lindex $ytroc [expr $i+1]]]
                $can create line $a1 $b1 $a2 $b2 -smooth true -fill blue -width 3    
            }
        }
    } else {
        $can delete all
        set x [ winfo width $can ]
        set y [ winfo height $can ]
        

        set as1 40
        set as2 170
        set bs1 100
        set bs2 50
        $can create rectangle $as1 $bs1 $as2 $bs2 -fill grey
        $can create text $as1 40 -text Pp
        $can create text $as2 40 -text Pr
        $can create line 105 100 105 50
        

        set ytroc [list 0]
        set xtroc [list 0]
        set h [expr 5*$pi/50] 
        set R 15
        set r 8

        for {set i 1 } {$i <= 50 } {incr i 1} {
            set angtroci [expr $h*$i]
            set xtroci [expr $R*$angtroci-$r*sin($angtroci)]
            set ytroci [expr $R+$r*cos($angtroci)]
            lappend xtroc $xtroci
            lappend ytroc $ytroci
        }    
        for {set i 0 } {$i <= 50 } {incr i 1} { 
            if {$i <= 49} {
                set a1 [expr -36 + $R*$wave::phase+[lindex $xtroc $i]]
                set a2 [expr -36 + $R*$wave::phase+[lindex $xtroc [expr $i+1]]]
                set b1 [expr 85 - [lindex $ytroc $i]]
                set b2 [expr 85 - [lindex $ytroc [expr $i+1]]]
                $can create line $a1 $b1 $a2 $b2 -smooth true -fill blue -width 3    
            }
        }
    }
}

proc wave::rbsel { e21 e22 e23 e24 initb} {
    variable rbvar
    variable activ
  
    if {[info exists rbvar] && $rbvar == 1} {
        set activ 0
        $e21 configure -state disabled  -relief raised -background grey
        $e22 configure -state disabled  -relief raised -background grey
        $e23 configure -state disabled  -relief raised -background grey
        $e24 configure -state disabled  -relief raised -background grey
        $initb configure -text [= "Activate"]        
        set rbvar 0        
        return        
    } else {
        set activ 1
        $e21 configure -state normal  -relief sunken -background white
        $e22 configure -state normal  -relief sunken -background white
        $e23 configure -state normal  -relief sunken -background white
        $e24 configure -state normal  -relief sunken -background white
        $initb configure -text [= "Deactivate"]        
        set rbvar 1
        return
    }  
 
}


proc wave::accept { } {
    variable wavetype
    variable can
    variable phase 
    variable emer 
    variable heel 
    variable trim 
    variable length 
    variable ampl 
    variable pi 3.1416
    variable flag
    variable gizzmo 0
    variable refpoint 
    variable shiplength
    variable XW
    variable ZW
    variable stern
    variable st0
    variable st1
    variable st2
    variable ref0 
    variable ref1 
    variable ref2
        

    set refpoint [list $ref0 $ref1 $ref2]
    set stern [list $st0 $st1 $st2]

    
    set val1 $wave::phase
    set val2 $wave::heel
    set val3 $wave::trim
    
    set xb1 [lindex $refpoint 0]
    set xs1 [lindex $stern 0]
  
    if {$refpoint != ""} {
        if {$xb1 <= 0 && $xs1 <= 0} {
            set wave::length [expr abs(abs($xb1) - abs($xs1))]
        } elseif {$xb1 <= 0 && $xs1 >= 0} {
            set wave::length [expr abs($xb1) + $xs1]
        } elseif {$xb1 >= 0 && $xs1 <= 0} {
            set wave::length [expr abs($xs1) + $xb1]
        } elseif {$xb1 >= 0 && $xs1 >= 0} {
            set wave::length [expr abs($xb1 - $xs1)]
        }
    }
 
    set wave::shiplength $wave::length
    set Lb $wave::shiplength
    
    if {[regexp {pi} "$val1"]} {
        set val1 [expr $val1]
        set wave::phase $val1
    }

    if {[regexp {pi} "$val2"]} {
        set val2 [expr $val2]
        set wave::heel $val2
    }

    if {[regexp {pi} "$val3"]} {
        set val3 [expr $val3]
        set wave::trim $val3
    }

    ####Control de errores#######

    wave::errorcntrl 
    
    if {$gizzmo == 1 && $wavetype == [= "Sinusoidal"]} {
        set flag 1
        wave::sin
    } elseif {$gizzmo == 1 && $wavetype == [= "Trochoidal"]} {
        set flag 1
        wave::troch
    } elseif {$gizzmo != 1} { 
        return
    }
}

proc wave::errorcntrl { } {
    variable phase 
    variable emer 
    variable heel 
    variable trim 
    variable length 
    variable ampl 
    variable buoyc
    variable pi 3.1416
    variable activ
    variable gizzmo 
    variable refpoint
    variable shiplength 
    variable wavetype
    variable stern
    variable aux1
    variable units
    
 
    set refcontrol $units

    if { $activ==1 } {
        foreach "var description max min" [list $wave::phase "Phase angle" [expr 2*$pi] 0.0 \
                $wave::emer "Emergence" 40 0.0 $wave::heel "Heel angle" [expr 5*$pi/18] 0.0 \
                $wave::trim "Trim angle" [expr $pi/18] 0.0 $wave::shiplength "Length" "" 0.0 \
                $wave::ampl "Amplitude" 50 0.0 $wave::buoyc "Buoyancy center" 50 0.0 ] {
            if {![string is double $var] } {
                WarnWin [= "Please check inserted data. Field \"$description\" seems incorrect."] 
                return 
            }
            if {$max != ""} {
                if {$var < $min || $var > $max} {
                    WarnWin [= "Please check inserted data. Field \"$description\" seems incorrect."] 
                    return 
                }
            } 
            if {$stern == "" || ![string is double $stern]} {
                WarnWin [= "Please insert correct reference point"] 
                return
            }
            if {$refpoint == "" || ![string is double $refpoint]} {
                WarnWin [= "Please insert correct reference point"] 
                return
            }
            if { $refcontrol == "mm" } {
                set unitlength [expr $shiplength*1.0e-3]
            } elseif { $refcontrol == "cm" } {
                set unitlength [expr $shiplength*1.0e-2]
            } else {
                set unitlength $wave::shiplength
            }
            if { $unitlength < [expr 2*$pi*$wave::ampl] && $wavetype == [= "Trochoidal"] } {
                WarnWin [= "Check!Wave length must be bigger than 2 * Pi * Wave Amplitude"]
                return
            }
            if {$wavetype == ""} {
                WarnWin [= "Please choose a type of wave profile"]
                return
            }
        }
    } elseif {$activ==0} {
        foreach "var description max min" [list $wave::phase "Phase angle" [expr 2*$pi] [expr 0] \
                $wave::shiplength "Length" "" 0.0 \
                $wave::ampl "Amplitude" 50 0.0 ] {
            if {![string is double $var] || $var == "" } {
                WarnWin [= "Please check inserted data"] 
                return 
            }
            if {$max != ""} {
                if {$var < $min || $var > $max} {
                    WarnWin [= "Please check inserted data"] 
                    return 
                }
            }
            foreach i [list [lindex $stern 0] [lindex $stern 1] [lindex $stern 2]] {
                if {$i == "" || ![string is double $i]} {
                    WarnWin [= "Please insert correct reference point"] 
                    return
                }
            }
            foreach i [list [lindex $refpoint 0] [lindex $refpoint 1] [lindex $refpoint 2]] {
                if {$i == "" || ![string is double $i]} {
                    WarnWin [= "Please insert correct reference point"] 
                    return
                }
            }
            if {$wave::ampl == ""} {
                WarnWin [= "Please check inserted data"] 
                return
            }
            if { $refcontrol == "mm" } {
                set unitlength [expr $shiplength*1.0e-3]
            } elseif { $refcontrol == "cm" } {
                set unitlength [expr $shiplength*1.0e-2]
            } else {
                set unitlength $wave::shiplength
            }
            if { $unitlength < [expr 2*$pi*$wave::ampl] && $wavetype == [= "Trochoidal"] } {
                WarnWin [= "Check!Wave length must be bigger than 2 * Pi * Wave Amplitude"]
                return
            }
            if {$wavetype == ""} {
                WarnWin [= "Please choose a type of wave profile"]
                return
            }
        }  
    } 
    set gizzmo 1
    return 
}


proc wave::ComunicateWithGiD { op args } {
    variable gizzmo        
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            
            set f [frame $PARENT.f]            
            wave::Init $f $args
            
            set he [DWLocalGetValue $GDN $STRUCT WaveHeel]
            set em [DWLocalGetValue $GDN $STRUCT WaveEmergence]
            set tr [DWLocalGetValue $GDN $STRUCT WaveTrim]
            set buo [DWLocalGetValue $GDN $STRUCT WaveBuoyc]
            set am [DWLocalGetValue $GDN $STRUCT WaveAmplitude]
            set len [DWLocalGetValue $GDN $STRUCT WaveLength]
            set ph [DWLocalGetValue $GDN $STRUCT WavePhase]
            set shlen [DWLocalGetValue $GDN $STRUCT WaveShipLength]
            set refp [DWLocalGetValue $GDN $STRUCT WaveRefpoint]
            set type [DWLocalGetValue $GDN $STRUCT WaveType] 
            set popa [DWLocalGetValue $GDN $STRUCT WaveStern] 
            
            if { $he ne "" } {
                set wave::heel $he
            }
            if { $em ne "" } {
                set wave::emer $em
            }
            if { $tr ne "" } {
                set wave::trim $tr
            }
            if { $buo ne "" } {
                set wave::buoyc $buo
            }            
            if { $am ne "" } {
                set wave::ampl $am
            }
            if { $len ne "" } {
                set wave::length $len
            }
            if { $ph ne "" } {
                set wave::phase $ph
            }
            if { $shlen ne "" } {
                set wave::shiplength $shlen
            }
            if { $refp ne "" } {
                set wave::refpoint $refp
            }
            if { $type ne "" } {
                set wave::wavetype $type
            }
            if { $popa ne "" } {
                set wave::stern $popa
            }
            
            
            grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
            grid rowconf $PARENT $ROW -weight 1
            grid columnconf $PARENT 1 -weight 1
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            
            foreach "he em tr buo am len ph \
                shlen refp type popa" [GiveSelectedValues] break
            
            DWLocalSetValue $GDN $STRUCT WaveHeel $he
            DWLocalSetValue $GDN $STRUCT WaveEmergence $em
            DWLocalSetValue $GDN $STRUCT WaveTrim $tr
            DWLocalSetValue $GDN $STRUCT WaveBuoyc $buo
            
            DWLocalSetValue $GDN $STRUCT WaveAmplitude $am
            DWLocalSetValue $GDN $STRUCT WaveLength $len
            DWLocalSetValue $GDN $STRUCT WavePhase $ph
            DWLocalSetValue $GDN $STRUCT WaveShipLength $shlen 
            DWLocalSetValue $GDN $STRUCT WaveRefpoint $refp 
            DWLocalSetValue $GDN $STRUCT WaveType $type
            DWLocalSetValue $GDN $STRUCT WaveStern $popa
                                    
            return ""
        }
    }
    
}

proc wave::get_valueWave { name } {
    variable doc   
    set file [file join $::lsdynaPriv(problemtypedir) "ramseries_default.spd"]
    set aux1 [tDOM::xmlReadFile $file]
    set doc [dom parse $aux1]
    
    set node [$doc selectNodes [format_xpath {//value[@n=%s]} $name]]
    return [get_domnode_attribute $node v]

}

proc wave::create_window { wp dict dict_units domNode} {
    variable ampl   
    variable length 
    variable refpoint
    variable shiplength
    variable phase 
    variable wavetype
    variable stern
    variable w
    variable f
    variable units
    variable tclDataWave

    set datalist ""

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Wave Loads"]]
    set f [$w giveframe]
    
    set units [wave::get_valueWave units_mesh]   


    Init $f
    
    grid columnconfigure $f 0 -weight 1
    grid rowconfigure $f 0 -weight 1
    
   
    bind $w <Return> [list $w invokeok]
    set action [$w createwindow]
    while 1 {
        if { $action <= 0 } { 
            destroy $w
            return ""
        }
        set dict ""

        accept

        lappend datalist $ampl $phase $length $shiplength $refpoint $stern $wavetype
        set tclDataWave [WriteWaveCustomLoad $datalist]

        dict set dict "WaveTclCode" $tclDataWave
        dict set dict "WaveAmplitude" $ampl
        dict set dict "WavePhase" $phase
        dict set dict "WaveLength" $length
        dict set dict "WaveShipLength" $shiplength
        dict set dict "WaveRefpoint" $refpoint
        dict set dict "WaveStern" $stern
        dict set dict "WaveType" $wavetype
        
        destroy $w
        
        return [list $dict $dict_units]
    }
}


proc wave::GiveSelectedValues {} {

    variable ampl   
    variable emer 
    variable heel 
    variable trim
    variable buoyc
    variable length 
    variable refpoint
    variable shiplength
    variable XW
    variable ZW
    variable phase 
    variable wavetype
    variable stern
    variable gizzmo
    
    set XW ""
    set ZW ""
    
    wave::accept

    
    return [list $heel $emer $trim $buoyc $ampl $length \
            $phase $shiplength $refpoint $wavetype $stern]

}

proc wave::WriteWaveCustomLoad {datalist} {
#     variable bas_custom_waveload
#        
#     array unset bas_custom_waveload
#     set _ ""
#     set matnum [expr {[llength [GiD_Info materials]]+1}]
#     
#     set refunits [GiD_AccessValue get gendata Mesh_units#CB#(m,cm,mm)]
   
    variable units
    
    if { $units == "mm" } {
        set ref 0
    } elseif { $units == "cm" } {
        set ref 1
    } elseif { $units == "m" } {
        set ref 2
    }

#     
#     set data [GiD_Info conditions -interval 2 Wave_Loads mesh]
#     if { ![llength $data] } { return "" }
#     append _ "NavalWaveLoad\n"
#     append _ "custom_data\n"

#     set data $gNode
# 
#     foreach i $data 
#         foreach "- num - WaveHeel WaveEmergence WaveTrim WaveBuoyc WaveAmplitude \
#             WaveLength WavePhase WaveShipLength WaveRefpoint WaveType WaveStern" $i break
     
    set WaveAmplitude [lindex $datalist 0]
    set WavePhase [lindex $datalist 1]
    set WaveLength [lindex $datalist 2]
    set WaveShipLength [lindex $datalist 3]
    set WaveRefpoint [lindex $datalist 4]
    set WaveStern [lindex $datalist 5]
    set WaveType [lindex $datalist 6]


    set flag 1
    set key [list $WaveAmplitude $WaveLength $WavePhase $WaveShipLength $WaveRefpoint $WaveType $WaveStern]
    
    if {$WaveType == [= "Sinusoidal"]} { set WaveType 0 }
    if {$WaveType == [= "Trochoidal"]} { set WaveType 1 }
    
    
    set tcl_code {
        foreach "xmin xmax" [list 1e20 -1e20] break              
        foreach "zmin zmax" [list 1e20 -1e20] break
        for { set i 1 } { $i <= 3 } { incr i } {
            if { coords($i,3) < $zmin } { set zmin [coords $i 3] }              
            if { coords($i,3) > $zmax } { set zmax [coords $i 3] }
            
            if { coords($i,1) < $xmin } { set xmin [coords $i 1] }
            if { coords($i,1) > $xmax } { set xmax [coords $i 1] }
        }
        
        set x_med [expr {.5*($xmin + $xmax)}]
        
        if { $ref == 0 } {
            set x_ref1 [expr 1.0e-3*[lindex $WaveRefpoint 0]]
            set x_ref2 [expr 1.0e-3*[lindex $WaveStern 0]]
            set z_ref [expr 1.0e-3*[lindex $WaveRefpoint 2]]
            set y_ref2 [expr 1.0e-3*[lindex $WaveStern 1]]
            set z_ref2 [expr 1.0e-3*[lindex $WaveStern 2]]
            set y_ref1 [expr 1.0e-3*[lindex $WaveRefpoint 1]]
            set WaveLength [expr 1.0e-3*$WaveLength]
            set WaveShipLength [expr 1.0e-3*$WaveShipLength]
        } elseif { $ref == 1 } {
            set x_ref1 [expr 1.0e-2*[lindex $WaveRefpoint 0]]
            set x_ref2 [expr 1.0e-2*[lindex $WaveStern 0]]
            set y_ref2 [expr 1.0e-2*[lindex $WaveStern 1]]
            set z_ref2 [expr 1.0e-2*[lindex $WaveStern 2]]
            set z_ref [expr 1.0e-2*[lindex $WaveRefpoint 2]]
            set y_ref1 [expr 1.0e-2*[lindex $WaveRefpoint 1]]
            set WaveLength [expr 1.0e-2*$WaveLength]
            set WaveShipLength [expr 1.0e-2*$WaveShipLength]
        } elseif { $ref == 2 } {
            set x_ref1 [lindex $WaveRefpoint 0]
            set x_ref2 [lindex $WaveStern 0]
            set z_ref [lindex $WaveRefpoint 2]
            set y_ref2 [lindex $WaveStern 1]
            set z_ref2 [lindex $WaveStern 2]
            set y_ref1 [lindex $WaveRefpoint 1]
        }
        
        if { $zmin == $zmax && $ref == 0} {
            set zmax [expr $zmax + 1.0e-3]
        } elseif { $zmin == $zmax && $ref == 1} {
            set zmax [expr $zmax + 1.0e-2]
        } elseif { $zmin == $zmax && $ref == 0} {
            set zmax [expr $zmax + 1.0e-1]
        }
        
        if {$x_ref1 > $x_ref2} {
            set x1_aux $x_ref2
            set y1_aux $y_ref2
            set z1_aux $z_ref2
            
            set x_ref2 $x_ref1
            set y_ref2 $y_ref1
            
            set x_ref1 $x1_aux
            set y_ref1 $y1_aux
            set z_ref $z1_aux
        }
        
        set amp $WaveAmplitude
        set pi 3.14159265358979323846
        
        if {$x_ref1 <= 0 && $x_med <= 0} {
            set iX [expr abs(abs($x_ref1) - abs($x_med))]
        } elseif {$x_ref1 <= 0 && $x_med >= 0} {
            set iX [expr abs($x_ref1) + $x_med]
        } elseif {$x_ref1 >= 0 && $x_ref2 <= 0} {
            set iX [expr abs($x_med) + $x_ref1]
        } elseif {$x_ref1 >= 0 && $x_med >= 0} {
            set iX [expr abs($x_ref1 - $x_med)]
        }
        
        if {$x_ref1 <= 0 && $x_ref2 <= 0} {
            set L1 [expr abs(abs($x_ref1) - abs($x_ref2))]
        } elseif {$x_ref1 <= 0 && $x_ref2 >= 0} {
            set L1 [expr abs($x_ref1) + $x_ref2]
        } elseif {$x_ref1 >= 0 && $x_ref2 <= 0} {
            set L1 [expr abs($x_ref2) + $x_ref1]
        } elseif {$x_ref1 >= 0 && $x_ref2 >= 0} {
            set L1 [expr abs($x_ref1 - $x_ref2)]
        }
        
        set Patm 0.0
        set g 9.81
        set rho 1025.0
        set K [expr 2*$pi/$L1]
        set w [expr sqrt($K*$g)]
        set H [expr 2*$amp]
        
        if {$x_med >= [ expr $x_ref1 - $L1/4.0] && $x_med <= [ expr $x_ref2 + $L1/4.0] } {
            if { $WaveType == 0} {
                set z_wave [expr $z_ref + $amp*cos(2*$pi*($x_med-$x_ref1)/$L1 + $WavePhase )]
                
                if { $zmin < $z_wave } {
                    set izmin [expr $zmin - $z_ref]
                    set p_zmin [ expr $Patm - $rho*$g*$izmin + \
                            $rho*$g*$amp*exp($K*$izmin)*cos($K*$iX + $WavePhase) ]              
                } else {
                    set p_zmin $Patm
                }
                if { $zmax < $z_wave } {
                    set izmax [expr $zmax - $z_ref]                          
                    set p_zmax [ expr $Patm - $rho*$g*$izmax + \
                            $rho*$g*$amp*exp($K*$izmax)*cos($K*$iX + $WavePhase) ] 
                } else {
                    set p_zmax $Patm
                }
            } elseif { $WaveType == 1 } {
                
                set R [expr $L1/(2*$pi)]
                set r $WaveAmplitude
                set th [expr $pi/2]
                
                set xph [expr $R*$WavePhase - $r*sin($WavePhase)]
                
                for { set i 1 } { $i <= 1000 } { incr i } {
                    set thh $th
                    set th [expr $th - ($R*$th - $r*sin($th) - \
                            ($x_med - $x_ref1 - $xph))/($R - $r*cos($th))]
                    if { ($th < 0 && $thh < 0) || ($th > 0 && $thh > 0) } {
                        if { [expr abs($th - $thh)] <= 1.0e-4 } { 
                            set th $th
                            break 
                        }
                    }
                }
                
                set z_wave [expr  $z_ref + $r*cos($th)]
                
                if { $zmin < $z_wave } {
                    set izmin [expr $zmin - $z_ref]
                    set p_zmin [ expr $Patm - $rho*$g*$izmin - \
                            0.5*$rho*$amp*$amp*$w*$w*exp(2*$K*$izmin) + \
                            $rho*$g*$amp*exp($K*$izmin)*cos($K*($iX-$xph)) ]              
                } else {
                    set p_zmin $Patm
                }
                if { $zmax < $z_wave } {
                    set izmax [expr $zmax - $z_ref]
                    set p_zmax [ expr $Patm - $rho*$g*$izmax - \
                            0.5*$rho*$amp*$amp*$w*$w*exp(2*$K*$izmax) + \
                            $rho*$g*$amp*exp($K*$izmax)*cos($K*($iX-$xph)) ]
                } else {
                    set p_zmax $Patm
                }
                
            }
            
            set p_aprox [expr 0.5*($p_zmax + $p_zmin)]
            
            if { $zmin != $zmax } {
                addload -local triangular_pressure \
                    [list 0.0 0.0 $p_zmin] [list 0.0 0.0 $p_zmax] \
                    [list 0.0 0.0 $zmin] [list 0.0 0.0 $zmax]
            }
            
        }                                  
    }
    set maplist ""
    
    foreach i [list WaveAmplitude WaveLength WavePhase WaveShipLength WaveRefpoint WaveType WaveStern ref] {
        lappend maplist \$$i [list [set $i]]
    }
    set tcl_code [string map $maplist $tcl_code]
    
    set tcl_code [string trim $tcl_code]
    if { $tcl_code eq "" } { set tcl_code " " }
    
    #         set tcl_code_enc [string map [list %0D ""] [::ncgi::encode $tcl_code]]
    #         set bas_custom_waveload($key) [list $matnum $tcl_code_enc]
       
    





    #     foreach key [array names bas_custom_waveload] {
        #         foreach "matnum tcl_code_enc" $bas_custom_waveload($key) break
        #         append _ "$matnum Units=N-m-kg tcl=$tcl_code_enc name=custom$matnum\n"
        #         incr matnum
        #     }
    #     append _ "end custom_data\n"
    
    #     return $_

    return $tcl_code
    
}

proc wave::WavePreCalc { eMomX eResX eMomY eResY eMomZ eResZ momCalcB printResB frame} {
    variable waveBendMomTotX 0.0
    variable waveResForceTotX 0.0
    variable waveBendMomTotY 0.0 
    variable waveResForceTotY 0.0
    variable waveBendMomTotZ 0.0
    variable waveResForceTotZ 0.0
    variable NumList
    variable PressList
    variable FpXList
    variable FpYList
    variable FpZList
    variable MpXList
    variable MpYList
    variable MpZList
    variable doc
    variable progress

    set progress 0

    set waveBar .gid.waveprogress
    if { [winfo exists $waveBar] } { return }
    ProgressDlg::create .gid.waveprogress -height 2 -width 50 -stop "Stop" -title "Wave Forces Calculation" \
        -variable wave::progress
    if { ![winfo exists $waveBar] } return  
    
    set pBar [ProgressBar $waveBar.pBar -height 2 -maximum 100 -type incremental \
            -variable wave::progress -width 40  -troughcolor grey -bg white -relief raised -orient horizontal]
    
  
    set doc $gid_groups_conds::doc
    set root [$doc documentElement]
          
    set NumList ""
    set PressList ""
    set MpXList ""
    set MpYList ""
    set MpZList ""
    set FpXList ""
    set FpYList ""
    set FpZList ""
    
    set refunits [get_valueWave units_mesh]
    if { $refunits == "mm" } {
        set ref 0
    } elseif { $refunits == "cm" } {
        set ref 1
    } elseif { $refunits == "m" } {
        set ref 2
    }
           
    set flagWave 0
    set flagMeshWave [GiD_MustRemeshFlag get] 

    set xp {container[@n='loadcases']/blockdata[@n='loadcase']/container[@n='Shells']/condition[@n='WaveLoad_shell']/group}
    
    set aux [$root selectNodes $xp]
    if {$aux != ""} {
        set flagWave 1
    }
    if { $flagWave==0 } { 
        tk_messageBox -parent $frame -icon error -type ok -message [= "It is necessary to asign Wave Loads and mesh\nbefore calculating \
                Bending Moment"]
        destroy $waveBar
        return "" 
    } elseif {$flagWave == 1 && $flagMeshWave == 1 } {
        tk_messageBox -parent $frame -icon error -type ok -message [= "Wave Loads have changed since the last meshing.\n\
                It is necessary to asign and remesh again before calculating.\n\
                Asign, re-mesh, and then press again to calculate."]
        destroy $waveBar                
        return ""        
    }
    
      
    $momCalcB configure -state disabled
    $printResB configure -state disabled
    
    $eResX configure -readonlybackground grey -textvariable wave::waveResForceTotX
    $eMomX configure -readonlybackground grey -textvariable wave::waveBendMomTotX
    
    $eResY configure -readonlybackground grey -textvariable wave::waveResForceTotY
    $eMomY configure -readonlybackground grey -textvariable wave::waveBendMomTotY
    
    $eResZ configure -readonlybackground grey -textvariable wave::waveResForceTotZ
    $eMomZ configure -readonlybackground grey -textvariable wave::waveBendMomTotZ
    
    set waveBendMomTot 0.0
    set waveResForceTot 0.0
    set TotalBendMX 0.0
    set TotalResX 0.0
    set TotalBendMY 0.0
    set TotalResY 0.0
    set TotalBendMZ 0.0
    set TotalResZ 0.0
    set TotRES 0.0

    foreach gNode [$root selectNodes $xp] {
        set formats ""
        set elmList ""
        
        dict set formats [$gNode @n] "%d\n"
    }
    set elmList [GiD_WriteCalculationFile elements -return $formats]
    set elmList [split $elmList \n]
    
    set elmListaux ""
    foreach num $elmList { 
        if {$num != ""} {
            lappend elmListaux $num
        }
    }        
    set elmList $elmListaux
    set nProgr [expr 90.0/[llength $elmList]]
    set incrProgr 0
    foreach num $elmList { 
        
        set E1 ""
        set E2 ""
        set E3 ""
        set v_a ""
        set v_b ""
        set v_c ""
        set elemNormal ""
        
        set progress [expr $incrProgr*$nProgr]
        incr incrProgr
        
        set WaveAmplitude [$gNode selectNodes {string(value[@n='WaveAmplitude']/@v)}]
        set WaveShipLength [$gNode selectNodes {string(value[@n='WaveShipLength']/@v)}]
        set WavePhase [$gNode selectNodes {string(value[@n='WavePhase']/@v)}]
        set WaveLength [$gNode selectNodes {string(value[@n='WaveLength']/@v)}]
        set WaveRefpoint [$gNode selectNodes {string(value[@n='WaveRefpoint']/@v)}]
        set WaveType [$gNode selectNodes {string(value[@n='WaveType']/@v)}]
        set WaveStern [$gNode selectNodes {string(value[@n='WaveStern']/@v)}]
        
        set elem [GiD_Info Mesh Elements Triangle $num]
        
        foreach "xmin xmax" [list 1e20 -1e20] break              
        foreach "zmin zmax" [list 1e20 -1e20] break
        
        for { set j 1 } { $j <= 3 } { incr j } {
            set coords [GiD_Info Coordinates [lindex $elem $j] mesh] 
            
            if { [lindex $coords 0 2] < $zmin } { set zmin [lindex $coords 0 2] } 
            if { [lindex $coords 0 2] > $zmax } { set zmax [lindex $coords 0 2] }
            
            if { [lindex $coords 0 0] < $xmin } { set xmin [lindex $coords 0 0] }
            if { [lindex $coords 0 0] > $xmax } { set xmax [lindex $coords 0 0] }
            
            if {$j == 1} {
                lappend E1 [lindex $coords 0 0] [lindex $coords 0 1] [lindex $coords 0 2]
            } elseif {$j == 2} {
                lappend E2 [lindex $coords 0 0] [lindex $coords 0 1] [lindex $coords 0 2]
            } elseif {$j == 3} {
                lappend E3 [lindex $coords 0 0] [lindex $coords 0 1] [lindex $coords 0 2]
            }
        }
        
        lappend v_a [expr [lindex $E2 0] - [lindex $E1 0]] [expr [lindex $E2 1] - [lindex $E1 1]] [expr [lindex $E2 2] - [lindex $E1 2]]
        lappend v_b [expr [lindex $E3 0] - [lindex $E2 0]] [expr [lindex $E3 1] - [lindex $E2 1]] [expr [lindex $E3 2] - [lindex $E2 2]]
        lappend v_c [expr ([lindex $v_b 2]*[lindex $v_a 1] - [lindex $v_b 1]*[lindex $v_a 2])] \
            [expr ([lindex $v_b 0]*[lindex $v_a 2] - [lindex $v_b 2]*[lindex $v_a 0])] \
            [expr ([lindex $v_b 1]*[lindex $v_a 0] - [lindex $v_b 0]*[lindex $v_a 1])]
        
        set v_cModule [expr sqrt([lindex $v_c 0]*[lindex $v_c 0] + \
                [lindex $v_c 1]*[lindex $v_c 1] + [lindex $v_c 2]*[lindex $v_c 2])]
        
        lappend elemNormal [expr [lindex $v_c 0]/$v_cModule] [expr [lindex $v_c 1]/$v_cModule] [expr [lindex $v_c 2]/$v_cModule]
        
        
        set elemProps [GiD_Info ListMassProperties Elements $num]

        if { [GiD_Info GiDVersion] == "8.1.6b" } {
            set elemArea [lindex [GiD_Info ListMassProperties Elements $num] 12]
            set elemArea [split $elemArea =]
            set elemArea [lindex $elemArea 1]
        } else {
            set elemArea [lindex [GiD_Info ListMassProperties Elements $num] 13]
            set elemArea [split $elemArea =]
            set elemArea [lindex $elemArea 1]
        }

        
        #             set elemArea [lindex [regexp -linestop -inline {area=([ 0-9 ].[ 0-9 ]*)} $elemArea] 1]
        set elemXcG [lindex [GiD_Info ListMassProperties Elements $num] 9]
        set elemXcG [lindex [regexp -linestop -inline {center=([ 0-9 ].[ 0-9 ]*)} $elemXcG] 1]
        if {$elemXcG == ""} {
            set elemXcG [lindex [GiD_Info ListMassProperties Elements $num] 9]
            set elemXcG [lindex [regexp -linestop -inline {center=-([ 0-9 ].[ 0-9 ]*)} $elemXcG] 1]
        }
        if {$elemXcG == ""} {
            set elemXcG [lindex [GiD_Info ListMassProperties Elements $num] 9]
            set elemXcG [lindex [regexp -linestop -inline {center=-([ 0-9 ]*)} $elemXcG] 1]
        }
        if {$elemXcG == ""} {
            set elemXcG [lindex [GiD_Info ListMassProperties Elements $num] 9]
            set elemXcG [lindex [regexp -linestop -inline {center=([ 0-9 ]*)} $elemXcG] 1]
        }
        
        set elemYcG [lindex [GiD_Info ListMassProperties Elements $num] 10]
        set elemZcG [lindex [GiD_Info ListMassProperties Elements $num] 11]
        if { [GiD_Info GiDVersion] == "8.1.6b" } {
            set elemZcG [split $elemZcG Total]
            set elemZcG [lindex $elemZcG 0]
        }
        
        #         set x_med [expr {.5*($xmin+$xmax)}]
        set x_med $elemXcG
        
        if { $refunits == "mm" } {
            set zmax [expr $zmax*1.0e-3]
            set zmin [expr $zmin*1.0e-3]
            set x_med [expr 1.0e-3*$x_med]
            set x_ref1 [expr 1.0e-3*[lindex $WaveRefpoint 0]]
            set x_ref2 [expr 1.0e-3*[lindex $WaveStern 0]]
            set y_ref2 [expr 1.0e-3*[lindex $WaveStern 1]]
            set z_ref2 [expr 1.0e-3*[lindex $WaveStern 2]]
            set z_ref [expr 1.0e-3*[lindex $WaveRefpoint 2]]
            set y_ref1 [expr 1.0e-3*[lindex $WaveRefpoint 1]]
            set WaveLength [expr 1.0e-3*$WaveLength]
            set WaveShipLength [expr 1.0e-3*$WaveShipLength]
            set elemArea [expr $elemArea*1.0e-6]
        } elseif { $refunits == "cm" } {
            set zmax [expr $zmax*1.0e-2]
            set zmin [expr $zmin*1.0e-2]
            set x_med [expr 1.0e-2*$x_med]
            set x_ref1 [expr 1.0e-2*[lindex $WaveRefpoint 0]]
            set x_ref2 [expr 1.0e-2*[lindex $WaveStern 0]]
            set y_ref2 [expr 1.0e-2*[lindex $WaveStern 1]]
            set z_ref2 [expr 1.0e-2*[lindex $WaveStern 2]]
            set z_ref [expr 1.0e-2*[lindex $WaveRefpoint 2]]
            set y_ref1 [expr 1.0e-2*[lindex $WaveRefpoint 1]]
            set WaveLength [expr 1.0e-2*$WaveLength]
            set WaveShipLength [expr 1.0e-2*$WaveShipLength]
            set elemArea [expr $elemArea*1.0e-4]
        } else {
            set x_ref1 [lindex $WaveRefpoint 0]
            set x_ref2 [lindex $WaveStern 0]
            set z_ref [lindex $WaveRefpoint 2]
            set y_ref2 [lindex $WaveStern 1]
            set z_ref2 [lindex $WaveStern 2]
            set y_ref1 [lindex $WaveRefpoint 1]
        }
        
        if { $zmin == $zmax && $refunits == "mm"} {
            set zmax [expr $zmax + 1.0e-3]
        } elseif { $zmin == $zmax && $refunits == "cm"} {
            set zmax [expr $zmax + 1.0e-2]
        } elseif { $zmin == $zmax && $refunits == "m"} {
            set zmax [expr $zmax + 1.0e-1]
        }
        
        # Cambio de la referencia, por si el usuario no elige bien los puntos
        if {$x_ref1 > $x_ref2} {
            set x1_aux $x_ref2
            set y1_aux $y_ref2
            set z1_aux $z_ref2
            
            set x_ref2 $x_ref1
            set y_ref2 $y_ref1
            
            set x_ref1 $x1_aux
            set y_ref1 $y1_aux
            set z_ref $z1_aux
        }
        
        if {$x_ref1 == $x_ref2} {
            tk_messageBox -parent $frame -icon error -type ok -message [= "Reference points not correctly chosen.\nPlease \
                    verify that the hull�s long. simmetry plane coincides with GiD�s XZ reference plane"]
            $momCalcB configure -state normal
            $printResB configure -state normal 
            return ""
        }
        set amp $WaveAmplitude
        set pi 3.14159265358979323846
        set Patm 0.0
        set g 9.81
        set rho 1025.0
        
        if {$x_ref1 <= 0 && $x_med <= 0} {
            set iX [expr abs(abs($x_ref1) - abs($x_med))]
        } elseif {$x_ref1 <= 0 && $x_med >= 0} {
            set iX [expr abs($x_ref1) + $x_med]
        } elseif {$x_ref1 >= 0 && $x_ref2 <= 0} {
            set iX [expr abs($x_med) + $x_ref1]
        } elseif {$x_ref1 >= 0 && $x_med >= 0} {
            set iX [expr abs($x_ref1 - $x_med)]
        }   
        
        if {$x_ref1 <= 0 && $x_ref2 <= 0} {
            set L1 [expr abs(abs($x_ref1) - abs($x_ref2))]
        } elseif {$x_ref1 <= 0 && $x_ref2 >= 0} {
            set L1 [expr abs($x_ref1) + $x_ref2]
        } elseif {$x_ref1 >= 0 && $x_ref2 <= 0} {
            set L1 [expr abs($x_ref2) + $x_ref1]
        } elseif {$x_ref1 >= 0 && $x_ref2 >= 0} {
            set L1 [expr abs($x_ref1 - $x_ref2)]
        }            
        
        set K [expr 2*$pi/$L1]
        set w [expr sqrt($K*$g)]
        set H [expr 2*$amp] 
        
        
        if {$x_med >= [ expr $x_ref1 - $L1/4.0] && $x_med <= [ expr $x_ref2 + $L1/4.0] } {
            if { $WaveType == [= "Sinusoidal"]} {
                
                set z_wave [expr $z_ref + $amp*cos(2*$pi*($x_med-$x_ref1)/$L1 + $WavePhase )]
                
                if { $zmin < $z_wave } {
                    set izmin [expr $zmin - $z_ref]
                    set p_zmin [ expr $Patm - $rho*$g*$izmin + \
                            $rho*$g*$amp*exp($K*$izmin)*cos($K*$iX + $WavePhase) ]              
                } else {
                    set p_zmin $Patm
                }
                if { $zmax < $z_wave } {
                    set izmax [expr $zmax - $z_ref]
                    set p_zmax [ expr $Patm - $rho*$g*$izmax + \
                            $rho*$g*$amp*exp($K*$izmax)*cos($K*$iX + $WavePhase) ] 
                } else {
                    set p_zmax $Patm
                }
            } elseif { $WaveType == [= "Trochoidal"] } {
                
                set R [expr $L1/(2*$pi)]
                set r $WaveAmplitude
                set th [expr $pi/2]
                
                set xph [expr $R*$WavePhase - $r*sin($WavePhase)]
                
                for { set i 1 } { $i <= 1000 } { incr i } {
                    set thh $th
                    set th [expr $th - ($R*$th - $r*sin($th) - \
                            ($x_med - $x_ref1 - $xph))/($R - $r*cos($th))]
                    if { ($th < 0 && $thh < 0) || ($th > 0 && $thh > 0) } {
                        if { [expr abs($th - $thh)] <= 1.0e-4 } { 
                            set th $th
                            break 
                        }
                    }
                }
                
                set z_wave [expr  $z_ref + $r*cos($th)]
                
                if { $zmin < $z_wave } {
                    set izmin [expr $zmin - $z_ref]
                    set p_zmin [ expr $Patm - $rho*$g*$izmin - \
                            0.5*$rho*$amp*$amp*$w*$w*exp(2*$K*$izmin) + \
                            $rho*$g*$amp*exp($K*$izmin)*cos($K*($iX-$xph)) ]              
                } else {
                    set p_zmin $Patm
                }
                if { $zmax < $z_wave } {
                    set izmax [expr $zmax - $z_ref]
                    set p_zmax [ expr $Patm - $rho*$g*$izmax - \
                            0.5*$rho*$amp*$amp*$w*$w*exp(2*$K*$izmax) + \
                            $rho*$g*$amp*exp($K*$izmax)*cos($K*($iX-$xph)) ]
                } else {
                    set p_zmax $Patm
                }
            }
            
            set p_aprox [expr 0.5*($p_zmax + $p_zmin)]
            set y_refp [lindex $WaveRefpoint 1]
        }
        
        set n1 [lindex $elemNormal 0]
        set n2 [lindex $elemNormal 1]
        set n3 [lindex $elemNormal 2]
        
        set FpX [expr $p_aprox*$elemArea*$n1]
        set FpY [expr $p_aprox*$elemArea*$n2]
        set FpZ [expr $p_aprox*$elemArea*$n3]         
        
        set MpX [expr $FpY*($elemZcG - $z_ref) + $FpZ*($elemYcG - $y_ref1)]
        set MpY [expr $FpX*($elemZcG - $z_ref) + $FpZ*($elemXcG - $x_ref1)]
        set MpZ [expr $FpY*($elemXcG - $x_ref1) + $FpX*($elemYcG - $y_ref1)]
        
        set TotalResX [expr $TotalResX + $FpX]
        set TotalResY [expr $TotalResY + $FpY]
        set TotalResZ [expr $TotalResZ + $FpZ]
        
        set TotalBendMX [expr $TotalBendMX + $MpX]
        set TotalBendMY [expr $TotalBendMY + $MpY]
        set TotalBendMZ [expr $TotalBendMZ + $MpZ]
        
        lappend NumList $num
        lappend PressList $p_aprox
        
        lappend FpXList $FpX
        lappend FpYList $FpY
        lappend FpZList $FpZ
        
        lappend MpXList $MpX
        lappend MpYList $MpY
        lappend MpZList $MpZ
        
    } 
    
    
    set waveResForceTotX [format %g $TotalResX]
    set waveBendMomTotX [format %g $TotalBendMX]
    
    set waveResForceTotY [format %g $TotalResY]
    set waveBendMomTotY [format %g $TotalBendMY] 
    
    set waveResForceTotZ [format %g $TotalResZ]
    set waveBendMomTotZ [format %g $TotalBendMZ] 

    $eResX configure -readonlybackground white -textvariable wave::waveResForceTotX
    $eMomX configure -readonlybackground white -textvariable wave::waveBendMomTotX

    $eResY configure -readonlybackground white -textvariable wave::waveResForceTotY
    $eMomY configure -readonlybackground white -textvariable wave::waveBendMomTotY

    $eResZ configure -readonlybackground white -textvariable wave::waveResForceTotZ
    $eMomZ configure -readonlybackground white -textvariable wave::waveBendMomTotZ

    $momCalcB configure -state normal 
    $printResB configure -state normal 
    
    set progress 100
    destroy $waveBar
    tk_messageBox -parent $frame -type ok -message [= "Calculation complete."]

    
}

proc wave::WavePrintResults {momCalcB printResB frame} {
       
    variable NumList 
    variable PressList 
    variable FpXList 
    variable FpYList 
    variable FpZList 
    variable MpXList 
    variable MpYList 
    variable MpZList 
    variable doc
  
    set doc $gid_groups_conds::doc
    set root [$doc documentElement]
     
    set flagMeshWave [GiD_MustRemeshFlag get] 
    set flagWave 0
    
    set xp {container[@n='loadcases']/blockdata[@n='loadcase']/container[@n='Shells']/condition[@n='WaveLoad_shell']/group}
    
    set aux [$root selectNodes $xp]
    if {$aux != ""} {
        set flagWave 1
    }

    if { $flagWave==0 } {
        tk_messageBox -parent $frame -icon error -type ok -message [= "No results to print.\nIt is necessary to asign Wave Loads,\n\
                mesh, and calculate bending moment before printing \
                Bending Moment "]
        
        return ""
    } elseif { $flagWave==1 && $flagMeshWave==1} {
        tk_messageBox -parent $frame -icon error -type ok -message [= "No results to print.\nWave Loads have changed since the last meshing.\n\
                It is necessary to asign, remesh and calcualte again before printing "]
        
        return ""    
    }
    if {$NumList == ""} {
        tk_messageBox -parent $frame -icon error -type ok -message [= "No results to print.\nIt is necessary to calculate bending moment before printing \
                Bending Moment and Forces. Press CALCULATE button first"]
        return ""
    }

    set projectPath [GiD_Info Project ModelName]
    set initial [file rootname [file tail $projectPath]].flavia.res
    set ext ".flavia.res"
    if { $::tcl_platform(platform) == "windows" } {
        set tofile [tk_getSaveFile -defaultextension $ext \
                -initialfile $initial -parent $frame -initialdir $projectPath \
                -title "Save Results"]
    } else {
        set tofile [Browser-ramR file save]
    }
    
    
    $momCalcB configure -state disabled
    $printResB configure -state disabled

    if { $tofile == "" } { 
        $momCalcB configure -state normal
        $printResB configure -state normal
        return
    }
    
    if { [file ext $tofile] != ".res"} {
        WarnWin "Unknown extension for file '$tofile'"
        return
    }
    

#     set waveOutFile "$projectPath.flavia.res"
    set waveOutFile $tofile
    set res_file [open $waveOutFile "w+"]

    puts $res_file "GiD Post Results File 1.0"
    puts $res_file "GaussPoints \"G_P\" Elemtype Triangle"
    puts $res_file "Number Of Gauss Points: 1"
    puts $res_file "Natural Coordinates: Internal"
    puts $res_file "End Gausspoints"
    
    puts $res_file "Result \"Pressure\" \"WaveLoads\" 1 Scalar OnGaussPoints \"G_P\""
    puts $res_file "Values"  
    for {set j 0} {$j <= [llength $NumList]} {incr j} {
        puts $res_file "[lindex $NumList $j] [lindex $PressList $j]" 
    }
    puts $res_file "End Values"
    
    puts $res_file "Result \"M_p\" \"WaveLoads\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"MpX\" \"MpY\" \"MpZ\" \"|MP|\""
    puts $res_file "Values"   
    for {set j 0} {$j <= [llength $NumList]} {incr j} {
        puts $res_file "[lindex $NumList $j] [lindex $MpXList $j] [lindex $MpYList $j] [lindex $MpZList $j]"
    }
    puts $res_file "End Values" 

    puts $res_file "Result \"F_p\" \"WaveLoads\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"FpX\" \"FpY\" \"FpZ\" \"|FP|\""
    puts $res_file "Values"   
    for {set j 0} {$j <= [llength $NumList]} {incr j} {
        puts $res_file "[lindex $NumList $j] [lindex $FpXList $j] [lindex $FpYList $j] [lindex $FpZList $j]"
    }
    puts $res_file "End Values" 
    
    close $res_file

    $momCalcB configure -state normal 
    $printResB configure -state normal 
    
    
}

# proc wave::WriteWaveDataFile {_} {
#     
#     variable bas_custom_waveload
#     
# #     if { $interval_num != 1 } { return }
# #     set data [GiD_Info conditions -interval 2 Wave_Loads mesh]
#     if { ![llength $data] } { return "" }
#     
#     set _ ""
#     append _ "static_load\ncustom_data_elems\n"
#     foreach i $data {
#         foreach "- num - WaveHeel WaveEmergence WaveTrim WaveBuoyc WaveAmplitude WaveLength \
#             WavePhase WaveShipLength WaveRefpoint WaveType WaveStern" $i break
#         set key [list $WaveHeel $WaveEmergence $WaveTrim $WaveBuoyc $WaveAmplitude $WaveLength \
#                 $WavePhase $WaveShipLength $WaveRefpoint $WaveType $WaveStern]
#         append _ "$num [lindex $bas_custom_waveload($key) 0]\n"
#     }
#     append _ "end custom_data_elems\nend static_load\n"
#     return $_
#     
# }




