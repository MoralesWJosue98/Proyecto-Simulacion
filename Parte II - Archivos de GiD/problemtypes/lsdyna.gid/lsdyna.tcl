

proc GiD_Event_InitProblemtype { dir } {
    global ProblemTypePriv LsdynaPriv    
    if { $::tcl_platform(platform) != "windows" } {
        WarnWin [= "Error: this interface requires Windows"]        
        return 1      
    } 
            
    set read_ini [lsdyna::ReadDefaultValues]
        
    set ::ProblemTypePriv(problemtypedir) $dir
    array set problemtype_local [GidUtils::ReadProblemtypeXml [file join $dir lsdyna.xml] Infoproblemtype {Name Version MinimumGiDVersion}]
    if { [GidUtils::VersionCmp $problemtype_local(MinimumGiDVersion)] < 0 } {  
            W [= "This problemtype requires GiD %s or later" $problemtype_local(MinimumGiDVersion)]
    }
    set ::ProblemTypePriv(name) $problemtype_local(Name)
    set ::ProblemTypePriv(version) $problemtype_local(Version)

    if { [lsearch -exact $::auto_path [file join $dir scripts]] == -1 } {
        lappend ::auto_path [file join $dir scripts]
    }
                   
    lsdyna::load_gid_groups_conds
    
    if { ![info exists ::LsdynaPriv(splash_showed)] } {    
        lsdyna::Splash 1
        set ::LsdynaPriv(splash_showed) 1
    }    
    lsdyna::Bitmaps $dir    
    #drawopengl registercondition [list gid_groups_utils::draw] surface_groups
    #drawopengl register [list gid_groups_utils::drawall surface_groups]    
    gid_groups_conds::SetProgramName $::ProblemTypePriv(name)        
    gid_groups_conds::begin_problemtype [file join $dir lsdyna.spd] [lsdyna::GivelsdynaDefaultsFile]
    catch {
        ContextualEntity::RegisterUserDataCommand lsdyna::AddDataItemsToMenu
    }    
    set galileo_dir [file join $dir scripts galileo_stress]
    if { [GidUtils::IsLink $galileo_dir] } {
        set galileo_dir [GidUtils::ReadLink $galileo_dir]
    }
    if { [GidUtils::IsLink $galileo_dir.lnk] } {
        set galileo_dir [GidUtils::ReadLink $galileo_dir.lnk]
    }
    if { [file isdirectory $galileo_dir] } {
        source [file join $galileo_dir galileo_stress.tcl]
        galileo_stress::init $galileo_dir        
    }        
    if {$read_ini=="0" || ![info exists ::LsdynaPriv(SolverPath)]} {
        set ::LsdynaPriv(SolverPath) {C:\LSDYNA\program\ls971_d_7600_winx64_p.exe}
    }    
    #NECESSARY CONDITION TO MESH POINTS WHICH ARE NOT RELATED TO ANY MESH
    GiD_Set ForceMeshEntities 1
    lsdyna::ChangeMenus
    return 0
}

proc GiD_Event_EndProblemtype {} {
    global ProblemTypePriv
    if { ![info exists ::ProblemTypePriv(problemtypedir)] } {
        #if the variable not exists it was not initialized
        return 1
    }        
    lsdyna::EndBitmaps
    lsdyna::EndBitmapsPost    
    #READING LDYNA.INI FILE
    set write_ini [lsdyna::WriteTCLDefaultsInFile]
    if {$write_ini!="1"} {
        error [= "Error writing lsdyna.ini file"]
    }     
    set filename_user_defaults "" ;#empty to no save .ini
    if { [GiD_Set SaveGidDefaults] } {
        set filename_user_defaults [lsdyna::GivelsdynaDefaultsFile]
    }
    gid_groups_conds::end_problemtype $filename_user_defaults
    array unset ::ProblemTypePriv
    return 0
}

proc GiD_Event_ChangedLanguage { language  } { 
    lsdyna::ChangeMenus
}

proc GiD_Event_InitGIDPostProcess {} {
    global ProblemTypePriv    
    gid_groups_conds::close_all_windows
    gid_groups_conds::open_post check_default
    set dir $::ProblemTypePriv(problemtypedir)
    lsdyna::BitmapsPost $dir    
    lsdyna::LamResults
}

proc GiD_Event_EndGIDPostProcess {} {
    gid_groups_conds::close_all_windows
    gid_groups_conds::open_conditions check_default
}

# Load GiD project files (initialise XML Tdom structure)
proc GiD_Event_LoadModelSPD { filespd } {    
    if { ![file exists $filespd] } { 
        return
    }
    set versionPT [gid_groups_conds::give_data_version]
    gid_groups_conds::open_spd_file $filespd    
    set versionData [gid_groups_conds::give_data_version]
    if { [package vcompare $versionPT $versionData] == 1 } {
        after idle lsdyna::upgrade_problemtype
    }
}
# Save GiD project files (save XML Tdom structure to spd file)
proc GiD_Event_SaveModelSPD { filespd } {    
    gid_groups_conds::report_check_name $filespd
    gid_groups_conds::save_spd_file $filespd
}

proc GiD_Event_BeforeRunCalculation { batfilename basename dir problemtypedir gidexe args } {    
    global ProblemTypePriv LsdynaPriv
    #we print an error window only in local calculation and invalid solver path    
    if {![file exists $::LsdynaPriv(SolverPath)] && (![info exists ProblemTypePriv(calc_remote)] || $::ProblemTypePriv(calc_remote)!="remote")} {  
        WarnWin [= "Please select a correct solver path in the calculate menu"] 
    }        
}

proc GiD_Event_SelectGIDBatFile { dir basename } {
    global ProblemTypePriv LsdynaPriv    
    if { [info exists ProblemTypePriv(calc_remote)] && $::ProblemTypePriv(calc_remote) eq "remote" } {
        #REMOTE CALCULATION
        set more_files [b_write_calc_file::files_to_copy_to_remote_server]
        return [list lsdyna.win.remote.bat $more_files]
    } else {
        #WE SEND TO THE .BAT FILE AN EXTRA PARAMETER IN THE LOCAL CALCULATION    
        return [list lsdyna.win.bat $::LsdynaPriv(SolverPath)]
    }
    return ""
}

#this task is already done by default by GiD
#proc GiD_Event_AfterTransformProblemType { filename oldproblemtype newproblemtype messages } {    
#    set spd_file [file join $filename.gid [file tail $filename].spd]
#    return [gid_groups_conds::transform_problemtype $spd_file]
#}

proc GiD_Event_AfterWriteCalculationFile { filename error } {
    global ProblemTypePriv         
    if { ![info exists gid_groups_conds::doc] } {
        WarnWin [= "Error: data not OK"]
        return
    }    
    if { [info exists ProblemTypePriv(before_calc_handler_list)] } {
        foreach i $::ProblemTypePriv(before_calc_handler_list) {
            uplevel #0 $i [list $gid_groups_conds::doc $filename]
        }
    }    
    set err [catch { b_write_calc_file::writeCalcFile $gid_groups_conds::doc $filename } ret]
    if { $err } {
        catch { GiD_WriteCalculationFile end } ;#to close the file 
        snit_messageBox -parent .gid -message [= "Error when preparing data for analysis (%s)" $ret]        
        return "-cancel-"
    }
    return $ret
}

namespace eval lsdyna {
}

proc lsdyna::load_gid_groups_conds {} {   
    set packs [list]
    if { ![GidUtils::IsTkDisabled] } {
        lappend packs dialogwin fulltktree
    }    
    lappend packs customLib customLib_utils    
    foreach pack $packs {
        package require $pack
    } 
} 

