namespace eval nasmat_anisotropicshell { } {
    variable elastic_matrix
    variable limit_stress
    variable conductivity_matrix
    variable thermal_exp
    variable density
    variable damping
    variable tempref
    variable sp_heat
    variable honey
    variable heatgen
    variable nontype 
    variable plasticity 
    variable harderule 
     variable yieldfunc
    variable limit1 
    variable limit2 
    variable updatenon 
    variable st_srlist
    variable matid
    variable elastic_temp
    variable expansion_temp
    variable conduc_temp
}

proc nasmat_anisotropicshell::initvars { } { 
    variable elastic_matrix
    variable limit_stress
    variable conductivity_matrix
    variable thermal_exp
    variable density ""
    variable damping ""
    variable tempref ""
    variable sp_heat ""
    variable honey ""
    variable heatgen ""
    variable nontype none
    variable plasticity ""
    variable harderule 1.Isotropic
     variable yieldfunc "1.Von-Mises" 
    variable limit1 ""
    variable limit2 ""
    variable updatenon 0
    variable st_srlist ""

    for {set i 1} {$i<=3} {incr i } {
        set thermal_exp(A$i) ""
        for {set j $i} {$j<=3} {incr j} {
            set elastic_matrix($i,$j) ""
            set conductivity_matrix($i,$j) ""
        }
    }
    foreach name {tension compression shear} {
        set limit_stress($name) ""
    }
}
# ###########################################################################
# 
# 
#                                      Comunication with GiD
# 
# 
# ##########################################################################
proc nasmat_anisotropicshell::ComunicateWithGiD { op args } {
    variable window
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            set window $PARENT
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set f [frame $PARENT.fanisotropic]
            grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 
            grid columnconf $f 0 -weight 1
            grid rowconf $f 0 -weight 1
            grid rowconf $PARENT $ROW -weight 1
            grid columnconf $PARENT 0 -weight 1
            upvar \#0 $GDN GidData
            nasmat_anisotropicshell::initwindow $f 
            nasmat_anisotropicshell::initvars
            nasmat_anisotropicshell::getvalues $GDN $STRUCT
             return ""
         }
         "SYNC" {
             set GDN [lindex $args 0]
             set STRUCT [lindex $args 1]
            if { [ nasmat_anisotropicshell::errorcntrl $window] } {
                nasmat_anisotropicshell::dump $GDN $STRUCT
                return ""            
            } 
        }
    }
}

