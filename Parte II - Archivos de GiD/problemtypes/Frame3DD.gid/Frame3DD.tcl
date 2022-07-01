proc InitGIDProject { dir } {
    Frame3DD::InitGIDProject $dir
}

proc EndGIDProject {} {  
    Frame3DD::EndGIDProject   
}

proc ChangedLanguage { newlan } {
    Frame3DD::ChangeMenus
}

proc LoadGIDProject { filespd } {    
    Frame3DD::LoadGIDProject $filespd    
}

proc SaveGIDProject { filespd } {
    set filename [file rootname $filespd].xml
    Frame3DD::SaveXml $filename
}

#GiD-tcl event automatically invoked when the calculation is finished, to convert results
proc GiD_Event_AfterRunCalculation { basename dir problemtypedir where error errorfilename } {
    if { $error == 0 } {
        set filename [file join [lindex $dir 0] $basename].out        
        if { [catch { Frame3DD::TransformResultsToGiD $filename } err] } {
            WarnWin [= "Error %s" $err]
        }
    }
    return
}

proc AfterMeshGeneration { fail } {
    if { !$fail } {
        Frame3DD::TransferSpecialConditions
    }
    return ""
}

proc BeforeInitGIDPostProcess { } {
    set model_name [GiD_Info Project ModelName]    
    set filename [file join $model_name.gid [file tail $model_name]].post.res
    if { ![file exists $filename] } {
        WarnWin [= "Results file '%s' doesn't exists" $filename]
        return -cancel-
    }
}

proc InitGIDPostProcess { } {
    Frame3DD::SetStaticStep 1.0
}
  
#define the procedures in a separated namespace named Frame3DD
namespace eval Frame3DD {
    variable ProgramName Frame3DD
    variable VersionNumber ;#interface version, get it from xml to avoid duplication
    variable _dir ;#path to the problemtype   
}

proc Frame3DD::InitGIDProject { dir } {
    variable _dir
    set Frame3DD::_dir $dir
    set data [GidUtils::ReadProblemtypeXml [file join $dir Frame3DD.xml] Infoproblemtype {Version MinimumGiDVersion}]      
    if { $data == "" } {
        WarnWinText [= "Configuration file %s not found" [file join $dir Frame3DD.xml]]
        return 1
    }    
    array set problemtype_local $data
    set Frame3DD::VersionNumber $problemtype_local(Version)

    if { [GidUtils::VersionCmp $problemtype_local(MinimumGiDVersion)] < 0 } {  
        WarnWinText [= "This problemtype requires GiD %s or later" $problemtype_local(MinimumGiDVersion)]
    }    
    package require math::linearalgebra
    package require math::interpolate
    package require gid_draw_opengl
    
    GiD_DataBehaviour materials DefaulDrawPointLoadt hide {assign draw unassign}
    GiD_OpenGL registercondition Frame3DD::DrawLineInteriorPointLoad line_Interior_point_load
    GiD_OpenGL registercondition Frame3DD::DrawPointLoad point_Load
    GiD_OpenGL registercondition Frame3DD::DrawPointMomentum point_Momentum
    GiD_OpenGL registercondition Frame3DD::DrawLineUniformLoad line_Uniform_load
    GiD_OpenGL registercondition Frame3DD::DrawLineTrapezoidalLoad line_Trapezoidal_load
    GiD_OpenGL registercondition Frame3DD::DrawLineSectionProperties Section_properties

    Frame3DD::Splash

    GiD_RegisterPluginAddedMenuProc Frame3DD::ChangeMenus
    
    GiDMenu::DisableUpdateMenus
    set ::GidPriv(HideVolumeLevel) 1 ;#changing this variable hide menus and toolbars related to volumes
    set ::GidPriv(HideSurfaceLevel) 1 ;#changing this variable hide menus and toolbars related to surfaces
    set ::GidPriv(HideQuadraticTypeLevel) [expr 1+2+4] ;#changing this variable hide all: 2^0=linear, 2^1=quadratic and 2^2 quadratic9 from menus and preferences
    #Frame3DD::ChangeMenus
    GiDMenu::EnableUpdateMenus
    GiDMenu::UpdateMenus
}

proc Frame3DD::EndGIDProject { } {
    variable _opengl_draw_list    
    #Frame3DD::RestoreMenus
    GiD_UnRegisterPluginAddedMenuProc Frame3DD::ChangeMenus
    GiDMenu::DisableUpdateMenus
    set ::GidPriv(HideVolumeLevel) 0
    set ::GidPriv(HideSurfaceLevel) 0
    set ::GidPriv(HideQuadraticTypeLevel) 0    
    GiDMenu::EnableUpdateMenus
    GiDMenu::UpdateMenus 
##    cannot unregistercondition because the conditions have been deleted when calling EndGIDProject
#     foreach condition {line_Interior_point_load point_Load point_Momentum line_Uniform_load line_Trapezoidal_load Section_properties} {
#         GiD_OpenGL unregistercondition $condition
#     }
    foreach item [array names Frame3DD::_opengl_draw_list] {
        GiD_OpenGL draw -deletelists [list $Frame3DD::_opengl_draw_list($item) 1]
    }
    array unset _opengl_draw_list
}

proc Frame3DD::SaveXml { filename } {
    variable ProgramName
    variable VersionNumber
    set fp [open $filename w]
    if { $fp != "" } {
        puts $fp {<?xml version='1.0' encoding='utf-8'?><!-- -*- coding: utf-8;-*- -->}
        puts $fp "<$ProgramName version='$VersionNumber'/>"
        close $fp
    }
}

#return -1 if the xml is not an problemtype one or if the xml not exists
#        the problemtype version of the model of the xml file
proc Frame3DD::ReadXml { filename } {
    variable ProgramName
    set model_problemtype_version_number -1
    if { [file exists $filename] } {
        set fp [open $filename r]
        if { $fp != "" } {
            set line ""
            gets $fp header
            gets $fp line ;#something like: <Frame3DD version='1.0'/>
            close $fp
            set line [string range $line 1 end-2]
            set model_problemtype [lindex $line 0]
            if { $model_problemtype == $ProgramName } {
                set model_version [lindex $line 1]
                if { [lindex [split $model_version =] 0] == "version" } {
                    set model_problemtype_version_number [string range [lindex [split $model_version =] 1] 1 end-1]
                }
            } else {
                set model_problemtype_version_number -1
            }
        }
    }
    return $model_problemtype_version_number
}