proc lsdyna::ChangeMenus { } {
    if { [GidUtils::IsTkDisabled] } { 
        return
    }    
    set ipos [GiDMenu::_FindIndex Calculate PRE]
    if { $ipos != -1 } {
        InsertMenuOption [_ Calculate] [_ Calculate] 0 [list lsdyna::Calculate local] PRE replace
        InsertMenuOption [_ Calculate] [_ "Calculate remote"] 1 [list lsdyna::Calculate remote] PRE replace
        InsertMenuOption [_ Calculate] --- 6 "" PRE
        InsertMenuOption [_ Calculate] [= "Cancel results"] 7 lsdyna::CancelResults PRE
        InsertMenuOption [_ Calculate] [= "Solver path"] 8 lsdyna::Choose_solver_path PRE
        InsertMenuOption [_ Files] [= "Import .dyn mesh"] 5 [list lsdyna::Import_dyna_mesh_win Import] PRE insert
        InsertMenuOption [_ Files] [= "Add .dyn mesh"] 6 [list lsdyna::Import_dyna_mesh_win Add] PRE insert 
        #         lappend MenuEntries($ipos) --- [= "Cancel results"]
        #         lappend MenuCommands($ipos) "" [list -np- lsdynaCancelResults]
        #         lappend MenuAcceler($ipos) "" ""
    }
    
    #     set ipos [GiDMenu::_FindIndex Mesh PRE]
    #     if { $ipos != -1 } {
        #         HIDDEN IN THIS LS-DYNA VERSION
        #         lappend MenuEntries($ipos) "---"
        #         lappend MenuCommands($ipos) ""
        #         lappend MenuAcceler($ipos) ""
        #         
        #         lappend MenuEntries($ipos) "[= {Scale assigned sizes}]..."
        #         lappend MenuCommands($ipos) [list -np- ScaleMeshSizes]
        #         lappend MenuAcceler($ipos) ""
        #     }
    
    GidChangeDataLabel "Data units" ""
    GidChangeDataLabel "Interval" ""
    GidChangeDataLabel "Conditions" ""
    GidChangeDataLabel "Materials" ""
    GidChangeDataLabel "Interval Data" ""
    GidChangeDataLabel "Problem Data" ""
    GidChangeDataLabel "Local axes" ""
    
    GidAddUserDataOptions "---" "" 3
    #START DATA HAVE BEEN REMOVED PROVISIONALLY
    #GidAddUserDataOptions [= "Start data"] "lsdyna::StartWindow" 4
    GidAddUserDataOptions [= "Groups"] "gid_groups_conds::open_groups .gid window" 5
    GidAddUserDataOptions [= "Data"] "gid_groups_conds::open_conditions window" 6    
    GidAddUserDataOptions [= "Data (internal)"] "gid_groups_conds::open_conditions menu" 7
            
    GidAddUserDataOptions "---" "" 10
    GidAddUserDataOptionsMenu [= "Local axes"] "gid_groups_conds::local_axes_menu %W" 11
    
    set ipos [GiDMenu::_FindIndex Window POST]
    if { $ipos != -1 } {
        InsertMenuOption [_ Window] [_ "Create results"] 7 [list create_post_result .createpostresult] POST replace
    }
       
    GiDMenu::RemoveOption Help Tutorials PREPOST
    #GiDMenu::RemoveOption Help [list "Register Problem type"] PREPOST
    GiDMenu::InsertOption Help [list "Lsdyna Tutorial"] end PREPOST [list lsdyna::Help_manual_pdf $::ProblemTypePriv(problemtypedir) manuals gid_lsdyna_tutorial] "" "" insert =    
    GiDMenu::InsertOption Help [list "About lsdyna"] end PREPOST [list lsdyna::Splash 0] "" "" insert =
    
    GiDMenu::UpdateMenus
}

# PROC TO SELECT LS-DYNA EXECUTABLE

proc lsdyna::Choose_solver_path {} {
    global LsdynaPriv    
    set types [list [list [_ "Executable file"] ".exe"] [list [_ "All files"] ".*"]]
    set pathw .gid.pathw    
    if {[file exists $::LsdynaPriv(SolverPath)]} {   
        #IF DEFAULT SOLVER PATH EXISTS 
        #FIRST, WE PRINT A CONFIRMATION WINDOW SHOWING THE CURRENT (or default) SELECTION
        if {[string compare $::LsdynaPriv(SolverPath) {C:\LSDYNA\program\ls971_d_7600_winx64_p.exe}]=="0"} {  
            set answer [tk_dialogRAM $pathw [_ "Solver Path Selection"] [_ "By default solver path is set to: $::LsdynaPriv(SolverPath)\nDo you want to change the excecutable?"] gidquestionhead 1 [_ "Yes"] [_ "No"]]     
        } else {
            set answer [tk_dialogRAM $pathw [_ "Solver Path Selection"] [_ "Selected solver path is: $::LsdynaPriv(SolverPath)\nDo you want to change the excecutable?"] gidquestionhead 1 [_ "Yes"] [_ "No"]]
        }
        #IF THE USER WANT TO CHANGE THE EXCETUBALE, WE PRINT A SELECTION WINDOW
        if {$answer=="0"} {
            set ::LsdynaPriv(SolverPath) [Browser-ramR file read .gid [_ "Specify solver path"] "" $types]
        }   
    } else {
        #IF DEFAULT PATH DOESN'T EXIST THE USER HAVE TO SELECT A CORRECT ONE
        set ::LsdynaPriv(SolverPath) [Browser-ramR file read .gid [_ "Specify solver path"] "" $types]
    }
    
    if {![info exists ::LsdynaPriv(SolverPath)]} {
        error [= "Problems during solver path selection"]
    }
    return 1
}

proc lsdyna::Import_dyna_mesh_win { option } {
    #User can choose the path of a .dyn file
    set types [list [list [= "Dyna mesh"] ".dyn"] [list [= "Dyna mesh"] ".k"] [list [= "All files"] "*"]]   
    set input_file [Browser-ramR file read .gid [_ "Choose ls-dyna mesh location"] "" $types]
    if { $input_file!="" } {
        ::GidUtils::WaitState .gid
        set res [lsdyna::Import_dyna_mesh $input_file $option]
        ::GidUtils::EndWaitState .gid
        return $res
    }
}

# PROC TO IMPORT A .DYN/.K MESH
proc lsdyna::Import_dyna_mesh { input_file option } {
    global ProblemTypePriv    
    if { $input_file=="" } {
        return 1
    }
    
    set temp_dir [lsdyna::RamTempDir]
    set problemtypedir $::ProblemTypePriv(problemtypedir)
    
    #A .msh mesh is created in a temporary directory 
    set output_file [file join $temp_dir temp_mesh.msh]
    if { [file exists $output_file] } {
        file delete $output_file
    }
    set exe [file join $problemtypedir exec giddyn.exe]
    exec $exe $input_file $output_file
    
    #This .msh is imported form GiD (it depends if there's already a mesh or not)
    
    switch $option {            
        Import {
            GiD_Process escape escape escape escape Files MeshRead $output_file
        }
        Add {
            GiD_Process escape escape escape escape Files MeshRead AddNoShare $output_file
        }            
    }
    
    #The .msh file is removed from the temporary directory (IT SHOULD BE EVALUATED)
    
    file delete $output_file   
    return 0
}



proc lsdyna::GivelsdynaDefaultsFile {} {
    global ProblemTypePriv
    set filename [GiveGidDefaultsFile]
    set dirname [file dirname $filename]
    set extname [file extension $filename]
    set lsdynaname $::ProblemTypePriv(name)$::ProblemTypePriv(version)
    if { $::tcl_platform(platform) == "windows" } {
        return [file join $dirname $lsdynaname.ini]
    } else {
        return [file join $dirname .$lsdynaname.ini]
    }
}

proc lsdyna::GivelsdynaPreferencesFile {} {
    set filename [GiveGidDefaultsFile]
    set dirname [file dirname $filename]
    if { $::tcl_platform(platform) == "windows" } {
        return [file join $dirname lsdyna.ini]
    } else {
        return [file join $dirname .lsdyna.ini]
    }
}

proc lsdyna::upgrade_problemtype {} {
    
    set w [dialogwin_snit .gid._ask -title [_ "Action"] -entrytext \
            [= "The model needs to be upgraded. Do you want to upgrade to new version?"]]
    set action [$w createwindow]
    destroy $w
    if { $action < 1 } { return }
    set project [lindex [GiD_Info Project] 0]
    
    GiD_Process escape escape escape escape Data Defaults TransfProblem \
        $project
}

proc lsdyna::Calculate { local_or_remote } {
    global ProblemTypePriv    
    set ::ProblemTypePriv(calc_remote) $local_or_remote
    GiD_Process escape escape escape escape Utilities Calculate
}

