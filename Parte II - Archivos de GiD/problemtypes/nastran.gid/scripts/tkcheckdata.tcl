#tkwidget.tcl  -*- TCL -*- Created: JGE Jun-2002, Modified: JGE Jun-2002

###################################################
# UTILIDAD TKWIDGET PARA CONTROL DE DATOS GENERALES
###################################################
#
# Requiere ser llamado desde el archivo de definici�n del 
# material, datos, ... en la forma:
# TKWIDGET: CheckDataWidget::Control "Field1 type1 Field2 type2 ..."
# Donde Field1, Field2, etc. son los diferentes campos QUESTION y
# type1, type2, etc. son los tipos de entrada, que pueden ser:
#
#      word:    word without spaces
#      any:     anything
#      real:    real
#      real+:   positive real
#      real0+:  positive real, including 0
#      int:     int
#      int+:    positive int
#      int0+:   positive int, including 0
#
# Note: Types must be lowercase
#
namespace eval CheckDataWidget {        
}

proc CheckDataWidget::Control { flds op args } {
    # op puede ser INIT,SYNC o CLOSE
    # INIT es enviado al abrir la ventana
    # SYNC es enviado al pulsar AcceptData
    # CLOSE es enviado al cerrar la ventana
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            upvar      [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            
            for { set i 1 } { $i < [llength $flds] } { incr i 2 } {
                set type [lindex $flds $i]
                set QUESTION [lindex $flds [expr $i-1]]
                if { [catch {set ifld $GidData($STRUCT,LABEL,$QUESTION)}] } {
                    set ifld [LabelField $GDN $STRUCT $QUESTION]
                }
                if { $ifld != -1 } {
                    set val [DWLocalGetValue $GDN $STRUCT $QUESTION]
                    set errmessage [IsType $type $val .gid]
                    if { $errmessage != "" } {
                        append errmessage " in field $QUESTION" 
                        set w .gid.cdata
                        while { [winfo exists $w] } { append w a }
                        set newval [tk_dialogEntryType $w \
                                [= "Enter correct value"] $errmessage "" $type $val]
                        DWLocalSetValue $GDN $STRUCT $QUESTION $newval
                    } 
                }
            }
            return ""
        }
    }
}

###################################################
# UTILIDADES CREACI�N DE LISTBOX, ENTRY Y OTROS
###################################################

# proc IsType
#
# w: parent window
# type -        Can be:
#                        word:    word without spaces
#                        any:     anything
#                        real:    real
#                        real+:   positive real
#                        real0+:  positive real, including 0
#                        int:     int
#                        int+:    positive int
#                        int0+:   positive int, including 0