# ###########################################################################
# 
# 
#                                        Initalitzation of main window
# 
# 
# ##########################################################################
proc nasmat_anisotropicshell::initwindow { parent } {

    set tfglobal [ TitleFrame $parent.fglobal -text [= "Anisotropic Shell Material"] -relief groove -bd 2 ]
    set fglobal [ $tfglobal getframe  ]

    set nbglobal [NoteBook $fglobal.nbglobal ]
    set page1 [$nbglobal insert 0 page1 -text [= "Stiffness"]]
    set fpage1 [ $nbglobal getframe page1 ]
    set page2 [ $nbglobal insert 1 page2 -text Thermal ]
    set fpage2 [ $nbglobal getframe page2 ]
    set page3 [ $nbglobal insert 2 page3 -text Others]
    set fpage3 [ $nbglobal getframe page3 ]
    $nbglobal raise page1

    set tfstiffness [ TitleFrame $fpage1.fstiffness -text [= "Stiffness"] -relief groove -bd 2 ]
    set fstiffness [ $tfstiffness  getframe ]
    
    set tfelasticmatrix [ TitleFrame $fstiffness.felasticmatrix -text [= "Elastic Matrix"] -relief groove -bd 2 ]
    set felasticmatrix [ $tfelasticmatrix  getframe ]
    for {set i 1} {$i<=3} {incr i} {
        for {set j $i} {$j<=3} {incr j} {
            set eelastic$i$j [ entry $felasticmatrix.eelastic$i$j -textvariable nasmat_anisotropicshell::elastic_matrix($i,$j)]
        }
    }
     set btempelastic  [Button $felasticmatrix.btempelastic -text [= "Temp"]... -width 10\
            -command "matmatrix::initwindow $parent 3 3 {G11 G12 G13 G22 G23 G33} yes nasmat_anisotropicshell::elastic_temp nasmat_anisotropicshell::elastictemp"]

    set tflimit [ TitleFrame $fpage1.flimit -text [= "Limit Stress"] -relief groove -bd 2 ]
    set flimit [ $tflimit getframe ]
    
    set llimtension [ Label $flimit.llimtension -text [= "Tension"] -helptext [= "Allowable tensile stress"]]
    set elimtension [ entry $flimit.elimtension -textvariable nasmat_anisotropicshell:::limit_stress(tension)]
    set blimtension [menubutton $flimit.blimtension -text [= "Temp"]... -menu $flimit.blimtension.mlimtension \
            -bd 2 -relief raised ]
    set mlimtension [menu $blimtension.mlimtension -title NULL \
            -postcommand "nasmat_anisotropicshell::updatetablelist $blimtension.mlimtension nasmat_anisotropicshell:::limit_stress(tension)"]
 
    set llimcompression [ Label $flimit.llimcompression -text [= "Compression"] \
            -helptext [= "Allowable compressive stress"]]
    set elimcompression [ entry $flimit.elimcompression -textvariable nasmat_anisotropicshell:::limit_stress(compression)]
    set blimcompression [menubutton $flimit.blimcompression -text [= "Temp"]... -menu $flimit.blimcompression.mlimcompression \
            -bd 2 -relief raised]
    set mlimcompression [menu $blimcompression.mlimcompression -title NULL \
            -postcommand "nasmat_anisotropicshell::updatetablelist $blimcompression.mlimcompression nasmat_anisotropicshell:::limit_stress(compression)"]

    set llimshear [ Label $flimit.llimshear -text [= "Shear"] -helptext [= "Allowable shear stress"]]
    set elimshear [ entry $flimit.elimshear -textvariable nasmat_anisotropicshell::limit_stress(shear)]
    set blimshear [menubutton $flimit.blimshear -text [= "Temp"]... -menu $flimit.blimshear.mlimshear \
            -bd 2 -relief raised ]
    set mlimshear [menu $blimshear.mlimshear -title NULL \
            -postcommand "nasmat_anisotropicshell::updatetablelist $blimshear.mlimshear nasmat_anisotropicshell::limit_stress(shear)"]

    set tfthermal [ TitleFrame $fpage2.fthermal -text [= "Thermal"] -relief groove -bd 2 ]
    set fthermal [ $tfthermal  getframe ]

    set tfexpansion [ TitleFrame $fthermal.fexpansion -text [= "Expansion Vector"] -relief groove -bd 2 ]
    set fexpansion [ $tfexpansion  getframe ]
    for {set i 0} {$i<=3} {incr i } {
        set eexpansionA$i [ entry $fexpansion.eexpansionA$i -textvariable nasmat_anisotropicshell::thermal_exp(A$i) ]
    }
    set ftempexp [frame $fexpansion.ftempexp]
    set btempexp [button $ftempexp.btempexp -text [= "Temp"]... -width 10\
            -command "matmatrix::initwindow $parent 3 0 {A1 A2 A3}  no nasmat_anisotropicshell::expansion_temp nasmat_anisotropicshell::expansiontemp"]
  
    set tfconductivty [ TitleFrame $fthermal.fconductivty -text [= "Conductivity Matrix"] -relief groove -bd 2 ]
    set fconductivty [ $tfconductivty  getframe ]
    for {set i 1 } {$i<=3 } {incr i } {
        for {set j $i} {$j<=3 } {incr j } {
            set econd$i$j [ entry $fconductivty.econd$i$j -textvariable nasmat_anisotropicshell::conductivity_matrix($i,$j) ]
        }
    }
    set btempcond [button $fconductivty.btempcond -text [= "Temp"]... -width 10\
            -command "matmatrix::initwindow $parent 3 3 {K11 K12 K13 K22 K23 K33} yes nasmat_anisotropicshell::conduc_temp nasmat_anisotropicshell::conductemp"]


    set lspheat [ Label $fthermal.lspheat -text [= "Specific Heat"] \
            -helptext [= "Heat capacity per unit mass at constant pressure"]]
    set espheat [ entry $fthermal.espheat -textvariable nasmat_anisotropicshell::sp_heat ]
    set bspheat [menubutton $fthermal.bspheat -text [= "Temp"]... -menu $fthermal.bspheat.mspheat \
            -bd 2 -relief raised ]
    set mspheat [menu $bspheat.mspheat -title NULL \
            -postcommand "nasmat_anisotropicshell::updatetablelist $bspheat.mspheat nasmat_anisotropicshell::sp_heat"]
   
    set lheatgen [ Label $fthermal.lheatgen -text [= "Heat Generation"] \
            -helptext [= "Heat Generation capability."]]
    set eheatgen [ entry $fthermal.eheatgen -textvariable nasmat_anisotropicshell::heatgen ]
    set bheatgen [menubutton $fthermal.bheatgen -text [= "Temp"]... -menu $fthermal.bheatgen.mheatgen \
            -bd 2 -relief raised ]
    set mheatgen [menu $bheatgen.mheatgen -title NULL \
            -postcommand "nasmat_anisotropicshell::updatetablelist $bheatgen.mheatgen nasmat_anisotropicshell::heatgen"]

    set tfothers [ TitleFrame $fpage3.fothers -text [= "Others"] -relief groove -bd 2 ]
    set fothers [ $tfothers getframe ] 
    
    set ldensity [ Label $fothers.ldensity -text [= "Mass Density"] \
            -helptext [= "Weight density may be used if the value 1/g is entered on the PARAM, WTMASS entry"]]
    set edensity [ entry $fothers.edensity -textvariable nasmat_anisotropicshell::density ]
    set bdensity [menubutton $fothers.bdensity -text [= "Temp"]... -menu $fothers.bdensity.mdensity \
            -bd 2 -relief raised ]
    set mdensity [menu $bdensity.mdensity -title NULL \
            -postcommand "nasmat_anisotropicshell::updatetablelist $bdensity.mdensity nasmat_anisotropicshell::density"]


    set ldamping [ Label $fothers.ldamping -text [= "Damping Coef."] \
            -helptext [= "To obtain the damping coefficient, multiply the critical damping ratio C/C0, by 2.0."]]
    set edamping [ entry $fothers.edamping -textvariable nasmat_anisotropicshell::damping ]
    set bdamping [menubutton $fothers.bdamping -text [= "Temp"]... -menu $fothers.bdamping.mdamping \
            -bd 2 -relief raised ]
    set mdamping [menu $bdamping.mdamping -title NULL \
            -postcommand "nasmat_anisotropicshell::updatetablelist $bdamping.mdamping nasmat_anisotropicshell::damping"]


    set ltempref [ Label $fothers.ltempref -text [= "Temp. Ref."] \
            -helptext [= "Reference temperature for the calculation of thermal loads."]]
    set etempref [ entry $fothers.etempref -textvariable nasmat_anisotropicshell::tempref ]
    set lhoney [ Label $fothers.lhoney -text [= "Honeycomb"] \
            -helptext [= "Honeycomb sandwich core cell size.\n\
            Required if material defines \n\
            the core of a honeycomb sandwich\n\
            and dimpling stability index is desired"]]
    set ehoney [ entry $fothers.ehoney -textvariable nasmat_anisotropicshell::honey]
 

    set fnonlinear [ frame $fglobal.fnonlinear ]
    set bnonlinear [ button $fnonlinear.bnonlinear -text [= "NonLinear"]... -command "nasmat_anisotropicshell::initnonlinearwindow $parent" \
            -underline 0 -width 12]
    bind $nbglobal <Alt-KeyPress-n>  "tkButtonInvoke  $bnonlinear"
        

    grid $tfglobal -row 0 -column 0 -sticky nsew -padx 2 -pady 2
    grid columnconf $fglobal 0 -weight 1
    grid rowconf $fglobal 0 -weight 1

    grid $nbglobal -row 0 -column 0 -sticky nsew
    
    grid columnconf $fpage1 0 -weight 1
    grid rowconf $fpage1 10 -weight 1

    grid columnconf $fpage2 0 -weight 1
    grid rowconf $fpage2 10 -weight 1
 
    grid columnconf $fpage3 0 -weight 1
    grid rowconf $fpage3 10 -weight 1
   
    grid $tfstiffness -row 0 -column 0 -sticky nsew -padx 2 -pady 2
    grid columnconf $fstiffness 0 -weight 1
    
    grid $tfelasticmatrix -row 0 -column 0 -sticky nsew -padx 2 -pady 2 
    for {set i 1} {$i<=3} {incr i } {
        grid columnconf $felasticmatrix [expr $i-1] -weight 1
        for {set j $i} {$j<=3} {incr j } {
            set widget "eelastic$i$j"
            grid [set $widget] -row [expr $i-1] -column [expr $j-1] -sticky ew
        }
    }
    grid $btempelastic -row 2 -column 0 -sticky ns -pady 2
           
    grid rowconf $fpage2 1 -weight 1
    
    grid $tflimit -row 1 -column 0 -sticky nsew -padx 2 -pady 2
    grid columnconf $flimit 1 -weight 1

    grid $llimtension -row 0 -column 0 -sticky e
    grid $elimtension -row 0 -column  1 -sticky we -pady 2
    grid $blimtension -row 0 -column 2 -sticky ew -padx 4 

    grid $llimcompression -row 1 -column 0 -sticky e
    grid $elimcompression -row 1 -column  1 -sticky we -pady 2
    grid $blimcompression -row 1 -column 2 -sticky ew -padx 4 
    
    grid $llimshear -row 2 -column 0 -sticky e
    grid $elimshear -row 2 -column  1 -sticky we -pady 2
    grid $blimshear -row 2 -column 2 -sticky ew -padx 4 

    grid $tfthermal -row 0 -column 0 -sticky nsew -padx 2 -pady 2
    grid columnconf $fthermal 1 -weight 1
    
    grid $tfexpansion -row 0 -column 0 -sticky nsew -padx 2 -pady 2 -columnspan 3
    for {set i 1} {$i<=3} {incr i } {
        grid columnconf $fexpansion [expr $i-1] -weight 1
        set widget eexpansionA$i
        grid [set $widget] -row 0 -column [expr $i-1] -sticky ew
   } 
    grid $ftempexp -row 1 -column 1 -sticky nsew -pady 2
    grid $btempexp -row 0 -column 0 
   grid $tfconductivty -row 1 -column 0 -sticky nsew -padx 2 -pady 2 -columnspan 3
    for {set i 1} {$i<=3} {incr i } {
       grid columnconf $fconductivty [expr $i-1] -weight 1
        for {set j $i} {$j<=3} {incr j } {
            set widget "econd$i$j"
            grid [set $widget] -row [expr $i-1] -column [expr $j-1] -sticky ew
        }
    }
    grid $btempcond -row 2 -column 0 -sticky ns
    grid $lspheat -row 2 -column 0 -sticky e
    grid $espheat -row 2 -column 1 -sticky ew -pady 2
    grid $bspheat -row 2 -column 2 -sticky ew -padx 4 

 
    grid $lheatgen -row 3 -column 0 -sticky e
    grid $eheatgen -row 3 -column 1 -sticky ew -pady 2
    grid $bheatgen -row 3 -column 2 -sticky ew -padx 4   

    grid $tfothers -row 0 -column 0 -sticky nsew -padx 2 -pady 2
    grid columnconf $fothers 1 -weight 1
    
    grid rowconf $fpage3 1 -weight 1

    grid $ldensity -row 0 -column 0 -sticky e
    grid $edensity -row 0 -column 1 -sticky ew -pady 2
    grid $bdensity -row 0 -column 2 -sticky ew -padx 4 

    grid $ldamping -row 1 -column 0 -sticky e
    grid $edamping -row 1 -column 1 -sticky ew -pady 2
    grid $bdamping -row 1 -column 2 -sticky ew -padx 4

    grid $ltempref -row 2 -column 0 -sticky e
    grid $etempref -row 2 -column 1 -sticky ew -pady 2
    
    grid $lhoney -row 3 -column 0 -sticky e
    grid $ehoney -row 3 -column 1 -sticky ew -pady 2    
    
    
    grid $fnonlinear -row 2 -column 0 -columnspan 2 -sticky nsew
    grid $bnonlinear -row 0 -column 0 -pady 3
 
    
}
# ###########################################################################
# 
# 
#                                        Updates of thermal tables values
# 
# 
# ########################################################################## 
proc nasmat_anisotropicshell::updatetablelist { widget varname} { 
    
    set values ""
    set aux [ GiD_Info materials]
     foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            set tableinfo [lrange [GiD_Info materials $elem] 1 end]
            set index [lsearch $tableinfo "Value_type*"]
            incr index
            if { [lindex $tableinfo $index] == "vs._Temperature"} {
                lappend values  $elem
            }
        }
    }
    $widget delete 0 end
    foreach table $values {
        $widget add command -label $table -command "set $varname $table"
    }
    if { $values !="" } {
        $widget add  separator
    }
    $widget add command -label [= "Table Window"]... -command "GidOpenMaterials Tables"
}
# ###########################################################################
# 
# 
#                                        Initalitzation of nonlinear window
# 
# 
# ##########################################################################
proc nasmat_anisotropicshell::initnonlinearwindow { parent } {
    global tkPriv tcl_platform
    variable nontype

    set topname $parent.nonlinear
    catch {destroy $topname}
    toplevel $topname

    wm title $topname [= "NonLinear Properties"]
     if { $tcl_platform(platform) == "windows" } {
        wm transient $topname [winfo toplevel [winfo parent $topname]]
    }
   
    grid columnconf $topname 0 -weight 1
    grid rowconf $topname 4 -weight 1
    
    set tftype [ TitleFrame $topname.ftype -text [= "NonLinearity Type"] -relief groove -bd 2 ]
    set ftype [ $tftype getframe ]
    set bgcolor [$ftype cget -background]

     set rbnone [ radiobutton $ftype.rbnone -text [= "None"] -variable nasmat_anisotropicshell::nontype \
            -value none -command "event generate $topname <<none>>" ]
    set rbnonlinear [ radiobutton $ftype.rbnonlinear -text [= "Nonlinear Elastic"] \
            -variable nasmat_anisotropicshell::nontype \
            -value nonlinear -command "event generate $topname <<nonlinear-elastic>>" ]
    set rbelastplas [ radiobutton $ftype.rbelastplas -text [= "Elasto-Plastic"] \
            -variable nasmat_anisotropicshell::nontype \
            -value elasticplastic -command "event generate $topname <<elasto-plastic>>" ]

    focus $rbnone        

    set tfprop [ TitleFrame $topname.fprop -text [= "NonLinear Properties"] -relief groove -bd 2 ]
    set fprop [ $tfprop getframe ] 
    
    set lplasticity [ Label $fprop.lplasticity -text [= "Plasticity Modulus"] \
            -helptext [= "Slope of stress vs. plastic strain"] \
            -disabledforeground grey60 -foreground black]
    bind $topname <<none>> "$lplasticity configure -state disabled"
    bind $topname <<nonlinear-elastic>> "$lplasticity configure -state normal"
    bind $topname <<elasto-plastic>> "$lplasticity configure -state normal"
    set eplasticity [ entry $fprop.eplasticity -textvariable nasmat_anisotropicshell::plasticity -disabledbackground $bgcolor -bg white]
    bind $topname <<none>> "+ $eplasticity configure -state disabled "
    bind $topname <<nonlinear-elastic>> "+ $eplasticity configure -state normal"
    bind $topname <<elasto-plastic>> "+ $eplasticity configure -state normal "
    set bplasticity [ Button $fprop.bplasticity -text [= "Function"]... \
            -helptext [= "For more than a single slope in the\n\
            plastic range, the stress-strain data \nmust be supplied on a table"] \
            -command "nasfunanisotropic::initwindow $topname nasmat_anisotropicshell::plasticity" \
            -underline 0 -fg black -disabledforeground grey60]
    bind $topname <Alt-KeyPress-f>  "tkButtonInvoke $bplasticity"
    bind $topname <<none>> "+ $bplasticity configure -state disabled"
    bind $topname <<nonlinear-elastic>> "+ $bplasticity configure -state normal"
    bind $topname <<elasto-plastic>> "+ $bplasticity configure -state normal"
    
    set lharderule [ Label $fprop.lharderule -text [= "Hardening rule"] -disabledforeground grey60 -foreground black ]
    bind $topname <<none>> "+ $lharderule configure -state disabled"
    bind $topname <<nonlinear-elastic>> "+ $lharderule configure -state disabled"
    bind $topname <<elasto-plastic>> "+ $lharderule configure -state normal"
    set cbharderule [ ComboBox $fprop.cbharderule -editable no -values [list 1.Isotropic 2.Kinematic 3.Both] \
        -textvariable nasmat_anisotropicshell::harderule ]
    bind $topname <<none>> "+ $cbharderule configure -state disabled -entrybg $bgcolor"
    bind $topname <<nonlinear-elastic>> "+ $cbharderule configure -state disabled -entrybg $bgcolor"
    bind $topname <<elasto-plastic>> "+ $cbharderule configure -state normal -entrybg white"
    
    set tfyield [TitleFrame $topname.fyield -text [= "Yield Criterion"] -relief groove -bd 2 ]
    set fyield [ $tfyield getframe ]

    set lyieldfunc [Label $fyield.fyieldfunc -text [= "Yield function"] -disabledforeground grey60 -foreground black ]
    bind $topname <<none>> "+ $lyieldfunc configure -state disabled"
    bind $topname <<nonlinear-elastic>> "+ $lyieldfunc configure -state disabled"
    bind $topname <<elasto-plastic>> "+ $lyieldfunc configure -state normal"
    set cbyieldfunc [ ComboBox $fyield.cbyieldfunc -editable no -values [list "1.Von-Mises"  2.Tresca 3.Mohr-Coulomb \
                    4.Drucker-Prager] -textvariable nasmat_anisotropicshell::yieldfunc ]
    bind $topname <<none>> "+ $cbyieldfunc configure -state disabled -entrybg $bgcolor"
    bind $topname <<nonlinear-elastic>> "+ $cbyieldfunc configure -state disabled -entrybg $bgcolor"
    bind $topname <<elasto-plastic>> "+ $cbyieldfunc configure -state normal -entrybg white"
    
    set llimit1 [ Label $fyield.llimit1 -text [= "Initial Yield Value"] \
            -helptext [= "Initial yield stress for Von Mises and Tresca yield criteria"] \
            -disabledforeground grey60 -foreground black ]
    bind $topname <<none>> "+ $llimit1 configure -state disabled  "
    bind $topname <<nonlinear-elastic>> "+ $llimit1 configure -state disabled "
    bind $topname <<elasto-plastic>> "+ $llimit1 configure -state normal "
    set elimit1 [ entry $fyield.elimit1 -textvariable nasmat_anisotropicshell::limit1 -bg white -disabledbackground $bgcolor]
    bind $topname <<none>> "+ $elimit1 configure -state disabled "
    bind $topname <<nonlinear-elastic>> "+ $elimit1 configure -state disabled "
    bind $topname <<elasto-plastic>> "+ $elimit1 configure -state normal "
    set llimit2 [ Label $fyield.llimit2 -text [= "Friction Angle"] \
            -helptext [= "Friction angle (measured in degrees) for the Mohr-Coulomb and Drucker-Prager yield criteria."] \
            -disabledforeground grey60 -foreground black ]
    bind $topname <<none>> "+ $llimit2 configure -state disabled"
    bind $topname <<nonlinear-elastic>> "+ $llimit2 configure -state disabled"
    bind $topname <<elasto-plastic>> "+ $llimit2 configure -state normal"
    set elimit2 [ entry $fyield.elimit2 -textvariable nasmat_anisotropicshell::limit2 -bg white -disabledbackground $bgcolor]
    bind $topname <<none>> "+ $elimit2 configure -state disabled "
    bind $topname <<nonlinear-elastic>> "+ $elimit2 configure -state disabled "
    bind $topname <<elasto-plastic>> "+ $elimit2 configure -state normal "
    
    set fbuttons [ frame $topname.fbuttons ]
    
    set baccept [ button $fbuttons.baccept -text [= "Accept"] -underline 0 -command "nasmat_anisotropicshell::acceptnon $topname" -pady 3 -padx 8]
    set bcancel [ button $fbuttons.bcancel -text [= "Cancel"] -underline 0 -command "nasmat_anisotropicshell::cancelnon $topname" -pady 3 -padx 8]
    bind $topname <Alt-KeyPress-a>  "tkButtonInvoke $baccept"
    bind $topname <Alt-KeyPress-c>  "tkButtonInvoke $bcancel"
    
   
    
    grid $tftype -row 0 -column 0 -sticky nsew -padx 2 -pady 2
    
    grid $rbnone -row 0 -column 0
    grid $rbnonlinear -row 0 -column 1 
    grid $rbelastplas -row 0 -column 2
    
    grid $tfprop -row 1 -column 0 -sticky nsew  -padx 2 -pady 2
    grid columnconf $fprop 1 -weight 1

    grid $lplasticity -row 0 -column 0 -sticky e
    grid $eplasticity -row 0 -column 1 -sticky ew -pady 2 
    grid $bplasticity -row 0 -column 2 -sticky ew -pady 2 -padx 3

    grid $lharderule -row 1 -column 0 -sticky e
    grid $cbharderule -row 1 -column 1 -sticky ew -columnspan 2 -pady 2

    grid $tfyield -row 2 -column 0 -sticky nsew  -padx 2 -pady 2
    grid columnconf $fyield 1 -weight 1
    
    grid $lyieldfunc -row 0 -column 0 -sticky e
    grid $cbyieldfunc -row 0 -column 1 -sticky ew -pady 2
    
    grid $llimit1 -row 1 -column 0 -sticky e
    grid $elimit1 -row 1 -column 1 -sticky ew  -pady 2

    grid $llimit2 -row 2 -column 0 -sticky e
    grid $elimit2 -row 2 -column 1 -sticky ew  -pady 2
    
    grid $fbuttons -row 3 -column 0 -sticky nsew -pady 2

    grid $baccept -row 0 -column 0 -sticky w -padx 4
    grid  $bcancel -row 0 -column 1 -sticky e -padx 4
    
    bind $topname <<none>> "+ set nasmat_anisotropicshell::plasticity {}; set nasmat_anisotropicshell::limit1 {}; set nasmat_anisotropicshell::limit2 {} "
    bind $topname <<none>> "+ set nasmat_anisotropicshell::limit1 {}; set nasmat_anisotropicshell::limit2 {} "

    wm withdraw $topname
    update idletasks
    set xpos [ expr [winfo x  [winfo toplevel $parent]]+[winfo width [winfo toplevel $parent]]/2-[winfo reqwidth $topname]/2]
    set ypos [ expr [winfo y  [winfo toplevel $parent]]+[winfo height [winfo toplevel $parent]]/2-[winfo reqheight $topname]/2]

    wm geometry $topname +$xpos+$ypos
    wm deiconify $topname

    switch $nontype { 
        "none" { event generate $topname <<none>> } 
        "nonlinear" { event generate $topname <<nonlinear-elastic>> }
        "elasticplastic" { event generate $topname <<elasto-plastic>> }
    }

    
}
# ###########################################################################
# 
# 
#                                       Control errors
# 
# 
# ##########################################################################      

