#! /usr/bin/env wish
# the next line restarts using wish\

# Rozen Don't think that the following line is needed or desirable.
#exec wish8.5 "$0" "$@"

# $Id: vtcl.tcl,v 1.49 2006/07/28 13:43:55 unixabg Exp $

##############################################################################
#
# Visual TCL - A cross-platform application development environment
#
# Copyright (C) 1996-1998 Stewart Allen
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

##############################################################################
#

# vTcl:setup_meta
# vTcl:setup_gui      where we initiaite stuff like fonts
## for Tcl/Tk 8.4
## It also seems needed for later versions. Rozen
if {![llength [info commands tkTextInsert]]} {
    ::tk::unsupported::ExposePrivateCommand tkTextInsert
}


namespace eval ::vTcl {}

set vTcl(sourcing) 0

proc vTcl:log {msg} {
    return
    global vTcl tcl_platform

    if {![info exists vTcl(LOG_FD_W)]} {
    ## If we can't open the log files in HOME, try in the vTcl directory.
    if {[catch {open $vTcl'(LOG_FILE) "w"} vTcl(LOG_FD_W)] \
        || [catch {open $vTcl(LOG_FILE) "r"} vTcl(LOG_FD_R)]} {
        vTcl:error "Cannot open vTcl log file."
        vTcl:exit
    }
    catch {fconfigure $vTcl(LOG_FD_R) -buffering line}
    }

    puts $vTcl(LOG_FD_W) "$msg"
    flush $vTcl(LOG_FD_W)
    # tkcon_puts $msg
}

proc vTcl:splash_status {string {nodots {}}} {
    global statusMsg
    if {$nodots == {}} { append string ... }
    set statusMsg $string
    update
}

proc vTcl:splash {} {
    global vTcl
    toplevel .x -relief groove
    wm withdraw .x
    set sw [winfo screenwidth .]
    set sh [winfo screenheight .]
    image create photo "title" \
        -file [file join $vTcl(VTCL_HOME) images page_splash.png]
        #-file [file join $vTcl(VTCL_HOME) images title.gif]
    wm overrideredirect .x 1
    label .x.l -image title -bd 1 -relief sunken -background black
    pack .x.l -side top -expand 1 -fill both
    entry .x.status -relief flat -background black -foreground white \
        -textvar statusMsg -font "Helvetica 12"
    pack .x.status -side bottom -expand 1 -fill both
    set x [expr {($sw - 200)/2}]
    set y [expr {($sh - 250)/2}]
    wm geometry .x +$x+$y
    wm deiconify .x
    update idletasks
    # The following removes the splash screen. Moved to bottom of main
    # proc so that I can create the toplevel with the correct widget
    # tree.
    # after 2000 {catch {destroy .x}}

}

proc vTcl:load_lib {lib} {
    global vTcl
    vTcl:splash_status "Loading library [file tail $lib]"

    set file [file join $vTcl(LIB_DIR) $lib]

    if {[file exists $file] == 0} {
        vTcl:log "Missing Libary: $lib"
        return 0
    } else {
        uplevel #0 [list source $file]
        return 1
    }
}

proc vTcl:load_widgets {} {
    global vTcl
    global tcl_platform

    vTcl:splash_status "Loading widgets"

    ## Query for the list of libs to load. Either from prefs or defaults
    ## to all available libraries.
    set toload [vTcl::project::getLibrariesToLoad]
    ## Make sure lib_core loads before all other widget libraries.
    ::vTcl::lremove toload *lib_core.tcl
    set toload [linsert $toload 0 lib_core.tcl]
    set toload [list lib_core.tcl lib_ttk.tcl lib_scrolled.tcl]
    foreach i $toload {
        set lib [lindex [split [file root $i] _] end]
        if {[vTcl:load_lib $i]} {
            set libname [lindex [split [lindex [file split $i] end] .] 0]

            ## If we don't have the library, don't load the widgets for it.
            if {![vTcl:$libname:init]} { continue }
            lappend vTcl(w,libs) $libname
            vTcl:LoadWidgets [file join $vTcl(VTCL_HOME) lib Widgets $lib]
        }
    }
}

proc vTcl:load_libs {libs} {
    global vTcl
    foreach i $libs {
        vTcl:load_lib $i
    }
}

proc ::vTcl::load_bwidgets {} {
    vTcl:splash_status "Loading BWidgets"

    uplevel #0 {
        set dir [file join $vTcl(LIB_DIR) bwidget]
        source  [file join $dir pkgIndex.tcl]
    }

}


proc vTcl:setup {} {
    global tk_strictMotif env vTcl tcl_platform __vtlog
    global tcl_version
    global vTcl
    # The stuff below has been done already in main.
    # if {$env(VTCL_HOME) == ""} {
    #     set vTcl(VTCL_HOME) [pwd]
    # } else {
    #     set vTcl(VTCL_HOME) $env(VTCL_HOME)
    # }

    set version_file [file join $vTcl(VTCL_HOME) version]
    source $version_file
    set vTcl(tcl_version) $tcl_version

    ## See if we can write to a file in HOME.  If not, use VTCL_HOME
    if {$env(HOME) == "" || [catch {open [file join $env(HOME) .tmp] w} fp]} {
        set vTcl(CONF_FILE) [file join $vTcl(VTCL_HOME) .pagerc]
        set vTcl(LIB_FILE)  [file join $vTcl(VTCL_HOME) .pagelibs]
        set vTcl(LOG_FILE)  [file join $vTcl(VTCL_HOME) .pagelog]
    } else {
        # Rozen changed file names.
        set vTcl(CONF_FILE) [file join $env(HOME) .pagerc]
        set vTcl(LIB_FILE)  [file join $env(HOME) .pagelibs]
        set vTcl(LOG_FILE)  [file join $env(HOME) .pagelog]
    }
    catch {
        close $fp
    file delete -force [file join $env(HOME) .tmp]
    }

    set vTcl(LIB_DIR)   [file join $vTcl(VTCL_HOME) lib]
    set  vTcl(LIB_WIDG) []
    #set vTcl(LIB_WIDG)  [glob -nocomplain [file join $vTcl(LIB_DIR) lib_*.tcl]]
    set LIBS            "globals.tcl about.tcl propmgr.tcl balloon.tcl
             attrbar.tcl bgerror.tcl bind.tcl command.tcl color.tcl
             tkcon.tcl compound.tcl compounds.tcl do.tcl
             dragsize.tcl dump.tcl edit.tcl file.tcl handle.tcl
             input.tcl loadwidg.tcl font.tcl images.tcl menu.tcl misc.tcl
             name.tcl prefs.tcl proc.tcl tclet.tcl
             tops.tcl tree.tcl var.tcl vtclib.tcl
             widget.tcl help.tcl menus.tcl new.tcl ttd/ttd.tcl toolbar.tcl
             gui_python_gen.tcl support_python_gen.tcl
             color_array.tcl colorDlg.tcl close_color.tcl choosefont.tcl
             lib_core.tcl lib_scrolled.tcl lib_ttk.tcl relative_path.tcl
             callback.tcl apply.tcl"

    # UKo 2000-12-10: initiate some variables
    set vTcl(libs)      {}
    set vTcl(classes)   {}
    set vTcl(options)   {}
    #set tk_strictMotif    1
    wm withdraw .
    vTcl:splash
    #::vTcl::load_bwidgets
    #for scrolled Bands widget
    source [ file join $vTcl(LIB_DIR) kpwidgets sbands.tcl ]
    namespace import kpwidgets::*
    vTcl:load_libs $LIBS
    ## load preference
    if {[file exists $vTcl(CONF_FILE)]} {
        catch {uplevel #0 [list source $vTcl(CONF_FILE)]
            vTcl:update_tabbed_variables}
        catch {set vTcl(w,def_mgr) $vTcl(pr,manager)}
    }
    # See if we have to play dual monitor games.
    vTcl:check_geometry   ;# In misc.tcl

    vTcl:load_widgets
    ::vTcl::load_bwidgets

    # initializes the stock images database
    vTcl:image:init_stock

    # initializes the stock fonts database
    set fonts [font names]
    vTcl:font:init_stock
    set fonts [font names]
    # Set Actual Colors and Actual Fonts. (In color.tcl)
    vTcl:set_actuals
    # initializes the project
    vTcl::project::initModule main
    # make sure TkCon doesn't see command line arguments here
    set argc $::argc
    set argv $::argv
    set ::argc 0
    set ::argv {}
    vTcl:setup_gui
    set ::argc $argc
    set ::argv $argv
    update idletasks
    set vTcl(start,procs)   [lsort [info procs]]
    set vTcl(start,globals) [lsort [info globals]]
    vTcl:setup_meta
}

proc vTcl:setup_meta {} {
    global vTcl tcl_platform

    proc exit {args} {}
    proc init {argc argv} {}
    proc main {argc argv} {}

    #vTcl:proclist:show $vTcl(pr,show_func)
    vTcl:toplist:show  $vTcl(pr,show_top)
}

proc vTcl:setup_gui {} {
    global vTcl tcl_platform tk_version

    rename exit vTcl:exit

    vTcl:splash_status "Setting Up Workspace"
    ## We use our own version of Bwidgets with some bug fixes. Will
    ## submit them the bugs when time permits.
    package require BWidget
    if {$tcl_platform(platform) == "macintosh"} {
        set vTcl(pr,balloon) 0
        set vTcl(balloon,on) 0
    }
    # At this point define the fonts to be used.
    # First associate font with font description for simple case.
    foreach f [list TkDefaultFont TkTextFont TkFixedFont TkMenuFont] {
        set vTcl(font,f) $f
    }
    if {[string index $vTcl(pr,font_dft) 0] != T} {
        # Case where $vTcl(pr,font_dft) is not one of the default
        # fonts. I create the font and remember its name.
        font create font_dft {*}$vTcl(pr,font_dft)
        set vTcl(font,$vTcl(pr,font_dft)) font_dft
    }

    if {$tcl_platform(platform) == "unix"} {
        option add *vTcl*Scrollbar.width 10
        option add *vTcl*Scrollbar.highlightThickness 0
        option add *vTcl*Scrollbar.elementBorderWidth 2
        option add *vTcl*Scrollbar.borderWidth 2
        option add *Scrollbar.width 10
        option add *vTcl*font {Helvetica 12}
        option add *vTcl*font $vTcl(pr,font_dft)
        option add *ScrolledWindow.size 14
    }

    if {$tcl_platform(platform) == "windows"} {
        option add *Button.padY 0
    }
    if {$vTcl(pr,bgcolor) == ""} {set vTcl(pr,bgcolor) $vTcl(tk_default_bgcolor)}
    if {$vTcl(pr,fgcolor) == ""} {set vTcl(pr,fgcolor) "Black"}
    option add *vTcl*font $vTcl(pr,font_dft)
    option add *vTcl*Text*font $vTcl(pr,font_fixed)
    option add *NoteBook.font $vTcl(pr,font_dft)
    option add *__tk__messagebox*font $vTcl(pr,font_dft)
    option add *vTcl*foreground $vTcl(pr,fgcolor)
    if {[info exists vTcl(pr,bgcolor)] && ![lempty $vTcl(pr,bgcolor)]} {
        ## On some systems, the . window has an empty {} background option,
        ## and this makes the tk_setPalette code fail
        . configure -background gray
        tk_setPalette $vTcl(pr,bgcolor)
        option add *vTcl*background $vTcl(pr,bgcolor)
    }

    option add *vTcl*Entry.background $vTcl(pr,entrybgcolor)
    option add *vTcl*Entry.foreground $vTcl(pr,fgcolor)
    option add *vTcl*Listbox.background $vTcl(pr,listboxbgcolor)
    option add *vTcl*Listbox.foreground black

    option add *vTcl*Button*activebackground "#f4bcb2"

    vTcl:setup_bind_tree .

    vTcl:load_images
    # Rozen Window is a proc in vtclib.tcl. Next line brings up main window.
    Window show .vTcl
    foreach l $vTcl(w,libs) {
        vTcl:widget:lib:$l       ;# This appears to load the toolbar.
    }
    vTcl:config_toolbar_canvas
    vTcl:toolbar_reflow
    foreach i $vTcl(gui,showlist) {
        # This loop creates initial windows from saved information in
        # .pagerc

        if {$i == ".vTcl.gui_console"} continue  ;# Rozen NEEDS WORK
        if {$i == ".vTcl.about"} continue  ;# Rozen  Don't show about/
        Window show $i    ;# Window is in vtcllib.tcl
    }
    vTcl:clear_wtree

    vTcl:define_bindings
    vTcl:cmp_sys_menu
    raise .vTcl
}

proc vTclWindow.vTcl {args} {
    global vTcl tcl_platform tcl_version
    if {[winfo exists .vTcl]} {return}
    toplevel $vTcl(gui,main)
    wm title $vTcl(gui,main) "PAGE"  ;# Rozen
    wm resizable $vTcl(gui,main) 0 0
    wm group $vTcl(gui,main) $vTcl(gui,main)
    wm command $vTcl(gui,main) "$vTcl(VTCL_HOME)/page"
    wm iconname $vTcl(gui,main) "PAGE"   ;# Rozen
    if {$tcl_platform(platform) == "macintosh"} {
        wm geometry $vTcl(gui,main) +0+20
    } else {
         wm geometry $vTcl(gui,main) +0+0
    }
    catch { ;# Rozen removed the following statement so that I could
             # control the size from the stuff in the prefs.  regsub
             # -all {[0-9]+x[0-9]+} $vTcl(geometry,.vTcl) "" \
             # vTcl(geometry,.vTcl)

        wm geometry .vTcl $vTcl(geometry,.vTcl)
    }
    wm protocol .vTcl WM_DELETE_WINDOW {vTcl:quit}
    set tmp $vTcl(gui,main).menu
    frame $tmp -relief flat
    frame .vTcl.stat -relief flat
    pack $tmp -side top -expand 1 -fill x

    .vTcl conf -menu .vTcl.m -relief groove

    # Changed by Rozen mode and compound do not have meaning for Page
    # but gen_Python definitely does.  Perhaps I do want to use the
    # compound stuff.
    foreach menu {file edit options window widget gen_Python help} {
        if {$tcl_version >= 8} {
            vTcl:menu:insert .vTcl.m.$menu $menu .vTcl.m
        #} else {
        #    menubutton $tmp.$menu -text [vTcl:upper_first $menu] \
        #        -menu $tmp.$menu.m -anchor w
        #    vTcl:menu:insert $tmp.$menu.m $menu
        #    pack $tmp.$menu -side left
        #}
    }
    # Rozen. The help isn't worth crap anyway.
    #vTcl:menu:insert .vTcl.m.help help .vTcl.m

    # RIGHT CLICK MENU
    set vTcl(gui,rc_menu) .vTcl.menu_rc
    menu $vTcl(gui,rc_menu) -tearoff 0

    set vTcl(gui,rc_widget_menu) .vTcl.menu_rc.widgets
    menu $vTcl(gui,rc_widget_menu) -tearoff 0

    $vTcl(gui,rc_menu) add cascade -label "Widget" \
    -menu $vTcl(gui,rc_widget_menu)

    $vTcl(gui,rc_menu) add command -label "Set Alias..." -command {
        vTcl:set_alias $vTcl(w,widget)
    }

    $vTcl(gui,rc_menu) add separator
    $vTcl(gui,rc_menu) add command -label "Select Toplevel" -command {
        vTcl:select_toplevel
    }
    $vTcl(gui,rc_menu) add command -label "Select Parent" -command {
        vTcl:select_parent
    }
    $vTcl(gui,rc_menu) add separator

    # Rozen deleted pending a bit of debuging.
    $vTcl(gui,rc_menu) add comm -label "Cut" -comm {
        vTcl:cut
     }
    $vTcl(gui,rc_menu) add comm -label "Copy" -comm {
        vTcl:copy
    }
    $vTcl(gui,rc_menu) add comm -label "Paste" -comm {
        vTcl:paste -mouse
    }
    $vTcl(gui,rc_menu) add comm -label "Delete" -comm {
        vTcl:delete "" $vTcl(w,widget)
    }

    $vTcl(gui,rc_menu) add separator
    $vTcl(gui,rc_menu) add command -label "Bindings..." -command {
        vTcl:show_bindings
    }
    $vTcl(gui,rc_menu) add command -label "Callbacks..." -command {
        vTcl:show_callbacks   ;# Added May 2018

    }
    $vTcl(gui,rc_menu) add separator
    $vTcl(gui,rc_menu) add command -label "Lock Widget"  -command {
        vTcl:lock_widget   ;# Added August 2018

    }
    $vTcl(gui,rc_menu) add command -label "Unlock Widget" -command {
        vTcl:unlock_widget   ;# Added October 2018

    }
    # Stash and Apply entries
    $vTcl(gui,rc_menu) add separator
    $vTcl(gui,rc_menu) add command -label "Stash Config"  -command {
        vTcl:stash_config   ;# Added October 2018

    }
    # $vTcl(gui,rc_menu) add command -label "Apply Config" -command {
    #     vTcl:apply_config   ;# Added October 2018
    # }

    # Rozen. I want to be able to close the menu with nothing happening.
    $vTcl(gui,rc_menu) add separator  ;# Rozen
    $vTcl(gui,rc_menu) add command -label "Close Menu" -command {
    }

    # STATUS AREA
    label .vTcl.stat.sl \
        -relief groove -bd 2 -text "Status" -anchor w -width 35 \
        -textvariable vTcl(status)

    frame .vTcl.stat.f -relief sunken -bd 1 -width 150 -height 15
    frame .vTcl.stat.f.bar -relief raised -bd 1 -bg #ff4444
    pack .vTcl.stat.sl -side left -expand 1 -fill both
    #pack .vTcl.stat.mo -side left -padx 2
    pack .vTcl.stat.f  -side left -padx 2 -fill y
    pack .vTcl.stat -side top -fill both

    vTcl:setup_vTcl:bind .vTcl

    ## Create a hidden entry widget that holds the name of the current widget.
    ## We use this for copying the widget name and using it globally.
    entry .vTcl.widgetname -textvariable vTcl(w,widget)

    ## Make the menu flat
    .vTcl.m configure -relief flat
}

proc vTcl:vtcl:remap {w} {
    global vTcl

    if {![vTcl:streq $w ".vTcl"]} { return }
    if {![info exists vTcl(tops,unmapped)]} { return }

    foreach i $vTcl(tops,unmapped) {
        if {![winfo exists $i]} { continue }

        vTcl:show_top $i
    }

    wm deiconify .vTcl.toolbar
    set vTcl(tops,unmapped) ""
}

proc vTcl:vtcl:unmap {w} {
    global vTcl

    if {![vTcl:streq $w ".vTcl"]} { return }
    if {[vTcl:streq [wm state $w] "normal"]} { return }

    set vTcl(tops,unmapped) ""

    foreach i $vTcl(tops) {
    if {![winfo exists $i]} { continue }
        if {[wm state $i] != "withdrawn"} {
            vTcl:hide_top $i
            lappend vTcl(tops,unmapped) $i
        }
    }
}


proc vTcl:define_bindings {} {
    global vTcl
    vTcl:status "creating bindings"
    foreach i {a b} {
        #bind vTcl($i) <Control-z>  { vTcl:pop_action }
        #bind vTcl($i) <Control-r>  { vTcl:redo_action }
        bind vTcl($i) <Control-x>  { vTcl:cut %W }
        bind vTcl($i) <Control-c>  { vTcl:copy %W }
        bind vTcl($i) <Control-v>  { vTcl:paste {} %W }
        bind vTcl($i) <Control-q>  { vTcl:quit }
        #bind vTcl($i) <Control-n>  { vTcl:new } ;# Rozen 2/27/18
        bind vTcl($i) <Control-o>  { vTcl:open }
        bind vTcl($i) <Control-s>  { vTcl:save }
        #bind vTcl($i) <Control-w>  { vTcl:close %W}  ;# Rozen 10/24/18
        bind vTcl($i) <Control-a>  { vTcl:save_as }
        bind vTcl($i) <Control-b>  { vTcl:borrow }

        #bind vTcl($i) <Control-h>  { vTcl:hide }     ;# Rozen
        bind vTcl($i) <Control-p>  { vTcl:generate_python_UI }  ;# Rozen
        bind vTcl($i) <Control-u>  { vTcl:generate_python_support }  ;# Rozen
        bind vTcl($i) <Control-i>  { vTcl:load_python_idle } ;# Rozen
        bind vTcl($i) <Control-l>  { vTcl:load_python_consoles } ;# Rozen

        bind vTcl($i) <Key-Delete> { vTcl:delete %W $vTcl(w,widget) }
        bind vTcl($i) <Alt-a>      { vTcl:set_alias $vTcl(w,widget) }
        #bind vTcl($i) <Alt-f>      { vTcl:proclist:show flip }
        bind vTcl($i) <Alt-o>      { vTcl:toplist:show flip }
        bind vTcl($i) <Alt-t>      { vTcl:setup_unbind_tree . }
        bind vTcl($i) <Alt-e>      { vTcl:setup_bind_tree . }
        bind vTcl($i) <Alt-b>      { vTcl:show_bindings }
        bind vTcl($i) <Alt-w>      { vTcl:show_wtree }
        #bind vTcl($i) <Alt-c>      { vTcl:name_compound $vTcl(w,widget) }
        bind vTcl($i) <Alt-c>      { vTcl:show_all_callbacks }
        bind vTcl($i) <Alt-f>      { vTcl:save_wtree }

    }

    bind vTcl(c) <Configure>  {
        if {$vTcl(w,widget) == "%W"} {
            vTcl:update_widget_info %W
        }

        after idle "vTcl:place_handles \"$vTcl(w,widget)\""
    }

    bind Text <Control-Key-c> {tk_textCopy %W}
    bind Text <Control-Key-x> {tk_textCut %W}
    bind Text <Control-Key-v> {tk_textPaste %W}
    bind Text <Key-Tab>       {
        tkTextInsert %W $vTcl(tab)
        focus %W
        break
    }
    #
    # handles auto-indent and syntax coloring
    #
    bind Text <Key-Return>    {

        # exclude user inserted text widgets from vTcl bindings
        if {(! [string match .vTcl* %W]) ||
            [info exists %W.nosyntax] } {
            tkTextInsert %W "\n"
            focus %W
            break
        }

        vTcl:syntax_color %W
        set pos [%W index "insert linestart"]
        # change by Nelson 3.9.2003: better auto indent
        set nos [%W search -regexp "\[^#\ \]|$" $pos]
        # set nos [%W search -regexp -nocase "\[a-z0-9\]" $pos]
        if {$nos != ""} {
            set ct [%W get $pos $nos]
            tkTextInsert %W "\n${ct}"
            focus %W
            break
        } else {
            tkTextInsert %W "\n"
            focus %W
            break
        }
    }
    # bind Text <Key-space> {
    #     vTcl:syntax_color %W
    #     tkTextInsert %W " "
    #     focus %W
    #     break
    # }
    bind Text <KeyRelease>   {
        # exclude user inserted text widgets from vTcl bindings
        if {(! [string match .vTcl* %W]) ||
            [info exists %W.nosyntax]  } {
            break
        }
        if {"%K"=="Up" ||
            "%K"=="Down" ||
            "%K"=="Right" ||
            "%K"=="Left"||
            "%K"=="space"||
            "%K"=="End"||
            "%K"=="Home"||
            "%K"=="Home"||
            "%K"=="Home"||
            "%K" == "apostrophe" ||
            "%K" == "quotedbl" ||
            [regexp {[]\")\}]} %A]} {
                scan [%W index insert] %%d pos
                vTcl:syntax_color %W ;# $pos $pos
                focus %W
                break
            }
# if {"%K" == "apostrophe" ||
#     "%K" == "quotedbl"} {
#     vTcl:syntax_color %W
#     focus %W
#     break
# } ;# end if

    }
    bind vTcl(b) <Button-3>          {vTcl:right_click %W %X %Y %x %y}
    bind vTcl(b) <Double-Button-1>   {vTcl:widget_dblclick %W %X %Y %x %y}
    bind vTcl(b) <Button-1>          {vTcl:bind_button_1 %W %X %Y %x %y}
    #bind vTcl(b) <Button-2>          {vTcl:bind_button_2 %W %X %Y %x %y}
    bind vTcl(b) <Control-Button-1>   {vTcl:bind_button_top %W %X %Y %x %y}
    bind vTcl(b) <Shift-Button-1>      {vTcl:bind_button_container %W %X %Y %x %y}
    bind vTcl(b) <B1-Motion>         {vTcl:bind_motion %W %X %Y}
    #bind vTcl(b) <B2-Motion>         {vTcl:bind_motion %W %X %Y}
    bind vTcl(b) <Control-B1-Motion> {vTcl:bind_motion_ctrl %W %X %Y}
    bind vTcl(b) <ButtonRelease-1>   {vTcl:bind_release %W %X %Y %x %y}
    bind vTcl(b) <ButtonRelease-2>   {vTcl:bind_release %W %X %Y %x %y}

    bind vTcl(b) <Up> {
        vTcl:widget_delta $vTcl(w,widget) 0 -$vTcl(key,y) 0 0
    }

    bind vTcl(b) <Down> {
        vTcl:widget_delta $vTcl(w,widget) 0 $vTcl(key,y) 0 0
    }

    bind vTcl(b) <Left> {
        vTcl:widget_delta $vTcl(w,widget) -$vTcl(key,x) 0 0 0
    }

    bind vTcl(b) <Right> {
        vTcl:widget_delta $vTcl(w,widget) $vTcl(key,x) 0 0 0
    }

    bind vTcl(b) <Shift-Up> {
        vTcl:widget_delta $vTcl(w,widget) 0 0 0 -$vTcl(key,h)
    }

    bind vTcl(b) <Shift-Down> {
        vTcl:widget_delta $vTcl(w,widget) 0 0 0 $vTcl(key,h)
    }

    bind vTcl(b) <Shift-Left> {
        vTcl:widget_delta $vTcl(w,widget) 0 0 -$vTcl(key,w) 0
    }

    bind vTcl(b) <Shift-Right> {
        vTcl:widget_delta $vTcl(w,widget) 0 0 $vTcl(key,w) 0
    }

    bind vTcl(b) <Alt-h> {
        if {$vTcl(h,exist)} {
            vTcl:destroy_handles
        } else {
            vTcl:create_handles $vTcl(w,widget)
        }
    }

    ## If we iconify or deiconify vTcl, take the top windows with us.
    bind .vTcl <Unmap> { vTcl:vtcl:unmap %W }
    bind .vTcl <Map> { vTcl:vtcl:remap %W }

    vTcl:status "Status"


}

proc vTcl:expand_file_name {file} {
    # If a file name is give, we look at it to see if there is an
    # extension. If not or the extension is "." we add the extension
    # "tcl". Then we check to see if the file exists, if not we give
    # user choice of continuing.
    if {$file == ""} { ;# Nothing to expand.
        return
    }
    set ext [file extension $file]
    if {$ext == ""} {
        set file "$file.tcl"
    } elseif { $ext == "."} {
        append file "tcl"
    } else {
        if {$ext != ".tcl"} {
            destroy .x
            # set answer [tk_messageBox  \
            #   -message "File $file must have extension \".tcl\"\n Exiting PAGE" \
            #             -type ok -icon info \
            #             -title "Fatal Error" \
            #            ]
            tk_dialog .foo "File Error" \
                 "File $file must have extension \".tcl\"\n Exiting PAGE" \
                  info 0 "ok"

            puts "File must have the extension \".tcl\""
            puts "Exiting PAGE."
            exit
        }
    }

    if {[file exists $file]} {
        return $file
    } elseif {[file exists [file join [pwd] $file]]} {
        return $file
    } else {
        set msg [concat "File $file does not exist?" \
                     "\nDo you wish to continue?"]
        set answer [tk_messageBox  \
            -message $msg -type yesno -icon question -title "Missing File" \
            -default "no"          ]
        if {$answer == "no"} {
            #puts "File $file not found."
            exit
        }
        return ""
    }
}

proc vTcl:main {argc argv} {
    set dir "./bwidget"
    #source [file join $dir pkgIndex.tcl]
    #source "lib/bwidget/pkgIndex.tcl"
    global env vTcl tcl_version tcl_platform
    catch {package require Unsafe} ; #for running in Netscape
    catch {package require dde}    ; #for windows
    catch {package require Tk}     ; #for dynamic loading tk
    catch {package require Ttk}    ; #for themed widgets - Rozen
    if {$tcl_version < 8.6} {
        wm deiconify .
        wm title . "Time to upgrade"
        frame .f -relief groove -bd 2
        pack .f -expand 1 -fill both -padx 2 -pady 2
        label .f.l1 -text "This version of Tcl/Tk is old..."
        label .f.l2 -text "Tcl8.6 and Tk8.6 or newer recommended"
        button .f.b -text "Close" -command {exit}
        pack .f.l1 .f.l2 -side top -padx 5
        pack .f.b -side top -pady 5
    return
    }
# For debugging on Windows
# if  {$tcl_platform(platform) == "windows"} {
#   console show  ;# Rozen for debugging.
# }
    # if {$tcl_platform(platform) == "macintosh"} {
    #     set vTcl(VTCL_HOME) $env(HOME)
    # }
    if {![info exists env(PAGE_HOME)]} {
        set home [file dirname [info script]]
        switch [file pathtype $home] {
            absolute {set env(PAGE_HOME) $home}
            relative {set env(PAGE_HOME) [file join [pwd] $home]}
            volumerelative {
                set curdir [pwd]
                cd $home
                set env(PAGE_HOME) [file join [pwd] [file dirname \
                    [file join [lrange [file split $home] 1 end]]]]
                cd $curdir
            }
        }
    }
    # VTCL_HOME is a hold over from Virtual Tcl.
    set vTcl(VTCL_HOME) $env(PAGE_HOME)
    # This sets up the debugging stuff at this point, which is early
    # in the executions.  I can use the debugging function in this
    # code before the libs are loaded.
    source [file join $vTcl(VTCL_HOME) lib debug.tcl]

    if {![file isdir $env(PAGE_HOME)]} { set vTcl(VTCL_HOME) [pwd] }
    set env(PAGE_HOME) $vTcl(VTCL_HOME)
    set file ""

    for {set x 0} {$x<$argc} {incr x} {
        append file [lindex $argv $x] " "
    }
    set file [string trimright $file]
    set file [vTcl:expand_file_name $file]
    vTcl:setup

    ## init the bindings editor
    ::widgets_bindings::init
    vTcl:splash_status "              PAGE Loaded" -nodots
    # after 1000 {if {[winfo exists .x]} {destroy .x}}
    ## load file passed in command line, get rid of splash window right here
    if {$file != ""} {
        if {[file exists $file]} {
            destroy .x
            vTcl:open $file
        } elseif {[file exists [file join [pwd] $file]]} {
            destroy .x
            vTcl:open [file join [pwd] $file]
        } else {
            puts "File $file not found."
            puts "Exiting PAGE."
            vTcl:exit
        }
        set vTcl(project_specified) 1
    } else {
        # No project given.
        set vTcl(project_specified) 0
    }
    if [info exists vTcl(pr,autoloadcomp)] {
        if {$vTcl(pr,autoloadcomp)} {
            set loaded [vTcl:load_compounds $vTcl(pr,autoloadcompfile)]
            if {$loaded == ""} {
                ## if user cancels, we unselect the "autoload compounds" option
                ## so (s)he is not prompted again
                set vTcl(pr,autoloadcomp) 0
            } else {
                ## user changed the compounds file, save the setting
                set vTcl(pr,autoloadcompfile) $loaded
            }
        }
    }
    # set appdefaults "TKoptionDB"
    # if [file exists $appdefaults] {
    #    option readfile $appdefaults
    # }
    # Close Splash screen and insert initial Toplevel. New code 11/15/2017
    set vTcl(change) 0
    after 500 {if {[winfo exists .x]} {destroy .x}
        if {!$vTcl(project_specified)} {
            vTcl:new_widget 0 "Toplevel" bbb
            set vTcl(change) 0
            set vTcl(real_top) [lindex $vTcl(tops) 0]
        }
    }
}

proc tracer {varname args} {
    upvar #0 $varname var
    puts "tracer: $varname was updated to be \"$var\""
    puts "$var"
    dtrace
    # if {$var == "wheat"} {
    #     puts "hello"
    #     set x [expr 1 / 0]
    # }

}
proc watch {varname key op} {
        if {$key != ""} {
                set varname ${varname}($key)
                }
        upvar $varname var
        puts "$varname is $var (operation $op)"
        }

#trace add variable vTcl(w,opt,-highlightcolor) \
    write "tracer vTcl(w,opt,-highlightcolor)"

#trace add variable defaults(-highlightcolor) \
    write "tracer defaults(-highlightcolor)"

#trace add variable vTcl(m,place,-x) \
    write "tracer vTcl(m,place,-x)"

#trace add variable vTcl(gui_search_pattern) \
    write "tracer vTcl(gui_search_pattern)"

vTcl:main $argc $argv