proc lsdyna::Bitmaps { dir { type "DEFAULT INSIDELEFT"} } {
    if { [GidUtils::AreWindowsDisabled] } {
        return
    }
    global ProblemTypePriv
    global lsdynaBitmapsNames lsdynaBitmapsCommands lsdynaBitmapsHelp
    if { [GidUtils::AreWindowsDisabled] } {
        return
    }    
    set lsdynaBitmapsNames(0) [list images/groups.gif images/boundary_conds.gif\
            --- images/prdata.gif images/constraints.gif images/section.gif \
            images/loads.gif  \
            --- images/view_symbols.gif images/drawconstraints.gif \
            images/drawproperties.gif images/drawloads.gif --- images/mesh.gif \
            images/calc.gif images/info.gif images/stop.gif]
    set lsdynaBitmapsCommands(0) [list \
            {-np- gid_groups_conds::open_groups .gid menu %W} \
            {-np- gid_groups_conds::open_conditions menu} {} \
            {-np- gid_groups_conds::open_conditions menu_or_any -select_xpath
            {/*/blockdata[@n="General data"]}} \
            {-np- gid_groups_conds::open_conditions menu_or_any -select_xpath 
            {/*/container[@n="Constraints"]}} \
            {-np- gid_groups_conds::open_conditions menu_or_any -select_xpath
            {/*/container[@n="Properties"]}} \
            {-np- gid_groups_conds::open_conditions menu_or_any -select_xpath
            {/*/container[@n="Loads"]}} \
            {} {-np- gid_groups_conds::draw_nodes -auto_finish symbols_all } \
            {-np- gid_groups_conds::draw_nodes_xp symbols \
            {/*/container[@n="Constraints" or @n="Connections"]} } \
            {-np- gid_groups_conds::draw_nodes_xp symbols \
            {/*/container[@n="Properties"]} } \
            {-np- gid_groups_conds::draw_nodes_xp symbols \
            {/*/container[@n="Loads"]} } \
            {} "Meshing generate" \
            "Utilities Calculate" "-np- PWViewOutput" \
            [list Utilities CancelProcess] ]
    
    #{-np- gid_groups_win::open}
    
    set lsdynaBitmapsHelp(0) [list [= "Define groups"] [= "Define conditions"] \
            "" [= "Define general data"] [= "Assign constraints"] \
            [= "Assign properties"] [= "Assign loads"] "" [= "Draw boundary conditions"] \
            [= "Draw constraints & connections"] [= "Draw properties"] \
            [= "Draw loads"] \
            "" [= "Generate mesh"] \
            [= "Calculate"] \
            [= "View process info"] \
            [= {Cancel calculation process}]]
    
    #     set lsdynaBitmapsNames(0,0) ""
    #     set lsdynaBitmapsCommands(0,0) ""
    
    # prefix values:
    #          Pre        Only active in the preprocessor
    #          Post       Only active in the postprocessor
    #          PrePost    Active Always
    
    set prefix Pre
    set - [= "lsdyna toolbar"] ;# only for translations, to pick the sentence
    
    set ::ProblemTypePriv(toolbarwin) [CreateOtherBitmaps lsdynaBar "lsdyna toolbar" \
            lsdynaBitmapsNames lsdynaBitmapsCommands \
            lsdynaBitmapsHelp $dir [list lsdyna::Bitmaps $dir] $type $prefix]
    AddNewToolbar "$::ProblemTypePriv(name) bar" ${prefix}lsdynaBarWindowGeom \
        [list lsdyna::Bitmaps $dir] [= "%s bar" $::ProblemTypePriv(name)]
    
}

proc lsdyna::EndBitmaps {} {
    if { [GidUtils::AreWindowsDisabled] } {
        return
    }
    global ProblemTypePriv
    ReleaseToolbar "lsdyna toolbar"
    if { [winfo exists $::ProblemTypePriv(toolbarwin)] } { 
        destroy $::ProblemTypePriv(toolbarwin)
    }
}

proc lsdyna::BitmapsPost { dir { type "DEFAULT INSIDELEFT"} } {
    if { [GidUtils::AreWindowsDisabled] } {
        return
    }
    if { [info command ::lsdyna::ViewResultsBarBitmaps] eq "" } {
        rename ::ViewResultsBarBitmaps ::lsdyna::ViewResultsBarBitmaps
    }
    set body [info body ::lsdyna::ViewResultsBarBitmaps]
    
    regexp -line -indices {CreateOtherBitmaps.*} $body lineIdx
    set idx0 [lindex $lineIdx 0]
    
    set data [string map [list %I% [file join $dir images/boundary_conds.gif]] {
            set ViewResultsBarBitmapsNames(0) [linsert $ViewResultsBarBitmapsNames(0) 0 "%I%" "---"]
            set ViewResultsBarBitmapsCommands(0) [linsert $ViewResultsBarBitmapsCommands(0) 0 {-np- gid_groups_conds::open_post menu} {}]
            set ViewResultsBarBitmapsHelp(0) [linsert $ViewResultsBarBitmapsHelp(0) 0 [= "View results"] ""]
        }]
    set body [string range $body 0 [expr {$idx0-1}]]$data\n[string range $body $idx0 end]
    proc ::ViewResultsBarBitmaps { { what "DEFAULT"} } $body
}

proc lsdyna::EndBitmapsPost {} {
    if { [GidUtils::AreWindowsDisabled] } {
        return
    }
    if { [info command lsdyna::ViewResultsBarBitmaps] eq "" } { return }
    rename ::lsdyna::ViewResultsBarBitmaps ::ViewResultsBarBitmaps
}

proc lsdyna::Splash { { autodestroy 1 } } {
    if { [GidUtils::AreWindowsDisabled] } {
        return
    }
    global ProblemTypePriv
    set text "$::ProblemTypePriv(name) V $::ProblemTypePriv(version)"    
    set dir $::ProblemTypePriv(problemtypedir)
    GidUtils::Splash [file join $dir images splash.jpg] .splash $autodestroy [list $text 70 150]
}


#CREATED PROC TO OPEN LS-DYNA TUTORIAL
proc lsdyna::Help_manual_pdf { dir folder name } {
    
    set pdffile [file join $dir $folder "$name.pdf"]  
    set err [catch {
            package require registry
            set root HKEY_CLASSES_ROOT
            set appKey [registry get $root\\.pdf ""]
            set appCmd [registry get $root\\$appKey\\shell\\open\\command ""]
            regsub {%1} $appCmd [file native $pdffile] appCmd
            regsub -all {\\} $appCmd {\\\\} appCmd
            eval exec $appCmd &
        } errstring]
    if { $err } {
        set file [tk_getSaveFile -filetypes \
                {{{PDF files} ".pdf"} {{All files} "*"}}  \
                -initialdir [pwd] \
                -title "Save PDF file" -defaultextension .pdf]
        if { $file == "" } { return }
        if { [string equal [file normalize $pdffile] [file normalize $file]] } {
            return $pdffile
        }
        file copy -force $pdffile $file
    }
    
}

proc lsdyna::LocalAxesMenu { menu } {
    
    #if { [$menu index end] ne "none" } { return }
    
    $menu delete 0 end
    
    set local_axes [GiD_Info localaxes]
    
    foreach i [list Point Line Surface] name [list [= Points] [= Lines] [= Surfaces]] {
        $menu add cascade -label $name -menu $menu.m$i
        destroy $menu.m$i
        set m [menu $menu.m$i -tearoff 0]
        if { [lsearch "Line Surface" $i] != -1 } {
            $m add command -label [= "Assign Automatic"] -command [list GiD_Process \
                    escape escape escape escape Data Conditions AssignCond ${i}_Local_axes \
                    change -Automatic-]
            $m add command -label [= "Assign Automatic alt"] -command [list GiD_Process \
                    escape escape escape escape Data Conditions AssignCond ${i}_Local_axes \
                    change -Automatic_alt-]
            $m add separator
        }
        set idx 0
        foreach j $local_axes {
            $m add command -label [= "Assign '%s'" $j] -command [list GiD_Process \
                    escape escape escape escape Data Conditions AssignCond ${i}_Local_axes \
                    change $j]
            incr idx
        }
        if { $idx } { $m add separator }
        $m add command -label [= "Unassign"] -command [list GiD_Process \
                escape escape escape escape Data Conditions AssignCond ${i}_Local_axes \
                Unassign]
        
        $m add separator
        $m add command -label [= Draw] -command [list GiD_Process \
                escape escape escape escape Data Conditions DrawCond -LocalAxes- \
                ${i}_Local_axes -draw-]
    }
    set ns [list [_ "Define#C#menu"] --- [_ "Draw#C#menu"] [_ "Draw all#C#menu"] \
            --- [_ "Delete#C#menu"] [_ "Delete all#C#menu"]]
    set cs {
        "Data LocalAxes DefineLocAxes"
        {} "Data LocalAxes DrawLocAxes"
        "Data LocalAxes DrawLocAxes -All-"
        {} "Data LocalAxes DeleteLA"
        "Data LocalAxes DeleteAllLA"
    }
    $menu add separator
    foreach n $ns c $cs {
        if { $n eq "---" } {
            $menu add separator
        } else {
            $menu add command -label $n -command [concat "GiD_Process escape escape \
                    escape escape" $c]
        }
    }
}

proc lsdyna::StartWindow {} {
    
    package require dialogwin
    set w .gid.basics
    destroy $w
    set w [dialogwin_snit $w -title [_ "Start data"]]
    set f [$w giveframe]
    
    set f1 [ttk::labelframe $f.f1 -text [= "Analysis type"]]
    
    ttk::radiobutton $f1.cb1 -text [_ "Beams"] -variable \
        [$w give_uservar Problem_type] -value Beams 
    ttk::radiobutton $f1.cb2 -text [_ "Shells"] -variable \
        [$w give_uservar Problem_type] -value Shells 
    ttk::radiobutton $f1.cb3 -text [_ "Beams & Shells"] -variable \
        [$w give_uservar Problem_type] -value Beams_and_shells 
    ttk::radiobutton $f1.cb4 -text [_ "Solids"] -variable \
        [$w give_uservar Problem_type] -value Solids 
    ttk::radiobutton $f1.cb5 -text [_ "Plane strain"] -variable \
        [$w give_uservar Problem_type] -value Plane_strain 
    ttk::radiobutton $f1.cb6 -text [_ "Plane stress"] -variable \
        [$w give_uservar Problem_type] -value Plane_stress
    ttk::radiobutton $f1.cb7 -text [_ "Plates"] -variable \
        [$w give_uservar Problem_type] -value Plates
    
    
    ttk::radiobutton $f1.cbN -text [_ "Naval"] -variable \
        [$w give_uservar Problem_type] -value Naval 
    
    ttk::button $f1.b1 -text [= More]... -command \
        [list lsdyna::_more_problemtypes $f1.b1 $f1.cb5 $f1.cb6 $f1.cb7]
    
    cu::combobox $f1.cb8 -textvariable [$w give_uservar analysis_type] \
        -valuesvariable [$w give_uservar analysis_typeList] -state readonly \
        -width 20 -dictvariable [$w give_uservar analysis_typeDict ""]
    
    #     THESE START DATA OPTIONS ARE HIDDEN AT THE MOMENT
    #     grid $f1.cb1  -sticky w -padx 3 -pady 1
    #     grid $f1.cb2  -     -sticky w -padx 3 -pady 1
    #     grid $f1.cb3  $f1.b1     -sticky w -padx 3 -pady 1
    #     grid $f1.cb4     -   -sticky w -padx 3 -pady 1
    #     #   grid $f1.cbN  -sticky w -padx 3 -pady 1
    #     grid $f1.cb8     -   -sticky w -padx "40 2" -pady 15
    #     grid configure $f1.b1 -padx "20 0"
    #     grid columnconfigure $f1 2 -weight 1
    
    
    set f2 [ttk::labelframe $f.f2 -text [= "Gravity"]]
    
    
    ttk::radiobutton $f2.cb1 -text [_ "Negative Y direction"] -variable \
        [$w give_uservar Gravity] -value -Y
    ttk::radiobutton $f2.cb2 -text [_ "Negative Z direction"] -variable \
        [$w give_uservar Gravity] -value -Z
    ttk::radiobutton $f2.cb3 -text [_ "Another"] -variable \
        [$w give_uservar Gravity] -value ""
    
    #WE DONT SHOW THIS OPTION IN LSDYNA
    
    #     grid $f2.cb1 $f2.cb2 -sticky w -padx 3 -pady 1
    #     grid $f2.cb3    -    -sticky w -padx 3 -pady 1
    #     grid columnconfigure $f2 1 -weight 1
    
    set f3 [ttk::labelframe $f.f3 -text [= "Units"]]
    
    ttk::label $f3.l1 -text [= "Units system"]:
    cu::combobox $f3.cb1 -textvariable [$w give_uservar units_system] \
        -valuesvariable [$w give_uservar units_systemList] -state readonly \
        -width 16
    
    ttk::label $f3.l2 -text [= "Mesh units"]:
    cu::combobox $f3.cb2 -textvariable [$w give_uservar units_mesh] \
        -valuesvariable [$w give_uservar units_meshList] -state readonly \
        -width 16
    
    ttk::label $f3.l3 -text [= "Default length units"]:
    cu::combobox $f3.cb3 -textvariable [$w give_uservar units_length] \
        -valuesvariable [$w give_uservar units_lengthList] -state readonly \
        -width 16
    
    ttk::label $f3.l4 -text [= "Default force units"]:
    cu::combobox $f3.cb4 -textvariable [$w give_uservar units_force] \
        -valuesvariable [$w give_uservar units_forceList] -state readonly \
        -width 16
    
    grid $f3.l1 $f3.cb1 -sticky w -padx 3 -pady 1
    grid $f3.l2 $f3.cb2 -sticky w -padx 3 -pady 1
    grid $f3.l3 $f3.cb3 -sticky w -padx 3 -pady "6 1"
    grid $f3.l4 $f3.cb4 -sticky w -padx 3 -pady 1
    
    grid columnconfigure $f3 1 -weight 1
    
    ttk::label $f.l -wraplength 250 -text \
        [= "Note: all these values can be modified later either in this window or in the data tree"]
    
    #     grid $f1 -sticky nsew
    #     grid $f2 -sticky nsew
    grid $f3 -sticky nsew
    #     grid $f.l -sticky w
    grid columnconfigure $f 0 -weight 1
    
    set node [gid_groups_conds::give_node_xpath {//value[@n='Problem_type']}]
    set pt [get_domnode_attribute $node v]
    $w set_uservar_value Problem_type $pt
    if { [lsearch [list Plane_strain Plane_stress Plates] $pt] != -1 } {
        lsdyna::_more_problemtypes $f1.b1 $f1.cb5 $f1.cb6 $f1.cb7
    }
    
    set node [gid_groups_conds::give_node_xpath {//value[@n='Analysis_Type']}]
    $w set_uservar_value analysis_typeList [split \
            [get_domnode_attribute $node values] ,]
    $w set_uservar_value analysis_typeDict [split \
            [get_domnode_attribute $node dict] ,]
    $w set_uservar_value analysis_type [get_domnode_attribute $node v]
    
    set epsilon 1e-11
    set gravity_vec ""
    
    #set xp "/*/blockdata\[@n='General data'\]/container\[@n='Gravity'\]/value\[@n='Gravity_$i'\]"
    
    
    set xp {/*/blockdata[@n="General data"]/container[@n="Gravity"]/value[@n="Active_gravity"]} 
    set node [gid_groups_conds::give_node_xpath $xp]
    set activation [get_domnode_attribute $node v]
    
    #GRAVITY VECTOR CREATION IS CHANGED IN THIS LSDYNA VERSION, BUT THIS PART OF THE CODE MUST BE REVISED
    
    if  {$activation} {
        set xp {/*/blockdata[@n="General data"]/container[@n="Gravity"]/value[@n="Gravity_Magnitude"]} 
        set node [gid_groups_conds::give_node_xpath $xp]
        #IT IS NOT CONVERTED INTO DEFAULT UNITS
        set g [get_domnode_attribute $node v]
        if {$g<0} {
            error [= "Invalid Gravity Magnitude"]
        } else {
            set direction [get_value Gravity_Direction]
            foreach i [list X Y Z] {
                if { $direction=="$i-" } { 
                    lappend gravity_vec "[format "-%-8g" $g]"
                } elseif { $direction=="$i+" } { 
                    lappend gravity_vec "[format "%8g" $g]"
                } else {                   
                    lappend gravity_vec "0"
                }
            }
        }                
    } else {
        set gravity_vec "0 0 0"
    }
    
    set err [catch { m::unitLengthVector $gravity_vec } gravity_vec]
    if { $err } {
        $w set_uservar_value Gravity ""
    } elseif { [m::norm [m::sub $gravity_vec "0 0 -1"]] < 1e-11 } {
        $w set_uservar_value Gravity -Z
    } elseif { [m::norm [m::sub $gravity_vec "0 -1 0"]] < 1e-11 } {
        $w set_uservar_value Gravity -Y
    } else {
        $w set_uservar_value Gravity ""
    }
    
    set node [gid_groups_conds::give_node_xpath {//value[@n='units_system']}]
    $f3.cb1 configure -dict [split [get_domnode_attribute $node dict] ,]
    $w set_uservar_value units_system [get_domnode_attribute $node v]
    $w set_uservar_value units_systemList [split \
            [get_domnode_attribute $node values] ,]
    
    foreach i [list units_mesh units_length units_force] {
        set xp [format_xpath {//value[@n=%s]} $i]
        set node [gid_groups_conds::give_node_xpath $xp]
        $w set_uservar_value $i [get_domnode_attribute $node v]
        $w set_uservar_value ${i}List [split \
                [get_domnode_attribute $node values] ,]
    }
    set cmd [list lsdyna::_change_units_system $w]
    trace add variable [$w give_uservar units_system] write "$cmd;#"
    bind $f3.cb1 <Destroy> [list trace remove variable \
            [$w give_uservar units_system] write "$cmd;#"]
    
    tk::TabToWindow $f1.cb1
    bind [winfo toplevel $f] <Return> [list $w invokeok]
    set action [$w createwindow]
    
    if { $action == 1 } {
        set node [gid_groups_conds::give_node_xpath {//value[@n='Problem_type']}]
        gid_groups_conds::modify_value_node $node \
            [$w give_uservar_value Problem_type]
        
        set node [gid_groups_conds::give_node_xpath {//value[@n='Analysis_Type']}]
        gid_groups_conds::modify_value_node $node \
            [$w give_uservar_value analysis_type]
        
        set gravity_vec ""
        switch -- [$w give_uservar_value Gravity] {
            -Z {
                set gravity_vec "0 0 -1"
            }
            -Y {
                set gravity_vec "0 -1 0"
            }
        }
        if { $gravity_vec ne "" } {
            set idx 0
            foreach i [list X Y Z] {
                set xp "/*/blockdata\[@n='General data'\]/container\[@n='Gravity'\]/value\[@n='Gravity_$i'\]"
                set node [gid_groups_conds::give_node_xpath $xp]
                gid_groups_conds::modify_value_node $node \
                    [lindex $gravity_vec $idx]
                incr idx
            }
        }
        foreach i [list units_system units_mesh units_length units_force] {
            set xp [format_xpath {//value[@n=%s]} $i]
            set node [gid_groups_conds::give_node_xpath $xp]
            gid_groups_conds::modify_value_node $node \
                [$w give_uservar_value $i]
        }
        gid_groups_conds::actualize_conditions_window
    }
    destroy $w
}

proc lsdyna::_more_problemtypes { b r1 r2 r3 } {
    
    grid forget $b
    grid $r1 -row 0 -column 1 -sticky w -padx 3 -pady 1
    grid $r2 -row 1 -column 1 -sticky w -padx 3 -pady 1
    grid $r3 -row 2 -column 1 -sticky w -padx 3 -pady 1
}

proc lsdyna::checkNaval {ck1 cb} {
    set value [$cb cget -value]
    if {$value == "Shells" || $value == "Beams_and_shells"} {
        $ck1 configure -state normal
    } else {
        $ck1 configure -state disabled
    }
}

proc lsdyna::_change_units_system { w } {
    
    set units_system [$w give_uservar_value units_system]
    
    foreach i [list units_mesh units_length units_force] j [list L L F] {
        set xp [format_xpath {*/units/unit_magnitude[@n=%s]/unit[@units_system=%s]} \
                $j $units_system]
        set values ""
        foreach node [gid_groups_conds::give_node_xpath $xp] {
            lappend values [$node @n]
        }
        $w set_uservar_value ${i}List $values
        $w set_uservar_value $i [lindex $values 0]
    }
}

proc lsdyna::function_loads { ftype what n pn frame domNode funcNode units_var ov_var } {
    switch $ftype {
        triangular_load {
            return [function_loads_triangular $what $n $pn $frame $domNode $funcNode $units_var $ov_var]
        }
        hydrostatic_load {
            return [function_loads_hydrostatic $what $n $pn $frame $domNode $funcNode $units_var $ov_var]
        }
        sinusoidal_load {
            return [function_loads_sinusoidal $what $n $pn $frame $domNode $funcNode $units_var $ov_var]
        }
    }
}

proc lsdyna::_pick_point { button var } {
    global ProblemTypePriv
    
    set img [$button cget -image]
    set cmd [$button cget -command]
    set help [gid_groups_conds::register_popup_help $button]
    $button configure -image [icon_chooser::giveimage locationbar_erase-16] \
        -command [list GiD_Process escape]
    gid_groups_conds::register_popup_help $button [= "Cancel point selection"]
    set pnt [GidUtils::GetCoordinates]
    $button configure -image $img -command $cmd
    gid_groups_conds::register_popup_help $button $help
    if { $pnt eq "" } { return }
    foreach i $pnt v [list x y z] {
        set ::ProblemTypePriv(${var}_$v) $i
    }
}

proc lsdyna::function_loads_triangular { what n pn f domNode funcNode \
    units_var ov_var } {
    global ProblemTypePriv
    
    switch $what {
        create {
            foreach i [list 1 2] txt [list [= "First point"] [= "Second point"]] {
                set f1 [ttk::labelframe $f.f$i -text $txt]
                ttk::label $f1.l1 -text P${i}:
                ttk::entry $f1.ex -textvariable ProblemTypePriv(flt_p${i}_x) \
                    -width 8
                ttk::label $f1.lm1 -text ","
                ttk::entry $f1.ey -textvariable ProblemTypePriv(flt_p${i}_y) \
                    -width 8
                ttk::label $f1.lm2 -text ","
                ttk::entry $f1.ez -textvariable ProblemTypePriv(flt_p${i}_z) \
                    -width 8
                
                ttk::button $f1.b -image [icon_chooser::giveimage bookmark_folder-16] \
                    -command [list lsdyna::_pick_point $f1.b flt_p${i}] \
                    -style Toolbutton
                gid_groups_conds::register_popup_help $f1.b \
                    [= "Pick a point in the screen"]
                
                ttk::label $f1.l2 -text V${i}:
                ttk::entry $f1.e4 -textvariable ProblemTypePriv(flt_v${i}) -width 6
                
                grid $f1.l1 $f1.ex $f1.lm1 $f1.ey $f1.lm2 $f1.ez $f1.b -sticky w
                grid $f1.l2 $f1.e4    -      - -sticky w -pady 2
                grid configure $f1.e4 -sticky ew
                
            }
            
            if { ![info exists ProblemTypePriv(l_tri_img)] } {
                set ::ProblemTypePriv(l_tri_img) [image create photo \
                        -file [file join $::ProblemTypePriv(problemtypedir) images \
                            carga_triangular.gif]]
            }
            
            label $f.image -image $::ProblemTypePriv(l_tri_img)
            
            grid $f.f1 $f.image -sticky nw -padx 3
            grid $f.f2     ^    -sticky nw -padx 3
            grid configure $f.image -sticky new
            
            grid columnconfigure $f 1 -weight 1
            grid rowconfigure $f 1 -weight 1
            
            #tk::TabToWindow $f.f1.e1
            
            if { $funcNode ne "" } {
                set xp {functionVariable[@variable="xyz" and
                    @n="triangular_load"]}
                set fvarNode [$funcNode selectNodes $xp]
            } else { set fvarNode "" }
            if { $fvarNode ne "" } {
                foreach i [list 1 2] {
                    set xp [format_xpath {string(value[@n=%s]/@v)} p$i]
                    foreach v [split [$fvarNode selectNodes $xp] ,] c [list x y z] {
                        set ::ProblemTypePriv(flt_p${i}_$c) $v
                    }
                    set xp [format_xpath {string(value[@n=%s]/@v)} v${i}]
                    set ::ProblemTypePriv(flt_v${i}) [$fvarNode selectNodes $xp]  
                }
            } else {
                foreach i [list 1 2] {
                    foreach c [list x y z] {
                        set ::ProblemTypePriv(flt_p${i}_$c) 0.0
                    }
                    set ::ProblemTypePriv(flt_v${i}) 1.0
                }
            }
            return [= "Triangular load"]
        }
        apply {
            foreach i [list 1 2] {
                foreach c [list x y z] {
                    if { ![string is double -strict $::ProblemTypePriv(flt_p${i}_$c)] } {
                        tk::TabToWindow $f.f$i.e$c
                        error [= "Coordinate %s of point %s is not OK" $c $i]
                    }
                }
                if {  ![string is double -strict $::ProblemTypePriv(flt_v${i})] } {
                    tk::TabToWindow $f.f$i.e4
                    error [= "Value of point %s is not OK" $c $i]
                }
            }
            set xp {functionVariable[@variable="xyz"]}
            if { [$funcNode selectNodes $xp] eq "" } {
                set fvarNode [$funcNode appendChildTag functionVariable]
            } else {
                set fvarNode [$funcNode selectNodes $xp]
                foreach i [$fvarNode childNodes] { $i delete }
            }
            $fvarNode setAttribute n triangular_load pn [= "Triangular load"] \
                variable "xyz"
            foreach i [list 1 2] {
                set pList ""
                foreach c [list x y z] {
                    lappend pList $::ProblemTypePriv(flt_p${i}_$c)
                }
                $fvarNode appendChildTag value [list attributes() \
                        n p$i pn "P$i" v [join $pList ,]]
                $fvarNode appendChildTag value [list attributes() \
                        n v$i pn "V$i" v $::ProblemTypePriv(flt_v${i})]
            }
        }
    }
}

# proc lsdyna::_setup_units_combo { domNode unit_magnitude value unit f var1 var2 } {
    #     foreach "units factors defunits activeunits" [gid_groups_conds::give_units \
        #             -give_factors $unit_magnitude] break
    # 
    #     set value [gid_groups_conds::nice_number [gid_groups_conds::convert_unit_value \
        #                 $domNode $unit_magnitude $value $unit \
        #                 $activeunits]]
    #     set unitsN [gid_groups_conds::units_to_nice_unitsList $units]
    # 
    #     ttk::paned $f -orient horizontal
    #     ttk::entry $f.e -textvariable $var1 -width 10
    # 
    #     ttk::combobox $f.c -textvariable $var2 \
        #         -width 6 -values $unitsN
    #     
    #     $f add $f.e -weight 3
    #     $f add $f.c -weight 1
    # 
    #     set unitN [gid_groups_conds::units_to_nice_units $unit]
    # 
    #     upvar #0 $var1 v1
    #     upvar #0 $var2 v2
    #     upvar #0 ${var2}_old v2_old
    # 
    #     set v1 $value
    #     set v2 $unitN
    #     set v2_old $unitN
    # 
    #     set cmd [list lsdyna::_manage_units_combo $domNode $unit_magnitude $var1 \
        #             $var2]
    #     append cmd ";#"
    #     trace add variable v2 write $cmd
    #     bind $f <Destroy> +[list trace remove variable \
        #             v2 write $cmd]
    #         
    #     $f.c state readonly
    # }
# 
# proc lsdyna::_manage_units_combo { domNode magnitude var1 var2 } {
    # 
    #     upvar #0 $var1 v1
    #     upvar #0 $var2 v2
    #     upvar #0 ${var2}_old v2_old
    #     if { $v2 eq $v2_old } { return }
    #     
    #     set unit_from [gid_groups_conds::nice_units_to_units $v2_old]
    #     set unit_to [gid_groups_conds::nice_units_to_units $v2]
    # 
    #     catch {
        #         set nv [gid_groups_conds::convert_unit_value $domNode $magnitude \
            #                 $v1 $unit_from $unit_to]
        #         set v1 [gid_groups_conds::nice_number $nv]
        #     }
    #     set v2_old $v2
    # }

proc lsdyna::function_loads_hydrostatic { what n pn f domNode funcNode \
    units_var ov_var } {
    
    global ProblemTypePriv
    
    switch $what {
        create {
            set help [= "This is a triangular load that has value 0.0 at the reference coordinate (in the sense of the gravity) and gives an hydrostatic pressure that depends on the self-weight of the water or terrain"]
            
            set f1 [ttk::frame $f.f1]
            
            set node [gid_groups_conds::give_node_xpath {//value[@n="units_mesh"]}]
            set unit [get_domnode_attribute $node v]
            
            ttk::label $f1.l1 -text [= "Reference coordinate (%s)" D]:
            gid_groups_conds::register_popup_help $f1.l1 $help
            ttk::entry $f1.e1 -textvariable ProblemTypePriv(flh_ref_coord)
            ttk::label $f1.l1u -text $unit
            
            ttk::label $f1.l2 -text [= "Water self-weight (%s)" \u03b3]:
            gid_groups_conds::register_popup_help $f1.l2 $help
            
            set ::ProblemTypePriv(flh_ref_coord) 0.0
            
            gid_groups_conds::entry_units $f1.sw -unit_magnitude F/L^3 \
                -value_variable ProblemTypePriv(flh_self_weight) -units_variable ProblemTypePriv(flh_self_weight_units)
            grid $f1.l1 $f1.e1 $f1.l1u -sticky w -padx 2 -pady 2
            grid $f1.l2 $f1.sw - -sticky w -padx 2 -pady 2
            grid configure $f1.sw -sticky ew
            
            if { ![info exists ProblemTypePriv(l_hydro_img)] } {
                set ::ProblemTypePriv(l_hydro_img) [image create photo -file [file join $::ProblemTypePriv(problemtypedir) images carga_hidrostatica.gif]]
            }
            
            label $f.image -image $::ProblemTypePriv(l_hydro_img)
            
            grid $f1 $f.image -sticky nw -padx 2 -pady 2
            grid configure $f.image -sticky new
            
            grid columnconfigure $f 0 -weight 1
            grid rowconfigure $f 0 -weight 1
            
            if { $funcNode ne "" } {
                set xp {functionVariable[@variable="xyz" and
                    @n="hydrostatic_load"]}
                set fvarNode [$funcNode selectNodes $xp]
            } else { set fvarNode "" }
            if { $fvarNode ne "" } {
                set pnList [list [= "Reference coordinate (%s)" D] \
                        [= "Water self-weight (%s)" \u03b3]]
                foreach i [list flh_ref_coord flh_self_weight] \
                    n [list reference_coordinate water_self_weight] \
                    pn $pnList {
                    set xp [format_xpath {string(value[@n=%s]/@v)} $n]
                    set ::ProblemTypePriv($i) [$fvarNode selectNodes $xp]  
                    if { $i eq "flh_self_weight" } {
                        set xp [format_xpath {string(value[@n=%s]/@units)} $n]
                        set ::ProblemTypePriv(flh_self_weight_units) \
                            [gid_groups_conds::units_to_nice_units [$fvarNode selectNodes $xp]] 
                    }
                }
            }
            return [= "Hydrostatic load"]
        }
        apply {
            set f1 $f.f1
            set pnList [list [= "Reference coordinate (%s)" D] \
                    [= "Water self-weight (%s)" \u03b3]]
            foreach i [list flh_ref_coord flh_self_weight] \
                e [list $f1.e1 $f1.sw.e] pn $pnList {
                if { ![string is double -strict $::ProblemTypePriv($i)] } {
                    tk::TabToWindow $e
                    error [= "Value %s is not OK" $pn]
                }
            }
            set xp {functionVariable[@variable="xyz"]}
            if { [$funcNode selectNodes $xp] eq "" } {
                set fvarNode [$funcNode appendChildTag functionVariable]
            } else {
                set fvarNode [$funcNode selectNodes $xp]
                foreach i [$fvarNode childNodes] { $i delete }
            }
            $fvarNode setAttribute n hydrostatic_load pn [= "Hydrostatic load"] \
                variable "xyz"
            foreach i [list flh_ref_coord flh_self_weight] \
                n [list reference_coordinate water_self_weight] \
                pn $pnList {
                set v [$fvarNode appendChildTag value [list attributes() \
                            n $n pn $pn v $::ProblemTypePriv($i)]]
                if { $i eq "flh_self_weight" } {
                    set newunits [gid_groups_conds::nice_units_to_units \
                            $::ProblemTypePriv(flh_self_weight_units)]
                    $v setAttribute unit_magnitude "F/L^3" \
                        units $newunits
                }
            }
        }
    }
}

proc lsdyna::function_loads_sinusoidal { what n pn f domNode funcNode units_var ov_var } {
    #THE WHOLE FUNCTION HAS BEEN MODIFIED BECAUSE BOTH ENDING AND INITIAL TIME ARE NOT IMPLEMENTED AT THE MOMENT
    
    global ProblemTypePriv
    
    switch $what {
        create {
            set help [= "This is a a sinusoidal load that depends on the time"]
            
            set f1 [ttk::frame $f.f1]
            
            set idx 0
            
            foreach i [list amplitude circular_frequency phase_angle ] \
                n [list [= "Amplitude (%s)" A] \
                    [= "Circular frequency (%s)" \u03c9] [= "Phase angle (%s)" \u3a6]] \
                m [list - Rotation Rotation ] \
                u [list - rad rad ] \
                v [list 1.0 3.1416 0.0 ] {
                
                
                ttk::label $f1.l$idx -text $n:
                gid_groups_conds::register_popup_help $f1.l$idx $help
                
                if { $m ne "-" } {
                    gid_groups_conds::entry_units $f1.sw$idx \
                        -unit_magnitude $m \
                        -value_variable ProblemTypePriv($i) \
                        -units_variable ProblemTypePriv(${i}_units)
                } else {
                    ttk::entry $f1.sw$idx -textvariable ProblemTypePriv($i)
                    set ::ProblemTypePriv($i) $v
                }
                grid $f1.l$idx $f1.sw$idx -sticky w -padx 2 -pady 2
                grid configure $f1.sw$idx -sticky ew
                incr idx
            }
            if { ![info exists ProblemTypePriv(l_sin_img)] } {
                set ::ProblemTypePriv(l_sin_img) [image create photo \
                        -file [file join $::ProblemTypePriv(problemtypedir) images \
                            carga_sinusoidal.gif]]
            }
            
            ttk::label $f1.l -text "f(t)=A*sin(\u03c9t+\u03a6)" \
                -relief solid -padding 3 -width 20 \
                -anchor w
            grid $f1.l -sticky w -padx 6 -pady 6
            
            label $f.image -image $::ProblemTypePriv(l_sin_img) -bd 1 -relief solid
            
            grid $f1 $f.image -sticky nw -padx 8 -pady 2
            grid configure $f.image -sticky new
            
            grid columnconfigure $f 1 -weight 1
            grid rowconfigure $f 0 -weight 1
            
            if { $funcNode ne "" } {
                set xp {functionVariable[@variable="t" and
                    @n="sinusoidal_load"]}
                set fvarNode [$funcNode selectNodes $xp]
            } else { set fvarNode "" }
            if { $fvarNode ne "" } {
                
                
                foreach i [list amplitude circular_frequency phase_angle ] \
                    pn [list [= "Amplitude (%s)" A] \
                        [= "Circular frequency (%s)" \u03c9] [= "Phase angle (%s)" \u3a6] ] \
                    m [list - Rotation Rotation ] {
                    
                    set xp [format_xpath {string(value[@n=%s]/@v)} $i]
                    set ::ProblemTypePriv($i) [$fvarNode selectNodes $xp]
                    if { $m ne "-" } {
                        set xp [format_xpath {string(value[@n=%s]/@units)} $i]
                        set ::ProblemTypePriv(${i}_units) \
                            [gid_groups_conds::units_to_nice_units [$fvarNode selectNodes $xp]] 
                    }
                }
            }
            return [= "Sinusoidal load"]
        }
        apply {
            set idx 0
            set f1 $f.f1
            
            foreach i [list amplitude circular_frequency phase_angle] \
                pn [list [= "Amplitude (%s)" A] \
                    [= "Circular frequency (%s)" \u03c9] [= "Phase angle (%s)" \u3a6] ] \
                m [list - Rotation Rotation ] {
                if { ![string is double -strict $::ProblemTypePriv($i)] } {
                    if { $m ne "-" } { set e $f1.sw$idx.e } else { set e $f1.sw$idx }
                    tk::TabToWindow $e
                    error [= "Value %s is not OK" $pn]
                }
                incr idx
            }
            set xp {functionVariable[@variable="t"]}
            if { [$funcNode selectNodes $xp] eq "" } {
                set fvarNode [$funcNode appendChildTag functionVariable]
            } else {
                set fvarNode [$funcNode selectNodes $xp]
                foreach i [$fvarNode childNodes] { $i delete }
            }
            $fvarNode setAttribute n sinusoidal_load pn [= "Sinusoidal load"] \
                variable "t"
            
            
            foreach i [list amplitude circular_frequency phase_angle] \
                pn [list [= "Amplitude (%s)" A] \
                    [= "Circular frequency (%s)" \u03c9] [= "Phase angle (%s)" \u3a6] ] \
                m [list - Rotation Rotation ] {
                
                set v [$fvarNode appendChildTag value [list attributes() \
                            n $i pn $pn v $::ProblemTypePriv($i)]]
                if { $m ne "-" } {
                    set newunits [gid_groups_conds::nice_units_to_units \
                            $::ProblemTypePriv(${i}_units)]
                    $v setAttribute unit_magnitude $m \
                        units $newunits
                }
            }
        }
    }
}


proc lsdyna::function_non_linear_elastic_constraints { ftype what n pn f \
    domNode funcNode units_var ov_var } {
    
    global ProblemTypePriv
    
    switch $what {
        create {
            set help [= "The elastic constraint is non linear and is only activated in degree '%s' for the chosen situation: only compression or only tension" $pn]
            
            ttk::label $f.l -text $pn:
            cu::combobox $f.cb -textvariable ProblemTypePriv(type) -values \
                [list compression_only tensile_only] -dict \
                [list compression_only "Compression only" \
                    tensile_only "Tensile only"] -state readonly
            gid_groups_conds::register_popup_help $f.l $help
            
            ttk::label $f.l2 -text [= "%s stiffness" $pn]:
            gid_groups_conds::register_popup_help $f.l2 $help
            
            gid_groups_conds::entry_units $f.e1 \
                -unit_magnitude [$domNode @unit_magnitude] \
                -value_variable ProblemTypePriv(stiffness) \
                -units_variable $units_var \
                -ov_variable $ov_var
            
            grid $f.l $f.cb   -sticky nw -padx 2 -pady 2
            grid $f.l2 $f.e1 -sticky nw -padx 2 -pady 2
            
            grid columnconfigure $f 2 -weight 1
            grid rowconfigure $f 1 -weight 1
            
            if { $funcNode ne "" } {
                set xp {functionVariable[@n="NL_elastic_constraints"]}
                set fvarNode [$funcNode selectNodes $xp]
            } else { set fvarNode "" }
            if { $fvarNode ne "" } {
                set xp {string(value[@n="compression_tensile"]/@v)}
                set ::ProblemTypePriv(type) [$fvarNode selectNodes $xp]
                set xp {string(value[@n="stiffness"]/@v)}
                set ::ProblemTypePriv(stiffness) [$fvarNode selectNodes $xp]
                
            } else {
                set ::ProblemTypePriv(type) compression_only
                set ::ProblemTypePriv(stiffness) 0.0
            }
            return [= "Compression/Tensile only"]
        }
        apply {
            set xp {functionVariable[@n="NL_elastic_constraints"]}
            if { [$funcNode selectNodes $xp] eq "" } {
                set fvarNode [$funcNode appendChildTag functionVariable]
            } else {
                set fvarNode [$funcNode selectNodes $xp]
                foreach i [$fvarNode childNodes] { $i delete }
            }
            $fvarNode setAttribute n NL_elastic_constraints pn \
                [= "Compression/Tensile only"] variable $n
            $fvarNode appendChildTag value [list attributes() \
                    n compression_tensile pn [= "Compression/Tensile only"] \
                    v $::ProblemTypePriv(type)]
            $fvarNode appendChildTag value [list attributes() \
                    n stiffness pn [= "Stiffness"] \
                    v $::ProblemTypePriv(stiffness)]
        }
    }
}

proc lsdyna::custom_data_edit { domNode dict } {
    if { ![interp exists ramdebugger] } { interp create ramdebugger }
    ramdebugger eval [list set argv [list -noprefs -rgeometry 500x250+300+300 -onlytext]]
    package require RamDebugger
    
    if { [dict exists $dict tcl_code] } {
        set data [string trim [dict get $dict tcl_code]]
    } else {
        set xp {string(value[@n="tcl_code"]/@v)}
        set data [string trim [$domNode selectNodes $xp]]
    }
    if { $data eq "" } {
        set data [format "#    %s\n#    %s\n" [= "Enter TCL code to define a load"] [= "Use menu 'Custom data' for help"]]
    }
    set ::end_edit_custom_data ""
    interp alias ramdebugger EditEndInRamDebugger "" lappend ::end_edit_custom_data
    ramdebugger eval [list RamDebugger::OpenFileSaveHandler "*custom data*" $data EditEndInRamDebugger]
    
    set menu ""
    foreach "n nargs" [list coords 2 conec 1 nnode 0 elem_num 0 elem_normal 1 epsilon 0 facLoad 0] {
        set name [= "Insert command '%s'" $n]
        set cmd {
            set t $::RamDebugger::text
            $t insert insert [list %N%]
            $t insert insert "("
            $t insert insert [string repeat , %NARGS%]
            $t insert insert ")"
            $t mark set insert "insert-[expr {%NARGS%+1}]c"
        }
        set cmd [string map [list %N% $n %NARGS% $nargs] \
                $cmd]
        lappend menu [list command $name "" "" "" -command $cmd]
    }
    lappend menu [list separator]
    
    foreach "n nfull" [list \
            add_to_load_vector "add_to_load_vector ?-substitute? ?-local? nodenum loadvector" \
            addload "addload ?-local? pressure|triangular_pressure|punctual_load args"] {
        set name [= "Insert command '%s'" $n]
        set cmd {
            $::RamDebugger::text insert insert [list %NFULL%]
        }
        set cmd [string map [list %NFULL% $nfull] $cmd]
        lappend menu [list command $name "" "" "" -command $cmd]
    }
    ramdebugger eval [list RamDebugger::AddCustomFileTypeMenu [= "Custom data"] $menu]
    vwait ::end_edit_custom_data
    set data [string trim [lindex $::end_edit_custom_data 1]]
    set d [dict create tcl_code $data]
    return [list $d ""]
}

################################################################################
#             Add items to control-1 contextual menu
################################################################################

proc lsdyna::AddDataItemsToMenu { menu whatuse type entity } {
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    switch $type {
        Points { set cnds point_groups }
        Lines { set cnds line_groups }
        Surfaces { set cnds surface_groups }
        Volumes { set cnds volume_groups }
        Nodes { set cnds point_groups }
        Elements { set cnds "line_groups surface_groups volume_groups" }
    }
    switch $type Points - Lines - Surfaces - Volumes { set where geometry } Nodes - \
        Elements { set where mesh }
    
    set doc $gid_groups_conds::doc
    
    set submenu ""
    set needsseparator 0
    foreach cnd $cnds {
        set ret [GiD_Info Conditions $cnd $where $entity]
        foreach i $ret {
            foreach "num face - group" $i break
            if { $num == 0 } { continue }
            if { $num eq "E" } { set num $face }
            if { $submenu == "" } {
                set j 1
                while { [winfo exists $menu.m$j] } { incr j }
                set submenu [menu $menu.m$j -tearoff 0]
                set text [= Groups]
                $menu add cascade -label $text -menu $submenu
                set needsseparator 1
            }
            set xp [format_xpath {//group[@n=%s and ancestor::condition]} \
                    $group]
            set domNodes [$doc selectNodes $xp]
            
            set txt [= "Group: %s" $group]
            if { ![llength $domNodes] } {
                ContextualEntity::AddToMenu $submenu $txt \
                    [list lsdyna::_AddDataItemsToMenuItem $group]
            } else {
                set j 1
                while { [winfo exists $submenu.m$j] } { incr j }
                set subsubmenu [menu $submenu.m$j -tearoff 0]
                $submenu add cascade -label $txt -menu $subsubmenu
                ContextualEntity::AddToMenu $subsubmenu $txt \
                    [list lsdyna::_AddDataItemsToMenuItem $group]
                foreach domNode $domNodes {
                    set cndNode [$domNode selectNodes ancestor::condition]
                    set blockNode [$domNode selectNodes {ancestor::blockdata[@sequence='1']}]
                    if { $blockNode ne "" } {
                        set txt [= "Condition: %s - %s" [$blockNode @name] [$cndNode @pn]]
                    } else {
                        set txt [= "Condition: %s" [$cndNode @pn]]
                    }
                    ContextualEntity::AddToMenu $subsubmenu $txt \
                        [list lsdyna::_AddDataItemsToMenuItemD $group \
                            $domNode]
                }
            }
        }
    }
    if { $needsseparator } { $menu add separator }
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    
}

proc lsdyna::_AddDataItemsToMenuItem { group } {
    gid_groups_conds::open_groups .gid window_force window
    set wg $gid_groups_conds::gid_group_var
    set tree [$wg givetreectrl]
    
    $tree selection clear
    foreach item [$tree item children root] {
        if { [$tree item text $item 0] eq $group } {
            $tree selection add $item
            break
        }
    }
}

proc lsdyna::_AddDataItemsToMenuItemD { group domNode } {
    
    set what [gid_groups_conds::open_conditions window_type]
    if { $what eq "none" } { set what window }
    
    set xpath [gid_groups_conds::nice_xpath $domNode]
    gid_groups_conds::open_conditions $what -select_xpath $xpath
}


proc lsdyna::CancelResults {} {
    
    set dir [lindex [GiD_Info Project] 1].gid
    set basename [file tail [lindex [GiD_Info Project] 1]]
    
    set file1 [file join $dir $basename.flavia.res]
    if { ![file exists $file1] } {
        WarnWin [= "There are no results"]
        return
    }
    set size [file size $file1]
    
    foreach i [list .dat .flavia.msh .err .war .info .detailed.xml] {
        if { [file exists [file join $dir $basename$i]] } {
            incr size [file size [file join $dir $basename$i]]
        }
    }
    set size [expr int($size/1024)]
    
    set txt [= "Do you want to cancel results (size=%s Kb)?" $size]
    set retval [tk_messageBox -default ok -icon question -message $txt -type okcancel]
    if { $retval == "cancel" } { return }
    file delete $file1
    foreach i [list .dat .flavia.msh .err .war .info .detailed.xml] {
        file delete [file join $dir $basename$i]
    }
}

proc lsdyna::LamResults {} {
    global MenuNamesP MenuEntriesP MenuCommandsP
    
    set curr [GiD_Info postprocess get cur_analisis]
    set cstep [GiD_Info post get cur_step $curr]
    if {$curr == "" || $cstep == ""} {
        return
    }
    
    set restypes [GiD_Info postprocess get results_list Contour_Fill $curr $cstep]
    set num [lsearch $MenuNamesP [_ "View results"]]
    set flagSet 0
    
    foreach {i j} [array get MenuEntriesP $num,*] {
        foreach data $j { 
            set aux2 [lindex $j 0]
            if { [lindex $j 1] == "More..." } {
                set flagSet 1
                break
            }
        }
    }
    
    if { [lsearch $restypes Laminate*] != -1 } {
        if {$flagSet == 0 } {
            set ip 17
            lappend MenuEntriesP($num) [= "Laminates"] ---
            lappend MenuCommandsP($num)  "" ""
            set MenuEntriesP($num,$ip) ""
            set MenuCommandsP($num,$ip) ""
            set jp 0
            foreach i $restypes {
                if { [string match Laminate* $i] } {
                    lappend MenuEntriesP($num,$ip) [string map [list _ " "] $i]
                    set comp [GiD_Info post get components_list Contour_Fill $i $curr $cstep]
                    if { [llength $comp] == 1 } {
                        lappend MenuCommandsP($num,$ip) "-np- lsdyna::DisplayContourFill $i $comp"
                    } else {
                        lappend MenuCommandsP($num,$ip) ""
                        foreach j [lrange $comp 0 2] {
                            lappend MenuEntriesP($num,$ip,$jp) $j
                            lappend MenuCommandsP($num,$ip,$jp) "-np- lsdyna::DisplayContourFill $i $j"
                        }
                    }
                    incr jp
                }
            }
            lappend MenuEntriesP($num,$ip) [= "More..."]
            lappend MenuCommandsP($num,$ip) "-np- lsdynaLaminateResults::LoadNewResult"
            #         incr ip 2
        } else {
            return
        }
    } else {
        return
    }
    
    
}

proc lsdyna::DisplayContourFill { args } {
    set DisableGraphics [.central.s disable graphics]
    .central.s disable graphics 1
    GiD_Process escape escape escape escape Results Geometry NoResults Geometry Original
    GiD_Process escape escape escape escape Results ContourFill {*}$args escape
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    GiD_Redraw
}

proc lsdyna::RamTempDir {} { 
    return [lindex [GiD_Info Project] 9] 
}

#CREATED LS-DYNA PROC THAT ALLOWS THE USER TO PICK UP POINTS FROM THE SCREEN

proc lsdyna::pick_joint_points { wp dict dict_units domNode pos } {
    
    set point [GidUtils::GetCoordinates [_ "Please pick the point from the screen"]]
    if { $point=="" } return "" 
    
    switch $pos {
        0 {
            set components_list [list x_r y_r z_r]
        }
        1 {
            set components_list [list x y z]
        }
        2 {
            set components_list [list x_2 y_2 z_2]
        }
        3 {
            set components_list [list x_3 y_3 z_3]
        }
        4 {
            set components_list [list x_4 y_4 z_4]
        }
    }   
    
    #we consider mesh units
    
    set mesh_units [dict get $dict units_mesh_auxiliar]
    set mesh_factor [lsdyna::convert_distance_to_factor $mesh_units]    
    
    foreach i $components_list j [list 0 1 2] {   
        
        set coord_units [dict get $dict_units $i]
        set coord_factor [lsdyna::convert_distance_to_factor $coord_units]
        
        set factor [expr ($mesh_factor/$coord_factor)]        
        dict set dict $i [ expr ($factor*[lindex $point $j])]
    } 
    
    return [list $dict $dict_units]    
}


#CREATED PROC THAT DRAW ALL JOINT POINTS

proc lsdyna::draw_joint_points { wp dict dict_units domNode} {
    
    set list_1 ""
    set list_2 ""
    set list_3 ""
    set list_4 ""
    set list_5 ""
    
    set joint_type [dict get $dict Joint_type]
    
    switch $joint_type {
        Spherical {
            set points_list [list x y z]
            set container_list [list list_1 list_1 list_1]
        }
        Revolute {
            set points_list [list x y z x_2 y_2 z_2]
            set container_list [list list_1 list_1 list_1 list_2 list_2 list_2]
        }
        Translational {
            set points_list [list x y z x_2 y_2 z_2 x_3 y_3 z_3]
            set container_list [list list_1 list_1 list_1 list_2 list_2 list_2 list_3 list_3 list_3]
        }
        Seatbelt {
            set sensor_number [dict get $dict Sensor_number]
            switch $sensor_number {
                1 {
                    set points_list [list x_r y_r z_r x y z]
                    set container_list [list list_1 list_1 list_1 list_2 list_2 list_2]
                }
                2 {
                    set points_list [list x_r y_r z_r x y z x_2 y_2 z_2]
                    set container_list [list list_1 list_1 list_1 list_2 list_2 list_2 list_3 list_3 list_3]
                }
                3 {
                    set points_list [list x_r y_r z_r x y z x_2 y_2 z_2 x_3 y_3 z_3]
                    set container_list [list list_1 list_1 list_1 list_2 list_2 list_2 list_3 list_3 list_3 list_4 list_4 list_4]
                }
                4 {
                    set points_list [list x_r y_r z_r x y z x_2 y_2 z_2 x_3 y_3 z_3 x_4 y_4 z_4]
                    set container_list [list list_1 list_1 list_1 list_2 list_2 list_2 list_3 list_3 list_3 list_4 list_4 list_4 list_5 list_5 list_5]
                }
            }
        }
    }  
    
    #we consider mesh units
    
    set mesh_units [dict get $dict units_mesh_auxiliar]
    set mesh_factor [lsdyna::convert_distance_to_factor $mesh_units]
    
    foreach i $points_list j $container_list {  
        
        set coord_units [dict get $dict_units $i]
        set coord_factor [lsdyna::convert_distance_to_factor $coord_units]
        
        set factor [expr ($coord_factor/$mesh_factor)]    
        lappend $j [expr ($factor*[dict get $dict $i])]   
    }  
    
    set draw_result [GiD_Process escape escape escape escape utilities SignalEntities Point FNoJoin $list_1 $list_2 $list_3 $list_4 $list_5]
    
}

#CREATED PROC THAT DEFINE A COORDINATE SYSTEM FROM THREE POINTS

proc lsdyna::pick_joint_coordinate_system { wp dict dict_units domNode entity} {
    
    set point_1 [GidUtils::GetCoordinates [_ "Enter Local Axes center"] NoJoin]
    if { $point_1=="" } return ""
    
    set point_2 [GidUtils::GetCoordinates [_ "Enter Point in Positive X axe (it will be inside the plane)"] NoJoin]
    if { $point_2=="" } return "" 
    
    set point_3 [GidUtils::GetCoordinates [_ "Enter Point in Positive Z axe (the point will be exactly inside the axes)"] NoJoin]
    if { $point_3=="" } return ""    
    
    #we consider mesh units
    
    set mesh_units [dict get $dict units_mesh_auxiliar]
    set mesh_factor [lsdyna::convert_distance_to_factor $mesh_units]
    
    set points_list [list point_1 point_1 point_1 point_2 point_2 point_2 point_3 point_3 point_3]
    set position_list [list 0 1 2 0 1 2 0 1 2]
    
    switch $entity {
        1 {
            set components_list [list x_center_1 y_center_1 z_center_1 x_posx_1 y_posx_1 z_posx_1 x_posz_1 y_posz_1 z_posz_1]
            dict set dict Axes_system_1 local
        }
        2 {
            set components_list [list x_center_2 y_center_2 z_center_2 x_posx_2 y_posx_2 z_posx_2 x_posz_2 y_posz_2 z_posz_2]
            dict set dict Axes_system_2 local
        }
    }  
    
    foreach i $components_list j $points_list k $position_list {   
        
        set coord_units [dict get $dict_units $i]
        set coord_factor [lsdyna::convert_distance_to_factor $coord_units]
        
        set factor [expr ($mesh_factor/$coord_factor)]        
        dict set dict $i [ expr ($factor*[lindex [subst "$$j"] $k])]
    } 
    
    return [list $dict $dict_units]    
    
    #     set p [MathUtils::VectorDiff $p1 $p2]
}


#THIS PROCESS SHOULD BE DONE AUTOMATICALLY 

proc lsdyna::convert_distance_to_factor {unit} {
    
    switch $unit {
        m {
            return 1.0
        }
        cm {
            return 1.0e-2
        }
        mm {
            return 1.0e-3
        }
        km {
            return 1.0e+3
        }
        in {
            return 25.4e-3
        } 
        default {
            error [= "This application only works with the following units: m,cm,mm,km,in"]
        }
    }
}

#WRITING LSDYNA.INI

proc lsdyna::WriteTCLDefaultsInFile {} {
    global GidPriv LsdynaPriv
    
    if { $::GidPriv(OffScreen)} {
        return
    }
    if { [GiD_Set SaveGidDefaults] } {
        set file [lsdyna::GivelsdynaPreferencesFile]
        if { [catch { set fileid [open $file w] }] } {
            return 0
        }        
        if {![info exists ::LsdynaPriv(SolverPath)]} {
            set ::LsdynaPriv(SolverPath) {C:\LSDYNA\program\ls971_d_7600_winx64_p.exe}
        }                    
        puts $fileid "SolverPath $::LsdynaPriv(SolverPath)"        
        close $fileid
    }    
    return 1
}

#READING LSDYNA.INI

proc lsdyna::ReadDefaultValues {} {
    global LsdynaPriv
    
    set file [lsdyna::GivelsdynaPreferencesFile]
    if { [catch { set fileid [open $file r] }] } {
        return 0
    }
    while { ![eof $fileid] } {
        set aa [gets $fileid]
        if { [catch { set varname [lindex $aa 0] } ] } { continue }
        switch -- $varname {
            SolverPath {
                set ::LsdynaPriv(SolverPath) [lindex $aa 1]
            }            
        }
    }
    close $fileid
    
    return 1
}