proc nasmat_anisotropicshell::errorcntrl { window } { 
    variable elastic_matrix
    variable limit_stress
    variable conductivity_matrix
    variable thermal_exp
    variable density
    variable damping
    variable tempref
    variable sp_heat
    variable honey
    variable heatgen
    variable nontype 
    variable plasticity 
    variable harderule 
     variable yieldfunc
    variable limit1 
    variable limit2 
    variable updatenon 
    variable st_srlist
   
   
    set tables ""
    set aux [ GiD_Info materials]
     foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            set tableinfo [lrange [GiD_Info materials $elem] 1 end]
            set index [lsearch $tableinfo "Value_type*"]
            incr index
            if { [lindex $tableinfo $index] == "vs._Temperature"} {
                lappend tables  $elem
            }
        }
    }
       
    set writestiffness 0
    set writethermal 0
    set writeothers 0
    set messagestiffness [= "Problems found in Stiffness tab"]:\n
   for {set i 1} {$i<=3} {incr i} { 
        for {set j $i} {$j<=3} {incr j} {
            lappend varvaluesstiffness $elastic_matrix($i,$j)
        }
    }
    foreach name {tension compression shear} {
        lappend varvaluesstiffness "$limit_stress($name)"
    }
    foreach value $varvaluesstiffness {
        if { ![string is double [string trim $value]] } {
            set addmsg 1
            if { [lsearch -exact $tables "$value"]!=-1 } {
                set addmsg 0
            }
            if { $addmsg } {
                append messagestiffness [= "'%s' is not a valid input" $value]\n
                set writestiffness 1
            }
        }
    }
    set messagethermal [= "Problems found in Thermal tab"]:\n
    for {set i 1} {$i<=3} {incr i} { 
        lappend varvaluesthermal $thermal_exp(A$i)
        for {set j $i} {$j<=3} {incr j} {
            lappend varvaluesthermal $conductivity_matrix($i,$j)
        }
    }
    lappend varvaluesthermal "$sp_heat" "$heatgen"
    foreach value $varvaluesthermal {
         if { ![string is double [string trim $value]] } {
            set addmsg 1
            if { [lsearch -exact $tables "$value"]!=-1  } {
                set addmsg 0
            }
            if { $addmsg } {
                append messagethermal [= "'%s' is not a valid input" $value]\n
                set writethermal 1
            }
        }
    }
    set messageothers [= "Problems found in Others tab"]:\n
    set varvaluesothers [list $density $damping $tempref $honey] 
    foreach value $varvaluesothers {
        if { ![string is double [string trim $value]] } {
            set addmsg 1
            foreach tablename $tables { 
                if { $value == $tablename } {
                    set addmsg 0
                }
            }
            if { $addmsg } {
                append messageothers [= "'%s' is not a valid input" $value]\n
                set writeothers 1
            }
        }
    }
    set message ""
    if { $writestiffness == 1 } {
        append message $messagestiffness
    }
    if { $writethermal == 1 } {
        append message $messagethermal
    }
    if { $writeothers == 1 } {
        append message $messageothers
    }
    if  { $message != "" } {
        WarnWin $message $window
        return 0
    }
    return 1
}
# ###########################################################################
# 
# 
#                                   Accept button nonlinear
# 
# 
# ##########################################################################   

