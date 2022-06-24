
proc GiD_Event_InitProblemtype { dir } {
    global ProblemTypePriv NastranPriv
    global GidPriv
    
    GiD_Set MaintainProblemTypeInNew 1
    set ProblemTypePriv(nastrantype) "GiD"    
    set ProblemTypePriv(problemtypedir) $dir
    
    array set problemtype_local [GidUtils::ReadProblemtypeXml [file join $dir nastran.xml] Infoproblemtype {Name Version MinimumGiDVersion}]
    set ::ProblemTypePriv(name) $problemtype_local(Name)
    set ::ProblemTypePriv(version) $problemtype_local(Version)
    if { [GidUtils::VersionCmp $problemtype_local(MinimumGiDVersion)] < 0 } {  
	    W [= "This problemtype requires GiD %s or later" $problemtype_local(MinimumGiDVersion)]
    }
           
    if { [info exists ::GidPriv(CalculationFileExtension)] } {
        set ProblemTypePriv(OldCalculationFileExtension) $::GidPriv(CalculationFileExtension)
    }
    set ::GidPriv(CalculationFileExtension) ".nas"
    
    GidUtils::DisableWarnLine
    GidShowBook intvdata "" 0    
    NASTRANWindonsMat
    
    package require BWidget    
    package require base64    
    package require helpviewer
    package require tablelist_tile
        
    foreach i [list nastranpch2gid.tcl function.tcl \
            tkcheckdata.tcl verify_properties.tcl \
            nasmat.tcl buttontable.tcl loadcases.tcl heatboundaries.tcl \
            convection.tcl nastogid.tcl nasmat_anisotropicshell.tcl nasmat_orthotropicshell.tcl \
            calcangle.tcl baswriter.tcl plate.tcl buttonmaterial.tcl materialsmatrixtemp.tcl \
            nassections.tcl composite.tcl] {
        source [file join $dir scripts $i]
    }
    
    LoadCasesInit $dir
        
    
    foreach i [list PostCmdAssignMat] {
        if { [info command Nastran$i] == "" } {
            rename $i Nastran$i
            set err [ catch {rename NastranBase$i $i} errstring]
        }
    }
    
    if { ![info exists ::NastranPriv(splash_showed)] } {
        Splash $dir 1
        set ::NastranPriv(splash_showed) 1
    }
    
    NastranBitmaps $dir
    
    set ::GidPriv(ProgName) $::ProblemTypePriv(name)
    ChangeWindowTitle   
    UpdateMenusNastran
    GidUtils::EnableWarnLine
}

proc GiD_Event_EndProblemtype {} {
    global ProblemTypePriv
    
    if { [info exists ProblemTypePriv(condfuns)] } {
        foreach i $ProblemTypePriv(condfuns) {
            catch { rename $i {} }
            catch { rename $i-base $i }
        }
    }
    catch { destroy .gid.loadcases }
    foreach i [list PostCmdAssignMat DWDrawMaterials DWUnassignMat] {
        if { [info command Nastran$i] != "" } {
            catch {rename $i "" }
            catch { rename Nastran$i $i }
        }
    }
    global GidPriv
    set ::GidPriv(ProgName) GiD
    ChangeWindowTitle ""
    EndNastranBitmaps
    if { [info exists ProblemTypePriv(OldCalculationFileExtension)] } {
        set ::GidPriv(CalculationFileExtension) $ProblemTypePriv(OldCalculationFileExtension)
    } else {
        unset ::GidPriv(CalculationFileExtension)
    }
    array unset ProblemTypePriv
}

proc GiD_Event_BeforeWriteCalculationFile { file  } {
    if { [array exists NasComposite::matidlist]} {
        foreach name [array names NasComposite::matidlist] {
            unset NasComposite::matidlist($name)
        }
    }
    if { [array exists plate::matidlist]} {
        foreach name [array names plate::matidlist] {
            unset plate::matidlist($name)
        }
    }
    set BasWriter::currentmatid 0    
}

