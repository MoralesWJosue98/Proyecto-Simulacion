proc GiD_Event_InitProblemtype { dir } {
    global ProblemTypePriv        
    set read_ini [abaqus::ReadDefaultValues] 
    set ::ProblemTypePriv(problemtypedir) $dir
    array set problemtype_local [GidUtils::ReadProblemtypeXml [file join $dir abaqus.xml] Infoproblemtype {Name Version MinimumGiDVersion}]
    if { [GidUtils::VersionCmp $problemtype_local(MinimumGiDVersion)] < 0 } {  
	    W [= "This problemtype requires GiD %s or later" $problemtype_local(MinimumGiDVersion)]
    }
    set ::ProblemTypePriv(name) $problemtype_local(Name)
    set ::ProblemTypePriv(version) $problemtype_local(Version)
    set ::ProblemTypePriv(CalculationFileExtension) $::GidPriv(CalculationFileExtension)
    set ::GidPriv(CalculationFileExtension) ".inp"
    abaqus::splash $dir 1
    abaqus::modifymenus
    abaqus::MyBitmaps $dir
}

proc GiD_Event_EndProblemtype {} {
    global ProblemTypePriv
    set ::GidPriv(CalculationFileExtension) $::ProblemTypePriv(CalculationFileExtension)
    abaqus::EndMyBitmaps    
    #READING ABAQUS.INI FILE
    abaqus::WriteTCLDefaultsInFile
    array unset ::ProblemTypePriv
}

#to force refresh some menus managed by the problemtype when the user change to newlanguage
proc GiD_Event_ChangedLanguage { language  } {    
    abaqus::modifymenus
}

proc GiD_Event_LoadModelSPD { filespd } {
    global ProblemTypePriv
    set filename [file rootname $filespd].xml    
    set model_problemtype_version_number [GidUtils::ReadXmlWithNameAndVersion $filename $::ProblemTypePriv(name)]
    if { $model_problemtype_version_number != -1 && $model_problemtype_version_number < $::ProblemTypePriv(version) } {
        set must_transform 1
    } else {
        set must_transform 0
    }
    if { $must_transform } {
        after idle [list GiD_Process escape escape escape escape Data Defaults TransfProblem [GidUtils::GetRelativeProblemTypePath [GiD_Info problemtypepath]] escape]        
    }
}

proc GiD_Event_SaveModelSPD { filespd } {
    global ProblemTypePriv
    set filename [file rootname $filespd].xml
    #trivial auxiliary file to store problemtype name and version with the model
    GidUtils::SaveXmlWithNameAndVersion $filename $::ProblemTypePriv(name) $::ProblemTypePriv(version)    
}

namespace eval abaqus {

}

proc abaqus::splash { dir autodestroy } {
    set text "Abaqus V $::ProblemTypePriv(version)"
    GidUtils::Splash [file join $dir images abaqus_about.gif] .splash $autodestroy [list $text 70 150]
}

proc abaqus::modifymenus { } {
    set dir $::ProblemTypePriv(problemtypedir)
    foreach where {PRE POST} {                
        GiDMenu::InsertOption "Help#C#menu" [list "ABAQUS interface help"] 0 $where [list GiDHelpViewer::Show [file join $dir info en AB index.html] -title [= "ABAQUS interface help"]] "" "" "insert" =
        # [= "About Abaqus interface"] comment to be found by ramtranslator
        GiDMenu::InsertOption "Help#C#menu" [list "About ABAQUS interface"] end $where [list abaqus::splash $dir 0] "" "" "insertafter" =
    }
    if { $::tcl_platform(platform) == "windows" && $::tcl_platform(pointerSize) == 4 } {
        #abaqusreader.dll is only valid for win x32
        set lib [file join $dir abaqusreader.dll]
        if { [file exists $lib] } {
            GiDMenu::InsertOption "Files#C#menu" [list "Import#C#menu" "ABAQUS ODB...#C#menu"] 0 PRE [list abaqus::ImportFile] "" "" "insert" =
            GiDMenu::InsertOption "Files#C#menu" [list "Import#C#menu" "ABAQUS ODB libraries...#C#menu"] 1 PRE [list abaqus::ImportFile force] "" "" "insert" =
        }
    }
    GidChangeDataLabel "Conditions" ""
    GidAddUserDataOptions [= "Define sets"] "GidOpenConditions Sets" 2
    GiDMenu::UpdateMenus
}