proc nasmat_anisotropicshell::acceptnon { window } { 
    
    variable updatenon
    if { [nasmat_anisotropicshell::errorcntrlnon $window] } {
        set updatenon 1 
        destroy $window
    } else {
        return
    }
}
proc nasmat_anisotropicshell::errorcntrlnon { window } {
    
    variable nontype 
    variable plasticity
    variable harderule
    variable yieldfunc 
    variable limit1
    variable limit2 
    set message ""
    
    switch $nontype {
        "nonlinear" { 
            if { "$plasticity"!="table" } {
                   if { ![string is double $plasticity] } {
                        append message [= "Plasticity Modulus has an invalid input"]
                    }
                }
            }
        "elasticplastic" {
            if { "$plasticity"!="table"} {
                if { ![string is double $plasticity] } {
                        append message [= "Plasticity Modulus has an invalid input"]\n
                    }
                }
            if { ![string is double $limit1] } {
                        append message [= "Initial Yield Value has an invalid input"]\n
                }
                if { ![string is double $limit2] } {
                        append message [= "Friction Angle has an invalid input"]\n
                }
        }
    }
    if { $message != "" } {
        WarnWin $message $window
        return 0
    }
    return 1
}     
                                

# ###########################################################################
# 
# 
#                                  Cancel  button nonlinear
# 
# 
# ##########################################################################   

proc nasmat_anisotropicshell::cancelnon { window } { 

    variable updatenon
    set updatenon 0
    destroy $window
}
# ###########################################################################
# 
# 
#                                Comunication with materials matrix  namespace
# 
# 
# ##########################################################################  
proc nasmat_anisotropicshell::elastictemp { } {
    variable elastic_temp
    variable elastic_matrix
    array set names [list 11 1,1 12 1,2 13 1,3 22 2,2 23 2,3 33 3,3]
    set elastic_matrix($names([lindex $elastic_temp 1])) [lindex $elastic_temp 0]
     
}
# ###########################################################################
# 
# 
#                                Comunication with materials matrix  namespace
# 
# 
# ##########################################################################  
proc nasmat_anisotropicshell::conductemp { } {
    variable conduc_temp
    variable conductivity_matrix
    array set names [list 11 1,1 12 1,2 13 1,3 22 2,2 23 2,3 33 3,3]
    set conductivity_matrix($names([lindex $conduc_temp 1])) [lindex $conduc_temp 0]
     
}
# ###########################################################################
# 
# 
#                                Comunication with materials matrix  namespace
# 
# 
# ##########################################################################  
proc nasmat_anisotropicshell::expansiontemp { } {
    variable expansion_temp
    variable thermal_exp
    array set names [list 1 A1 2 A2 3 A3]
    set thermal_exp($names([lindex $expansion_temp 1])) [lindex $expansion_temp 0]
     
}
# ###########################################################################
# 
# 
#                                   ComuniacteWithGiD: dump values in materials file
# 
# 
# ##########################################################################    

proc nasmat_anisotropicshell::dump { GDN STRUCT } {

   variable elastic_matrix
    variable limit_stress
    variable conductivity_matrix
    variable thermal_exp
    variable density
    variable damping
    variable tempref
    variable sp_heat
    variable honey
    variable heatgen
    variable nontype 
    variable plasticity
    variable harderule
     variable yieldfunc 
    variable limit1
    variable limit2 
    variable updatenon
    variable st_srlist
    
    for {set i 1} {$i<=3} {incr i} {
        set values(A$i) $thermal_exp(A$i)
        for {set j $i} {$j<=3} {incr j} {
            set values(G$i$j) $elastic_matrix($i,$j)
            set values(K$i$j) $conductivity_matrix($i,$j)
        }
    }
    set values(rho) $density
    set values(Cp) $sp_heat
    set values(Hgen) $heatgen
    set values(Cs) $honey
    set values(Tref) $tempref
    set values(Ge) $damping
    set values(Ss) $limit_stress(shear)
    set values(Sc) $limit_stress(compression)
    set values(St) $limit_stress(tension)
        
    set names [array names values]    
    foreach item $names {
        if  { [string trim $values($item)] == "" } {
            DWLocalSetValue $GDN $STRUCT $item void
        } else {
            DWLocalSetValue $GDN $STRUCT $item $values($item)
        }
    }
    if { $updatenon } {
        DWLocalSetValue $GDN $STRUCT  "nontype" $nontype
        switch $nontype {
            "none" { 
                DWLocalSetValue $GDN $STRUCT  "plasticity" void
                DWLocalSetValue $GDN $STRUCT  "harden" void
                DWLocalSetValue $GDN $STRUCT  "yield_func" void
                DWLocalSetValue $GDN $STRUCT  "initial" void
                DWLocalSetValue $GDN $STRUCT  "friction" void  
            }
            "nonlinear" { 
                DWLocalSetValue $GDN $STRUCT  "plasticity" $plasticity
                DWLocalSetValue $GDN $STRUCT  "harden" void
                DWLocalSetValue $GDN $STRUCT  "yield_func" void
                DWLocalSetValue $GDN $STRUCT  "initial" void
                DWLocalSetValue $GDN $STRUCT  "friction" void  
            }
            "elasticplastic" {
                DWLocalSetValue $GDN $STRUCT  "plasticity" $plasticity
                DWLocalSetValue $GDN $STRUCT  "harden" $harderule
                DWLocalSetValue $GDN $STRUCT  "yield_func" $yieldfunc
                DWLocalSetValue $GDN $STRUCT  "initial" $limit1
                if { [string trim $limit2] == "" } {
                    DWLocalSetValue $GDN $STRUCT  "friction" void
                } else {
                    DWLocalSetValue $GDN $STRUCT  "friction" $limit2
                }
            }
        }
    }
    if { $plasticity == "table" } {
        set aux [base64::encode -wrapchar "" $st_srlist]
        DWLocalSetValue $GDN $STRUCT "stress-strain" $aux
    }
}
# ###########################################################################
# 
# 
#                                   Comunicate with GiD: get values from materials file.
# 
# 
# ##########################################################################    

proc nasmat_anisotropicshell::getvalues { GDN STRUCT } {
    upvar \#0 $GDN GidData
     variable elastic_matrix
    variable limit_stress
    variable conductivity_matrix
    variable thermal_exp
    variable density
    variable damping
    variable tempref
    variable sp_heat
    variable honey
    variable heatgen
    variable nontype 
    variable plasticity 
    variable harderule 
     variable yieldfunc
    variable limit1 
    variable limit2 
    variable updatenon 
    variable st_srlist
    set question 1
    for {set i 1} {$i<=3} {incr i} {
        set thermal_exp(A$i) [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,[expr 9+$i])]
        for { set j $i} {$j<=3} {incr j} {
            set elastic_matrix($i,$j) [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,[expr 2+$question])]
            set conductivity_matrix($i,$j) [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,[expr 18+$question])]
            incr question
        }
    }
    set density [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,9) ]
    set tempref [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,13)]
    set damping [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,14)]
    set limit_stress(tension) [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,15)]
    set limit_stress(compression) [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,16)]
    set limit_stress(shear) [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,17)]
    set honey [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,18)]
    set sp_heat [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,25)]
    set heatgen [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,26)]
    set nontype [nasmat_anisotropicshell::void_value $GidData($STRUCT,VALUE,27)]
    switch $nontype {
        "none" {}
        "nonlinear" { 
            variable plasticity $GidData($STRUCT,VALUE,28) 
        }
        "elasticplastic" {
            variable plasticity $GidData($STRUCT,VALUE,28)
            variable harderule $GidData($STRUCT,VALUE,29)
            variable yieldfunc $GidData($STRUCT,VALUE,30)
            variable limit1 $GidData($STRUCT,VALUE,31)
            variable limit2 $GidData($STRUCT,VALUE,32)
            if { $limit2 == "void" } {
                set limit2 ""
            }
        }
    }
    if { $plasticity == "table" } {
        set st_srlist [base64::decode $GidData($STRUCT,VALUE,33) ]
    }

} 
proc nasmat_anisotropicshell::void_value { value } {
    if { $value == "void" } {
        return ""
    } else {
        return [string trim $value]
    }
}
# ###########################################################################
# 
# 
#                                    Namespaces to create tables 
# 
# 
# ##########################################################################    

namespace eval nasfunanisotropic {
    variable insert_data {
       R0lGODlhGAAYAOMAAAICBK2tmo2NgOXlztXVvzY2MlxcWfLy2///////////
       /////////////////////yH5BAEKAAgALAAAAAAYABgAAAR4EMlJq704awu2
       BkDQeRVIDERBTibhnuPWuugwiLLw7vagfr5Xr3eIXQCHQ4E3SKKMpWZBN0wm
       oRSkQdi0WrGSVs3mTeI43G45ScACaCfy+tA+DtVlEOZ9Lw/AFAZyZQKAWU14
       fysISFZPi4wEbAaGGUh1kFmVmRoRADs=
    }
    variable insert [image create photo -data [set insert_data]]
    
    variable get_data {
       R0lGODlhGAAYAOMAAAICBK2tmo2NgOXlztXVvzY2MlxcWfLy2///////////
       /////////////////////yH5BAEKAAgALAAAAAAYABgAAAR/EMlJq704awu2
       BkDQeRVIDERBTibhnuPWuugwiLLw7vagfj4XoGcDHGIX46FAMBWHzcxwKQD1
       QIej9GAQDozgrDYJoA3PRzGO8/p+08pstERrFrPxw7x0HaT/R0gUZUR+Ygdf
       GwY2h2JVHlOGWYkreSiCMgRyBpiQep2VoCujEQA7
    }
    variable get [image create photo -data [set get_data]]


    
    variable delete_data {
       R0lGODlhDwAPAKEAAP8AAICAgAAAAP///yH+Dk1hZGUgd2l0aCBHSU1QACH5
       BAEKAAMALAAAAAAPAA8AAAIxnI+AAxDbXJIstnesvlOLj2XWJyzVWEKNYIUi
       wEbu+RnyW4vhmk4p3IOkcqYBsWgqAAA7
    }
    variable delete [image create photo -data [set delete_data]]
    
    variable entrytype
    variable deltax
    variable x 
    variable y
    variable tox
    variable toy
    variable ldeltax
    variable lx
    variable ly
    variable ltox
    variable ltoy
    variable edeltax
    variable ex
    variable ey
    variable etox
    variable etoy
    variable etoy2
    variable index 0
    variable insertype
    variable table
    variable list
    variable can   

} 
proc  nasfunanisotropic::getvalues { entries } {
    variable table
    
    set nelems [lindex $entries 1]
    set nelems [expr $nelems-1] 
    for { set i 2 } { $i <= $nelems  } { incr i 2 } {
        set x [lindex $entries $i ]
        set y [lindex $entries [expr $i+1]]
        $table insert end "[format %#16e $x] [format %#16e $y]"
    }
    
}

