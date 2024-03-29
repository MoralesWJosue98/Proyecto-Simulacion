
######################################################################
# example procedures asking GiD_Info and doing things with GiD_Process
proc Cmas2d::CreateWindow { } {  
    if { [GidUtils::AreWindowsDisabled] } {
        return
    }  
    if { [GiD_Info geometry NumSurfaces] > 0 } {
        #only offer to create a new random surface if there is no more surfaces in the current model
        return
    }
    set w .gid.win_example
    InitWindow $w [= "CMAS2D.TCL - Example tcl file"] PreExampleCMAS2DWindowGeom "" "" 1
    if { ![winfo exists $w] } return ;# windows disabled || usemorewindows == 0
    ttk::frame $w.top -style ridge.TFrame
    ttk::label $w.top.title_text -text [= "TCL window example for CMAS2D problem type"] -font BigFont
    ttk::frame $w.information -style ridge.TFrame
    label $w.information.help -text [= "This problemtype allows the user to compute the center of mass of a given 2D geometry. \
      \nThe geometry can be generated by the user or a random surface can be created"]
    $w.information.help configure -wraplength 320 -justify left
    ttk::frame $w.bottom -style BottomFrame.TFrame
    ttk::button $w.bottom.start  -style BottomFrame.TButton \
	-text [= "Continue"] -command [list destroy $w]
    # ttk::button $w.bottom.random -text [= "Random surface"] -command [list Cmas2d::CreateRandomSurfaceAsk $w]
    ttk::button $w.bottom.random  -style BottomFrame.TButton \
	-text [= "Random surface"] -command \
	"Cmas2d::CreateRandomSurface; GiD_Process 'Zoom Frame escape escape escape; destroy $w"
    grid $w.top.title_text -sticky ew -padx 6 -pady 6
    grid $w.top -sticky new   
    grid $w.information.help -sticky we -padx 6 -pady 6
    grid $w.information -sticky nsew    
    grid $w.bottom.start $w.bottom.random -padx 6 -pady 12 -sticky ew
    grid $w.bottom -sticky sew
    if { $::tcl_version >= 8.5 } { grid anchor $w.bottom center }
    grid rowconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
    grid rowconfigure $w 2 -weight 1
    grid columnconfigure $w 0 -weight 1    
}

proc Cmas2d::CreateRandomSurfaceAsk {w} {
    set ret [tk_dialogRAM $w.dialog [= "Warning!!"] [= "Warning: this will create a nurbs surface in your current project"] "" 1 [= "Ok"] [= "Cancel"]]    
    if {$ret ==0} {
        destroy $w
        Cmas2d::CreateRandomSurface        
        GiD_Process 'Zoom Frame escape escape escape
    }
}

proc Cmas2d::CreateRandomSurface {} {
    set a_x [expr rand()*10]
    set a_y [expr rand()*10]    
    set b_x [expr $a_x+rand()*10]
    set b_y [expr $a_y+rand()*10]    
    set c_x [expr $b_x+rand()*10]
    set c_y [expr $b_y-rand()*10]    
    if {$a_y < $c_y} {
        set d_y [expr $a_y-rand()*10]
        set d_x [expr $a_x+rand()*10]
    } else {
        set d_y [expr $c_y-rand()*10] 
        set d_x [expr $c_x-rand()*10]
    }
    set next_line_id [GiD_Info Geometry MaxNumLines]
    GiD_Process Mescape Geometry Create Line $a_x,$a_y,0 $b_x,$b_y,0 $c_x,$c_y,0 $d_x,$d_y,0 close escape
    GiD_Process Mescape Geometry Create NurbsSurface [expr $next_line_id+1]:[expr $next_line_id+4] escape escape
    GiD_Process 'Zoom Frame
}