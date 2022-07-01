namespace eval nasmat { } {
    variable young
    variable shear
    variable nu
    variable expansion
    variable conduc
    variable spheat
    variable convection 
    variable heatgen
    variable limtension
    variable limcompression
    variable limshear
    variable density
    variable damping 
    variable tempref 
    variable nontype  
    variable plasticity
    variable harderule 
    variable yieldfunc
    variable limit1
    variable limit2
    variable updatenon
    variable st_srlist
    variable window
    variable matid
}

proc nasmat::initvars { } { 
    variable young ""
    variable shear ""
    variable nu ""
    variable expansion ""
    variable conduc ""
    variable spheat ""
    variable convection ""
    variable heatgen ""
    variable limtension ""
    variable limcompression ""
    variable limshear ""
    variable density ""
    variable damping  ""
    variable tempref   ""
    variable nontype none
    variable plasticity ""
    variable harderule "1.Isotropic"
    variable yieldfunc "1.Von-Mises" 
    variable limit1 ""
    variable limit2 ""
    variable updatenon 0
    variable st_srlist ""
}
# ###########################################################################
# 
# 
#                                      Comunication with GiD
# 
# 
# ##########################################################################
proc nasmat::ComunicateWithGiD { op args } {
    variable window
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            set window $PARENT
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set f [frame $PARENT.f]
            grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 
            grid columnconf $f 0 -weight 1
            grid rowconf $f 0 -weight 1
            grid rowconf $PARENT $ROW -weight 1
            grid columnconf $PARENT 0 -weight 1
            upvar \#0 $GDN GidData
            nasmat::initwindow $f 
            nasmat::initvars
            nasmat::getvalues $GDN $STRUCT
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            if { [ nasmat::errorcntrl $window] } {
                nasmat::dump $GDN $STRUCT
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
proc nasmat::initwindow { parent } {
    
    set tfglobal [ TitleFrame $parent.fglobal -text [= "Isotropic Material"] -relief groove -bd 2 ]
    set fglobal [ $tfglobal getframe  ]
    
    set nbglobal [NoteBook $fglobal.nbglobal ]
    set page1 [$nbglobal insert 0 page1 -text [= "Stiffness"]]
    set fpage1 [ $nbglobal getframe page1 ]
    set page2 [ $nbglobal insert 1 page2 -text [= "Thermal"]]
    set fpage2 [ $nbglobal getframe page2 ]
    set page3 [ $nbglobal insert 2 page3 -text [= "Others"]]
    set fpage3 [ $nbglobal getframe page3 ]
    $nbglobal raise page1
    
    set tfstiffness [ TitleFrame $fpage1.fstiffness -text [= "Stiffness"] -relief groove -bd 2 ]
    set fstiffness [ $tfstiffness  getframe ]
    
    set lyoung [ Label $fstiffness.lyoung -text "E" -helptext [= "Young Modulus"]] 
    set eyoung [ entry $fstiffness.eyoung -textvariable nasmat::young ]
    set byoung [menubutton $fstiffness.byoung -text [= "Temp"]... -menu $fstiffness.byoung.myoung \
            -bd 2 -relief raised ]
    set myoung [menu $byoung.myoung -title NULL -postcommand "nasmat::updatetablelist $byoung.myoung nasmat::young"]
    
    set lshear [ Label $fstiffness.lshear -text "G" -helptext [= "Shear Modulus"]]
    set eshear [ entry $fstiffness.eshear -textvariable nasmat::shear ]
    set bshear [menubutton $fstiffness.bshear -text [= "Temp"]... -menu $fstiffness.bshear.mshear \
            -bd 2 -relief raised ]
    set mshear [menu $bshear.mshear -title NULL -postcommand "nasmat::updatetablelist $bshear.mshear nasmat::shear"]
    
    set lnu [ Label $fstiffness.lnu -text [= "Poisson"] -helptext [= "Poisson's Coef."]]
    set enu [ entry $fstiffness.enu -textvariable nasmat::nu ]
    set bnu [menubutton $fstiffness.bnu -text [= "Temp"]... -menu $fstiffness.bnu.mnu \
            -bd 2 -relief raised ]
    set mnu [menu $bnu.mnu -title NULL -postcommand "nasmat::updatetablelist $bnu.mnu nasmat::nu"]
    
    set bisotropic1 [ Button $fstiffness.bisotropic1 -text "G \u2192 \u03b7" -helptext [= "Obtain values for \
                G, nu\n using formula E=2(1+NU)G"] -command "nasmat::isotropic [list $parent G]"  -width 12 ]
    set bisotropic2 [ Button $fstiffness.bisotropic2 -text "G \u2190 \u03b7" -helptext [= "Obtain values for \
                G, nu\n using formula E=2(1+NU)G"] -command "nasmat::isotropic [list $parent nu]"  -width 12 ]
    
    set tflimit [ TitleFrame $fpage1.flimit -text [= "Limit Stress"] -relief groove -bd 2 ]
    set flimit [ $tflimit getframe ]
    
    set llimtension [ Label $flimit.llimtension -text [= "Tension"] -helptext [= "Allowable stress in tension"]]
    set elimtension [ entry $flimit.elimtension -textvariable nasmat:::limtension ]
    
    set blimtension [menubutton $flimit.blimtension -text [= "Temp"]... -menu $flimit.blimtension.mlimtension \
            -bd 2 -relief raised ]
    set mlimtension [menu $blimtension.mlimtension -title NULL \
            -postcommand "nasmat::updatetablelist $blimtension.mlimtension nasmat::limtension"]
    
    set llimcompression [ Label $flimit.llimcompression -text [= "Compression"] \
            -helptext [= "Allowable stress in compression"]]
    set elimcompression [ entry $flimit.elimcompression -textvariable nasmat:::limcompression ]
    set blimcompression [menubutton $flimit.blimcompression -text [= "Temp"]... -menu $flimit.blimcompression.mlimcompression \
            -bd 2 -relief raised ]
    set mlimcompression [menu $blimcompression.mlimcompression -title NULL \
            -postcommand "nasmat::updatetablelist $blimcompression.mlimcompression nasmat::limcompression"]
    
    set llimshear [ Label $flimit.llimshear -text [= "Shear"] -helptext [= "Allowable stress in shear"]]
    set elimshear [ entry $flimit.elimshear -textvariable nasmat:::limshear ]
    set blimshear [menubutton $flimit.blimshear -text [= "Temp"]... -menu $flimit.blimshear.mlimshear \
            -bd 2 -relief raised ]
    set mlimshear [menu $blimshear.mlimshear -title NULL \
            -postcommand "nasmat::updatetablelist $blimshear.mlimshear nasmat::limshear"]
    
    set tfthermal [ TitleFrame $fpage2.fthermal -text [= "Thermal"] -relief groove -bd 2 ]
    set fthermal [ $tfthermal  getframe ]
    
    set lexpansion [ Label $fthermal.lexpansion -text [= "Expansion Coeff."] \
            -helptext [= "Thermal expansion coefficient."]]
    set eexpansion [ entry $fthermal.eexpansion -textvariable nasmat::expansion ]
    set bexpansion [menubutton $fthermal.bexpansion -text [= "Temp"]... -menu $fthermal.bexpansion.mexpansion \
            -bd 2 -relief raised ]
    set mexpansion [menu $bexpansion.mexpansion -title NULL \
            -postcommand "nasmat::updatetablelist $bexpansion.mexpansion nasmat::expansion"]
    
    
    set lcond [ Label $fthermal.lcond -text [= "Conductivity"] -helptext [= "Conductivity K"]]
    set econd [ entry $fthermal.econd -textvariable nasmat::conduc ]
    set bcond [menubutton $fthermal.bcond -text [= "Temp"]... -menu $fthermal.bcond.mcond \
            -bd 2 -relief raised ]
    set mcond [menu $bcond.mcond -title NULL \
            -postcommand "nasmat::updatetablelist $bcond.mcond nasmat::conduc"]
    
    
    set lspheat [ Label $fthermal.lspheat -text [= "Specific Heat"] \
            -helptext [= "Heat capacity per unit mass at constant pressure"]]
    set espheat [ entry $fthermal.espheat -textvariable nasmat::spheat ]
    set bspheat [menubutton $fthermal.bspheat -text [= "Temp"]... -menu $fthermal.bspheat.mspheat \
            -bd 2 -relief raised ]
    set mspheat [menu $bspheat.mspheat -title NULL \
            -postcommand "nasmat::updatetablelist $bspheat.mspheat nasmat::spheat"]
    
    
    set lconvection [ Label $fthermal.lconvection -text [= "Free Convection"] \
            -helptext [= "Free Convection heat transfer coefficient."]]
    set econvection [ entry $fthermal.econvection -textvariable nasmat::convection ]
    set bconvection [menubutton $fthermal.bconvection -text [= "Temp"]... -menu $fthermal.bconvection.mconvection \
            -bd 2 -relief raised ]
    set mconvection [menu $bconvection.mconvection -title NULL \
            -postcommand "nasmat::updatetablelist $bconvection.mconvection nasmat::convection"]
    
    set lheatgen [ Label $fthermal.lheatgen -text [= "Heat Generation"] \
            -helptext [= "Heat Generation capability."]]
    set eheatgen [ entry $fthermal.eheatgen -textvariable nasmat::heatgen ]
    set bheatgen [menubutton $fthermal.bheatgen -text [= "Temp"]... -menu $fthermal.bheatgen.mheatgen \
            -bd 2 -relief raised ]
    set mheatgen [menu $bheatgen.mheatgen -title NULL \
            -postcommand "nasmat::updatetablelist $bheatgen.mheatgen nasmat::heatgen"]
    
    set tfothers [ TitleFrame $fpage3.fothers -text [= "Others"] -relief groove -bd 2 ]
    set fothers [ $tfothers getframe ] 
    
    set ldensity [ Label $fothers.ldensity -text [= "Mass Density"] \
            -helptext [= "Weight density may be used if the value 1/g is entered on the PARAM, WTMASS entry"]]
    set edensity [ entry $fothers.edensity -textvariable nasmat::density ]
    set bdensity [menubutton $fothers.bdensity -text [= "Temp"]... -menu $fothers.bdensity.mdensity \
            -bd 2 -relief raised ]
    set mdensity [menu $bdensity.mdensity -title NULL \
            -postcommand "nasmat::updatetablelist $bdensity.mdensity nasmat::density"]
    
    
    set ldamping [ Label $fothers.ldamping -text [= "Damping Coef."] \
            -helptext [= "To obtain the damping coefficient, multiply the critical damping ratio C/C0, by 2.0."]]
    set edamping [ entry $fothers.edamping -textvariable nasmat::damping ]
    set bdamping [menubutton $fothers.bdamping -text [= "Temp"]... -menu $fothers.bdamping.mdamping \
            -bd 2 -relief raised ]
    set mdamping [menu $bdamping.mdamping -title NULL \
            -postcommand "nasmat::updatetablelist $bdamping.mdamping nasmat::damping"]
    
    
    set ltempref [ Label $fothers.ltempref -text [= "Temp. Ref."] \
            -helptext [= "Reference temperature for the calculation of thermal loads."]]
    set etempref [ entry $fothers.etempref -textvariable nasmat::tempref ]
    
    
    set fnonlinear [ frame $fglobal.fnonlinear ]
    set bnonlinear [ button $fnonlinear.bnonlinear -text [= "NonLinear"]... -command "nasmat::initnonlinearwindow $parent" \
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
    grid columnconf $fstiffness 1 -weight 1
    
    
    grid $lyoung -row 0 -column 0 -sticky e
    grid $eyoung -row 0 -column 1 -sticky ew -pady 2
    grid $byoung -row 0 -column 2 -sticky ew -padx 4
    
    grid $lshear -row 1 -column 0 -sticky e
    grid $eshear -row 1 -column 1 -sticky ew -pady 2
    grid $bshear -row 1 -column 2 -sticky ew -padx 4 
    
    grid $lnu -row 2 -column 0 -sticky e
    grid $enu -row 2 -column 1 -sticky ew -pady 2
    grid $bnu -row 2 -column 2 -sticky ew -padx 4 
    
    grid $bisotropic1 -row 3 -column 1 -pady 2  -sticky w -padx 8
    grid $bisotropic2 -row 4 -column 1 -pady 1  -sticky w -padx 8
    
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
    
    grid $lexpansion -row 0 -column 0 -sticky e
    grid $eexpansion -row 0 -column 1 -sticky ew -pady 2
    grid $bexpansion -row 0 -column 2 -sticky ew -padx 4 
    
    grid $lcond -row 1 -column 0 -sticky e
    grid $econd -row 1 -column 1 -sticky ew -pady 2
    grid $bcond -row 1 -column 2 -sticky ew -padx 4 
    
    grid $lspheat -row 2 -column 0 -sticky e
    grid $espheat -row 2 -column 1 -sticky ew -pady 2
    grid $bspheat -row 2 -column 2 -sticky ew -padx 4 
    
    grid $lconvection -row 3 -column 0 -sticky e
    grid $econvection -row 3 -column 1 -sticky ew -pady 2
    grid $bconvection -row 3 -column 2 -sticky ew -padx 4     
    
    grid $lheatgen -row 4 -column 0 -sticky e
    grid $eheatgen -row 4 -column 1 -sticky ew -pady 2
    grid $bheatgen -row 4 -column 2 -sticky ew -padx 4   
    
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
proc nasmat::updatetablelist { widget varname} { 
    
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
proc nasmat::initnonlinearwindow { parent } {
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
    
    set rbnone [ radiobutton $ftype.rbnone -text [= "None"] -variable nasmat::nontype \
            -value none -command "event generate $topname <<none>>" ]
    set rbnonlinear [ radiobutton $ftype.rbnonlinear -text [= "Nonlinear Elastic"] -variable nasmat::nontype \
            -value nonlinear -command "event generate $topname <<nonlinear-elastic>>" ]
    set rbelastplas [ radiobutton $ftype.rbelastplas -text [= "Elasto-Plastic"] -variable nasmat::nontype \
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
    set eplasticity [ entry $fprop.eplasticity -textvariable nasmat::plasticity -disabledbackground $bgcolor -bg white]
    bind $topname <<none>> "+ $eplasticity configure -state disabled "
    bind $topname <<nonlinear-elastic>> "+ $eplasticity configure -state normal"
    bind $topname <<elasto-plastic>> "+ $eplasticity configure -state normal "
    set bplasticity [ Button $fprop.bplasticity -text [= "Function"]... \
            -helptext [= "For more than a single slope in the plastic range, the stress-strain data must be supplied on a table"] \
            -command "nasfunction::initwindow $topname nasmat::plasticity" \
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
            -textvariable nasmat::harderule]
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
                4.Drucker-Prager] -textvariable nasmat::yieldfunc ]
    bind $topname <<none>> "+ $cbyieldfunc configure -state disabled -entrybg $bgcolor"
    bind $topname <<nonlinear-elastic>> "+ $cbyieldfunc configure -state disabled -entrybg $bgcolor"
    bind $topname <<elasto-plastic>> "+ $cbyieldfunc configure -state normal -entrybg white"
    
    set llimit1 [ Label $fyield.llimit1 -text [= "Initial Yield Value"] \
            -helptext [= "Initial yield stress for Von  Mises and Tresca yield criteria"] \
            -disabledforeground grey60 -foreground black ]
    bind $topname <<none>> "+ $llimit1 configure -state disabled  "
    bind $topname <<nonlinear-elastic>> "+ $llimit1 configure -state disabled "
    bind $topname <<elasto-plastic>> "+ $llimit1 configure -state normal "
    set elimit1 [ entry $fyield.elimit1 -textvariable nasmat::limit1 -bg white -disabledbackground $bgcolor]
    bind $topname <<none>> "+ $elimit1 configure -state disabled "
    bind $topname <<nonlinear-elastic>> "+ $elimit1 configure -state disabled "
    bind $topname <<elasto-plastic>> "+ $elimit1 configure -state normal "
    set llimit2 [ Label $fyield.llimit2 -text [= "Friction Angle"] \
            -helptext [= "Friction angle (measured in degrees) for the Mohr-Coulomb and Drucker-Prager yield criteria"].\
            -disabledforeground grey60 -foreground black ]
    bind $topname <<none>> "+ $llimit2 configure -state disabled"
    bind $topname <<nonlinear-elastic>> "+ $llimit2 configure -state disabled"
    bind $topname <<elasto-plastic>> "+ $llimit2 configure -state normal"
    set elimit2 [ entry $fyield.elimit2 -textvariable nasmat::limit2 -bg white -disabledbackground $bgcolor]
    bind $topname <<none>> "+ $elimit2 configure -state disabled "
    bind $topname <<nonlinear-elastic>> "+ $elimit2 configure -state disabled "
    bind $topname <<elasto-plastic>> "+ $elimit2 configure -state normal "
    
    set fbuttons [ frame $topname.fbuttons ]
    
    set baccept [ button $fbuttons.baccept -text [= "Accept"] \
            -underline 0 -command "nasmat::acceptnon $topname" -pady 3 -padx 8]
    set bcancel [ button $fbuttons.bcancel -text [= "Cancel"] \
            -underline 0 -command "nasmat::cancelnon $topname" -pady 3 -padx 8]
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
    
    bind $topname <<none>> "+ set nasmat::plasticity {}; set nasmat::limit1 {}; set nasmat::limit2 {} "
    bind $topname <<none>> "+ set nasmat::limit1 {}; set nasmat::limit2 {} "
    
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
#                                        Automatic calculation of nu,G,E using E=2(1+nu)G
# 
# 
# ##########################################################################

proc nasmat::isotropic { window var} {
    
    variable young
    variable shear
    variable nu
    
    set message ""
    foreach value [list [string trim $young] [string trim $shear] [string trim $nu]] {
        if { ![string is double [string trim $value]]  } {
            append message [= "'%s' is not a valid input" $value]
        }
    }
    if { $message != ""} {
        WarnWin $message
        return
    }
    set counter 0
    foreach value [list [string trim $young] [string trim $shear] [string trim $nu]] {
        if { $value == ""  } {
            incr counter 
        }
    }
    if { $counter >= 2 } {
        WarnWin [= "There are more than one entry blank. Please check for errors"]
        return
    }
    if {  $var == "nu" && [string trim $nu] != ""} {
        set shear  [format %#8.3g [ expr {$young/double(2*(1+$nu))} ] ]
        set shear [string trim $shear]
        return    
    }
    if {  $var == "G" && [string trim  $shear] != ""} {
        set nu [format %#4.2f [ expr {$young/double(2*$shear)-1} ] ]
        set nu [string trim $nu]
        return        
    }
    if { [string trim  $shear] != "" && [string trim $young] == "" && [string trim $nu] != "" } {
        set young [format %#8.3g [ expr {2*(1+$nu)*$shear} ]  ]
        set young [string trim $young]
        return        
    }
}
# ###########################################################################
# 
# 
#                                       Control errors
# 
# 
# ##########################################################################      

proc nasmat::errorcntrl { window } { 
    
    variable young
    variable shear
    variable nu
    variable expansion
    variable conduc
    variable spheat
    variable convection 
    variable heatgen
    variable limtension
    variable limcompression
    variable limshear
    variable density
    variable damping 
    variable tempref 
    
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
    set varvaluesstiffness [ list $young $shear $nu  $limtension $limcompression $limshear ]
    foreach value $varvaluesstiffness {
        if { ![string is double [string trim $value]] } {
            set addmsg 1
            foreach tablename $tables { 
                if { $value == $tablename } {
                    set addmsg 0
                    break
                }
            }
            if { $addmsg } {
                append messagestiffness [= "'%s' is not a valid input" $value]
                set writestiffness 1
            }
        }
    }
    set messagethermal [= "Problems found in Thermal tab"]:\n
    set varvaluesthermal [list $expansion $conduc $spheat $convection]
    foreach value $varvaluesthermal {
        if { ![string is double [string trim $value]] } {
            set addmsg 1
            foreach tablename $tables { 
                if { $value == $tablename } {
                    set addmsg 0
                    break
                }
            }
            if { $addmsg } {
                append messagethermal [= "'%s' is not a valid input" $value]
                set writethermal 1
            }
        }
    }
    set messageothers [= "Problems found in Others tab"]:\n
    set varvaluesothers [list $density $damping $tempref ] 
    foreach value $varvaluesothers {
        if { ![string is double [string trim $value]] } {
            set addmsg 1
            foreach tablename $tables { 
                if { $value == $tablename } {
                    set addmsg 0
                    break
                }
            }
            if { $addmsg } {
                append messageothers [= "'%s' is not a valid input" $value]
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

proc nasmat::acceptnon { window } { 
    
    variable updatenon
    if { [nasmat::errorcntrlnon $window] } {
        set updatenon 1 
        destroy $window
    } else {
        return
    }
}
proc nasmat::errorcntrlnon { window } {
    
    variable nontype 
    variable plasticity
    variable harderule
    variable yieldfunc 
    variable limit1
    variable limit2 
    set message ""
    switch $nontype {
        "nonlinear" { 
            if { $plasticity != "table" } {
                if { ![string is double $plasticity] } {
                    append message [= "Plasticity Modulus has an invalid input"]
                }
            }
        }
        "elasticplastic" {
            if { $plasticity != "table" } {
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

proc nasmat::cancelnon { window } { 
    
    variable updatenon
    set updatenon 0
    destroy $window
}
# ###########################################################################
# 
# 
#                                   ComuniacteWithGiD: dump values in materials file
# 
# 
# ##########################################################################    

proc nasmat::dump { GDN STRUCT } {
    
    variable young 
    variable shear 
    variable nu 
    variable expansion 
    variable conduc 
    variable spheat 
    variable convection 
    variable heatgen
    variable limtension 
    variable limcompression 
    variable limshear 
    variable density 
    variable damping  
    variable tempref   
    variable nontype 
    variable plasticity
    variable harderule
    variable yieldfunc 
    variable limit1
    variable limit2 
    variable updatenon
    variable st_srlist
    
    array set values [ list young [list $young young] shear [list $shear mo_shear] nu [list $nu poisson] \
            density [list $density density] tempref [list $tempref temp_ref] limtension [list $limtension tension] \
            limcompression [list $limcompression compression] limshear [list $limshear shear] damping [list $damping damping] \
            expansion [list $expansion expansion] conduc [list $conduc conductivity] spheat [list $spheat spec_heat] \
            convection [list $convection free_conv] heatgen [list $heatgen heatgen]] 
    set names [array names values]    
    foreach item $names {
        set values($item) [list [string trim [lindex $values($item) 0]] [lindex $values($item) 1]]
        if  { [lindex $values($item) 0] == "" } {
            DWLocalSetValue $GDN $STRUCT [lindex $values($item) 1] void
        } else {
            DWLocalSetValue $GDN $STRUCT [lindex $values($item) 1] [lindex $values($item) 0]
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

proc nasmat::getvalues { GDN STRUCT } {
    upvar \#0 $GDN GidData
    variable plasticity
    variable st_srlist
    
    variable young $GidData($STRUCT,VALUE,3)
    variable shear $GidData($STRUCT,VALUE,4) 
    variable nu $GidData($STRUCT,VALUE,5)
    variable density $GidData($STRUCT,VALUE,6)
    variable tempref $GidData($STRUCT,VALUE,7)   
    variable limtension $GidData($STRUCT,VALUE,8)
    variable limcompression $GidData($STRUCT,VALUE,9)
    variable limshear $GidData($STRUCT,VALUE,10)
    variable damping $GidData($STRUCT,VALUE,11)
    variable expansion $GidData($STRUCT,VALUE,12)
    variable conduc $GidData($STRUCT,VALUE,13)
    variable spheat $GidData($STRUCT,VALUE,14)
    variable convection $GidData($STRUCT,VALUE,15)
    variable heatgen $GidData($STRUCT,VALUE,16)
    variable nontype $GidData($STRUCT,VALUE,17)
    array set values [ list young $young shear $shear nu $nu density $density tempref $tempref limtension $limtension \
            limcompression $limcompression limshear $limshear damping $damping expansion $expansion conduc $conduc \
            spheat $spheat convection $convection heatgen $heatgen] 
    set names [array names values]
    foreach item $names {
        if { $values($item) == "void" } {
            set $item ""
        }
    }
    
    switch $nontype {
        "none" {}
        "nonlinear" { 
            variable plasticity $GidData($STRUCT,VALUE,18) 
        }
        "elasticplastic" {
            variable plasticity $GidData($STRUCT,VALUE,18)
            variable harderule $GidData($STRUCT,VALUE,19)
            variable yieldfunc $GidData($STRUCT,VALUE,20)
            variable limit1 $GidData($STRUCT,VALUE,21)
            variable limit2 $GidData($STRUCT,VALUE,22)
            if { $limit2 == "void" } {
                set limit2 ""
            }
        }
    }
    if { $plasticity == "table" } {
        set st_srlist [base64::decode $GidData($STRUCT,VALUE,23) ]
    }
    
} 

# ###########################################################################
# 
# 
#                                    Namespaces to create tables 
# 
# 
# ##########################################################################    

namespace eval nasfunction {
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
proc  nasfunction::getvalues { entries } {
    variable table
    
    set nelems [lindex $entries 1]
    set nelems [expr $nelems-1] 
    for { set i 2 } { $i <= $nelems  } { incr i 2 } {
        set x [lindex $entries $i ]
        set y [lindex $entries [expr $i+1]]
        $table insert end "[format %#16e $x] [format %#16e $y]"
    }
    
}

proc nasfunction::initwindow { parent varname } {
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
    
    if  { $nasmat::st_srlist != "void" } {
        set  list $nasmat::st_srlist
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
            -listvariable nasfunction::list -selectmode extended]
    $sw setwidget $table
    bind [$table bodypath] <Double-ButtonPress-1> { nasfunction::edit $nasfunction::table }
    set bbox [ButtonBox $f1.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $nasfunction::get -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Edit entry"] -command "nasfunction::edit $table"
    $bbox add -image $nasfunction::delete -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Delete entry"] -command "nasfunction::delete $table"
    
    #---------------------------Crear Data Entry-------------------------------------------------#
    set pw2 [$pw add -weight 1]
    set pane2 [$pw getframe 1]
    set title2 [TitleFrame $pane2.data -relief groove -bd 2 -text [= "Data Entry"] -side left]
    set f2 [$title2 getframe]
    
    catch { unset bgcolor }
    set bgcolor [$f2 cget -background]
    set nasfunction::entrytype "Single Value"
    trace variable nasfunction::entrytype w "nasfunction::modify ;# "
    
    frame $f2.f
    radiobutton $f2.f.single -text [= "Single Value"] -var nasfunction::entrytype \
        -value "Single Value"  -selectcolor white 
    radiobutton $f2.f.linear -text [= "Linear Ramp"] -var nasfunction::entrytype \
        -value "Linear Ramp" -selectcolor white 
    radiobutton $f2.f.equation -text [= "Equation"] -var nasfunction::entrytype \
        -value "Equation" -selectcolor white
    radiobutton $f2.f.periodic -text [= "Periodic"] -var nasfunction::entrytype \
        -value "Periodic" -selectcolor white
    
    set nasfunction::x "" 
    set nasfunction::y ""
    set nasfunction::deltax ""
    set nasfunction::tox ""
    set nasfunction::toy ""   
    set fentries [ frame $f2.fentries ]
    set ldeltax [label $fentries.ldeltax -text [= "Delta X"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled ]
    set edeltax [entry $fentries.edeltax -textvariable nasfunction::deltax \
            -justify left -bd 2 -relief sunken  -background $bgcolor \
            -state disabled ] 
    set lx [label $fentries.lx -text "X" -justify right ]
    set ex [entry $fentries.ex -textvariable nasfunction::x -justify left \
            -bd 2  -relief sunken ]
    focus $ex
    set ly [label $fentries.ly -text "Y" -justify right -disabledforeground grey60 \
            -foreground black -state normal ]
    set ey [entry $fentries.ey -textvariable nasfunction::y -justify left  -bd 2 \
            -relief sunken -state normal ]
    set ltox [label $fentries.ltox -text [= "To X"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled ]
    set etox [entry $fentries.etox -textvariable nasfunction::tox -justify left \
            -bd 2  -relief sunken -background $bgcolor -state disabled ]
    set ltoy [label $fentries.ltoy -text [= "To Y"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled ]
    set fetoy [frame $fentries.etoy] 
    set etoy [entry $fetoy.e -textvariable nasfunction::toy -justify left \
            -bd 2 -relief sunken -background $bgcolor -state disabled]
    set examples { 3*x+log(x) pow(x,2)*exp(x) x*cos(3*x) sqrt(x+2)+sinh(pow(x,3)) \
        atan(x) abs(x) }
    set etoy2 [ComboBox $fetoy.cb -textvariable nasfunction::toy  \
            -background $bgcolor -values $examples]
    
    frame $pane2.fadd 
    button $pane2.fadd.badd -text [= "Add"] -underline 1 -padx 5 -command "nasfunction::add $table" 
    button $pane2.fadd.bclear -text [= "Clear All"] -underline 1 -padx 5 \
        -command "nasfunction::clear $table"  
    frame $pane2.fradio
    set nasfunction::insertype end
    radiobutton $pane2.fradio.end -text [= "Add at End"] -variable  nasfunction::insertype \
        -justify left -value end 
    radiobutton $pane2.fradio.no -text [= "Add before Selected"] -variable  nasfunction::insertype \
        -value no 
    set can [canvas $pane2.can -relief sunken -bd 2 -bg white -width 130 -height 100]
    set fbuttons [ frame $w.fbuttons ]
    set baccept [ button $fbuttons.baccept -text [= "Accept"] -underline 0 -pady 3 -padx 8 -command "nasfunction::acceptfunc $topname"]
    set bcancel [ button $fbuttons.bcancel -text [= "Cancel"] -underline 0 -pady 3 -padx 8 -command "nasfunction::cancelfunc $topname" ]
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
    bind $can <Configure> "nasfunction::IntDrawGraphR $can ;#"
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
proc nasfunction::modify { } {
    
    if { ![winfo exists $nasfunction::ldeltax] } { return }
    
    catch { unset bgcolor }
    set bgcolor [$nasfunction::ldeltax cget -background]  
    
    if { $nasfunction::entrytype == "Single Value" } {
        set nasfunction::deltax "" 
        set nasfunction::x ""
        set nasfunction::y ""
        set nasfunction::tox ""
        set nasfunction::toy ""
        $nasfunction::ldeltax configure -state disable  -text [= "Delta X"]
        $nasfunction::edeltax configure -state disable -background $bgcolor 
        $nasfunction::ly configure -state normal
        $nasfunction::ey configure -state normal -background white
        $nasfunction::ltox configure -state disable  
        $nasfunction::etox configure -state disable -background $bgcolor
        $nasfunction::ltoy configure -state disabled -text [= "To Y"]
        $nasfunction::etoy configure -state disabled -background $bgcolor
        
        grid $nasfunction::etoy
        grid remove $nasfunction::etoy2 
        
        
    }
    if { $nasfunction::entrytype == "Linear Ramp" } {
        set nasfunction::deltax "" 
        set nasfunction::x ""
        set nasfunction::y ""
        set nasfunction::tox ""
        set nasfunction::toy ""
        $nasfunction::ldeltax configure -state normal -text [= "Delta X"]
        $nasfunction::edeltax configure -state normal -background white
        $nasfunction::ly configure -state normal
        $nasfunction::ey configure -state normal -background white
        $nasfunction::ltox configure -state normal  
        $nasfunction::etox configure -state normal -background white
        $nasfunction::ltoy configure -state normal -text [= "To Y"]
        $nasfunction::etoy configure -state normal -background white 
        grid $nasfunction::etoy
        grid remove $nasfunction::etoy2 
    }
    if { $nasfunction::entrytype == "Equation" } {
        set nasfunction::deltax "" 
        set nasfunction::x ""
        set nasfunction::y ""
        set nasfunction::tox ""
        set nasfunction::toy ""
        $nasfunction::ldeltax configure -state normal -text [= "Delta X"]
        $nasfunction::edeltax configure -state normal -background white
        $nasfunction::ly configure -state disabled
        $nasfunction::ey configure -state disabled -background $bgcolor
        $nasfunction::ltox configure -state normal  
        $nasfunction::etox configure -state normal -background white
        $nasfunction::ltoy configure -state normal -text "Y(X)"
        $nasfunction::etoy configure -state normal -background white 
        grid $nasfunction::etoy2
        grid remove $nasfunction::etoy 
    }
    if { $nasfunction::entrytype == "Periodic" } {
        set nasfunction::deltax "" 
        set nasfunction::x ""
        set nasfunction::y ""
        set nasfunction::tox ""
        set nasfunction::toy ""
        $nasfunction::ldeltax configure -state normal -text [= "Period"]
        $nasfunction::edeltax configure -state normal -background white
        $nasfunction::ly configure -state normal
        $nasfunction::ey configure -state normal -background white
        $nasfunction::ltox configure -state normal  
        $nasfunction::etox configure -state normal -background white
        $nasfunction::ltoy configure -state disabled -text [= "To Y"]
        $nasfunction::etoy configure -state disabled -background $bgcolor 
        grid $nasfunction::etoy
        grid remove $nasfunction::etoy2 
    } 
}



proc nasfunction::add { wtext } {
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
    nasfunction::IntDrawGraphR $can 
}
proc nasfunction:::edit { table } {
    
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


proc  nasfunction::delete { wtext } {
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
proc nasfunction::errorcntrl { } {
    variable deltax
    variable x
    variable y
    variable tox
    variable entrytype  
    set cntrlx 0
    set cntrly 0
    set cntrltox 0
    set cntrldeltax 0
    set text [= "Please make sure all activated fields are filled only with numerical values"].
    set texteq [= "Please make sure all activated fields are filled only with \
            numerical values.\nOnly the Y(X) field can be filled with an \
            equation including alphabetical\ncharacters."]
    
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
            append text \n\n[= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrly == 0 } {
                append  text "\nY " [= "file is blank or filled with alphabetical characters"]. 
            }
            WarnWin $text
            return 0
        }
    }
    if { $entrytype == "Linear Ramp"  } {
        if { [expr $cntrlx+$cntrly+$cntrldeltax+$cntrltox] == 4 } {
            return 1
        } else {
            append text "\n\n" [= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrldeltax == 0 } {
                append text "\n" [= "Delta X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrltox == 0 } {
                append text "\n" [= "To X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            WarnWin $text
            return 0
        }
    }
    if { $entrytype == "Equation"  } {
        if { [expr $cntrlx+$cntrldeltax+$cntrltox] == 3 } {
            return 1
        } else {
            append texteq "\n\n" [= "Errors found"]:
            if { $cntrlx == 0 } {
                append texteq "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrltox == 0 } {
                append texteq "\n" [= "To X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrldeltax == 0 } {
                append texteq "\n" [= "Delta X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            WarnWin $texteq
            return 0
        }
    }
    if { $entrytype == "Periodic"  } {
        if { [expr $cntrlx+$cntrldeltax+$cntrltox+$cntrly] == 4 } {
            return 1
        } else {
            append text "\n\n" [= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"]. 
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrldeltax == 0 } {
                append text "\n" [= "Delta X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrltox == 0 } {
                append text "\n" [= "To X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            WarnWin $text
            return 0
        }
    }
}

proc nasfunction::clear { values } {
    variable table
    variable can   
    
    set answer [tk_dialogRAMFull $table.empwiniw [= "information window"] \
            [= "Are you sure you want to clear all  values?"] \
            "" "" gidquestionhead 0 [= "Ok"] [= "Cancel"]]
    if { $answer == 0 } {
        $values delete 0 end
        nasfunction::IntDrawGraphR $can 
    }    
}
proc nasfunction::acceptfunc { window } { 
    variable list
    set nasmat::plasticity "table"
    set nasmat::st_srlist $list
    destroy $window
}
proc nasfunction::cancelfunc  { window } {
    
    destroy $window
}

proc nasfunction::IntDrawGraphR { can } {
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
    #     if { $ynummax == $ynummin } { set ynummin [expr $ynummin-1] }
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
proc nasmat::getmatnum { input } {
    variable matid
    set matid $input
    return ""
    
}

proc nasmat::writenastran  { matname } {
    
    variable matid 
    
    set alphabet [list A1 B1 C1 D1 E1 F1 G1 H1 I1 J1 K1 L1 M1 N1 O1 P1 Q1 R1 S1 T1 U1 V1 W1 X1 Y1 Z1]
    set gendata [ lrange [ GiD_Info gendata ] 1 end ]
    
    foreach { name value } $gendata {
        if { [regexp Format_File* $name] } {
            set format $value
        }
    }
    set matname [string trim $matname]
    array set matinfo [lrange [ GiD_Info materials $matname ] 1 end]
    set names [ list young mo_shear poisson density temp_ref tension \
            compression shear damping expansion conductivity spec_heat \
            free_conv nontype plasticity harden yield_func initial friction \
            stress-strain ]
    set matinfo(stress-strain) [base64::decode $matinfo(stress-strain)]
    
    
    if { $format == "Small" } {
        append result [format "MAT1    %8i" $matid] [nasmat::outputformat $matinfo(young) s] \
            [nasmat::outputformat  $matinfo(mo_shear) s] [nasmat::outputformat $matinfo(poisson) s] \
            [nasmat::outputformat $matinfo(density) s] [nasmat::outputformat $matinfo(expansion) s] \
            [nasmat::outputformat $matinfo(temp_ref) s] [nasmat::outputformat $matinfo(damping) s] 
        
        if { [string trim $matinfo(tension)] != "void"  &&  [string trim $matinfo(compression)] != "void" && [string trim $matinfo(shear)] != "void" } {
            append result [format "+MT%5i\n" $matid]
            append result [format  "+MT%5i" $matid] [nasmat::outputformat $matinfo(tension) s] \
                [nasmat::outputformat $matinfo(compression) s] [nasmat::outputformat $matinfo(shear) s] \n 
        } else {
            append result \n
        }
        if { [string trim $matinfo(conductivity)] != "void" } {
            append result [format "MAT4    %8i" $matid] [nasmat::outputformat $matinfo(conductivity) s] \
                [nasmat::outputformat $matinfo(spec_heat) s] [nasmat::outputformat $matinfo(density) s] \
                [nasmat::outputformat $matinfo(free_conv) s] "        " [nasmat::outputformat $matinfo(heatgen) s]\n
        }
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
    } else {
        append result [format "MAT1*           %8i" $matid] [nasmat::outputformat $matinfo(young) l] \
            [nasmat::outputformat $matinfo(mo_shear) l] [nasmat::outputformat $matinfo(poisson) l] \
            [format "*MT%5i\n" $matid]
        append result [format "*MT%5i" $matid] [nasmat::outputformat  $matinfo(density) l] [nasmat::outputformat $matinfo(expansion) l] \
            [nasmat::outputformat $matinfo(temp_ref) l] [nasmat::outputformat $matinfo(damping) l] 
        if { [string trim $matinfo(tension)] != "void"  &&  [string trim $matinfo(compression)] != "void" && [string trim $matinfo(shear)] != "void" } {
            append result [format "*MS%5i\n"  $matid]
            append result [format  "*MS%5i" $matid] [nasmat::outputformat $matinfo(tension) l] \
                [nasmat::outputformat $matinfo(compression) l] [nasmat::outputformat $matinfo(shear) l] \n
        } else {
            append result \n
        }
        if { [string trim $matinfo(conductivity)] != "void" } {
            append result [format "MAT4*           %8i" $matid] [nasmat::outputformat $matinfo(conductivity) l] \
                [nasmat::outputformat $matinfo(spec_heat) l] [nasmat::outputformat $matinfo(density) l] [format "*MTC%4i\n" $matid] \
                [format "*MTC%4i" $matid] [nasmat::outputformat $matinfo(free_conv) l] "                " \
                [nasmat::outputformat $matinfo(heatgen) l]\n
            
        }
        
        switch $matinfo(nontype) {
            "elasticplastic" { 
                if { $matinfo(plasticity) != "table" } {
                    append result [format "MATS1   %8i         PLASTIC%#8.3g%8i%8i%#8.3g" $matid $matinfo(plasticity) \
                            [string index $matinfo(yield_func) 0] [string index $matinfo(harden) 0] $matinfo(initial) ] 
                    if { $matinfo(friction) != "void" } {
                        append result [format "%#8.3g" $matinfo(friction)]
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
    }          
    append result [nasmat::mattemp $matname $matid]
    #    append result [nasmat::tabletemp]
    return $result
}                                                                                        

proc nasmat::outputformat { value formattype} { 
    
    if { $formattype == "s" } {
        set freal %#8.3g
        set fint %8i
    } else {
        set freal %#16.6g
        set fint %16i
    }
    
    if { [string is double -strict [string trim $value]] } {
        if { $formattype == "s" } {
            set output [GiD_FormatReal $freal $value forcewidthnastran]
        } else {
            set output [GiD_FormatReal $freal $value forcewidthnastran]
        }        
    } else { 
        if { [string trim $value] != "" &&  [string trim $value] !="void"}  {
            WarnWin [= "This number format %s is not supported for GiD-NASTRAN Interface. NASTRAN default value assumed. Please edit materials" $value]
        }
        if { $formattype == "s" } {
            set output "        "
        } else {
            set output "                "
        }
    }
    return $output
}
proc nasmat::mattemp { matname matid } {
    
    set write1 0
    set write4 0
    set matname [string trim $matname]
    array set matinfo [lrange [ GiD_Info materials $matname ] 1 end]
    set matinfo(stress-strain) [base64::decode $matinfo(stress-strain)]
    set namesMAT1 [ list young mo_shear poisson density expansion \
            damping tension compression shear ]
    set namesMAT4 [list conductivity spec_heat \
            free_conv heatgen] ;# Order of elements in the list very important
    
    set tables ""
    set aux [ GiD_Info materials]
    set index 1 
    foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            lappend tables  [list $elem $index]
            incr index
        }
    }
    
    set output [format "MATT1   %8i" $matid]
    foreach name $namesMAT1 {
        switch $name {
            "expansion" {
                if { [string is double [string trim $matinfo($name)]] || $matinfo($name)== "void"} {
                    append output "                "
                } else {
                    foreach table $tables {
                        if { $matinfo($name) == [lindex $table 0] } {
                            append output [format "%8i        " [lindex $table 1]]
                            set write1 1
                            break
                        }
                    }
                }
            }
            "damping" {
                if { [string is double [string trim $matinfo($name)]] || $matinfo($name)== "void"} {
                    append output [format "        +MTT1%3i" $matid]\n
                    append output [format "+MTT1%3i" $matid]
                } else {
                    foreach table $tables {
                        if { $matinfo($name) == [lindex $table 0]} {
                            append output "[format "%8i+MTT1%3i" [lindex $table 1] $matid]\n"
                            append output [format "+MTT1%3i" $matid]
                            set write1 1 
                            break
                        }
                    }
                }
            }
            default {
                if { [string is double [string trim $matinfo($name)]] || $matinfo($name)== "void"} {
                    append output "        "
                } else {
                    foreach table $tables {
                        if { $matinfo($name) == [lindex $table 0] } {
                            append output [format "%8i" [lindex $table 1]]
                            set write1 1 
                            break
                        }
                    }
                }
            }
        }
    }
    set output4 [format "MATT4   %8i" $matid]
    foreach name $namesMAT4 {
        switch $name {
            "spec_heat" {
                if { [string is double [string trim $matinfo($name)]] || $matinfo($name)== "void"} {
                    append output4 "                "
                } else {
                    foreach table  $tables {
                        if { $matinfo($name) == [lindex $table 0] } {
                            append output4 [format "%8i        " [lindex $table 1]]
                            set write4 1
                            break
                        }
                    }
                }
            }
            "free_conv" {
                if { [string is double [string trim $matinfo($name)]] || $matinfo($name)== "void"} {
                    append output4 "                "
                } else {
                    foreach table $tables {
                        if { $matinfo($name) == [lindex $table 0] } {
                            append output4 [format "%8i        " [lindex $table 1]]
                            set write4 1
                            break
                        }
                    }
                }
            }
            default {
                if { [string is double [string trim $matinfo($name)]] || $matinfo($name)== "void"} {
                    append output4 "        "
                } else {
                    foreach table $tables {
                        if { $matinfo($name) == [lindex $table 0] } {
                            append output4 [format "%8i" [lindex $table 1]]
                            set write4 1 
                            break
                        }
                    }
                }
            }
        }
    }
    if { $write1 == 0 && $write4== 0} {
        return ""
    } elseif { $write1 == 0 && $write4== 1 } {
        return [append output4 "\n"]
    } elseif { $write1 == 1 && $write4== 0 } {
        return [append output "\n"]
    } elseif { $write1 == 1 && $write4== 1} { 
        return [append output "\n$output4 \n"]
    }
}

proc nasmat::tabletemp { } {
    
    set alphabet [list A1 B1 C1 D1 E1 F1 G1 H1 I1 J1 K1 L1 M1 N1 O1 P1 Q1 R1 S1 T1 U1 V1 W1 X1 Y1 Z1]
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
                    if  { $tableid >= [llength $alphabet ] } {
                        set lineid [lindex $alphabet [expr $tableid/[llength $alphabet ] ] ]
                    } else {
                        set lineid [lindex $alphabet $tableid ]
                    }
                    append result [format "TABLEM1 %8i                                                        +%s%5i \n" $tableid $lineid $tableid ]
                    set numblock 1
                    set numline $tableid
                    foreach {x y} $values {
                        if { $numblock != 1 && $numblock !=7 } {
                            append result [GiD_FormatReal "%#8.5g" $x forcewidthnastran]
                            append result [GiD_FormatReal "%#8.5g" $y forcewidthnastran]
                        }
                        if { $numblock == 1 } {
                            append result [ format "+%s%5i" $lineid $numline ]
                            append result [GiD_FormatReal "%#8.5g" $x forcewidthnastran]
                            append result [GiD_FormatReal "%#8.5g" $y forcewidthnastran]
                            set numline [expr {$numline+1} ]                    
                        }
                        if { $numblock == 7} {
                            append result [GiD_FormatReal "%#8.5g" $x forcewidthnastran]
                            append result [GiD_FormatReal "%#8.5g" $y forcewidthnastran]                            
                            append result [ format "+%s%5i\n" $lineid $numline ]
                            set numblock -1
                        }
                        set numblock [expr $numblock+2]
                    } 
                    if { $numblock == 1 } {
                        append result [ format "+%s%5i    ENDT" $lineid $numline ]
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