proc nasfunanisotropic::initwindow { parent varname } {
    variable table
    variable can   
    variable ldeltax
    variable lx
    variable ly
    variable ltox
    variable ltoy
    variable edeltax
    variable ex
    variable ey
    variable etox
    variable etoy
    variable etoy2
    variable list
    global tkPriv tcl_platform

    if  { $nasmat_anisotropicshell::st_srlist != "void" } {
        set  list $nasmat_anisotropicshell::st_srlist
    }
    set topname $parent.sr_st
    catch {destroy $topname}
    toplevel $topname    
    wm title $topname [= "Stress-Strain Curve"]
     if { $tcl_platform(platform) == "windows" } {
        wm transient $topname [winfo toplevel [winfo parent $topname]]
    }
    grid columnconf $topname 0 -weight 1
    grid rowconf $topname 0 -weight 1
    #-------------------------Crear Table values-----------------------------------#
    set w $topname
    set pw [PanedWindow $w.pw -side top]
    set pw0 [$pw add -weight 0 ]
    set pane [ $pw getframe 0]
    set title1 [TitleFrame $pane.tablevalues -relief groove -bd 2 -text [= "Table Values"] -side left]
    set f1 [$title1 getframe]
    set sw [ScrolledWindow $f1.scroll -scrollbar both ]
    set table [tablelist::tablelist $f1.scroll.table \
            -columns [list 0 [= "Strain"](\u03b5) center 0 [= "Stress"](\u03c3) center] \
            -stretch all -background white \
            -listvariable nasfunanisotropic::list -selectmode extended]
    $sw setwidget $table
    bind [$table bodypath] <Double-ButtonPress-1> { nasfunanisotropic::edit $nasfunanisotropic::table }
    set bbox [ButtonBox $f1.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $nasfunanisotropic::get -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Edit entry"] -command "nasfunanisotropic::edit $table"
    $bbox add -image $nasfunanisotropic::delete -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Delete entry"] -command "nasfunanisotropic::delete $table"
 
#---------------------------Crear Data Entry-------------------------------------------------#
    set pw2 [$pw add -weight 1]
    set pane2 [$pw getframe 1]
    set title2 [TitleFrame $pane2.data -relief groove -bd 2 -text [= "Data Entry"] -side left]
    set f2 [$title2 getframe]
    
    catch { unset bgcolor }
    set bgcolor [$f2 cget -background]
    set nasfunanisotropic::entrytype "Single Value"
    trace variable nasfunanisotropic::entrytype w "nasfunanisotropic::modify ;# "
    
    frame $f2.f
    radiobutton $f2.f.single -text [= "Single Value"] -var nasfunanisotropic::entrytype \
            -value "Single Value"  -selectcolor white 
    radiobutton $f2.f.linear -text [= "Linear Ramp"] -var nasfunanisotropic::entrytype \
            -value "Linear Ramp" -selectcolor white 
    radiobutton $f2.f.equation -text [= "Equation"] -var nasfunanisotropic::entrytype \
            -value "Equation" -selectcolor white
    radiobutton $f2.f.periodic -text [= "Periodic"] -var nasfunanisotropic::entrytype \
            -value "Periodic" -selectcolor white
    
    set nasfunanisotropic::x "" 
    set nasfunanisotropic::y ""
    set nasfunanisotropic::deltax ""
    set nasfunanisotropic::tox ""
    set nasfunanisotropic::toy ""   
    set fentries [ frame $f2.fentries ]
    set ldeltax [label $fentries.ldeltax -text [= "Delta X"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled ]
    set edeltax [entry $fentries.edeltax -textvariable nasfunanisotropic::deltax \
            -justify left -bd 2 -relief sunken  -background $bgcolor \
            -state disabled ] 
    set lx [label $fentries.lx -text "X" -justify right ]
    set ex [entry $fentries.ex -textvariable nasfunanisotropic::x -justify left \
            -bd 2  -relief sunken ]
    focus $ex
    set ly [label $fentries.ly -text "Y" -justify right -disabledforeground grey60 \
            -foreground black -state normal ]
    set ey [entry $fentries.ey -textvariable nasfunanisotropic::y -justify left  -bd 2 \
            -relief sunken -state normal ]
    set ltox [label $fentries.ltox -text [= "To X"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled ]
    set etox [entry $fentries.etox -textvariable nasfunanisotropic::tox -justify left \
            -bd 2  -relief sunken -background $bgcolor -state disabled ]
    set ltoy [label $fentries.ltoy -text [= "To Y"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled ]
    set fetoy [frame $fentries.etoy] 
    set etoy [entry $fetoy.e -textvariable nasfunanisotropic::toy -justify left \
            -bd 2 -relief sunken -background $bgcolor -state disabled]
    set examples { 3*x+log(x) pow(x,2)*exp(x) x*cos(3*x) sqrt(x+2)+sinh(pow(x,3)) \
            atan(x) abs(x) }
    set etoy2 [ComboBox $fetoy.cb -textvariable nasfunanisotropic::toy  \
            -background $bgcolor -values $examples]
    
    frame $pane2.fadd 
    button $pane2.fadd.badd -text [= "Add"] -underline 1 -padx 5 -command "nasfunanisotropic::add $table" 
    button $pane2.fadd.bclear -text [= "Clear All"] -underline 1 -padx 5 \
            -command "nasfunanisotropic::clear $table"  
    frame $pane2.fradio
    set nasfunanisotropic::insertype end
    radiobutton $pane2.fradio.end -text [= "Add at End"] -variable  nasfunanisotropic::insertype \
            -justify left -value end 
    radiobutton $pane2.fradio.no -text [= "Add before Selected"] -variable  nasfunanisotropic::insertype \
            -value no 
    set can [canvas $pane2.can -relief sunken -bd 2 -bg white -width 130 -height 100]
    set fbuttons [ frame $w.fbuttons ]
    set baccept [ button $fbuttons.baccept -text [= "Accept"] -underline 0 -pady 3 -padx 8 -command "nasfunanisotropic::acceptfunc $topname"]
    set bcancel [ button $fbuttons.bcancel -text [= "Cancel"] -underline 0 -pady 3 -padx 8 -command "nasfunanisotropic::cancelfunc $topname" ]
#------------------------Empaquetat amd grid -------------------------------------#
    grid rowconf $w 0 -weight 1
    grid columnconf $w 0 -weight 1
    
    grid $pw  -sticky nsew
    grid rowconf $pw 0 -weight 1
    grid columnconf $pw 0 -weight 1
    grid rowconf $pane 0 -weight 1
    grid columnconf $pane 0 -weight 1
    grid rowconf $pane2 3 -weight 1
    grid columnconf $pane2 0 -weight 1
    
    grid $title1 -column 0 -row 0 -padx 2 -pady 3 -sticky nsew 
    grid rowconf $f1 0 -weight 1
    grid columnconf $f1 0 -weight 1
    grid $sw -column 0 -row 0 -sticky nsew
    grid $bbox -column 0 -row 1 -sticky wn
    
    
    grid $title2 -column 0 -row 0 -padx 2 -pady 3 -sticky nsew
    grid  $f2.f -column 0 -row 0 -sticky nsew
    grid $f2.f.single -column 0 -row 0 -sticky w
    grid $f2.f.linear -column 1 -row 0 -sticky w
    grid $f2.f.equation -column 0 -row 1 -sticky w
    grid $f2.f.periodic -column 1 -row 1 -sticky w 
    
    grid $fentries -column 0 -row 1 -padx 2 -sticky nsew
    grid $ldeltax -column 0 -row 0 -pady 2 -sticky e 
    grid $edeltax -column 1 -row 0 -padx 2 -sticky we
    grid $lx -column 0 -row 1 -padx 2 -sticky e
    grid $ex -column 1 -row 1 -padx 2 -sticky we
    grid $ly -column  2 -row 1 -padx 2 -sticky e
    grid $ey -column 3 -row 1 -padx 2 -sticky we
    grid $ltox -column 0 -row 2 -padx 2 -sticky e
    grid $etox -column 1 -row 2 -padx 2 -sticky we
    grid $ltoy -column 2 -row 2 -padx 2 -sticky e
    grid $fetoy -column 3 -row 2 -padx 2 -sticky nsew
    grid  $etoy -column 0 -row 0  -sticky we 
    grid $etoy2 -column 0 -row 0 -sticky we
#     grid columnconf $f2.etoy 0 -weight 1
#     grid rowconf $f2.etoy 0 -weight 1
    grid remove $etoy2
    grid propagate $etoy 0
    
    grid $pane2.fadd -row 1 -column 0 -sticky nsew 
    grid columnconf $pane2.fadd 1 -weight 1
    grid $pane2.fadd.badd -row 0 -column 0 -padx 5 -pady 5
    grid $pane2.fadd.bclear -row 0 -column 1 -padx 5 -pady 5
    grid $pane2.fradio -row 2 -column 0 -sticky nsew 
    grid columnconf $pane2.fradio 2 -weight 1
    grid $pane2.fradio.end -row 0 -column 0 
    grid $pane2.fradio.no -row 0 -column 1
    grid $can -row 3 -column 0 -sticky nsew -padx 5 -pady 5
    
    grid $fbuttons -row 1 -column 0 -sticky nsew
    grid $baccept -row 0 -column 0 -padx 4
    grid $bcancel -row 0 -column  1 -padx 4
    
 
    
    bind $w <Alt-KeyPress-d> "tkButtonInvoke $pane2.fadd.badd"
    bind $w <Alt-KeyPress-l> "tkButtonInvoke $pane2.fadd.bclear"
    bind $can <Configure> "nasfunanisotropic::IntDrawGraphR $can ;#"
    bind $w <Alt-KeyPress-a> "tkButtonInvoke $baccept"
    bind $w <Alt-KeyPress-c> "tkButtonInvoke $bcancel"

     wm withdraw $topname
    update idletasks
    set xpos [ expr [winfo x  $parent]+[winfo width $parent]/2-[winfo reqwidth $topname]/2]
    set ypos [ expr [winfo y  $parent]+[winfo height $parent]/2-[winfo reqheight $topname]/2]

    wm geometry $topname +$xpos+$ypos
    wm deiconify $topname 
}

#----------------------------------------Modificacio finestra--------------------------------#
proc nasfunanisotropic::modify { } {

    if { ![winfo exists $nasfunanisotropic::ldeltax] } { return }
    
    catch { unset bgcolor }
    set bgcolor [$nasfunanisotropic::ldeltax cget -background]  
    
    if { $nasfunanisotropic::entrytype == "Single Value" } {
        set nasfunanisotropic::deltax "" 
        set nasfunanisotropic::x ""
        set nasfunanisotropic::y ""
        set nasfunanisotropic::tox ""
        set nasfunanisotropic::toy ""
        $nasfunanisotropic::ldeltax configure -state disable  -text [= "Delta X"]
        $nasfunanisotropic::edeltax configure -state disable -background $bgcolor 
        $nasfunanisotropic::ly configure -state normal
        $nasfunanisotropic::ey configure -state normal -background white
        $nasfunanisotropic::ltox configure -state disable  
        $nasfunanisotropic::etox configure -state disable -background $bgcolor
        $nasfunanisotropic::ltoy configure -state disabled -text [= "To Y"]
        $nasfunanisotropic::etoy configure -state disabled -background $bgcolor

        grid $nasfunanisotropic::etoy
        grid remove $nasfunanisotropic::etoy2 


    }
    if { $nasfunanisotropic::entrytype == "Linear Ramp" } {
        set nasfunanisotropic::deltax "" 
        set nasfunanisotropic::x ""
        set nasfunanisotropic::y ""
        set nasfunanisotropic::tox ""
        set nasfunanisotropic::toy ""
        $nasfunanisotropic::ldeltax configure -state normal -text [= "Delta X"]
        $nasfunanisotropic::edeltax configure -state normal -background white
        $nasfunanisotropic::ly configure -state normal
        $nasfunanisotropic::ey configure -state normal -background white
        $nasfunanisotropic::ltox configure -state normal  
        $nasfunanisotropic::etox configure -state normal -background white
        $nasfunanisotropic::ltoy configure -state normal -text [= "To Y"]
        $nasfunanisotropic::etoy configure -state normal -background white 
        grid $nasfunanisotropic::etoy
        grid remove $nasfunanisotropic::etoy2 
    }
    if { $nasfunanisotropic::entrytype == "Equation" } {
        set nasfunanisotropic::deltax "" 
        set nasfunanisotropic::x ""
        set nasfunanisotropic::y ""
        set nasfunanisotropic::tox ""
        set nasfunanisotropic::toy ""
        $nasfunanisotropic::ldeltax configure -state normal -text [= "Delta X"]
        $nasfunanisotropic::edeltax configure -state normal -background white
        $nasfunanisotropic::ly configure -state disabled
        $nasfunanisotropic::ey configure -state disabled -background $bgcolor
        $nasfunanisotropic::ltox configure -state normal  
        $nasfunanisotropic::etox configure -state normal -background white
        $nasfunanisotropic::ltoy configure -state normal -text "Y(X)"
        $nasfunanisotropic::etoy configure -state normal -background white 
        grid $nasfunanisotropic::etoy2
        grid remove $nasfunanisotropic::etoy 
    }
    if { $nasfunanisotropic::entrytype == "Periodic" } {
        set nasfunanisotropic::deltax "" 
        set nasfunanisotropic::x ""
        set nasfunanisotropic::y ""
        set nasfunanisotropic::tox ""
        set nasfunanisotropic::toy ""
        $nasfunanisotropic::ldeltax configure -state normal -text [= "Period"]
        $nasfunanisotropic::edeltax configure -state normal -background white
        $nasfunanisotropic::ly configure -state normal
        $nasfunanisotropic::ey configure -state normal -background white
        $nasfunanisotropic::ltox configure -state normal  
        $nasfunanisotropic::etox configure -state normal -background white
        $nasfunanisotropic::ltoy configure -state disabled -text [= "To Y"]
        $nasfunanisotropic::etoy configure -state disabled -background $bgcolor 
        grid $nasfunanisotropic::etoy
        grid remove $nasfunanisotropic::etoy2 
    } 
}



proc nasfunanisotropic::add { wtext } {
    variable entrytype
    variable deltax
    variable x
    variable y
    variable tox
    variable toy
    variable index
    variable insertype
    variable can
     
    
    if { [errorcntrl] } {  
        if { $insertype == "end" } {
            if { $entrytype == "Single Value" } {
                $wtext insert $index "[format %#16e $x] [format %#16e $y]"
                $wtext see end
                set index [expr $index+1]
            }
            if { $entrytype == "Linear Ramp" } {
                set x [expr double($x)]
                set tox [expr double($tox)]
                set deltax [expr double($deltax)]
                set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                set v1 [expr double([expr $tox-$x])]
                set v2 [expr double([expr $toy-$y])]
                set b [expr $y-$x*$v2/$v1]
                set m [expr $v2/$v1]
                for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr $x+$i*$deltax]
                    set yi [expr $m*$xi+$b]
                    $wtext insert $index "[format %#16e $xi] [format %#16e $yi]"
                    $wtext see end
                    set index [expr $index+1]
                }
            }
            if { $entrytype == "Equation" } {
                set x [expr double($x)]
                set tox [expr double($tox)]
                set deltax [expr double($deltax)]
                set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                string tolower $toy
                regsub -all {\mx\M} $toy \$xi aux
                set xi $x
                if { [catch { expr $aux } error] } { 
                    WarnWin $error
                    return 0 
                }
                for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr double([expr $x+$i*$deltax])]
                    set yi [expr $aux]
                    $wtext insert $index "[format %#16e $xi] [format %#16e $yi]"
                    $wtext see end
                    set index [expr $index+1]
                }
            }
            if { $entrytype == "Periodic" } {
                set x [expr double($x)]
                set tox [expr double($tox)]
                set deltax [expr double($deltax)]
                set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr $x+$i*$deltax]
                    $wtext insert $index "[format %#16e $xi] [format %#16e $y]"
                    $wtext see end
                    set index [expr $index+1]
                }
            }
        }
        if { $insertype == "no" } {
            set entry [$wtext curselection]
            if { $entry == "" } {
                WarnWin [= "It is necessary to select a row of values"]
            } else {
                if { $entrytype == "Single Value" } {
                    $wtext insert $entry "[format %#16e $x] [format %#16e $y]"
                    $wtext see $entry
                }
                if { $entrytype == "Linear Ramp" } {
                    set x [expr double($x)]
                    set tox [expr double($tox)]
                    set deltax [expr double($deltax)]
                    set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                    set v1 [expr double([expr $tox-$x])]
                    set v2 [expr double([expr $toy-$y])]
                    set b [expr $y-$x*$v2/$v1]
                    set m [expr $v2/$v1]
                    for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr $x+$i*$deltax]
                        set yi [expr $m*$xi+$b]
                        $wtext insert $entry "[format %#16e $xi] [format %#16e $yi]"
                        $wtext see $entry
                        set entry [expr $entry+1]
                    }
                }
                if { $entrytype == "Equation" } {
                    set x [expr double($x)]
                    set tox [expr double($tox)]
                    set deltax [expr double($deltax)]
                    set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                    string tolower $toy
                    regsub -all {\mx\M} $toy \$xi aux
                    for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr double([expr $x+$i*$deltax])]
                        set yi [expr $aux]
                        $wtext insert $entry "[format %#16e $xi] [format %#16e $yi]"
                        $wtext see $entry
                        set entry [expr $entry+1]
                    }
                }
                if { $entrytype == "Periodic" } {
                    set x [expr double($x)]
                    set tox [expr double($tox)]
                    set deltax [expr double($deltax)]
                    set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                    for { set i 0 } { $i<=$numint } { incr i } {
                        set xi [expr $x+$i*$deltax]
                        $wtext insert $entry "[format %#16e $xi] [format %#16e $y]"
                        $wtext see $entry
                        set entry [expr $entry+1]
                    } 
                }
            }
        }
    }
    nasfunanisotropic::IntDrawGraphR $can 
}
proc nasfunanisotropic:::edit { table } {
    
    variable x
    variable y
      set index [$table curselection]
    if { [llength $index] > 1} {
        WarnWin [= "It is only possible edit one row at the same time"]
        return
    } 
    if { $index != "" } {
        set entry [$table get $index]
        set x [lindex $entry 0]  
        set y [lindex $entry 1]
    }
} 
        