proc GiD_Event_ChangedLanguage { language  } {
    #to force refresh some menus managed by the problemtype when the user change to newlanguage
    UpdateMenusNastran
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


proc UpdateMenusNastran { } {
    global ProblemTypePriv
    
    set dir $ProblemTypePriv(problemtypedir)        
    foreach where {PRE POST} {        
        GiDMenu::InsertOption "Help#C#menu" [list [= "%s Interface tutorials" $::ProblemTypePriv(name)]] 0 $where \
            [list GiDHelpViewer::Show [file join $dir info en NT index.html] -title [= "%s Interface tutorials" $::ProblemTypePriv(name)]] "" "" "insert"
        GiDMenu::InsertOption "Help#C#menu" [list [= "%s Interface help" $::ProblemTypePriv(name)]] 0 $where \
            [list GiDHelpViewer::Show [file join $dir info en NRM index.html] -title [= "%s Interface help" $::ProblemTypePriv(name)]] "" "" "insert"
        GiDMenu::InsertOption "Help#C#menu" [list [= "About %s Interface" $::ProblemTypePriv(name)]] end $where [list Splash $dir 0] "" "" "insertafter"
    }    
    GiDMenu::InsertOption "Files#C#menu" [list "Import#C#menu" [= "Import PUNCH"]...] end POST [list PCH2GiD $dir 1 0] "" "" "insertafter"
    GiDMenu::InsertOption "Files#C#menu" [list "Import#C#menu" [= "Import PUNCH(Smooth)"]...] end POST [list PCH2GiD $dir 1 1] "" "" "insertafter"
    
    #UpdateDataOptionsNastran
    #to force refresh some menus managed by the problemtype when the user change to newlanguage
    DWInitUserDataOptions ;#reset default options
    
    GidChangeDataLabel "Problem Data" ""
    GidChangeDataLabel "Conditions" ""
    GidChangeDataLabel "Materials" ""
    GidChangeDataLabel "Interval" ""
    GidChangeDataLabel "Interval Data" ""
    
    GidAddUserDataOptions [= "Load cases"] "LoadCaseWindow" 2
    GidAddUserDataOptionsMenu [= "Boundary Conditions"] "NastranBoundaryconditionsSubmenu %W" 3
    GidAddUserDataOptionsMenu [= "Loads"] "NastranLoadsSubmenu %W" 4
    GidAddUserDataOptions [= "Advanced Conditions"] "GidOpenConditions Advanced_Conditions" 5
    GidAddUserDataOptions [= "Rigid bodies"] "GidOpenConditions Rigid_Body" 6
    GidAddUserDataOptions [= "Materials"] "GidOpenMaterials Material" 7
    GidAddUserDataOptionsMenu [= "Properties"] "NastranPropertiesSubmenu %W" 8
    GidAddUserDataOptionsMenu [= "Analysis Design"] "NastranAnalysisSubmenu %W" 9
    GidAddUserDataOptionsMenu [= "Problem data"] "NastranProblemdataSubmenu %W" 10
    GidAddUserDataOptions [= "Verify Properties"] VerifyProperty 11
    GidAddUserDataOptions "---" "" 12     
    CreateTopMenus ;#apply menu changes
}

proc NastranPropertiesSubmenu { w } {
    $w del 0 end
    $w add command -label [= "Property"] -command [list GidOpenMaterials Property ]
    $w add command -label [= "Local Axes"] -command [list GidOpenConditions Local_Axes ]
    $w configure -postcommand ""
}

proc NastranLoadsSubmenu { w } {
    $w del 0 end
    $w add command -label [= "Static Loads"] -command [list GidOpenConditions Static_Loads ]
    $w add command -label [= "Dynamics Loads"] -command [list GidOpenConditions Dynamics_Loads ]
    $w add command -label [= "Thermal Loads"] -command [list GidOpenConditions Thermal_Loads ]
    $w add command -label [= "Tables"] -command [list GidOpenMaterials Tables ]
    $w configure -postcommand ""
}

proc NastranBoundaryconditionsSubmenu { w } {
    $w del 0 end
    $w add command -label [= "Constraints"] -command [list GidOpenConditions Constraints ]
    $w add command -label [= "Connections"] -command [list GidOpenConditions Connections ]
    $w add command -label [= "Heat Boundaries"] -command [list GidOpenConditions Heat_Boundaries ]
    $w configure -postcommand ""
}

proc NastranProblemdataSubmenu { w } {
    $w del 0 end
    $w add command -label [= "Executive Control"] -command [list GidOpenProblemData Executive_Control]
    $w add command -label [= "Case Control"] -command [list GidOpenProblemData Case_Control]
    $w add command -label [= "Parameters"] -command [list GidOpenProblemData Parameters]
    $w configure -postcommand ""
}

proc NastranAnalysisSubmenu { w } {
    $w del 0 end
    $w add command -label [= "Thermal"] -command [list GidOpenProblemData Thermal]
    $w add command -label [= "Dynamics"] -command [list GidOpenProblemData Dynamics]
    $w add command -label [= "Buckling"] -command [list GidOpenProblemData Buckling]
    $w add command -label [= "NonLinear"] -command [list GidOpenProblemData NonLinear]
    $w configure -postcommand ""
}

proc Splash { dir { autodestroy 1 } } {
    global ProblemTypePriv
    GidUtils::Splash [file join $dir images nasopen.gif] .splash $autodestroy [list $::ProblemTypePriv(version) 62 62]
}

proc NASTRANWindonsMat { } {    
    GiD_DataBehaviour material Isotropic hide {delete}
    GiD_DataBehaviour material Anisotropic_Shell hide {delete}
    GiD_DataBehaviour material Orthotropic_Shell hide {delete}
    GiD_DataBehaviour materials Material hide {assign draw unassign}
    GiD_DataBehaviour materials Tables hide {assign draw unassign}
    GiD_DataBehaviour material Bar hide {delete}
    GiD_DataBehaviour material Beam hide {delete}
    GiD_DataBehaviour material Tube hide {delete}
    GiD_DataBehaviour material Pipe hide {delete}
    GiD_DataBehaviour material Cable hide {delete}
    GiD_DataBehaviour material Rod hide {delete}
    GiD_DataBehaviour material Shear_Panel hide {delete}
    GiD_DataBehaviour material Plate hide {delete}
    GiD_DataBehaviour material Viscous_Damper hide {delete}
    GiD_DataBehaviour material Laminate hide {delete}
    GiD_DataBehaviour material Spring hide {delete}
    GiD_DataBehaviour material DOF_Spring hide {delete}
    GiD_DataBehaviour material Tetrahedron hide {delete}
    GiD_DataBehaviour material Hexahedron hide {delete}
    GiD_DataBehaviour material Table hide {delete}    
}

proc NastranBase2PostCmdAssignMat { GDN w Menu entitylabel entitytype } {
    $Menu del 0 end
    if { [catch { set whatuse [lindex [GiD_Info Project] 4] }] } {
        set whatuse GEOMETRYUSE
    }
    switch $whatuse {
        GEOMETRYUSE {
            $Menu add command -label $entitylabel -command [list DWAssignMaterials $GDN $w $entitytype]
        }
        MESHUSE {
            set entitylabel [= "Elements"]
            set entitytype Elements
            $Menu add command -label $entitylabel -command [list DWAssignMaterials $GDN $w $entitytype]
        }
    }
}

proc NastranBasePostCmdAssignMat { GDN w Menu } {
    
    if { [::GidUtils::VersionCmp 7.4.1b] >= 0 } { 
        set _MatName [DWGetCurrentMaterial $GDN] 
    } else {
        upvar \#0 $GDN GidData
        set _MatName [DWSpace2Under $GidData(MAT,matname)] ;#deprecated
    }
    
    set property [lindex [GiD_Info Materials $_MatName] 4]
    set book [GiD_Info Materials $_MatName BOOK]
    
    set LinesMats [list BAR BEAM TUBE VISCOUS_DAMPER SPRING DOF_SPRING ROD]
    set SurfacesMats [list PLATE SHEAR_PANEL LAMINATE ]
    set VolumesMats [list TETRAHEDRON HEXAHEDRON] 
    if { [lsearch $LinesMats $property] != -1 } {
        NastranBase2PostCmdAssignMat $GDN $w $Menu [= "Lines"] "Lines"
    } elseif { [lsearch $SurfacesMats $property] != -1 } {
        NastranBase2PostCmdAssignMat $GDN $w $Menu [= "Surfaces"] "Surfaces"
    } elseif { [lsearch $VolumesMats $property] != -1 } {
        NastranBase2PostCmdAssignMat $GDN $w $Menu [= "Volumes"] "Volumes"
    } elseif { $book != "Material" && $book != "Tables"} {
        NastranPostCmdAssignMat $GDN $w $Menu
    }
    #    else {
        #         $Menu del 0 end
        #        $Menu add command -label [= "This material or table cannot be assigned"]
        #     }
}

proc NASTRANlaunch { } {
    if { $::tcl_platform(platform) == "windows" } {
        package require registry 
        if { [catch {registry get {HKEY_LOCAL_MACHINE\SOFTWARE\Noran Engineering\Engine} Path} aux] } {
            WarnWin [= "Unable to find NE/NASTRAN installation directory. Automatic Editor launch will be disable"]
        } else {
            set NASTRANPath [file join $aux Editor.exe]
            #         set modelname [lindex [GiD_Info project] 1]
            #         if { $modelname == "UNNAMED" } {
                #             set filename [Browser-ramR project write .gid [= "Save Project"]] 
                #             if { $filename == "" } return
                #             GiD_Process escape escape escape escape Files SaveAs $filename
                #         }
            if { [GiD_Info Mesh]== 0 } {
                WarnWin [= "Don't forget to generate the mesh"]
                return
            }
            if { [lindex [GiD_Info project] 10]==1 } {
                WarnWin [= "WARNING: Some changes have been made to geometry, conditions or materials. Mesh should probably be generated again."]
            }
            GidUtils::WaitState .gid             
            WriteCalcFile
            set modelname [file join [lindex [GiD_Info project] 1].gid [file tail [lindex [GiD_Info project] 1]].nas]
            exec $NASTRANPath $modelname >& NUL: &            
            GidUtils::EndWaitState .gid
        }
    }
}

proc PCH2GiD { dir reenterpost  smooth } {
    
    global DefaultSearchDirectory
    
    if { ![info exists DefaultSearchDirectory] || \
        ![file isdirectory $DefaultSearchDirectory]} {
        set DefaultSearchDirectory [pwd]
    }
    set deft $DefaultSearchDirectory
    
    set types [list \
            [list [= "PUNCH files"] .pch] \
            [list [= "All files"] *]]
    
    #set filein [tk_getOpenFile -defaultextension ".pch"  -initialdir $deft -parent .gid -filetypes $types]
    set filein [Browser-ramR file read .gid [= "Load PUNCH files"] $deft $types "" 0]
    
    if { $filein == "" } {
        return
    }
    set DefaultSearchDirectory [file dirname $filein]
    
    set aa [GiD_Info Project]
    set ProjectName [lindex $aa 1]
    if { [file extension $ProjectName] == ".gid" } {
        set ProjectName [file root $ProjectName]
    }
    if { $ProjectName == "UNNAMED" } {
        tk_dialogRAM .gid.tmpwin error \
            [= "Before importing, a project title is needed. Save project to get it"] \
            error 0 OK
        return
    }
    
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
        set directory [file join [pwd] $directory]
    }
    set fileout [file join $directory [file root [file tail $ProjectName]].flavia.res]
    
    PCH2GiD::TranslateW  $filein $fileout $smooth
    
    if { $reenterpost } {
        set DisableGraphics [.central.s disable graphics]
        set DisableWarnLine [.central.s disable warnline]
        .central.s disable graphics 1
        .central.s disable warnline 1
        GiD_Process escape escape escape escape preprocess yes 
        GiD_Process escape escape escape escape postprocess yes
        if { !$DisableGraphics } { .central.s disable graphics 0 }
        if { !$DisableWarnLine } { .central.s disable warnline 0 }
    }
}

