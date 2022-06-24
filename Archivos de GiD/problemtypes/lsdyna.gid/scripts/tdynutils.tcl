#tdynutils.tcl  -*- TCL -*- Created: JGE Feb-2002, Modified: JGE Feb-2002

###################################################
# UTILIDAD PARA CREAR UN INFORME DE LOS RESULTADOS
###################################################

proc UseCreateReportWindow { {w ""} } {
    global ProblemTypePriv

    if { $w == "" } { set w .gid.createreport }

    if { [info procs InitWindow] != "" } {
	InitWindow $w [= {Create report window}] PrePostCreateReportWindowGeom ""
    } else {
	toplevel $w
    }

    ReportPrefs::init $ProblemTypePriv(problemtypedir)
    CreateReportWindow $w

    set b $w.buts 
    frame $b
    button $b.close -text [= {Close}] -width 5 -und 0 -command "destroy $w"
    button $b.help -image [imagefromtdyn questionarrow.gif] -command "PickHelp $b.help" \
	    -highlightthickness 0

    wm protocol $w WM_DELETE_WINDOW "tkButtonInvoke $b.close"
    bind $w <Escape> "tkButtonInvoke $b.close"
    bind $w <Alt-c> "tkButtonInvoke $b.close"
    
    grid $b.close -row 2 -column 1 -sticky e -pady 3 -padx 3
    grid $b.help -row 2 -column 3 -pady 2 -sticky w
    grid $b -padx 3 -pady 3
    grid rowconfigure $w {1 2 3} -weight 1
    grid columnconfigure $w 0 -weight 1 
    wm geometry $w ""
}

proc CreateReportWindow { base } {

    framelabel $base.f1 [= {global report}]

    label $base.f1.l1 -text "[= {Title}]:"
    entry $base.f1.e1 -textvar ReportPrefs::reporttitle

    GidHelp "$base.f1.l1 $base.f1.e1" "[= {This is the title of the report that will be created with button 'Create'}]."

    frame $base.f1.buts0
    button $base.f1.buts0.b1 -text "[= {Description}]." -width 15 -command \
	    "EnterText $base._desc {ReportPrefs::reportdescription} \"[= {Report Description}]\""
    pack $base.f1.buts0.b1 -side left 

    GidHelp "$base.f1.buts0.b1" "[= {Here can be entered the description of the analysis made}].\n[= {It will appear in the report}]"

    frame $base.f1.buts
    button $base.f1.buts.b1 -text [= {Create}] -width 7 -command \
	    "ReportPrefs::CreateReport $base.f1"
    button $base.f1.buts.b2 -text [= {View}] -width 7 -command \
	    "ReportPrefs::ViewReportHtmlFile $base.f1"
    button $base.f1.buts.b3 -text [= {Export}] -width 7 -command \
	    "ReportPrefs::ExportReport $base.f1"

    GidHelp "$base.f1.buts.b1" "[= {This button will create a new report of the analysis.}]\n[= {It can be filled afterwards by using buttons 'Insert'}]."

    GidHelp "$base.f1.buts.b2" "[= {This button launches a viewer that will display the created report}].\n[= {It must be previously created with button 'Create'}]."

    set projectdir [ReportPrefs::GiveProjectDir]
    if { $projectdir == "" } { set projectdir MODEL.gid }
    
    GidHelp "$base.f1.buts.b3" "[= {This button exports the report as an HTML file} $projectdir].\n[= {It is also possible to obtain the HTML file by searching in the model directory: $projectdir} $projectdir]"
    
    proc UpdateViewReportButton { args } {
	foreach w $args {
	    if { [winfo exists $w] } {
		if { $ReportPrefs::reportfilename == "" } {
		    $w conf -state disabled
		} else {
		    $w conf -state normal
		}
	    }
	}
    }
    
    trace var ReportPrefs::reportfilename w "UpdateViewReportButton $base.f1.buts.b2 \
	$base.f1.buts.b3 ;#"
    set ReportPrefs::reportfilename $ReportPrefs::reportfilename
    
    grid $base.f1.buts.b1 -row 1 -column 1 -padx 2 -pady 2
    grid $base.f1.buts.b2 -row 1 -column 2 -padx 2 -pady 2
    grid $base.f1.buts.b3 -row 1 -column 3 -padx 2 -pady 2
    
    grid $base.f1.l1 -row 1 -column 1 -sticky e -pady $ReportPrefs::FramesSeparation
    grid $base.f1.e1 -row 1 -column 2 -sticky ew -padx 2
    grid $base.f1.buts0 -row 2 -column 1 -columnspan 2 -sticky w -padx 2
    grid $base.f1.buts -row 3 -column 1 -columnspan 2 -sticky ew
    grid columnconf $base.f1 2 -weight 1
    
    framelabel $base.f2 [= {insert current view}]
    label $base.f2.l1 -text "[= {Caption}]:"
    entry $base.f2.e1 -textvar ReportPrefs::reportlastimgcaption
    
    frame $base.f2.buts
    button $base.f2.buts.b1 -text [= {Insert}] -width 8 -command \
	"ReportPrefs::AddCurrentViewToReport $base"
    button $base.f2.buts.b2 -text [= {Delete last}] -width 8 -command \
	"ReportPrefs::DeleteLastFromReport $base image"
    
    GidHelp "$base.f2.l1 $base.f2.e1" "[= {When inserting an image in the report with button 'Insert', caption is the text that appears just below the image, describing it}]."
    GidHelp "$base.f2.buts.b1" "[= {This option inserts current view of the model at the end of the report}]."
    GidHelp "$base.f2.buts.b2" "[= {This button deletes from the report the last inserted image}]."
    
    grid $base.f2.buts.b1 -row 1 -column 1 -padx 2 -pady 2
    grid $base.f2.buts.b2 -row 1 -column 2 -padx 2 -pady 2
    
    grid $base.f2.l1 -row 1 -column 1 -sticky e -pady $ReportPrefs::FramesSeparation
    grid $base.f2.e1 -row 1 -column 2 -sticky ew -padx 2
    grid $base.f2.buts -row 3 -column 1 -columnspan 2 -sticky ew
    grid columnconf $base.f2 2 -weight 1
    
    framelabel $base.f3 [= {insert text}]
    button $base.f3.edit -text "[= {Edit text}]..." -width 15 -command \
	"EnterText $base._text {ReportPrefs::reportlasttext} \"[= {Edit text}]\""
    frame $base.f3.buts
    button $base.f3.buts.b1 -text [= {Insert}] -width 8 -command \
	"ReportPrefs::AddCurrentTextToReport $base"
    button $base.f3.buts.b2 -text [= {Delete last}] -width 8 -command \
	"ReportPrefs::DeleteLastFromReport $base text"
    
    GidHelp "$base.f3.edit" "[= {Here can be entered a text to be included in the report}]."
    GidHelp "$base.f3.buts.b1" [= {This option inserts the current text at the end of the report}]
    GidHelp "$base.f3.buts.b2" [= {This button deletes from the report the last inserted text}]

    grid $base.f3.buts.b1 -row 1 -column 1 -padx 2 -pady 2
    grid $base.f3.buts.b2 -row 1 -column 2 -padx 2 -pady 2
    
    grid $base.f3.edit -row 1 -column 1 -sticky e -pady $ReportPrefs::FramesSeparation
    grid $base.f3.buts -row 3 -column 1 -columnspan 2 -sticky ew
    grid columnconf $base.f3 2 -weight 1

#    framelabel $base.f3 "insert current results"

#    frame $base.f3.buts
#    button $base.f3.buts.b1 -text [= {Insert}] -width 8 -command \
#            "ReportPrefs::AddCurrentResultsToReport $base"
#    button $base.f3.buts.b2 -text [= {Delete last}] -width 8 -command \
#            "ReportPrefs::DeleteLastFromReport $base results"

#    GidHelp "$base.f3.buts.b1" "This option inserts last results obtained with buttons"\
#            " 'Dimension' or 'Check' at the end of the report."
#    GidHelp "$base.f3.buts.b2" "This button deletes from the report the last inserted results"


#    grid $base.f3.buts.b1 -row 1 -column 1 -padx 2 -pady 2
#    grid $base.f3.buts.b2 -row 1 -column 2 -padx 2 -pady 2
    
#    grid $base.f3.buts -row 1 -column 1 -columnspan 2 -sticky ew -pady $ReportPrefs::FramesSeparation
#    grid columnconf $base.f3 2 -weight 1

#    framelabel $base.f4 "export dxf"

#    frame $base.f4.buts
#    button $base.f4.buts.b1 -text [= {Export DXF}] -width 12 -command \
#            "ReportPrefs::ExportDXF $base"

#    GidHelp "$base.f4.buts.b1" "This button exports as a DXF file the drawing of the last"\
#            " sections obtained with buttons 'Dimension' or 'Check'"

#    grid $base.f4.buts.b1 -row 1 -column 1 -padx 2 -pady 2
    
#    grid $base.f4.buts -row 1 -column 1 -columnspan 2 -sticky ew -pady $GUIState::FramesSeparation
#    grid columnconf $base.f4 2 -weight 1

    grid $base.f1 -padx 5 -pady $ReportPrefs::FramesSeparation
    grid $base.f2 -padx 5 -pady $ReportPrefs::FramesSeparation
    grid $base.f3 -padx 5 -pady $ReportPrefs::FramesSeparation

#    pack $base.f1 -side top -padx 5 -pady $GUIState::FramesSeparation -expand 0 -fill x
#    pack $base.f2 -side top -padx 5 -pady $GUIState::FramesSeparation -expand 0 -fill x
#    pack $base.f3 -side top -padx 5 -pady $GUIState::FramesSeparation -expand 0 -fill x
#    pack $base.f4 -side top -padx 5 -pady $GUIState::FramesSeparation -expand 0 -fill x
} 