proc Frame3DD::Transform { from_version to_version } {    
    variable ProgramName
    GiD_Process escape escape escape escape Data Defaults TransfProblem $ProgramName escape    
}

proc Frame3DD::LoadGIDProject { filespd } {        
    if { [file join {*}[lrange [file split $filespd] end-1 end]] == "Frame3DD.gid/Frame3DD.spd" } {
        #loading the problemtype itself, not a model
    } else {
        set pt [GiD_Info project ProblemType]
        if { $pt == "Frame3DD" } {
            set filename [file rootname $filespd].xml
            set model_problemtype_version_number [Frame3DD::ReadXml $filename]            
            if { $model_problemtype_version_number != -1 && $model_problemtype_version_number < $::Frame3DD::VersionNumber } {            
                set must_transform 1
            } else {
                set must_transform 0
            }
            if { $must_transform } {
                after idle [list Frame3DD::Transform $model_problemtype_version_number $::Frame3DD::VersionNumber]
            }
        }
    }
}

proc Frame3DD::ChangeMenus { } {
    variable ProgramName   
    GiDMenu::RemoveOption View  [list "Full screen"] PREPOST
    GiDMenu::RemoveOption Geometry [list Create Polyline] PRE
    GiDMenu::RemoveOption Geometry [list Create ---1] PRE
    GiDMenu::RemoveOption Geometry [list Create "Geometry from mesh"] PRE
    GiDMenu::RemoveOption Geometry [list Edit Divide Polylines] PRE
    GiDMenu::RemoveOption Geometry [list Edit Polyline] PRE
    GiDMenu::RemoveOption Utilities [list ---5] PRE
    GiDMenu::RemoveOption Utilities [list "Repair model"] PRE
    GiDMenu::RemoveOption Mesh [list Unstructured] PRE
    GiDMenu::RemoveOption Mesh [list Cartesian] PRE
    GiDMenu::RemoveOption Mesh [list "Quadratic type"] PRE
    GiDMenu::RemoveOption Mesh [list "Mesh criteria"] PRE
    GiDMenu::RemoveOption Mesh [list Draw "Element type"] PRE
    GiDMenu::RemoveOption Mesh [list Draw "Mesh / No mesh"] PRE
    GiDMenu::RemoveOption Mesh [list Draw "Structured type"] PRE
    GiDMenu::RemoveOption Mesh [list Draw "Skip entities (Rjump)"] PRE
    GiDMenu::RemoveOption Mesh [list Draw "Unstructured mesher"] PRE
    GiDMenu::RemoveOption Help [list "Register GiD"] PREPOST
    GiDMenu::RemoveOption Help [list "Register problem type"] PREPOST
    GiDMenu::RemoveOption Help [list "Register from file"] PREPOST
    GiDMenu::RemoveOption Help [list ---0] PREPOST
    
    GiDMenu::RemoveOption Files [list "Open multiple"] POST
    GiDMenu::RemoveOption Files [list Merge] POST
    GiDMenu::RemoveOption Files [list Import Cut] POST
    GiDMenu::RemoveOption Files [list Import "Stream lines"] POST
    GiDMenu::RemoveOption Files [list Export "Post information" "Stream lines"] POST
    GiDMenu::RemoveOption Files [list Export "Cut"] POST
    GiDMenu::RemoveOption Files [list Export "Cover mesh"] POST
    GiDMenu::RemoveOption View  [list Mode] POST  
    GiDMenu::RemoveOption View [list ---4] PREPOST
    GiDMenu::Delete Geometry POST
    GiDMenu::RemoveOption Utilities [list "Scale result view"] POST    
    GiDMenu::Delete "View results" POST
    GiDMenu::Create Results POST 3   
    set i -1
    GiDMenu::InsertOption Results [list "No results"] [incr i] POST \
        [list GiD_Process Mescape Results Geometry NoResults Geometry Original Geometry HideTheShow] "" element.png    
    GiDMenu::InsertOption Results [list "Analysis/step"] [incr i] POST [list Frame3DD::StaticResultsMenu %W] "" PostBarAnalysisStep.png
    GiDMenu::InsertOption Results [list "Analysis/step" ""] 0 POST "" "" ""
    GiDMenu::InsertOption Results [list "Deformated"] [incr i] POST \
        [list GiD_Process Mescape Results Geometry Deformation Displacements] "" PostBarDeformation.png
    GiDMenu::InsertOption Results [list ---] [incr i] POST "" "" ""
    GiDMenu::InsertOption Results [list "Line diagram"] [incr i] POST "" "" ""
    set j 0
    foreach result {My' Mz' Nx' Vy' Vz' Tx'} {
        if { [string index $result 1] == "x" } {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results LineDiagram ScalarDiagram $result]
        } else {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results LineDiagram VectorDiagram $result |$result|]
        }
        GiDMenu::InsertOption Results [list "Line diagram" $result] $j POST $cmd "" ""
        incr j
    }
    GiDMenu::InsertOption Results [list "Line thickness"] [incr i] POST "" "" PostBarLineThickness.png
    set j 0
    foreach result {My' Mz' Nx' Vy' Vz' Tx'} {
        if { [string index $result 1] == "x" } {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results LineThickness $result]
        } else {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results LineThickness $result |$result|]
        }
        GiDMenu::InsertOption Results [list "Line thickness" $result] $j POST $cmd "" ""
        incr j
    }
    GiDMenu::InsertOption Results [list "Contour fill"] [incr i] POST "" "" PostBarContourFill.png
    set j 0
    foreach result {My' Mz' Nx' Vy' Vz' Tx' Displacements} {
        if { [string index $result 1] == "x" } {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results ContourFill $result]
        } else {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results ContourFill $result |$result|]
        }
        GiDMenu::InsertOption Results [list "Contour fill" $result] $j POST $cmd "" ""
        incr j
    }
    GiDMenu::InsertOption Results [list "Min max"] [incr i] POST "" "" PostBarShMinMax.png
    set j 0
    foreach result {My' Mz' Nx' Vy' Vz' Tx' Displacements Reaction_forces Reaction_moments} {
        if { [string index $result 1] == "x" } {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results ShMinMax $result]
        } else {
            set cmd [list Frame3DD::ProcessStaticResult Mescape Results ShMinMax $result |$result|]
        }
        GiDMenu::InsertOption Results [list "Min max" $result] $j POST $cmd "" ""
        incr j
    }    
    GiDMenu::InsertOption Results [list ---] [incr i] POST "" "" ""
    GiDMenu::InsertOption Results [list "Reactions"] [incr i] POST "" "" PostBarVectors.png
    GiDMenu::InsertOption Results [list "Reactions" "Forces"] 0 POST \
        [list Frame3DD::ProcessStaticResult Mescape Results DisplayVectors Reaction_forces |Reaction_forces|] "" ""
    GiDMenu::InsertOption Results [list "Reactions" "Moments"] 1 POST \
        [list Frame3DD::ProcessStaticResult Mescape Results DisplayVectors Reaction_moments |Reaction_moments|] "" ""
    GiDMenu::InsertOption Results [list ---] [incr i] POST "" "" ""
    GiDMenu::InsertOption Results [list "Vector displacement"] [incr i] POST  \
        [list Frame3DD::ProcessStaticResult Mescape Results DisplayVectors Displacements |Displacements|] "" PostBarVectors.png    
    GiDMenu::InsertOption Results [list ---] [incr i] POST "" "" ""
    GiDMenu::InsertOption Results [list "Modal displacement"] [incr i] POST [list Frame3DD::DynamicResultsMenu %W] "" ""
    GiDMenu::InsertOption Results [list "Modal displacement" ""] 0 POST "" "" ""
    
    GiDMenu::RemoveOption Window [list "Several results"] POST
    GiDMenu::RemoveOption Window [list "Results ranges table"] POST
    GiDMenu::RemoveOption Window [list "Create result"] POST
    GiDMenu::RemoveOption Window [list "Create statistical result"] POST
    GiDMenu::RemoveOption Window [list "Create graphs"] POST
    GiDMenu::RemoveOption Window [list ---0] POST
        
    GiDMenu::InsertOption Help [list [concat [= "Help on"] $ProgramName]...] 0 PREPOST {GiDCustomHelp -start "Frame3DD-manual.html" -report 0} "" "" insert =      
    GiDMenu::InsertOption Help [list [concat [= "About"] $ProgramName ...]] end PREPOST Frame3DD::About "" "" insert =    
    GiDMenu::UpdateMenus
}