proc NastranBitmaps { dir { type "DEFAULT INSIDELEFT"} } {
    global NastranBitmapsNames NastranBitmapsCommands NastranBitmapsHelp
    global ProblemTypePriv
    
    set NastranBitmapsNames(0) "images/l1.gif images/constraints.gif \
        images/heatboundaries.gif --- images/loads.gif images/dynamicloads.gif \
        images/thermalloads.gif --- \
        images/section.gif images/localaxes.gif --- \
        images/executivecontrol.gif images/casecontrol.gif --- images/dynamics.gif \
        images/buckling.gif images/nonlinear.gif --- images/mesh.gif images/calculate.gif" 
    if {$ProblemTypePriv(nastrantype) == "NENASTRAN" } { 
        set NastranBitmapsCommands(0) [list {} [list -np- GidOpenConditions Constraints] \
                [list -np- GidOpenConditions Heat_Boundaries] \
                "" \
                [list -np- GidOpenConditions Static_Loads] \
                [list -np- GidOpenConditions Dynamics_Loads] \
                [list -np- GidOpenConditions Thermal_Loads] \
                "" \
                [list -np- GidOpenMaterials Property] \
                [list -np- GidOpenConditions Local_Axes] \
                "" \
                [list -np- GidOpenProblemData Executive_Control] \
                [list -np- GidOpenProblemData Case_Control] \
                "" \
                [list -np- GidOpenProblemData Dynamics] \
                [list -np- GidOpenProblemData Buckling] \
                [list -np- GidOpenProblemData  NonLinear] \
                "" \
                "Meshing generate" \
                [list -np- NASTRANlaunch]]
    } else {
        set NastranBitmapsCommands(0) [list {} [list -np- GidOpenConditions Constraints] \
                [list -np- GidOpenConditions Heat_Boundaries] \
                "" \
                [list -np- GidOpenConditions Static_Loads] \
                [list -np- GidOpenConditions Dynamics_Loads] \
                [list -np- GidOpenConditions Thermal_Loads] \
                "" \
                [list -np- GidOpenMaterials Property] \
                [list -np- GidOpenConditions Local_Axes] \
                "" \
                [list -np- GidOpenProblemData Executive_Control] \
                [list -np- GidOpenProblemData Case_Control] \
                "" \
                [list -np- GidOpenProblemData Dynamics] \
                [list -np- GidOpenProblemData Buckling] \
                [list -np- GidOpenProblemData  NonLinear] \
                "" \
                "Meshing generate" \
                [list -np- WriteCalcFile]]
    }
    set NastranBitmapsHelp(0) [list \
            "" \
            [= "Assign Constraints"] \
            [= "Assign Heat Boundaries"] \
            "" \
            [= "Assign Static Loads"] \
            [= "Assign Dynamic Loads"] \
            [= "Assign Thermal Loads"] \
            "" \
            [= "Assign Properties"] \
            [= "Define Local Axes for 1-D elements\nDefine Material Orientation."] \
            "" \
            [= "Define parameters of Executive Control section"] \
            [= "Define parameters of Case Control section"] \
            "" \
            [= "Define parameters of Dynamic Analysis"] \
            [= "Define parameters of Buckling Analysis"] \
            [= "Define parameters of NonLinear Analysis"] \
            "" \
            [= "Generate Mesh" "Write Nastran Input file"]]
    
    set NastranBitmapsNames(0,0) ""
    set NastranBitmapsCommands(0,0) ""
    
    # prefix values:
    #          Pre        Only active in the preprocessor
    #          Post       Only active in the postprocessor
    #          PrePost    Active Always
    
    set prefix Pre
    
    set ProblemTypePriv(toolbarwin) [CreateOtherBitmaps NastranBar [= "Nastran toolbar"] \
            NastranBitmapsNames NastranBitmapsCommands \
            NastranBitmapsHelp $dir "NastranBitmaps [list $dir]" $type $prefix]
    set title [= "Nastran toolbar"]
    AddNewToolbar "$::ProblemTypePriv(name) bar" ${prefix}NastranBarWindowGeom "NastranBitmaps [list $dir]" $title
    
    # button number 3
    set ProblemTypePriv(loadcasewin) $ProblemTypePriv(toolbarwin).0
    
    if { [info exists ProblemTypePriv(loadcaseimg1)] } {
        ChangeToLoadCase 1
    }
    
}

proc EndNastranBitmaps {} {
    global ProblemTypePriv
    
    ReleaseToolbar "$::ProblemTypePriv(name) bar"
    rename NastranBitmaps ""
    
    catch { destroy $ProblemTypePriv(toolbarwin) }
}

proc WriteCalcFile {} {
    if { [GiD_Set DefaultFileNameInCalcFile] && [GidUtils::ModelHasName] } {
        GiD_Process Mescape Files WriteCalcFile
    } else {
        set directory [GidUtils::GetDirectoryModel]
        if { [GidUtils::ModelHasName] } {
            if { [file pathtype $directory] == "relative" } {
                set directory [file join [pwd] $directory]
            }
        } else {
            if { ![file exists $directory] } {
                file mkdir $directory
            }
        }
        set modelname [file rootname $directory]
        set filename [GidUtils::GetFilenameInsideProject $modelname .nas]
        GiD_Process Mescape Files WriteCalcFile $filename
    }
    return 0
}