namespace eval ReportPrefs {
    variable ramdir
    variable elem ""
    variable pointelem ""
    variable lasthtmlfile ""
    variable elemuse Automatic
    variable elemname ""
    variable SymbolsAsImages 0
    variable reporttitle ""
    variable reportfilename ""
    variable reportdescription ""
    variable reportlasttext ""
    variable reportlastimgcaption ""
    variable reportexportdir ""
    variable syma 
    variable symb 
    variable symd 
    variable syme 
    variable symg 
    variable symf 
    variable symh 
    variable symmm
    variable sym12 
    variable sym14
    variable sym34 
    variable supF
    variable subF
    variable norF
    variable sqrF
    proc init { dir } {
	variable ramdir
	variable FontHeight
	variable FramesSeparation
	variable syma 
	variable symb 
	variable symd 
	variable syme 
	variable symg 
	variable symf 
	variable symh 
	variable symmm 
	variable sym12 
	variable sym14
	variable sym34 
	variable supF
	variable subF
	variable norF
	variable sqrF
	# inicializaci�n de algunas variables
	set ramdir $dir 
	DefFonts
	set FontHeight [font metric BoldFont -linespace]
	set FramesSeparation [expr $FontHeight/2+1]
	# creaci�n de los s�mbolos
	set syma [image create photo \
		-file [file join $dir images sym-a.gif]]
	set symb [image create photo \
		-file [file join $dir images sym-b.gif]]
	set symd [image create photo \
		-file [file join $dir images sym-d.gif]]
	set syme [image create photo \
		-file [file join $dir images sym-e.gif]]
	set symg [image create photo \
		-file [file join $dir images sym-g.gif]]
	set symf [image create photo \
		-file [file join $dir images sym-f.gif]]
	set symh [image create photo \
		-file [file join $dir images sym-h.gif]]
	set symmm [image create photo \
		-file [file join $dir images sym-mm.gif]]
	set sym12 [image create photo \
		-file [file join $dir images sym-12.gif]]
	set sym14 [image create photo \
		-file [file join $dir images sym-14.gif]]
	set sym34 [image create photo \
		-file [file join $dir images sym-34.gif]]
	set subF [image create photo \
		-file [file join $dir images sym-2d.gif]]
	set supF [image create photo \
		-file [file join $dir images sym-2u.gif]]
	set norF [image create photo \
		-file [file join $dir images sym-2n.gif]]
	set sqrF [image create photo \
		-file [file join $dir images sym-sqr.gif]]
	# Read existing file if found
	Read
    }
    proc DefFonts {} {
	global tcl_platform
	set size 12
	if { [lsearch [font names] NormalFont] != -1 } {
	    set size [font configure NormalFont -size]
	}
	if { [lsearch [font names] BoldFont] == -1 } {
	    if { $tcl_platform(platform) == "windows"} {
		font create BoldFont -family "MS Sans Serif" -size $size
	    } else {
		font create BoldFont -family {new century schoolbook} -size [expr $size+2]
	    }
	    #          option add *font BoldFont
	    option add *Button*BorderWidth 1
	}
	if { [lsearch [font names] SmallFont] == -1 } {
	    if { $tcl_platform(platform) == "windows"} {
		font create SmallFont -family "MS Sans Serif" -size [expr $size-2]
	    } else {
		font create SmallFont -family {new century schoolbook} -size [expr $size-2]
	    }
	} elseif { [font conf SmallFont -size] >= [font conf NormalFont -size]} {
	    set size [font conf NormalFont -size]
	    set family [font conf NormalFont -family]
	    font conf SmallFont -family $family -size [expr $size-2]
	}
	if { [lsearch [font names] SymbolFont] == -1 } {
	    if { $tcl_platform(platform) == "windows"} {
		font create SymbolFont -family Symbol -size $size
	    } else {
		font create SymbolFont -family Symbol -size [expr $size+2]
	    }
	    #          option add *font BoldFont
	    option add *Button*BorderWidth 1
	}
    }
    proc ViewPoint {} {
	variable pointelem
	if { $pointelem == "" } {
	    WarnLine "[= {There is no point to view}]. [= {Select firt one}]"
	    return
	}
	.central.s process escape escape escape escape Utilities SignalEntities \
		Nodes FNoJoin $pointelem

    }
    proc GiveTempDir {} {
	global env

	if { [info exists env(TEMP)] } {
	    return $env(TEMP)
	}
	if { [info exists env(TMP)] } {
	    return $env(TMP)
	}
	if { [info exists env(WINDIR) && [file isdir [file join $env(WINDIR) temp]]] } {
	    return [file join $env(WINDIR) temp]
	}
	if { [file isdir /tmp] } {
	    return /tmp
	}
	return ""
    }
    proc GiveProjectDir {} {
	set aa [.central.s info Project]
	set ProjectName [lindex $aa 1]
	if { [file extension $ProjectName] == ".gid" } {
	    set ProjectName [file root $ProjectName]
	}
	
	if { $ProjectName == "UNNAMED" } {
	    return ""
	}
	
	set directory $ProjectName.gid
	if { [file pathtype $directory] == "relative" } {
	    set directory [file join [pwd] $directory]
	}
	return $directory
    }
    proc ExistsReport { } {

	set aa [.central.s info Project]
	set ProjectName [lindex $aa 1]
	if { [file extension $ProjectName] == ".gid" } {
	    set ProjectName [file root $ProjectName]
	}

	set directory $ProjectName.gid
	if { [file pathtype $directory] == "relative" } {
	    set directory [file join [pwd] $directory]
	}
	set file [file join $directory [file tail $ProjectName].html]
	return [file exists $file]
    }
    proc GiveReportName { {needname "no"} } {

	if { $needname=="yes" } {
	    set info [.central.s info list_entities status]
	    regexp "name:\[ ]*(\[^\n]*)\n" $info {} projectname
	    if { [.central.s info postprocess arewein]=="YES" } {
		if { $projectname=="(null)" } { 
#                    WarnWin "A project title is needed. Save project to get it."
		    return ""
		}
	    } else {
		if { $projectname=="UNNAMED" } { 
#                    WarnWin "A project title is needed. Save project to get it."
		    return ""
		} 
	    }
	}

	set aa [.central.s info Project]
	set ProjectName [lindex $aa 1]
	if { [file extension $ProjectName] == ".gid" } {
	    set ProjectName [file root $ProjectName]
	}
	
	if { $ProjectName == "UNNAMED" } {
	    set dir [GiveTempDir]
	    if { $dir != "" } {
		return [file join $dir tmp_report.html]
	    }
	    return ""
	}

	set directory $ProjectName.gid
	if { [file pathtype $directory] == "relative" } {
	    set directory [file join [pwd] $directory]
	}
	return [file join $directory [file tail $ProjectName].html]
    }
    proc SaveFile { file { isglobal } } {
	variable varstosave
	variable varstosaveglobal

	if { [catch {
	    set fout [open $file w]
	} err] } {
	    WarnWin "[= {It is not possible to save data in file '$file'} $file].\n[= {Check your writing permissions} $file]."
	    return -1
	}

	if { !$isglobal } {
	    set vars $varstosave
	} else {
	    set vars $varstosaveglobal
	}

	foreach i $vars {
	    foreach j [info vars ::ReportPrefs::$i] {
		set var [namespace tail $j]
		variable $var
		if { [array exists $var] } {
		    puts $fout "begin array $var"
		    foreach k [array names $var] {
		        puts $fout "   [list $k [set ${var}($k)]]"
		    }
		    puts $fout "end array"
		} elseif { [info exists $var] } {
		    puts $fout [list $var [set $var]]
		}
	    }
	}
	close $fout
	return 0
    }
    proc SaveLocal {} {
	set dir [GiveProjectDir]
	if { $dir != "" } {
	    set file [file join $dir concrete.prefs]
	    SaveFile $file 0
	}
    }
    proc Save {} {
	variable saveprefsonproblemtype 
	variable ramdir 
	
	set retval -1 ; set retval2 -1;

	if { $saveprefsonproblemtype } {
	    set file [file join $ramdir concrete.prefs]
	    set retval [SaveFile $file 1]
	}
	if { !$saveprefsonproblemtype || $retval } {
	    set dir [GiveProjectDir]
	    if { $dir != "" } {
		set file [file join $dir concrete.prefs]
		set retval2 [SaveFile $file 0]
	    }
	}

	if { $saveprefsonproblemtype && $retval } {
	    if { !$retval2 } {
		WarnWin "[= {It is not possible to save data}].\n[= {Check your writing permissions. Data has been saved locally}]"
	    } else {
		WarnWin "[= {It is not possible to save data}].\n[= {Check your writing permissions. Data has NOT been saved}]"
	    }
	}
	if { !$saveprefsonproblemtype && $retval2 } {
	    WarnWin "[= {It is not possible to save data in local project}].\n[= {Check your writing permissions and disk space. Data has NOT been saved}]"
	}
    }
    proc ReadFile { file } {
	if { [catch {
	    set fin [open $file r]
	} ] } { return }
	set array ""
	while { ![eof $fin] } {
	    gets $fin aa
	    set name [lindex $aa 0]
	    set value [lindex $aa 1]
	    if { $name == "begin" && $value == "array" } {
		set array [lindex $aa 2]
		variable $array
		catch { unset $array }
	    } elseif { $name == "end" && $value == "array" } {
		set array ""
	    } elseif { $array != "" } {
		set [set array]($name) $value
	    } else {
		variable $name
		set $name $value
	    }
	}
	close $fin
    }
    proc ReadHtmlFile { file } {
	variable reporttitle
	variable reportdescription
	variable reportlasttext
	variable reportlastimgcaption
	if { [catch {
	    set fin [open $file r]
	} ] } { return }
	
	set initialtext ""
	set imagetext ""
	set lasttext ""
	set ONinitialtext 1
	set ONimagetext 0
	set ONlasttext 0
	while { ![eof $fin] } {
	    gets $fin aa
	    if { [regexp "<a\[ ]+name=\"image\"" $aa] } { 
		set ONimagetext 1 
		set imagetext ""
	    }
#            if { [regexp "<a\[ ]+name=\"tdyntext\"" $aa] }
	    if { [regexp "<br clear=left>" $aa] } {
		set ONlasttext 1
		set lasttext ""
	    }
	    if { $ONinitialtext } { append initialtext $aa }
	    if { $ONimagetext   } { append imagetext $aa }
	    if { $ONlasttext    } { append lasttext  $aa }
#            if { [regexp "<\a>" $aa] && $ONlasttext } { set ONlasttext 0 }         
	    if { [regexp "<\br>" $aa] && $ONlasttext } { set ONlasttext 0 } 
	    if { [regexp "</table>" $aa] && $ONimagetext } { set ONimagetext 0 }
	    if { [regexp "</p></p>" $aa] } { set ONinitialtext 0 }
	}
	close $fin
	
	set reporttitle ""
	regexp "<title>(.*)</title>" $initialtext {} reporttitle
	set reportdescription ""
	regexp "<p><p>(.*)</p></p>" $initialtext {} reportdescription
	set reportlastimgcaption ""
	regexp -all "<a\[ ]+name=\"image\".*<center>(.*)</center>" $imagetext {} reportlastimgcaption
	set reportlasttext ""
#        regexp -all "<a\[ ]+name=\"tdyntext\"><p><p>(.*)</p></p></a>" $lasttext {} reportlasttext
	regexp -all "<br clear=left><p><p>(.*)</p></p></br>" $lasttext {} reportlasttext
	set reporttitle [getshtml $reporttitle]
	set reportdescription [getshtml $reportdescription]
	set reportlastimgcaption [getshtml $reportlastimgcaption]
	set reportlasttext [getshtml $reportlasttext]
    }
    proc Read {} {
	variable ramdir
	variable reportfilename
	if { [ExistsReport] } {
	    set reportfilename [GiveReportName]
	    ReadHtmlFile $reportfilename
	}
    }
    proc ViewLastHtmlFile { base } {
	variable lasthtmlfile
	variable ramdir

	if { $lasthtmlfile == "" } {
	    WarnWin [_ {There are no results to view}]
	    return
	}
	if { ![file readable $lasthtmlfile] } {
	    WarnWin [_ {Results cannot be viewed}]
	    return
	}
	set top [winfo toplevel $base]
	set x [expr [winfo x $top]+[winfo width $top]/2-350]
	set y [expr [winfo y $top]+[winfo height $top]/2-300]
	set geom 650x600+${x}+$y

	HelpWindowRam -geomhelp $geom -tt -title Results -win .gid.results $lasthtmlfile

#          set exec [file join $ramdir HelpViewer]
#          exec $exec -geomhelp $geom -tt -title Results $lasthtmlfile &
    }
    proc ViewReportHtmlFile { base } {
	variable reportfilename
	variable ramdir

	if { $reportfilename == "" } {
	    WarnWin "[= {There is no report to view}].\n[= {Create it first with button 'Create'}]."
	    return
	}

	set reportfilename [GiveReportName]

	if { ![file readable $reportfilename] } {
	    WarnWin "[= {Report cannot be viewed (check problems in file}]: '$reportfilename')"
	    return
	}
	set top [winfo toplevel $base]
	set x [expr [winfo x $top]+[winfo width $top]/2-350]
	set y [expr [winfo y $top]+[winfo height $top]/2-300]
	set geom 650x600+${x}+$y
	HelpWindowRam -geomhelp $geom -tt -title Report -win .gid.report $reportfilename
#          set exec [file join $ramdir HelpViewer]
#          exec $exec -geomhelp $geom -tt -title Report $reportfilename &
    }
    proc ViewHelpFor { base file } {
	variable ramdir

#          set top [winfo toplevel $base]
#          set x [expr [winfo x $top]+[winfo width $top]/2-350]
#          set y [expr [winfo y $top]+[winfo height $top]/2-300]
#          set geom 650x600+${x}+$y
#          set exec [file join $ramdir HelpViewer]
#          exec $exec -geomhelp $geom -tt [file join $ramdir $file] &
	HelpWindow CUSTOM_HELP_FILE [file join $ramdir $file]
    }
    proc AddCurrentViewToReport { base } {
	variable reportfilename
	variable reportlastimgcaption

	if { $reportfilename == "" } {
	    WarnWin "[= {There is no report where to add current view}].\n[= {Create it first with button 'Create'}]."
	    return
	}
	
	set reportfilename [GiveReportName]

	if { ![file writable $reportfilename] } {
	    WarnWin "[= {Report cannot be modified (check problems in file}]: '$reportfilename')"
	    return
	}
	set dir [file join [file dirname $reportfilename] images]
	set i 1
	if { ![file exists $dir] } {
	    file mkdir $dir
	}
	while { [file exists [file join $dir view$i.gif]] } { incr i }
	set img [file join $dir view$i.gif]
	set shortimg [file join images view$i.gif]
	.central.s process Hardcopy GIF \"$img\" escape
	file rename $reportfilename $reportfilename.tmp
	set fin [open $reportfilename.tmp r]
	set fout [open $reportfilename w]
	while { ![eof $fin] } {
	    gets $fin aa
	    if { [regexp {</body>} $aa] } {
		puts $fout "<a name=\"image\"></a>"
		puts $fout "<br clear=all>"
		puts $fout "<table>\n<tr><td>"
		puts $fout "<img src=\"$shortimg\" align=\"center\">"
		puts $fout "</tr>\n<tr><td><center>$reportlastimgcaption</center></tr></table>"
	    } 
	    puts $fout $aa
	}
	close $fin
	close $fout
	file delete $reportfilename.tmp
	WarnWinReport [= {Image inserted OK}] $base
    }
    proc AddCurrentTextToReport { base } {
	variable reportfilename
	variable reportlasttext

	if { $reportfilename == "" } {
	    WarnWin "[= {There is no report where to add current view}].\n[= {Create it first with button 'Create'}]"
	    return
	}
	
	set reportfilename [GiveReportName]

	if { ![file writable $reportfilename] } {
	    WarnWin "[= {Report cannot be modified (check problems in file}]: '$reportfilename')"
	    return
	}
	
	file rename $reportfilename $reportfilename.tmp
	set fin [open $reportfilename.tmp r]
	set fout [open $reportfilename w]
	while { ![eof $fin] } {
	    gets $fin aa
	    if { [regexp {</body>} $aa] } {
#                putshtml $fout "<a name=\"tdyntext\"><p>$reportlasttext</p></a>"
		putshtml $fout "<br clear=left><p>$reportlasttext</p></br>"
	    }
	    puts $fout $aa
	}
	close $fin
	close $fout
	file delete $reportfilename.tmp
	WarnWinReport [= {Text inserted OK}] $base
    }
    proc AddCurrentResultsToReport { base } {
	variable reportfilename
	variable lasthtmlfile

	if { $reportfilename == "" } {
	    WarnWin "[= {There is no report where to add current results}].\n\
		[= {Create it first with button 'Create'}]."
	    return
	}

	set reportfilename [GiveReportName]

	if { ![file writable $reportfilename] } {
	    WarnWin "[= {Report cannot be modified (check problems in file}]: '$reportfilename')"
	    return
	}
	if { ![file readable $lasthtmlfile] } {
	    WarnWin "[= {There are no results to add}].\n[= {Create them with 'Dimension' or 'Check'}]"
	    return
	}
	set imgtodir [file join [file dirname $reportfilename] images]
	set fromdir [file dirname $lasthtmlfile]
	set i 1
	if { ![file exists $imgtodir] } {
	    file mkdir $imgtodir
	}
	file rename $reportfilename $reportfilename.tmp
	set fin [open $reportfilename.tmp r]
	set finres [open $lasthtmlfile r]
	set fout [open $reportfilename w]
	while { ![eof $fin] } {
	    gets $fin aa
	    if { [regexp {</body>} $aa] } {
		puts $fout "<a name=\"results\"></a>"
		puts $fout "<br clear=all><hr width=90% align=center>"
		set isinit 0
		while { ![eof $finres] } {
		    gets $finres bb
		    if { [regexp {<body} $bb] } {
		        set isinit 1
		    } elseif { !$isinit } { continue }
		    if { [regexp {</body} $bb] } { break }
		    set ini 0
		    while { [regexp -indices "<img\[ ]+src=\"(\[^\"]+)\"" [string range $bb $ini end] \
		            {} imgidx] } {
		        set idx1 [expr $ini+[lindex $imgidx 0]]
		        set idx2 [expr $ini+[lindex $imgidx 1]]
		        set imgname [string range $bb $idx1 $idx2]
		        if { [regexp {^sym-} [file tail $imgname]] } {
		            if { ![file exists  [file join $imgtodir [file tail $imgname]]] } {
		                file copy [file join $fromdir $imgname] $imgtodir
		            }
		            set newname [file tail $imgname]
		        } else {
		            regexp {^[^0-9.]+} [file tail $imgname] shortname
		            set i 1
		            while { [file exists [file join $imgtodir $shortname$i.gif]] } { incr i }
		            set newname $shortname$i.gif
		            set imgtoname [file join $imgtodir $newname]
		            file copy [file join $fromdir $imgname] $imgtoname
		        }
		        set bb [join [list [string range $bb 0 [expr $idx1-1]] \
		                [file join images $newname] [string range $bb \
		                [expr $idx2+1] end]] ""]
		        set ini $idx2
		    }
		    puts $fout $bb
		}
	    } 
	    puts $fout $aa
	}
	close $fin
	close $fout
	close $finres
	file delete $reportfilename.tmp
	WarnWinReport [= {Results inserted OK}] $base
    }
    proc DeleteLastFromReport { base what } {
	variable reportfilename
	variable lasthtmlfile

	if { $reportfilename == "" } {
	    WarnWin "[= {There is no report where to delete last}] $what.\n[= {Create it first with button 'Create'}]."
	    return
	}

	set reportfilename [GiveReportName]

	if { ![file writable $reportfilename] } {
	    WarnWin "[= {Report cannot be modified (check problems in file}]:'$reportfilename')"
	    return
	}

	set fin [open $reportfilename r]
	set nline 1
	set linebegin ""
	set lineend ""
	while { ![eof $fin] } {
	    gets $fin aa
	    if { $what == "results" } {
		if { [regexp "<a\[ ]+name=\"results\"" $aa] } {
		    set linebegin $nline
		    set lineend ""
		} elseif { [regexp "<a\[ ]+name=\"image\"" $aa] } {
		    if { $linebegin != "" && $lineend == "" } {
		        set lineend [expr $nline -1]
		    }
		}
	    } elseif { $what == "image" } {
		if { [regexp "<a\[ ]+name=\"image\"" $aa] } {
		    set linebegin $nline
		    set lineend ""
		} elseif { [regexp "<a\[ ]+name=\"results\"" $aa] } {
		    if { $linebegin != "" && $lineend == "" } {
		        set lineend [expr $nline -1]
		    }
		}
	    } elseif { $what == "text" } {
#                 if { [regexp "<a\[ ]+name=\"tdyntext\"" $aa] }
		if { [regexp "<br clear=left" $aa] } {
		    set linebegin $nline
		    set lineend ""
		} elseif { [regexp "</br>" $aa] } {        
#                } elseif { [regexp "</a>" $aa] } {
		    if { $linebegin != "" && $lineend == "" } {
		        set lineend [expr $nline -1]
		    }
		}
	    }
	    if { [regexp {</body>} $aa] } {
		if { $linebegin != "" && $lineend == "" } {
		    set lineend [expr $nline -1]
		}
		break
	    }
	    incr nline
	}
	close $fin

	if { $linebegin == "" } {
	    WarnWin [= {error: There is no %s to delete in the report} $what]
	    return
	}
	set retval [tk_dialogRAM  $base._tmp Warning [= {Are you sure to delete last %s from report?} $what] \
		warning 0 OK Cancel]
	if { $retval == 1 } { return }

	file rename $reportfilename $reportfilename.tmp
	
	set fin [open $reportfilename.tmp r]
	set fout [open $reportfilename w]

	set dir [file dirname $reportfilename]
	set nline 1
	while { ![eof $fin] } {
	    gets $fin aa
	    if { $nline < $linebegin || $nline > $lineend } {
		puts $fout $aa
	    } else {
		set ini 0
		while { [regexp -indices "<img\[ ]+src=\"(\[^\"]+)\"" [string range $aa $ini end] \
		        {} imgidx] } {
		    set idx1 [expr $ini+[lindex $imgidx 0]]
		    set idx2 [expr $ini+[lindex $imgidx 1]]
		    set imgname [file join $dir [string range $aa $idx1 $idx2]]
		    if { [regexp {^sym-} [file tail $imgname]] } {
		        # nothing
		    } elseif { [file exists $imgname] } {
		        file delete $imgname
		    }
		    set ini $idx2
		}
	    }
	    incr nline
	}
	close $fin
	close $fout
	file delete $reportfilename.tmp
	WarnWinReport [= {Last %s deleted OK from report} $what] $base
    }
    proc ExportReport { base } {
	variable reportfilename
	variable reportexportdir

	if { $reportfilename == "" } {
	    WarnWin "[= {There is no report to export}]. [= {Create it first with button 'Create'}]"
	    return
	}

	set reportfilename [GiveReportName]

	if { ![file readable $reportfilename] } {
	    WarnWin [= {Report cannot be read (check problems in file: '%s')} $reportfilename]
	    return
	}
	if { ![file isdir $reportexportdir] } {
	    set reportexportdir [pwd]
	}
	
	global tk_strictMotif
	set tk_strictMotif_save $tk_strictMotif
	set tk_strictMotif 0
	set filename [tk_getSaveFile -defaultextension .html -filetypes [= "{{Html Files} {.html .htm}}"] \
		-initialdir $reportexportdir -initialfile [file tail $reportfilename] -parent $base \
		-title [= {Export report}]]
	set tk_strictMotif $tk_strictMotif_save
	if { $filename == "" } { return }
	set reportexportdir [file dirname $filename]
	if { [string compare -nocase $reportexportdir [file dirname $reportfilename]]==0 } {
	    WarnWin [= {Cannot export to the model directory}]
	    return
	}
	set imgdir [file join $reportexportdir images]
	if { [file exists $imgdir] } {
	    set retval [tk_dialogRAM  $base._tmp Warning \
		    [= {Are you sure to delete directory '%s' and all its contents?} $imgdir]\
		    warning 0 OK Cancel]
	    if { $retval == 1 } { return }
	    if { [catch {
		file delete -force $imgdir
	    } err] } {
		WarnWin [= {error: Could not delete directory '%s' (%s)} $imgdir $err]
		return
	    }
	}

	if { [catch {
	    file copy -force [file join [file dirname $reportfilename] images] \
		    $imgdir
	    file copy -force $reportfilename $filename
	} err] } {
	    WarnWin "[= {Problems exporting report to '$filename' ($err)} $filename $err].\n[= {Check write permissions and disk space} $filename $err]"
	    return
	}
	WarnWin [= {Report exported OK to file '%s'} $filename]
    }
    proc ExportDXF { base } {
	variable reportexportdir
	variable reportfilename

	set dir [GiveProjectDir]
	set dxffile [file join $dir tmp_concrete.dxf]
	if { ![file readable $dxffile] } {
	    WarnWin "[= {There is no DXF file to export}].\n[= {Use buttons 'Dimension' or 'Check' to create}]."
	    return
	}

	if { ![file isdir $reportexportdir] } {
	    set reportexportdir [pwd]
	}
	global tk_strictMotif
	set tk_strictMotif_save $tk_strictMotif
	set tk_strictMotif 0
	set initialfile ""
	if { $reportfilename != "" } {
	    set initialfile [file join [file root [file tail $reportfilename]].dxf]
	}
	set filename [tk_getSaveFile -defaultextension .dxf -filetypes {{[= {DXF files}] ".dxf .DXF"}} \
		-initialdir $reportexportdir -initialfile $initialfile -parent $base \
		-title [= {Export DXF}]]
	set tk_strictMotif $tk_strictMotif_save
	if { $filename == "" } { return }
	set reportexportdir [file dirname $filename]

	if { [catch {
	    file copy -force $dxffile $filename
	} err] } {
	    WarnWin "[= {Problems exporting DXF file to '$filename' ($err)} $filename $err].\n[= {Check write permissions and disk space} $filename $err]"
	    return
	}
	WarnWin [= {DXF exported OK to file '%s'} $filename]
    }
    # Convierte el pseudo-html interno en verdadero html
    proc putshtml { fout text } {
	variable SymbolsAsImages

	if { $SymbolsAsImages } {
	    # translation of symbols
	    regsub -all {<sym>a</sym>} $text {<img src="images/sym-a.gif">} text
	    regsub -all {<sym>b</sym>} $text {<img src="images/sym-b.gif">} text
	    regsub -all {<sym>g</sym>} $text {<img src="images/sym-g.gif">} text
	    regsub -all {<sym>d</sym>} $text {<img src="images/sym-d.gif">} text
	    regsub -all {<sym>e</sym>} $text {<img src="images/sym-e.gif">} text
	    regsub -all {<sym>f</sym>} $text {<img src="images/sym-f.gif">} text
	    regsub -all {<sym>h</sym>} $text {<img src="images/sym-h.gif">} text
	}
	regsub -all {<nor>} $text {} text
	regsub -all {</nor>} $text {} text
	regsub -all {<sym>} $text "<tt><font face=\"Symbol\">" text
	regsub -all {</sym>} $text {</font></tt>} text
	regsub -all {</sel>} $text {} text
	regsub -all {<sel>} $text {} text

	set len [string length $text]
	for { set i 0 } { $i < $len } { incr i } {
	    set char [string index $text $i]
	    switch -- $char {
		\u00e1 { puts -nonewline $fout "&aacute;" }
		\u00e8 { puts -nonewline $fout "&eacute;" }
		\u00ec { puts -nonewline $fout "&iacute;" }
		\u00f2 { puts -nonewline $fout "&oacute;" }
		\u00f9 { puts -nonewline $fout "&uacute;" }
		\u00f1 { puts -nonewline $fout "&ntilde;" }
		\u00b7 { puts -nonewline $fout "&middot;" }
		default {  puts -nonewline $fout $char }
	    }
	}
	puts $fout ""
    }   
    proc getshtml { text } {
	variable SymbolsAsImages

	if { $SymbolsAsImages } {
	    # translation of symbols
	    regsub -all {<img src="images/sym-a.gif">} $text {<sym>a</sym>} text
	    regsub -all {<img src="images/sym-b.gif">} $text {<sym>b</sym>} text
	    regsub -all {<img src="images/sym-g.gif">} $text {<sym>g</sym>} text
	    regsub -all {<img src="images/sym-d.gif">} $text {<sym>d</sym>} text
	    regsub -all {<img src="images/sym-e.gif">} $text {<sym>e</sym>} text
	    regsub -all {<img src="images/sym-f.gif">} $text {<sym>f</sym>} text
	    regsub -all {<img src="images/sym-h.gif">} $text {<sym>h</sym>} text
	}        
#        regsub -all </p><p> $text \n text
#        regsub -all <p> $text {} text
#        regsub -all </p> $text {} text
	regsub -all "<tt><font face=\"Symbol\">" $text {<sym>} text
	regsub -all {</font></tt>} $text {</sym>} text

	regsub -all "&aacute;" $text {\u00e1} text
	regsub -all "&eacute;" $text {\u00e8} text
	regsub -all "&iacute;" $text {\u00ec} text
	regsub -all "&oacute;" $text {\u00f2} text
	regsub -all "&uacute;" $text {\u00f9} text
	regsub -all "ntilde;"  $text {\u00f1} text
	regsub -all "&middot;" $text {\u00b7} text

	return $text
    }
    proc CreateReport { base } {
	variable ramdir
	variable reporttitle
	variable reportfilename
	variable reportdescription

	set name [GiveReportName "yes"]

	if { $name == "" } {
	    WarnWin "[= {A project title is needed}]. [= {Save project to get it}]."
	    return
	}
	
	if { [file exists $name] } {
	    set retval [tk_dialogRAM  $base._temp Warning [= {File '%s' exists, overwrite?} $name] \
		    warning 0 OK Cancel]
	    if { $retval == 1 } { return }
	}
	if { [catch {
	    set fout [open $name w]
	} err] } {
	    WarnWin [= {error: could not write file '%s' (%s)} $name $err]
	    return
	}
	#WARNING
	fconfigure $fout -encoding binary
	set reportfilename $name
	

	set title [string trim $reporttitle]
	if { $title == "" } {
	    set title "--[= {untitled}]--"
	}
	putshtml $fout "<html>\n<head>\n<title>$title</title>\n</head>\n<body bgcolor=\"#FFFFFF\">"
	putshtml $fout "<h1>$title</h1>"

	putshtml $fout "<p><p>$reportdescription</p></p>"

	set info [.central.s info list_entities status]
	regexp "name:\[ ]*(\[^\n]*)\n" $info {} projectname
	set nnodes 0
	set lines 0
	set triangles 0
	set quadrilats 0
	set tetrahedras 0
	set hexahedras 0
	if { [.central.s info postprocess arewein]=="YES" } {
	    if { $projectname=="(null)" } { 
		WarnWin "[= {A project title is needed}]. [= {Save the project to get it}]."
		return
	    }
	    regexp "nodes:\[ ]*(\[^\n]*)\n" $info {} nnodes
	    regexp -line "� lines: (.*)" $info {} lines
	    regexp "triangles:\[ ]*(\[^\n]*)\n" $info {} triangles
	    regexp "quadrilaterals:\[ ]*(\[^\n]*)\n" $info {} quadrilats
	    regexp "tetrahedras:\[ ]*(\[^\n]*)\n" $info {} tetrahedras
	    regexp "hexahedras:\[ ]*(\[^\n]*)\n" $info {} hexahedras
	} else {
	    if { $projectname=="UNNAMED" } { 
		WarnWin "[= {A project title is needed}]. [= {Save the project to get it}]."
		return 
	    } 
	    regexp -line "nodes:(.*)" $info {} nnodes
	    regexp -line "Linear elements:(.*)" $info {} lines
	    regexp -line "Triangle elements:(.*)" $info {} triangles
	    regexp -line "Quadrilateral elements:(.*)" $info {} quadrilats
	    regexp -line "Tetrahedra elements:(.*)" $info {} tetrahedras
	    regexp -line "Hexahedra elements:(.*)" $info {} hexahedras
	}

	if { $tetrahedras>0 || $hexahedras>0 } { set lines 0 }

	putshtml $fout "<table border=1 align=left>"
	putshtml $fout "<tr><td>Project<td>$projectname</tr>"
	putshtml $fout "<tr><td>Num. nodes<td>$nnodes</tr>"
	if { $lines > 0 } {
	    putshtml $fout "<tr><td>Num. elm. linear<td>$lines</tr>"
	}
	if { $triangles > 0 } {
	    putshtml $fout "<tr><td>Num. elm. triang.<td>$triangles</tr>"
	}
	if { $quadrilats > 0 } {
	    putshtml $fout "<tr><td>Num. elm. quadril.<td>$quadrilats</tr>"
	}
	if { $tetrahedras > 0 } {
	    putshtml $fout "<tr><td>Num. elm. tetrahed.<td>$tetrahedras</tr>"
	}
	if { $hexahedras > 0 } {
	    putshtml $fout "<tr><td>Num. elm. hexahed.<td>$hexahedras</tr>"
	}
	putshtml $fout "</table>"

#        set val [lsearch [.central.s info gendata] Activate_Load_Cases*]
#        incr val
#        set justone 0
#        if { [lindex [.central.s info gendata] $val] == "none" } {
#            set justone 1
#        }
#        if { $justone } {
#            putshtml $fout "<h2>Hay una �nica hip�tesis de carga</h2>"
#        } else {
#            set val [lsearch [.central.s info gendata] Combined_load_cases*]
#            incr val
#            set lcases [lrange [lindex [.central.s info gendata] $val] 2 end]
#            set lsimple ""
#            foreach "LC isstrengths combs" $lcases {
#                foreach "fac namel" [split $combs ,] {
#                    if { [lsearch $lsimple $namel] == -1 } {
#                        lappend lsimple $namel
#                    }
#                }
#            }
#            putshtml $fout "<br clear=all>"
#            putshtml $fout "<h2>Hip�tesis de carga</h2>"
#            putshtml $fout "<table border=1 align=left>"
#            putshtml $fout "<tr><td><b>hip. combinada</b><td><b>est. lim. �lt.</b>"
#            foreach i $lsimple {
#                putshtml $fout "<td><b>$i</b>"
#            }
#            putshtml $fout "</tr>"

#            foreach "lc isstrengths combs" $lcases {
#                putshtml $fout "<tr><td>$lc"
#                if { $isstrengths } {
#                    putshtml $fout "<td>s�"
#                } else { putshtml $fout "<td>no" }
#                set facs ""
#                foreach i $lsimple { lappend facs 0.0 }
#                foreach "fac namel" [split $combs ,] {
#                    set idx [lsearch $lsimple $namel]
#                    if { $idx != -1 } {
#                        set facs [lreplace $facs $idx $idx $fac]
#                    }
#                }
#                foreach i $facs { putshtml $fout "<td>[format %g $i]" }
#            }
#            putshtml $fout "</tr>"
#            putshtml $fout "</table>"
#        }

	putshtml $fout "</body>\n</html>"
	close $fout
	set dir [file join [GiveProjectDir] images]
	if { [file isdir $dir] } {
	    file delete -force $dir
	}
	file mkdir $dir
	file copy [file join $ramdir images sym-a.gif] $dir
	file copy [file join $ramdir images sym-b.gif] $dir
	file copy [file join $ramdir images sym-d.gif] $dir
	file copy [file join $ramdir images sym-e.gif] $dir
	file copy [file join $ramdir images sym-f.gif] $dir
	file copy [file join $ramdir images sym-g.gif] $dir
	file copy [file join $ramdir images sym-h.gif] $dir

	WarnWinReport [= {Created report '%s'} $name] $base
    }
}

proc WarnWinReport { text w } {

    set ww $w.__WarnWin
    set retval [tk_dialogRAM  $ww Warning $text warning 0 OK [= {View report}]]
    if { $retval == 1 } {
	ReportPrefs::ViewReportHtmlFile $w
    }
}

# Convierte el c�digo pseudo-html que devuelve ReturnHtmlFromText en texto
# para el editor.
proc PutHtmlInText { w text { clear yes } } {

    set state [$w cget -state]
    $w conf -state normal
    if { $clear == "yes" } {
	$w del 1.0 end
    }
    # Eliminamos/Sustitu�mos las etiquetas elementales de texto
    regsub -all </p><p> $text \n text
    regsub -all <p> $text {} text
    regsub -all </p> $text {} text
    # Comprobamos si hay alguna tag
    if { ![regexp -indices {<([^>]*)>} $text tag tagname] } {
	$w ins end $text 
	$w conf -state $state
	return
    }
    set taglevel 0 
    while { $text!="" } {
	# Se define el bloque actual sobre el que se aplicar�n las tags
	if { ![regexp -indices {<([^>]*)>} $text tag] } {
	    set ind [string length $text]
	} else { 
	    set ind [expr [lindex $tag 0]-1]
	}
	# Se inserta el bloque y se asignan las tags activas
	set ini [$w index insert]
	$w ins end [string range $text 0 $ind]
	for { set i 1 } { $i <= $taglevel } { incr i } {
	    $w tag add $tagarray($i) $ini "end - 1 chars"
	}
	# Se define el nuevo tag
	set tagname [string range $text [expr [lindex $tag 0]+1] \
		[expr [lindex $tag 1]-1]]
	if { ![regexp {/} $tagname] } {
	    incr taglevel
	    set tagarray($taglevel) $tagname
	} else {
	    set tagname [string range $tagname 1 end]
	    if { $tagname==$tagarray($taglevel) } {
		incr taglevel -1 
	    } else { 
		for { set i 1 } { $i < $taglevel } { incr i } {
		    if { $tagname==$tagarray($i) } {
		        set tagarray($i) $tagarray($taglevel)
		        incr taglevel -1 
		        break 
		    }
		}
	    }
	}
	set text [string range $text [expr [lindex $tag 1]+1] end]
    }
    $w conf -state $state
}

# Convierte el texto del editor en un c�digo pseudo-html que se guarda en
# una variable para uso interno
proc ReturnHtmlFromText { w } {

    set text ""
    foreach "key val idx" [$w dump -tag -text 1.0 end] {
	switch $key {
	    text { 
		if { $val != "\n" } {
		    append text $val 
		}
	    }
	    tagon { if { $val!="sel" } { append text <$val> } }
	    tagoff { if { $val!="sel" } { append text </$val> } }
	}
    }
#    set text "<p>$text</p>"
    regsub -all \n $text </p><p> text
    return $text
}