proc abaqus::MyBitmaps { dir { type "DEFAULT INSIDELEFT"} } {       
    global MyBitmapsNames MyBitmapsCommands MyBitmapsHelp 
    global ProblemTypePriv          
    set MyBitmapsNames(0) "images/section.gif images/elastic.gif images/axes.gif images/calc.gif"
    set MyBitmapsCommands(0) [list [list -np- GidOpenConditions Sets] [list -np- GidOpenMaterials] "Data LocalAxes DefineLocAxes" "Files WriteCalcFile"]    
    set MyBitmapsHelp(0) [list [= "Define sets and element formulation"] [= "Define and apply elastic materials"] [= "Define local axes systems"]  \
            [= "Output .inp file for ABAQUS simulations"]]       
    set prefix Pre    
    set ProblemTypePriv(toolbarwin) [CreateOtherBitmaps AbaqusBar [= "ABAQUS bar"] MyBitmapsNames MyBitmapsCommands MyBitmapsHelp $dir "abaqus::MyBitmaps [list $dir]" $type $prefix]
    AddNewToolbar "ABAQUS bar" ${prefix}AbaqusBarWindowGeom "abaqus::MyBitmaps [list $dir]" [= "ABAQUS bar"]
}

proc abaqus::EndMyBitmaps {} {
    global ProblemTypePriv
    ReleaseToolbar "ABAQUS bar"
    #rename MyBitmaps ""
    catch { destroy $ProblemTypePriv(toolbarwin) }
}

proc abaqus::writefile {} {
    set err [catch { abaqus::writefile_do } string]
    if { $err } { 
        WarnWin $string
    }
    return $string
}

# GiD Triangle faces:        12   23   31
# GiD Quadrilateral faces:   12   23   34   41
# GiD Tetra faces: 123  243  341  421
# GiD Hexa faces: 1234  1485  1562  2673  3784  5876
# GiD Prism faces: 123 1452 2563 3641  465  

# ABAQUS Tetrahedral element faces

# Face 1    1 2 3 face 
# Face 2    1 4 2 face 
# Face 3    2 4 3 face 
# Face 4    3 4 1 face 

# ABAQUS Hexahedron (brick) element faces

# Face 1    1 2 3 4 face 
# Face 2    5 8 7 6 face 
# Face 3    1 5 6 2 face 
# Face 4    2 6 7 3 face 
# Face 5    3 7 8 4 face 
# Face 6    4 8 5 1 face 

#reorder GiD connectivities to Abaqus connectivities
proc abaqus::GetAbaqusConnectivitiesHexahedra20 { connectivities } {
    return [concat [lrange $connectivities 0 11] [lrange $connectivities 16 19] [lrange $connectivities 12 15]]
}

proc abaqus::GetAbaqusConnectivitiesHexahedra27 { connectivities } {
    return [concat [lrange $connectivities 0 11] [lrange $connectivities 16 19] [lrange $connectivities 12 15] \
            [lindex $connectivities 26] [lindex $connectivities 20] [lindex $connectivities 25] [lrange $connectivities 21 24]]
}

proc abaqus::GetAbaqusConnectivitiesPrism15 { connectivities } {
    return [concat [lrange $connectivities 0 8] [lrange $connectivities 12 14] [lrange $connectivities 9 11]]
}

proc abaqus::GetAbaqusConnectivitiesPrism18 { connectivities } {
    return [concat [lrange $connectivities 0 8] [lrange $connectivities 12 14] [lrange $connectivities 9 11] [lrange $connectivities 15 17]]
}