proc IsType { type word { w .gid } { errorText "" } } {    
    set errorRes ""
    switch $type {
        word {
            if { ![regexp {^[  ]*[^ \t]+[  ]*$} $word] } {
                set errorRes [= "A single word must be entered"]
            }
        }
        real {
            if { ![regexp {^[  ]*([+-]?([0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)([eE][+-]?[0-9]+)?)[  ]*$} $word] } {
                set errorRes [= "One number must be entered"]
            }           
        }
        real+ {
            if { ![regexp {^[  ]*([+]?([0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)([eE][+-]?[0-9]+)?)[  ]*$} $word] } {
                set errorRes [= "One positive number must be entered"]
            } elseif { $word == 0 } {
                set errorRes [= "One positive number must be entered"]
            }
        }
        real0+ {
            if { ![regexp {^[  ]*([+]?([0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)([eE][+-]?[0-9]+)?)[  ]*$} $word] } {
                set errorRes [= "One non negative number must be entered"]
            }
        }
        int {
            if { ![regexp {^[  ]*[+-]?[0-9]+[  ]*$} $word] } {
                set errorRes [= "One integer number must be entered"]
            }           
        }
        int+ {
            if { ![regexp {^[  ]*[+]?[0-9]*[1-9]+[0-9]*[  ]*$} $word] } {
                set errorRes [= "One positive integer number must be entered"]
            }   
        }
        int0+ {
            if { [regexp  {^[  ]*[+-]?[0-9]+[  ]*$} $word] } {
                if { $word < 0 } {
                    set errorRes [= "One non negative integer number must be entered"]
                }
            } else {
                set errorRes [= "One non negative integer number must be entered"]
            }
        }
    }
    if { $errorRes!="" } {
        if { $errorText!="" } {
            tk_dialogRAM $w.tempwinerr [= "Error window"] "$errorRes $errorText" error 0 OK
        }
        return "$errorRes"
    } 
    return ""
}

#
# This procedure displays a dialog box, with an entry, waits for a button in 
# the dialog to be invoked, then returns the entry.
#
# Arguments:
# w -                Window to use for dialog top-level.
# title -        Title to display in dialog's decorative frame.
# text -        Message to display in dialog.
# bitmap -        Bitmap to display in dialog (empty string means none).
# type -        Can be any of IsType types and:
#                        text:    text with spaces and '\n'
#                        textro:  text with spaces and '\n' read-only
# default -    default value for entry

proc tk_dialogEntryType {w title text bitmap type default } {
    global tkPriv tcl_platform
    
    # 1. Create the top-level window and divide it into top, middle
    # and bottom parts.
    
    while { [winfo exists $w] } { append w a }
    catch {destroy $w}
    toplevel $w -class OverlayWindow
    
    wm title $w $title
    wm iconname $w Dialog
    wm protocol $w WM_DELETE_WINDOW { }
    
    if { $tcl_platform(platform) == "windows" } {
        wm transient $w [winfo toplevel [winfo parent $w]]
    }
    
    frame $w.bot -relief raised -bd 1
    pack $w.bot -side bottom -fill both
    frame $w.top -relief raised -bd 1
    
    if { $type != "text" && $type != "textro"} {
        pack $w.top -side top -fill both -expand 1
    } else {
        pack $w.top -side top -fill both
    }
    
    frame $w.middle -relief raised -bd 1
    if { $type != "text" && $type != "textro"} {
        entry $w.middle.e -relief sunken -xscroll "$w.middle.xscroll set" \
            -textvariable this_entry -bd 1
        if { $type == "password" } { $w.middle.e conf -show * }
        
        $w.middle.e del 0 end
        if { $default != "" } {
            #kike,correcci�n si $default == "", no har�a caso a la tecla retroceso
            $w.middle.e ins end $default
            $w.middle.e sel from 0 
            $w.middle.e sel to end
        }
        
        scrollbar $w.middle.xscroll -relief sunken \
            -orient horizontal -command "$w.middle.e xview" \
            -bd 1 -elementborderwidth 1
        #     pack $w.middle.xscroll -side bottom -fill x
        #     pack $w.middle.e -side top
        
        grid $w.middle.e -sticky ew
        grid $w.middle.xscroll -sticky ew
        
        pack $w.middle
        
    } else {
        set this_entry ""
        
        text $w.middle.t -relief sunken -width 40 -height 8 \
            -yscroll "$w.middle.yscroll set" -bd 1
        $w.middle.t delete 0.0 end
        $w.middle.t ins end $default
        #$w.middle.t tag add sel 0.0 end
        if { $type == "textro"} {
            $w.middle.t conf -state disabled
        }
        
        scrollbar $w.middle.yscroll -relief sunken \
            -orient vertical -command "$w.middle.t yview" \
            -bd 1 -elementborderwidth 1
        
        # grid $w.middle.t $w.middle.yscroll -sticky ewns -ipady 3
        # 
        # grid rowconfigure $w.middle 0 -weight 1
        # grid rowconfigure $w.middle 1 -weight 1
        # grid columnconfigure $w.middle 0 -weight 1
        # grid columnconfigure $w.middle 1 -weight 0
        pack $w.middle.t -side left -expand 1 -fill both
        pack $w.middle.yscroll -expand 1 -fill y
        
        pack $w.middle -expand 1 -fill both
    }
    
    # 2. Fill the top part with bitmap and message (use the option
    # database for -wraplength so that it can be overridden by
    # the caller).
    
    #    option add *Dialog.msg.wrapLength 3i widgetDefault
    label $w.msg -justify left -text $text -wraplength 75m -font BigFont
    
    pack $w.msg -in $w.top -side right -expand 1 -fill both -padx 3m -pady 3m
    if {$bitmap != ""} {
        label $w.bitmap -bitmap $bitmap
        pack $w.bitmap -in $w.top -side left -padx 3m -pady 3m
    }
    
    if { $type != "text" && $type != "textro"} {
        bind $w <Return> "
            $w.button0 configure -state active -relief sunken
            update idletasks
            after 100
            set tkPriv(button) 0
            "
    }
    
    # 3. Create a row of buttons at the bottom of the dialog.
    
    set UnderLineList ""
    set i 0
    set default 0
    #    set args [list [= "OK"] [= "Cancel"]] 
    set args [= "Ok"]
    set lentext 0
    foreach but $args {
        if { [string length $but] > $lentext } {
            set lentext [string length $but]
        }
    }
    foreach but $args {
        button $w.button$i -text $but -command "set tkPriv(button) $i" \
            -width $lentext -bd 1
        pack $w.button$i -in $w.bot -side left -expand 1 \
            -padx 3m -pady 2m
        
        bind $w.button$i <Return> "
            $w.button$i configure -state active -relief sunken
            update idletasks
            after 100
            set tkPriv(button) $i
            break
            "
        
        if { [regexp -nocase cancel $but] } "
            bind $w <Escape> \"
            $w.button$i configure -state active -relief sunken
            update idletasks
            after 100
            set tkPriv(button) $i
            \""
        incr i
    }
    
    # 5. Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.
    
    #    if { [winfo parent $w] == ".gid" } {
        #        bind $w <Destroy> [list DestroyWinInDialogs $w GeomDialog]
        #    }
    
    #    if { [info exists GidPriv(GeomDialog)] && [winfo parent $w] == ".gid"} {
        #        WmGidGeom  $w $GidPriv(GeomDialog)
        #    } else {
        wm withdraw $w
        update idletasks
        
        # extrange errors with updates
        if { ![winfo exists $w] } { return 0}
        
        set pare [winfo toplevel [winfo parent $w]]
        set x [expr [winfo x $pare]+[winfo width $pare ]/2- [winfo reqwidth $w]/2]
        set y [expr [winfo y $pare]+[winfo height $pare ]/2- [winfo reqheight $w]]
        if { $x < 0 } { set x 0 }
        if { $y < 0 } { set y 0 }
        WmGidGeom $w +$x+$y
        update
        wm deiconify $w
        #   }
    
    # 6. Set a grab and claim the focus too.
    
    set oldFocus [focus]
    tkwait visibility $w
    set oldGrab [grab current $w]
    if {$oldGrab != ""} {
        set grabStatus [grab status $oldGrab]
    }
    grab $w
    
    if { $type != "text" && $type != "textro" } {
        focus $w.middle.e
        after 100 catch [list "focus -force $w.middle.e"]
    } elseif { $type == "textro" } {
        focus $w.button0
        after 100 catch [list "focus -force $w.button0"]
    } else {
        focus $w.middle.t 
        after 100 catch [list "focus -force $w.middle.t"]
    }
    
    # 7. Wait for the user to respond, then restore the focus and
    # return the index of the selected button.  Restore the focus
    # before deleting the window, since otherwise the window manager
    # may take the focus away so we can't redirect it.  Finally,
    # restore any grab that was in effect.
    
    set errorRes ""
    while 1 {
        tkwait variable tkPriv(button)
        #        if { $tkPriv(button) == 1} { break }
        if { $type != "text" && $type != "textro" } {
            set result [$w.middle.e get]
        } else {
            set result [ $w.middle.t get 0.0 end]
        }
        set errorRes [IsType $type $result .gid "!!!"]
        set this_entry "$result"
        if { $errorRes == "" } { break }
    }
    
    if { $oldFocus == "" || [catch {focus $oldFocus}] } {
        if { [winfo exists .gid] } {
            focus [focus -lastfor .gid]
        }
    }
    destroy $w
    if {$oldGrab != ""} {
        if {$grabStatus == "global"} {
            grab -global $oldGrab
        } else {
            grab $oldGrab
        }
    }
    return $this_entry
}

# proc tk_ListBox
#
# wn: parent window
# title: title of the listbox
# subtitle: lateral text of the listbox
# names: names of entries of the list
# command: to be executed when ready

proc tk_ListBox { wn title subtitle names { command "" } } { 
    
    set w $wn.lsbox
    while { [winfo exists $w] } { append w a }
    
    toplevel $w -height 200 -width 200
    wm title $w $title
    #    wm iconname $w Dialog        
    wm transient $w $wn
    
    set pare [winfo toplevel [winfo parent $w]]
    set x [expr [winfo x $pare]+[winfo width $pare ]/2- [winfo reqwidth $w]/2]
    set y [expr [winfo y $pare]+[winfo height $pare ]/2- [winfo reqheight $w]]
    if { $x < 0 } { set x 0 }
    if { $y < 0 } { set y 0 }
    wm geometry $w +$x+$y
    
    #   Primera fila del grid, compuesta por el subt�tulo y la listbox 
    frame $w.main -bd 2 -relief groove
    label $w.main.msg -wraplength 1.5i -justify left -text $subtitle -font Normal -padx 10
    grid $w.main.msg -row 0 -column 0 -sticky nsew -pady 3
    
    frame $w.main.frame -bd .1c
    grid $w.main.frame -row 0 -column 1 -sticky nsew -pady 1
    
    scrollbar $w.main.frame.scroll -command "$w.main.frame.list yview"
    listbox $w.main.frame.list -yscroll "$w.main.frame.scroll set" -selectmode single \
        -setgrid 1 -height 12 -bg white
    grid $w.main.frame.scroll -row 0 -column 1 -sticky nse
    grid $w.main.frame.list -row 0 -column 0 -sticky nsew
    grid columnconfigure $w.main.frame 0 -weight 1
    grid rowconfigure $w.main.frame 0 -weight 1
    grid $w.main -row 0 -column 0 -sticky nsew
    grid columnconfigure $w.main 0 -weight 1
    grid rowconfigure $w.main 0 -weight 1
    
    proc tk_ListBox_thisprocess { w list command } {
        eval $command [$list curselection]
        destroy $w
    } 
    
    bind $w.main.frame.list <Return> "tk_ListBox_thisprocess $w $w.main.frame.list \"$command\""
    bind $w.main.frame.list <Double-1> "tk_ListBox_thisprocess $w $w.main.frame.list \"$command\""
    
    eval $w.main.frame.list insert 0 $names
    
    #   Segunda fila del grid, compuesta por los botones
    frame $w.buttons
    grid $w.buttons -row 1 -column 0 -sticky nsew -padx 3 -pady 1
    button $w.buttons.ok -text OK -width 5 -command "tk_ListBox_thisprocess $w $w.main.frame.list \"$command\""
    button $w.buttons.cancel -text Cancel -width 5 -command "destroy $w"
    grid $w.buttons.ok -row 0 -column 0 -sticky s -padx 3 -pady 1
    grid $w.buttons.cancel -row 0 -column 1 -sticky s -padx 3 -pady 1  
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 0 -weight 1
    update
}

# proc tk_ListMenu
#
# wn: parent window
# text: text of the buttonmenu
# names: names of commands of the menu
# command: list of commands of the menu

proc tk_ListMenu { wn text names { command "" } } { 
    set w $wn.lsmenu
    menubutton $w -text $text -underline 0 -direction below -menu $w.ls -relief raised
    menu $w.ls -tearoff 0
    foreach name $names {
        if { $name != "" } {
            set nmtext $name
            if { [string length $nmtext]>10 } {
                set nmtext [string range $name 0 9]
            }
            $w.ls add command -label $nmtext -command "$command \"$name\""
        }
    }
    return $w
}