# Convierte el texto del editor en un c�digo pseudo-html que se guarda en
# una variable para uso interno. Por otra parte, el visor interno de html 
# est� bastante limitado y se han incluido varios controles para que todo funcione
proc ReturnBestHtmlFromText { w } {

    set text ""
    set taglevel 0
    foreach "key val idx" [$w dump -tag -text 1.0 end] {
	switch $key {
	    text { 
		if { [regexp {\n} $val] } {
		    set taglist "" 
		    for { set i 1 } { $i <= $taglevel } { incr i } {
		        append taglist </$tagarray($i)>
		    }
		    append taglist "</p><p>"
		    for { set i 1 } { $i <= $taglevel } { incr i } {
		        append taglist <$tagarray($i)>
		    }
		    regsub -all {\n} $val $taglist val
		}
		append text $val 
	    }
	    tagon { 
		if { $val!="sel" } { 
		    for { set i 1 } { $i <= $taglevel } { incr i } {
		        append text </$tagarray($i)>
		    }
		    incr taglevel
		    set tagarray($taglevel) $val
		    for { set i 1 } { $i <= $taglevel } { incr i } {
		        append text <$tagarray($i)>
		    }
		} 
	    }
	    tagoff { 
		if { $val!="sel" } {
		    for { set i $taglevel } { $i >= 1 } { incr i -1 } {
		        if { $val==$tagarray($i) } {
		            break 
		        }
		    }
		    for { set j $taglevel } { $j >= $i } { incr j -1 } {
		        append text </$tagarray($j)>
		    }
		    for { set j $i } { $j < $taglevel } { incr j } {
		        set tagarray($j) $tagarray([expr $j+1])
		        append text <$tagarray($j)>
		    }
		    incr taglevel -1 
		}
	    }
	}
    }
#    set text "<p>$text</p>"
    # Se eliminan los �ltimos saltos de l�nea
    while { [string compare [string range $text end-6 end] "</p><p>"]==0 } {
	set text [string range $text 0 end-7]
    }
    return $text
}

# Editor de texto b�sico con algunos s�mbolos
proc EnterText { w tvar { title "[= {Text editor}]"} } {
    global tkPriv tcl_platform ProblemTypePriv

    toplevel $w
    wm title $w $title

    if { $tcl_platform(platform) == "windows" } {
	wm transient $w [winfo toplevel [winfo parent $w]]
    }

    frame $w.f -bd 2 -relief groove

    frame $w.f.buts 

    button $w.f.buts.a -height 20 -width 18 -image $ReportPrefs::syma -command "\
	    $w.f.t insert insert a sym"
    button $w.f.buts.b -height 20 -width 18 -image $ReportPrefs::symb -command "\
	    $w.f.t insert insert b sym" 
    button $w.f.buts.d -height 20 -width 18 -image $ReportPrefs::symd -command "\
	    $w.f.t insert insert d sym"
    button $w.f.buts.e -height 20 -width 18 -image $ReportPrefs::syme -command "\
	    $w.f.t insert insert e sym"
    button $w.f.buts.g -height 20 -width 18 -image $ReportPrefs::symg -command "\
	    $w.f.t insert insert g sym"
    button $w.f.buts.f -height 20 -width 18 -image $ReportPrefs::symf -command "\
	    $w.f.t insert insert f sym" 
    button $w.f.buts.h -height 20 -width 18 -image $ReportPrefs::symh -command "\
	    $w.f.t insert insert h sym"  
    button $w.f.buts.i -height 20 -width 18 -image $ReportPrefs::symmm -command "\
	    $w.f.t insert insert � nor"  
    button $w.f.buts.j -height 20 -width 18 -image $ReportPrefs::sym12 -command "\
	    $w.f.t insert insert � nor"   
    button $w.f.buts.k -height 20 -width 18 -image $ReportPrefs::sym14 -command "\
	    $w.f.t insert insert � nor"
    button $w.f.buts.l -height 20 -width 18 -image $ReportPrefs::sym34 -command "\
	    $w.f.t insert insert � nor"
    button $w.f.buts.sup -height 20 -width 18 -image $ReportPrefs::supF -command "\
	    addtag $w.f.t sup"
    button $w.f.buts.sub -height 20 -width 18 -image $ReportPrefs::subF -command "\
	    addtag $w.f.t sub" 
    button $w.f.buts.nor -height 20 -width 18 -image $ReportPrefs::norF -command "\
	    remtag $w.f.t sub; remtag $w.f.t sup;"

    proc addtag { w tag } {
	set range [$w tag prevrange sel end]
	if {$range!="" } { 
	    eval $w tag add $tag $range
	}
    }
    proc remtag { w tag } {
	set range [$w tag prevrange sel end]
	if {$range!="" } { 
	    eval $w tag remove $tag $range
	}
    }

    pack $w.f.buts.a $w.f.buts.b $w.f.buts.d $w.f.buts.e $w.f.buts.g \
	    $w.f.buts.f $w.f.buts.h $w.f.buts.i $w.f.buts.j $w.f.buts.l \
	    $w.f.buts.k $w.f.buts.sup $w.f.buts.sub $w.f.buts.nor -side left

    text $w.f.t -xscroll "$w.f.hscr set" -yscroll "$w.f.vscr set" \
	    -width 60    
    scrollbar $w.f.vscr -orient vertical -comm "$w.f.t yview"
    scrollbar $w.f.hscr -orient horizontal -comm "$w.f.t xview"

    $w.f.t tag configure nor -font NormalFont
    $w.f.t tag configure sym -font SymbolFont
    $w.f.t tag configure sup -offset 4p
    $w.f.t tag configure sub -offset -3p
    $w.f.t tag configure und -underline on

    PutHtmlInText $w.f.t [set $tvar] yes

    bind $w.f.t <KeyPress> {
	if { [regexp {[a-zA-Z]} %A] } {
	    catch {
		if {[%W compare sel.first <= insert]
		&& [%W compare sel.last >= insert]} {
		    %W delete sel.first sel.last
		}
	    }
	    %W insert insert %A ""
	    break 
	}
    }

    grid $w.f.buts  -row 1 -column 1 -sticky w -pady $ReportPrefs::FramesSeparation -padx 5 -columnspan 2
    grid $w.f.t -row 2 -column 1  -padx 2 -sticky nsew
    grid $w.f.vscr -row 2 -column 2 -sticky ns
    grid $w.f.hscr -row 3 -column 1 -sticky ew -padx 2 
    grid columnconf $w.f 1 -weight 1
    grid rowconf $w.f 2 -weight 1

    frame $w.dbuts
    button $w.ok -text [= {OK}] -width 5 -command "set tkPriv(ed_button) ok" -und 0
    button $w.clear -text [= {Clear}] -width 5 -command "$w.f.t del 1.0 end" -und 1
    button $w.cancel -text [= {Cancel}] -width 5 -command "set tkPriv(ed_button) cancel" -und 0

    wm protocol $w WM_DELETE_WINDOW "tkButtonInvoke $w.cancel"
    bind $w.ok <Return> "tkButtonInvoke $w.ok"
    bind $w <Escape> "tkButtonInvoke $w.cancel"
    bind $w.f.t <Alt-o> "tkButtonInvoke $w.ok"
    bind $w.f.t <Alt-l> "tkButtonInvoke $w.clear"
    bind $w.f.t <Alt-c> "tkButtonInvoke $w.cancel"

    grid $w.f -row 1 -column 1  -pady $ReportPrefs::FramesSeparation -sticky ewns \
	    -padx 2
    grid $w.dbuts -row 2 -column 1
    grid $w.ok -in $w.dbuts -row 2 -column 1 -sticky e -pady 3 -padx 2
    grid $w.clear -in $w.dbuts -row 2 -column 2 -pady 2 -sticky w -padx 2
    grid $w.cancel -in $w.dbuts -row 2 -column 3 -pady 2 -sticky w -padx 2

    grid columnconf $w 1 -weight 1
    grid rowconf $w 1 -weight 1

    wm withdraw $w
    update idletasks

    set pare [winfo toplevel [winfo parent $w]]
    set x [expr [winfo x $pare]+[winfo width $pare ]/2- [winfo reqwidth $w]/2]
    set y [expr [winfo y $pare]+[winfo height $pare ]/2- [winfo reqheight $w]]
    if { $x < 0 } { set x 0 }
    if { $y < 0 } { set y 0 }
    WmGidGeom $w +$x+$y
    update
    wm deiconify $w

    set oldFocus [focus]
    tkwait visibility $w
    set oldGrab [grab current $w]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $w
    focus $w.f.t
    after 100 catch [list "focus -force $w.f.e"]

    while 1 {
	tkwait variable tkPriv(ed_button)

	set retval ""
	if { $tkPriv(ed_button) == "ok" } {
	    set $tvar [ReturnBestHtmlFromText $w.f.t]
	    #WarnWinText ---$ReportPrefs::reportdescription---
	    break
	} else { break }
    }
    
    if { $oldFocus == "" || [catch {focus $oldFocus}] } {
	if { [winfo exists .gid] } {
	    focus [focus -lastfor .gid]
	}
    }

    destroy $w
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    catch { grab -global $oldGrab }
	} else {
	    catch { grab $oldGrab }
	}
    }

    return $retval
}

###################################################
# UTILIDADES DE CREACI�N DE GR�FICOS Y TIME TABLE
###################################################
### Generic utility to draw a graph             ###
namespace eval TdynDrawGraph {

    variable yvalues
    variable maxx
    variable xlabel
    variable ylabel
    variable title
    variable initialx
variable initialy
    variable xfact 
    variable xm 
    variable yfact 
    variable ym 
    variable ymax 
    variable ynummin 
    variable ynummax
    variable after_draw_idle
variable xsel

    proc DrawCurve { cv yvaluesv maxxv maxyv xlabelv ylabelv titlev inix iniy xvaluesv {xselected ""} } {
	Init $cv $yvaluesv $maxxv $maxyv $xlabelv $ylabelv $titlev $inix $iniy $xvaluesv 
	Draw $cv
    }
}

proc TdynDrawGraph::Init { c yvaluesv maxxv maxyv xlabelv ylabelv titlev inix iniy xvaluesv {xselected ""} } {
    variable yvalues
    variable xvalues
    variable maxx
variable maxy
    variable xlabel
    variable ylabel
    variable title
    variable initialx
variable initialy
variable xsel
    variable xfact 
    variable xm 
    variable yfact 
    variable ym 
    variable ymax 
    variable ynummin 
    variable ynummax
    set yvalues($c) $yvaluesv
    set xvalues($c) $xvaluesv
set maxy($c) $maxyv
    set maxx($c) $maxxv
    set xlabel($c) $xlabelv
    set ylabel($c) $ylabelv
    set title($c) $titlev
    set initialx($c) $inix
set initialy($c) $iniy
set xsel($c) $xselected
    set xfact($c) ""
    set xm($c) ""
    set yfact($c) ""
    set ym($c) ""
    set ymax($c) ""
    set ynummin($c) ""
    set ynummax($c) ""

    bind $c <Configure> [list TdynDrawGraph::Draw_idle $c]
}

proc TdynDrawGraph::Draw { c } {
    upvar 0 TdynDrawGraph::xvalues($c) xvalues
    upvar 0 TdynDrawGraph::yvalues($c) yvalues
    upvar 0 TdynDrawGraph::maxx($c) maxx
    upvar 0 TdynDrawGraph::xlabel($c) xlabel
    upvar 0 TdynDrawGraph::ylabel($c) ylabel
    upvar 0 TdynDrawGraph::title($c) title
    upvar 0 TdynDrawGraph::xfact($c) xfact
    upvar 0 TdynDrawGraph::xm($c) xm
    upvar 0 TdynDrawGraph::yfact($c) yfact
    upvar 0 TdynDrawGraph::ym($c) ym
    upvar 0 TdynDrawGraph::ymax($c) ymax
    upvar 0 TdynDrawGraph::ynummin($c) ynummin
    upvar 0 TdynDrawGraph::ynummax($c) ynummax
    upvar 0 TdynDrawGraph::initialx($c) initialx
    upvar 0 TdynDrawGraph::initialy($c) initialy
    upvar 0 TdynDrawGraph::xsel($c) xsel

    $c delete curve
    $c delete axestext
    $c delete titletext
    $c delete zeroline

    set inix $initialx
    set iniy $initialy
    set numdivisions [expr [llength $yvalues]-1]

    set ymax [expr [winfo height $c]]
    if { $ymax <= 1 } { set ymax [winfo reqheight $c] }
    set xmax [winfo width $c]
    if { $xmax <= 1 } { set xmax [winfo reqwidth $c] }

    set ynummax [lindex $yvalues 0]
    set ynummin $initialy
    set textwidth 0
    for {set i 0 } { $i <= $numdivisions } { incr i } {
	set yval [lindex $yvalues $i]
	if { $yval > $ynummax } {
	    set ynummax $yval
	}
	if { $i == 0 || $yval < $ynummin } {
	    set ynummin $yval
	}
    }
    if { $ynummax == $ynummin } { 
	set ynummax [expr $ynummax+1.0] 
	set ynummin [expr $ynummin-1.0]
    }

    set inumtics 11
#8
    
    for {set i 0 } { $i < $inumtics } { incr i } {
	set yvaltext [format "%.4g" [expr $ynummin+$i/double($inumtics-1)*($ynummax-$ynummin)]]
	regsub {e([+-])00} $yvaltext {e\10} yvaltext
	set tt [font measure NormalFont $yvaltext]
	if { $tt > $textwidth } { set textwidth $tt }
    }
    set fam [font actual NormalFont -family]
    set tsize [expr [font actual NormalFont -size]*2]

    set xm [expr $textwidth+15]
    set textheight [font metrics [list $fam $tsize] -linespace]
    set ylabelrows [llength [split $ylabel \n]]
    if { $ylabelrows == 0 } {
	set ylabeltextheight [font metrics [list $fam $tsize] -linespace]
    } else {
	set ylabeltextheight [expr [font metrics [list $fam $tsize] -linespace]*$ylabelrows]
    }
    set ym [expr $ylabeltextheight]
    set xlabeltextlength 0
    set tmplabel [split $xlabel \n]
    foreach label $tmplabel {
	set length [font measure NormalFont $label]
	if { $length>$xlabeltextlength } { set xlabeltextlength $length } 
    }
    set xmlabel [expr $xmax-$xlabeltextlength-5]
    if { $xm < [expr $xlabeltextlength+8] } {
	set xmax [expr $xmax-$xlabeltextlength+$xm-15]
    }
    
    set fam [font configure NormalFont -family]
    set rtitle [split $title \n]
    set factor [expr 2./[llength $rtitle]]
    if { $factor < 0.25 } {
	set factor 0.25
    }
    set tsize [expr int([font configure NormalFont -size]*$factor)]

#     $c create text [expr $xmax/2] 6 -anchor n -justify center \
#             -text $title -font [list $fam $tsize] -tags titletext
#     
#     $c create line $xm $ym $xm [expr $ymax-$ym] [expr $xmax-$xm] \
#             [expr $ymax-$ym] -tags axestext

    set inumtics 11 
#8

    set fam [font configure NormalFont -family]
    set tsize [expr int([expr [font configure NormalFont -size]*0.5])]
    for {set i 0 } { $i < $inumtics } { incr i } {
#        set xvaltext [format "%3.1lf" \
#                [expr $inix+$i/double($inumtics-1)*($maxx-$inix)]]
	set xvaltext [format "%.3g" \
		[expr $inix+$i/double($inumtics-1)*($maxx-$inix)]]
	set xval [expr $xm+$i/double($inumtics-1)*($xmax-2*$xm)]
	set xvalt $xval
	if { $i == 0 } { set xvalt [expr $xvalt+4] }
	$c create line $xval [expr $ymax-$ym+2] $xval [expr $ymax-$ym] \
		-tags axestext
	$c create text $xval [expr $ymax-$ym+2] -anchor n -justify center \
		-text $xvaltext -font [list $fam $tsize] -tags axestext

####
	if { $i != 0 } {
	    $c create line $xval $ym $xval [expr $ymax-$ym] -fill grey -tags axestext 
	}
####

	set yvaltext [format "%.4g" [expr $ynummin+$i/double($inumtics-1)*($ynummax-$ynummin)]]
	regsub {e([+-])00} $yvaltext {e\10} yvaltext
	set yval [expr $ymax-$ym-$i/double($inumtics-1)*($ymax-2*$ym)]
	set yvalt $yval
	if { $i == 0 } { set yvalt [expr $yvalt-4] }
	$c create line [expr $xm-2] $yval $xm $yval -tags axestext
	$c create text [expr $xm-3] $yvalt -anchor e -justify right \
		-text $yvaltext -font [list $fam $tsize] -tags axestext

####
	if { $i != 0 } {
	    $c create line $xm $yval [expr $xmax-$xm] $yval -fill grey -tags axestext 
	}
####

    }

    #Selected values
    foreach "xval xtext" $xsel {
	set fac [expr ($xval-$initialx)/double($maxx-$initialx)]
	set xvalue [expr ($xvalt-$xm)*$fac+$xm]
	$c create line $xvalue [expr $ymax-$ym+26] $xvalue [expr $ymax-$ym] \
	    -fill grey -tags axestext
	$c create text $xvalue [expr $ymax-$ym+26] -anchor n -justify center \
	    -text $xtext -font [list $fam $tsize] -tags axestext
	$c create line $xvalue $ym $xvalue [expr $ymax-$ym] -fill grey -tags axestext 
    }

    $c create text 6 6 -anchor nw -justify left \
	    -text $ylabel -font NormalFont -tags axestext
    set textwidth [font measure NormalFont 0.0]
    $c create text $xmlabel [expr $ymax-$ym] \
	    -anchor nw -justify left \
	    -text $xlabel -font NormalFont -tags axestext

    set xfact [expr ($xmax-2.0*$xm)/double($maxx-$inix)]
    set yfact [expr ($ymax-2.0*$ym)/double($ynummax-$ynummin)]

    set yval [expr $ymax-$ym-(0.0-$ynummin)*$yfact]
    if { $yval > $ym && $yval <= [expr $ymax-$ym] } {
	$c create line $xm $yval [expr $xmax-$xm] $yval -tags zeroline -dash -.-
    }
    if { [llength $xvalues] } {
	set xfactdiv [expr ($xmax-2.0*$xm)/double($maxx-$inix)]
	set lastxval [expr {([lindex $xvalues 0]-$inix)*$xfactdiv+$xm}]
	set lastyval [expr $ymax-$ym-([lindex $yvalues 0]-$ynummin)*$yfact]
	for {set i 1 } { $i <= $numdivisions } { incr i } {
	    set xval [expr {([lindex $xvalues $i]-$inix)*$xfactdiv+$xm}]
	    set yval [expr $ymax-$ym-([lindex $yvalues $i]-$ynummin)*$yfact]
	    $c create line $lastxval $lastyval \
		$xval $yval -tags curve -width 3 -fill red
	    set lastxval $xval
	    set lastyval $yval
	}
    } else {
	set xfactdiv [expr ($xmax-2.0*$xm)/double($numdivisions)]
	set lastyval [expr $ymax-$ym-([lindex $yvalues 0]-$ynummin)*$yfact]
	for {set i 1 } { $i <= $numdivisions } { incr i } {
	    set yval [expr $ymax-$ym-([lindex $yvalues $i]-$ynummin)*$yfact]
		   $c create line [expr ($i-1)*$xfactdiv+$xm] $lastyval \
		               [expr $i*$xfactdiv+$xm] $yval -tags curve -width 3 -fill red
	    set lastyval $yval
	}
    }

####    
    $c create text [expr $xmax/2] 6 -anchor n -justify center \
	-text $title -font [list $fam $tsize] -tags titletext
    
    $c create line $xm $ym $xm [expr $ymax-$ym] [expr $xmax-$xm] \
	[expr $ymax-$ym] -tags axestext
####
    $c bind curve <ButtonPress-1> "TdynDrawGraph::DrawGraphCoords %x %y $c"
}

proc TdynDrawGraph::Draw_idle { c } {
    variable after_draw_idle

    if { [info exists after_draw_idle] } {
	after cancel $after_draw_idle
	unset after_draw_idle
    }
    set cmd "TdynDrawGraph::Draw $c; unset TdynDrawGraph::after_draw_idle"
    set after_draw_idle [after 100 $cmd]
}

proc TdynDrawGraph::FindClosestPoint { x y c } {

    set mindist2 1e20
    foreach i [$c find withtag curve] {
	foreach "ax ay bx by" [$c coords $i] break
	set vx [expr $bx-$ax]
	set vy [expr $by-$ay]
	set alpha [expr $vx*($ax-$x)+$vy*($ay-$y)]
	if { $vx == 0 && $vy == 0 } { continue }
	set landa [expr -1*$alpha/double($vx*$vx+$vy*$vy)]
	if { $landa < 0.0 } { set landa 0.0 }
	if { $landa > 1.0 } { set landa 1.0 }
	set px [expr $ax+$landa*$vx]
	set py [expr $ay+$landa*$vy]

	set dist2 [expr ($px-$x)*($px-$x)+($py-$y)*($py-$y)]
	if { $dist2 < $mindist2 } {
	    set mindist2 $dist2
	    set minpx $px
	    set minpy $py
	}
    }
    return [list $minpx $minpy]
}

proc TdynDrawGraph::DrawGraphCoords { x y c } {

    upvar 0 TdynDrawGraph::yvalues($c) yvalues
    upvar 0 TdynDrawGraph::maxx($c) maxx
    upvar 0 TdynDrawGraph::xlabel($c) xlabel
    upvar 0 TdynDrawGraph::ylabel($c) ylabel
    upvar 0 TdynDrawGraph::title($c) title
    upvar 0 TdynDrawGraph::xfact($c) xfact
    upvar 0 TdynDrawGraph::xm($c) xm
    upvar 0 TdynDrawGraph::yfact($c) yfact
    upvar 0 TdynDrawGraph::ym($c) ym
    upvar 0 TdynDrawGraph::ymax($c) ymax
    upvar 0 TdynDrawGraph::ynummin($c) ynummin
    upvar 0 TdynDrawGraph::ynummax($c) ynummax
    upvar 0 TdynDrawGraph::initialx($c) initialx

    $c delete coords
    $c delete coordpoint

    set ymax [winfo height $c]
    set xmax [winfo width $c]
    
    if { [lindex $yvalues end] < ($ynummax-$ynummin)/2.0 } {
	foreach "{} {} {} ytitle" [$c bbox titletext] break
	set ytitle [expr $ytitle+2]
	set anchor ne
    } else {
	set ytitle [expr $ymax-$ym-5]
	set anchor se
    }

    foreach "xcurve ycurve" [TdynDrawGraph::FindClosestPoint $x $y $c] break

    $c create oval [expr $xcurve-2] [expr $ycurve-2] [expr $xcurve+2] [expr $ycurve+2] \
	    -tags coordpoint

    set xtext [expr ($xcurve-$xm)/double($xfact)+$initialx]
    regsub {e([+-])00} $xtext {e\10} xtext
    set ytext [expr ($ymax-$ym-$ycurve)/double($yfact)+$ynummin]
    regsub {e([+-])00} $ytext {e\10} ytext

    $c create text [expr $xmax-6] $ytitle -anchor $anchor -font NormalFont \
	    -text [format "$xlabel: %.4g  $ylabel: %.4g" $xtext $ytext] -tags coords

    $c bind curve <ButtonRelease-1> "$c delete coords coordpoint; $c bind curve <B1-Motion> {}"
    $c bind curve <B1-Motion> "TdynDrawGraph::DrawGraphCoords %x %y $c"
}