proc Frame3DD::ProcessStaticResult { args } {
    #set result [GiD_Info postprocess get cur_result]    
    if { [GiD_Info postprocess get cur_analysis] != "Static" } {
        GiD_Process Mescape Results AnalysisSel Static 1.0 escape        
    }
    GiD_Process {*}$args
}

proc Frame3DD::SetStaticStep { step } {
    set result_view [GiD_Info postprocess get cur_results_view] ;#e.g.Vector_Line_Diagram
    set result [GiD_Info postprocess get cur_result]
    GiD_Process Mescape Results AnalysisSel Static $step escape
    set ::GidPriv(PostResultsStep) $step
    if { $result != "" } {
        if { $result_view == "Vector_Line_Diagram" } {
            GiD_Process Mescape Results LineDiagram VectorDiagram $result |$result|
        } elseif { $result_view == "Scalar_Line_Diagram" } {
            GiD_Process Mescape Results LineDiagram ScalarDiagram $result    
        } elseif { $result_view == "Line_Thickness" || $result_view == "Contour_Fill" || $result_view == "Sh_Min_Max" } {
            set result_view_cmd [string map {_ ""} $result_view]
            if { [string index $result 1] == "x" } {
                GiD_Process Mescape Results $result_view_cmd $result
            } else {
                GiD_Process Mescape Results $result_view_cmd $result |$result|
            }   
        } elseif { $result_view == "Display_Vectors" } {
            set result_view_cmd [string map {_ ""} $result_view]
            GiD_Process Mescape Results $result_view_cmd $result |$result|
        } else {
            #not implemented in simplified results menu
        }
    }
}

proc Frame3DD::StaticResultsMenu { menu } {    
    set load_cases ""
    if { [catch { set load_cases [GiD_Info postprocess get all_steps Static] } msg] } {
        
    } else {
        
    }
    if { [GiD_Info postprocess get cur_analysis] == "Static" } {
        set current_load_case [GiD_Info postprocess get cur_step]
        if { ![info exists ::GidPriv(PostResultsStep)] } {
            set ::GidPriv(PostResultsStep) $current_load_case
        }
    } else {
        set current_load_case ""
    }
    $menu delete 0 end
    foreach load_case $load_cases {
        set i_load_case [expr int($load_case)]
        if { $current_load_case == $load_case } {
            $menu add checkbutton -label $i_load_case -variable ::GidPriv(PostResultsStep) \
                -indicatoron true -command [list Frame3DD::SetStaticStep $load_case]
            #-onvalue $load_case          
        } else {
            $menu add command -label $i_load_case -command [list Frame3DD::SetStaticStep $load_case]
        }
    }    
}

proc Frame3DD::SetDynamicResult { modal_result } {
    #set result [GiD_Info postprocess get cur_result]    
    if { [GiD_Info postprocess get cur_analysis] != "Dynamic" } {
        GiD_Process Mescape Results AnalysisSel Dynamic 0.0 escape        
    }
    GiD_Process Mescape Results Geometry NoResult Geometry Deformation $modal_result escape        
}

proc Frame3DD::DynamicResultsMenu { menu } {
    set modal_results ""
    if { [catch { set modal_results [GiD_Info postprocess get results_list contour_fill Dynamic 0.0] } msg] } {
        
    } else {
        
    }
    $menu delete 0 end
    foreach modal_result $modal_results {      
        set label $modal_result
        if { [string range $label 0 19] == "Modal_Displacements_" } {
            set label [string range $label 20 end]
        }
        $menu add command -label $label -command [list Frame3DD::SetDynamicResult $modal_result]        
    }
}
 
proc Frame3DD::RestoreMenus { } {
    variable ProgramName
    GiDMenu::RemoveOption Help [list [concat [= "Help on"] $ProgramName]...] PREPOST =
    GiDMenu::RemoveOption Help [list [concat [= "About"] $ProgramName ...]] PREPOST =       
    GiDMenu::UpdateMenus
}

