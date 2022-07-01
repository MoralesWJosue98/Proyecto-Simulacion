namespace eval buttonmat { } {
    
}

proc buttonmat::comunicatewithGiD { op args} {
    
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set cmd "GidOpenMaterials Material"
            set bmat [Button $PARENT.bmat -text [= "Create Material"] -helptext [= "Create a new Material"] \
                    -command $cmd  -width 15 -underline 0 -padx 2]
            grid $bmat -column 1 -row [expr $ROW+1] -sticky nw -pady 10   
            bind $PARENT <Alt-KeyPress-c> "tkButtonInvoke $bmat"
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            upvar \#0 $GDN GidData 
        }
        "CLOSE" {
        }
    }
}