proc TdynDrawGraph::AutoConfAxis_Pos { init_maxx init_minx div fac } {
    #Round minimum value
    foreach "minx fac_minx" [Mult $init_minx] break
    set minx [expr floor($minx)]
    set minx [expr $minx/double($fac_minx)]
    #Calculate new maximum value
    set lenx [expr $fac*($init_maxx-$minx)]
    set incx [expr ($lenx/$div)]
    foreach "incx fac_incx" [Mult $incx] break
    set incx [expr round($incx)]
    set incx [expr $incx/double($fac_incx)]
    set lenx [expr $incx*$div]
    set maxx [expr ($lenx/double($fac))+$minx]
#     if { $init_maxx > $maxx } { set maxx [expr $maxx+$incx] }
    while { $init_maxx > $maxx } {
	set maxx [expr $maxx+$incx]
    }

    return [list $maxx $minx]
}

### Draw a forces graph, reading info from file ###
namespace eval ForcesGraph {
    variable initim
    variable endtim
    variable itim
    variable fwin
    variable file

    variable iset
    variable sets

    variable types [list PFX PFY PFZ PMX PMY PMZ SPX SPY SPZ SMX SMY SMZ VFX VFY VFZ VMX VMY VMZ]
    variable typenames [list [= {Pressure Force X}] [= {Pressure Force Y}] [= {Pressure Force Z}] \
	    [= {Pressure Moment X}] [= {Pressure Moment Y}] [= {Pressure Moment Z}] \
	    [= {Static Pressure Force X}] [= {Static Pressure Force Y}] [= {Static Pressure Force Z}] \
	    [= {Static Pressure Moment X}] [= {Static Pressure Moment Y}] [= {Static Pressure Moment Z}] \
	    [= {Viscous Force X}] [= {Viscous Force Y}] [= {Viscous Force Z}] \
	    [= {Viscous Moment X}] [= {Viscous Moment Y}] [= {Viscous Moment Z}]]
    variable itype [lindex $typenames 0]

    for { set i 0 } { $i < [llength $types] } { incr i } {
	set item [lindex $types $i]
	variable $item
	set ${item}(name) [lindex $typenames $i]
    }
}

proc ForcesGraph::go { c } {
    variable itim
    variable initim
    variable endtim
    variable iset
    variable types
    variable typenames
    variable itype
    foreach item $types {
	variable $item
    }

    # Calculate list of data
    set idx [lsearch $typenames $itype]
    if { $idx == -1 } {
	return
    }
    set type [lindex $types $idx]
    upvar 0 ${type}($iset) listb
    set numpoints [llength $listb]  
    if { $numpoints == 1 } {
	set ypoin [lindex $listb 0]
	$c delete all
	$c create text 10 10 -anchor nw -justify left \
		-text [= {Only one value found: %s = %s} [lindex $typenames $idx] $ypoin] -font NormalFont -tags axestext
	return
    } elseif { $numpoints > 200 } {
	set numpoints 200
    }
    if { ![string is double $initim] } {
	set initim [lindex $itim 0]
    }
    if { ![string is double $endtim] } {
	set endtim [lindex $itim end]
    }
    if { $initim >= $endtim } {
	set initim [lindex $itim 0]
	set endtim [lindex $itim end] 
    }
    if { $initim < [lindex $itim 0] } {
	WarnWin [= {Check value. X value is smaller than the minimum value.}]
	set initim [lindex $itim 0]
    }
    if { $endtim > [lindex $itim end] } {
	WarnWin [= {X value is greater than the last written value.}]
	set endtim [lindex $itim end]
    }
    set init 0
    set fini 0
    set listx ""
    set listy ""
    set dt [expr (double($endtim)-double($initim))/(double($numpoints)-1.0)]
    set idx 0
    set t $initim
    for { set i 0 } { $i < $numpoints } { incr i } {
	while { [lindex $itim $idx]<=$t && $idx!=[llength $itim] } { incr idx }
	lappend listx $t
	set prevy [lindex $listb [expr $idx-1]] 
	set curry [lindex $listb $idx]
	set prevx [lindex $itim [expr $idx-1]] 
	set currx [lindex $itim $idx]
	lappend listy [expr $prevy+($t-$prevx)*($curry-$prevy)/($currx-$prevx)]
	set t [expr $t+$dt]
    }

    TdynDrawGraph::DrawCurve $c $listy $endtim "" Time "$itype" [= {Time Evolution}] $initim "" ""
}

proc ForcesGraph::init { { w .fordat } } {

    # Variables
    variable fwin $w
    variable itim
    variable initim
    variable endtim
    variable iset
    variable sets
    variable types
    variable typenames

    # Control de existencia del archivo de datos  
    set forcesfile ""
    set aa [.central.s info Project]
    set ProjectName [lindex $aa 1]
    if { [file extension $ProjectName] == ".gid" } {
    set ProjectName [file root $ProjectName]
    }
    set basename [file tail $ProjectName]
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
	set directory [file join [pwd] $directory]
    }
    variable file [file join $directory $basename.flavia.for]
    if { ![file exists $file] } {
      catch { destroy $w }
	tk_dialogRAM .gid.tempwin {Error window} [= {No forces data found for this model}] \
		error 0 OK
	return
    } 
    set fd [open $file r]
    set bb "" 
    while { ![eof $fd] } { 
	gets $fd bb
	set bblen [llength $bb]
	if { $bblen>0 && $bblen<14 } {
	    close $fd
	    catch { destroy $w }
	    tk_dialogRAM .gid.tempwin {Error window} [= {Forces data not found in file}] \
		    error 0 OK
	    return
	} elseif { $bblen>0 } {
	    break
	}
    }
    if {$bb == ""} { 
	close $fd
	catch { destroy $w }
	tk_dialogRAM .gid.tempwin {Error window} [= {Forces file is empty}] \
		error 0 OK
	    return
    }

    # Llama a InitFCGraph para leer los datos
    ForcesGraph::ReadFCGraph

    # Aqui se crea la ventana
    InitWindow $w [= {Forces & Moments Graph}] PrePostForcesDataWindowGeom ""
    wm minsize $w 325 275
#    wm withdraw $w

    # Crea el "lienzo" d�nde se dibujar� la gr�fica
    set can [canvas $w.can -relief sunken -bd 2 -bg white -width 250 -height 200]
    grid $can -row 1 -column 0 -sticky nswe

    trace vdelete ForcesGraph::itype w "ForcesGraph::go $can $w ;#"

    # Crea una barra de opciones que permite seleccionar los sets
    NoteBook $w.set -homogeneous 1
    set i 0
    foreach iset $sets {
	set name set_[incr i]
	$w.set insert end $name -text $iset -raisecmd "ForcesGraph::goset $iset $can"
    }
    $w.set raise [lindex set_1 0] 
    grid $w.set -row 0 -column 0 -sticky nswe

    set fr1 [frame $w.fr1]
    label $fr1.l1 -text "[= {Time}]: [= {From}]"
    entry $fr1.e1 -textvariable ForcesGraph::initim -relief sunken -width 5
    label $fr1.l2 -text " [= {To}]"
    entry $fr1.e2 -textvariable ForcesGraph::endtim -relief sunken -width 5
    label $fr1.l3 -text "[= {}]."

    grid $fr1 -row 2 -column 0 -sticky nswe 
    grid $fr1.l1 -row 0 -column 0
    grid $fr1.e1 -sticky ew -row 0 -column 1
    grid $fr1.l2  -row 0 -column 2
    grid $fr1.e2 -sticky ew -row 0 -column 3
    grid $fr1.l3 -row 0 -column 4

    set fr2 [frame $w.fr2]
    label $fr2.lab -anchor w -text "[= {Select graph}]:"
    eval tk_optionMenu $fr2.type ForcesGraph::itype $typenames

    grid $fr2 -row 3 -column 0 -sticky wns
    grid $fr2.lab -row 0 -column 0 -sticky w
    grid $fr2.type -row 0 -column 1

    frame $w.buts
    button $w.buts.ap -text [= {Apply Limits}] -command "ForcesGraph::go $can"
    button $w.buts.ac -text [= {Actualize}] -command "ForcesGraph::Actualize $can"
    button $w.buts.cl -text [= {Close}] -command "destroy $w"
    grid $w.buts -row 4 -column 0 -sticky nswe -padx 5 -pady 10
    grid $w.buts.ap -row 0 -column 0 -sticky nswe -padx 5
    grid $w.buts.ac -row 0 -column 1 -sticky nswe -padx 5
    grid $w.buts.cl -row 0 -column 2 -sticky nswe -padx 5

    grid columnconf $w 0 -weight 1
    grid rowconf $w 1 -weight 1
    grid columnconf $fr1 1 -weight 1
    grid columnconf $fr1 3 -weight 1

    bind $fr1.e1 <Return> "ForcesGraph::go $can"
    bind $fr1.e2 <Return> "ForcesGraph::go $can"
    trace var ForcesGraph::itype w "ForcesGraph::go $can ;#"

    bind $w <Configure> "ForcesGraph::go $can"

    update idletasks
    wm deicon $w

    upvar #0 [winfo name $w] data
}

proc ForcesGraph::CreateFrame { base } {
    # Variables
    variable itim
    variable initim
    variable endtim
    variable iset
    variable sets
    variable types
    variable typenames

    # Crea el "lienzo" d�nde se dibujar� la gr�fica
    set can [canvas $base.can -relief sunken -bd 2 -bg white -width 250 -height 200]
    grid $can -row 1 -column 0 -sticky nswe

    trace vdelete ForcesGraph::itype w "ForcesGraph::go $can $base ;#"

    # Crea el pie
    set fr1 [frame $base.fr1]
    label $fr1.l1 -text "[= {Time}]: [= {From}]"
    entry $fr1.e1 -textvariable ForcesGraph::initim -relief sunken -width 5
    label $fr1.l2 -text " [= {To}]"
    entry $fr1.e2 -textvariable ForcesGraph::endtim -relief sunken -width 5
    label $fr1.l3 -text "[= {}]."

    grid $fr1 -row 2 -column 0 -sticky nswe 
    grid $fr1.l1 -row 0 -column 0
    grid $fr1.e1 -sticky ew -row 0 -column 1
    grid $fr1.l2  -row 0 -column 2
    grid $fr1.e2 -sticky ew -row 0 -column 3
    grid $fr1.l3 -row 0 -column 4

    set fr2 [frame $base.fr2]
    label $fr2.lab -anchor w -text "[= {Select graph}]:"
    eval tk_optionMenu $fr2.type ForcesGraph::itype $typenames

    grid $fr2 -row 3 -column 0 -sticky wns
    grid $fr2.lab -row 0 -column 0 -sticky w
    grid $fr2.type -row 0 -column 1

    grid columnconf $base 0 -weight 1
    grid rowconf $base 1 -weight 1
    grid columnconf $fr1 1 -weight 1
    grid columnconf $fr1 3 -weight 1

    bind $fr1.e1 <Return> "ForcesGraph::go $can"
    bind $fr1.e2 <Return> "ForcesGraph::go $can"
    trace var ForcesGraph::itype w "ForcesGraph::go $can ;#"

    bind $base <Configure> "ForcesGraph::go $can"

}

proc ForcesGraph::goset { iset can } {
    set ForcesGraph::iset $iset
    ForcesGraph::go $can
}

proc ForcesGraph::kill {  } {
    variable fwin
    if { [winfo exists fwin] } {
	destroy $fwin
    }
}

proc ForcesGraph::Actualize { c } {
    variable iset
    if { [catch {
	set isettmp $iset
	ForcesGraph::ReadFCGraph
	set iset $isettmp
	ForcesGraph::go $c
    }] } {
	tk_dialogRAM .gid.tempwin {Error window} "[= {Error found}]. [= {Cannot actualize graph}]." \
		error 0 OK
#        $c create text 10 10 -anchor nw -justify left -font NormalFont -tags axestext\
#                -text "[= {Error found}]. [= {Cannot actualize graph}]." 
    }
}

proc ForcesGraph::ReadFCGraph { } {
    variable file
    variable initim
    variable endtim
    variable itim
    variable iset
    variable sets
    variable types
    foreach item $types {
	variable $item
    }
    set sets "" 
    set itim "" 

    set listlen [expr [llength $types]+1]
    # Se lee el archivo de datos para el gr�fico
    set fd [open $file r]
#    set bb "Nothing at all"
    while { ![eof $fd] } {
	gets $fd aa
	if { [regexp {[0-9]} $aa ] } {
	    if { [llength $aa] < $listlen } {
		close $fd
		return
	    }
	    lappend bb $aa
	}
    } 
    close $fd

    for { set ir 0 } { $ir < [llength $bb] } { incr ir } {  
	set listb [lindex $bb [expr $ir]] 
	lappend itim [lindex $listb 0]
	for { set i 1 } { $i < [llength $listb] } { incr i $listlen } {
	    set thisset [lindex $listb [expr $i]]
	    if { $ir == 0 } { 
		lappend sets $thisset
		foreach item $types {
		    set ${item}($thisset) ""
		}
	    }
	    set j $i
	    foreach item $types {
		lappend ${item}($thisset) [lindex $listb [incr j]]
	    }
	}
    }
    set iset [lindex $sets 0]
    set initim [lindex $itim 0] 
    set endtim [lindex $itim end]
}

### Draw a motions graph, reading info from file ###
namespace eval MotionsGraph {
    variable initim
    variable endtim
    variable itim
    variable fwin
    variable file

    variable iset
    variable sets

    variable types [list DOX DOY DOZ ROX ROY ROZ]
    variable typenames [list [= {Displacement OX}] [= {Displacement OY}] [= {Displacement OZ}] \
	    [= {Rotation OX}] [= {Rotation OY}] [= {Rotation OZ}]]
    variable itype [lindex $typenames 0]

    for { set i 0 } { $i < [llength $types] } { incr i } {
	set item [lindex $types $i]
	variable $item
	set ${item}(name) [lindex $typenames $i]
    }
}

proc MotionsGraph::go { c } {
    variable itim
    variable initim
    variable endtim
    variable iset
    variable types
    variable typenames
    variable itype
    foreach item $types {
	variable $item
    }
    # Calculate list of data
    set idx [lsearch $typenames $itype]
    if { $idx == -1 } {
	return
    }
    set type [lindex $types $idx]
    upvar 0 ${type}($iset) listb
    set numpoints [llength $listb]  
    set nnumpoints 200
    if { $numpoints == 1 } {
	set ypoin [lindex $listb 0]
	$c delete all
	$c create text 10 10 -anchor nw -justify left \
		-text "[= {Only one value found: %s = %s} [lindex $typenames $idx] $ypoin]" -font NormalFont -tags axestext
	return
    } elseif { $numpoints > 200 } {
	set numpoints 200
    }
    if { ![string is double $initim] } {
	set initim [lindex $itim 0]
    }
    if { ![string is double $endtim] } {
	set endtim [lindex $itim end]
    }
    if { $initim >= $endtim } {
	set initim [lindex $itim 0]
	set endtim [lindex $itim end] 
    }
    if { $initim < [lindex $itim 0] } {
	WarnWin [= {Check value. X value is smaller than the minimum value.}]
	set initim [lindex $itim 0]
    }

    set init 0
    set fini 0
    set listx ""
    set listy ""
    set dt [expr (double($endtim)-double($initim))/(double($numpoints)-1.0)]
    set idx 0
    set t $initim

    for { set i 0 } { $i < $numpoints } { incr i } {
	while { [lindex $itim $idx]<=$t && $idx!=[llength $itim] } { incr idx }
	lappend listx $t
	set prevy [lindex $listb [expr $idx-1]] 
	set curry [lindex $listb $idx]
	set prevx [lindex $itim [expr $idx-1]] 
	set currx [lindex $itim $idx]
	lappend listy [expr $prevy+($t-$prevx)*($curry-$prevy)/($currx-$prevx)]
	set t [expr $t+$dt]
    }


    TdynDrawGraph::DrawCurve $c $listy $endtim "" Time "$itype" [= {Time Evolution}] $initim "" ""
}

proc MotionsGraph::init { { w .movdat } } {

    # Variables
    variable fwin $w
    variable itim
    variable initim
    variable endtim
    variable iset
    variable sets
    variable itype
    variable types
    variable typenames

    # Control de existencia del archivo de datos  
    set forcesfile ""
    set aa [.central.s info Project]
    set ProjectName [lindex $aa 1]
    if { [file extension $ProjectName] == ".gid" } {
    set ProjectName [file root $ProjectName]
    }
    set basename [file tail $ProjectName]
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
	set directory [file join [pwd] $directory]
    }
    variable file [file join $directory $basename.flavia.mov]

    if { ![file exists $file] } {
      catch { destroy $w }
	tk_dialogRAM .gid.tempwin {Error window} [= {No motions data found for this model}] \
		error 0 OK
	return
    } 
    set fd [open $file r]
    set bb "" 
    while { ![eof $fd] } { 
	gets $fd bb
	set bblen [llength $bb]
	if { $bblen>0 && $bblen<8 } {
	    close $fd
	    catch { destroy $w }
	    tk_dialogRAM .gid.tempwin {Error window} [= {Motions data not found in file}] \
		    error 0 OK
	    return
	} elseif { $bblen>0 } {
	    break
	}
    }
    if {$bb == ""} { 
	close $fd
	catch { destroy $w }
	tk_dialogRAM .gid.tempwin {Error window} [= {Motions file is empty}] \
		error 0 OK
	    return
    }

    # Llama a InitFCGraph para leer los datos
    MotionsGraph::ReadFCGraph

    # Aqui se crea la ventana
    InitWindow $w [= {Motions Graph}] PrePostMovementDataWindowGeom ""
    wm minsize $w 325 275
#    wm withdraw $w

    # Crea el "lienzo" d�nde se dibujar� la gr�fica
    set can [canvas $w.can -relief sunken -bd 2 -bg white -width 250 -height 200]
    grid $can -row 1 -column 0 -sticky nswe

    trace vdelete MotionsGraph::itype w "MotionsGraph::go $can $w ;#"

    # Crea una barra de opciones que permite seleccionar los sets
    NoteBook $w.set -homogeneous 1
    set i 0
    foreach iset $sets {
	set name set_[incr i]
	$w.set insert end $name -text $iset -raisecmd "MotionsGraph::goset $iset $can"
    }
    $w.set raise [lindex set_1 0] 
    grid $w.set -row 0 -column 0 -sticky nswe

    set fr1 [frame $w.fr1]
    label $fr1.l1 -text "[= {Time}]: [= {From}]"
    entry $fr1.e1 -textvariable MotionsGraph::initim -relief sunken -width 5
    label $fr1.l2 -text " [= {To}]"
    entry $fr1.e2 -textvariable MotionsGraph::endtim -relief sunken -width 5
    label $fr1.l3 -text "[= {}]."

    grid $fr1 -row 2 -column 0 -sticky nswe 
    grid $fr1.l1 -row 0 -column 0
    grid $fr1.e1 -sticky ew -row 0 -column 1
    grid $fr1.l2  -row 0 -column 2
    grid $fr1.e2 -sticky ew -row 0 -column 3
    grid $fr1.l3 -row 0 -column 4

    set fr2 [frame $w.fr2]
    label $fr2.lab -anchor w -text "[= {Select graph}]:"
    eval tk_optionMenu $fr2.type MotionsGraph::itype $typenames

    grid $fr2 -row 3 -column 0 -sticky wns
    grid $fr2.lab -row 0 -column 0 -sticky w
    grid $fr2.type -row 0 -column 1

    frame $w.buts
    button $w.buts.ap -text [= {Apply Limits}] -command "MotionsGraph::go $can"
    button $w.buts.ac -text [= {Actualize}] -command "MotionsGraph::Actualize $can"
    button $w.buts.cl -text [= {Close}] -command "destroy $w"
    grid $w.buts -row 4 -column 0 -sticky nswe -padx 5 -pady 10
    grid $w.buts.ap -row 0 -column 0 -sticky nswe -padx 5
    grid $w.buts.ac -row 0 -column 1 -sticky nswe -padx 5
    grid $w.buts.cl -row 0 -column 2 -sticky nswe -padx 5

    grid columnconf $w 0 -weight 1
    grid rowconf $w 1 -weight 1
    grid columnconf $fr1 1 -weight 1
    grid columnconf $fr1 3 -weight 1

    bind $fr1.e1 <Return> "MotionsGraph::go $can"
    bind $fr1.e2 <Return> "MotionsGraph::go $can"
    trace var MotionsGraph::itype w "MotionsGraph::go $can ;#"

    bind $w <Configure> "MotionsGraph::go $can"

    update idletasks
    wm deicon $w

    upvar #0 [winfo name $w] data
}

proc MotionsGraph::goset { iset can } {
    set MotionsGraph::iset $iset
    MotionsGraph::go $can
}

proc MotionsGraph::kill {  } {
    variable fwin
    if { [winfo exists fwin] } {
	destroy $fwin
    }
}

proc MotionsGraph::Actualize { c } {
    variable iset
    if { [catch {
	set isettmp $iset
	MotionsGraph::ReadFCGraph
	set iset $isettmp
	MotionsGraph::go $c
    }] } {
	tk_dialogRAM .gid.tempwin {Error window} "[= {Error found}]. [= {Cannot actualize graph}]." \
		    error 0 OK
#        $c create text 10 10 -anchor nw -justify left -font NormalFont -tags axestext\
#                -text "[= {Error found}]. [= {Cannot actualize graph}]." 
    }   
}

proc MotionsGraph::ReadFCGraph { } {
    variable file
    variable initim
    variable endtim
    variable itim
    variable iset
    variable sets
    variable types
    foreach item $types {
	variable $item
    }
    set sets "" 
    set itim "" 

    # Se lee el archivo de datos para el gr�fico
    set fd [open $file r]
#    set bb "Nothing at all"
    while { ![eof $fd] } {
	gets $fd aa
	if { [regexp {[0-9]} $aa ] } {
	    if { [llength $aa] < 8 } {
		close $fd
		return
	    }
	    lappend bb $aa
	}
    } 
    close $fd

    for { set ir 0 } { $ir < [llength $bb] } { incr ir} {  
	set listb [lindex $bb [expr $ir]] 
	lappend itim [lindex $listb 0]
	for { set i 1 } { $i < [llength $listb] } { incr i 7} {
	    set thisset [lindex $listb [expr $i]]
	    if { $ir == 0 } { 
		lappend sets $thisset
		foreach item $types {
		    set ${item}($thisset) ""
		}
	    }
	    set j $i
	    foreach item $types {
		lappend ${item}($thisset) [lindex $listb [incr j]]
	    }
	}
    }
    set iset [lindex $sets 0]
    set initim [lindex $itim 0] 
    set endtim [lindex $itim end]
}

### Draw a graph, reading info from file ###
namespace eval GraphFromFile {
    variable title
    variable wname
    variable xtitle

    variable inixval
variable inixval
    variable endxval
variable endyval
    variable fwin
    variable file
    
    variable xval
    variable yval
}

proc GraphFromFile::go { c } {
    variable title
    variable xtitle
    variable xval
    variable yval
    variable inixval
    variable endxval
    variable iniyval
    variable endyval
    
    set numpoints [llength $yval]  
    set nnumpoints 200
    if { $numpoints == 1 } {
	set ypoin [lindex $yval 0]
	$c delete all
	$c create text 10 10 -anchor nw -justify left -text "[= {Only one value found: %s}  \
	     $ypoin]" -font NormalFont -tags axestext
	return
    } elseif { $numpoints > 200 } {
	set numpoints 200
    }
    if { ![string is double $inixval] } {
	set inixval [lindex $xval 0]
    }
    if { ![string is double $endxval] } {
	set endxval [lindex $xval end]
    }
    if { $inixval >= $endxval } {
	set inixval [lindex $xval 0]
	set endxval [lindex $xval end] 
    }
    set init 0
    set fini 0
    set listx ""
    set listy ""
    set dt [expr (double($endxval)-double($inixval))/(double($numpoints)-1.0)]
    set idx 0
    set t $inixval

####    
# Axis defined by the user
    set OutOfRange 0
    set n_inixval $inixval
    set n_endxval $endxval
    if { $inixval < [lindex $xval 0] } { 
	set t [lindex $xval 0]
	set n_inixval [lindex $xval 1]
	set OutOfRange 1
    }
    if { $endxval > [lindex $xval end] } { 
	set n_endxval [lindex $xval end] 
	set OutOfRange 1
    }
    if { $OutOfRange == 1 } {
	set dt [expr (double($n_endxval)-double($n_inixval))/(double($numpoints)-1.0)]
	Warning [= {Values out of range.}]
#         return $
	
    }
####

    for { set i 0 } { $i < $numpoints } { incr i } {
	while { [lindex $xval $idx]<=$t && $idx!=[llength $xval] } { incr idx }
	lappend listx $t
	set prevy [lindex $yval [expr $idx-1]] 
	set curry [lindex $yval $idx]
	set prevx [lindex $xval [expr $idx-1]] 
	set currx [lindex $xval $idx]
	lappend listy [expr $prevy+($t-$prevx)*($curry-$prevy)/($currx-$prevx)]
	set t [expr $t+$dt]
    }

####
    # Axis autoconfiguration
    set iniyval [lindex $listy 0]
    set endyval [lindex $listy end]
    if { $endyval > $iniyval } {
	foreach "endyval iniyval" [AutoConfAxis_Pos $endyval $iniyval 10 1] break
    } else {
	foreach "endyval iniyval" [AutoConfAxis_Pos $iniyval $endyval 10 1] break
    }
####

    TdynDrawGraph::DrawCurve $c $listy $endxval $endyval $xtitle "" $title $inixval $iniyval $listx
}