proc Frame3DD::Splash { {self_close 1} } {
    variable _dir
    set prev_splash_state [GiD_Set SplashWindow]
    GiD_Set SplashWindow 1 ;#set temporary to 1 to force show splash without take care of the GiD splash preference
    set txt "$Frame3DD::ProgramName Version $Frame3DD::VersionNumber"
    GidUtils::Splash [file join $Frame3DD::_dir images splash.png] .splash $self_close [list $txt 180 280]
    GiD_Set SplashWindow $prev_splash_state
}

proc Frame3DD::About { } {
    set self_close 0
    Frame3DD::Splash $self_close
}    

proc Frame3DD::TransferSpecialConditions { } {
    #line_Interior_point_load must replace all elements of the same geometric entiy 
    #by a single element where the parameters lies
    set condition_names {line_Interior_point_load line_Trapezoidal_load}
    set element_level line
    foreach condition_name $condition_names {
        array unset geometry_elements
        foreach item [GiD_Info Conditions $condition_name mesh] {
            set element_id [lindex $item 1]
            #use as key all applied values instead geometry_id, because allow repeat the condition, then the geometry_id is not enough
            #the values are then stored in the key
            set key [lrange $item 3 end]
            lappend geometry_elements($key) $element_id
        }
        GiD_UnAssignData Condition $condition_name Elements all
        foreach key [array names geometry_elements] {
            if { $condition_name == "line_Interior_point_load" } {
                lassign $key geometry_id coordinates_system parameters fx fy fz ;#Id hidden field to identify geometry parent
                set xyz [GiD_Info Parametric $element_level $geometry_id coord {*}$parameters]   
                set element_id [GidUtils::GetClosestElement $element_level $xyz $geometry_elements($key)]
                if { $element_id != "" } {
                    set res [GidUtils::GetElementRelativeCoordinatesFromCoord $element_level $xyz $element_id]  
                    set relative_coordinates [lrange $res 0 end-1]
                    set new_values [list $geometry_id $coordinates_system $relative_coordinates $fx $fy $fz]
                    GiD_AssignData condition $condition_name Elements $new_values $element_id
                } else {
                    W "projection $element_level element not found"
                }
            } elseif { $condition_name == "line_Trapezoidal_load" } {
                lassign $key geometry_id coordinates_system start_parameters start_fx start_fy start_fz \
                   end_parameters end_fx end_fy end_fz;#Id hidden field to identify geometry parent
                #take into account units
                foreach axis {x y z} {
                    lassign [GidConvertValueUnit [set start_f$axis]] start_f$axis strength_linear_unit
                    lassign [GidConvertValueUnit [set end_f$axis]] end_f$axis strength_linear_unit
                }                
                set start_xyz [GiD_Info Parametric $element_level $geometry_id coord {*}$start_parameters]
                set end_xyz [GiD_Info Parametric $element_level $geometry_id coord {*}$end_parameters]
                array unset node_t
                foreach element_id $geometry_elements($key) {                  
                    foreach node_id [lrange [GiD_Mesh get element $element_id] 3 4] {
                        if { ![info exists node_t($node_id)] } {
                            set xyz [lrange [GiD_Mesh get node $node_id] 1 3]
                            set node_t($node_id) [GiD_Info Parametric $element_level $geometry_id t_fromcoord {*}$xyz]
                        }
                    }                    
                }
                foreach element_id $geometry_elements($key) {
                    lassign [lrange [GiD_Mesh get element $element_id] 3 4] n0 n1                                      
                    if { $node_t($n0)<$end_parameters && $node_t($n1)>$start_parameters} {
                        if { $node_t($n0)<$start_parameters } {
                            #start_parameters is inside this element
                            set line_t0 $start_parameters
                            set element_t0 [expr {($line_t0-$node_t($n0))/($node_t($n1)-$node_t($n0))}]
                        } else {
                            set line_t0 $node_t($n0)
                            set element_t0 0.0
                        }
                        if { $node_t($n1)>$end_parameters } {
                            #start_parameters is inside this element
                            set line_t1 $end_parameters
                            set element_t1 [expr {($line_t1-$node_t($n0))/($node_t($n1)-$node_t($n0))}]
                        } else {
                            set line_t1 $node_t($n1)
                            set element_t1 1.0
                        }                        
                        foreach axis {x y z} {   
                            set data [list $start_parameters [set start_f${axis}] $end_parameters [set end_f${axis}]]
                            set start_element_f${axis} [math::interpolate::interp-linear $data $line_t0]$strength_linear_unit
                            set end_element_f${axis} [math::interpolate::interp-linear $data $line_t1]$strength_linear_unit
                        }                        
                        set new_values [list $geometry_id $coordinates_system \
                                $element_t0 $start_element_fx $start_element_fy $start_element_fz \
                                $element_t1 $end_element_fx $end_element_fy $end_element_fz]
                        GiD_AssignData condition $condition_name Elements $new_values $element_id                   
                    }
                }
            } else {
                W "unexpected condition_name=$condition_name"
            }
        }
    }       
}

proc Frame3DD::DrawPointLoad  { condition use entity_id values } {    
    gid_draw_opengl::set_scale_draw_loads [GiD_AccessValue get gendata Scale_draw_loads]
    if { $use == "GEOMETRYUSE" } {
        set xyz(p1) [lrange [GiD_Geometry get point $entity_id] 1 3]
    } elseif { $use == "MESHUSE" } {
        set xyz(p1) [lrange [GiD_Mesh get node $entity_id] 1 3]
    } elseif { $use == "POSTUSE" } {
        return 0
    } else {
        return 0
    }   
    lassign $values fx fy fz
    set fx [lindex [GidConvertValueUnit $fx] 0]
    set fy [lindex [GidConvertValueUnit $fy] 0]
    set fz [lindex [GidConvertValueUnit $fz] 0]
    set f [list $fx $fy $fz]    
    gid_draw_opengl::draw_symbol_point_load $xyz(p1) $f
    return 1 ;# 1 avoids drawing the standard symbol   
}