proc abaqus::writefile_do {} {
    set _ ""
    append _ "*HEADING\nCreated by GiD on [clock format [clock seconds] -format %d-%h-%y] at "
    append _ "[clock format [clock seconds] -format %H:%M:%S]"
    
    ######WRITING THE MESH############################
    
    append _ "\n*NODE"
    # Here the set number can be defined optionally (same line as node)
    foreach "n x y z" [GiD_Info Mesh Nodes] {
        append _ "\n[format " %d, %.6g, %.6g, %.6g" $n $x $y $z]"
    }

    array unset elemtypes
    set IsQuadratic [GiD_Info Project Quadratic]
    foreach "elemtype name" [list Linear B3 Triangle S Quadrilateral S Tetrahedra C3D Hexahedra C3D Prism C3D] {
        set elems [GiD_Info Mesh Elements $elemtype]
        if { [llength $elems] } {
            # Construction of the default element type
            switch $elemtype {
                Linear { switch $IsQuadratic 0 { set n 2 } default { set n 3 } }
                Triangle { switch $IsQuadratic 0 { set n 3 } default { set n 6 } }
                Quadrilateral { switch $IsQuadratic 0 { set n 4 } 1 { set n 8 } 2 { set n 9 } }
                Tetrahedra { switch $IsQuadratic 0 { set n 4 } default { set n 10 } }
                Hexahedra { switch $IsQuadratic 0 { set n 8 } 1 { set n 20 } 2 { set n 27 } }
                Prism {switch $IsQuadratic 0 { set n 6 } 1 { set n 15 } 2 { set n 18 }}
            }     
            switch $elemtype {
                Linear { append name "[expr {$n-1}]"}
                default { append name "$n" }
            }
            set len [llength $elems]
            set incr [expr {$n+2}]
            if { $IsQuadratic } {
                if { $elemtype == "Hexahedra" || $elemtype == "Prism" } {
                    set abaqus_elems ""
                    for { set i 0 } { $i < $len } { incr i $incr } {  
                        set i_elem [lindex $elems $i]
                        set connectivities [lrange $elems $i+1 $i+$n]
                        set material [lindex $elems [expr $i+$n+1]]
                        lappend abaqus_elems $i_elem {*}[GetAbaqusConnectivities$elemtype$n $connectivities] $material
                    }
                    set elems $abaqus_elems
                }
            }
            # ELSET Parameter can be entered here also (optional)
            for { set i 0 } { $i < $len } { incr i $incr } {  
                set element_name $name
                # We update de default element formulation if needed                
                if {$elemtype=="Linear"} {
                    set formulation_string [GiD_Info conditions Line_Element_formulation mesh [lindex $elems $i]]  
                    set formulation_list [split $formulation_string " -{}"] 
                    if {[lindex $formulation_list 1] ne "0"} { 
                        set element_name [lindex $formulation_list 5]
                    }  
                    #If the element has been entered by the user, it is updated with the "Entered element" value
                    if {$element_name eq "User_defined"} {
                        set element_name [lindex $formulation_list 6]
                    }
                } elseif {$elemtype=="Triangle" || $elemtype=="Quadrilateral"} {
                    set formulation_string [GiD_Info conditions Surface_Element_formulation mesh [lindex $elems $i]]
                    set formulation_list [split $formulation_string " -{}"]                        
                    if {[lindex $formulation_list 1] ne "0"} {                            
                        set element_type [lindex $formulation_list 5]  
                        if {$element_type eq "Triangle" || $element_type eq "Quadrilateral"} {
                            #If the user is wrong when choosing, an error appears 
                            if {$elemtype ne $element_type} {error [= "Some $elemtype mesh elements are related with $element_type elements formulation"]}
                            switch $elemtype {
                                Triangle {set element_name [lindex $formulation_list 6]}
                                Quadrilateral {set element_name [lindex $formulation_list 7]}                               
                            }                            
                        } else {
                            # User defined   
                            set element_name [lindex $formulation_list 8]               
                        }
                    }  
                } elseif {$elemtype=="Tetrahedra" || $elemtype=="Hexahedra" || $elemtype=="Prism"} {
                    set formulation_string [GiD_Info conditions Volume_Element_formulation mesh [lindex $elems $i]] 
                    set formulation_list [split $formulation_string " -{}"] 
                    if {[lindex $formulation_list 1] ne "0"} {                            
                        set element_type [lindex $formulation_list 5] 
                        if {$element_type eq "Tetrahedra" || $element_type eq "Hexahedra" || $element_type eq "Prism"} { 
                            #If the user is wrong when choosing, an error appears 
                            if {$elemtype ne $element_type} {error [= "Some $elemtype mesh elements are related with $element_type elements formulation" ]}
                            switch $elemtype {
                                Tetrahedra {set element_name [lindex $formulation_list 6]}
                                Hexahedra {set element_name [lindex $formulation_list 7]}    
                                Prism {set element_name [lindex $formulation_list 8]}                            
                            }  
                        } else {
                            # User defined   
                            set element_name [lindex $formulation_list 9]    
                    }                        
                }
                } else {
                    error [= "Error, not supported element type"]
                }
                
                append _ "\n*ELEMENT, TYPE=$element_name"
                
                if { $n<=15 } {
                   append _ "\n[join [lrange $elems $i [expr {$i+$n}]] {,   }]"
                } else {
                   # More than 15 nodes uses continuation lines
                    append _ "\n[join [lrange $elems $i [expr {$i+15}]] {,   }],\n[join [lrange $elems [expr {$i+16}] [expr {$i+$n}]] {,   }]"
                }
                set elemtypes([lindex $elems $i]) $elemtype
            }
        }
    }
    
    ######DEFINING NODE SETS############################
    
    foreach cndname [list Point_Nset Line_Nset Surface_Nset Volume_Nset] {
        foreach cnd [GiD_Info conditions $cndname mesh] {
            lappend nset([lindex $cnd 3]) [lindex $cnd 1]
        }
    }   
    foreach i [array names nset] {
        set nodes [lsort -integer -unique $nset($i)]
        # Parameter GENERATE could be defined optionally
        append _ "\n*NSET, NSET=$i"
        set inum 0
        append _ "\n"
        foreach j $nodes {
            append _ " $j,"
            incr inum
            if { $inum == 16 } {
                set inum 0
                append _ "\n"
            }
        }  
        set _ [string trimright $_ ",\n"]      
    }
    
    ######DEFINING ELEMENT SETS############################
    
    foreach cndname [list Line_Elset Surface_Elset Volume_Elset] {
        foreach cnd [GiD_Info conditions $cndname mesh] {
            lappend elset([lindex $cnd 3]) [lindex $cnd 1]
        }
    }    
    foreach i [array names elset] {
        set elements [lsort -integer -unique $elset($i)]
        # Parameter GENERATE could be defined optionally
        append _ "\n*ELSET, ELSET=$i"
        set inum 0
        append _ "\n"
        foreach j $elements {
            append _ " $j,"
            incr inum
            if { $inum == 16 } {
                set inum 0
                append _ "\n"
            }
        }    
        set _ [string trimright $_ ",\n"]   
    }
    
    ######DEFINING SURFACE SETS############################
  
    ###### Defined as faces of 3D elements 
    
    foreach cnd [GiD_Info conditions Surface_Surface_set mesh] {
        lappend surfaceset([lindex $cnd 3]) [lrange $cnd 0 1]
    }      
    
    foreach i [array names surfaceset] {
        set elems [lsort -integer -unique -index 0 $surfaceset($i)]        
        append _ "\n*SURFACE,NAME=$i,TYPE=ELEMENT"   
        set inum 0
        foreach j $elems {    
            foreach "num gidface" $j break
            switch $elemtypes($num) {
                Tetrahedra {
                    if { $gidface == "2"} { 
                        set abaqusface 3 
                    } elseif { $gidface == "3"} { 
                        set abaqusface 4 
                    } elseif { $gidface == "4"} { 
                        set abaqusface 2 
                    } else {
                        set abaqusface $gidface
                    }
                }
                Hexahedra {
                    if { $gidface == "2"} { 
                        set abaqusface 6 
                    } elseif { $gidface == "6"} { 
                        set abaqusface 2 
                    } else {
                        set abaqusface $gidface
                    }
                }
                Prism {
                    if { $gidface == "2"} { 
                        set abaqusface 3 
                    } elseif { $gidface == "3"} { 
                        set abaqusface 4 
                    } elseif { $gidface == "4"} {
                        set abaqusface 5 
                    } elseif { $gidface == "5"} { 
                        set abaqusface 2 
                    } else {
                        set abaqusface $gidface
                    }
                }
                default {
                    error [= "Error in condition 'Surface set'. It cannot be applied to the element $num, bad element type"]
                }
            }

            append _ "\n[lindex $j 0],S$abaqusface"
        }
    }
    
    ###### Defined as sets of nodes
    
    foreach cndname [list Point_SurfaceNodeset Line_SurfaceNodeset Surface_SurfaceNodeset] {
        foreach cnd [GiD_Info conditions $cndname mesh] {
            lappend surfacenodes([lindex $cnd 3]) [lindex $cnd 1]
        }     
    }    
    foreach i [array names surfacenodes] {
        set nodes [lsort -integer -unique $surfacenodes($i)]        
        append _ "\n*SURFACE,NAME=$i,TYPE=NODE"   
        set inum 0
        foreach j [lrange $nodes 0 end] { 
            append _ "\n$j,"    
        }  
        set _ [string trimright $_ ",\n"]
    }
    
    ######### WRITING ELASTIC MATERIALS (materials sets are written directly form .bas file)##############
    
    foreach material [GiD_Info materials] {        
        append _ "\n*MATERIAL,NAME=$material"
        set values [GiD_Info materials $material]       
        append _ "\n*ELASTIC\n[lindex $values 2],[lindex $values 4]"
        append _ "\n*DENSITY\n[lindex $values 6]"      
    }  
    

    return $_
}