proc GraphFromFile::init { f name { tit "" } { wnm "" } {xtit ""} } {

    # Variables
    variable title
    variable xtitle
    variable wname
    variable fwin .[string tolower [string trim $name {.}]]
    variable file $f
    variable xval
    variable inixval
    variable endxval
    variable iniyval
    variable endyval
    
    # Control de existencia del archivo de datos
    if { ![file exists $file] } {
	catch { destroy $fwin }
	tk_dialogRAM .gid.tempwin {Error window} \
	    "[= {No data found for graph}] $name" error 0 OK
	return
    } 
    set fd [open $file r]
    set bb "" 
    while { ![eof $fd] } { 
	gets $fd bb
	set bblen [llength $bb]
	if { $bblen>0 } {
	    break
	}
    }
    if {$bb == ""} { 
	close $fd
	catch { destroy $fwin }
	tk_dialogRAM .gid.tempwin {Error window} [= {Graph file is empty}] \
	    error 0 OK
	return
    }
    # Inicializamos las variables
    set wname $wnm
    if { $wnm == "" } {
	set wname [= {Graph}]
    }
    set title $tit
    if { $tit == "" } {
	set title [= {Time Evolution}]
    }
    set xtitle $xtit
    if { $xtit == "" } {
	set xtitle [= {Time}]
    }

    # Llama a InitFCGraph para leer los datos
    GraphFromFile::ReadFCGraph
    
    # Aqui se crea la ventana
    if { [winfo exist $fwin] } {
	destroy $fwin
    }
    InitWindow $fwin "$wname" PrePost${name}FileWindowGeom ""
    wm minsize $fwin 325 275
    wm withdraw $fwin
    
    # Crea el "lienzo" d�nde se dibujar� la gr�fica
    set can [canvas $fwin.can -relief sunken -bd 2 -bg white -width 250 -height 200]
    grid $can -row 1 -column 0 -sticky nswe
    
    # Se crean las utilidades de la ventana
    set fr1 [frame $fwin.fr1]
    label $fr1.l1 -text "$xtitle: [= {From}]"
    entry $fr1.e1 -textvariable GraphFromFile::inixval -relief sunken -width 8
    label $fr1.l2 -text " [= {To}]"
    entry $fr1.e2 -textvariable GraphFromFile::endxval -relief sunken -width 8
    label $fr1.l3 -text "[= {}]."
    
    grid $fr1 -row 2 -column 0 -sticky nswe 
    grid $fr1.l1 -row 0 -column 0
    grid $fr1.e1 -sticky ew -row 0 -column 1
    grid $fr1.l2  -row 0 -column 2
    grid $fr1.e2 -sticky ew -row 0 -column 3
    grid $fr1.l3 -row 0 -column 4
    
    frame $fwin.buts
    button $fwin.buts.ap -text [= {Apply Limits}] -command "GraphFromFile::go $can"
    button $fwin.buts.ac -text [= {Actualize}] -command "GraphFromFile::Actualize $can"
    button $fwin.buts.cl -text [= {Close}] -command "destroy $fwin"
    grid $fwin.buts -row 4 -column 0 -sticky nswe -padx 5 -pady 10
    grid $fwin.buts.ap -row 0 -column 0 -sticky nswe -padx 5
    grid $fwin.buts.ac -row 0 -column 1 -sticky nswe -padx 5
    grid $fwin.buts.cl -row 0 -column 2 -sticky nswe -padx 5
    
    grid columnconf $fwin 0 -weight 1
    grid rowconf $fwin 1 -weight 1
    grid columnconf $fr1 1 -weight 1
    grid columnconf $fr1 3 -weight 1
    
    bind $fr1.e1 <Return> "GraphFromFile::go $can"
    bind $fr1.e2 <Return> "GraphFromFile::go $can"
    
    bind $fwin <Configure> "GraphFromFile::go $can"
    
    update idletasks
    wm deicon $fwin
    
    upvar #0 [winfo name $fwin] data
}

proc GraphFromFile::goset { iset can } {
	set GraphFromFile::iset $iset
	GraphFromFile::go $can
}

proc GraphFromFile::kill {  } {
	variable fwin
	if { [winfo exists fwin] } {
		destroy $fwin
	}
}

proc GraphFromFile::Actualize { c } {
	if { [catch {
		GraphFromFile::ReadFCGraph
		GraphFromFile::go $c
	}] } {
		tk_dialogRAM .gid.tempwin {Error window} \
		        "[= {Error found}]. [= {Cannot actualize graph}]." error 0 OK
		$c create text 10 10 -anchor nw -justify left -font NormalFont -tags axestext \                
		                -text "[= {Error found}]. [= {Cannot actualize graph}]."
	}   
}

proc GraphFromFile::ReadFCGraph { } {
    variable file
    variable inixval
    variable endxval
    variable xval
    variable yval
    
#     set xval "" 
#     set yval ""
    
    # Se lee el archivo de datos para el gr�fico
    set fd [open $file r]
    set bb ""
    while { ![eof $fd] } {
	gets $fd aa
	if { [regexp {[0-9]} $aa ] } {
	    if { [llength $aa] < 2 } {
		close $fd
		return
	    }
	    lappend bb $aa
	}
    } 
    close $fd

    set xval "" 
    set yval ""

    for { set ir 0 } { $ir < [llength $bb] } { incr ir} {  
	set data [lindex $bb [expr $ir]] 
	lappend xval [lindex $data 0]
	lappend yval [lindex $data 1]
    }
    
    set inixval [lindex $xval 0] 
    set endxval [lindex $xval end]
    set endxval [lindex $xval end]
    set iniyval [lindex $yval 0] 
}

###################################################
# Table Editor
###################################################

namespace eval TableEditor {
    variable tabwidget
    variable codetype
    variable initdata
    
    proc InitTable { win data {fixed 50x20} {type "plain"} } {
	variable tabwidget
	variable codetype
	variable initdata

	package require fulltktable

	set initdata $data
	set codetype $type

	switch $codetype {
	    plain {
	    }
	    base64 {
		set data [TUI_decodebase64 $data]
	    }
	}
	set data [split $data "\n"]
	
	set thic [split [lindex $data 0] { }]
	set temp [split [lindex $data 1] { }]
	set data [lrange $data 2 end]

	set nrows [llength $temp] 
	set ncols [llength $thic]

	set tdata ""
	# First Row
	lappend tdata "0,0" ""
	for { set j 0 } { $j < $ncols } { incr j } {
	    lappend tdata "0,[expr $j+1]" [lindex $thic $j]
	}
	# Rest of the Rows
	for { set i 0 } { $i < $nrows } { incr i } {
	    lappend tdata "[expr $i+1],0" [lindex $temp $i]
	    for { set j 0 } { $j < $ncols } { incr j } {
		lappend tdata "[expr $i+1],[expr $j+1]" [lindex [lindex $data $i] $j]
	    }
	}
	# Let's create the table
	if { $fixed != "" } {
	    regexp {(.*)x(.*)} $fixed -> nrows ncols
	}
	set tabwidget [fulltktable::table $win -scrolling both -editwithtext "" \
		-rows [expr $nrows+1] -cols [expr $ncols+1] -height 6 -formulae 1 \
		-drawmode compatible -relief solid -bd 1 -highlightthickness 0 \
		-colstretchmode all]
	$win configure -sparsearray 0
	$win configure -titlecols 0 -titlerows 0

	# Fill table
	$win setcontents $tdata

	return $tabwidget
    }

    proc GetData { {type "plain"} } {
	variable tabwidget
	variable codetype
	variable initdata

	set tdata [$tabwidget givefullcontents]
	set thic ""
	set temp ""
	set ldata ""
	
	set nrows 0
	set ncols 0
	set length 0
	foreach "idx val" $tdata {
	    set i -1
	    set j -1
	    regexp {(.*),(.*)} $idx -> i j
	    if { $i==-1 | $j==-1 } {
		break
	    } elseif { $i==0 & $j==0 } {
		set i 0
	    } elseif { $i==0 } {
		if { $thic!="" } {
		    append thic " "
		}
		append thic $val
		incr ncols
	    } elseif { $j==0 } {
		if { $temp!="" } {
		    append temp " "
		}
		append temp $val
		incr nrows
	    } else {
		if { $ldata!="" } {
		    append ldata " "
		}
		lappend ldata $val
		incr length
	    }
	}
	# Let's check data
	if { $length != [expr $nrows*$ncols] } {
	    Warning [= {Wrong matrix data found in Table. New data will be ignored.}]
	    return $initdata
	}
	set data ""
	for { set i 0 } { $i < $nrows } { incr i } {
	    for { set j 0 } { $j < $ncols } { incr j } {
		append data [lindex $ldata [expr $i*$ncols+$j]]
		if { $j != [expr $ncols-1] } {
		    append data " "
		}
	    }
	    if { $i != [expr $nrows-1] } {
		append data "\n"
	    }
	}
	set data "$thic\n$temp\n$data"
   
	switch $codetype {
	    plain {
	    }
	    base64 {
		set data [TUI_encodebase64 $data]
	    }
	}
	return $data
    }
}

###################################################
# Time Table Window
###################################################

proc OpenTimeTableWindow { } {

    set title [= {Time Table}]
    set w .gid.timetable

    InitWindow $w $title PostTimeTableWindowGeom

    #text $w.t -xscrollcommand "$w.scrollbar#1 set" \
    #                -yscrollcommand "$w.scrollbar#2 set" -font FixedFont

    text $w.t -yscrollcommand "$w.scrollbar#2 set" -font FixedFont

    scrollbar $w.scrollbar#2 -command "$w.t yview" -orient v
    #scrollbar $w.scrollbar#1 -command "$w.t xview" -orient h
    button $w.close -text [= {Close}] -command "destroy $w"
    focus $w.close
    grid $w.t -row 1 -column 1 -sticky nesw
    grid $w.scrollbar#2 -row 1 -column 2 -sticky ns
    #grid $w.scrollbar#1 -row 2 -column 1 -sticky ew
    grid $w.close -row 3 -column 1 -rowspan 2 -pady 5
    grid rowconfigure $w 1 -weight 1 
    grid columnconfigure $w 1 -weight 1 

    # Determina el nombre del archivo
    set aa [.central.s info Project]
    set ProjectName [lindex $aa 1]
    if { [file extension $ProjectName] == ".gid" } {
    set ProjectName [file root $ProjectName]
    }
    set basename [file tail $ProjectName]

    if { $ProjectName == "UNNAMED" } {
	$w.t insert end [= {It is necessary to calculate to view these results}]
	return
    }
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
	set directory [file join [pwd] $directory]
    }
    set file [file join $directory $basename.flavia.tim]

    if { ![file exists $file] } {
	$w.t insert end [= {There are no results for this model}]
	return
    }
    set fd [open $file r]
    set bb ""
    while { ![eof $fd] } {
	gets $fd aa
	if { [regexp {[0-9]} $aa ] } {
	    append bb $aa\n
	}
    }
    if { $bb == "" } { set bb [= {Nothing at All}] }

    $w.t insert end $bb

    bind $w <Destroy> "catch [list close $fd]"
}

###################################################
# UTILIDAD DE LECTURA DE SUPERFICIE LIBRE
###################################################

proc ReadFreeSurfaceFromPrevious { {w .gid} } {
    set filename [Browser-ramR project read $w {Read free surface}] 
    if { $filename == "" } { return }
    set fileid [OpenFile "flavia.sat" $filename]
    if { $fileid =="" } {
	tk_dialogRAM $w.tmpwin {Error window} \
		[= {Cannot open sat file in %s} $filename] \
		error 0 OK 
	return 
    }
    CreateFreeSurfaceFromPrevious $fileid
}

proc CreateFreeSurfaceFromPrevious { fileid } {
    # Cambiamos el cursor y desactivamos la ventana gr�fica
    GraphicsOFF
    # Enviamos todas la entidades hacia atr�s
    .central.s process layer SendToBack Volumes 1: escape
    .central.s process layer SendToBack Surfaces 1: escape
    .central.s process layer SendToBack Lines 1: escape
    .central.s process layer SendToBack Points 1: escape
    # Leemos los puntos
    set readcontrol 0
    while { ![eof $fileid] } {
	set input [gets $fileid]
	if { [regexp {Frees} $input] } { 
	    set readcontrol 1
	    .central.s process escape escape escape escape Geometry Create Point
	    while { ![regexp {end frees} $input] } {
		set input [gets $fileid]
		.central.s process $input
	    } 
	}
    } 
    .central.s process escape escape escape escape
    if { $readcontrol==0 } {
	GraphicsON
	tk_dialogRAM .gid.tmpwin {Error window} \
		[= {Cannot find free surface data in file}] \
		error 0 OK
    } else {
    # Creamos la superficie
	.central.s process escape escape escape Geometry Create NurbsSurface\
		ByPoints 1: escape
    # Borramos los puntos
	.central.s process escape escape escape escape Geometry Delete \
		point 1: escape
    }
    # Traemos todas la entidades hacia delante
    .central.s process layer BringToFrontAll escape
    # Cambiamos el cursor y activamos la ventana gr�fica
    GraphicsON
}

###################################################
# UTILIDADES MANEJO DE UNIDADES
###################################################

proc ConvertVelocityUnitsToSI { system } {
    switch $system {
	"m/s"  { return 1.0 }
	"knot" { return 0.5144 }
	"cm/s" { return 1e-2 }
	"mm/s" { return 1e-3 }
	"mach" { return 331.46 }
    }
    WarnWin [= {Error, using an unknown magnitude '%s' for the velocity units} $system]
    return 1.0
}

proc ConvertTimeUnitsToSI { system } {
    switch $system {
	"s"    { return 1.0 }
	"cs"   { return 1e-2 }
	"ms"   { return 1e-3 }
	"min"  { return 60.0 }
	"hour" { return 3600.0 }
    }
    WarnWin [= {Error, using an unknown magnitude '%s' for the time units} $system]
    return 1.0
}

proc ConvertLengthUnitsToSI { system } {
    switch $system {
	"m"  { return 1.0 }
	"mm" { return 1e-3 }
	"cm" { return 1e-2 }
    }
    WarnWin [= {Error, using an unknown magnitude '%s' for the length units} $system]
    return 1.0 
}

###################################################
# UTILIDADES GEN�RICAS PARA USO CON GiD
###################################################
#
# Lee un archivo en el directorio dado y devuelve su indicador de lectura
#
proc OpenFile { ext dir } {

    # Comprueba los datos
    set ProjectName $dir
    if { [file extension $ProjectName] == ".gid" } {
	set ProjectName [file root $ProjectName]
    }
    if { $ProjectName == "UNNAMED" } { 
	return ""
    }
    set basename [file tail $ProjectName]
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
	set directory [file join [pwd] $directory]
    }
    set file [file join $directory $basename.$ext]
    if { ![file readable $file] } {
	return ""
    }
    return [open $file r]
#    set read ""
#    if { ![eof $fd] } {
#        gets $fd read
#    }
#    if {$read == ""} {
#        tk_dialogRAM .gid.tmpwin {Error window} \
#                "Sink and Trim Data file $basename.flavia.$ext is empty" error 0 OK 
#        return 0
#    }
#    return 1
}

#
# Copia un archivo desde el directorio inicial al directorio final
# Si enddir es nulo, utiliza el directorio actual
proc CopyFile { ext inidir {enddir ""}} {

    # Comprueba los datos
    set ProjectName $inidir
    if { [file extension $ProjectName] == ".gid" } {
	set ProjectName [file root $ProjectName]
    }
    if { $ProjectName == "UNNAMED" } { 
	return 0
    }
    set basename [file tail $ProjectName]
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
	set directory [file join [pwd] $directory]
    }
    set file [file join $directory $basename.$ext]
    if { ![file readable $file] } {
	return 0
    }
    # Busca el directorio actual
    if { $enddir == "" } {
	set info [.central.s info Project]
	set enddir [lindex $info 1]
	if { $enddir == "UNNAMED" } {
	    return 0
	}
	if { [file extension $enddir] != ".gid" } {
	    set enddir $enddir.gid
	}
	if { [file pathtype $enddir] == "relative" } {
	    set enddir [file join [pwd] $enddir]
	}
    }
    # Copia el archivo
    file copy -force $file $enddir
    return $enddir
}
#
# Borra una serie de archivos en el directorio actual
# data es una lista de extensiones
proc DeleteFiles { data } {

    set aa [.central.s info Project]
    set ProjectName [lindex $aa 1]
    if { $ProjectName == "UNNAMED" } { 
	return 0
    }
    if { [file extension $ProjectName] != ".gid" } {
	set base [file tail $ProjectName]
	set ProjectName $ProjectName.gid
    } else {
	set base [file root [file tail $ProjectName]]
    }
    set dir $ProjectName
    if { [file pathtype $dir] == "relative" } {
	set dir [file join [pwd] $dir]
    }
    foreach ext $data {
	catch {
	    file delete -force [file join $dir $base.$ext] 
	} res
    }
    return 1
}
#
# Borra una serie de archivos en el directorio actual
# data es una extensi�n del tipo flavia.*
proc ClearFiles { ext } {

    set aa [.central.s info Project]
    set ProjectName [lindex $aa 1]
    if { $ProjectName == "UNNAMED" } { 
	return 0
    }
    if { [file extension $ProjectName] != ".gid" } {
	set base [file tail $ProjectName]
	set ProjectName $ProjectName.gid
    } else {
	set base [file root [file tail $ProjectName]]
    }
    set dir $ProjectName
    if { [file pathtype $dir] == "relative" } {
	set dir [file join [pwd] $dir]
    }
    catch {
	foreach i [glob -dir $dir "$base.$ext"] {
	    file delete -force [file join $dir $i]  
	}
    } res
    return 1

}