proc  nasfunanisotropic::delete { wtext } {
    variable x
    variable y
    variable can
    
    set entry [$wtext curselection]
    if { $entry != "" } {
        $wtext delete [lindex $entry 0] [lindex $entry end]
        $wtext see [lindex $entry end]
        Function::IntDrawGraphR $can     
    }   
}
proc nasfunanisotropic::errorcntrl { } {
    variable deltax
    variable x
    variable y
    variable tox
    variable entrytype  
    set cntrlx 0
    set cntrly 0
    set cntrltox 0
    set cntrldeltax 0
    set text "Please make sure all activated fields are filled only with numerical values."
    set texteq "Please make sure all activated fields are filled only with \
            numerical values.\nOnly the Y(X) field can be filled with an \
            equation including alphabetical\ncharacters."
    
    if { [string is double -strict $x] || [string is integer -strict $x] } {
        set cntrlx 1
    } 
    if { [string is double -strict $y] || [string is integer -strict $y] } {
        set cntrly 1
    }
    if { [string is double -strict $tox] || [string is integer -strict $tox] } {
        set cntrltox 1
    }
    if { [string is double -strict $deltax] || [string is integer -strict $deltax] } {
        set cntrldeltax 1
    }

    if { $entrytype == "Single Value"  } {
        if { [expr $cntrlx+$cntrly] == 2 } {
            return 1
        } else {
            append text "\n\n"
            append text [= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"]. 
            }
            WarnWin $text
            return 0
        }
    }
    if { $entrytype == "Linear Ramp"  } {
        if { [expr $cntrlx+$cntrly+$cntrldeltax+$cntrltox] == 4 } {
            return 1
        } else {
            append text "\n\n"
            append text [= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrldeltax == 0 } {
                append text "\nDelta X " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrltox == 0 } {
                append text "\nTo X " [= "file is blank or filled with alphabetical characters"]. 
            }
            WarnWin $text
            return 0
        }
    }
    if { $entrytype == "Equation"  } {
        if { [expr $cntrlx+$cntrldeltax+$cntrltox] == 3 } {
            return 1
        } else {
            append text "\n\n"
            append text [= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrldeltax == 0 } {
                append text "\nDelta X " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrltox == 0 } {
                append text "\nTo X " [= "file is blank or filled with alphabetical characters"]. 
            }
            WarnWin $text
            return 0
        }
    }
    if { $entrytype == "Periodic"  } {
        if { [expr $cntrlx+$cntrldeltax+$cntrltox+$cntrly] == 4 } {
            return 1
        } else {
            append text "\n\n"
            append text [= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrldeltax == 0 } {
                append text "\nDelta X " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrltox == 0 } {
                append text "\nTo X " [= "file is blank or filled with alphabetical characters"]. 
            }
            WarnWin $text
            return 0
        }
    }
}