proc Frame3DD::DrawPointMomentum  { condition use entity_id values } {    
    if { $use == "GEOMETRYUSE" } {
        set xyz(p1) [lrange [GiD_Geometry get point $entity_id] 1 3]
    } elseif { $use == "MESHUSE" } {
        set xyz(p1) [lrange [GiD_Mesh get node $entity_id] 1 3]
    } elseif { $use == "POSTUSE" } {
        return 0
    } else {
        return 0
    }   
    lassign $values mx my mz
    set mx [lindex [GidConvertValueUnit $mx] 0]
    set my [lindex [GidConvertValueUnit $my] 0]
    set mz [lindex [GidConvertValueUnit $mz] 0]
    set m [list $mx $my $mz]
    gid_draw_opengl::draw_symbol_point_momentum $xyz(p1) $m
    return 1 ;# 1 avoids drawing the standard symbol    
}

proc Frame3DD::DrawLineInteriorPointLoad { condition use entity_id values } {   
    if { $use == "GEOMETRYUSE" } {
        lassign [lrange [GiD_Geometry get line $entity_id] 2 3] p1 p2
        set xyz(p1) [lrange [GiD_Geometry get point $p1] 1 3]
        set xyz(p2) [lrange [GiD_Geometry get point $p2] 1 3]
    } elseif { $use == "MESHUSE" } {
        lassign [lrange [GiD_Mesh get element $entity_id] 3 4] p1 p2
        set xyz(p1) [lrange [GiD_Mesh get node $p1] 1 3]
        set xyz(p2) [lrange [GiD_Mesh get node $p2] 1 3]
    } elseif { $use == "POSTUSE" } {
        return 0
    } else {
        return 0
    }
    lassign $values id coordinates_system relative_position fx fy fz
    set coordinates_system [string tolower $coordinates_system]
    set fx [lindex [GidConvertValueUnit $fx] 0]
    set fy [lindex [GidConvertValueUnit $fy] 0]
    set fz [lindex [GidConvertValueUnit $fz] 0]
    set f [list $fx $fy $fz]
    gid_draw_opengl::draw_symbol_line_interior_point_load $xyz(p1) $xyz(p2) $f $coordinates_system $relative_position
    return 1 ;# 1 avoids drawing the standard symbol
}

proc Frame3DD::DrawLineUniformLoad { condition use entity_id values } {    
    if { $use == "GEOMETRYUSE" } {
        lassign [lrange [GiD_Geometry get line $entity_id] 2 3] p1 p2
        set xyz(p1) [lrange [GiD_Geometry get point $p1] 1 3]
        set xyz(p2) [lrange [GiD_Geometry get point $p2] 1 3]
    } elseif { $use == "MESHUSE" } {
        lassign [lrange [GiD_Mesh get element $entity_id] 3 4] p1 p2
        set xyz(p1) [lrange [GiD_Mesh get node $p1] 1 3]
        set xyz(p2) [lrange [GiD_Mesh get node $p2] 1 3]
    } elseif { $use == "POSTUSE" } {
        return 0
    } else {
        return 0
    }   
    lassign $values coordinates_system fx fy fz
    set coordinates_system [string tolower $coordinates_system]
    set fx [lindex [GidConvertValueUnit $fx] 0]
    set fy [lindex [GidConvertValueUnit $fy] 0]
    set fz [lindex [GidConvertValueUnit $fz] 0]
    set f [list $fx $fy $fz]
    gid_draw_opengl::draw_symbol_line_uniform_load $xyz(p1) $xyz(p2) $f $coordinates_system
    return 1 ;# 1 avoids drawing the standard symbol
}

proc Frame3DD::DrawLineTrapezoidalLoad { condition use entity_id values } {   
    if { $use == "GEOMETRYUSE" } {
        lassign [lrange [GiD_Geometry get line $entity_id] 2 3] p1 p2
        set xyz(p1) [lrange [GiD_Geometry get point $p1] 1 3]
        set xyz(p2) [lrange [GiD_Geometry get point $p2] 1 3]
    } elseif { $use == "MESHUSE" } {
        lassign [lrange [GiD_Mesh get element $entity_id] 3 4] p1 p2
        set xyz(p1) [lrange [GiD_Mesh get node $p1] 1 3]
        set xyz(p2) [lrange [GiD_Mesh get node $p2] 1 3]
    } elseif { $use == "POSTUSE" } {
        return 0
    } else {
        return 0
    }   
    lassign $values id coordinates_system t0 f0x f0y f0z t1 f1x f1y f1z
    set coordinates_system [string tolower $coordinates_system]
    set f0x [lindex [GidConvertValueUnit $f0x] 0]
    set f0y [lindex [GidConvertValueUnit $f0y] 0]
    set f0z [lindex [GidConvertValueUnit $f0z] 0]   
    set f1x [lindex [GidConvertValueUnit $f1x] 0]
    set f1y [lindex [GidConvertValueUnit $f1y] 0]
    set f1z [lindex [GidConvertValueUnit $f1z] 0]
    set f0 [list $f0x $f0y $f0z]
    set f1 [list $f1x $f1y $f1z]
    gid_draw_opengl::draw_symbol_line_trapezoidal_load $xyz(p1) $xyz(p2) $f0 $f1 $coordinates_system $t0 $t1
    return 1 ;# 1 avoids drawing the standard symbol
}

proc Frame3DD::DrawLineSectionProperties { condition use entity_id values } {
    if { $use == "GEOMETRYUSE" } {
        lassign [lrange [GiD_Geometry get line $entity_id] 2 3] p1 p2
        set xyz(p1) [lrange [GiD_Geometry get point $p1] 1 3]
        set xyz(p2) [lrange [GiD_Geometry get point $p2] 1 3]
    } elseif { $use == "MESHUSE" } {
        lassign [lrange [GiD_Mesh get element $entity_id] 3 4] p1 p2
        set xyz(p1) [lrange [GiD_Mesh get node $p1] 1 3]
        set xyz(p2) [lrange [GiD_Mesh get node $p2] 1 3]
    } elseif { $use == "POSTUSE" } {
        return 0
    } else {
        return 0
    }   
    lassign $values coordinates_system ax asy asz jz iy iz material    
    #lassign [GiD_Info UnitsSystems modunit] magnitude index_units index_set    
    #set model_length_units [lindex [lindex [GiD_Info Magnitudes $index_set length units] $index_units] 1] ;#e.g. mm
    set length_factor [GidGetLengthFactor] ;#to convert from the declared model units to the destination units system for length magnitude    
    set section_width [expr {66e-3/$length_factor}] ;#140e-3m but expressed in current model units
    set section_heigth [expr {140e-3/$length_factor}] ;#66e-3m but expressed in current model units   
    if { $iy >= $iz } {
        set rotated 1
        #normal orientation of the profile agaings gravity loads       
    } else {
        set rotated 0
        #rotate 90 degrees swapping y-z axis       
    }
    gid_draw_opengl::draw_symbol_section_properties $xyz(p1) $xyz(p2) $rotated $section_width $section_heigth
    return 1 ;# 1 avoids drawing the standard symbol
}