# 
# Devuelve la capa a la que pertenece una entidad 
#    type: Points/Lines/Surfaces/Volumes/Nodes/Elements
#
proc GiveLayer { type number } {
    set ret ""
    if { ![catch {
	set retval [.central.s info list_entities $type $number]
    }] } {
	regexp -linestop -nocase {Layer: *(.*)} $retval {} ret
    }
    return $ret
} 
#
# Se crea una nueva capa. Si ya existe una capa y (ent == 1) con ese nombre se borra todo lo que 
# haya en esa la capa y se activa como capa a usar (si use == 1). 
#
proc CreateLayer { layer_name { ent 0 } { use 1 } } { 
    set layer_list [.central.s info layers]
    foreach layer [lrange $layer_name 0 end] {
	if {[lsearch -exact $layer_list $layer] == -1} {
	    .central.s process escape escape escape escape utilities layer new $layer
	} else {
	    if { $ent == 1 } {
		DeleteLayer $layer 1
		if { ![ExistsLayer $layer] } {
		    .central.s process escape escape escape escape utilities layer new $layer
		}
	    }
	    if { $use == 1 } {
		.central.s process escape escape escape escape utilities layer touse $layer
	    }
	}
    }
}
#
# Se elimina una capa y su contenido (si ent == 1).
#
proc DeleteLayer { layer_name { ent 0 } } {
    set layer_list [.central.s info layers]
    set ent_type {list volume surface line point}
    if { $ent == 1 } {
	foreach type [lrange $ent_type 0 end] {
	    foreach layer [lrange $layer_name 0 end] {
		if {[lsearch -exact $layer_list $layer] != -1} {
		    .central.s process escape escape escape escape Geometry \
		            delete $type layer:$layer escape
		}
	    }
	}
    }
    foreach layer [lrange $layer_name 0 end] {
	if {[lsearch -exact $layer_list $layer] != -1} {
	    .central.s process escape escape escape escape utilities layer delete $layer
	}
    }
}
#
# Se mueve el contenido de una capa a otra. La vac�a se activa. (Si ent == 1 tambi�n cambia de capa los elementos y nodos)
#
proc MoveToLayer {layer_ini layer_fin { ent 0 } } {
    set layer_list [.central.s info layers]
    if {[lsearch -exact $layer_list $layer_fin] == -1} {
	if {[lsearch -exact $layer_list $layer_ini] == -1} { return }
	.central.s process escape escape escape escape utilities layer new $layer_fin
    } 
    if {[lsearch -exact $layer_list $layer_ini] == -1} { 
	.central.s process escape escape escape escape utilities layer new $layer_ini
    } else {
#   Error en GiD: lo correcto ser�a  utilities layer entities $layer_fin all layer:$layer_ini
	.central.s process escape escape escape escape utilities layer entities \
		$layer_fin points layer:$layer_ini
	.central.s process escape escape escape escape utilities layer entities \
		$layer_fin lines layer:$layer_ini        
	.central.s process escape escape escape escape utilities layer entities \
		$layer_fin surfaces layer:$layer_ini
	.central.s process escape escape escape escape utilities layer entities \
		$layer_fin volumes layer:$layer_ini
	if {$ent == 1} {
	    .central.s process escape escape escape escape utilities layer entities \
		$layer_fin elements layer:$layer_ini
	    .central.s process escape escape escape escape utilities layer entities \
		$layer_fin nodes layer:$layer_ini
	}
	.central.s process escape escape escape escape utilities layer touse $layer_ini
	
    }
}
#
# Se introducen en una capa las entidades de menor orden pertenencientes a las que ya est�n en la capa.
#
proc MoveLowerToLayer {layer_name} { 
    set layer_list [.central.s info layers]
    foreach layer [lrange $layer_name 0 end] {
	if {[lsearch -exact $layer_list $layer] != -1} {
	    .central.s process escape escape escape escape utilities layer entities $layer \
		    LowerEntities volumes layer:$layer
	    .central.s process escape escape escape escape utilities layer entities $layer \
		    LowerEntities surfaces layer:$layer
	    .central.s process escape escape escape escape utilities layer entities $layer \
		    LowerEntities lines layer:$layer    
	}
    }
}
#
# Se activa una capa. Si no existe se crea. 
#
proc ToUseLayer {layer_name} {
    set layer_list [.central.s info layers]
    if {[lsearch -exact $layer_list $layer_name] == -1} {
	.central.s process escape escape escape escape utilities layer new $layer_name
    } else {
	.central.s process escape escape escape escape utilities layer touse $layer_name
    }
}
#
# Comprueba si existe una capa
#
proc ExistsLayer {layer_name} {
    if { $layer_name=="" } { return 0 }
    set layer_list [.central.s info layers]
    if {[lsearch -exact $layer_list $layer_name] == -1} {
	return 0
    } else {
	return 1
    }
}
#
# Comprueba si existen entidades (geom�tricas) en una capa o varias
#
proc IsLayerEmpty {layer_name {entities "all"} } {
    set layer_list [.central.s info layers]
    set entities_list ""
    foreach layer [lrange $layer_name 0 end] {
	if {[lsearch -exact $layer_list $layer] != -1} {
	    if { $entities == "all" } {
		append entities_list [.central.s info layers -entities points   $layer_name]
		append entities_list [.central.s info layers -entities lines    $layer_name]
		append entities_list [.central.s info layers -entities surfaces $layer_name]
		append entities_list [.central.s info layers -entities volumes  $layer_name]
		if { $entities_list != "" } { return 0 }
	    } else { 
		foreach entity [lrange $entities 0 end] {
		    set entities_list [.central.s info layers -entities $entity $layer_name]
		    if { $entities_list != "" } { return 0 }
		}
	    }
	}
    }
    return 1
}
#
#  Env�a todas las entidades de una capa hacia atr�s
#
proc SendAllToBack { {layer "all"} } {
    if { $layer=="all" } {
	.central.s process escape escape escape utilities layer SendToBack Volumes 1: escape
	.central.s process escape escape escape utilities layer SendToBack Surfaces 1: escape
	.central.s process escape escape escape utilities layer SendToBack Lines 1: escape
	.central.s process escape escape escape utilities layer SendToBack Points 1: escape
    } else {
	.central.s process escape escape escape utilities layer SendToBack Volumes $layer escape
	.central.s process escape escape escape utilities layer SendToBack Surfaces $layer escape
	.central.s process escape escape escape utilities layer SendToBack Lines $layer escape
	.central.s process escape escape escape utilities layer SendToBack Points $layer escape
    }
}
#
#  Trae todas las entidades hacia delante
#
proc BringAllToFront { } { 
    set layer_list [.central.s info layers]
    foreach layer [lrange $layer_name 0 end] {
	.central.s process escape escape escape utilities layers bringtofront $layer
    }
}
#
# Devuelve las caracter�sticas del paralelep�pedo de contorno de una capa o varias
#
proc LayerLength { {layer_name "all"} {type "D"} } {
    if { $layer_name == "all" || $layer_name == "" } { 
	set layer_name [.central.s info layers]
    }
    if { [catch {
	    set points [lindex [eval .central.s info layers -bbox $layer_name] 0]
	}] } {
	return 0
    }
    set x1 [expr double([lindex $points 0])]
    set y1 [expr double([lindex $points 1])]
    set z1 [expr double([lindex $points 2])]
    set x2 [expr double([lindex $points 3])]
    set y2 [expr double([lindex $points 4])]
    set z2 [expr double([lindex $points 5])]
    set xc [expr 0.5*($x1+$x2)]
    set yc [expr 0.5*($y1+$y2)]
    set zc [expr 0.5*($z1+$z2)]
    switch $type {
	X  { return [expr abs($x1-$x2)] }
	Y  { return [expr abs($y1-$y2)] }
	Z  { return [expr abs($z1-$z2)] }        
	XD { return [list $x1 [expr abs($x1-$x2)]] }
	YD { return [list $y1 [expr abs($y1-$y2)]] }
	ZD { return [list $z1 [expr abs($z1-$z2)]] }
	D  { return [expr sqrt(($x1-$x2)*($x1-$x2)+\
		($y1-$y2)*($y1-$y2)+($z1-$z2)*($z1-$z2))] }
	C  { return [list $xc $yc $zc] }
	XC { return $xc }
	YC { return $yc }
	ZC { return $zc }
	XDIST { return [expr sqrt(($y1-$y2)*($y1-$y2)+($z1-$z2)*($z1-$z2))] }
	YDIST { return [expr sqrt(($x1-$x2)*($x1-$x2)+($z1-$z2)*($z1-$z2))] }
	ZDIST { return [expr sqrt(($x1-$x2)*($x1-$x2)+($y1-$y2)*($y1-$y2))] }
	MINX {
	    if { $x1>$x2 } { return $x2 }
	    return $x1
	}
	MINY {
	    if { $y1>$y2 } { return $y2 }
	    return $y1
	}
	MINZ {
	    if { $z1>$z2 } { return $z2 }
	    return $z1
	}
	MAXX {
	    if { $x1<$x2 } { return $x2 }
	    return $x1
	}
	MAXY {
	    if { $y1<$y2 } { return $y2 }
	    return $y1
	}
	MAXZ {
	    if { $z1<$z2 } { return $z2 }
	    return $z1
	}
    }
    return [list [expr abs($x1-$x2)] [expr abs($y1-$y2)] \
	    [expr abs($z1-$z2)]]
}
#
# Se asignan tama�os a todas las entidades de una capa.
#
proc AssignSizeLayer {layer_name size} {
    if { [ExistsLayer $layer_name] } {
	.central.s process escape escape escape escape Meshing AssignSizes Points $size layer:$layer_name
	.central.s process escape escape escape escape Meshing AssignSizes Lines $size layer:$layer_name
	 .central.s process escape escape escape escape Meshing AssignSizes Surfaces $size layer:$layer_name
	.central.s process escape escape escape escape Meshing AssignSizes Volumes $size layer:$layer_name
	.central.s process escape escape escape escape
    }
} 
#
# Se asignan tama�os a las entidades de una capa si la entidad no tiene asignada una inferior.
#
proc AssignSmallerSizeLayer { layer_name size {entity Surfaces} } {
    if { [ExistsLayer $layer_name] } {
	set info [.central.s info list_entities $entity layer:$layer_name]
	set infoindx [regexp -inline -all -line {Num:\s*(.*)\s+Higher} $info]
#        set infosize [regexp -inline -all -line {size=(.*)\s+Meshing} $info]
	set infosize [regexp -inline -all -line {size=(.*)\s} $info]
	set len [llength $info]
	for { set i 1 } { $i < $len } { incr i 2 } {
	    set oldsize [lindex $infosize $i]
	    if { $size < $oldsize || $oldsize == 0.0 } {
		.central.s process escape escape escape escape Meshing \
		    AssignSizes $entity $size [lindex $infoindx $i]
	    }
	}
    }
} 
# Devuelve el tama�o asignado a una entidad (entity puede ser points, lines,
# surfaces o volumes)
proc GiveEntitySize { id { entity points } } {
    set info [lindex [regexp -inline -line {Meshing Info: (.*)} [.central.s info list_entities $entity $id]] end]
    set ret [lindex [regexp -inline -all -line {size=[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?} $info] 1]
    if { $ret == "" || ![string is double -strict $ret]} {
	WarnWin "Cannot change mesh size of $entity $id"
	return 0.0
    }
    return $ret
}
# 
#  Indica si ya hay malla generada, y el tipo de malla (estruct VS noEstruct)
# 
proc CheckMesh { id { entity points } } {
    variable flagMesh1 
    variable flagMesh2 
    variable meshDef

    set meshYes -1
    set meshStr -1

    set infoStr [.central.s info list_entities $entity $id]
    
    set meshYes [lsearch $infoStr "Meshing"]
    set meshStr [lsearch $infoStr "IsStructured=1"]

    if {$meshYes != -1} {
	set flagMesh1 1
	set meshDef [lindex $infoStr 18]
    } else {
	set flagMesh1 0
    }
    if {$meshStr != -1} {
	set flagMesh2 1
    } else {
	set flagMesh2 0
    }

}

# Se asignan tama�os para mallado a distintas entidades
#
proc AssignSizePoints {size points} {
    .central.s process escape escape escape escape Meshing \
	    AssignSizes Points $size $points escape
}
proc AssignSizeLinesAndLower {size lines} {
    .central.s process escape escape escape escape Meshing \
	    AssignSizes Lines $size $lines escape escape escape 
    foreach line [lrange $lines 0 end] {
	set retval [.central.s info list_entities lines $line] 
	set points [regexp -linestop -all -inline {Points:([ 0-9]*)} $retval]
	for { set i 1 } { $i < [llength $points] } { incr i 2 } {
	    AssignSizePoints $size [lindex $points $i]
	}
    }
} 
proc AssignSizeSurfacesAndLower {size surfaces} {
    .central.s process escape escape escape escape Meshing \
	    AssignSizes Surfaces $size $surfaces escape escape escape 
    foreach surface [lrange $surfaces 0 end] {
	set retval [.central.s info list_entities surfaces $surface] 
	set lines [regexp -linestop -all -inline {Line:([ 0-9]*)} $retval]
	for { set i 1 } { $i < [llength $lines] } { incr i 2 } {
	    AssignSizeLinesAndLower $size [lindex $lines $i]
	}
    }
} 
proc AssignSizeVolumesAndLower {size volumes} {
    .central.s process escape escape escape escape Meshing \
	    AssignSizes Volumes $size $volumes escape escape escape 
    foreach volume [lrange $volumes 0 end] {
	set retval [.central.s info list_entities volumes $volume] 
	set surfaces [regexp -linestop -all -inline {Surface:([ 0-9]*)} $retval]
	for { set i 1 } { $i < [llength $surfaces] } { incr i 2 } {
	    AssignSizeSurfacesAndLower $size [lindex $surfaces $i]
	}
    }
} 
#
# Calcula un tama�o de una l�nea en funci�n de un error cordal
# num: �ndice de la l�nea
# cordalerror: error cordal
#
proc CalcSizeByCordalError { num cordalerror } {
    
    set retval [.central.s info list_entities -more Lines $num]
    regexp {Length=[ ]*([0-9.]*)[ ]*Radius=([0-9.]*)} $retval {} length radius
       
    if { $radius < 0 || $radius >= 1e5  } { 
	set radius Inf.
    }
    if { $cordalerror < 0 || $cordalerror > 1e5 } {
	set cordalerror .1
    }

    if { $radius == "Inf." } {
	set NumberOfElems 1
	set size 1e5
    } else {
	set CE $cordalerror
	set R $radius
	set size [expr 2.0*sqrt(2*$R*$CE-$CE*$CE)]
	if { $size == 0 } {
	    set size 0.1
	    set NumberOfElems 1
	} else { set NumberOfElems [expr int($length/$size)] }
	if { $NumberOfElems < $length } { set NumberOfElems 1 }
    }
    return $size
}
#
# Busca una linea (en una capa) que est� limitada por los 2 puntos cuyos �ndices son los dados
#
proc SearchLine {point1 point2 {layer ""} } {
    if { [ExistsLayer $layer] } {
	set lines [.central.s info list_entities lines layer:$layer]
    } else {
	set lines [.central.s info list_entities lines 1:2147483647]
    }
    set lines [regexp -linestop -all -inline {Num: ([0-9]*)} $lines]
    if { [llength $lines]<2 } { return "" }
    for { set i 1 } { $i < [llength $lines] } { incr i 2 } {
	set line [lindex $lines $i]
	if { $line > 0 } {
	    set retval [.central.s info list_entities lines $line] 
	    set points [lindex [regexp -linestop -inline {Points: ([ 0-9]*)} $retval] 1] 
	    if { [lsearch $points $point1]!=-1 && [lsearch $points $point2]!=-1 } {
		return $line
	    }
	}
    }
    return ""
}
#
# Devuelve todos las puntos de una capa
#
proc GivePoints { {layer ""} } {
    if { [ExistsLayer $layer] } {
	set points [.central.s info list_entities points layer:$layer]
    } else {
	set points [.central.s info list_entities points 1:2147483647]
    }
    set points [regexp -linestop -all -inline {Num: ([0-9]*)} $points]
    if { [llength $points]<2 } { return "" } 
    set ret ""
    for { set i 1 } { $i < [llength $points] } { incr i 2 } {
	lappend ret [lindex $points $i]
    }
    return $ret
}
#
# Devuelve todas las lineas de una capa
#
proc GiveLines { {layer ""} } {
    if { [ExistsLayer $layer] } {
	set lines [.central.s info list_entities lines layer:$layer]
    } else {
	set lines [.central.s info list_entities lines 1:2147483647]
    }
    set lines [regexp -linestop -all -inline {Num: ([0-9]*)} $lines]
    if { [llength $lines]<2 } { return "" } 
    set ret ""
    for { set i 1 } { $i < [llength $lines] } { incr i 2 } {
	lappend ret [lindex $lines $i]
    }
    return $ret
}
#
# Devuelve todas las superf�cies de una capa
#
proc GiveSurfaces { {layer ""} } {
    if { [ExistsLayer $layer] } {
	set surfaces [.central.s info list_entities surfaces layer:$layer]
    } else {
	set surfaces [.central.s info list_entities surfaces 1:2147483647]
    }
    set surfaces [regexp -linestop -all -inline {Num: ([0-9]*)} $surfaces]
    set ret ""
    if { [llength $surfaces]<2 } { return "" } 
    set ret ""
    for { set i 1 } { $i < [llength $surfaces] } { incr i 2 } {
	lappend ret [lindex $surfaces $i]
    }
    return $ret
}
#
# Devuelve todos los vol�menes de una capa
#
proc GiveVolumes { {layer ""} } {
    if { [ExistsLayer $layer] } {
	set volumes [.central.s info list_entities volumes layer:$layer]
    } else {
	set volumes [.central.s info list_entities volumes 1:2147483647]
    }
    set volumes [regexp -linestop -all -inline {Num: ([0-9]*)} $volumes]
    set ret ""
    if { [llength $volumes]<2 } { return "" } 
    set ret ""
    for { set i 1 } { $i < [llength $volumes] } { incr i 2 } {
	lappend ret [lindex $volumes $i]
    }
    return $ret
}
#
# Busca una linea (cualquiera) en una capa
#
proc GiveOneLine { {layer ""} } {
    if { [ExistsLayer $layer] } {
	set lines [.central.s info list_entities lines layer:$layer]
    } else {
	set lines [.central.s info list_entities lines 1:2147483647]
    }
    set lines [regexp -linestop -all -inline {Num: ([0-9]*)} $lines]
    if { [llength $lines]>1 } {
	return [lindex $lines 1]
    }
    return ""
}
#
# Busca una superficie (cualquiera) en una capa
#
proc GiveOneSurface { {layer ""} } {
    if { [ExistsLayer $layer] } {
	set surfaces [.central.s info list_entities surfaces layer:$layer]
    } else {
	set surfaces [.central.s info list_entities surfaces 1:2147483647]
    }
    set surfaces [regexp -linestop -all -inline {Num: ([0-9]*)} $surfaces]
    if { [llength $surfaces]>1 } {
	return [lindex $surfaces 1]
    }
    return ""
}
#
# Calcula la Distancia entre dos puntos
#
proc Distance { p1 p2 } {
    set x1 [expr double([lindex $p1 0])]
    set y1 [expr double([lindex $p1 1])]
    set z1 [expr double([lindex $p1 2])]
    set x2 [expr double([lindex $p2 0])]
    set y2 [expr double([lindex $p2 1])]
    set z2 [expr double([lindex $p2 2])]
    set dist [expr sqrt(($x2-$x1)*($x2-$x1)+($y2-$y1)*($y2-$y1)+($z2-$z1)*($z2-$z1))]
    return $dist
}
#
# Busca los puntos (en una capa) que est�n en una esfera que se define por un punto y un radio
#
proc SearchPointInSphere { center radius {layer ""} } {
    if { [ExistsLayer $layer] } {
	set points [.central.s info list_entities points layer:$layer]
    } else {
	set points [.central.s info list_entities points 1:2147483647]
    }
    set points [regexp -linestop -all -inline {Num: ([0-9]*)} $points] 
    set foundpoints ""        
    set x1 [expr double([lindex $center 0])]
    set y1 [expr double([lindex $center 1])]
    set z1 [expr double([lindex $center 2])]
    for { set i 1 } { $i < [llength $points] } { incr i 2 } {
	set pntidx [lindex $points $i]
	set point [lindex [.central.s info Coordinates $pntidx] 0]
	set xA [expr double([lindex $point 0])]
	set yA [expr double([lindex $point 1])]
	set zA [expr double([lindex $point 2])]
	set dist [expr sqrt(($xA-$x1)*($xA-$x1)+($yA-$y1)*($yA-$y1)+($zA-$z1)*($zA-$z1))]
	if { $dist <= $radius } {
	    lappend foundpoints $pntidx
	}
    }
    return $foundpoints
}
#
# Busca los puntos (en una capa) que est�n en un cilindro OZ que se define por un punto, 
# un radio y una altura
#
proc SearchPointInOZCylinder { center radius layer {height -1}} {
    if { [ExistsLayer $layer] } {
	set points [.central.s info list_entities points layer:$layer]
    } else {
	set points [.central.s info list_entities points 1:2147483647]
    }
    set points [regexp -linestop -all -inline {Num: ([0-9]*)} $points]
    set foundpoints ""        
    set x1 [expr double([lindex $center 0])]
    set y1 [expr double([lindex $center 1])]
    set z1 [expr double([lindex $center 2])]
    for { set i 1 } { $i < [llength $points] } { incr i 2 } {
	set pntidx [lindex $points $i]
	set point [lindex [.central.s info Coordinates $pntidx] 0]
	set xA [expr double([lindex $point 0])]
	set yA [expr double([lindex $point 1])]
	set zA [expr double([lindex $point 2])]
	set dist [expr sqrt(($xA-$x1)*($xA-$x1)+($yA-$y1)*($yA-$y1))]
	set zdst [expr abs($z1-$zA)]
	if { $dist<=$radius && $height < 0.0 } {
	    lappend foundpoints $pntidx
	} elseif { $dist<=$radius && $zdst<=$height } {
	    lappend foundpoints $pntidx
	}
    }
    return $foundpoints
}
#
# Busca los puntos (en una capa) que est�n en la caja que se define por los dos puntos 
# y una tolerancia
#
proc SearchPointInBox {point1 point2 tol {layer ""} } {
    if { [ExistsLayer $layer] } {
	set points [.central.s info list_entities points layer:$layer]
    } else {
	set points [.central.s info list_entities points 1:2147483647]
    }
    set points [regexp -linestop -all -inline {Num: ([0-9]*)} $points] 
    set foundpoints ""        
    set x1 [expr double([lindex $point1 0])] 
    set y1 [expr double([lindex $point1 1])]
    set z1 [expr double([lindex $point1 2])] 
    set x2 [expr double([lindex $point2 0])] 
    set y2 [expr double([lindex $point2 1])] 
    set z2 [expr double([lindex $point2 2])] 
    if { $x1 > $x2 } { set tmp $x1; set x1 $x2; set x2 $tmp; }
    if { $y1 > $y2 } { set tmp $y1; set y1 $y2; set y2 $tmp; }
    if { $z1 > $z2 } { set tmp $z1; set z1 $z2; set z2 $tmp; }
    set x1 [expr $x1-$tol]; set x2 [expr $x1+$tol];
    set y1 [expr $y1-$tol]; set y2 [expr $y1+$tol];
    set z1 [expr $z1-$tol]; set z2 [expr $z1+$tol];
    for { set i 1 } { $i < [llength $points] } { incr i 2 } {
	set pntidx [lindex $points $i]
	set point [lindex [.central.s info Coordinates $pntidx] 0]
	set xA [expr double([lindex $point 0])]
	set yA [expr double([lindex $point 1])]
	set zA [expr double([lindex $point 2])]
	if { $xA>=$x1 && $yA>=$y1 && $zA>=$z1 && $xA<=$x2 && $yA<=$y2 && $zA<=$z2 } {
	    lappend foundpoints $pntidx
	}
    }
    return $foundpoints
}
#
# Busca l�neas (en una capa) cuyos puntos extremos est�n en la caja que se define por los dos puntos 
# y una tolerancia
#
proc SearchLineInBox {point1 point2 tol {layer ""} } {
    if { [ExistsLayer $layer] } {
	set lines [.central.s info list_entities lines layer:$layer]
    } else {
	set lines [.central.s info list_entities lines 1:2147483647]
    }    
    set x1 [expr double([lindex $point1 0])] 
    set y1 [expr double([lindex $point1 1])]
    set z1 [expr double([lindex $point1 2])] 
    set x2 [expr double([lindex $point2 0])] 
    set y2 [expr double([lindex $point2 1])] 
    set z2 [expr double([lindex $point2 2])] 
    if { $x1 > $x2 } { set tmp $x1; set x1 $x2; set x2 $tmp; }
    if { $y1 > $y2 } { set tmp $y1; set y1 $y2; set y2 $tmp; }
    if { $z1 > $z2 } { set tmp $z1; set z1 $z2; set z2 $tmp; }
    set x1 [expr $x1-$tol]; set x2 [expr $x2+$tol];
    set y1 [expr $y1-$tol]; set y2 [expr $y2+$tol];
    set z1 [expr $z1-$tol]; set z2 [expr $z2+$tol];
    set foundlines ""
    set lines [regexp -linestop -all -inline {Num: ([0-9]*)} $lines]
    for { set i 1 } { $i < [llength $lines] } { incr i 2 } {
	set line [lindex $lines $i]
	if { $line > 0 } {
	    set retval [.central.s info list_entities lines $line] 
	    set points [lindex [regexp -linestop -inline {Points: ([ 0-9]*)} $retval] 1]
	    set pointA [lindex [.central.s info Coordinates [lindex $points 0]] 0]
	    set pointB [lindex [.central.s info Coordinates [lindex $points 1]] 0]
	    set xA [expr double([lindex $pointA 0])]
	    set yA [expr double([lindex $pointA 1])]
	    set zA [expr double([lindex $pointA 2])] 
	    set xB [expr double([lindex $pointB 0])]
	    set yB [expr double([lindex $pointB 1])]
	    set zB [expr double([lindex $pointB 2])]
	    if { $xA>=$x1 && $xB>=$x1 && $yA>=$y1 && $yB>=$y1 && $zA>=$z1 && $zB>=$z1 && \
		    $xA<=$x2 && $xB<=$x2 && $yA<=$y2 && $yB<=$y2 && $zA<=$z2 && $zB<=$z2 } {
		lappend foundlines $line
	    }
	}
    }
    return $foundlines
}
#
# Busca l�neas (en una capa) cuyos puntos extremos est�n en la caja que se define por los dos puntos 
# y una tolerancia
#
proc SearchLineInOYPlane {OYplane tol {layer ""} } {
    if { [ExistsLayer $layer] } {
	set lines [.central.s info list_entities lines layer:$layer]
    } else {
	set lines [.central.s info list_entities lines 1:2147483647]
    }    
    set y1 [expr double([lindex $OYplane 1])]; set y2 [expr double([lindex $OYplane 1])];
    if { $y1 > $y2 } { set tmp $y1; set y1 $y2; set y2 $tmp; }
    set y1 [expr $y1-$tol]; set y2 [expr $y2+$tol];
    set foundlines ""
    set lines [regexp -linestop -all -inline {Num: ([0-9]*)} $lines]
    for { set i 1 } { $i < [llength $lines] } { incr i 2 } {
	set line [lindex $lines $i]
	if { $line > 0 } {
	    set retval [.central.s info list_entities lines $line] 
	    set points [lindex [regexp -linestop -inline {Points: ([ 0-9]*)} $retval] 1]
	    set pointA [lindex [.central.s info Coordinates [lindex $points 0]] 0]
	    set pointB [lindex [.central.s info Coordinates [lindex $points 1]] 0]
	    set yA [expr double([lindex $pointA 1])]; set yB [expr double([lindex $pointB 1])];
	    if { $yA>=$y1 && $yB>=$y1 && $yA<=$y2 && $yB<=$y2 } {
		lappend foundlines $line
	    }
	}
    }
    return $foundlines
}
#
# Se calcula un vector normalizado, a partir de dos �ndices de puntos
#
proc NormVector { pnt1 pnt2 } {
    set pointA [lindex [.central.s info Coordinates $pnt1] 0]
    set pointB [lindex [.central.s info Coordinates $pnt2] 0]
    set x [expr [expr double([lindex $pointB 0])]-[lindex $pointA 0]]
    set y [expr [expr double([lindex $pointB 1])]-[lindex $pointA 1]]
    set z [expr [expr double([lindex $pointB 2])]-[lindex $pointA 2]]
    set norm [expr sqrt($x*$x+$y*$y+$z*$z)]
    if { $norm == 0 } { return "" }
    set x [expr $x/$norm]
    set y [expr $y/$norm]
    set z [expr $z/$norm]
    return "$x $y $z"
}
#
# Se crea una lista con todos los puntos de una lista de l�neas (se excluyen los repetidos)
#
proc ListPointsFromLines { lines } {
    set ret_list ""
    for { set i 0 } { $i < [llength $lines] } { incr i } {
	set line [lindex [lindex $lines $i] 0]
	set retval [.central.s info list_entities lines $line] 
	set points [regexp -linestop -all -inline {Points:([ 0-9]*)} $retval]
	for { set j 1 } { $j < [llength $points] } { incr j 2 } {
	    set pnt1 [lindex [lindex $points $j] 0]
	    set pnt2 [lindex [lindex $points $j] 1]
	    if { [lsearch $ret_list $pnt1 ]==-1 } { lappend ret_list $pnt1 }
	    if { [lsearch $ret_list $pnt2 ]==-1 } { lappend ret_list $pnt2 }
	}
    } 
    return $ret_list
}
#
# Se crea una lista con todas los l�neas de una lista de superficies (se excluyen las repetidas)
#
proc ListLinesFromSurfaces { surfaces } {
    set ret_list ""
    for { set i 0 } { $i < [llength $surfaces] } { incr i } {
	set surface [lindex [lindex $surfaces $i] 0]
	set retval [.central.s info list_entities surfaces $surface] 
	set lines [regexp -linestop -all -inline {Line:([ 0-9]*)} $retval]
	for { set j 1 } { $j < [llength $lines] } { incr j 2 } {
	    set line [lindex $lines $j]
	    if { [lsearch $ret_list $line ]==-1 } { lappend ret_list $line }
	}
    } 
    return $ret_list
}
#
# Se asignan tama�os a todas las entidades de una capa.
#
proc AssignMeshCriteriaLayer {layer_name {ms Mesh}} {
    if { [ExistsLayer $layer_name] } {
	.central.s process escape escape escape escape Meshing MeshCriteria $ms Points layer:$layer_name
	.central.s process escape escape escape escape Meshing MeshCriteria $ms Lines layer:$layer_name
	 .central.s process escape escape escape escape Meshing MeshCriteria $ms Surfaces layer:$layer_name
	.central.s process escape escape escape escape Meshing MeshCriteria $ms Volumes layer:$layer_name
	.central.s process escape escape escape escape
    }
}  
#
# Se asigna una condici�n a todas las entidades de una capa. Para ello asigna los valores pertinentes a los campos.
#
proc AssignConditionToLayer {layer_name cond { value "" }} {
    if { [ExistsLayer $layer_name] } {
	if { $value != "" } {
	    .central.s process escape escape escape escape Data Conditions AssignCond $cond change
	     foreach ivalue [lrange $value 0 end] {
		.central.s process $ivalue
	    }
	    .central.s process layer:$layer_name escape
	} else {
	    .central.s process escape escape escape escape Data Conditions AssignCond \
		    $cond layer:$layer_name escape
	}
    }
} 
#
# Se asigna un material a una capa.
#
proc AssignMaterialToLayer {layer_name material entity} {
    if { [ExistsLayer $layer_name] && [ExistsMaterial $material] } {
	.central.s process escape escape escape escape Data Materials AssignMaterial \
		$material $entity layer:$layer_name escape
    }
}  
#
# Se desasignan todas las condiciones de contorno.
#
proc UnAssignConditions {} {
    .central.s process escape escape escape escape Data Conditions UnAssign Yes escape
}  
#
# Se desasignan todos los materiales
#
proc UnAssignMaterials {} {
    .central.s process escape escape escape escape Data Materials UnAssign Yes escape
} 
#
# Comprueba si existe un material
#
proc ExistsMaterial { mat } {
    if { $mat=="" } { return 0 }
    set mats_list [.central.s info materials]
    if {[lsearch -exact $mats_list $mat] == -1} {
	return 0
    } else {
	return 1
    }
}  
#
# Se crea un nuevo material y se editan algunos campos
# Nota: Se elimina el material con el nombre $newmat si existe
#
proc CreateMaterial { mat newmat {field ""} {value ""} } {
    if { ![ExistsMaterial $mat] } { return } 
    if { [ExistsMaterial $newmat] } { 
	.central.s process escape escape escape escape data \
		materials deletematerial $newmat escape
    } 
    # lee los datos del material
    set input [.central.s info materials $mat]
    set NumFields [lindex $input 0]
    set NameList ""
    set ValueList ""
    for { set i 0 } { $i < $NumFields } { incr i 1 } {
	lappend NameList [lindex $input [expr $i*2+1]]
	lappend ValueList [lindex $input [expr $i*2+2]]
    }
    # cambia los datos del material
    if { $value != "" } {
	foreach ifield [lrange $field 0 end] {
	    set idxold [lsearch -glob $NameList $ifield*]
	    set idxnew [lsearch -exact $field $ifield]
	    if { $idxold!=-1 && $idxnew!=-1 } {
		set NewValue [lindex $value $idxnew] 
	       #set OldValue [lindex $ValueList $idxold]
		set ValueList [lreplace $ValueList $idxold $idxold $NewValue]
	    } 
	}
	set output "" 
	foreach i $ValueList {
	    append output "$i "
	}
	.central.s process escape escape escape escape data \
		materials newmaterial $mat $newmat $output
    } else {
	.central.s process escape escape escape escape data \
		materials newmaterial $mat $newmat $input
    }
}  
#
# Se cambian valores de los datos del problema
#
proc EditProblemData { field value } {
    set NumFields [llength $field]
     for { set i 0 } { $i < $NumFields } { incr i 1 } {
	 set ifield [lindex $field $i]
	 set ivalue [lindex $value $i]
	GiD_Process escape escape escape escape Data ProblemData -SingleField- \
		$ifield $ivalue escape escape escape escape 
    } 
} 
#
# Se dibuja una linea dados los �ndices de los puntos existentes
#
proc DrawLineByPoints { pntA pntB } {
    .central.s process escape escape escape escape geometry create line $pntA old
    .central.s process $pntB old escape
}
#
# Se dibuja una linea dados los �ndices de los puntos existentes
#
proc DrawLineByIndex { pntA pntB } {
    .central.s process escape escape escape escape geometry create \
	line join $pntA $pntB escape
}
#
# Lee una imagen de un archivo
#
proc imagefromtdyn { name } {
    global ProblemTypePriv
    if { ![info exist ProblemTypePriv(image-$name)] } {
	set ProblemTypePriv(image-$name) [image create photo -file \
		[file join $ProblemTypePriv(problemtypedir) images $name]]
    }
    return $ProblemTypePriv(image-$name)
}
#
# Deshabilita la ventana gr�fica de GiD y pone el cursor en espera
#
proc GraphicsOFF { } {
    .gid conf -cursor watch
    .central.s waitstate 1
    update 
    .central.s disable windows 1
    .central.s disable graphics 1
}
#
# Habilita la ventana gr�fica de GiD y pone el cursor en activo
#
proc GraphicsON { } {
    .central.s disable windows 0
    .central.s disable graphics 0
    .central.s process escape escape escape zoom frame escape  
    .gid conf -cursor ""
    .central.s waitstate 0
}

proc RemoveMenuOptionIfExists {menu_name option_name prepost} { 
    global MenuNames MenuEntries MenuCommands MenuAcceler
    global MenuNamesP MenuEntriesP MenuCommandsP MenuAccelerP
    
    if {$prepost!="PRE" && $prepost!="POST" && $prepost!="PREPOST"} {  
	return -code error "[= {Wrong arg. Must be PRE, POST or PREPOST}]."
    }
    
    if {$prepost=="PRE" || $prepost=="PREPOST"} {
	set ipos [lsearch $MenuNames $menu_name]
	if { $ipos != -1 } {
	    set jpos [lsearch $MenuEntries($ipos) $option_name]
	    if { $jpos != -1 } {
		set MenuEntries($ipos)  [lreplace $MenuEntries($ipos) $jpos  $jpos]
		set MenuCommands($ipos) [lreplace $MenuCommands($ipos) $jpos $jpos]
		if {[info exists MenuAcceler($ipos)] && [llength $MenuAcceler($ipos)] > $jpos} {
		    set MenuAcceler($ipos) [lreplace $MenuAcceler($ipos) $jpos $jpos]
		}
	    } 
	}
    }
    if {$prepost=="POST" || $prepost=="PREPOST"} {
	set ipos [lsearch $MenuNamesP $menu_name]
	if { $ipos != -1 } {
	    set jpos [lsearch $MenuEntriesP($ipos) $option_name]
	    if { $jpos != -1 } {
		set MenuEntriesP($ipos)  [lreplace $MenuEntriesP($ipos) $jpos  $jpos]
		set MenuCommandsP($ipos) [lreplace $MenuCommandsP($ipos) $jpos $jpos]
		if {[info exists MenuAccelerP($ipos)] && [llength $MenuAccelerP($ipos)] > $jpos} {
		    set MenuAccelerP($ipos) [lreplace $MenuAccelerP($ipos) $jpos $jpos]
		}
	    } 
	}
    }
}
#
# Devuelve una lista de valores, partiendo de la inicial "list" pero saltando 
# los elementos cada "step" valores y comenzando en el elemento "inicio
#
proc lstep { list step {inicio 0} } {
    set iend [llength $list]
    set newlist ""
    if { $inicio == "end" } {
	set newlist [lindex $list end] 
    } else {
	for { set i $inicio } { $i <= $iend } { incr i $step } {
	    lappend newlist [lindex $list $i] 
	}
    }
    return $newlist
} 

#
# Devuelve una cadena de longitud igual o mayor que length, conteniendo 
# string y llenando el resto con espacios si la longitud de string es
# menor que length. En otro caso devuelve string.  
#
proc fillspaces { string length } {
    set slength [string length $string]
    if { $slength < $length } {
	for { set i $slength } { $i<=$length } { incr i } {
	    set string " $string"
	}
    }
    return $string
} 

# Abre una ventana con el resultado de las fuerzas sobre los cuerpos 
proc OpenForcesWindow { } {

    set title [= {Forces on Boundaries}]
    set w .gid.boundariespostforces

    InitWindow $w $title PostBoundForcesWindowGeom

    #text $w.t -xscrollcommand "$w.scrollbar#1 set" \
    #                -yscrollcommand "$w.scrollbar#2 set" -font FixedFont

    text $w.t -yscrollcommand "$w.scrollbar#2 set" -font FixedFont

    scrollbar $w.scrollbar#2 -command "$w.t yview" -orient v
    #scrollbar $w.scrollbar#1 -command "$w.t xview" -orient h
    button $w.close -text [= {Close}] -command "destroy $w"
    focus $w.close
    grid $w.t -row 1 -column 1 -sticky nesw
    grid $w.scrollbar#2 -row 1 -column 2 -sticky ns
    #grid $w.scrollbar#1 -row 2 -column 1 -sticky ew
    grid $w.close -row 3 -column 1 -rowspan 2 -pady 5
    grid rowconfigure $w 1 -weight 1 
    grid columnconfigure $w 1 -weight 1 

    # Types
    set typenames [list [= {Pressure Force X}] [= {Pressure Force Y}] [= {Pressure Force Z}] \
	    [= {Pressure Moment X}] [= {Pressure Moment Y}] [= {Pressure Moment Z}] \
	    [= {Static Pressure Force X}] [= {Static Pressure Force Y}] [= {Static Pressure Force Z}] \
	    [= {Static Pressure Moment X}] [= {Static Pressure Moment Y}] [= {Static Pressure Moment Z}] \
	    [= {Viscous Force X}] [= {Viscous Force Y}] [= {Viscous Force Z}] \
	    [= {Viscous Moment X}] [= {Viscous Moment Y}] [= {Viscous Moment Z}]]
    set typeslen [llength $typenames]

    # Determina el nombre del archivo
    set aa [.central.s info Project]
    set ProjectName [lindex $aa 1]
    if { [file extension $ProjectName] == ".gid" } {
	set ProjectName [file root $ProjectName]
    }
    set basename [file tail $ProjectName]

    if { $ProjectName == "UNNAMED" } {
	$w.t insert end [= {It is necessary to calculate to view these results}]
	return
    }
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
	set directory [file join [pwd] $directory]
    }
    set file [file join $directory $basename.flavia.for]

    if { ![file exists $file] } {
	$w.t insert end [= {There are no results for this model}]
	return
    }
    set fd [open $file r]
    set bb ""
    while { ![eof $fd] } {
	gets $fd bb
	set bblen [llength $bb]
	if { $bblen>0 && $bblen<$typeslen } {
	    $w.t insert end [= {Forces data not found in file}]
	    close $fd
	    return
	}
    }
    if {$bb == ""} {
	$w.t insert end [= {Forces file is empty}]
	close $fd
	return
    }

    set sets ""
    set itim [lindex $bb 0]
    for { set i 1 } { $i < [llength $bb] } { incr i [expr $typeslen+1] } {
	set iset [lindex $bb $i]
	lappend sets $iset
	set Pforces($iset) [lrange $bb [expr $i+1] [expr $i+3]]
	set Pmomenta($iset) [lrange $bb [expr $i+4] [expr $i+6]]
	set Hforces($iset) [lrange $bb [expr $i+7] [expr $i+9]]
	set Hmomenta($iset) [lrange $bb [expr $i+10] [expr $i+12]]
	set Vforces($iset) [lrange $bb [expr $i+13] [expr $i+15]]
	set Vmomenta($iset) [lrange $bb [expr $i+16] [expr $i+18]]
    }
    foreach i $sets {
	$w.t insert end "$i: ([= {Final step}] $itim)\n"
	$w.t insert end "[= {Pressure Forces}] (PFx PFy PFz)\n"
	$w.t insert end "[format %8.5g [expr [lindex $Pforces($i) 0]]]\t\
	    [format %8.5g [expr [lindex $Pforces($i) 1]]]\t\
	    [format %8.5g [expr [lindex $Pforces($i) 2]]]\n"
	$w.t insert end "[= {Pressure Moments}] (PMx PMy PMz)\n"
	$w.t insert end "[format %8.5g [expr [lindex $Pmomenta($i) 0]]]\t\
	    [format %8.5g [expr [lindex $Pmomenta($i) 1]]]\t\
	    [format %8.5g [expr [lindex $Pmomenta($i) 2]]]\n"
	$w.t insert end "[= {Static Pressure Forces}] (SPx SPy SPz)\n"
	$w.t insert end "[format %8.5g [expr [lindex $Hforces($i) 0]]]\t\
	    [format %8.5g [expr [lindex $Hforces($i) 1]]]\t\
	    [format %8.5g [expr [lindex $Hforces($i) 2]]]\n"
	$w.t insert end "[= {StaticPressure Moments}] (SMx SMy SMz)\n"
	$w.t insert end "[format %8.5g [expr [lindex $Hmomenta($i) 0]]]\t\
	    [format %8.5g [expr [lindex $Hmomenta($i) 1]]]\t\
	    [format %8.5g [expr [lindex $Hmomenta($i) 2]]]\n"
	$w.t insert end "[= {Viscous Forces}] (VFx VFy VFz)\n"
	$w.t insert end "[format %8.5g [expr [lindex $Vforces($i) 0]]]\t\
	    [format %8.5g [expr [lindex $Vforces($i) 1]]]\t\
	    [format %8.5g [expr [lindex $Vforces($i) 2]]]\n"        
	$w.t insert end "[= {Viscous Moments}] (VMx VMy VMz)\n"
	$w.t insert end "[format %8.5g [expr [lindex $Vmomenta($i) 0]]]\t\
	    [format %8.5g [expr [lindex $Vmomenta($i) 1]]]\t\
	    [format %8.5g [expr [lindex $Vmomenta($i) 2]]]\n"
	$w.t insert end "[= {Total Forces}]\n"
	$w.t insert end "[format %8.5g [expr [lindex $Pforces($i) 0]+[lindex $Hforces($i) 0]+[lindex $Vforces($i) 0]]]\t\
		[format %8.5g [expr [lindex $Pforces($i) 1]+[lindex $Hforces($i) 1]+[lindex $Vforces($i) 1]]]\t\
		[format %8.5g [expr [lindex $Pforces($i) 2]+[lindex $Hforces($i) 2]+[lindex $Vforces($i) 2]]]\n"       
	$w.t insert end "[= {Total Moments}]\n"
	$w.t insert end "[format %8.5g [expr [lindex $Pmomenta($i) 0]+[lindex $Hmomenta($i) 0]+[lindex $Vmomenta($i) 0]]]\t\
		[format %8.5g [expr [lindex $Pmomenta($i) 1]+[lindex $Hmomenta($i) 1]+[lindex $Vmomenta($i) 1]]]\t\
		[format %8.5g [expr [lindex $Pmomenta($i) 2]+[lindex $Hmomenta($i) 2]+[lindex $Vmomenta($i) 2]]]\n"
	$w.t insert end "*****************************************\n"
    }
    $w.t insert end "*****************************************\n"
    $w.t insert end "[= {Note}]: \n\t[= {Pressure Forces are calculated by integrating pressure on surface}]\n"
    $w.t insert end "\t[= {Static Pressure Forces are calculated by integrating static pressure on surface}]\n"
    $w.t insert end "\t[= {Viscous Forces are calculated by integrating viscous stresses on surface}]\n" 
    $w.t insert end "\t[= {Three cartesian components of forces and moments are given in both cases}]\n" 
    $w.t insert end "\t[= {Units are OutPut Units defined by the user}]\n" 

#    close $fd

#    if { [catch { set fd [open $filename r] } ] } {
#        update idletasks
#        after 1000 PWViewOutputWin $filename $name [list $date] yes
#        return
#    }
#    PWViewOutputFill $w.t $fd

    bind $w <Destroy> "catch [list close $fd]"
}