proc abaqus::ComunicateWithGiD { op args } {    
    variable SetName
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            upvar      [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set f [frame $PARENT.f]
            set values ""            
            set condname [lindex [split $STRUCT ","] 1]             
            if { [string match *Nset $condname] } {
                set initial_list {Nset1 Nset2 Nset3 Nset4}
            } elseif { [string match *Elset $condname] } {
                set initial_list {Elset1 Elset2 Elset3 Elset4}
            } else {
                set initial_list {Set1 Set2 Set3 Set4}
            }
            foreach domain [list geometry mesh] {
                foreach cnd [GiD_Info conditions $condname $domain] {
                    set name [lindex $cnd 3]
                    if { [lsearch $values $name] == -1 && [lsearch $initial_list $name] == -1 } { 
                        lappend values $name 
                    }
                }
            }
            if { [llength $values] } { lappend values --- }            
            append values " $initial_list"
            label $f.l1 -text [= Name]
            if { ![info exists SetName] || [string trim $SetName] eq "" } {
                set SetName [lindex $values 0]
            }
            ComboBox $f.cb1 -textvariable abaqus::SetName -values $values
            #$f.cb1 setvalue first
            after 100 Widget::traverseTo $f.cb1
            grid $f.l1 $f.cb1 -sticky nw
            grid configure $f.cb1 -sticky new -padx "1 5"
            grid rowconfigure $f 1 -weight 1
            grid columnconfigure $f 1 -weight 1
            GidHelpRecursive $f [= "Enter the name for the set"]
            grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
            grid rowconf $PARENT $ROW -weight 1
            grid columnconf $PARENT 1 -weight 1
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]            
            set SetName [string trim $SetName]
            if { $SetName eq "" } {
                return [list ERROR [= "Name is not valid"]]
            } elseif {[string length $SetName]>"80"} {
                return [list ERROR [= "Name is too long"]]
            } else {                
                DWLocalSetValue $GDN $STRUCT Name $SetName
            }
            return ""
        }
    }
}