proc nasfunanisotropic::clear { values } {
    variable table
    variable can   
    
    set answer [tk_dialogRAMFull $table.empwiniw [= "information window"] \
            [= "Are you sure you want to clear all  values?"] \
            "" "" gidquestionhead 0 [= "Ok"] [= "Cancel"]]
    if { $answer == 0 } {
        $values delete 0 end
        nasfunanisotropic::IntDrawGraphR $can 
    }    
}

proc nasfunanisotropic::acceptfunc { window } { 
            variable list
            set nasmat_anisotropicshell::plasticity "table"
            set nasmat_anisotropicshell::st_srlist $list
            destroy $window
}

proc nasfunanisotropic::cancelfunc  { window } {

    destroy $window
}

proc nasfunanisotropic::IntDrawGraphR { can } {
    variable list
     if { [llength $list] > 1} {
        set aux [join $list]
        set aux [string trim $aux]
        foreach { x y } $aux {
            lappend aux1 $y
        }     
        NasDrawGraph::DrawCurve $can $aux1 [lindex $aux [expr [llength $aux]-2]] \u03b5 \u03c3  {Stress-Strain Curve} [lindex $aux 0]
     } else {
        $can delete all
    }
}

# namespace eval NasDrawGraph {
#     variable c
#     variable yvalues
#     variable maxx
#     variable xlabel
#     variable ylabel
#     variable title
#     variable initialx
#     variable xfact "" xm "" yfact "" ym "" ymax "" ynummin "" ynummax ""
# 
#     proc DrawCurve { cv yvaluesv maxxv xlabelv ylabelv titlev inix} {
#         Init $cv $yvaluesv $maxxv $xlabelv $ylabelv $titlev $inix
#         Draw
#     }
# }
# 
# proc NasDrawGraph::Init { cv yvaluesv maxxv xlabelv ylabelv titlev inix} {
#     variable c $cv
#     variable yvalues $yvaluesv
#     variable maxx $maxxv
#     variable xlabel $xlabelv
#     variable ylabel $ylabelv
#     variable title $titlev
#     variable initialx $inix
# }
# 
# 
# proc NasDrawGraph::Draw {} {
#     variable c
#     variable yvalues
#     variable maxx
#     variable xlabel
#     variable ylabel
#     variable title
#     variable xfact
#     variable xm
#     variable yfact
#     variable ym
#     variable ymax
#     variable ynummin
#     variable ynummax
#     variable initialx
# 
#     $c delete curve
#     $c delete axestext
#     $c delete titletext
#     $c delete zeroline
# 
#     set inix $initialx
#     set numdivisions [expr [llength $yvalues]-1]
# 
#     set ymax [winfo height $c]
#     set xmax [winfo width $c]
# 
#     set ynummax 0
#     set textwidth 0
#     for {set i 0 } { $i <= $numdivisions } { incr i } {
#         set yval [lindex $yvalues $i]
#         if { $yval > $ynummax } {
#             set ynummax $yval
#         }
#         if { $i == 0 || $yval < $ynummin } {
#             set ynummin $yval
#         }
#     }
#     if { $ynummax == $ynummin } { incr ynummax }
# 
#     set inumtics 8
#     for {set i 0 } { $i < $inumtics } { incr i } {
#         set yvaltext [format "%.4g" [expr $ynummin+$i/double($inumtics-1)*($ynummax-$ynummin)]]
#         regsub {e([+-])00} $yvaltext {e\10} yvaltext
#         set tt [font measure NormalFont $yvaltext]
#         if { $tt > $textwidth } { set textwidth $tt }
#     }
# 
#     set xm [expr $textwidth+10]
#     set textheight [font metrics NormalFont -linespace]
#     set ym [expr int($textheight*1.5)+10]
# 
#     set fam [font configure NormalFont -family]
#     set tsize [expr [font configure NormalFont -size]*2]
#     $c create text [expr $xmax/2] 6 -anchor n -justify center \
#             -text $title -font [list $fam $tsize] -tags titletext
#     
#     $c create line $xm $ym $xm [expr $ymax-$ym] [expr $xmax-$xm] \
#             [expr $ymax-$ym]  -tags axestext
# 
#     set inumtics 8
#     set fam [font configure NormalFont -family]
#     set tsize [expr int([expr [font configure NormalFont -size]*0.5])]
#     for {set i 0 } { $i < $inumtics } { incr i } {
#         set xvaltext [format "%3.1lf" \
#                 [expr $inix+$i/double($inumtics-1)*($maxx-$inix)]]
#         set xval [expr $xm+$i/double($inumtics-1)*($xmax-2*$xm)]
#         set xvalt $xval
#         if { $i == 0 } { set xvalt [expr $xvalt+4] }
#         $c create line $xval [expr $ymax-$ym+2] $xval [expr $ymax-$ym] \
#                 -tags axestext
#         $c create text $xval [expr $ymax-$ym+2] -anchor n -justify center \
#                 -text $xvaltext -font NormalFont -tags axestext
# 
#         set yvaltext [format "%.4g" [expr $ynummin+$i/double($inumtics-1)*($ynummax-$ynummin)]]
#         regsub {e([+-])00} $yvaltext {e\10} yvaltext
#         set yval [expr $ymax-$ym-$i/double($inumtics-1)*($ymax-2*$ym)]
#         set yvalt $yval
#         if { $i == 0 } { set yvalt [expr $yvalt-4] }
#         $c create line [expr $xm-2] $yval $xm $yval -tags axestext
#         $c create text [expr $xm-3] $yvalt -anchor e -justify right \
#                 -text $yvaltext -font [list $fam $tsize] -tags axestext
#     }
#     $c create text 6 6 -anchor nw -justify left \
#             -text $ylabel -font NormalFont -tags axestext
#     set textwidth [font measure NormalFont 0.0]
#     $c create text [expr $xmax-$xm+$textwidth] [expr $ymax-$ym] \
#             -anchor nw -justify left \
#             -text $xlabel -font NormalFont -tags axestext
# 
#     set xfact [expr ($xmax-2.0*$xm)/double($maxx-$inix)]
#     set yfact [expr ($ymax-2.0*$ym)/double($ynummax-$ynummin)]
# 
#     set yval [expr $ymax-$ym-(0.0-$ynummin)*$yfact]
#     if { $yval > $ym && $yval <= [expr $ymax-$ym] } {
#         $c create line $xm $yval [expr $xmax-$xm] $yval -tags zeroline -dash -.-
#     }
# 
#     set xfactdiv [expr ($xmax-2.0*$xm)/double($numdivisions)]
#     set lastyval [expr $ymax-$ym-([lindex $yvalues 0]-$ynummin)*$yfact]
#     for {set i 1 } { $i <= $numdivisions } { incr i } {
#         set yval [expr $ymax-$ym-([lindex $yvalues $i]-$ynummin)*$yfact]
#         $c create line [expr ($i-1)*$xfactdiv+$xm] $lastyval \
#                 [expr $i*$xfactdiv+$xm] $yval -tags curve -width 3 -fill red
#         set lastyval $yval
#     }
# 
#     $c bind curve <ButtonPress-1> "NasDrawGraph::DrawGraphCoords %x %y"
# }
# 
# proc NasDrawGraph::FindClosestPoint { x y } {
#     variable c
# 
#     set mindist2 1e20
#     foreach i [$c find withtag curve] {
#         foreach "ax ay bx by" [$c coords $i] break
#         set vx [expr $bx-$ax]
#         set vy [expr $by-$ay]
#         set alpha [expr $vx*($ax-$x)+$vy*($ay-$y)]
#         set landa [expr -1*$alpha/double($vx*$vx+$vy*$vy)]
#         if { $landa < 0.0 } { set landa 0.0 }
#         if { $landa > 1.0 } { set landa 1.0 }
#         set px [expr $ax+$landa*$vx]
#         set py [expr $ay+$landa*$vy]
# 
#         set dist2 [expr ($px-$x)*($px-$x)+($py-$y)*($py-$y)]
#         if { $dist2 < $mindist2 } {
#             set mindist2 $dist2
#             set minpx $px
#             set minpy $py
#         }
#     }
#     return [list $minpx $minpy]
# }
# 
# proc NasDrawGraph::DrawGraphCoords { x y } {
#     variable c
#     variable xlabel
#     variable ylabel
#     variable xfact
#     variable xm
#     variable yfact
#     variable ym
#     variable ymax
#     variable ynummin
#     variable ynummax
#     variable yvalues
#     variable initialx
# 
#     $c delete coords
#     $c delete coordpoint
# 
#     set ymax [winfo height $c]
#     set xmax [winfo width $c]
#     
#     if { [lindex $yvalues end] < ($ynummax-$ynummin)/2.0 } {
#         foreach "{} {} {} ytitle" [$c bbox titletext] break
#         set ytitle [expr $ytitle+2]
#         set anchor ne
#     } else {
#         set ytitle [expr $ymax-$ym-5]
#         set anchor se
#     }
# 
#     foreach "xcurve ycurve" [NasDrawGraph::FindClosestPoint $x $y] break
# 
#     $c create oval [expr $xcurve-2] [expr $ycurve-2] [expr $xcurve+2] [expr $ycurve+2] \
#             -tags coordpoint
# 
#     set xtext [expr ($xcurve-$xm)/double($xfact)+$initialx]
#     regsub {e([+-])00} $xtext {e\10} xtext
#     set ytext [expr ($ymax-$ym-$ycurve)/double($yfact)+$ynummin]
#     regsub {e([+-])00} $ytext {e\10} ytext
# 
#     $c create text [expr $xmax-6] $ytitle -anchor $anchor -font NormalFont \
#             -text [format "$xlabel: %.4g  $ylabel: %.4g" $xtext $ytext] -tags coords
# 
#     $c bind curve <ButtonRelease-1> "$c delete coords coordpoint; $c bind curve <B1-Motion> {}"
#     $c bind curve <B1-Motion> "NasDrawGraph::DrawGraphCoords %x %y"
# }

# ###########################################################################
# 
# 
#                                   nastran.bas: Write results in *.bas file
# 
# 
# ##########################################################################    
proc nasmat_anisotropicshell::getmatnum { input } {
    variable matid
    set matid $input
    return ""
   
}