####################################
#    Tdyn configuration window     #
####################################

proc ConfigureTdynWindow { {war 1} } {
    global ProblemTypePriv ProgramName
    set w .gid.tdynconf
  
    if { [info procs InitWindow] != "" } {
	InitWindow $w [= {Tdyn Preferences}] PreTdynConfWindowGeom ""
    } else {
	toplevel $w
    }
    # Create Notebook
    set pages [NoteBook $w.pages -arcradius 0]
    # Create Modules page (1)
    set page1 [$pages insert 0 page1 -text [= {Modules}]]
    set fpage1 [$pages getframe page1]

    set domtitle [TitleFrame $fpage1.f0 -relief ridge -bd 3\
	    -text [= {Domain Selection}] -side left ]
    set domframe [$domtitle getframe]

    set ProblemTypePriv(show_fluid) [IsVarOnTdynDefaults show_fluid 1]
    checkbutton $domframe.c1 -text [= {Activate Fluid Solver}] \
	    -var ProblemTypePriv(show_fluid)
    set ProblemTypePriv(show_solid) [IsVarOnTdynDefaults show_solid 1]
    checkbutton $domframe.c2 -text [= {Activate Solid Solver}] \
	    -var ProblemTypePriv(show_solid)
    GidHelp "$fpage1.f0" "[= {Select if you are going to use Tdyn to solve problems \
	    in one or two domains}].\n[= {You can change these values in the future, \
	    selecting Utilities > Tdyn_Preferences.}]"

    set prbtitle [TitleFrame $fpage1.f1 -relief ridge -bd 3\
	    -text [= {Problem Selection}] -side left ]
    set prbframe [$prbtitle getframe]

    set ProblemTypePriv(show_ransol) [IsVarOnTdynDefaults show_ransol 1]
    checkbutton $prbframe.c1 -text [= {Activate RANSOL Module}] \
	    -var ProblemTypePriv(show_ransol)
    set ProblemTypePriv(show_heatrans) [IsVarOnTdynDefaults show_heatrans 1]
    checkbutton $prbframe.c2 -text [= {Activate HEATRANS Module}] \
	    -var ProblemTypePriv(show_heatrans)
    set ProblemTypePriv(show_advect) [IsVarOnTdynDefaults show_advect 1]
    checkbutton $prbframe.c3 -text [= {Activate ADVECT Module}] \
	    -var ProblemTypePriv(show_advect)
    set ProblemTypePriv(show_ursolver) [IsVarOnTdynDefaults show_ursolver 1]
    checkbutton $prbframe.c4 -text [= {Activate URSOLVER Module}] \
	    -var ProblemTypePriv(show_ursolver)
    set ProblemTypePriv(show_oddls) [IsVarOnTdynDefaults show_oddls 1]
    checkbutton $prbframe.c4b -text [= {Activate ODDLS Module}] \
	    -var ProblemTypePriv(show_oddls)
    set ProblemTypePriv(show_alemesh) [IsVarOnTdynDefaults show_alemesh 1]
    checkbutton $prbframe.c5 -text [= {Activate ALEMESH Module}] \
	    -var ProblemTypePriv(show_alemesh)
    if { $ProgramName=="Tdyn3D" } {
	set ProblemTypePriv(show_ramsolid) [IsVarOnTdynDefaults show_ramsolid 1] 
	checkbutton $prbframe.c6 -text [= {Activate RAMSOLID Module}] \
		-var ProblemTypePriv(show_ramsolid)
    } else {
	set ProblemTypePriv(show_ramsolid) 0 
    }
    if { $ProgramName=="Tdyn3D" } {
	set ProblemTypePriv(show_naval) [IsVarOnTdynDefaults show_naval 1] 
	checkbutton $prbframe.c7 -text [= {Activate NAVAL Module}] \
		-var ProblemTypePriv(show_naval)
    } else {
	set ProblemTypePriv(show_naval) 0 
    }
    GidHelp "$fpage1.f1" "[= {Select the modules you are going to use}].\n[= {You may\
	    change these values in the future, selecting Utilities > Tdyn_Preferences}]."

    # Grid Modules page (1)
    grid $domtitle -row 0 -column 0 -sticky wnes
    grid $domframe.c1 -row 0 -column 0 -sticky nw
    grid $domframe.c2 -row 1 -column 0 -sticky nw 
    grid $prbtitle -row 1 -column 0 -sticky wnes -pady 10
    grid $prbframe.c1 -row 0 -column 0 -sticky nw
    grid $prbframe.c2 -row 1 -column 0 -sticky nw 
    grid $prbframe.c3 -row 2 -column 0 -sticky nw 
    grid $prbframe.c4 -row 3 -column 0 -sticky nw 
    grid $prbframe.c4b -row 4 -column 0 -sticky nw 
    grid $prbframe.c5 -row 5 -column 0 -sticky nw
    if { $ProgramName=="Tdyn3D" } {
	grid $prbframe.c6 -row 6 -column 0 -sticky nw 
	grid $prbframe.c7 -row 7 -column 0 -sticky nw 
    }

    # Create Algorithm page (2)
    set page2 [$pages insert 1 page2 -text [= {Algorithm}]]
    set fpage2 [$pages getframe page2]

    set ftitle [TitleFrame $fpage2.f0 -relief ridge -bd 3\
	    -text [= {Fluid Assembling Type}] -side left ]
    set fframe [$ftitle getframe]

    set ProblemTypePriv(fluid_atype) [IsVarOnTdynDefaults fluid_atype 1]
    radiobutton $fframe.fnodla -relief flat -text [= {Nodal Assembling}] \
	    -variable ProblemTypePriv(fluid_atype) -value 1
    radiobutton $fframe.felema -relief flat -text [= {Elemental Assembling}] \
	    -variable ProblemTypePriv(fluid_atype) -value 2

    set stitle [TitleFrame $fpage2.s0 -relief ridge -bd 3\
	    -text [= {Solid Assembling Type}] -side left ]
    set sframe [$stitle getframe]

    set ProblemTypePriv(solid_atype) [IsVarOnTdynDefaults solid_atype 1]
    radiobutton $sframe.snodla -relief flat -text [= {Nodal Assembling}] \
	    -variable ProblemTypePriv(solid_atype) -value 1
    radiobutton $sframe.selema -relief flat -text [= {Elemental Assembling}] \
	    -variable ProblemTypePriv(solid_atype) -value 2


    # Grid Algorithm page (2)
    grid $ftitle -row 1 -column 0 -sticky wnes -pady 10
    grid $fframe.fnodla -row 0 -column 0 -sticky nw
    grid $fframe.felema -row 1 -column 0 -sticky nw 
    grid $stitle -row 2 -column 0 -sticky wnes -pady 10
    grid $sframe.snodla -row 0 -column 0 -sticky nw
    grid $sframe.selema -row 1 -column 0 -sticky nw 

    # Create Checking page (3)
    set page3 [$pages insert 1 page3 -text [= {Checking}]]
    set fpage3 [$pages getframe page3]

    set title [TitleFrame $fpage3.f0 -relief ridge -bd 3\
	    -text [= {Checking Selection}] -side left ]
    set frame [$title getframe]

    set ProblemTypePriv(check_functions) [IsVarOnTdynDefaults check_funct 1]
    checkbutton $frame.chkfun -relief flat -text [= {Check Functions}] \
	    -var ProblemTypePriv(check_functions)
    set ProblemTypePriv(edit_units) [IsVarOnTdynDefaults edit_units 1]
    checkbutton $frame.edtuni -relief flat -text [= {Edit Units}] \
	    -var ProblemTypePriv(edit_units)
    set ProblemTypePriv(check_units) [IsVarOnTdynDefaults check_units 0]
    checkbutton $frame.chkuni -relief flat -text [= {Check Units}] \
	    -var ProblemTypePriv(check_units)

    # Grid Checking page (3)
    grid $title -row 1 -column 0 -sticky wnes -pady 10
    grid $frame.chkfun -row 0 -column 0 -sticky nw
    grid $frame.edtuni -row 1 -column 0 -sticky nw
    grid $frame.chkuni -row 2 -column 0 -sticky nw 

    # Grid Notebook
    grid $pages -row 1 -column 0 -sticky nwes -pady 5
    grid rowconf $fpage1 15 -weight 1
    grid rowconf $fpage2 15 -weight 1
    grid rowconf $fpage3 15 -weight 1
    grid columnconf $fpage1 0 -weight 1
    grid columnconf $fpage2 0 -weight 1
    grid columnconf $fpage3 0 -weight 1
    $pages raise page1

    # Grid Buttons frame
    frame $w.buts
    button $w.buts.ac -text [= {Accept}] -command "SetTdynPreferences $w $war"
    button $w.buts.cn -text [= {Cancel}] -command "destroy $w"
    grid $w.buts.ac $w.buts.cn  -padx 5 -pady 5 
    grid $w.buts -row 3 -column 0 -sticky swe

    grid rowconfigure $w 2 -weight 1
    grid columnconfigure $w 0 -weight 1

    wm geometry $w ""
}