#auxiliary procedure to be used to print material properties from the .bas template in the .dat calculation file 
proc Frame3DD::GetMaterialProperties { name } {
    set res ""
    set data [GiD_Info materials $name]
    foreach {question value} [lrange $data 1 end] {        
        lappend res [lindex [GidConvertValueUnit $value] 0]
    }
    return $res
}

proc Frame3DD::GetElementAbsoluteDistanceConsideringUnits { element_id relative_distance } {
    if { $relative_distance > 1.0 } {
        set relative_distance 1.0
    }
    set element_data [GiD_Mesh get element $element_id]
    set n0_xyz [lrange [GiD_Mesh get node [lindex $element_data 3]] 1 end]
    set n1_xyz [lrange [GiD_Mesh get node [lindex $element_data 4]] 1 end]
    set element_length [math::linearalgebra::norm_two [math::linearalgebra::sub_vect $n0_xyz $n1_xyz]]
    set length_factor [GidGetLengthFactor] ;#to convert from the declared model units to the destination units system for length magnitude
    set absolute_distance [expr {$relative_distance*$element_length*$length_factor}]
    set absolute_distance [format %.4f $absolute_distance] ;#dark trick to avoid calculation error considering by tolerence longer that length!!
    return $absolute_distance
}

proc Frame3DD::GetDxFromNumDivisions { num_divisions } {
    if { ![string is integer -strict $num_divisions] || $num_divisions<=0 } {        
        set dx -1 ;#-1 to not calculate internal forces
    } else {
        set min_length 1e30
        foreach {line_id line_length} [lrange [GiD_Info ListMassProperties Lines 1:end] 3 end-6] {
            if { $min_length > $line_length } {
                set min_length $line_length
            }
        }
        if  { $min_length <= 0.0 } {
            set dx -1 ;#-1 to not calculate internal forces
        } else {
            set length_factor [GidGetLengthFactor] ;#to convert declared model units to selected units system lenth unit
            set dx [expr {($min_length*$length_factor)/double($num_divisions)}]
        }            
    }        
    return $dx
}

proc Frame3DD::ConvertForceFromGlobalToLocal { element_id fx fy fz } {
    lassign [lrange [GiD_Mesh get element $element_id] 3 4] p1 p2
    set xyz(p1) [lrange [GiD_Mesh get node $p1] 1 3]
    set xyz(p2) [lrange [GiD_Mesh get node $p2] 1 3]
    set v12 [math::linearalgebra::sub_vect $xyz(p2) $xyz(p1)]
    set x_axis [math::linearalgebra::unitLengthVector $v12]    
    lassign [MathUtils::CalculateLocalAxisFromXAxis $x_axis] y_axis z_axis
    set matrix [math::linearalgebra::mkMatrix 3 3]
    math::linearalgebra::setrow matrix 0 $x_axis
    math::linearalgebra::setrow matrix 1 $y_axis
    math::linearalgebra::setrow matrix 2 $z_axis
    set f [math::linearalgebra::matmul $matrix [list $fx $fy $fz]]
    return $f
}

proc Frame3DD::ConvertForceFromGlobalToLocalGetIndex { element_id fx fy fz index } {
    return [lindex [Frame3DD::ConvertForceFromGlobalToLocal $element_id $fx $fy $fz] $index]
}

#auxiliary procedure used by TransformResultsToGiD
proc Frame3DD::_FileFind { fp text line } {
    set len [string length $text]
    if { [string range $line 0 $len-1] == $text } {
        return 1
    }
    while { ![eof $fp] } {
        gets $fp line           
        if { [string range $line 0 $len-1] == $text } {
            return 1
        }
    }
    return 0
}