proc nasmat_anisotropicshell::writenastran  { matname } {
    
    variable matid 
   
    set alphabet [list A1 B1 C1 D1 E1 F1 G1 H1 I1 J1 K1 L1 M1 N1 O1 P1 Q1 R1 S1 T1 U1 V1 W1 X1 Y1 Z1]
    set gendata [ lrange [ GiD_Info gendata ] 1 end ]
    foreach { name value } $gendata {
        if { [regexp Format_File* $name] } {
            set format $value
        }
    }
    set tables ""
    set aux [ GiD_Info materials]
    foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            lappend tables  $elem
        }
    }
    set matname [string trim $matname]
    array set matinfo [lrange [ GiD_Info materials $matname ] 1 end]
    set matinfo(stress-strain) [base64::decode $matinfo(stress-strain)]
    set names2 [list G11 G12 G13 G22 G23 G33  rho A1 A2 A3 Tref Ge St Sc Ss Cs]          
    set names5 [list  K11 K12 K13 K22 K23 K33 Cp rho Hgen]
    set layout2 [list \
            1 1 1 1 1 1 1 1\
            1 1 1 1 1 1 1 1\
            0 1]
    set type2 [list \
            i r r r r r r r\
            r r r r r r r r\
            0 r]
    set layout5 [list \
            1 1 1 1 1 1 1 1\
            1 1]
    set type5 [list \
            i r r r r r r r\
            r r]
    set values2 $matid
    set mattemp2 0
    set mattemp5 0
    foreach name $names2 {
        if {[lsearch $tables $matinfo($name)]==-1} {
            lappend values2 $matinfo($name)
        } else {
            set mattemp2 1
            lappend values2 1.0
        }
    }
    set values5 $matid
    foreach name $names5 {
        if {[lsearch $tables $matinfo($name)]==-1} {
            lappend values5 $matinfo($name)
            
        } else {
            set mattemp5 1
            lappend values5 1.0
        }
    }
    set result [nasmat_anisotropicshell::writecard $format MAT2 $layout2 $type2 $values2]
    append result "\n[nasmat_anisotropicshell::writecard $format MAT5 $layout5 $type5 $values5]\n"
              
    switch $matinfo(nontype) {
        "elasticplastic" { 
            if { $matinfo(plasticity) != "table" } {
                append result [format "MATS1   %8i         PLASTIC" $matid] [GiD_FormatReal "%#8.5g" $matinfo(plasticity) forcewidthnastran] \
                    [format "%8i%8i" [string index $matinfo(yield_func) 0] [string index $matinfo(harden) 0] ] \
                    [GiD_FormatReal "%#8.5g" $matinfo(initial) forcewidthnastran]   
                if { $matinfo(friction) != "void" } {
                    append result [GiD_FormatReal "%#8.5g" $matinfo(friction) forcewidthnastran] 
                }
            } else {
                append result [format "MATS1   %8i%8i PLASTIC\n" $matid $matid ]
                if  { $matid >= [llength $alphabet ] } {
                    set lineid [lindex $alphabet [expr $matid/[llength $alphabet ] ] ]
                } else {
                    set lineid [lindex $alphabet $matid ]
                }
                append result [format "TABLES1 %8i                                                        +%s%5i \n" $matid $lineid $matid ]
                set numblock 1
                set numline $matid
                foreach pair $matinfo(stress-strain) {
                    if { $numblock != 1 && $numblock !=7 } {
                        append result  [GiD_FormatReal "%#8.5g" [lindex $pair 0] forcewidthnastran]
                        append result  [GiD_FormatReal "%#8.5g" [lindex $pair 1] forcewidthnastran]
                    }
                    if { $numblock == 1 } {
                        append result [ format "+%s%5i" $lineid $numline ]
                        append result  [GiD_FormatReal "%#8.5g" [lindex $pair 0] forcewidthnastran]
                        append result  [GiD_FormatReal "%#8.5g" [lindex $pair 1] forcewidthnastran]
                        set numline [expr {$numline+1} ]                    
                    }
                    if { $numblock == 7} {
                        append result  [GiD_FormatReal "%#8.5g" [lindex $pair 0] forcewidthnastran]
                        append result  [GiD_FormatReal "%#8.5g" [lindex $pair 1] forcewidthnastran]                            
                        append result [ format "+%s%5i\n" $lineid $numline ]
                        set numblock -1
                    }
                    set numblock [expr $numblock+2]
                } 
                if { $numblock == 1 } {
                    append result [ format "+%s%5i    ENDT" $lineid $numline ]
                } else {
                    append result "    ENDT"                                   
                }  
            }  
        }                                                                     
        "nonlinear" {
            append result [format "MATS1   %8i%8i NLELAST\n" $matid $matid ]
            if  { $matid >= [llength $alphabet ] } {
                set lineid [lindex $alphabet [expr $matid/[llength $alphabet ] ] ]
            } else {
                set lineid [lindex $alphabet $matid ]
            }
            append result [format "TABLES1 %8i                                                        +%s%5i \n" $matid $lineid $matid ]
            set numblock 1
            set numline $matid
            foreach pair $matinfo(stress-strain) {
                if { $numblock != 1 && $numblock !=7 } {
                    append result  [GiD_FormatReal "%#8.5g" [lindex $pair 0] forcewidthnastran]
                    append result  [GiD_FormatReal "%#8.5g" [lindex $pair 1] forcewidthnastran]
                }
                if { $numblock == 1 } {
                    append result [ format "+%s%5i" $lineid $numline ]
                    append result  [GiD_FormatReal "%#8.5g" [lindex $pair 0] forcewidthnastran]
                    append result  [GiD_FormatReal "%#8.5g" [lindex $pair 1] forcewidthnastran]
                    set numline [expr {$numline+1} ]                    
                }
                if { $numblock == 7} {
                    append result  [GiD_FormatReal "%#8.5g" [lindex $pair 0] forcewidthnastran]
                    append result  [GiD_FormatReal "%#8.5g" [lindex $pair 1] forcewidthnastran]                            
                    append result [ format "+%s%5i\n" $lineid $numline ]
                    set numblock -1
                }
                set numblock [expr $numblock+2]
            } 
            if { $numblock == 1 } {
                append result [ format "+%s%5i    ENDT" $lineid $numline ]
            } else {
                append result "    ENDT"                                   
            }  
        }
    }          
    append result [nasmat_anisotropicshell::mattemp $matname $matid $mattemp2 $mattemp5]
    return $result
}                                                                                        
                                        
proc nasmat_anisotropicshell::outputformat { value formattype numbertype} { 
    
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
proc nasmat_anisotropicshell::mattemp { matname matid mattemp2 mattemp5} {
     
    set gendata [ lrange [ GiD_Info gendata ] 1 end ]
   foreach { name value } $gendata {
        if { [regexp Format_File* $name] } {
            set format $value
        }
    }
    set output2 ""
    set output5 ""
    set matname [string trim $matname]
    array set matinfo [lrange [ GiD_Info materials $matname ] 1 end]
    set matinfo(stress-strain) [base64::decode $matinfo(stress-strain)]
    set names2 [list G11 G12 G13 G22 G23 G33  rho A1 A2 A3 Ge St Sc Ss]          
    set names5 [list  K11 K12 K13 K22 K23 K33 Cp Hgen]
    set tables ""
    set aux [ GiD_Info materials]
    set index 1 
    foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            lappend tables $elem
            lappend tablesindex $index
            incr index
        }
    }
    if { $mattemp2} {
        set layout2 [list \
                1 1 1 1 1 1 1 1\
                1 1 1 0 1 1 1 1 ]
        set type2 [list \
                i i i i i i i i\
                i i i 0 i i i i]
        set values2 $matid
        foreach name $names2 {
            set tableid [lsearch $tables $matinfo($name)]
            if {$tableid!=-1} {
                lappend values2 [lindex $tablesindex $tableid]
            } else {
                lappend values2 ""
            }
        }
        set output2 [nasmat_anisotropicshell::writecard $format MATT2 $layout2 $type2 $values2]
    }
    if { $mattemp5} {
        set layout5 [list \
                1 1 1 1 1 1 1 1\
                0 1]
        set type5 [list \
                i i i i i i i i\
                0 i]
        set values5 $matid
        foreach name $names5 {
            set tableid [lsearch $tables $matinfo($name)]
            if {$tableid!=-1} {
                lappend values5 [lindex $tablesindex $tableid]
            } else {
                lappend values5 ""
            }            
        }
        set output5 [nasmat_anisotropicshell::writecard $format MATT5 $layout5 $type5 $values5]
    }
    set output ""
    if { $output2 != "" } {
        set output "\n$output2"
    }
    if {$output5 !="" } {
        append output "\n$output5"
    }
    return $output
}
    
proc nasmat_anisotropicshell::tabletemp { } {
         
    set aux [ GiD_Info materials]
    set tableid 1
    set result ""
    foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            set tableinfo [lrange [GiD_Info materials $elem] 1 end]
            set index [lsearch $tableinfo "Value_type*"]
            incr index
            if { [lindex $tableinfo $index] == "vs._Temperature"} {
                set indexvalues [lsearch $tableinfo "Table_Interpolation*"]
                incr indexvalues
                set values [lrange [lindex $tableinfo $indexvalues] 2 end]
                if { $values != "none" } {
                    set values [lrange $values 0 [expr [llength $values]-2]]
                    append result [format "TABLEM1 %8i                                                        +\n" $tableid]
                    set numblock 1
                    foreach {x y} $values {
                        if { $numblock != 1 && $numblock !=7 } {
                            append result [GiD_FormatReal "%#8.5g" $x forcewidthnastran]
                            append result [GiD_FormatReal "%#8.5g" $y forcewidthnastran]
                        }
                        if { $numblock == 1 } {
                            append result "+       "
                            append result [GiD_FormatReal "%#8.5g" $x forcewidthnastran]
                            append result [GiD_FormatReal "%#8.5g" $y forcewidthnastran]
                        }
                        if { $numblock == 7} {
                            append result [GiD_FormatReal "%#8.5g" $x forcewidthnastran]
                            append result [GiD_FormatReal "%#8.5g" $y forcewidthnastran]                            
                            append result  "+\n" 
                            set numblock -1
                        }
                        set numblock [expr $numblock+2]
                    } 
                    if { $numblock == 1 } {
                        append result "+           ENDT"
                    } else {
                        append result "    ENDT\n"                                   
                    }  
                }  
               
            }
             incr tableid
        }
    }
    return $result
}
proc nasmat_anisotropicshell::writecard {format card layout type values} {

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
 