proc SetTdynPreferences { w war } {
    global ProblemTypePriv ProgramName
    if { ($ProblemTypePriv(show_fluid)==0) && ($ProblemTypePriv(show_solid)==0) } {
	WarnWin [= {You must select at least one Domain to solve}]
	return
    }
    if { ($ProblemTypePriv(show_ransol)==0) && ($ProblemTypePriv(show_heatrans)==0) &&\
	 ($ProblemTypePriv(show_advect)==0) && ($ProblemTypePriv(show_ursolver)==0) &&\
	 ($ProblemTypePriv(show_ramsolid)==0)} {
	WarnWin [= {You must select at least one full Problem (module) to be used}]
	return
    }
    if { ($ProblemTypePriv(show_oddls)==1) && \
	 (($ProblemTypePriv(show_ransol)==0) || ($ProblemTypePriv(show_fluid)==0)) } {
	WarnWin "[= {ODDLS module have to be used in fluids with RANSOL module}].\n\
		[= {RANSOL module will be switched on}]."
	set ProblemTypePriv(show_ransol) 1
    }
    if { $ProgramName=="Tdyn3D" } {
	if { ($ProblemTypePriv(show_solid)==0) } {
	    set ProblemTypePriv(show_ramsolid) 0
	}
    } else {
	set ProblemTypePriv(show_ramsolid) 0
    }
    if { $ProgramName=="Tdyn3D" } {
	if { ($ProblemTypePriv(show_fluid)==0) } {
	    set ProblemTypePriv(show_naval) 0
	}
	if { ($ProblemTypePriv(show_ransol)==0) && ($ProblemTypePriv(show_naval)==1) } {
	    WarnWin "[= {NAVAL module cannot be used without RANSOL module}].\n\
		    [= {RANSOL module will be switched on}]."
	    set ProblemTypePriv(show_ransol) 1
	}
    } else {
	set ProblemTypePriv(show_naval) 0
    }

    set updated 0
    if { [WriteVarTdynDefaults show_fluid    $ProblemTypePriv(show_fluid)]    == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_solid    $ProblemTypePriv(show_solid)]    == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_ransol   $ProblemTypePriv(show_ransol) ]  == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_heatrans $ProblemTypePriv(show_heatrans)] == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_advect   $ProblemTypePriv(show_advect)]   == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_ursolver $ProblemTypePriv(show_ursolver)] == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_oddls    $ProblemTypePriv(show_oddls)]    == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_alemesh  $ProblemTypePriv(show_alemesh)]  == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_ramsolid $ProblemTypePriv(show_ramsolid)] == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults show_naval    $ProblemTypePriv(show_naval)]    == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults fluid_atype   $ProblemTypePriv(fluid_atype)]   == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults solid_atype   $ProblemTypePriv(solid_atype)]   == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults check_funct   $ProblemTypePriv(check_functions)] == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults edit_units    $ProblemTypePriv(edit_units)]    == 1 } { set updated 1 }
    if { [WriteVarTdynDefaults check_units   $ProblemTypePriv(check_units)]   == 1 } { set updated 1 }

    destroy $w
    if { !$updated } { return }
    if { $war==1 } {
	set filename [lindex [.central.s info Project] 1]
	set haycambios [lindex [.central.s info project] 2]
	if { $filename == "UNNAMED" || $haycambios } {
	    WarnWin "[= {You must restart Tdyn before these changes take effect}].\
		    \n[= {You can start Tdyn Preferences window by selecting Utilities>Tdyn Preferences}]."
	} else {
	    set answer [tk_messageBox  -type yesnocancel -icon question -message \
		    "[= {The problem will be reloaded to update the system}].\n[= {Do you want to proceed?}]"]
	    case $answer {
		yes {
		    .central.s process escape escape escape escape Files Read \"$filename\"
		}
		no  {
		    return
		}
	    }
	}
    }
}

#
# Devuelve el archivo de configuraci�n de Tdyn
#
proc GiveTdynDefaultsFile { } {
    global ProgramName VersionNumber
    set filename [GiveGidDefaultsFile]
    set dirname [file dirname $filename]
    set extname [file extension $filename]
#    set tdynname $ProgramName$VersionNumber
    set tdynname $ProgramName
    return [file join $dirname $tdynname.ini]
}
#
#   En este namespace se almacenan las preferencias que hay en el archivo *.ini
#   De esta manera no hay que acceder repetidamente al archivo
#
namespace eval TdynDefaults {
    variable initialised 0
    variable tdyndefault
}
#
#   Leemos el archivo de configuraci�n de Tdyn e inicializamos el namespace TdynDefaults
#
proc InitialiseTdynDefaults { } {
    if { [catch {        
	set file [GiveTdynDefaultsFile]
	if { [file exists $file] } {
	    set fileid [open $file r]
	    while { ![eof $fileid] } {
		set aa [gets $fileid]
		if { [regexp {([a-zA-z_]+)[ ]+([0-9])} $aa {} ivar ival] } {
		    set TdynDefaults::tdyndefault($ivar) $ival
		}
	    }
	    close $fileid
	}
    }  errormsg ]} {
	WarnWin "[= {Error found reading *.ini file.\n %s} $errormsg]."
    }
    set TdynDefaults::initialised 1
}

#
#   Comprueba el valor de una variable en el archivo de configuraci�n de Tdyn
#   Si la encuentra devuelve su valor, en otro caso devuelve el valor por 
#   defecto dado en def
#
proc IsVarOnTdynDefaults { var {def 0} } {
    if { $TdynDefaults::initialised } {
	if { [info exists TdynDefaults::tdyndefault($var)] } {
	    return $TdynDefaults::tdyndefault($var)
	} else {
	    return $def
	}
    } else {
	InitialiseTdynDefaults
	return [IsVarOnTdynDefaults $var $def]
    }
}
#
#   Escribe el valor de una variable en el archivo de configuraci�n de Tdyn
#   Devuelve 0 si el valor de var es el que figuraba en el fichero y 1 si era
#   diferente. Devuelve -1 si encuentra un error.
#
proc WriteVarTdynDefaults { var val } {
    if { $TdynDefaults::initialised==0 } {
	InitialiseTdynDefaults
    }

    set ret -1
    if { [info exists TdynDefaults::tdyndefault($var)] } {
	if { $TdynDefaults::tdyndefault($var)==$val } {
	    set ret 0
	} else {
	    set ret 1
	    set TdynDefaults::tdyndefault($var) $val
	}
    } else  {
	set TdynDefaults::tdyndefault($var) $val
    }

    set varlist [array names TdynDefaults::tdyndefault]
    set filewrite ""
    foreach ivar $varlist { 
	append filewrite "$ivar $TdynDefaults::tdyndefault($ivar)\n"
    }

    if { [catch {
	    set file [GiveTdynDefaultsFile]
	    set fileid [open $file w+]
	    puts $fileid $filewrite
	    close $fileid
	}  errormsg ]} {
	WarnWin "[= {Error found writting *.ini file.\n %s} $errormsg]."
    }
    return $ret
}
#
#   Devuelve el nombre del proyecto actualmente cargado
#
proc GiveProjectName {} {
    set aa [.central.s info Project]
    set ProjectName [lindex $aa 1]
    if { [file extension $ProjectName] == ".gid" } {
	set ProjectName [file root $ProjectName]
    }
	
    return $ProjectName
}
#
#   Devuelve el valor de una variable de GiD
#
proc ReadGiDVariable { varname } {
    return [.central.s info variable $varname]
}
#
#   Escribe el valor de una variable de GiD
#
proc WriteGiDVariable { varname varvalue } {
    return [.central.s process escape escape escape escape \
	    Utilities Variables $varname $value escape escape escape]
}
#
#   Limpia una cadena de "elementos peligrosos"
#
proc TdynCleanString { string } {
    # No se admiten espacios, ni tabulaciones ni saltos de l�nea
    set ttv $string
    regsub -all {\n} $ttv {} ttv 
    #regsub -all {\r} $ttv {} ttv
    regsub -all {\t} $ttv {} ttv
    regsub -all {;}  $ttv {} ttv 
    regsub -all { }  $ttv {} ttv
    return $ttv
}

proc TdynCancelResults {} {

    set dir [lindex [.central.s info Project] 1].gid
    set basename [file tail [lindex [.central.s info Project] 1]]

    set filelist ""
    catch { set filelist [glob -dir $dir "$basename.flavia*"] }
    catch { set filelist2 [glob -dir [file join $dir EnsightResults] "*"] }
    catch { foreach ifile $filelist2 { lappend filelist $ifile } }
    if { [llength $filelist] < 1 } {
	WarnWin [= "There are no results"]
	return
    }
    lappend filelist [file join $dir $basename.dat]

    set size 0
    foreach i $filelist {
	if { [file exists $i] } {
	    incr size [file size $i] 
	}
    }
    set size [expr int($size/1024)]
    
    set txt [= "Do you want to cancel results (size=%s Kb)?" $size]
    set retval [tk_messageBox -default ok -icon question -message $txt -type okcancel]
    if { $retval == "cancel" } { return }
    catch { file delete [file join $dir password.txt] }
    foreach i $filelist {
	catch { file delete -force $i }
    }
}

#
#   Similar a split, pero utiliza una cadena para dividir a otra
#        
proc ssplit { string splitString} {
    set len [string length $splitString]
    set idx 0
    while { $idx != -1 } {
	set idx [string first $splitString $string]
	if { $idx == -1 } {
	    lappend ret [string range $string 0 end]
	} else {
	    lappend ret [string range $string 0 $idx]
	    set string [string range $string [expr $idx+$len] end]
	}
    }
    return $ret
}

#
# En funci�n del valor de value oculta o muestra elementos en una ventana
#   
proc hideorshow { hslist value { cvalue "Yes" } } {

    if { [lsearch $cvalue $value] != -1 } {
	foreach item $hslist {
	    grid $item
	}
    } else {
	foreach item $hslist {
	    grid remove $item
	}
    }
    return 1
}

#
# Lee un archivo tcl o tbe
#   
proc loadsource { dir name } {
    if { [file exists [file join $dir $name.tcl]] } {
	source [file join $dir $name.tcl]
    } else {
	loadtbefile [file join $dir $name.tbe]
    } 
}

#
# Lee un package, si no est� ya cargado y si falla, trata de cargar un tcl
#   
proc loadpackage { dir name { ver "" } } {
    if { $ver != "" } {
	if { [catch { package require $name $ver }] } {
	    loadsource $dir $name
	}
    } else {
	if { [catch { package require $name }] } {
	    loadsource $dir $name
	}
    }
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Utilidad para escalar los
#   tama�os de malla asignados, 
#     todos a la vez

proc ScaleMeshSizes {} {
    global ProblemTypePriv ProgramName
    variable fazztor
    
    set escw .gid.meshscaling   
    if { ![winfo exists $escw] } {
	InitWindow $escw [_ "Scale assigned sizes"] scaleMeshWindowGeom ScaleMeshSizes "" 1
	if { ![winfo exists $escw] } return
   
	set pare [winfo parent $escw]
	set posx [expr [winfo x $pare]+[winfo width $pare ]/4]
	set posy [expr [winfo y $pare]+[winfo height $pare ]/4]
	wm geometry $escw [join "+$posx + $posy" ""]
	
	if { ![info exists fazztor] || ![string is double $fazztor] } { set fazztor 1.0 }
	label $escw.l_size -text "[= {Scale Factor}] " 
	entry $escw.e_size -textvariable fazztor
	
	GidHelp "$escw.e_size" [_ "Elements with previously assigned size will be scaled by this factor. \
		Scale factor 0.0 will unassign previous mesh sizes."]         
      
	# Buttons frame
	frame $escw.buts 
	# -bg [CCColorActivo [$escw cget -background]]
	set closecmd "closemeshscaling $escw"
	set acceptcmd "acceptmeshscaling $escw"

	# Accept button
	button $escw.buts.btn_accept -text [_ "OK"] -und 0 -width 6 \
	    -command "$acceptcmd"
	# Close / Calcel button
	#button $escw.buts.btn_close -text [_ "Close"] -und 0 -width 6 \
	#    -command "$closecmd"
	button $escw.buts.btn_close -text [_ "Cancel"] -und 0 -width 6 \
		-command "catch { destroy $escw }"
	
	wm protocol $escw WM_DELETE_WINDOW "$closecmd"
	bind $escw <Alt-o> "$escw.buts.btn_accept invoke"
	bind $escw <Alt-c> "$escw.buts.btn_close invoke"
	bind $escw.e_size <Return> "$escw.buts.btn_accept invoke"
	bind $escw <Escape> "$escw.buts.btn_close invoke"
	
	bind $escw.e_size <FocusIn> {
	    %W sel from 0
	    %W sel to end
	    %W icursor end
	}
	bind $escw.e_size <FocusOut> { %W sel clear }
	
	grid $escw.buts.btn_accept -row 1 -column 1 -padx 2 -pady 2
	grid $escw.buts.btn_close -row 1 -column 2 -padx 2 -pady 2

	grid $escw.l_size -row 1 -column 1 -sticky ne -pady 2
	grid $escw.e_size -row 1 -column 2 -sticky new

	grid $escw.buts -row 5 -column 1 -columnspan 7 -sticky ews
    }
    
    wm minsize $escw 250 60
    
    focus $escw.e_size
    $escw.e_size sel from 0
    $escw.e_size sel to end
    $escw.e_size icursor end
    
    return 1
}

proc acceptmeshscaling { win } {
    variable fazztor
    variable flagMesh1 
    variable flagMesh2 
    variable meshDef

    global ProblemTypePriv
    global scaledSize 
    

    set ProblemTypePriv(genesize) [lindex [GiD_Info Project] end-1]
    if {![string is double -strict $ProblemTypePriv(genesize)]} {
	set ProblemTypePriv(genesize) [format {%.3g} [expr 0.1*[LayerLength "" D]]]
	if { $ProblemTypePriv(genesize) == 0 } {
	    set ProblemTypePriv(genesize) 1.0
	}
    }
    set aux1 $ProblemTypePriv(genesize)
   
    if {$fazztor < 0.0} {
	set err_display "[= {Error: Factor must be bigger than 0.0.}] " 
	WarnWin $err_display
	set close 0
    } else {
	$win conf -cursor watch
	.central.s waitstate 1
	update
	.central.s disable graphics 1
	.central.s disable windows 1
	.central.s disable graphinput 1  
	
	set gensize [expr $fazztor*$aux1] 
	set AlreadyUsedLines ""
	set LinesToScale ""
	set ExistsNoMesh 0
	set entCount 0

	if { [ catch  {
		set close 1
		set no_vol 0
		set no_surf 0
		set no_line 0
		set no_point 0
		set n_layers 0
		
		set layer_list [.central.s info layers]
		set AlredyScaledLines ""
		set LinesToScale ""
		
		foreach layer $layer_list {
		    incr n_layers
		    set LineStructTotal ""
		    set ret_vols [GiveVolumes $layer]
		    if { $ret_vols == "" } {
		        incr no_vol 
		        set size_vol 0.0
		    } else {
		        foreach vol $ret_vols {
		            incr entCount;
		            set size_vol [GiveEntitySize $vol volumes]
		            CheckMesh $vol volumes
		            
		            if {$flagMesh1 == 0} {
		                incr ExistsNoMesh;
		            } 
		            if {($size_vol != "") && ($size_vol != 0) && ($flagMesh2 == 0)} {
		                set nsize_vol [expr $fazztor*$size_vol] 
		                .central.s process escape escape escape escape Meshing \
		                AssignSizes Volumes $nsize_vol $vol escape escape escape 
		            }              
		        }  
		        
		    }
		    
		    set ret_surfs [GiveSurfaces $layer]
		    if { $ret_surfs == "" } {
		        incr no_surf 
		        set size_surf 0.0
		    } else {
		        set LineToScaleStructTotal ""
		        foreach surf $ret_surfs {
		            incr entCount;
		            set size_surf [GiveEntitySize $surf surfaces]
		            CheckMesh $surf surfaces                
		            
		            if {$flagMesh1 == 0} {
		                incr ExistsNoMesh;
		            } 
		            if {$size_surf != "" && $size_surf != 0 && $flagMesh2 == 0} {
		                set nsize_surf [expr $fazztor*$size_surf] 
		                .central.s process escape escape escape escape Meshing \
		                AssignSizes Surfaces $nsize_surf $surf escape escape escape 
		            } elseif { $flagMesh2 == 1 && $size_surf == 0 } { 
		                set SurfStrList [.central.s info list_entities surfaces $surf]
		                set LineStruct [regexp -linestop -all -inline {Line:([ 0-9]*)} $SurfStrList]
		                set LineStructOk ""
		                for { set i 1 } { $i < [llength $LineStruct] } { incr i 2 } {
		                    lappend LineStructOk [lindex $LineStruct $i]
		                }
		                if {$LineToScaleStructTotal == ""} {
		                    foreach line $LineStructOk {
		                        lappend LineToScaleStructTotal $line
		                    }
		                } else {
		                    foreach Line1 $LineStructOk {
		                        set countL 0
		                        foreach Line2 $LineToScaleStructTotal {
		                            if {$Line1 != $Line2} {
		                                incr countL
		                            }
		                        }
		                        if {$countL == [llength $LineToScaleStructTotal]} {
		                            lappend LineToScaleStructTotal $Line1
		                        }
		                    }
		                }                                                         
		            }
		        }
		        set ListSizes ""
		        set ListSizesOk ""
		        set SizesListOk(-1) ""
		        
		        if {$LineToScaleStructTotal != ""} {
		            foreach LineOk $LineToScaleStructTotal {
		                set SizeLine [GiveEntitySize $LineOk lines] 
		                if {$ListSizes == ""} {
		                    lappend ListSizes $SizeLine
		                    lappend ListSizesOk $SizeLine
		                    set SizesListOk($SizeLine) [list $LineOk]
		                } else {
		                    lappend ListSizes $SizeLine
		                    
		                    set CountI 0
		                    foreach I $ListSizesOk {
		                        if {$SizeLine != $I} {
		                            incr CountI
		                        }
		                        if {$CountI == [llength $ListSizesOk]} {
		                            lappend ListSizesOk $SizeLine
		                        }
		                    }
		                    set CountS 0
		                    foreach SizeL $ListSizes {
		                        if {$SizeLine != $SizeL} {
		                            incr CountS
		                        } 
		                    }
		                    if { $CountS == [llength $ListSizes] } {
		                        set SizesListOk($SizeLine) [list $LineOk]
		                    } else {
		                        lappend SizesListOk($SizeL) $LineOk
		                    }
		                }
		            }
		            
		            set ListConfirm ""
		            foreach SizeListInd $ListSizesOk {
		                set AuxList $SizesListOk($SizeListInd)
		                foreach IndexAux $AuxList {
		                    set fazztorstr [expr 1/$fazztor]
		                    set nsize_line [expr $fazztorstr*$SizeListInd] 
		                    set nsize_line [expr int($nsize_line)]
		                    if {$nsize_line == 0} {
		                        set nsize_line 1
		                    }
		                    .central.s process escape escape escape escape Meshing \
		                    Structured Lines $nsize_line $IndexAux escape escape escape
		                    lappend ListConfirm $IndexAux                            
		                }
		                if {[llength $ListConfirm] == [llength $LineToScaleStructTotal]} {
		                    break
		                }
		            }
		            
		        }                                               
		    }
		    
		    set ret_lines [GiveLines $layer]
		    if { $ret_lines == "" } {
		        incr no_line 
		        set size_line 0.0
		    } else {
		        foreach line $ret_lines {
		            incr entCount;
		            set size_line [GiveEntitySize $line lines]
		            CheckMesh $line lines
		            if {$flagMesh1 == 0} {
		                incr ExistsNoMesh;
		            } 
		            if {$size_line != "" && $size_line != 0 && $flagMesh2 == 0} {
		                set nsize_line [expr $fazztor*$size_line] 
		                .central.s process escape escape escape escape Meshing \
		                AssignSizes Lines $nsize_line $line escape escape escape 
		            }                     
		        }               
		    }
		    
		    set ret_points [GivePoints $layer]
		    if { $ret_points == "" } {
		        incr no_point 
		        set size_point 0.0
		    } else {
		        foreach point $ret_points {
		            incr entCount;
		            set size_point [GiveEntitySize $point points]
		            CheckMesh $point points
		            if {$flagMesh1 == 0} {
		                incr ExistsNoMesh;
		            } 
		            if {$size_point != "" && $size_point != 0 && $flagMesh2 == 0} {
		                set nsize_point [expr $fazztor*$size_point] 
		                .central.s process escape escape escape escape Meshing \
		                AssignSizes Points $nsize_point $point escape escape escape 
		            }                
		        }
		    }
		}
	
	    } failstring ] } {

	tk_messageBox -message \
	    "Error found scaling sizes ($failstring)" \
	    -type ok -parent $win

    } else {       

	    if { ($no_point == $n_layers) && ($no_line == $n_layers) && ($no_surf == $n_layers) && ($no_vol == $n_layers) } {
		tk_messageBox -message "[= {Nothing to scale.}]" \
		    -type ok -icon info
	    } elseif { $ExistsNoMesh == $entCount} {
		tk_messageBox -message "[= {Default and assigned mesh sizes scaled, but still need to generate mesh.}]" \
		    -title "Scaled sizes"  -type ok -icon info                                
	    } else {
		tk_messageBox -message "[= {New mesh sizes correctly assigned.}]" \
		    -title "Scaled sizes"  -type ok -icon info
	    }
	    
	}
	
	#reactivar el dibujado, poner el cursor en modo normal y redibujar
	.central.s disable graphics 0
	.central.s disable windows 0
	.central.s disable graphinput 0
	.central.s process "redraw"
	$win conf -cursor ""
	.central.s waitstate 0
	
    }
    destroy $win
    
    if {$gensize != $aux1} {
	set scaledSize $gensize
    }
}

proc closemeshscaling { win } {
    variable fazztor

    if {$fazztor == 1.0} {
	destroy $win        
    } else {
	set answer [tk_dialogRAM $win [= {Mesh scaling}] \
		[= {Scale factor changed}].\n[= {Do you want to apply change?}] question 0 Yes No]
	if {$answer != 1} {
	    checkingaccept $win 
	} else {
	    destroy $win        
	} 
    }
}
