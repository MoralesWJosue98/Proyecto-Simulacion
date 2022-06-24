#######################################################################################
#GiD Raised events
#######################################################################################

proc InitGIDProject { dir } {    
    set FEniCS::_dir $dir
    #GiD_DataBehaviour materials Isotropic geomlist {surfaces}     
    FEniCS::Splash
    FEniCS::ChangeMenus
}

proc EndGIDProject {} {
    FEniCS::RestoreMenus
}

proc ChangedLanguage { newlan } {
    FEniCS::ChangeMenus
}

proc LoadGIDProject { filespd } {        
    if { [file join {*}[lrange [file split $filespd] end-1 end]] == "FEniCS.gid/FEniCS.spd" } {
        #loading the problemtype itself, not a model
    } else {
        set pt [GiD_Info project ProblemType]
        if { $pt == "FEniCS" } {
            set filename [file rootname $filespd].xml
            set model_problemtype_version_number [FEniCS::ReadXml $filename]            
            if { $model_problemtype_version_number != -1 && $model_problemtype_version_number < $::FEniCS::VersionNumber } {            
                set must_transform 1
            } else {
                set must_transform 0
            }
            if { $must_transform } {
                after idle [list FEniCS::Transform $model_problemtype_version_number $::FEniCS::VersionNumber]
            }
        }
    }
}

proc SaveGIDProject { filespd } {
    set filename [file rootname $filespd].xml
    FEniCS::SaveXml $filename
}

#to automatically convert results file to .post.res
#proc AfterRunCalculation { basename dir problemtypedir where error errorfilename } {
#    if { $error == 0 } {
#        set filename [file join [lindex $dir 0] $basename].xxx
#        if { [file exists $filename] } {
#            FEniCS::ConvertResultsToGiD $filename
#        }
#    }
#    return 0
#}


#######################################################################################
#FEniCS namespace procedures
#######################################################################################

namespace eval FEniCS {
    variable ProgramName FEniCS
    variable VersionNumber 1.0 ;#interface version
    variable _dir ;#path to the problemtype
}

proc FEniCS::SaveXml { filename } {
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
proc FEniCS::ReadXml { filename } {
    variable ProgramName
    set model_problemtype_version_number -1
    if { [file exists $filename] } {
        set fp [open $filename r]
        if { $fp != "" } {
            set line ""
            gets $fp header
            gets $fp line ;#something like: <FEniCS version='1.0'/>
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

proc FEniCS::Transform { from_version to_version } {    
    variable ProgramName
    GiD_Process escape escape escape escape Data Defaults TransfProblem $ProgramName escape    
}

proc FEniCS::ChangeMenus {} {
    variable ProgramName   
    ::GiDMenu::InsertOption Help [list [concat [= "Help on"] $ProgramName]...] 0 PREPOST {GiDCustomHelp -start "en/FEniCS_toc.html"} "" "" insert =      
    ::GiDMenu::InsertOption Help [list [concat [= "About"] $ProgramName ...]] end PREPOST FEniCS::About "" "" insert =
    ::GiDMenu::UpdateMenus
}

proc FEniCS::RestoreMenus {} {
    variable ProgramName
    ::GiDMenu::RemoveOption Help [list [concat [= "Help on"] $ProgramName]...] PREPOST =
    ::GiDMenu::RemoveOption Help [list [concat [= "About"] $ProgramName ...]] PREPOST =
    ::GiDMenu::UpdateMenus
}

proc FEniCS::Splash { {self_close 1} } {
    variable _dir
    set prev_splash_state [GiD_Set SplashWindow]
    GiD_Set SplashWindow 1 ;#set temporary to 1 to force show splash without take care of the GiD splash preference
    set txt "$FEniCS::ProgramName Version $FEniCS::VersionNumber"   
    ::GidUtils::Splash [file join $FEniCS::_dir images splash.png] .splash $self_close [list $txt 180 280]
    GiD_Set SplashWindow $prev_splash_state
}

proc FEniCS::About { } {
    set self_close 0
    FEniCS::Splash $self_close
}    