proc abaqus::ImportFile { { force "" } } {
    global AbaqusPriv  
    if {![info exists ::AbaqusPriv(Library_path)] } {
        set defaultdir [pwd] 
    } else {
        if {$::AbaqusPriv(Library_path) eq "0"} {
            set defaultdir [pwd]
        } else {
            set defaultdir $::AbaqusPriv(Library_path)
        }
    }
    if { $force ne "" || ![file readable [file join $defaultdir ABQodb.dll]] } {
        set dir [tk_chooseDirectory -initialdir $defaultdir -parent .gid -title [= "Choose ABAQUS libraries directory"] -mustexist 1]
        if { $dir eq "" } { return }
        if { ![file readable [file join $dir ABQodb.dll]] } {
            set t [= "The selected directory does not seem to contain ABAQUS libraries. Proceed?"]
            set ret [tk_messageBox -default cancel -icon question -message $t -parent .gid -type okcancel]
            if { $ret eq "cancel" } { return }
        }
        set ::AbaqusPriv(Library_path) $dir
        WriteTCLDefaultsInFile
    }    
    if {![info exists ::AbaqusPriv(Results_path)] } {
        set defaultdir [pwd] 
    } else {
        if {$::AbaqusPriv(Results_path) eq "0"} {
            set defaultdir [pwd]
        } else {
            set defaultdir $::AbaqusPriv(Results_path)
        }
    }    
    set file [tk_getOpenFile -filetypes [list [list "ABAQUS ODB" {.odb .ODB}] [list "All files" *]] \
                  -initialdir $defaultdir -parent .gid -title [= "ABAQUS results file"]]
    if { $file eq "" } { return }
    # set outputfile [file root $file].post.res
    set outputfile [file root $file].post.bin
    set pwd [pwd]    
    set lib [file join [GiD_Info problemtypepath] abaqusreader.dll]
    set librariesdir $::AbaqusPriv(Library_path)
    cd $librariesdir
    set err [catch { load $lib } errstring]
    cd $pwd
    if { $err } {
        WarnWin $errstring
        return
    }
    .central.s waitstate 1
    update
    set err [catch { abaqusreader $file $outputfile } errstring]
    if { $err } {
        .central.s waitstate 0
        WarnWin $errstring
        return
    }    
    set ::AbaqusPriv(Results_path) [file dirname $file]
    WriteTCLDefaultsInFile
    .central.s waitstate 0
    update    
    GiD_Process Mescape Postprocess
    GiD_Process Mescape Files Read $outputfile
}