#procedure to convert .out file to .post.res
proc Frame3DD::TransformResultsToGiD { filename } {
    if { ![file exists $filename] } {
        return
    }
    set fp [open $filename r]
    if { $fp == "" } {
        return
    }    
       
    set read_ifxx_files 1 ;#0 first version that only read forces at end, not the whole graph
    set non_numeric_values 0
    set exe_version ""
    set line ""        
    for {set i 0} {$i<13} {incr i} {
        gets $fp line          
        if { $i == 1 } {
            set exe_version [lindex $line 2]
        }
    }    
    set num_nodes [lindex $line 0]
    set num_constraints [lindex $line 2]
    set num_elements [lindex $line 5]
    set num_load_cases [lindex $line 8]
    for { set load_case 1 } { $load_case <= $num_load_cases } {incr load_case } {
        if { [Frame3DD::_FileFind $fp "L O A D   C A S E" $line] } {
            if { $exe_version == "20100105" } {
                # old version
                set displacements_text "J O I N T   D I S P L A C E M E N T S"
            } else {
                set displacements_text "N O D E   D I S P L A C E M E N T S"
            }           
            if { [Frame3DD::_FileFind $fp $displacements_text $line] } {                    
                gets $fp line  
                while { ![eof $fp] } {
                    gets $fp line  
                    set line [string trim $line]
                    if { ![string is digit [string index $line 0]] } {
                        break
                    }
                    lassign $line id dx dy dz rx ry rz
                    if { [string is double -strict $dx] } {
                        set Displacements($id) [list $dx $dy $dz]              
                        set Rotations($id) [list $rx $ry $rz]
                    } else {
                        incr non_numeric_values
                    }
                }
                #to set to 0 0 0 for nodes without explicit displacement value
                for {set id 1} {$id<=$num_nodes} {incr id} {
                    if { [info exists Displacements($id)] } {
                        append values(Displacements) "$id $Displacements($id)\n"
                    } else {
                        append values(Displacements) "$id 0 0 0\n"
                    }
                    if { [info exists Rotations($id)] } {
                        append values(Rotations) "$id $Rotations($id)\n"
                    } else {
                        append values(Rotations) "$id 0 0 0\n"
                    }
                }
                unset -nocomplain Displacements
                unset -nocomplain Rotations
               
                #set interesting_results {Displacements Rotations}
                set interesting_results {Displacements} ;#Rotations are not very interesting
                foreach item $interesting_results {
                    if { [info exists values($item)] } {
                        set result "Result $item Static $load_case Vector OnNodes"
                        set results($result) $values($item)
                    }
                }         
                unset -nocomplain values                
            } else {
                break
            }
            
            set item LocalAxes
            #calculate and store GiD local axes of each element
            foreach {element_id element_n0 element_n1 element_material} [GiD_Info mesh Elements linear] {                    
                set xyz0 [lrange [GiD_Mesh get node $element_n0] 1 end]
                set xyz1 [lrange [GiD_Mesh get node $element_n1] 1 end]
                set x_axis [math::linearalgebra::unitLengthVector [math::linearalgebra::sub_vect $xyz1 $xyz0]]
                lassign [MathUtils::CalculateLocalAxisFromXAxis $x_axis] y_axis z_axis
                set local_axis($element_id,x) $x_axis
                set local_axis($element_id,y) $y_axis
                set local_axis($element_id,z) $z_axis
                set euler_angles [MathUtils::CalculateEulerAnglesFromLocalAxis $x_axis $y_axis $z_axis]
                append values($item) "$element_id $euler_angles\n"
            }       
            set result "Result LocalAxes Static 1 $item OnGaussPoints GP_LINE_1"
            set results($result) $values($item)
            unset -nocomplain values 
            
            if { !$read_ifxx_files } {       
                if { [Frame3DD::_FileFind $fp "F R A M E   E L E M E N T   E N D   F O R C E S" $line] } {                                           
                    gets $fp line  
                    while { ![eof $fp] } {
                        gets $fp line  
                        set line [string trim $line]
                        if { ![string is digit [string index $line 0]] } {
                            break
                        }
                        lassign $line element_id node_id Nx Vy Vz Tx My Mz
                        foreach item {Nx Vy Vz Tx My Mz} {
                            set v [set $item]
                            if { [string is double -strict $v] } {                        
                                set v [expr {-1.0*$v}]
                                append values($item) "$element_id $v\n"
                            } else {
                                incr non_numeric_values
                            }
                        }
                        gets $fp line  
                        set line [string trim $line]
                        lassign $line element_id node_id Nx Vy Vz Tx My Mz
                        foreach item {Nx Vy Vz Tx My Mz} {                        
                            set v [set $item]
                            if { [string is double -strict $v] } {
                                append values($item) " $v\n"
                            } else {
                                incr non_numeric_values
                            }
                        }               
                    }                                                  
                    foreach item {Nx Vy Vz Tx My Mz} {
                        if { [info exists values($item)] } {
                            set axis [string index $item end]
                            if { $axis == "x" } {
                                #represent it as scalar result
                                set result "Result ${item}' Static $load_case Scalar OnGaussPoints GP_LINE_2"
                                set results($result) $values($item)     
                            } else {
                                #represent it as vector result in its local axis direction
                                set result "Result ${item}' Static $load_case Vector OnGaussPoints GP_LINE_2"
                                set vector_values ""
                                foreach {element_id e0 e1} $values($item) {
                                    set vector_0 [math::linearalgebra::scale_vect [expr {-1.0*$e0}] $local_axis($element_id,$axis)]
                                    set vector_1 [math::linearalgebra::scale_vect [expr {-1.0*$e1}] $local_axis($element_id,$axis)]
                                    append vector_values "$element_id $vector_0 $e0\n $vector_1 $e1\n"
                                }
                                set results($result) $vector_values    
                            }
                        }    
                    }   
                    unset -nocomplain values                  
                } else {
                    break
                }
            }
            if { [Frame3DD::_FileFind $fp "R E A C T I O N S" $line] } {                                
                gets $fp line  
                while { ![eof $fp] } {
                    gets $fp line  
                    set line [string trim $line]
                    if { ![string is digit [string index $line 0]] } {
                        break
                    }
                    lassign $line id fx fy fz mx my mz
                    if { [string is double -strict $fx] } {
                        append values(Reaction_forces) "$id $fx $fy $fz\n"
                        append values(Reaction_moments) "$id $mx $my $mz\n"
                    } else {
                        incr non_numeric_values
                    }
                }   
                foreach item {Reaction_forces Reaction_moments} {
                    if { [info exists values($item)] } {
                        set result "Result $item Static $load_case Vector OnNodes"
                        set results($result) $values($item) 
                    }
                }                
                unset -nocomplain values
            } else {
                break
            }   
        } else {
            break
        }
    }

    if { [Frame3DD::_FileFind $fp "M A S S   N O R M A L I Z E D   M O D E   S H A P E S" $line] } {
        gets $fp line ;#convergence tolerance
        while { ![eof $fp] } {
            gets $fp line
            if { [string range $line 0 34] == "M A T R I X    I T E R A T I O N S:"} {
                break
            }
            set i_mode [string range [lindex $line 1] 0 end-1]
            set frequency [lindex $line 3]
            set period [lindex $line 6]
            gets $fp line ;#X- modal participation factor
            gets $fp line ;#Y- modal participation factor
            gets $fp line ;#Z- modal participation factor
            gets $fp line ;#Joint   X-dsp       Y-dsp       Z-dsp       X-rot       Y-rot       Z-rot
            for { set i 1 } {$i <= $num_nodes } { incr i } {
                gets $fp line
                lassign $line id dx dy dz rx ry rz
                append values(Displacements) "$id $dx $dy $dz\n"
                append values(Rotations) "$id $rx $ry $rz\n"
            }
            #set interesting_results {Displacements Rotations}
            set interesting_results {Displacements} ;#Rotations are not very interesting
            foreach item $interesting_results {
                if { [info exists values($item)] } {
                    set result "Result Modal_${item}_${frequency}_Hz Dynamic 0 Vector OnNodes"
                    set results($result) $values($item) 
                }
            }
            unset -nocomplain values
        }
    }

    close $fp
    
    if { $read_ifxx_files } {  
        # read the *.ifXX files for internal force results along the elements    
        set interesting_results {Nx Vy Vz Tx My Mz}
        set num_spans 10
        set num_gauss_points [expr {$num_spans+1}]
        for { set load_case 1 } { $load_case <= $num_load_cases } {incr load_case } {
            set filename_ifx [file rootname $filename].if[format %02d $load_case]
            if { [file exists $filename_ifx] } {
                set fp [open $filename_ifx r]
                #jump header
                for {set i 0} {$i<8} {incr i} {
                    gets $fp line 
                }
                for {set i_element 0} {$i_element<$num_elements} {incr i_element} {
                    gets $fp line ;##        Elmnt        N1        N2 ...     
                    gets $fp line           
                    lassign $line dummy dummy element_id        n1        n2 x1 y1 z1 x2 y2 z2 nx
                    set element_length [math::linearalgebra::norm_two [math::linearalgebra::sub_vect [list $x1 $y1 $z1] [list $x2 $y2 $z2]]]
                    gets $fp line
                    gets $fp line ;# MAXIMUM ...
                    gets $fp line ;## MINIMUM ...
                    gets $fp line ;##.x ...
                    set xs [list]
                    foreach item $interesting_results {
                        set ${item}s [list]
                    }
                    for {set ix 0} {$ix<$nx} {incr ix} {
                        gets $fp line
                        lassign $line x Nx Vy Vz Tx My Mz dx dy dz rx
                        set relative_x [expr {double($x)/$element_length}]
                        lappend xs $relative_x
                        foreach item $interesting_results {
                            lappend ${item}s [set $item]
                        }
                    }
		    if { [llength $xs] >= 3 } {
			set cubic_interpolation 1
		    } elseif { [llength $xs] == 2 } {
			#do linear interpolation
			set cubic_interpolation 0
			WarnWinText "frame element internal force data only [llength $xs] values. Used linear interpolation. Check value of length of x-axis increment input value, and mesh units"
		    } else {
			WarnWinText "frame element internal force data only [llength $xs] values. Check value of length of x-axis increment input value, and mesh units"	       
			set cubic_interpolation -1
		    }
                    foreach item $interesting_results {
                        append values($item) "$element_id"
			if { $cubic_interpolation == 1 } {		
			    set coefficients [math::interpolate::prepare-cubic-splines $xs [set ${item}s]]
			} elseif { $cubic_interpolation == 0 } {
                            set xyvalues [list]
                            foreach x $xs y [set ${item}s] {
                                lappend xyvalues $x $y
                            }
                        } else {
			    continue
			}
                        for {set i_pt 0} {$i_pt<=$num_spans} {incr i_pt} {
                            set x [expr {double($i_pt)/$num_spans}]
                            if { $x < [lindex $xs 0] } {
                                set x [lindex $xs 0]
                            } elseif { $x > [lindex $xs end] } {
                                set x [lindex $xs end]
                            }
			    if { $cubic_interpolation == 1 } {
                                set v [math::interpolate::interp-cubic-splines $coefficients $x]
                            } else {
                                set v [::math::interpolate::interp-linear $xyvalues $x]
                            }
                            append values($item) " $v\n"
                        }                    
                    }
                    gets $fp line ;##--- ...
                    gets $fp line
                    gets $fp line
                }
                close $fp
                foreach item $interesting_results {
                    set axis [string index $item end]
                    if { $axis == "x" } {
                        #represent it as scalar result
                        set result "Result ${item}' Static $load_case Scalar OnGaussPoints GP_LINE_$num_gauss_points"
                        set results($result) $values($item)
                    } else {
                        #represent it as vector result in its local axis direction
                        #My Mz : momentum vector represents a rotation in the normal plane
                        if { $item == "My" } {
                            #represent it in the plane x'-z'
                            set axis_draw z
                            set sign_draw -1.0
                        } elseif { $item == "Mz" } {
                            #represent it in the plane x'-y'
                            set axis_draw y
                            set sign_draw -1.0
                        } else {
                            #Nx Vy Vz Tx
                            set axis_draw $axis
                            set sign_draw 1.0
                        }
                        set result "Result ${item}' Static $load_case Vector OnGaussPoints GP_LINE_$num_gauss_points"
                        set vector_values ""
                        set pos 0
                        for {set i_element 0} {$i_element<$num_elements} {incr i_element} {
                            set element_id [lindex $values($item) $pos]
                            append vector_values $element_id
                            incr pos
                            set vs [lrange $values($item) $pos [expr {$pos+$num_gauss_points-1}]]
                            incr pos $num_gauss_points
                            foreach v $vs {
                                set vector [math::linearalgebra::scale_vect [expr {$sign_draw*$v}] $local_axis($element_id,$axis_draw)]
                                append vector_values " $vector $v\n" ;#GiD trick last extra value is modulus but with sign
                            }                        
                        }
                        set results($result) $vector_values    
                    }
                }
                unset -nocomplain values
            }
        }
    }
    ####
    
    if { [array size results] } {
        set filename_post [file rootname $filename].post.res
        set fout [open $filename_post w]
        if { $fout == "" } {       
            return
        }
        set units(Displacements) [GidGetUnitStr length]
        set units(Rotations) [GidGetUnitStr angle]
        set units(Nx') [GidGetUnitStr strength]
        set units(Vy') [GidGetUnitStr strength]
        set units(Vz') [GidGetUnitStr strength]
        set units(Tx') [GidGetUnitStr momentum]
        set units(My') [GidGetUnitStr momentum]
        set units(Mz') [GidGetUnitStr momentum]
        set units(Reaction_forces) [GidGetUnitStr strength]
        set units(Reaction_moments) [GidGetUnitStr momentum]

        puts $fout "GiD Post Results File 1.0"
        puts $fout ""
        foreach num [list 2 $num_gauss_points] {
            puts $fout "GaussPoints GP_LINE_$num ElemType Linear"
            puts $fout "Number Of Gauss Points: $num"
            puts $fout "Nodes included"
            puts $fout "Natural Coordinates: Internal"
            puts $fout "End gausspoints"
        }
        
        foreach result [array names results] {
            puts $fout ""
            puts $fout $result
            set name [lindex $result 1]
            if { [string range $name 0 4] == "Modal" } {
                set name [lindex [split $name _] 1]
            }
            if { [info exists units($name)] } {
                puts $fout "Unit $units($name)" 
            }
            puts $fout Values 
            puts -nonewline $fout $results($result)
            puts $fout "End values"  
        }
        close $fout
        unset -nocomplain results
    }
    
    if { $non_numeric_values } {
        WarnWin [= "Error, there are 'not a number' results"]
    }
    return
}