#READING ABAQUS.INI
proc abaqus::GetPreferencesFile {} {    
    set dirname [file dirname [GiveGidDefaultsFile]]
    if { $::tcl_platform(platform) == "windows" } {
        return [file join $dirname abaqus.ini]
    } else {
        return [file join $dirname .abaqus.ini]
    }
}

proc abaqus::ReadDefaultValues {} {
    global AbaqusPriv
    
    set file [abaqus::GetPreferencesFile]
    if { [catch { set fileid [open $file r] }] } {
        return 0
    }
    while { ![eof $fileid] } {
        set read_value [gets $fileid]
        if { [catch { set varname [lindex $read_value 0] } ] } { continue }
        switch -- $varname {            
            Library_path {
                #lrange used to avoid problems related with the spaces in the path
                set ::AbaqusPriv(Library_path) [lrange $read_value 1 end]
            }
            Results_path {
                #lrange used to avoid problems related with the spaces in the path
                set ::AbaqusPriv(Results_path) [lrange $read_value 1 end]
            }
        }
    }
    close $fileid
    
    return 1
}

#WRITING ABAQUS.INI
proc abaqus::WriteTCLDefaultsInFile {} {
    global GidPriv AbaqusPriv    
    if { $::GidPriv(OffScreen)} {
        return
    }
    set filename [abaqus::GetPreferencesFile]
    if { [catch { set fileid [open $filename w] }] } {
        return 0
    }            
    foreach attribute [list Library_path Results_path] {
        if {![info exists ::AbaqusPriv($attribute)]} {
            set ::AbaqusPriv($attribute) 0
        }
    }

    foreach attribute [list Library_path Results_path] {
        puts $fileid "$attribute $::AbaqusPriv($attribute)"
    }    
    close $fileid    
    return 1
}
