# -*- Tcl -*-
# Time-stamp: 2012-12-17 23:00:07 rozen>

# Python_ui.tcl - procedures for generating Python User Interfaces
#
# This program was written by Don Rozenberg and is based on java_ui.tcl
# written by Constantin Teodorescu.
#
# The original copyright notice is attached and this program is released
# under the terms of that copyright.
#
# Copyright (C) 1996-1997 Constantin Teodorescu
# Copyright (C) 2013-2018 Donald Rozenberg
#
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

# vTcl:python_quick_run
# vTcl:python_parse_menu
# vTcl:Window.py_console
# vTcl:python_configure_widget
# vTcl:relative_placement
# vTcl:relative_x_y
# vTcl:python_source_widget    Switch for generating code for each widget class
# vTcl:python_menu_options
# vTcl:python_process_menu
# vTcl:generate_python           Top of the python generation.
# vTcl:generate_python_UI
# vTcl:style_code
# vTcl:get_top_level_configuration
# vTcl:python_menu_font
# vTcl:python_generate_context_menu
# vTcl:save_GUI_file
# vTcl:toplevel_geometry
# vTcl:python_dump_bind
# vTcl:create_functions
# vTcl:load_python_idle
# vTcl:run_prep
# vTcl:load_console
# vTcl:create_functions          Where the functions are created for the output
# vTcl:validation_parameters

# Changes: line 70

#  To  add a special attribute:
#      1. Add the attribute to global.tcl or lib_tix to put it in
#          vTcl(opt,list)
#      2. Add a new case to vTcl:update_widget_info
#      3. Add code to case of  vTcl:python_source_widget to handle
#             the special attributes.

#  Menu stuff starts 1900.

proc lambda {{p1 ""} {p2 ""} {p3 ""} {p4 ""} {p5 ""} {p6 ""} {p7 ""} {p8 ""}} {
    # This is a null proc to facilitate certain bindings.
    # If the user binds a command to a window event it may be executed when
    # the tcl file is sourced.  Since the command will attempt to execute a
    # Python lambda function, an error message will occur.  By having this null
    # procedure, the error message is avoided.
}

proc vTcl:generate_python_UI {} {
    global vTcl env
    # Code Generation starts here. <control-p> brings us here. Creates
    # the Python Console and calls vTcl:generate_python for actual
    # code generation.
    set vTcl(rework) 1                 ;# for debugging rework second version.
    set window $vTcl(real_top)
    if {$window == ""} {
        # There is nothing to save or process.
        tk_dialog .foo Error "There is no GUI to process." error 0 "OK"
        return
    }

    # For debugging only
    set winfo_geometry [winfo geometry $window]
    set wm_geometry [winfo geometry $window]
    #end debug code

    if {![info exists vTcl($window,x)]} {
        vTcl:active_widget $window
    }
    set vTcl(py_title) [wm title $window]
#dpr widget(rev,$window)
    # if {$vTcl(py_title) == ""} {
    #     # Get alias and use for the classname
    #     global widget
    #     set alias $widget(rev,$window)
    #     set  vTcl(py_classname) [vTcl:clean_string $alias]
    # } else {
    #     set  vTcl(py_classname) [vTcl:clean_string $vTcl(py_title)]
    # }
    global widget
    set alias $widget(rev,$window)
    set  vTcl(py_classname) [vTcl:clean_string $alias]
    vTcl:get_project_name
    vTcl:Window.py_console "gui"
    update
    $vTcl(gui_source_window) delete 1.0 end
    $vTcl(gui_output_window) delete 1.0 end

    set vTcl(funct_list) {}
    set vTcl(functions) ""
    set vTcl(class_functions) ""
    set vTcl(proc_list) {}
    set vTcl(fonts_defined,$vTcl(actual_gui_font_dft_name)) 1
    set vTcl(fonts_defined,$vTcl(actual_gui_font_text_name)) 1
    set vTcl(fonts_defined,$vTcl(actual_gui_font_fixed_name)) 1
    set vTcl(fonts_used) []
    set vTcl(menu_names) []
    lappend vTcl(alias_names) 1
    set bg $vTcl(actual_bg)
    set vTcl(bgcolor) $bg
    set fg $vTcl(actual_fg)
    set vTcl(fgcolor) $fg
    set vTcl(import_module) 0
    set vTcl(import_module) "[file rootname $vTcl(project,file)]_support.py"
    set t [file tail $vTcl(project,file)]
    set vTcl(import_name) [file rootname $t]_support

    set root_list [winfo children .]
    set vTcl(popup_code) ""
    set vTcl(toplevel_config) ""
    set vTcl(py_initfunc) ""
    if {[lsearch $root_list ".pop*"] > -1} {
        set vTcl(in_popup) 1
        vTcl:python_generate_context_menu $root_list
    }
    set vTcl(in_popup) 0
    set vTcl(pnotebook_count) 0
    set vTcl(tnotebook_count) 0
    set vTcl(notebook_image_count) 0


    try {
        vTcl:generate_python $window
    } trap {401} {errmsg} {
        set err_split [split $errmsg]
        set wid [lrange $err_split 2 2]
        Window hide .vTcl.gui_console
        Window show $vTcl(real_top)
        vTcl:select_widget $wid
        vTcl:create_handles $wid
        return
    }
}

proc vTcl:python_generate_context_menu {root_list} {
    # Generate source strings for the context (popup) menu.
    global vTcl widget
    set popups [lsearch -all -inline $root_list ".pop*"]
    set count 1
    foreach popup $popups {
        # Determine the import name because we will need it for both popup
        # code and regular code generation.
        set widname  $widget(rev,$popup)
        set l [string length "Popupmenu"]
        set count [string range $widname $l end]
        append vTcl(popup_code) "$vTcl(tab)@staticmethod\n"
        append vTcl(popup_code) "$vTcl(tab)def popup$count"
        append vTcl(popup_code) "(event, *args, **kwargs):\n"
        # append vTcl(popup_code) \
        #     "$vTcl(tab)$vTcl(tab)$widname = Menu(root, tearoff=0)\n"
        # vTcl:python_configure_widget $popup $widname "" \
        #     "menu"  "" $popup
        # vTcl:python_process_menu $popup $widname $widname

        # The following two lines put in the colors and the font.
        vTcl:python_configure_widget $popup $widname "" \
            "menu"  "" $popup
        vTcl:python_process_menu $popup $widname $widname
#        set vTcl(toplevel_config)
        vTcl:fonts_actually_used
        if {[info exists vTcl(toplevel_config)]} {
            append vTcl(popup_code) $vTcl(toplevel_config)
        }
        append vTcl(popup_code) \
            "$vTcl(tab)$vTcl(tab)$widname = tk.Menu(root, tearoff=0)\n"
        append vTcl(popup_code) $vTcl(py_initfunc)
        append vTcl(popup_code) \
            "$vTcl(tab)$vTcl(tab)$widname.post(event.x_root, event.y_root)\n"
        regsub -all "self\." $vTcl(popup_code) "" vTcl(popup_code)
        append vTcl(popup_code) "\n"
        unset vTcl(py_initfunc)

        if {[info exists vTcl(toplevel_config)]} {
            unset vTcl(toplevel_config)
        }
        incr count
    }
}

proc vTcl:generate_python {window} {
    # This is the top of the python generation. Called from
    # vTcl:generate_python_UI.
    global vTcl
    global tcl_platform
    global style_code
    #set vTcl(menubutton_list) {}
    set vTcl(add_helper_code) 0
    set vTcl(add_pnotebook_helper) 0
    set vTcl(helper_list) {}
    set vTcl(toplevel_menu_header) ""
    set vTcl(Tree_cnt) 0
    set vTcl(slash_pos_list) 0
    set vTcl(pw_cnt) 0
    set vTcl(image_count) 1
    set vTcl(menu_names) []
    set vTcl(menu_image_count) 0
    set vTcl(using_ttk) 0
    set vTcl(import_module) 0
    set vTcl(gui_save_warning) ""
    set vTcl(gui_search_pattern) ""
    vTcl:set_timestamp
    set vTcl(gui_py_change_time) [clock milliseconds]
    # The following loop gets rid of all the fonts that were defined
    # in the last call to generate python.  In short, it is one of the
    # things necessary to let one generate python multiple times within
    # PAGE.
    foreach index [array names vTcl fonts_defined,*] {
        unset vTcl($index)
    }

    #set vTcl(fonts_defined,gui_font_dft) 1

    set vTcl(fonts_defined,$vTcl(actual_gui_font_dft_name)) 1
    set vTcl(fonts_defined,$vTcl(actual_gui_font_text_name)) 1
    set vTcl(fonts_defined,$vTcl(actual_gui_font_fixed_name)) 1
    set vTcl(fonts_used) []
    set bg $vTcl(actual_bg)
    set vTcl(bgcolor) $bg
    set fg $vTcl(actual_fg)
    set vTcl(fgcolor) $fg
    lappend vTcl(alias_names) 1
    unset vTcl(alias_names)
    if {[info exists style_code]} {
        unset style_code
    }
    lappend vTcl(alias_names) 1
    set resizable [wm resizable $window]
    if {([lindex $resizable 0]=="0") || ([lindex $resizable 1]=="0")} {
        set resizable false
    } else {
        set resizable true
    }
    set classname $vTcl(py_classname)
    set title $vTcl(py_title)
    set constructor_arguments ""
    set constructor_super ""
    set main_args ""
    set main ""
    set onWindowClose "this.setVisible(false); this.dispose();"
    #    set lwin $vTcl(py_window)
    set geom [vTcl:toplevel_geometry $window]
    #set vTcl(geometry) \"[winfo geometry $window]\"
    set vTcl(geometry) $geom

    set main "\nif __name__ == '__main__':\n"
    append main "$vTcl(tab)vp_start_gui()\n"
    set onWindowClose "sys.exit()"

    set vTcl(py_vars) {}
    set vTcl(py_initfunc) {}
    set vTcl(py_funcdef) {}
    set vTcl(py_action) {}
    set vTcl(py_has_menus) 0
    set vTcl(global_variable) 0
    set vTcl(g_v_list) {}
    set vTcl(l_v_list) {}
    set vTcl(funct_list) {}
    set vTcl(functions) ""
    set vTcl(class_functions) ""
    set vTcl(proc_list) {}
    #    set vTcl(output_adjust_sash) 0   ;# temporary
    foreach bg [array names vTcl py_btngroup,*] {
        unset vTcl($bg)
    }

    set vTcl(import_module) "[file rootname $vTcl(project,file)]_support.py"
    vTcl:get_import_name
    vTcl:py_source_frame $window   ""  "" ;# generates code for all the widgets.
    #vTcl:py_process_menubutton_list

    # Put in stuff like geometry,title, etc.
    vTcl:get_top_level_configuration $window
    set my_procs ""
    set class_procs "\n"
    # if {$vTcl(global_variable)} {
    #     set set_vars [vTcl:py_build_set_Tk_var $vTcl(g_v_list)]
    # } else {
    #     set set_vars ""
    # }
    set set_vars ""
    set start_up_proc [vTcl:python_gui_startup $geom $title $classname]

    #set my_procs "def init():\n    pass\n"

    # Separate the proc's into those that go inside the class definition
    # from those that go outside.  Skip any without the 'py:' prefix.

    # The next loop and the call to create_functions generate the code
    # for the functions needed to make code executable.  They fall
    # into two cases, those which the user specified using the function
    # editor and those which PAGE detected from bindings or command
    # attributes. For the first case, all I do is to spit them out and
    # add their names to vTcl(proc_list) to preclude their being
    # generated twice. With the rest, I guess that I will have to
    # analyze the argument lists to generate parameter lists.

    # This deals with the proc which were generated with the Function
    # Editor.
    set init_found 0
    foreach i  [lsort $vTcl(procs)] {
        if {[string first "py:" $i] == -1} {
            continue
        }
        if {$i == "main"} {
            continue
        }
        if {$i == "vp_start_gui"} {
            continue
        }
        if {$i == "append_python_attributes"} {
            continue
        }
        if {$i == "py:init"} {
            set init_found 1
        }
        if {![regexp -nocase {vtcl} $i]} {
            # I just want the name so I pick up between the "def " and
            # the parameter list.
            set last [string first "(" $new_proc]
            set nn [string range $new_proc 4 [expr $last - 1]]
            set nn [string trim $nn]
            lappend vTcl(proc_list) $nn
            set p1 $last
            set p2 [string first ")" $new_proc]
            set parm_list [string range $new_proc [expr $p1 + 1] [expr $p2 - 1]]
            set type "global"
            if {$parm_list == "self"} {set type "class"}
            if {[string first "self," $parm_list] > -1} {set type "class"}
            if {$type == "global"} {
                # Global proc
                set new_proc [vTcl:python_subst_tabs $new_proc]
                set new_proc [vTcl:python_delete_lambda $new_proc]
                #set my_procs "$my_procs$new_proc\n"
                append my_procs "$new_proc\n"
            } else {
                # class procs
                set new_proc [vTcl:python_delete_lambda $new_proc]
                set new_proc [vTcl:python_subst_tabs $new_proc]
                set new_proc [vTcl:python_delete_leading_tabs $new_proc]
                set new_proc [vTcl:python_indent_lines $new_proc]
                #set class_procs "$class_procs$new_proc\n"
                append class_procs "$new_proc\n"
            }
        }
    }
    if {$init_found == 0} {
        if {$vTcl(import_module) == ""} {
            append my_procs "def init():\n    pass\n"
        }
    }
    # Auto-create import statements for support modules. NEEDS WORK 11/5/13
    foreach m $vTcl(funct_list) {
    }
    # Auto-create procs from vTcl(funct_list)
    vTcl:create_functions

    # Now I build the balloon stuff.
    # For time being I'm not supporting balloon creation.
    #set balloon_code [vTcl:create_balloon_code $vTcl(tops)]
    set balloon_code ""

    # Create the PNotebook helper functions. vTcl(add_pnotebook_helper)
    # set in vTcl:python_source_widget.
    if {$vTcl(add_pnotebook_helper)} {
        set pnotebook_helper [create_pnotebook_helper]
    } else {
        set pnotebook_helper ""
    }

    # Finally the ttk helper functions. vTcl(add_helper_code) set in
    # widget switch in vTcl:python_source_widget.
    if {$vTcl(add_helper_code)} {
        set ttk_helper [create_ttk_helper]
    } else {
        set ttk_helper ""
    }
    set source \
"#! /usr/bin/env python
#  -*- coding: utf-8 -*-
#
# GUI module generated by PAGE version $vTcl(version)
#  in conjunction with Tcl version $vTcl(tcl_version)
#    $vTcl(timestamp)  platform: $tcl_platform(os)

import sys

try:
$vTcl(tab)import Tkinter as tk
except ImportError:
$vTcl(tab)import tkinter as tk

try:
$vTcl(tab)import ttk
$vTcl(tab)py3 = False
except ImportError:
$vTcl(tab)import tkinter.ttk as ttk
$vTcl(tab)py3 = True"

    if {$vTcl(global_string) != ""} {
        append source \
"
$vTcl(global_string)
"
    }
    if {$start_up_proc != ""} {
        append source \
"
$start_up_proc
"
    }
    if {$set_vars != ""} {
        append source \
"
$set_vars
"
    }
    if {$my_procs != ""} {
        append source \
"
$my_procs
"
    }
    if {$vTcl(functions) != ""} {
    append source \
"
$vTcl(functions)
"
    }
    append source \
"
class $classname:
$vTcl(tab)def __init__(self, top=None):
$vTcl(tab)$vTcl(tab)'''This class configures and populates the toplevel window.
$vTcl(tab)$vTcl(tab)   top is the toplevel containing window.'''
$vTcl(toplevel_config)
$vTcl(py_initfunc)
$vTcl(popup_code)"
    if {$vTcl(class_functions) != ""} {
        append source \
"
$vTcl(class_functions)"
    }
# set source "$source
# $balloon_code
# $class_procs
# $ttk_helper
# $main
# "
    if {$balloon_code != ""} {
    append source \
"
$balloon_code
"
    }
    if {$class_procs != ""} {
    append source \
"
$class_procs
"
    }

    if {$pnotebook_helper != ""} {
    append source \
"$pnotebook_helper"
    }

    if {$ttk_helper != ""} {
    append source \
"$ttk_helper"
    }
    append source \
"
$main
"
    set numbered [vTcl:add_line_numbers $source]
    $vTcl(gui_source_window)  delete 1.0 end
    $vTcl(gui_source_window)  insert end $numbered
    set vTcl(python_module) "GUI"            ;#  10/4/14
    set vTcl(gui_save_warning) "Unsaved changes"
    set vTcl(py_source) $source
    vTcl:colorize_python "gui"
    set filename "[file rootname $vTcl(project,file)].py"
    set top .vTcl.gui_console
    wm title $top "GUI Console - $filename"
    update
    return
}

proc vTcl:add_line_numbers {code} {
    # split the code and add line numbers and remove multiple blank lines.
    global vTcl
    regsub -all {\n\n\n+} $code "\n\n" code
    set i 1
    foreach line [split $code "\n"] {
        set filler_len [expr 4 - [string length $i]]
        set filler [string repeat " " $filler_len]
        append str $filler  $i " " $line "\n"
        incr i
    }
    return $str
}

proc vTcl:remove_numbers {code} {
    global vTcl
    foreach line [split $code "\n"] {
        set new_line [string range $line 5 end]
        append str $new_line "\n"
    }
    return $str
} ;# end remove_numbers


proc vTcl:toplevel_geometry {window} {
    global vTcl
    # Routine to set up toplevel geometry for use in generated code.

    # psuedo code:
    # if default position is Yes
    #    set position ""
    # else
    #    if relative position is Yes
    #       calculate relative position
    # return [list size x y]

    # Determine default powition
    set geom_output ""
    set dflt_origin $vTcl(pr,default_origin)
    if {[info exists ::widgets::${window}::dflt,origin]} {
        set dflt_origin [vTcl:at ::widgets::${window}::dflt,origin]
    }
    set geom [wm geometry $window]
    set geom_split [split $geom "x+"]
    foreach {w h x y} $geom_split {}
    if {!$dflt_origin} {
        append str \"$w x $h + $x + $y\"
    } else {
        append str \"$w x $h\"
    }
    return $str
}

proc vTcl:create_functions {{gen gui}} {
    # Generate functions contained in vTcl(funct_list).
    # Called from vTcl:generate_python near line 270
    global vTcl
    set vTcl(functions) ""
    set mod ""
    set name_list {}
    if {! [info exists vTcl(funct_list)]} {
        # Empty list
        return
    }
    set functions_generated {}
    foreach fun [lsort -unique $vTcl(funct_list)] {
        if {$gen == "import" && [string first "pop" $fun] > -1} continue
        if {$fun == "_button_press" || $fun == "_button_release"
            || $fun == "_mouse_over" } continue
        # separate name and argument list.
        set spot [string first "(" $fun]
        if {$spot > -1} {
            set name [string range $fun 0 [expr $spot - 1]]
            set arg_list [string range $fun $spot end]
        } else {
            set name $fun
            set arg_list ""
        }
        # see if in vTcl(proc_list).
        set fun [vTcl:python_delete_lambda $name]
        if {[lsearch -exact $vTcl(proc_list) $name] > -1} {continue}
        # see if we have already generated the function.
        if {[lsearch -exact $name_list $fun] > -1} {continue}
        if {[string first "self." $name] > -1} {
            # class method skip in support module
            if {$gen == "import"} continue
            # Remove leading "self."
            set cfun [string range $fun 5 end]
            if {[lsearch -exact $vTcl(variable_parms) $fun]  > -1} {
                # We want a variable parameter list
                set parms "(*args)"
            } else {
                set parms [prepare_parameter_list $arg_list "class"]
            }
            append vTcl(class_functions) \
"
$vTcl(tab)def $cfun$parms:
$vTcl(tab)$vTcl(tab)$vTcl(tab)print('self.$cfun')
$vTcl(tab)$vTcl(tab)$vTcl(tab)sys.stdout.flush()
"
        } elseif { [string first "." $name] > -1} {
            # Name refers to an imported module.
            continue
            set spot [string first "." $name]
            set mod [string range $name 0 $spot]
            set ifun [string range $name [expr $spot + 1] end]
            set parms [prepare_parameter_list $arg_list "global"]
            if {$gen == ""} {
                append vTcl(functions) \
"
def $ifun$parms:
$vTcl(tab)$vTcl(tab)print('$fun')
$vTcl(tab)$vTcl(tab)sys.stdout.flush()
"
            }
        } else {
            if {$gen == "gui"} continue
            # It's a global function.
            set mod $vTcl(import_name).
            if {[lsearch -exact $vTcl(variable_parms) $fun]  > -1} {
                set parms "(*args)"
            } else {
                set parms [prepare_parameter_list $arg_list "global"]
            }
            set eventParm "(event)"; #Don, I didn't modify $parms to
                                     #avoid any new possible bugs to
                                     #appear
# Rozen moved this stuff to the GUI module and tightened it up a bit.
#             # Generate python functions to handle close button bindings
#             if {$fun == "_mouse_over"} {
#                 append vTcl(functions) \
# "
# def $fun$eventParm:

#     widget = event.widget
#     element = widget.identify(event.x, event.y)

#     if \"close\" in element:
#         widget.state(\['alternate'\])

#     else:
#         widget.state(\['!alternate'\])
# "


#             } elseif {$fun == "_button_press"} {

#                                 append vTcl(functions) \
# "
# def $fun$eventParm:

#     widget = event.widget

#     element = widget.identify(event.x, event.y)

#     if \"close\" in element:
#         index = widget.index(\"@%d,%d\" % (event.x, event.y))
#         widget.state(\['pressed'\])
#         widget._active = index
# "

#             } elseif {$fun == "_button_release"} {

#                                 append vTcl(functions) \
# "
# def $fun$eventParm:

#     widget = event.widget

#     if not widget.instate(\['pressed'\]):
#             return

#     element = widget.identify(event.x, event.y)

#     try:
#         index = widget.index(\"@%d,%d\" % (event.x, event.y))
#     except TclError:
#         pass

#     if \"close\" in element and widget._active == index:
#         widget.forget(index)
#         widget.event_generate(\"<<NotebookTabClosed>>\")

#     widget.state(\[\"!pressed\"\])
#     widget._active = None
# "
#             } else {
            # Adding the print statement and flush function below to
            # aid in verifying a GUI design.
                append vTcl(functions) \
"
def $fun$parms:
$vTcl(tab)print('$mod$fun')
"
                if {$parms != "()" && $parms != "(*args)" } {
                    set i_p [split $parms ',']
                    set p_len [llength $i_p]
                    for {set k 1} {$k<=$p_len} {incr k} {
                        append vTcl(functions) \
                            "    print('p$k = {0}'.format(p$k))\n"
                    } ;# end for loop
                }
                append vTcl(functions) \
"$vTcl(tab)sys.stdout.flush()\n"
#            }
            set mod ""
        }
        lappend name_list $fun
    }

}

proc vTcl:create_validation_functions {} {
    # Generate functions for the entry validation. This is a feature
    # that is very poorly documented and so this may have problems.
    global vTcl
    if {! [info exists vTcl(validate_function_list)]} {
        # Empty list
        return
    }
    set mod $vTcl(import_name).
    set parms "(*args)"
    foreach fun [lsort -unique $vTcl(validate_function_list)] {
        if {$vTcl(validate_function,$fun) == "validatecommand"} {
            set ret "return True"
        } else {
            set ret "return"
        }
        append vTcl(functions) \
"
def $fun$parms:
    print('$mod$fun')
    for arg in args:
        print ('another arg:', arg)
    sys.stdout.flush()
    $ret
"
    }
}

proc vTcl:validation_parameters {} {
    global vTcl

}

proc split_long_font_string {str} {
    global vTcl
    if {[lsearch $vTcl(standard_fonts) $str] > -1} {
        return "$str\n"
    }
    set font_stmt $str
    set len [string length $font_stmt]
    if {$len <= 70} {
        return "$str\n"
    }
    set brk [string wordstart $font_stmt 70]
    set pre_char [string index $font_stmt [expr $brk - 1]]
    if {$pre_char == "-"} {
        set brk [expr $brk - 1]
    }
    set part1 [string range $font_stmt 0 [expr $brk - 1]]
    set part2 [string range $font_stmt [expr $brk] end]
    set ret "$part1\""
    if {$part2 != ""} {
        append ret " \ \\\n$vTcl(tab2)$vTcl(tab)\"$part2\n"
    }
    return $ret
}

proc color_value {color} {
    if {[string first "#" $color] > -1} {
        return $color
    } else {
        return [::colorDlg::colorToPoundRgb $color]
    }
}

proc color_comment {color} {
    if {[string first "#" $color] > -1} {
        lassign [FindClosestNamedColor $color] name dist
        if {$dist == 0} {
            return "# X11 color: '$name'"
        } else {
            return "# Closest X11 color: '$name'"
        }
    } else {
        return "# X11 color: [::colorDlg::colorToHex $color]"
    }
}

proc check_default_font {font} {
    # Determine if font is one of the standard fonts, if so just
    # return the font name in quotes.  Oct 2013
    global vTcl
    if {$font in $vTcl(standard_fonts)} {
        return "\"$font\""
    } else {
        #return self.$font
        return $font
    }
}

proc vTcl:get_top_level_colors_fonts {} {
    # First put out the color definitions.
    global vTcl
    append vTcl(toplevel_config) \
      "$vTcl(tab2)_bgcolor = '$vTcl(actual_gui_bg)' \
                       [color_comment $vTcl(actual_gui_bg)]\n"
        #"$vTcl(tab2)_bgcolor = '$vTcl(bgcolor)'\n"
    append vTcl(toplevel_config) \
      "$vTcl(tab2)_fgcolor = '$vTcl(actual_gui_fg)' \
                       [color_comment $vTcl(actual_gui_fg)]\n"

    vTcl:comp_color        ;# Puts out stmt for complement color.
    vTcl:analog_colors     ;# Puts out stmts for analog colors.
    if {[::colorDlg::dark_color $vTcl(pr,guicomplement_color)]} {
        set comp_fg "white"
    } else {

        set comp_fg "black"
    }


    # Put out the fonts actually used.
    #vTcl:fonts_actually_used "self."
    vTcl:fonts_actually_used ;# "self."
}
proc vTcl:fonts_actually_used {{selfie ""}} {
    # Put out the fonts actually used.
    global vTcl
    set putout []
    set f_used [lsort -unique $vTcl(fonts_used)]
    foreach f [lsort -unique $vTcl(fonts_used)] {
        if {[string range $f 0 1] == "Tk"} {
            # If f is a default font then do nothing.
            continue
        }
        if {[catch {
            set font_cfg [font configure $f]}]} {
            # font configure failed.
            set font_cfg "TkDefaultFont"
        }
        #set font_string [vTcl:python_menu_font $font_cfg]
        # if {$popup_fonts == 0} {
        #     append vTcl(toplevel_config) \
        #         [split_long_font_string "$vTcl(tab2)self.$f = \"$font_cfg\""]
        #          #"$vTcl(tab2)$f = $font_string\n"
        #     lappend putout $f
        # } else {
        #     append vTcl(toplevel_config) \
        #         [split_long_font_string "$vTcl(tab2)$f = \"$font_cfg\""]
        #     lappend putout $f
        #}
        append vTcl(toplevel_config) \
                 [split_long_font_string "$vTcl(tab2)$selfie$f = \"$font_cfg\""]
                 #"$vTcl(tab2)$f = $font_string\n"
        lappend putout $f
    }
}

proc vTcl:get_top_level_configuration {window} {
    # Get configure information for the top level window.
    global vTcl
    set vTcl(toplevel_config) ""
    # Get the color and font information
    vTcl:get_top_level_colors_fonts

    if {[::colorDlg::dark_color $vTcl(pr,guicomplement_color)]} {
        set comp_fg "white"
    } else {

        set comp_fg "black"
    }

    if {$vTcl(using_ttk)} {
        append vTcl(toplevel_config) \
            "$vTcl(tab2)self.style = ttk.Style()\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)if sys.platform == \"win32\":\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)$vTcl(tab)self.style.theme_use('winnative')\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)self.style.configure('.',background=_bgcolor)\n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)self.style.configure('.',foreground=_fgcolor)\n"
        if {[lsearch $vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)] > -1} {
          append vTcl(toplevel_config) \
              "$vTcl(tab2)self.style.configure('.',font=[check_default_font \
                            $vTcl(actual_gui_font_dft_name)])\n"
#          "$vTcl(tab2)self.style.configure('.',font=$vTcl(actual_gui_font_dft_name))\n"
#            "$vTcl(tab2)self.style.configure('.',font=gui_font_dft)\n"
        }
       append vTcl(toplevel_config) \
          "$vTcl(tab2)self.style.map('.',background=\n"
       append vTcl(toplevel_config) \
    "$vTcl(tab2)$vTcl(tab)\[('selected', _compcolor), ('active',_ana2color)\])\n"
        if {[::colorDlg::dark_color $vTcl(pr,guianalog_color_m)]} {
            append vTcl(toplevel_config) \
                "$vTcl(tab2)self.style.map('.',foreground=\n"
            append vTcl(toplevel_config) \
    "$vTcl(tab2)$vTcl(tab)\[('selected', '$comp_fg'), ('active','white')\])\n"
        }
     }
    # Set the geometry of the top level.
    append vTcl(toplevel_config) \
        "\n$vTcl(tab2)top.geometry($vTcl(geometry))\n"
    # Set the title for the top level
    append vTcl(toplevel_config) \
        "$vTcl(tab2)top.title(\"$vTcl(py_title)\")\n"
    # Obtain a list of all attributes of the top level window.
    set opt [$window configure]
    # Above returns a list of lists. The values are:
    #              argvName,  dbName,  dbClass,  defValue, and current value
    foreach op $opt {
        foreach {o x y d v} $op {}
        set v [string trim $v]
        if {$d == $v} continue   ;# If value == default value bail.
        set len [string length $o]
        set sub [string range $o 1 end]
         switch -exact -- $sub {
             padX -
             padY -
             dropdown -
             editable -
             orient -
             fancy {
             }
             menu {
             }
             background {
                 #append vTcl(toplevel_config) \
                 #    "$vTcl(tab2)master.configure($sub=_bgcolor)\n"
                 append vTcl(toplevel_config) \
                      "$vTcl(tab2)top.configure($sub=\"$v\")\n"

             }
             default {
                 append vTcl(toplevel_config) \
                     "$vTcl(tab2)top.configure($sub=\"$v\")\n"
             }
        }
    }
    # Include top bindings
    append vTcl(toplevel_config) \
        "$vTcl(bind_top)\n"
}

proc prepare_parameter_list {arg_list type} {
    # Auto gen the parameter list.  We can't just use the parameter
    # given in the command clause because they may be constants. This
    # function returns a string.
    if {[string length $arg_list] == 0} { # Rozen change 2 into 0
        if {$type == "class"} {
            return "(self)"
        } else {
            return "()"
        }
    }
    set args "("            ;# Open the parenthesized list.
    if {$type == "class"} {
        append args "self,"
    }
    set argl [split $arg_list "(,)"]  ;# Get a list of the arguments
    set zlist [lrange $argl 1 end-1]  ;# Throw out the "(" and ")" list elements
    set c 1
    foreach z $zlist {
        append args p$c ","
        incr c
    }
    set args [string range $args 0 end-1]  ;# Get rid of last ","
    append args ")"                        ;# Close the parenthesized list.
    return $args
}

proc create_pnotebook_helper {} {
    global vTcl
    set pnotebook_helper \
"
# The following code is add to handle mouse events with the close icons
# in PNotebooks widgets.
def _button_press(event):
$vTcl(tab)widget = event.widget
$vTcl(tab)element = widget.identify(event.x, event.y)
$vTcl(tab)if \"close\" in element:
$vTcl(tab)$vTcl(tab)index = widget.index(\"@%d,%d\" % (event.x, event.y))
$vTcl(tab)$vTcl(tab)widget.state(\['pressed'\])
$vTcl(tab)$vTcl(tab)widget._active = index

def _button_release(event):
$vTcl(tab)widget = event.widget
$vTcl(tab)if not widget.instate(\['pressed'\]):
$vTcl(tab)$vTcl(tab)$vTcl(tab)return
$vTcl(tab)element = widget.identify(event.x, event.y)
$vTcl(tab)try:
$vTcl(tab)$vTcl(tab)index = widget.index(\"@%d,%d\" % (event.x, event.y))
$vTcl(tab)except TclError:
$vTcl(tab)$vTcl(tab)pass
$vTcl(tab)if \"close\" in element and widget._active == index:
$vTcl(tab)$vTcl(tab)widget.forget(index)
$vTcl(tab)$vTcl(tab)widget.event_generate(\"<<NotebookTabClosed>>\")

$vTcl(tab)widget.state(\['!pressed'\])
$vTcl(tab)widget._active = None

def _mouse_over(event):
$vTcl(tab)widget = event.widget
$vTcl(tab)element = widget.identify(event.x, event.y)
$vTcl(tab)if \"close\" in element:
$vTcl(tab)$vTcl(tab)widget.state(\['alternate'\])
$vTcl(tab)else:
$vTcl(tab)$vTcl(tab)widget.state(\['!alternate'\])
"
}

proc create_ttk_helper {} {
    global vTcl
    set ttk_helper \
"
# The following code is added to facilitate the Scrolled widgets you specified.
class AutoScroll(object):
$vTcl(tab)'''Configure the scrollbars for a widget.'''

$vTcl(tab)def __init__(self, master):
$vTcl(tab)$vTcl(tab)#  Rozen. Added the try-except clauses so that this class
$vTcl(tab)$vTcl(tab)#  could be used for scrolled entry widget for which vertical
$vTcl(tab)$vTcl(tab)#  scrolling is not supported. 5/7/14.
$vTcl(tab)$vTcl(tab)try:
$vTcl(tab)$vTcl(tab)$vTcl(tab)vsb = ttk.Scrollbar(master, orient='vertical', command=self.yview)
$vTcl(tab)$vTcl(tab)except:
$vTcl(tab)$vTcl(tab)$vTcl(tab)pass
$vTcl(tab)$vTcl(tab)hsb = ttk.Scrollbar(master, orient='horizontal', command=self.xview)

$vTcl(tab)$vTcl(tab)#self.configure(yscrollcommand=_autoscroll(vsb),
$vTcl(tab)$vTcl(tab)#    xscrollcommand=_autoscroll(hsb))
$vTcl(tab)$vTcl(tab)try:
$vTcl(tab)$vTcl(tab)$vTcl(tab)self.configure(yscrollcommand=self._autoscroll(vsb))
$vTcl(tab)$vTcl(tab)except:
$vTcl(tab)$vTcl(tab)$vTcl(tab)pass
$vTcl(tab)$vTcl(tab)self.configure(xscrollcommand=self._autoscroll(hsb))

$vTcl(tab)$vTcl(tab)self.grid(column=0, row=0, sticky='nsew')
$vTcl(tab)$vTcl(tab)try:
$vTcl(tab)$vTcl(tab)$vTcl(tab)vsb.grid(column=1, row=0, sticky='ns')
$vTcl(tab)$vTcl(tab)except:
$vTcl(tab)$vTcl(tab)$vTcl(tab)pass
$vTcl(tab)$vTcl(tab)hsb.grid(column=0, row=1, sticky='ew')

$vTcl(tab)$vTcl(tab)master.grid_columnconfigure(0, weight=1)
$vTcl(tab)$vTcl(tab)master.grid_rowconfigure(0, weight=1)

$vTcl(tab)$vTcl(tab)# Copy geometry methods of master  (taken from ScrolledText.py)
$vTcl(tab)$vTcl(tab)if py3:
$vTcl(tab)$vTcl(tab)$vTcl(tab)methods = tk.Pack.__dict__.keys() | tk.Grid.__dict__.keys() \\
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)  | tk.Place.__dict__.keys()
$vTcl(tab)$vTcl(tab)else:
$vTcl(tab)$vTcl(tab)$vTcl(tab)methods = tk.Pack.__dict__.keys() + tk.Grid.__dict__.keys() \\
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)  + tk.Place.__dict__.keys()

$vTcl(tab)$vTcl(tab)for meth in methods:
$vTcl(tab)$vTcl(tab)$vTcl(tab)if meth\[0\] != '_' and meth not in ('config', 'configure'):
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)setattr(self, meth, getattr(master, meth))

$vTcl(tab)@staticmethod
$vTcl(tab)def _autoscroll(sbar):
$vTcl(tab)$vTcl(tab)'''Hide and show scrollbar as needed.'''
$vTcl(tab)$vTcl(tab)def wrapped(first, last):
$vTcl(tab)$vTcl(tab)$vTcl(tab)first, last = float(first), float(last)
$vTcl(tab)$vTcl(tab)$vTcl(tab)if first <= 0 and last >= 1:
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)sbar.grid_remove()
$vTcl(tab)$vTcl(tab)$vTcl(tab)else:
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)sbar.grid()
$vTcl(tab)$vTcl(tab)$vTcl(tab)sbar.set(first, last)
$vTcl(tab)$vTcl(tab)return wrapped

$vTcl(tab)def __str__(self):
$vTcl(tab)$vTcl(tab)return str(self.master)

def _create_container(func):
$vTcl(tab)'''Creates a ttk Frame with a given master, and use this new frame to
$vTcl(tab)place the scrollbars and the widget.'''
$vTcl(tab)def wrapped(cls, master, **kw):
$vTcl(tab)$vTcl(tab)container = ttk.Frame(master)
        container.bind('<Enter>', lambda e: _bound_to_mousewheel(e, container))
        container.bind('<Leave>', lambda e: _unbound_to_mousewheel(e, container))
$vTcl(tab)$vTcl(tab)return func(cls, container, **kw)
$vTcl(tab)return wrapped"
    if {[lsearch $vTcl(helper_list) Scrolledtext] > -1} {
        append ttk_helper \
"

class ScrolledText(AutoScroll, tk.Text):
$vTcl(tab)'''A standard Tkinter Text widget with scrollbars that will
$vTcl(tab)automatically show/hide as needed.'''
$vTcl(tab)@_create_container
$vTcl(tab)def __init__(self, master, **kw):
$vTcl(tab)$vTcl(tab)tk.Text.__init__(self, master, **kw)
$vTcl(tab)$vTcl(tab)AutoScroll.__init__(self, master)"
     }
     if {[lsearch $vTcl(helper_list) Scrolledlistbox] > -1} {
     append ttk_helper \
"

class ScrolledListBox(AutoScroll, tk.Listbox):
$vTcl(tab)'''A standard Tkinter Text widget with scrollbars that will
$vTcl(tab)automatically show/hide as needed.'''
$vTcl(tab)@_create_container
$vTcl(tab)def __init__(self, master, **kw):
$vTcl(tab)$vTcl(tab)tk.Listbox.__init__(self, master, **kw)
$vTcl(tab)$vTcl(tab)AutoScroll.__init__(self, master)"
    }
    if {[lsearch $vTcl(helper_list) Scrolledentry] > -1} {
        append ttk_helper \
"

class ScrolledEntry(AutoScroll, tk.Entry):
$vTcl(tab)'''A standard Tkinter Entry widget with a horizontal scrollbar
$vTcl(tab)that will automatically show/hide as needed.'''
$vTcl(tab)@_create_container
$vTcl(tab)def __init__(self, master, **kw):
$vTcl(tab)$vTcl(tab)tk.Entry.__init__(self, master, **kw)
$vTcl(tab)$vTcl(tab)AutoScroll.__init__(self, master)"
    }
    if {[lsearch $vTcl(helper_list) Scrolledcombo] > -1} {
        append ttk_helper \
"

class ScrolledCombo(AutoScroll, ttk.Combobox):
$vTcl(tab)'''A ttk Combobox with a horizontal scrollbar that will
$vTcl(tab)automatically show/hide as needed.'''
$vTcl(tab)@_create_container
$vTcl(tab)def __init__(self, master, **kw):
$vTcl(tab)$vTcl(tab)ttk.Combobox.__init__(self, master, **kw)
$vTcl(tab)$vTcl(tab)AutoScroll.__init__(self, master)"
    }
    if {[lsearch $vTcl(helper_list) Scrolledtreeview] > -1} {
        append ttk_helper \
"

class ScrolledTreeView(AutoScroll, ttk.Treeview):
$vTcl(tab)'''A standard ttk Treeview widget with scrollbars that will
$vTcl(tab)automatically show/hide as needed.'''
$vTcl(tab)@_create_container
$vTcl(tab)def __init__(self, master, **kw):
$vTcl(tab)$vTcl(tab)ttk.Treeview.__init__(self, master, **kw)
$vTcl(tab)$vTcl(tab)AutoScroll.__init__(self, master)"
    }
    append ttk_helper \
"

import platform
def _bound_to_mousewheel(event, widget):
$vTcl(tab)child = widget.winfo_children()\[0\]
$vTcl(tab)if platform.system() == 'Windows' or platform.system() == 'Darwin':
$vTcl(tab)$vTcl(tab)child.bind_all('<MouseWheel>', lambda e: _on_mousewheel(e, child))
$vTcl(tab)$vTcl(tab)child.bind_all('<Shift-MouseWheel>', lambda e: _on_shiftmouse(e, child))
$vTcl(tab)else:
$vTcl(tab)$vTcl(tab)child.bind_all('<Button-4>', lambda e: _on_mousewheel(e, child))
$vTcl(tab)$vTcl(tab)child.bind_all('<Button-5>', lambda e: _on_mousewheel(e, child))
$vTcl(tab)$vTcl(tab)child.bind_all('<Shift-Button-4>', lambda e: _on_shiftmouse(e, child))
$vTcl(tab)$vTcl(tab)child.bind_all('<Shift-Button-5>', lambda e: _on_shiftmouse(e, child))

def _unbound_to_mousewheel(event, widget):
$vTcl(tab)if platform.system() == 'Windows' or platform.system() == 'Darwin':
$vTcl(tab)$vTcl(tab)widget.unbind_all('<MouseWheel>')
$vTcl(tab)$vTcl(tab)widget.unbind_all('<Shift-MouseWheel>')
$vTcl(tab)else:
$vTcl(tab)$vTcl(tab)widget.unbind_all('<Button-4>')
$vTcl(tab)$vTcl(tab)widget.unbind_all('<Button-5>')
$vTcl(tab)$vTcl(tab)widget.unbind_all('<Shift-Button-4>')
$vTcl(tab)$vTcl(tab)widget.unbind_all('<Shift-Button-5>')

def _on_mousewheel(event, widget):
$vTcl(tab)if platform.system() == 'Windows':
$vTcl(tab)$vTcl(tab)widget.yview_scroll(-1*int(event.delta/120),'units')
$vTcl(tab)elif platform.system() == 'Darwin':
$vTcl(tab)$vTcl(tab)widget.yview_scroll(-1*int(event.delta),'units')
$vTcl(tab)else:
$vTcl(tab)$vTcl(tab)if event.num == 4:
$vTcl(tab)$vTcl(tab)$vTcl(tab)widget.yview_scroll(-1, 'units')
$vTcl(tab)$vTcl(tab)elif event.num == 5:
$vTcl(tab)$vTcl(tab)$vTcl(tab)widget.yview_scroll(1, 'units')

def _on_shiftmouse(event, widget):
$vTcl(tab)if platform.system() == 'Windows':
$vTcl(tab)$vTcl(tab)widget.xview_scroll(-1*int(event.delta/120), 'units')
$vTcl(tab)elif platform.system() == 'Darwin':
$vTcl(tab)$vTcl(tab)widget.xview_scroll(-1*int(event.delta), 'units')
$vTcl(tab)else:
$vTcl(tab)$vTcl(tab)if event.num == 4:
$vTcl(tab)$vTcl(tab)$vTcl(tab)widget.xview_scroll(-1, 'units')
$vTcl(tab)$vTcl(tab)elif event.num == 5:
$vTcl(tab)$vTcl(tab)$vTcl(tab)widget.xview_scroll(1, 'units')"

    return $ttk_helper
}
#"
proc vTcl:py_build_set_Tk_var {var_list {new yes}} {
    # Build the function which will initialize the Tkinter variables.
    # A lot of code trying to get the blank lines in the right
    # place. Still confused.
    global vTcl
    if {$new == "yes"} {
        append ret \
"def set_Tk_var():"
    }
    set vars {}
    foreach {v m} $var_list {
        set vv $v
        set m ${vTcl(tk_prefix)}$m
        set i [string first . $v]
        if {$i > -1} {
            set v [string range $v  [expr $i + 1] end]
        }
        if {[lsearch -exact $vars $v] == -1} {
            if {[info exists vTcl($v,add_smileyface)] &&
                $vTcl($v,add_smileyface) != 0} {
                # append ret "\n$vTcl(tab)$v.set(':-)')"
                set extra "\n$vTcl(tab)$v.set('$vTcl($v,add_smileyface)')"
                if {$new != "yes"} {
                    append extra "\n"
                }
            } else {
                set extra ""
            }
            if {$new == "yes"} {
                append ret "\n"
            }
            append ret \
"$vTcl(tab)global $v
$vTcl(tab)$v = ${m}()${extra}"
            lappend vars $v
        }
    }
    if {$new != "yes"} {
        append ret "\n"
    }
    return $ret
}


proc vTcl:colorize_python {prefix} {
    global vTcl
    vTcl:syntax_color $vTcl(${prefix}_source_window)
}

proc vTcl:save_python_code {prefix} {
    global vTcl
    # We come here when the user hits the save button on the Python
    # Console. From here we either save the GUI module or the support
    # module depending on the value of vTcl(python_module) which was
    # set in either vTcl:generate_python_UI or
    # vTcl:generate_python_support. I also save the tcl file to be
    # sure that the tcl version and the gui code is in sync on the
    # disk.
    if {$prefix == "supp"  &&  \
        $vTcl(supp_save_warning)  != ""} {
        vTcl:save_support_file
    }
    if {$prefix == "gui"    &&   \
            $vTcl(gui_save_warning)  != ""} {
        vTcl:save
        vTcl:save_gui_file
    }
    $vTcl(${prefix}_source_window) edit modified 0
    update
    set vTcl(${prefix}_save_warning) ""
    set vTcl(${prefix}_search_pattern) ""
}

proc vTcl:save_gui_file {} {
    global vTcl
    # First we make a backup copy of any existing Python file popping
    # it onto a stack of backup files and then we write the new
    # version.  This saves up to five versions.

    # If the module most recently generated is the support module, it
    # was saved as part of the generation so there is nothing to do
    # here.
#    if {$vTcl(python_module) == "Support"} return
    if {$vTcl(project,file) == ""} {
        vTcl:save
    }
    set filename "[file rootname $vTcl(project,file)].py"
    vTcl:save_python_file $filename "gui"
    return 0
}

proc vTcl:py_source_frame {window prefix parentframe} {
    global vTcl
    # Starting entry for analyzing and creating the window.
    #set class [$window cget -class]
    set class [winfo class $window]
    if {$class == "Toplevel"} {
        set menu [$window cget -menu]
        set vTcl(toplevel_menu) $menu
        set vTcl(bind_top) [vTcl:python_dump_bind $window $vTcl(py_classname)]
    }
    if {$prefix!=""} {
        set prefix $prefix\_
    }
    set vTcl(balloon_widgets) ""

    foreach widget [winfo children $window] { # Rozen
        #vTcl:python_source_widget $widget $prefix $parentframe
        vTcl:python_source_widget $widget $prefix $window
    }
}

proc vTcl:py_get_command_parameters {cmdpar} {
    # Confusing. Rozen
    global vTcl
    upvar cmdname lname
    upvar cmdbody lbody
    set lname {}
    set lbody {}
    catch {
        set lname $cmdpar
        if {$lname!=""} {
            foreach line [split $lname "\n"] {
                set line [string trim $line]
                if {[info procs $lname]!=""} {
                    set lbody [info body $lname]
                }
            }
        }
    }

}

proc vTcl:python_parse_menu {menubutton widname {suffix m}} {
    global vTcl
    foreach widget [winfo children $menubutton] {
        if {[winfo class $widget]=="Menu"} {
            set nritems [$widget index end]
            for {set i 0} {$i<=$nritems} {incr i} {
                switch [$widget type $i] {
                    command {
                        vTcl:py_get_command_parameters \
                                [$widget entrycget $i -command]
                        if {$cmdname==""} {
                            set cmdname "$widname\_$i\_click"
                        }
                        append vTcl(py_initfunc) \
                         "$vTcl(tab2)self.$widname\_m$suffix.add_command(label="
                        append vTcl(py_initfunc) \
                                "\"[$widget entrycget $i -label]\","
                        # added to add the accelerator capability.
                        if {[$widget entrycget $i -accel] != ""} {
                            append vTcl(py_initfunc) \
                                    "accel=\"[$widget entrycget $i -accel]\","
                        }
                        append vTcl(py_initfunc) \
                                "command=$cmdname,underline=0)\n"
                    set v $cmdname
                    if {[string first "(" $v] == -1} {
                        append v "()"
                    }
                    lappend vTcl(funct_list) $v
                    }
                    checkbutton { # Like to put in more options
                        vTcl:py_get_command_parameters \
                                [$widget entrycget $i -command]
                        if {$cmdname == ""} {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_checkbutton(label=\"[$widget entrycget $i -label]\""
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                   "accel=\"[$widget entrycget $i -accel]\""
                            }
                        } else {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_checkbutton(label=\"[$widget entrycget $i -label]\",command=$cmdname"
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                   ",accel=\"[$widget entrycget $i -accel]\""
                            }
                        }
                        append vTcl(py_initfunc) ")\n"
                    }
                    radiobutton { # Like to put in more options
                        vTcl:py_get_command_parameters \
                                [$widget entrycget $i -command]
                        if {$cmdname == ""} {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_radiobutton(label=\"[$widget entrycget $i -label]\""
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                    ",accel=\"[$widget entrycget $i -accel]\""
                            }
                        } else {
                            append vTcl(py_initfunc) \
        "$vTcl(tab2)self.$widname\_m$suffix.add_radiobutton(label=\"[$widget entrycget $i -label]\",command=$cmdname"
                            if {[$widget entrycget $i -accel] != ""} {
                                append vTcl(py_initfunc) \
                                    ",accel=\"[$widget entrycget $i -accel]\""
                            }                        }
                        append vTcl(py_initfunc) ")\n"
                    }
                    separator {
                        append vTcl(py_initfunc)  \
                        "$vTcl(tab2)self.$widname\_m$suffix.add_separator()\n"
                    }
                    cascade {
                        set incsuffix ""
                        append incsuffix "m$suffix" "_cas$suffix
                        append vTcl(py_initfunc) \
                                "$vTcl(tab2)self.$widname\_$incsuffix = "
                        append vTcl(py_initfunc) \
                                "Menu(self.$widname\_m$suffix)\n"
                        append vTcl(py_initfunc) \
                                "$vTcl(tab2)self.$widname\_m$suffix.add_cascade(label=\"[$widget entrycget $i -label]\","
                        if {[$widget entrycget $i -accel] != ""} {
                            append vTcl(py_initfunc) \
                                    "accel=\"[$widget entrycget $i -accel]\","
                        }
                        append vTcl(py_initfunc) \
                                "menu=self.$widname\_$incsuffix)\n"
                        set arg_suffix ""
                        append arg_suffix $suffix "_cas$suffix"
                        vTcl:python_parse_menu $widget $widname \
                                $arg_suffix
                    }
                }
            }
        }
    }
}

proc vTcl:python_parse_combo_menu {menubutton widname} {
    global vTcl
    global suffix
    foreach widget [winfo children $menubutton] {
        set suffix [expr $suffix + 1]
        if {[winfo class $widget]=="Menu"} {
            set nritems [$widget index last]
            for {set i 0} {$i<=$nritems} {incr i} {
                set suffix [expr $suffix + 1]
                if {[$widget type $i]=="command"} {
                    vTcl:py_get_command_parameters \
                            [$widget entrycget $i -command]
                    append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname\.add_command(\"z_$suffix\",label="
                    append vTcl(py_initfunc) \
                            "\"[$widget entrycget $i -label]\","
                   append vTcl(py_initfunc) \
                            "underline=0)\n"
                }
                if {[$widget type $i]=="separator"} {

                    append vTcl(py_initfunc) \
                            "$vTcl(tab)$vTcl(tab)self."
                    append vTcl(py_initfunc) \
                            "$widname\.add_separator(\"z_$suffix\")\n"
                }
            }
        }
    }
}


proc vTcl:python_quick_run {base prefix} {
    global vTcl
    global tcl_platform
#    set run [vTcl:run_prep $prefix]
    if {[vTcl:run_prep $prefix] == "OK"} {
        switch $tcl_platform(platform) {
            unix {
                vTcl:python_run_unix $base $prefix
            }
            default {
                vTcl:python_run $base $prefix
            }
        }
    }
}

proc vTcl:run_prep {prefix {save "save"}} {
    # Introduced 12/21/15
    # Save the current content of source window then test if we have
    # both GUI and support modules saved and then execute the GUI
    # module.
    global vTcl global tcl_platform
    update
    vTcl:save_python_code $prefix ;# This will also save the tcl file
                                   # if approprite.
    update
    # Test to see that we have both a GUI module and a support module!
    set fg "[file rootname $vTcl(project,file)].py"
    set fs "[file rootname $vTcl(project,file)]_support.py"
    #set fg "\"[file rootname $vTcl(project,file)].py\""
    #set fs "\"[file rootname $vTcl(project,file)]_support.py\""
    set nogui [expr ![file exists $fg]]
    set nosupp [expr ![file exists $fs]]

    if {$nogui == 1} {
        # set choice [tk_messageBox -title Error -message \
        #     "No GUI module has been created and saved." \
        #     -icon warning \
        #     -type ok]
        set choice [tk_dialog .foo "ERROR" \
                        "No GUI module has been created and saved." \
                        question 0 "OK"]
        return "BAIL"
    }
    if {$nosupp == 1} {
        # set choice [tk_messageBox -title Error -message \
        #     "No support module has been created and saved." \
        #     -icon warning \
        #     -type ok]
        set choice [tk_dialog .foo "ERROR" \
                        "No support module has been created and saved." \
                        question 0 "OK"]
        return "BAIL"
    }
    # Test to see if the GUI python module has been generated after
    # the latest GUI change.
    if {$vTcl(gui_py_change_time) < $vTcl(gui_change_time)} {
        set question "GUI definition has been changed since GUI module created. Do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
                         question 0 "Cancel" "Proceed"]
        if {$choice == 0} {
            return "BAIL"
        }
    }
    # Test to see if support module needs updates.
    set window $vTcl(real_top)
    vTcl:determine_updates $window
    if {([info exists vTcl(must_add_vars)]) || \
            ([info exists vTcl(must_add_procs)])} {
        # There are possible updates.
        set question "Support module missing available updates of functions or TK variables. Do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
             question 0 "Cancel" "Proceed"]
        if {$choice == 0} {
            return "BAIL"
        }
    }
    # Everything OK
    return "OK"
}


proc vTcl:python_run {base prefix} {
    global vTcl
    global tcl_platform
    set root_name [file rootname $vTcl(project,file)]
    set pc .vTcl.gui_console
    set pc $base
    $pc configure -cursor watch
    set pc_output $vTcl(gui_output_window)
    $pc_output delete 1.0 end
    $pc_output insert end "Running $root_name.py ...\n"
    update
    file delete $root_name.output
    if { [catch {set res \
          "[exec python $root_name.py >>& $root_name.output]"} result]} {
        puts stderr $result
    }
    #catch {set res \
            "[exec python $root_name.py >>& $root_name.output]"}
    if {[file exists $root_name.output] && [file size $root_name.output] > 0} {
        set fid [open $root_name.output r]
        while {![eof $fid]} {
            gets $fid line
            $pc_output insert end "$line\n"
        }
        close $fid
    } else {
        $pc_output insert end "No Output"
    }
    $pc configure -cursor {}
    update
}

proc vTcl:python_run_unix {base prefix} {
    global tcl_platform
    # Executes the generated GUI code by opening a pipe to a python
    # process which executes the saved generated python GUI code.
    global vTcl
    #set pc .vTcl.gui_console
    set pc $base
    $pc configure -cursor watch
    set pc_output $vTcl(${prefix}_output_window)
    $pc_output delete 1.0 end
    set root_name [file rootname $vTcl(project,file)]
    $pc_output insert end "Running $root_name.py ...\n"
    update
    #set cmd "python $root_name.py 2>&1"
    set cmd "python \"$root_name.py\""
    # Start the pipe, vTcl(fifo), to the python interpreter
    # running the GUI
    set vTcl(fifo) [open "|$cmd |& cat" {RDWR}]
    # Configure buffering and blocking of the pipe
    fconfigure $vTcl(fifo) -buffering line -blocking 0
    # Link files events, such as close and flush, to the proc
    # vTcl:read_fifo.
    if {$prefix == "gui"} {
        fileevent $vTcl(fifo) readable {vTcl:read_fifo "gui"}
    } else {
        fileevent $vTcl(fifo) readable {vTcl:read_fifo "supp"}
    }
}
proc vTcl:python_run_both {pcommand} {
    global tcl_platform
    # Executes the generated GUI code by opening a pipe to a python
    # process which executes the saved generated python GUI code.
    # NEEDS WORK - doesn't look like I ever call this function.
    global vTcl
    set pc .vTcl.gui_console
    $pc configure -cursor watch
    set pc_output $vTcl(gui_output_window)
    $pc_output delete 1.0 end
    set root_name [file rootname $vTcl(project,file)]
    $pc_output insert end "Running $root_name.py ...\n"
    update
    #set cmd "python $root_name.py 2>&1"
    set cmd "python $root_name.py"
    # Start the pipe, vTcl(fifo), to the python interpreter process
    # running the GUI
    set vTcl(fifo) [open "|$cmd |& $pcommand" {RDWR}]
    # Configure buffering and blocking of the pipe
    fconfigure $vTcl(fifo) -buffering line -blocking 0
    # Link files events, such as close and flush, to the proc
    # vTcl:read_fifo.
    fileevent $vTcl(fifo) readable vTcl:read_fifo
}

proc vTcl:read_fifo {prefix} {
    # Reads the output of the execution pipe whenever a file event
    # such as close or buffer flush occurs. Mated with
    # vTcl:python_run. It adds the line read to output window of the
    # gui_console.
    global vTcl
    set pc_output $vTcl(${prefix}_output_window)
    if {[gets $vTcl(fifo) line] >= 0} {
        $pc_output insert end "$line\n"
    }
    if {[eof $vTcl(fifo)]} {
        close $vTcl(fifo)
        $pc_output insert end "Execution terminated.\n"
    }
    $pc_output see end ;# Last line visible
    update
}

proc vTcl:check_upon_close_button {base prefix} {
    # We check to see if we are closing the Python Console containing a
    # modified support module
    global vTcl
    set exists [winfo exists $vTcl(${prefix}_code_window)]
    if {!$exists} return
    if {$vTcl(${prefix}_save_warning) != ""} {
            set reply [tk_dialog .foo "Save Question" \
                       "Do you wish to save the content of the Console" \
                       question 1 "Save" "Abandon"]
        switch $reply {
            0 {
                vTcl:save_python_code $prefix
            }
            1 {
                # Abandon
            }
        }
    }
    Window hide $base
    update
    return
}

proc vTcl:search_text {prefix} {
    # searches the Python console, the one determined by 'prefix', for
    # the string specified by the variable, 'search_pattern', treated
    # as a regexp. Highlight the string found.
    global vTcl
    switch $prefix {
        callback {
            set source_window $::vTcl(gui,callback).cpd21.03
            set bg plum
        }
        default {
            set source_window $vTcl(${prefix}_source_window)
            set bg yellow
        }
    }
    #set source_window $vTcl(${prefix}_source_window)
    set patt $vTcl(${prefix}_search_pattern)
    if {$patt == ""} {
        # No pattern given.
        return
    }
    $source_window tag remove highlight 1.0 end ;# Remove existing highlight.
    # The "-count cnt" below is the number of characters matched.
    set index [$source_window search -regexp -count cnt $patt insert]
    if {$index != ""} {
        if {$prefix == "callback"} {
            # This cause the search to set selection to the matched string.
            $source_window tag add sel $index "$index+${cnt}c"
        } else {
            $source_window mark set insert "$index+${cnt}c"
            $source_window see $index
            $source_window tag add highlight $index insert
            $source_window tag configure highlight -background $bg
        }
    } ;# end if
}
proc vTcl:text_top {prefix} {
    global vTcl
    switch $prefix {
        callback -
        tree {
            set source_window $::vTcl(gui,$prefix).cpd21.03
        }
        default {
            set source_window $vTcl(${prefix}_source_window)
        }
    }
    $source_window mark set insert 1.0
    $source_window see insert
}


proc vTcl:Window.py_console {type} {
    # Builds the  Python Console
    global vTcl
    set prefix $type
    set base .vTcl.${prefix}_console
    if {[winfo exists $base]} {
        wm deiconify $base; raise $base
        return
    }
    set top $base
    set vTcl(${prefix}_save_warning) ""
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -background $vTcl(actual_bg) ;# 11/22/12
    wm focusmodel $top passive
    wm withdraw $base
    wm transient $base .vTcl
    set maxs [wm maxsize .]
    foreach {maxx maxy} $maxs {}
    set start_h [expr $maxy - (50*4)]

    wm geometry $top 800x$start_h+100+50; update
    #wm maxsize $top 1905 1170
    wm maxsize $top $maxx $maxy
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    if {$prefix == "gui"} {
        set window_name "GUI"
    } else {
        set window_name "Support"
    }
    #set window_name [string toupper $prefix]
    wm title $top "$window_name Console"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toolorplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ttk::style configure PyConsole.TLabelframe \
        -background $vTcl(actual_bg) ;# 11/22/12
    ttk::style configure PyConsole.TLabelframe.Label \
        -foreground $vTcl(actual_bg) \
        -background $vTcl(actual_bg) ;# 11/22/12
    ttk::style configure PyConsole.TPanedwindow \
        -background $vTcl(actual_bg) ;# 11/22/12
    ttk::style configure PyConsole.TSizegrip \
        -background $vTcl(actual_bg) ;# 11/22/12

    ttk::style configure Horizontal.TScrollbar \
        -background $vTcl(actual_bg)  -foreground $vTcl(actual_fg)
    ttk::style configure Vertical.TScrollbar \
        -background $vTcl(actual_bg) -foreground $vTcl(actual_fg)


    ttk::panedwindow $top.tPa42 -orient vertical \
        -style "troughcolorPyConsole.TPanedwindow"
    #ttk::panedwindow $top.tPa42 \
    #    -orient vertical -width 800 -height 900
    ttk::labelframe $top.tPa42.f1 \
        -style "PyConsole.TLabelframe" \
        -text {Generated Python} ;# -height 750

    $top.tPa42 add $top.tPa42.f1

    ttk::labelframe $top.tPa42.f2 \
        -style "PyConsole.TLabelframe" \
        -text {Execution Output} ;# -height 100
    $top.tPa42 add $top.tPa42.f2

    # Code goes into this text widget.
    text $top.tPa42.f1.01  -background #eff0f1 -foreground black \
        -xscrollcommand "$top.tPa42.f1.02 set"\
        -yscrollcommand "$top.tPa42.f1.03 set" \
        -insertborderwidth 3

    set text_window $top.tPa42.f1.01
    set vTcl(${prefix}_code_window) $top.tPa42.f1.01

    scrollbar $top.tPa42.f1.02  -command "$top.tPa42.f1.01 xview" \
        -orient horizontal
    scrollbar $top.tPa42.f1.03  -command "$top.tPa42.f1.01 yview"
    grid $top.tPa42.f1.01  -in $top.tPa42.f1 -column 0 -row 0 -columnspan 1 \
        -rowspan 1 -sticky nesw
    # Since the text window has the attribute "wrap", it will never
    #need the horizontal scrollbar and so I commented out the
    #following line.
    #grid $top.tPa42.f1.02 -in $top.tPa42.f1 -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $top.tPa42.f1.03  -in $top.tPa42.f1 -column 1 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ns
    # Rozen Added row, column config stuff so that it would resize properly.
    grid rowconfigure $top.tPa42.f1 0 -weight 1
    grid columnconfigure $top.tPa42.f1 0 -weight 1

    # Bindings for the mousewheel.
    bind $top.tPa42.f1.01 <Button-4> [list %W yview scroll -5 units]
    bind $top.tPa42.f1.01 <Button-5> [list %W yview scroll 5 units]
    # Color below was white or #ececec
    text $top.tPa42.f2.01  -background #eff0f1 -foreground black \
         -xscrollcommand "$top.tPa42.f2.02 set"\
         -yscrollcommand "$top.tPa42.f2.03 set"


    scrollbar $top.tPa42.f2.02  -command "$top.tPa42.f2.01 xview" \
        -orient horizontal

    scrollbar $top.tPa42.f2.03  -command "$top.tPa42.f2.01 yview"

    grid $top.tPa42.f2.01  -in  $top.tPa42.f2 -column 0 -row 0 -columnspan 1 \
         -rowspan 1 -sticky nesw
    grid $top.tPa42.f2.02  -in $top.tPa42.f2 -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $top.tPa42.f2.03  -in $top.tPa42.f2 -column 1 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ns
    # Rozen Added row, column config stuff so that it would resize properly.
    grid rowconfigure $top.tPa42.f2 0 -weight 1
    grid columnconfigure $top.tPa42.f2 0 -weight 1

    # Bindings for the mousewheel.  Both of the following approaches work.
    bind $top.tPa42.f2.01 <Button-4> [list %W yview scroll -5 units]
    bind $top.tPa42.f2.01 <Button-5> [list %W yview scroll 5 units]

    # Hopefully this will help the mousewheel in Windows by setting the focus.
    # Removed because I didn't like it popping up when I crossed a corner.7-14-18
    #bind $top.tPa42.f1.01 <Enter> {focus %W}
    #bind $top.tPa42.f2.01 <Enter> {focus %W}

    frame $top.butframe  -height 40  ;#     # 6/9/09
# -----------------
    # Save button
    button $top.butframe.but33 \
        -text Save -command "vTcl:save_python_code $prefix" \
        -background $vTcl(actual_bg) -foreground $vTcl(actual_fg)
    # save label
    label $top.butframe.lab14 \
        -textvariable vTcl(${prefix}_save_warning)
    # Run button
    button  $top.butframe.but34 \
        -text Run -command "vTcl:python_quick_run $base $prefix" \
        -background $vTcl(actual_bg) -foreground $vTcl(actual_fg)

    # Search entry
    entry $top.butframe.ent14 \
        -textvariable vTcl(${prefix}_search_pattern)

    button $top.butframe.but36 \
        -text Search \
        -command "vTcl:search_text $prefix" \
        -background $vTcl(actual_bg) -foreground $vTcl(actual_fg)

    button $top.butframe.but37 \
        -text Top \
        -command "vTcl:text_top $prefix" \
        -background $vTcl(actual_bg) -foreground $vTcl(actual_fg)

# ------------------
    button  $top.butframe.but35 \
        -text Close -command "vTcl:check_upon_close_button $base $prefix" \
        -background $vTcl(actual_bg)  -foreground $vTcl(actual_fg)

    place $top.butframe.but33 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.02 -y 5

    # save label
    place $top.butframe.lab14 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.13 -y 8

    place $top.butframe.but34 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.34 -y 5   ;# Run button
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    place $top.butframe.ent14 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.45 -y 8

    place $top.butframe.but36 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.70 -y 5

    place $top.butframe.but37 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.80 -y 5
# !!!!!!!!!!!!!!!!!!!!!!!!!!!
    place $top.butframe.but35 \
        -in $top.butframe  -anchor nw -bordermode ignore \
        -relx 0.88 -y 5

    place [ttk::sizegrip $top.sz -style "PyConsole.TSizegrip"] \
        -relx 1.0 -rely 1.0 -anchor se
#grid [ttk::sizegrip $top.butframe.sz] -column 999 -row 999 -sticky se
#pack [ttk::sizegrip $top.butframe.sz] -side right -anchor se
#place [ttk::sizegrip $top.butframe.sz] -in $top.butframe \
-anchor se

    ####################
    # SETTING GEOMETRY #
    ####################

    # Added 6/9/09
    grid $top.tPa42 -in $top -column 0 -row 0 -sticky news
    grid $top.butframe -in $top -column 0 -row 1 -sticky news
    grid rowconfigure $top 0 -weight 1
    grid columnconfigure $top 0 -weight 1

    # 6/9/09
    #pack $top.tPa42 -in $top -expand true -fill both -side top
    #pack $top.butframe -in $top  -fill x -side bottom
    # The purpose of the following is to overwrite the geometry stuff
    # above with the geometry which has been saved in the preferences.
    catch {wm geometry $base \
               $vTcl(geometry,$base)}
    set old_geometry [wm geometry $base]
    set old_height [split $old_geometry "x+"]
    set old_height [lindex $old_height 1]
    set vTcl(old_height) old_height
    # The following if-the-else needed because the second parameter is
    # a script which is not exercised until the event occures at which
    # point the local variable prefix does not exist. Don't know what
    # else to do! 1/9/16
    update
    if {$prefix == "gui"} {
        bind $base <Configure> {
            set new_geometry [wm geometry .vTcl.gui_console]
            set new_height [split $new_geometry "x+-"]
            set new_height [lindex $new_height 1]
            if {$new_height != $vTcl(old_height)} {
                set pos [expr int($new_height * 0.8)]
                set pos [min $pos [expr int($new_height) - 150]]
                .vTcl.gui_console.tPa42 sashpos 0 $pos
            }
            set vTcl(old_height) $new_height
        }
        bind $top.butframe.ent14 <Return> {vTcl:search_text "gui"}
    } else {
        bind $base <Configure> {
            set new_geometry [wm geometry .vTcl.supp_console]
            set new_height [split $new_geometry "x+-"]
            set new_height [lindex $new_height 1]
            if {$new_height != $vTcl(old_height)} {
                set pos [expr int($new_height * 0.8)]
                set pos [min $pos [expr int($new_height) - 150]]
                .vTcl.supp_console.tPa42 sashpos 0 $pos
            }
            set vTcl(old_height) $new_height
        }
        bind $top.butframe.ent14 <Return> {vTcl:search_text "supp"}
    }

    focus $top.butframe.but34     ;# Rozen 10/20/12
    update idletasks

    if {[info exists vTcl(${prefix}_sash)]} {
        $top.tPa42 sashpos 0 [expr int($vTcl(${prefix}_sash))]
    } else {
        set size [wm geometry $top]
        set size [split $size "x+-"] ;# minus cause window geometry
                                      # might be to far right
        set pos [lindex $size 1]
        set pos [expr int($pos * 0.8)]
        $top.tPa42 sashpos 0 $pos
    }

    vTcl:FireEvent $base <<Ready>>

    bind $base <Control-q> {vTcl:quit}
    ;# Rozen 3/31/14
    bind $base <Control-p> {vTcl:generate_python_UI}
    bind $base <Control-u> {vTcl:generate_python_support}
    bind $base <Control-i> {vTcl:load_python_idle}

    if {$prefix == "gui"} {
        bind $base <Control-r> {vTcl:python_quick_run .vTcl.gui_console "gui"}
        bind $base <Control-w> {vTcl:check_upon_close_button \
                                    .vTcl.gui_console "gui"}
    } else {
        bind $base <Control-r> {vTcl:python_quick_run .vTcl.supp_console "supp"}
        bind $base <Control-w> {vTcl:check_upon_close_button \
                                    .vTcl.supp_console "supp"}
    }
    # save label
    if {$prefix == "gui"} {
        bind $vTcl(gui_code_window) <<Modified>> {
            set vTcl(gui_save_warning) "Unsaved changes"
        }
    } else {
        bind $vTcl(supp_code_window) <<Modified>> {
            set vTcl(supp_save_warning) "Unsaved changes"
        }
    }

    set vTcl(${prefix}_source_window)   $top.tPa42.f1.01
    set vTcl(${prefix}_output_window)   $top.tPa42.f2.01
} ;# End vTcl:Window.vTcl.py_console


proc  vTcl:build_treeview_support {target widname cmdname widclass} {
    # This routine rounds out the support of the scrolledtreeview by
    # creating columns, and assigning them characteristics.
    global vTcl
    set cols [$target cget -columns]
    set column_names [concat "#0" $cols]
    foreach c $column_names {
            set heading($c) [$target heading $c]
            set column($c) [$target column $c]
    }
    foreach c $column_names {
        foreach {o v} $heading($c) {
            if {$v == ""} continue
            if {[string range $o 0 0] == "-"} {
                set sub [string range $o 1 end]
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.heading(\"$c\",$sub=\"$v\")\n"
        }
        foreach {o v} $column($c) {
            if {$v == ""} continue
            if {$o == "-id"} continue
            if {[string range $o 0 0] == "-"} {
                set sub [string range $o 1 end]
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.column(\"$c\",$sub=\"$v\")\n"
        }
    }
}

proc vTcl:gen_file_desc {block} {
    # I use this to transform something like "\{DajaVue Sans\} 9 bold" into
    # "-family {DajaVue Sans} -size 9 -weight bold".

    # We need to split the block up into words but cannot use
    # list operations as they throw away some significant
    # quoting, and [split] ignores braces as it should.
    while {[string length $block]} {
        # Look for the next word containing a quote: { }
        if {[regexp {[^ ]*(\{.*\})(.*)} $block match word rest]} {
             set block [string trim $rest]
             lappend words $word
        } else {
            # Take everything up to the end of the block ans split it.
            lappend words {*}[split $block]
            set block {}
        }
    }
    return $words
}

proc vTcl:transform_font_variable {v} {
    # NEEDS WORK May not neet the following two tests.
    # Fonts added by PAGE have the form font[0-9]*
    if {[regexp "font\[0-9\]*" $v]} {
        return $v
    }
    # System fonts have the form Tk[a-zA-Z]*Font, we need to quote it.
    if {[regexp "Tk\[a-zA-Z\]*Font" $v]} {
        return $v
    }
    set words [vTcl:gen_file_desc $v]
    set params {-family -size -weight -slant -underline -overstrike}
    set parm_index 0
    set desc ""
    foreach word $words {
        append desc [lindex $params $parm_index] " " $word " "
        incr parm_index
    }
    set desc [string trim $desc]
    return $desc
}



proc vTcl:prepend_import_name {cmd_exp {widname ""}} {
    global vTcl
    set first_period [string first "." $cmd_exp]
    set paren [string first "(" $cmd_exp]
    if {$first_period > -1 && $paren > -1 && $first_period < $paren} {
        # String already is qualified with a module name, possibly "self".
        return $cmd_exp
    }

    # I assume that the $cmd_exp has already been trimmed.
    if {$widname == ""} {
        set sub_name $vTcl(import_name)

    } else {
        set sub_name $widname
    }
    if {[string first "lambda" $cmd_exp] == 0} {
        # Extract the non lambda part of the function name
        set index [string first ":" $cmd_exp]
        set exp [expr $index + 1]
        # r will be the non lambda part
        set r [string range $cmd_exp [expr $index + 1] end]
        set r [string trim $r]
        #set new_cmd [string replace $cmd_exp $exp $exp $vTcl(import_name).]
        set new_cmd [string replace $cmd_exp $exp end $sub_name.$r]
    } else {
        set new_cmd $sub_name.$cmd_exp
    }
    return $new_cmd
}

proc vTcl:python_configure_widget {widget widname cmdname \
                                       widclass {name ""} {menu_name ""}} {
    global vTcl
    global color
    # Obtains a list of all attributes of the widget, checks to see if
    # the current value differs from the default value.  If it does, then
    # puts adds the configuration statement for that value.
    set opt [$widget configure]
    set active_fg_there 0
    foreach op $opt {
        foreach {o x y d v} $op {}
        set v [string trim $v]
        if {$o == "-activeforeground"} {
            set active_fg_there 1
        }

    }

    # Above returns a list of lists. The values are:
    #              argvName,  dbName,  dbClass,  defValue, and current value
    if {$name == ""} {\
        set name "self.$widname"
    }
    set class [vTcl:get_class $widget]
    foreach op $opt {
        foreach {o x y d v} $op {}
        set v [string trim $v]

        if {$d == $v} {
            continue   ;# If value == default value bail.
        }
        # The following is here because the TRadiobutton has a really
        # weird default value.
        if {$x == "variable"} {
            if {$v == ""} continue
        }
        set len [string length $o]
        set sub [string range $o 1 end]
        switch -exact -- $sub {
            padX -
            padY -
            dropdown -
            editable -
            height -
            fancy {
            }
            xscrollcommand -
            yscrollcommand {

                # There is a question here whether I really want
                # to support separate scrollbars.  I think that now
                # the answer is no.

            }
            textvariable {
                if {[string first "self." $v] == 0} {
                    if {[lsearch -exact $vTcl(l_v_list) $v] == -1} {
                        # Class variable.
                        append vTcl(py_initfunc) \
                        "$vTcl(tab2)$v = StringVar()\n"
                        lappend vTcl(l_v_list) $v
                        set local_var 1
                    }
                #} elseif {[string first . $v] >= 0} {
                #    # Variable in imported module
                #    set vTcl(supp_variables) 1
                } else {
                    # Global variable
                    set local_var 0
                    if {[lsearch -exact $vTcl(g_v_list) $v] == -1} {
                        set vTcl(global_variable) 1
                        set l [list $v "StringVar"]
                       #lappend vTcl(g_v_list) $l
                        lappend vTcl(g_v_list) $v StringVar
                    }
                }
                #                    append vTcl(py_initfunc) \tMe36_m
                #append vTcl(py_initfunc) \
                #    "$vTcl(tab2)$self..configure($sub=$v)\n"
                if {$local_var == 0} {
                    set v [vTcl:prepend_import_name $v]
                }
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.configure($sub=$v)\n"
                #lappend  vTcl(g_v_list) $v $m  CHECK This OUT!! What is $m.
            }
            listvariable -
            variable {
                if {[string bytelength $v] == 0} {
                    vTcl:error "No variable specified for $widget"
                }
                if {[string first :: $v] != -1} {
                    vTcl:error "Illegal variable $v specified in $widget"
                }
                # First some code to see if class or global variable
                # is wanted, I will tell by checking if 'self.' is
                # part of the name.
                if {[string first self. $v] == 0} {
                    # Class variable.
                    if {[lsearch -exact $vTcl(l_v_list) $v] == -1} {
                        switch $widclass {
                            "Scrolledlistbox" -
                            "Checkbutton" -
                            "TCheckbutton" -
                            "Radiobutton" -
                            "TRadiobutton" {
                                append v
                                    "$vTcl(tab2)$v = StringVar()\n"
                            }
                            "TScale" -
                            "Scale" {
                                append vTcl(py_initfunc) \
                                    "$vTcl(tab2)$v = DoubleVar()\n"
                            }
                            "TProgressbar" {
                                append vTcl(py_initfunc) \
                                    "$vTcl(tab2)$v = IntVar()\n"
                            }
                        }
                        lappend vTcl(l_v_list) $v
                    }
                #} elseif {[string first . $v] >= 0} {
                #    # Variable in imported module
                #    set vTcl(supp_variables) 1
                } else {
                    # Global variable
                    if {[lsearch -exact $vTcl(g_v_list) $v] == -1} {
                        set vTcl(global_variable) 1
                        switch $widclass {
                            "Scrolledlistbox" -
                            "Checkbutton" -
                            "TCheckbutton" -
                            "Listbox" -
                            "Radiobutton" -
                            "TRadiobutton" {
                                set m StringVar
                            }
                            "TScale" -
                            "Scale" {
                                set m DoubleVar
                            }
                            "TProgressbar" {
                                set m IntVar
                            }
                        }
                        set l [list $v $m]
                        #lappend vTcl(g_v_list) $l
                        lappend vTcl(g_v_list) $v $m
                    }
                }
                set v [vTcl:prepend_import_name $v]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.configure($sub=$v)\n"
            }
            validatecommand -
            invalidcommand {
                # The value, v, looks like (vcmd, '%P' ...) so pull out the name
                set check [vTcl:check_validate_cmd $v]
                if {!$check} {vTcl:invalid_syntax_response $widget}
                regexp {[a-zA-Z0-9_]+} $v vvv
                set vv [vTcl:prepend_import_name $vvv]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$vvv = self.$widname.register($vv)\n"

                lappend vTcl(validate_function_list) $vvv
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$v)\n"
            }
            command {
                if {[string first xview $v] > -1} {
                    set blank_index [string first " " $v]
                    set nm [string range $v 1 [expr $blank_index-1]]
                    set nm_wid [vTcl:widget_2_widname $nm]
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=self.$nm_wid.xview)\n"
                } elseif {[string first yview $v] > -1} {
                    set blank_index [string first " " $v]
                    set nm [string range $v 1 [expr $blank_index-1]]
                    set nm_wid [vTcl:widget_2_widname $nm]
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=self.$nm_wid.yview)\n"
                } else {
                    set vv $v
                    #if {[string first "(" $vv] == -1} {
                        # If we don't have any parameters make an
                        # empty parameter list.
#NEEDS WORK Check to see if we need the next command
                        #append vv "()"
                    #}
                    set v [vTcl:prepend_import_name $v]
                    lappend vTcl(funct_list) $vv
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=$v)\n"
                }
            }
            opencmd -
            closecmd -
            browsecmd {
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$v)\n"
            }
            menu {
                #set menu $v
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$menu_name)\n"
            }
            image {
                # NEEDS WORK Consolidate (use  vTcl:python_create_image)
                set file_name $vTcl(imagefile,$v)
                # Try for relative path.
                set file_name [vTcl:relTo $file_name [pwd]]
                set image_name self._img$vTcl(image_count)
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$image_name = tk.PhotoImage(file=\"$file_name\")\n"
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$image_name)\n"
                #append vTcl(py_initfunc) \
                     "$vTcl(tab2)$name.image = $image_name\n"
                incr vTcl(image_count)

            }
            values {
                # Used by Spinbox and Combobox.
                set values_list {}
                append values_list "\["

                foreach value $v {
                    if {$value == ""} continue
                    append values_list $value ","
                }
                append values_list "\]"
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.value_list = $values_list\n"
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=self.value_list)\n"
            }
            font {
                # Here we have to look up the font and then issue the statements.
                # The first thing to do is remove any blanks in v.
#                 set font_names [font names]
#                 if {[lsearch $font_names $v] == -1} {
                if {[regexp "^font\[0-9\]+$" $v]} {
                     # Remember that we used it.
                     lappend vTcl(fonts_used) $v
                 } else {
                    # Not one of the added fonts
                    set v "\"$v\""
                }
                # if {[regexp "^font\[0-9\]+$" $v] == 0} {
                #     # Not one of the added fonts
                #     set v "\"$v\""
                #  } else {
                #      # Remember that we used it.
                #      lappend vTcl(fonts_used) $v
#                     append vTcl(py_initfunc) \
#                         [split_long_font_string "$vTcl(tab2)$v = \"$v\""]
# dmsg inside else 14
# dpr vTcl(py_initfunc)
                #}

#                     set v [vTcl:transform_font_variable $v]

# #                     if {[info exists vTcl(fonts_defined,$v)] == 0} {
# #                         if {[info exists vTcl(fonts,$v,font_descr)]} {
# # dmsg if clause
# #                             # If we have a font description, we use it.
# #                             set desc $vTcl(fonts,$v,font_descr)
# #                         } else {
# #                             # Otherwise we create it.
# # dmsg else clause
# #                             set desc [vTcl:font:add_font $v user]
# # dpr desc
# #                             #set desc [font actual $v]
# #                             #set vTcl(fonts,$v,font_descr) $desc
# #                         }
# #                         append vTcl(py_initfunc) \
# #                             [split_long_font_string \
# #                                  "$vTcl(tab2)$desc = \"$v\""]
# #                                  #"$vTcl(tab2)$v = \"$desc\""]
# #                         # Remember that we created it.
# #                         set vTcl(fonts_defined,$v) 1
# #                     } else {
# # dmsg spot else two
# #                     }
#                     # Trial
#                     # Just add the font and see what happens.
#                     set fo_new [vTcl:font:add_font $v stock]
#                     lappend vTcl(fonts_used) $font_new
#                     set desc $font_new
#                     if {[info exists vTcl(fonts_defined,$v)] == 0} {
#                         #append vTcl(py_initfunc) \
#                             [split_long_font_string \
#                                  "$vTcl(tab2)$desc = \"$v\""]
#                                  #"$vTcl(tab2)$v = \"$desc\""]
#                         # Remember that we created it.
#                         set vTcl(fonts_defined,$v) 1
#                     }
                # } else {
                #     # v is all ready a good font name.
                #     set desc $v
                #     lappend vTcl(fonts_used) $v
                #     if {[regexp "Tk\[a-zA-Z\]*Font" $v]} {
                #         set desc \"$v\"
                #     }
                # }

                #set vv [check_default_font $v]   ;#  10-17-13
                #append vTcl(py_initfunc) \
                             "$vTcl(tab2)$name.configure($sub=$desc)\n"
                append vTcl(py_initfunc) \
                             "$vTcl(tab2)$name.configure($sub=$v)\n"
            }
            class {}
            #height -
            width {
                # I don't want to configure the widget with height and
                # width because in some cases values are interpreted
                # as character widths and in others in terms of
                # pixels.  Rather let us specify them in the call to
                # place where the values seem to be in units of
                # pixels.

                # It seem as though I do need this for Message
                # Widgets. 10/16/12
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=$v)\n"
            }
            text {
                # I may have a problem with multiline text.
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=\'\'\'$v\'\'\')\n"
            }
            orient {
                if {$widclass != "TPanedwindow"} {
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
                }
            }
            background {
                if {$v == $vTcl(bgcolor)} {
                    if {![info exists classes($class,ttkWidget)]} {
                        # The widget is not a ttkwidget
                        append vTcl(py_initfunc) \
                            "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
                    }
                } else {
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
                }
            }
            activebackground {
                set active_bg $v
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
                if {$active_fg_there == 1 &&
                    [::colorDlg::dark_color $active_bg]  == 1 } {
                    append vTcl(py_initfunc) \
                      "$vTcl(tab2)$name.configure(activeforeground=\"white\")\n"
                }
            }
            align -
            anchor -
            relief -
            state -
            orient -
            selectmode -
            style -
            wrap -
            justify {
                if {$widclass == "PNotebook" && $sub == "style"} {
                    append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=PNOTEBOOK)\n"
                } else {
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)$name.configure($sub='$v')\n"
                }
            }
            from -
            to {
                continue
            }
            default {
                if {$sub == "from"} {
                    set sub "from_"
                }
                if {[info exists color($v)]} {
                    if {$d == $color($v)} {
                        # The color name corresponds to the Hexadecimal
                        # default. So bail
                        continue
                    }
                }
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)$name.configure($sub=\"$v\")\n"
            }
        }
    }
}

proc vTcl:python_add_special_opt_to_optlist {option target} {
    global vTcl
    lappend vTcl(w,optlist) $option
    set vTcl(w,opt,$option) ""
    if {[info exists vTcl(w,opt,$option,$target)] != 0} {
        set vTcl(w,opt,$option) $vTcl(w,opt,$option,$target)
        if {[info exists vTcl(special_attributes)] == 0} {
            lappend vTcl(special_attributes) vTcl(w,opt,$option,$target)
        } else {
            if {[lsearch $vTcl(special_attributes) \
                    vTcl(w,opt,$option,$target)] == -1} {
                lappend vTcl(special_attributes) vTcl(w,opt,$option,$target)
            }
        }
    }
}

# Utility  Similar to vTcl:lib_tix:dump_subwidgets.
# Generate source code for the subwidgets of a megawidget.
proc vTcl:python_source_subwidgets {subwidget parentframe} {
    global vTcl
    # set widget_tree [vTcl:widget_tree $subwidget]
    # The above nets me all of the widgets in the subtree.
    # Things appeared at two levels in NoteBook pages, for instance.
    # However, if a subwidget is a container widget, I
    # expect it to handle its own subwidgets.  Therefore,
    # I do not want this procedure to look inside a
    # container subwidget.  I think I will try the following:
    set widget_tree [vTcl:get_children $subwidget]
    foreach i $widget_tree {
        set basename [vTcl:base_name $i]
        # don't try to source subwidget itself
        if {"$i" != "$subwidget"} {
            #set class [vTcl:get_class $i]
            #set pc [vTcl:get_class $parentframe]
            set pframe [ vTcl:widget_2_widname $subwidget] ;# New
            #vTcl:python_source_widget $i ""  $pframe
            vTcl:python_source_widget $i ""  $subwidget
        }
    }
    return
}

proc vTcl:split_line {str} {

    # An attempt to keep lines from wrapping, especially those with
    # relative placement.  If line is longer than max_l then back up
    # to last comma and see if it fits, etc.

    #return $str
    global vTcl
    set max_l 80
    set len [string length $str]
    if {$len <= $max_l} {
        return $str
    }

    if {[string first "\n" $str] > -1 } {
        set cr 1
    } else {
        set cr 0
    }
    set trim_str [string trimright $str]
    set pieces [split $trim_str ,]
    # Algorithm:
    # set chunk ""
    # while a chunk is left append chunk next piece.
    # If chunk shorter than max
    #   while another chunk will fit, add it.
    #   otherwise add the \n and add to output.
    #
    set ind 0
    set l_size [llength $pieces]
    set chunk ""
    while {$ind < $l_size} {
        if {$ind == 0} {
            append chunk [lindex $pieces $ind]
        } else {
            append chunk "," [lindex $pieces $ind]
        }
        incr ind
        while {$ind <= $l_size} {
            set l_chuck [string length $chunk]
            set l_next [string length [lindex $pieces $ind]]
            set t_len [expr $l_chuck + $l_next]
            if {$t_len > $max_l} {
                append output $chunk "\n"
                set chunk "$vTcl(tab2)$vTcl(tab2)"
                break
            } else {
                if {$ind == $l_size} {
                    append output $chunk
                } else {
                    #look at the space below.
                    append chunk ", " [string trim [lindex $pieces $ind]]
                }
                incr ind
            }
        }
    }
    if {$cr} {
        # add final newline, if needed.
        append output "\n"
    }
    return $output
}

proc vTcl:get_bmc {parent} {
    # Determines whether we need to include the bordermode option. It
    # appears we need it iff the parent is a labelframe.
    set parent_class [vTcl:get_class $parent]
    if {$parent_class == "Labelframe" ||$parent_class == "TLabelframe"} {
        set bmc ", bordermode='ignore'"
    } else {
        set bmc ""
    }
    return $bmc
}

proc vTcl:relative_placement {{parent {}}} {
    global vTcl
    global rel
    set bmc [vTcl:get_bmc $parent]
    if {$vTcl(pr,relative_placement)} { ;# Most common case
        append str \
         "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx), rely=$rel(rely), "
        append str \
            "relheight=$rel(relh), relwidth=$rel(relw)$bmc)\n"
    } else {
        # I am not supporting this as of 3/14/18. It's back 5/18/18
        set y $rel(y)
        append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x), y=$y, "
        append str \
            "height=$rel(h), width=$rel(w)$bmc)\n"
    }
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:entry_placement {{parent {}}} {
    # For entry widgets, I don't want to constrain the height so that
    # there will be room for scroll bars without eating into the
    # entry field itself.`
    global vTcl
    global rel
    set bmc [vTcl:get_bmc $parent]
    if {$vTcl(pr,relative_placement)} { ;# Most common case
        append str \
          "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx), rely=$rel(rely),"
        append str \
            "height=$rel(h), relwidth=$rel(relw)$bmc)\n"
    } else {
        set y $rel(y)
        append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x), y=$y, "
        append str \
            "height=$rel(h), width=$rel(w)$bmc)\n"
    }
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:scale_placement {widget parent} {
    # For the placement of scales one wants relative placement and
    # relative widths for horizontal scales and relative height for
    # vertical ones.
    global vTcl
    global rel
    set parent_class [vTcl:get_class $parent]
    set bmc [vTcl:get_bmc $parent]
    if {$vTcl(pr,relative_placement)} { ;# Most common case
        set o [$widget cget -orient]
        append str \
         "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx), rely=$rel(rely),"
        if {$o == "horizontal"} {
            append str \
                "relwidth=$rel(relw), relheight=0.0, height=$rel(h),"
            append str "bordermode='ignore')\n"
        } else {
            append str \
                "relwidth=0.0, relheight=$rel(relh), width=$rel(w),"
            append str "bordermode='ignore')\n"
        }
    } else {
        set y $rel(y)
        append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x), y=$y,"
        append str "height=$rel(h), width=$rel(w)$bmc)\n"
    }
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:separator_placement {widget parent} {
    # For the placement of scales one wants relative placement and
    # relative widths for horizontal scales and relative height for
    # vertical ones.
    global vTcl
    global rel
    set bmc [vTcl:get_bmc $parent]
    set o [$widget cget -orient]
    if {$vTcl(pr,relative_placement)} { ;# Most common case
        set parent_geometry [winfo geometry $parent]
        foreach {W H X Y} [split $parent_geometry "x+"] {}  ;# new 4/3/17
        append str \
         "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx), rely=$rel(rely),"
        if {$o == "horizontal"} {
            set width [place configure $widget -width]
            set width [lrange $width end end]
            set relw [expr $width / $W.0]
            set relw [expr {round($relw*1000)/1000.0}]
            append str " relwidth=$relw$bmc)\n"
        } else {
            set height [place configure $widget -height]
            set height [lrange $height end end]
            set relh [expr $height / $H.0]
            set relh [expr {round($relh*1000)/1000.0}]
            append str " relheight=$relh$bmc)\n"
        }
    } else {
        set y $rel(y)
        append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x), y=$y,"
        if {$o == "horizontal"} {
            set width [place configure $widget -width]
            set width [lrange $width end end]
            append str " width=$width$bmc)\n"
        } else {
            set height [place configure $widget -height]
            set height [lrange $height end end]
            append str " height=$height$bmc)\n"
        }
    }
    append vTcl(py_initfunc) [vTcl:split_line $str]

}

proc vTcl:progressbar_placement {{parent {}}} {
    # For placement of progress bars on wants something like
    # horizontal scale_placement above.
    global vTcl
    global rel
    set bmc [vTcl:get_bmc $parent]
    if {$vTcl(pr,relative_placement)} { ;# Most common case
        append str \
         "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx), rely=$rel(rely),"
        append str \
     "relwidth=$rel(relw), relheight=0.0, height=$rel(h)$bmc)\n"
    } else {
        set y $rel(y)
        append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x), y=$y,"
        append str " width=$rel(w), height=$rel(h)$bmc)\n"
    }
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:fixed_placement {} {
    global vTcl
    global rel
    append str \
        "$vTcl(tab2)self.$rel(widname).place(x=$rel(x), y=$rel(y), "
    append str " height=$rel(h), width=$rel(w)$bmc)\n"
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:relative_x_y {{parent {}}} {
    # Generates the place command for the widget based on whether or
    # not the relative flag is set. If set then the parameters relx,
    # rely, relwidth and relheight are set otherwise just x and
    # y. When I wrote this I expected to have a user option to turn it
    # on or off.  I have since decided not to make this an option.
    global vTcl
    global rel
    set bmc [vTcl:get_bmc $parent]
    if {$vTcl(pr,relative_placement)} { ;# Most common case
        append str \
         "$vTcl(tab2)self.$rel(widname).place(relx=$rel(relx), rely=$rel(rely),"
        append str " height=$rel(h), width=$rel(w)$bmc)\n"
    } else {
        set y $rel(y)
        append str \
            "$vTcl(tab2)self.$rel(widname).place(x=$rel(x), y=$y, "
        append str " height=$rel(h), width=$rel(w)$bmc)\n"
    }
    append vTcl(py_initfunc) [vTcl:split_line $str]
}

proc vTcl:comp_color {} {
    global vTcl
    if {![info exists style_code(compcolor)]} {
        set comp $vTcl(pr,guicomplement_color)
        append vTcl(toplevel_config) \
        "$vTcl(tab2)_compcolor = '$comp' [color_comment $comp]\n"
        set style_code(compcolor) 1
    }
}

proc vTcl:analog_colors {} {
    global vTcl
    if {![info exists style_code(anacolors)]} {
        set ap $vTcl(pr,guianalog_color_p)
        set am $vTcl(pr,guianalog_color_m)
        append vTcl(toplevel_config) \
            "$vTcl(tab2)_ana1color = '$ap' [color_comment $ap] \n"
        append vTcl(toplevel_config) \
            "$vTcl(tab2)_ana2color = '$am' [color_comment $am] \n"
        set style_code(anacolors) 1
    }
}

proc vTcl:style_code {widclass} {

    global vTcl
    global style_code
    if {[info exists style_code($widclass)]} return
    if {$widclass == "Text"} return
    # if {![info exists style_code(colors)]} {
    #     # Define background and foreground colors
    #     set bg $vTcl(pr,guibgcolor)
    #     set fg $vTcl(pr,guifgcolor)
    #     append vTcl(py_initfunc) \
    #        "$vTcl(tab2)_bgcolor = '$bg'\n"
    #     append vTcl(py_initfunc) \
    #        "$vTcl(tab2)_fgcolor = '$fg'\n"
    #     set style_code(colors) 1
    # }
    if {[string index $widclass 0] == T ||
        $widclass == "Heading" || $widclass == "Scrolledtreeview"} {
        switch $widclass {
            Heading {
                append vTcl(py_initfunc) \
        "$vTcl(tab2)self.style.configure('$widclass', background=_compcolor)\n"
            }
            TSizegrip {
                append vTcl(py_initfunc) \
       "$vTcl(tab2)self.style.configure('$widclass', background=_bgcolor)\n"
            }
            TNotebook.Tab {
                append vTcl(py_initfunc) \
       "$vTcl(tab2)self.style.configure('$widclass', background=_bgcolor)\n"
                append vTcl(py_initfunc) \
       "$vTcl(tab2)self.style.configure('$widclass', foreground=_fgcolor)\n"
                append vTcl(py_initfunc) \
          "$vTcl(tab2)self.style.map('$widclass', background=\n"
                append vTcl(py_initfunc) \
    "$vTcl(tab2)$vTcl(tab)\[('selected', _compcolor), ('active',_ana2color)\])\n"
            }
            Scrolledtreeview {
                append vTcl(py_initfunc) \
          "$vTcl(tab2)self.style.configure('Treeview.Heading', \
              font=[check_default_font $vTcl(actual_gui_font_dft_name)])\n"
#          "$vTcl(tab2)self.style.configure('Treeview.Heading',font=$vTcl(actual__font_dft_name))\n"
            }
            TCheckbutton -
            TRadiobutton {
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.style.map('$widclass',background=\n"
                append vTcl(py_initfunc) \
              "$vTcl(tab2)$vTcl(tab)\[('selected', _bgcolor), ('active', _ana2color)\])\n"
            }
        }
          #   default {
          #       append vTcl(py_initfunc) \
          # "$vTcl(tab2)self.style.configure('$widclass',background=_bgcolor)\n"
          #   }

        # if {$widclass != "TSizegrip"} {
        #     append vTcl(py_initfunc) \
        #         "$vTcl(tab2)style.configure('$widclass',foreground=_fgcolor)\n"
        # }
        set style_code($widclass) 1
    }
}

proc vTcl:python_source_widget {target prefix parentframe} {
    # This is the work horse of PAGE; it takes a widget and returns
    # the stream of Python code which realizes the widget.
    global vTcl widget
    global suffix
    global rel
    # Get target name and class
    set suffix 0
    set widclass [winfo class $target]
    set parent $parentframe            ;# Just to save typing.
    set widname [vTcl:widget_2_widname $target]
    if {[string first "vTH_" $target]>-1} {
        return
    }
    if {[winfo class $target]=="Menubutton"} {
        set menu_y_shift 24
    } else {
        set menu_y_shift 0
    }
    foreach {w h x y} [split [winfo geometry $target] "x+"] {}
    set rectangle "$x, [expr {$y-$menu_y_shift}], $w, $h"
    set cmdbody {}
    set cmdname {}
    set vTcl(gen_name) {}
    catch {
        vTcl:py_get_command_parameters [$target cget -command]
    }
    set parentclass [winfo class $parentframe]
    if {$parentclass == "Toplevel"} {     # Rozen
        #set pframe "master"
        set pframe "top"                 ;# 2/1/16
    } else {
        set parentf [vTcl:widget_2_widname $parentframe]
        set pframe "self.$parentf"
    }
    # Split the target geometry into w, h, x, y
    foreach {w h x y} [split [winfo geometry $target] "x+"] {}
    # Following makes sure that placement stays on units of 5 pixels.
    # Otherwise we end up with some things creeping across the window
    # when doing rework.
    set x [expr $x - [expr $x % 5]]
    set y [expr $y - [expr $y % 5]]
    # relative placement
    set rel(flag) 1
    set rel(rel_width) 1
    set parent_window [winfo parent $target]
    ### Have to play games with the TNotebook because only one of the
    ### children widgets is mapped and the geometry of unmapped widget
    ### is unusable. So we go to the grand parent and run thru the
    ### tabs to find the one that is mapped and use its geometry. 4/3/17
    set grand_parent_window [winfo parent $parent_window]
    set gpc [winfo class $grand_parent_window]
    if {$gpc == "TNotebook"} {
        foreach t [$grand_parent_window tabs] {
            if {[set parent_geometry [winfo geometry $t]] != "1x1+0+0"} {
                break
            }
        }
    } else {
        set parent_geometry [winfo geometry $parent_window]
    }
    foreach {W H X Y} [split $parent_geometry "x+"] {}  ;# new 4/3/17
    set rel(x) $x
    set rel(y) $y
    set rel(h) $h
    set rel(w) $w
    set relx [expr $x / $W.0]
    set rel(relx) [expr {round($relx*1000)/1000.0}]
    set rely [expr $y / $H.0]
    set rel(rely) [expr {round($rely*1000)/1000.0}]
    set relw [expr $w / $W.0]
    set rel(relw) [expr {round($relw*1000)/1000.0}]
    set relh [expr $h / $H.0]
    set rel(relh) [expr {round($relh*1000)/1000.0}]
    set rel(widname) $widname
    set rel(pframe) $pframe

    set vTcl(py_initfunc) "$vTcl(py_initfunc)\n"
    #set vTcl(image_count) 1
    # Following line puts out the required style code for ttk widgets.
    #append py_initfunc [vTcl:style_code $widclass]
    if {([string index $widclass 0] == "T" ||
         [string first  "Scroll" $widclass] > -1)  && $widclass != "Text"} {
        set vTcl(using_ttk) 1
    }
    # if {[info exists vTcl(widget_class,$target)]} {  #  12/17/17
    #     set widclass $vTcl(widget_class,$target)
    # }

    # Since PNotebook is not a real class, I have this hack to
    # distinguish between TNotebook and PNotebook. I split target and
    # look at the last piece to see if it starts with "pN".
    if {$widclass == "TNotebook"} {
        set tp [split $target "."]
        set tp_last [lrange $tp end end]
        if {[string first "pN" $tp_last] == 0} {
            set widclass "PNotebook"
        }
    }
        switch $widclass {
        Label {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Label($pframe)\n"
            vTcl:relative_x_y $parent  ;# Don't want labels stretchable.
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            vTcl:python_configure_widget $target $widname "" $widclass
        }
        Entry {
            vTcl:py_get_command_parameters [$target cget -textvar]
            if {$cmdname == ""} {
                set cmdname "$widname\_hit_enter"
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Entry($pframe)\n"
            #vTcl:relative_placement
            #vTcl:relative_x_y $parent
            vTcl:entry_placement $parent
            vTcl:python_configure_widget $target $widname "" $widclass
        }
        Button {
            set im [$target cget -image]
            set hi [$target cget -height]
            set wi [$target cget -width]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Button($pframe)\n"
            vTcl:relative_x_y $parent   ;# Don't want buttons stretchable.
            #vTcl:relative_placement
             if {$cmdname==""} {
                set cmdname "$widname\_click()"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Scale {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Scale($pframe)\n"
            #vTcl:relative_placement
            vTcl:scale_placement $target $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Scrollbar { # Since I am using the Tix widgets I am not too interested
                    # in scrollbars, so I haven't checked them out.
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Scrollbar($pframe)\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.place(in_=$pframe, x=$x, y=$y)\n"
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Frame -
        Labelframe {
            # Because vTcl uses Labelframe as the class name
            # and Tkinter uses LabelFrame, it is necessary for
            # some one to switch the names. I think it is
            # better to have the hack here in my code than
            # sprinkled through out the vtcl code.
            switch $widclass  {
                Frame {
                    set nn "tk.Frame"
                }
                Labelframe {
                    set nn "tk.LabelFrame"
                }
            }
            append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname = $nn" "($pframe)\n"
            vTcl:relative_placement $parent
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            if {$bdt == "none"} {
                set vTcl(py_initfunc) "$vTcl(py_initfunc)$vTcl(tab)"

                    "$widname.setBorder(new EmptyBorder(0,0,0,0))\n"
            } else {
                set relf [$target cget -relief]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.configure(relief='$relf')\n"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $widname
        }
        Text {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Text($pframe)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_load_cmd $target $widname
        }
       Message {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Message($pframe)\n"
            vTcl:relative_placement $parent
            #vTcl:fixed_placement
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_load_cmd $target $widname
        }
        Listbox {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Listbox($pframe)\n"
            vTcl:relative_placement $parent
            if {$cmdname==""} {
                set cmdname "$widname\_state_changed"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_load_cmd $target $widname

        }
        Radiobutton {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Radiobutton($pframe)\n"
            vTcl:relative_placement $parent
            if {$cmdname==""} {
                set cmdname "$widname\_click"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            # NEEDS WORK because I don't know what the following is for.
            set rbvar [$target cget -variable]
            if {![info exists vTcl(py_btngroup,$rbvar)]} {
                set vTcl(py_btngroup,$rbvar) 1
            }
        }
        Checkbutton {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Checkbutton($pframe)\n"
            vTcl:relative_placement $parent
            if {$cmdname==""} {
                set cmdname "$widname\_state_changed"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        Menubutton {
            set vTcl(in_menubutton) 1
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname = tk.Menubutton($pframe)\n"
            vTcl:relative_placement $parent
            set menu [$target cget -menu]
            set menu_name [vTcl:widget_2_widname $menu]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$menu_name = tk.Menu(self.$widname)\n"
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:python_process_menu $menu $widname
            set vTcl(in_menubutton) 0
        }
        Canvas {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = tk.Canvas($pframe)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $widname
        }
        Spinbox {
            set from [$target cget -from]
            set to [$target cget -to]
            append vTcl(py_initfunc) \
          "$vTcl(tab2)self.$widname = tk.Spinbox($pframe, from_=$from, to=$to)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        TButton {
            #set image_file [vTcl:look_for_image $widget]
            append vTcl(py_initfunc) \
                 "$vTcl(tab2)self.$widname = ttk.Button($pframe)\n"
            vTcl:relative_x_y $parent  ;# Don't want buttons stretchable.
            if {$cmdname==""} {
                set cmdname "$widname\_click()"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TEntry {
            vTcl:py_get_command_parameters [$target cget -textvar]
            if {$cmdname == ""} {
                set cmdname "$widname\_hit_enter"
            }
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Entry($pframe)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname "" $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TFrame {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Frame($pframe)\n"
            vTcl:relative_placement $parent
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            if {$bdt == "none"} {
                set vTcl(py_initfunc) "$vTcl(py_initfunc)$vTcl(tab)"

                    "$widname.setBorder(new EmptyBorder(0,0,0,0))\n"
            } else {
                set relf [$target cget -relief]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.configure(relief='$relf')\n"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $widname
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TLabel {
            # Don't forget to discuss the strange behavior of no width
            # upon creation.
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Label($pframe)\n"
            vTcl:relative_x_y $parent   ;# Don't want labels stretchable.
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            vTcl:python_configure_widget $target $widname "" $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TLabelframe {
           append py_initfunc [vTcl:style_code "TLabelframe.Label"]
           append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Labelframe($pframe)\n"
            vTcl:relative_placement $parent
            switch [$target cget -borderwidth] {
                0 {set bdt none}
                1 {set bdt SoftBevelBorder}
                default {set bdt BevelBorder}
            }
            if {$bdt == "none"} {
                set vTcl(py_initfunc) "$vTcl(py_initfunc)$vTcl(tab)"
                    "$widname.setBorder(new EmptyBorder(0,0,0,0))\n"
            } else {
                set relf [$target cget -relief]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.configure(relief='$relf')\n"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            #vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $widname
            vTcl:py_source_frame $target \
                    $prefix[lindex [split $target .] end] $parentframe
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TSpinbox {
            set from [$target cget -from]
            set to [$target cget -to]
            append vTcl(py_initfunc) \
          "$vTcl(tab2)self.$widname = ttk.TSpinbox($pframe, from_=$from, to=$to)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
        }        PNotebook {
            #this is PNotebook if there is an image and TNotebook in other cases
            #Don, winfo class $target returns TNotebook, as you've mentioned earlier
            #so I couldn't use it istead like so
            #if {[winfo class $target] == "PNotebook"}


            # Maksim

            incr vTcl(pnotebook_count)
            #dmsg $widgetCount
            if {$vTcl(pnotebook_count) == 1} {
            #if {[$target tab 0 -image] != "" && $vTcl(widgetCount) == 1} { }
                append vTcl(py_initfunc) \
"$vTcl(tab)$vTcl(tab)self.images = (

$vTcl(tab)$vTcl(tab) tk.PhotoImage(\"img_close\", data='''R0lGODlhDAAMAIQUADIyMjc3Nzk5OT09PT
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) 8/P0JCQkVFRU1NTU5OTlFRUVZWVmBgYGF hYWlpaXt7e6CgoLm5ucLCwszMzNbW
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) 1v//////////////////////////////////// ///////////yH5BAEKAB8ALA
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) AAAAAMAAwAAAUt4CeOZGmaA5mSyQCIwhCUSwEIxHHW+ fkxBgPiBDwshCWHQfc5
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) KkoNUtRHpYYAADs= '''),

$vTcl(tab)$vTcl(tab) tk.PhotoImage(\"img_closeactive\", data='''R0lGODlhDAAMAIQcALwuEtIzFL46
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) INY0Fdk2FsQ8IdhAI9pAIttCJNlKLtpLL9pMMMNTP cVTPdpZQOBbQd60rN+1rf
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) Czp+zLxPbMxPLX0vHY0/fY0/rm4vvx8Pvy8fzy8P//////// ///////yH5BAEK
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) AB8ALAAAAAAMAAwAAAVHYLQQZEkukWKuxEgg1EPCcilx24NcHGYWFhx P0zANBE
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) GOhhFYGSocTsax2imDOdNtiez9JszjpEg4EAaA5jlNUEASLFICEgIAOw== '''),

$vTcl(tab)$vTcl(tab) tk.PhotoImage(\"img_closepressed\", data='''R0lGODlhDAAMAIQeAJ8nD64qELE
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) rELMsEqIyG6cyG7U1HLY2HrY3HrhBKrlCK6pGM7lD LKtHM7pKNL5MNtiViNaon
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) +GqoNSyq9WzrNyyqtuzq+O0que/t+bIwubJw+vJw+vTz+zT z////////yH5BAE
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) KAB8ALAAAAAAMAAwAAAVJIMUMZEkylGKuwzgc0kPCcgl123NcHWYW Fs6Gp2mYB
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) IRgR7MIrAwVDifjWO2WwZzpxkxyfKVCpImMGAeIgQDgVLMHikmCRUpMQgA7 ''')
$vTcl(tab)$vTcl(tab))

$vTcl(tab)$vTcl(tab)self.style.element_create\(\"close\", \"image\", \"img_close\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)   \(\"active\", \"pressed\", \"!disabled\", \"img_closepressed\"\),
$vTcl(tab)$vTcl(tab)$vTcl(tab)   \(\"active\", \"alternate\", \"!disabled\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)   \"img_closeactive\"\), border=8, sticky=''\)

$vTcl(tab)$vTcl(tab)self.style.layout(\"ClosetabNotebook\", \[\(\"ClosetabNotebook.client\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab) \{\"sticky\": \"nswe\"\}\)\]\)
$vTcl(tab)$vTcl(tab)self.style.layout(\"ClosetabNotebook.Tab\", \[
$vTcl(tab)$vTcl(tab)$vTcl(tab)\(\"ClosetabNotebook.tab\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)  \{ \"sticky\": \"nswe\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"children\": \[
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\(\"ClosetabNotebook.padding\", \{
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"side\": \"top\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"sticky\": \"nswe\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"children\": \[
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\(\"ClosetabNotebook.focus\", \{
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"side\": \"top\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"sticky\": \"nswe\",
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"children\": \[
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\(\"ClosetabNotebook.label\", \{\"side\":
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)  \"left\", \"sticky\": ''\}\),
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\(\"ClosetabNotebook.close\", \{\"side\":
$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)$vTcl(tab)\"left\", \"sticky\": ''\}\),\]\}\)\]\}\)\]\}\)\]\)

$vTcl(tab)$vTcl(tab)PNOTEBOOK = \"ClosetabNotebook\" \n\n"
            }
            #append py_initfunc [vTcl:comp_color]
            #append py_initfunc [vTcl:analog_colors]
            append py_initfunc [vTcl:style_code "TNotebook.Tab"]
            append py_initfunc [vTcl:style_code "TFrame"]
            #append vTcl(py_initfunc) \
               "$vTcl(tab2)self.style.map('TNotebook.Tab', background=\[ \n"
            #append vTcl(py_initfunc) \
       "$vTcl(tab2)$vTcl(tab)('active', $_compcolor),"
            #append vTcl(py_initfunc) \
       "$vTcl(tab2)$vTcl(tab)('selected', _compcolor)\])\n"

            # append vTcl(py_initfunc) \
            #    "$vTcl(tab2)self.style.map('TNotebook.Tab', foreground=\[ \n"
            # append vTcl(py_initfunc) \
            #    "$vTcl(tab2)self.style.map('TNotebook.Tab', foreground=\[ \n"

            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname = ttk.Notebook($pframe)\n"
            vTcl:relative_placement $parent
            # vTcl:python_configure_widget $target $widname ""  \
            #     [winfo class $target]
            vTcl:python_configure_widget $target $widname ""  $widclass
            # Lets try to put out options for the nbframe subwidget
            set pages [$target tabs]
            set i 0
            foreach p  $pages {
                # if {[catch {set sub_name $widget(rev,$p)}]} {
                #     # This is the otherwise path: no alias
                #     set sub_name [join [concat $widname "_t" $i] ""]
                #     #set sub_name [join [concat $widname "_p" $cnt] ""]
                #     vTcl:python_alias $sub_name $p   ;# Rozen new
                # }   Removed and replaced with the line below. 12/16/17
                set sub_name ${widname}_t$i
                vTcl:python_alias $sub_name $p   ;# Rozen new
                #append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$sub_name = ttk.Frame(self.$widname)\n"
                #append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.add(self.$sub_name, padding=3)\n"
                append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$sub_name = tk.Frame(self.$widname)\n"
                append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.add(self.$sub_name, padding=3)\n"
                set options [vTcl:python_nb_tab_configure $target $p]
                append vTcl(py_initfunc) \
                [vTcl:split_line "$vTcl(tab2)self.$widname.tab($i, $options)\n"]
                vTcl:python_configure_widget $p $sub_name "" "Frame"
                incr i
            }
            # Now get the widgets inside each page.

            # # Since the pg returns a geometry of 1x1+0+0 we pick up
            # # the geometry of the parent.  Definitely a kludge. Not
            # # needed 4/3/17.
            # set rel(geometry) [winfo geometry [winfo parent $p]]
            foreach p  $pages {
                vTcl:python_source_subwidgets $p $p
            }
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
            set vTcl(add_pnotebook_helper) 1
        }
        TNotebook {
            append py_initfunc [vTcl:style_code "TNotebook.Tab"]
            append py_initfunc [vTcl:style_code "TFrame"]
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname = ttk.Notebook($pframe)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname ""  \
                [winfo class $target]
            # Lets try to put out options for the nbframe subwidget
            set pages [$target tabs]
            set i 0
            foreach p  $pages {
                # if {[catch {set sub_name $widget(rev,$p)}]} {
                #     # This is the otherwise path: no alias
                #     set sub_name [join [concat $widname "_t" $i] ""]
                #     #set sub_name [join [concat $widname "_p" $cnt] ""]
                #     vTcl:python_alias $sub_name $p   ;# Rozen new
                # }   Removed and replaced with the line below. 12/16/17
                set sub_name ${widname}_t$i
                vTcl:python_alias $sub_name $p   ;# Rozen new
                #append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$sub_name = ttk.Frame(self.$widname)\n"
                #append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.add(self.$sub_name, padding=3)\n"
                append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$sub_name = tk.Frame(self.$widname)\n"
                set options [vTcl:python_nb_tab_configure $target $p]
                if {$vTcl(encoding) != ""} {
                    append vTcl(py_initfunc) \
"$vTcl(tab2)self.img$vTcl(notebook_image_count) = tk.PhotoImage(file='''$vTcl(encoding)''')\n"
                    append options "image=self.img$vTcl(notebook_image_count)"
                    incr vTcl(notebook_image_count)
                }
                append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.add(self.$sub_name, padding=3)\n"
                append vTcl(py_initfunc) \
                [vTcl:split_line "$vTcl(tab2)self.$widname.tab($i, $options)\n"]
vTcl:python_configure_widget $p $sub_name "" "Frame"
                incr i
            }
            # Now get the widgets inside each page.

            # # Since the pg returns a geometry of 1x1+0+0 we pick up
            # # the geometry of the parent.  Definitely a kludge. Not
            # # needed 4/3/17.
            # set rel(geometry) [winfo geometry [winfo parent $p]]
            foreach p  $pages {
                vTcl:python_source_subwidgets $p $p
            }
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        Scrolledtext {
            set config [$target configure]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            #append vTcl(py_initfunc) \
                "$vTcl(tab2)root.option_add('*scrollbar*background', '$vTcl(actual_gui_bg)')\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledText($pframe)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledtext
        }
        Scrolledentry {
            set config [$target configure]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            #append vTcl(py_initfunc) \
                "$vTcl(tab2)root.option_add('*scrollbar*background', '$vTcl(actual_gui_bg)')\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledEntry($pframe)\n"
            vTcl:entry_placement  $parent
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledentry
        }
        Scrolledcombo {
            set config [$target configure]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            #append vTcl(py_initfunc) \
                "$vTcl(tab2)root.option_add('*scrollbar*background', '$vTcl(actual_gui_bg)')\n"
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledCombo($pframe)\n"
            vTcl:entry_placement $parent
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledcombo
        }
        TProgressbar {
            set config [$target configure]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Progressbar($pframe)\n"
            #vTcl:relative_placement
            vTcl:progressbar_placement $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass

        }
        TMenubutton {
            set vTcl(in_menubutton) 1
            append vTcl(py_initfunc) \
               "$vTcl(tab2)self.$widname = ttk.Menubutton($pframe)\n"
#            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.place(in_=$pframe, x=$x, y=$y)\n"
            vTcl:relative_placement $parent
            set menu [$target cget -menu]
            set menu_name [vTcl:widget_2_widname $menu]
            set menu_name [vTcl:python_unique_menu_name menu]
            append vTcl(py_initfunc) \
               "$vTcl(tab2)self.$menu_name = tk.Menu(self.$widname,tearoff=0)\n"
            vTcl:python_configure_widget $target $widname $cmdname \
                      $widclass "" "self.$menu_name"
            vTcl:python_process_menu $menu $widname $menu_name
            #append vTcl(py_initfunc) \
            #   "$vTcl(tab2)self.$widname.config(menu=$lablab)\n"
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
            set vTcl(in_menubutton) 0
        }
        Scrolledlistbox {
            append py_initfunc [vTcl:style_code "TScrollbar"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledListBox($pframe)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass
            #vTcl:python_load_cmd $target $widname
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledlistbox
        }
        Scrolledtreeview {
            #append py_initfunc [vTcl:comp_color]
            append py_initfunc [vTcl:style_code "TScrollbar"]
            append py_initfunc [vTcl:style_code "Scrolledtreeview"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ScrolledTreeView($pframe)\n"
            append py_initfunc [vTcl:style_code "TScrollbar"]
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target.01 $widname $cmdname $widclass

            vTcl:build_treeview_support $target.01 $widname $cmdname $widclass
            set vTcl(add_helper_code) 1
            lappend vTcl(helper_list) Scrolledtreeview
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TCheckbutton {
            append py_initfunc [vTcl:style_code "TCheckbutton"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Checkbutton($pframe)\n"
            vTcl:progressbar_placement $parent
            if {$cmdname==""} {
                set cmdname "$widname\_state_changed"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
                           # $('<Map>', self.__adjust_sash)widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TCombobox {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Combobox($pframe)\n"
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        Custom {
            # We have to play some extra games to allow variants of
            # the Custom class.
            #set variant $::widgets::${target}::options($spec_opt)
            set spec_opt "-variant"
            set variant [$::configcmd($spec_opt,get) $target]
            if {[info exists vTcl($target,-variant)]} {
                set variant $vTcl($target,-variant)
                set c_v Custom$variant
            } else {
                set c_v Custom
            }

            #append vTcl(py_initfunc) \
               "$vTcl(tab2)self.$widname = $vTcl(import_name).Custom($pframe)\n"
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname = $vTcl(import_name).${c_v}($pframe)\n"
            vTcl:relative_placement $parent
            #append vTcl(py_initfunc) \
             "$vTcl(tab2)self.$widname.pack(side=LEFT, expand=YES, fill=BOTH)\n"
            #vTcl:python_configure_widget $target $widname $cmdname $widclass
        }
        TRadiobutton {
            append py_initfunc [vTcl:style_code "TRadiobutton"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Radiobutton($pframe)\n"
            #vTcl:relative_placement $parent
            vTcl:progressbar_placement $parent
            if {$cmdname==""} {
                set cmdname "$widname\_click"
            }
            vTcl:python_configure_widget $target $widname $cmdname $widclass
# NEEDS WORK because I don't know what the following is for.
            set rbvar [$target cget -variable]
            if {![info exists vTcl(py_btngroup,$rbvar)]} {
                set vTcl(py_btngroup,$rbvar) 1
            }
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TScale {
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Scale($pframe)\n"
            #vTcl:relative_placement $parent
            vTcl:scale_placement $target $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TSeparator {
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname = ttk.Separator($pframe)\n"
            vTcl:separator_placement $target $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
        }
        TSizegrip {
            append py_initfunc [vTcl:style_code "TSizegrip"]
            append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname = ttk.Sizegrip($pframe)\n"
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.$widname.place(anchor='se', relx=1.0, rely=1.0)\n"
        }
        TPanedwindow {
            #append py_initfunc [vTcl:style_code "TLabelframe"]

            #append py_initfunc [vTcl:style_code "TLabelframe.Label"]
            set orient [$target cget -orient]
            append vTcl(py_initfunc) \
                [vTcl:split_line "$vTcl(tab2)self.$widname = ttk.Panedwindow($pframe, orient=\"$orient\")\n"]
            vTcl:relative_placement $parent
            vTcl:python_configure_widget $target $widname $cmdname $widclass
            # Add the panes.  The panes are added so that each pane
            # shares the same space.
            set panes [$target panes]
            set no_panes [llength $panes]
            set cnt 0
            foreach p $panes {
                incr cnt
                set text [$p cget -text]
                if {[catch {set sub_name $widget(rev,$p)}]} {
                    # This is the otherwise path: no alias
                    set sub_name [join [concat $widname "_p" $cnt] ""]
                    vTcl:python_alias $sub_name $p   ;# Rozen new
                }
                if {$orient == "horizontal"} {
                    set w [$p cget -width]
                    if {$cnt < $no_panes} {
                        set width_clause "width=$w, "
                    } else {
                        set width_clause ""
                    }
                    #append vTcl(py_initfunc) \
                        [vTcl:split_line "$vTcl(tab2)self.${widname}_f$cnt = ttk.Labelframe(${width_clause}text='$text')\n"]
                    #append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add(self.${widname}_f$cnt)\n"
                    append vTcl(py_initfunc) \
                        [vTcl:split_line "$vTcl(tab2)self.$sub_name = ttk.Labelframe(${width_clause}text='$text')\n"]
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add(self.$sub_name)\n"
                } else {
                    # vertical
                    set h [$p cget -height]
                    if {$cnt < $no_panes} {
                        set height_clause "height=$h, "
                    } else {
                        set height_clause ""
                    }
                    #append vTcl(py_initfunc) \
                        [vTcl:split_line "$vTcl(tab2)self.${widname}_f$cnt = ttk.Labelframe(${height_clause}text='$text')\n"]
                    #append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add(self.${widname}_f$cnt)\n"
                    append vTcl(py_initfunc) \
                        [vTcl:split_line "$vTcl(tab2)self.$sub_name = ttk.Labelframe(${height_clause}text='$text')\n"]
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add(self.$sub_name)\n"
                }
            }

        update idletasks
        set pos "pos = \["
        for {set i 0;set p [expr [llength $panes]-1]} {$i < $p} {incr i} {
            set coord [$target sashpos $i]
            append pos $coord ", "
        }
        append pos "\]"

#     This is the sort of code I want. It is from Guilherme Polo's Theming.py
#         self.__funcid = paned.bind('<Map>', self.__adjust_sash)

#     def __adjust_sash(self, event):
#         """Adjust the initial sash position between the top frame and the
#         bottom frame."""
#         height = self.master.geometry().split('x')[1].split('+')[0]
#         paned = event.widget
#         paned.sashpos(0, int(height) - 180)
#         paned.unbind('<Map>', self.__funcid)
#         del self.__funcidTcl(pr,menubgcolor
            append vTcl(py_initfunc) \
                "$vTcl(tab2)self.__funcid$vTcl(pw_cnt) = self.$widname.bind('<Map>', self.__adjust_sash$vTcl(pw_cnt))\n"

            append vTcl(class_functions) \
"
$vTcl(tab)def __adjust_sash$vTcl(pw_cnt)(self, event):
$vTcl(tab)$vTcl(tab)paned = event.widget
$vTcl(tab)$vTcl(tab)$pos
$vTcl(tab)$vTcl(tab)i = 0
$vTcl(tab)$vTcl(tab)for sash in pos:
$vTcl(tab)$vTcl(tab)$vTcl(tab)paned.sashpos(i, sash)
$vTcl(tab)$vTcl(tab)$vTcl(tab)i += 1
$vTcl(tab)$vTcl(tab)paned.unbind('<map>', self.__funcid$vTcl(pw_cnt))
$vTcl(tab)$vTcl(tab)del self.__funcid$vTcl(pw_cnt)
"
            incr vTcl(pw_cnt)

            # Generate code for each of the subwidgets.
            foreach p $panes {
                #set child [winfo children $p]
                vTcl:python_source_subwidgets $p $p
            }

            #vTcl:python_configure_widget $target $widname $cmdname $widclass
            lappend vTcl(fonts_used) $vTcl(actual_gui_font_dft_name)
         }
         Menu {
            if {$target == $vTcl(toplevel_menu)} {
                # First step is to put out the proper toplevel menus headers.
                # But only do once.
                set menu_config [$target configure]
                #set menu_font [$target cget -font] In the line below
                # I want the top level to have the font specified in
                # the preferences.  Since this is a menubar and there
                # will only be one menubar per toplevel window, I will
                # change the widname to "menubar".
                set readable_name menubar
                if {$vTcl(toplevel_menu_header) == "" } {
                    #set f_s [vTcl:python_menu_font $vTcl(pr,gui_font_menu)]
                    set f_s [vTcl:python_menu_font \
                                 $vTcl(actual_gui_font_menu_name)]
                    lappend vTcl(fonts_used) $vTcl(actual_gui_font_menu_name)
                    if {$f_s == "font=()"} {
                        # For readability I am explicitly saying that I
                        # will specify the use of TkMenuFont.
                        set f_s "font=\"TkMenuFont\""
                        #set f_s ""
                    }
                    if {$f_s != ""} {
                        set f_s ",$f_s"
                    }
                    set menu_bg [$target cget -background]
                    # set bg_s ""
                    # if { $vTcl(pr,menubgcolor) != $vTcl(pr,bgcolor)} {
                    #     append bg_s ",background=\'" $vTcl(pr,menubgcolor) "\'"
                    # }
                    set bg_s ""
                    if {[::colorDlg::compare_colors $menu_bg \
                             $vTcl(actual_gui_bg)]} {
                        append bg_s ",bg=_bgcolor"
                    } else {
                        append bg_s ",bg=\'" $menu_bg "\'"
                    }
                    # set fg_s ""
                    # if { $vTcl(pr,menufgcolor) != "#000000"} {
                    #     append fg_s ",fg=\'" $vTcl(pr,menufgcolor) "\'"
                    # }
                    set menu_fg [$target cget -foreground]
                    set fg_s ""
                    if {[::colorDlg::compare_colors $menu_fg \
                             $vTcl(actual_gui_fg)]} {
                        append fg_s ",fg=_fgcolor"
                    } else {
                        append fg_s ",fg=\'" $menu_fg "\'"
                    }
#NEEDS WORK for activebackground.
                    append vTcl(py_initfunc) \
                 "$vTcl(tab2)self.$readable_name = tk.Menu(top$f_s$bg_s$fg_s)\n"
                    append vTcl(py_initfunc) \
                   "$vTcl(tab2)top.configure(menu = self.$readable_name)\n"
                           #"$vTcl(tab2)master\[\'menu\'\] = self.$widname\n"
                    set vTcl(toplevel_menu_header) 1
                    append vTcl(py_initfunc) "\n"
                }
                vTcl:python_process_menu $target $widname $readable_name
            }
        }
        default {
            puts "Unknown widget class encountered: $widclass"
       }
    }

    # Here is were I put in the bindings.
    append vTcl(py_initfunc) [vTcl:python_dump_bind $target $widname]
}

proc vTcl:python_menu_font {font} {

    # Change something like
 #-family Purisa -size 14 -weight normal -slant roman -underline 0 -overstrike 0
    # into ,font=('Purisa',14,'normal','roman',)
    # Badly named becaues I use it whenever I want to reformat a font description.
    global vTcl
    set font_string ""
    # I want to see if font is a font name.  I will assume that if the
    # font name does not contain the string "family"we have then it is a font
    # name.

    if {$font in $vTcl(standard_fonts)} {
        return "font=\"$font\""
    }
    if {[string index $font 0] == "\{"} {
        foreach value $font {
        }
        return "font=\"$font\""
    }
    if {[string first "-family" $font] == -1} {

    # I think that we have a font name.
        lappend vTcl(fonts_used) $font
        #return "font=self.$font"
        return "font=$font"
    }
    if {$font == "" } {
        # I don't think that I hit this batch of code.
        set font vTcl(pr,gui_font_menu)
        #set font TkMenuFont
    }
    if {$font != ""} {
             set font_string "font=("
             # Reformat font sting for python
             foreach {prop value} $font {
                 switch $prop {
                     "-family" -
                     "-weight" -
                     "-slant" {
                         append font_string "'" $value "',"
                     }
                     "-size" {
                         append font_string $value ","
                     }
                     "-underline" {
                         if {$value == 1} {
                             append font_string "'underline',"
                         }
                     }
                     "-overstrike" {
                         if {$value == 1} {
                             append font_string "'overstrike',"
                         }
                     }
                 }
             }
             append font_string ")"
         }
         return $font_string
}

proc vTcl:python_menu_options { opts {index {}} {menu_name {}} {image_name {}}} {
    # Each time vTcl:python_process_menu processes a menu entry this
    # routine is called to create a python string which will add the
    # non default option values. It is passed the list of option lists.
    # The option list items looks like {-underline {} {} -1 -1}
    global vTcl
    set option_string ""
    # Now I will handle the configuration options: Added 12/24/11
    foreach op $opts {
        foreach {o x y d v} $op {
            # o - option
            # d - default
            # v - value
        }
        set v [string trim $v]
        if {$d == $v} continue   ;# If value == default value bail.
        set oa [string range $o 1 end]

        switch -exact -- $o {
            -font {
                set font_string [vTcl:python_menu_font $v]
                #append option_string [string range $font_string 1 end] ","
                if {$font_string != ""} {
                    append option_string \
                        "$vTcl(tab2)$vTcl(tab2)$font_string,\n"
                }
            }
            -menu {
                set z ''
                # Do nothing
                #append option_string "$oa=self.$menu_name,\n"
            }
            -accelerator -
            -activebackground -
            -activeforeground -
            -background -
            -compound -
            -foreground -
            -label -
            -selectcolor -
            -value {
                    append option_string \
                    "$vTcl(tab2)$vTcl(tab2)$oa=\"$v\",\n"
            }
            -command {
                #set v $cmdname
                #if {[string first "(" $v] == -1} {
                #        append v "()"
                #}
                if {[string first "#" $v] != -1} {
                    # We have found a value like #quit; so drop the #
                    set v [string range $v 1 end]
                }
                if {$v == "\# TODO"} {
                    # This is here for compatibility with previous
                    # creations. I am removing the hint # TODO.
                    continue
                }

                lappend vTcl(funct_list) $v
                set v [vTcl:prepend_import_name $v]
                append option_string \
                     "$vTcl(tab2)$vTcl(tab2)$oa=$v,\n"
            }
            -image {
                append option_string \
                     "$vTcl(tab2)$vTcl(tab2)$oa=$image_name,\n"
             }
            -variable {
                # The big deal here is to be sure that the global
                # variable is created $v is the variable name. Check
                # to see if it begins with "self." to tell if it is a
                # local rather than a global.
                if {[string first self. $v] == 0} {
                    if {[lsearch -exact $vTcl(l_v_list) $v] == -1} {
                        set vv  "$vTcl(tab2)$v = StringVar()\n"
                        lappend vTcl(l_v_list) $vv
                    }

                #} elseif {[string first . $v] >= 0} {
                #    # Variable in imported module
                #    set vTcl(supp_variables) 1
                } else {
                    # Global variable
                    if {[lsearch -exact $vTcl(g_v_list) $v] == -1} {
                        set vTcl(global_variable) 1
                        set m StringVar
                         set l [list $v $m]
                        #lappend vTcl(g_v_list) $l
                        lappend vTcl(g_v_list) $v $m
                    }
                }
                set v [vTcl:prepend_import_name $v]
                append option_string "$vTcl(tab2)$vTcl(tab2)$oa=$v,\n"
            }    ;# End of value and variable.
            -state -
            -relief {
                set v [string toupper $v]
                append option_string "$vTcl(tab2)$vTcl(tab2)$oa=$v,\n"
            }
            default {
                append option_string "$vTcl(tab2)$vTcl(tab2)$oa=$v,\n"
            }
        } ;# End of Switch
    }  ;# End of loop over opts
    # Remove last ',\n' from opt_string
    set option_string [string range $option_string 0 end-2]
    return $option_string
}

proc vTcl:python_unique_menu_name {name} {
    # Sees if name is in vTcl(menu_names) and if so generates an
    # integer when when appended to the name is unique in the
    # list. The last step is to add the new name to the list.
    global vTcl
    set final_name $name
    while {[lsearch -exact $vTcl(menu_names) $final_name] > -1} {
        incr i
        append final_name $i
    }
    lappend vTcl(menu_names) $final_name
    return $final_name
}

proc vTcl:python_create_image {target index} {
    # Looks up file name, converts it to a relative file name, and
    # generates an image name which it uses to generate a line of code
    # required by Python to create an reference. I do not have to
    # return the name because it will be used when process sing the
    # option list before another will be generated. This was borrowed
    # from vTcl:python_configure_widget.

    # NEEDS WORK: Should not have the same code in two places; will
    # consolidate. Add a parameter to increment.
    global vTcl
    # See if menu entry has an image.
    set image  [$target entrycget $index -image]
    if {$image == ""} return ""
    set file_name $vTcl(imagefile,$image)  ;# Fetch file name coupled to image.
    set file_name [regsub [pwd]/ $file_name ""] ;# Try for relative path
    set image_name self._img$vTcl(menu_image_count)
    append vTcl(py_initfunc) \
        "$vTcl(tab2)$image_name = tk.PhotoImage(file=\"$file_name\")\n"
    incr vTcl(menu_image_count)
    return $image_name
}

proc vTcl:python_replace_blanks {str} {
    # Replace all blanks in str with "_" and write to
    # no_blanks. Return no_blanks. Before starting we remove beginning
    # and train ling white space.
    set str [string trim $str]
    regsub -all {\s+}  $str "_" no_blanks
    return $no_blanks
}

proc vTcl:python_process_menu {target widname {readable_name {}}} {
    # This is a recursive proc to translate the menu stuff in
    # python. When we get to a menu item which is a cascade we so that
    # item and then recurse into the new cascade menu. It calls
    # vTcl:python_create_image to determine if the item contains an
    # image and to generate the needed extra reference to the
    # PhotoImage object (see
    # http://effbot.org/tkinterbook/photoimage.htm for an example.)
    # and then calls vTcl:python_menu_options to process the options
    # for the menu entry.
    global vTcl
    if {[string first .# $target] >= 0} {return}
    set entries [$target index end]
    if {$entries == "none"} {return}
    set result ""
    if {$readable_name == ""} {
        set widname [vTcl:widget_2_widname $target]
    } else {
        set widname $readable_name
    }
    for {set i 0} {$i<=$entries} {incr i} {
        set type [$target type $i]
        if {[info exists vTcl(toplevel_menu)] &&
            $target == $vTcl(toplevel_menu)} {
            if {$type == "tearoff"} {
                # tearoff at toplevel doesn't really mean anything,
                # but let the user specify it anyway.
                continue

            }
        }
        set opts [$target entryconfigure $i]
        set lab_name {}
        switch $type {
            cascade {
                set lab [$target entrycget $i -label] ;# Get label
                set lab_lower [string tolower $lab]
                set lab_name [vTcl:python_unique_menu_name "sub_menu"]
                set child [$target entrycget $i -menu]
                set widname_child [vTcl:widget_2_widname $child]
                set tearoff [$child cget -tearoff]
                if {$tearoff} {
                    set tearoff ",tearoff=1"
                } else {
                    set tearoff ",tearoff=0"
                }
                if {$vTcl(in_popup)} {
                    append vTcl(py_initfunc) \
                      "$vTcl(tab2)self.$lab_name = tk.Menu($widname$tearoff)\n"
                } else {
                    append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$lab_name = tk.Menu(top$tearoff)\n"
                }
                    # Generate the line of code which creates the
                    # required reference.
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$readable_name.add_cascade("

                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]

                append vTcl(py_initfunc) \
                        "menu=self.$lab_name,\n"
                append vTcl(py_initfunc) $op_str ")\n"
                vTcl:python_process_menu $child $lab_name $lab_name

            }
            command {
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                        "$vTcl(tab2)self.$widname.add_command(\n"
                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]
                append vTcl(py_initfunc) $op_str ")\n"
            }
            separator {
                set image_name ""
                append vTcl(py_initfunc)  \
                        "$vTcl(tab2)self.$widname.add_separator(\n"
                set op_str [vTcl:python_menu_options $opts]
                append vTcl(py_initfunc) $op_str ")\n"
            }
            checkbutton {
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                    "$vTcl(tab2)self.$widname.add_checkbutton(\n"
                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]
                append vTcl(py_initfunc) $op_str ")\n"
            }
            radiobutton {
                set image_name [vTcl:python_create_image $target $i]
                append vTcl(py_initfunc) \
                            "$vTcl(tab2)self.$widname.add_radiobutton(\n"
                set op_str [vTcl:python_menu_options \
                                $opts "" $lab_name $image_name]
                append vTcl(py_initfunc) $op_str ")\n"
            }

        }   ;# End of Switch
    }
    return $lab_name
}


proc vTcl:python_get_inner_frame {target} {
    global vTcl
    set output ""
    set pieces [split $target .]
    set max 0
    for {set i 1} {$i <= [llength $pieces]} {incr i} {
        set can [lindex $pieces $i]
        if {[string first "tix" $can] != -1} {
            set max $i
        }
    }
    if {$max > 2} {
        append f_name [lindex $pieces 2] "_" [lindex $pieces $max]
    } else {dp
        set f_name [lindex $pieces 2]
    }
     return f_name
}

proc vTcl:find_attribute {widget attribute} {
    global vTcl
    set config [$widget configure]
    foreach c  $config {
        if {[lindex $c 0] == $attribute} {
            return [lindex $c 4]
        }
    }
}

proc vTcl:python_process_me {command widget widname} {
    global vTcl
    set i [string first "%me" $vTcl($widget,$command)]
    set x $vTcl($widget,$command)
    set ind [string first "self." $widname]
    if {$ind > -1} {
        set widname [string range $widname 5 end]
    }
    if {$i > -1} {
        set head [string range $x 0  [expr $i - 1]]
        set tail [string range $x [expr $i + 3] end]
        set x $head
        append x "self.$widname"
        append x $tail
    }
    return $x
}

proc vTcl:python_load_cmd  {widget widname} {
    global vTcl
    if {[info exists vTcl($widget,-loadcommand)]} {
        set x [vTcl:python_process_me "-loadcommand" $widget $widname]
        append vTcl(py_initfunc) "$vTcl(tab2)$x\(self.$widname\)\n"
    }
}

proc vTcl:python_delete_leading_tabs {proc} {
    set p $proc
    set spaces ""
    while {[string first "\n" $p] == 0} {
        set p [string range $p 1 end]
        set spaces 1
    }
    while {[string first " " $p] == 0} {
        set p [string range $p 1 end]
        set spaces 1
    }
    while {[string first "\t" $p] == 0} {
        set p [string range $p 1 end]
        set spaces 1
    }
    if {$spaces == ""} {
        return $proc
    }
    return $p
}

proc vTcl:python_delete_lambda {proc} {
    set p $proc
    set p [regsub "lambda.*:" $p ""]
    set p [string trim $p]
    return $p
}

proc vTcl:python_indent_lines {proc} {
    global vTcl
global log
    set p $proc
    set rem  ""
    set tail $proc
    set lines ""
    while {[string first "\n" $tail] > -1} {
        set i [string first "\n" $tail]
        set head [string range $tail 0 $i]
        set tail [string range $tail [expr $i + 1] end]
        append rem $vTcl(tab) $head
        set lines 1
    }
    if {$lines == ""} {
        return proc
    }
    return $rem
}

proc vTcl:python_subst_tabs {proc} {
    global vTcl
    set p $proc
    set res ""
    set tabs ""
    while {[string first "\t" $p] > -1} {
        set i [string first "\t" $p]
        set head [string range $p 0 $i]
        set tail [string range $p [expr $i + 1] end]
        append p $head $vTcl(tab) $tail
        set tabs 1
    }
    if {$tabs == ""} {
        return $proc
    }
    return $p
}

proc vTcl:python_print_proc {proc} {
    set p $proc
    set i [string first "\t" $p]
    puts $p
}

proc vTcl:python_gui_startup {geom title classname} {
    global vTcl
    if {$vTcl(import_module) != ""} {
        append start_gui \
"
import $vTcl(import_name)
"
    }
    append start_gui \
"
def vp_start_gui():
$vTcl(tab)'''Starting point when module is the main routine.'''
$vTcl(tab)global val, w, root
$vTcl(tab)root = tk.Tk()"
    # root.title('$classname')"
    # Add the geometry stuff.
    #append start_gui $geom \
#"
#    root.geometry(geom)"

    if {$vTcl(global_variable)} {
        append start_gui \
"
$vTcl(tab)$vTcl(import_name).set_Tk_var()"
    }
    append start_gui \
"
$vTcl(tab)top = $classname (root)
"
    if {$vTcl(import_module) == "" } {
        append start_gui \
"
$vTcl(tab)init()
$vTcl(tab)root.mainloop()"
    } else {
        append start_gui \
"$vTcl(tab)$vTcl(import_name).init(root, top)
$vTcl(tab)root.mainloop()
"
    }
    append start_gui "\nw = None\n" "def create_$classname" \
                                "(root, *args, **kwargs):"
    append start_gui \
"
$vTcl(tab)'''Starting point when module is imported by another program.'''
$vTcl(tab)global w, w_win, rt
$vTcl(tab)rt = root
$vTcl(tab)w = tk.Toplevel (root)"
#     append start_gui $geom \
#     w.title('$classname')"
# "
#     w.geometry(geom)"

if {$vTcl(global_variable)} {
        append start_gui \
"
${vTcl(tab)}$vTcl(import_name).set_Tk_var()"
    }
    append start_gui \
"
$vTcl(tab)top = $classname (w)"
    if {$vTcl(import_module) == "" } {
        append start_gui \
"
$vTcl(tab)init()
$vTcl(tab)return (w, top)"
    } else {
        append start_gui \
"
$vTcl(tab)$vTcl(import_name).init(w, top, *args, **kwargs)
$vTcl(tab)return (w, top)
"
    }
    append start_gui "\ndef destroy_$classname" "():"
    append start_gui \
"
$vTcl(tab)global w
$vTcl(tab)w.destroy()
$vTcl(tab)w = None
"
    return $start_gui
}

proc  vTcl:get_subwidget_options {widget hlist} {
    # This Proc puts options of the subwidget into the -options
    # string of the widget creation.  I think that I could have
    #used this in more places.
    global vTcl
    set w [$widget subwidget $hlist]
    set config [$w config]
    # The following loop was borrowed from vTcl:python_configure_widget
    # It needs to be modified to return not a configure call but a
    # list for -options.
    set options ""
    foreach c  $config {
        if {[llength $c] == 5 &&
            [string first "Cmd" [lindex $c 1]] ==  -1 &&
            [string first "command" [lindex $c 1]] ==  -1 &&
            [string first "Command" [lindex $c 1]] ==  -1 } {
            if {[lindex $c 3] != [lindex $c 4]} {
                set str [lindex $c 0]
                # get rid of the - sign.
                set len [string length $str]
                set sub [string range $str 1 [expr $len -1]]
                append options \
              "\\\n$vTcl(tab2)$vTcl(tab2)$hlist.[lindex $c 1] \"[lindex $c 4]\""
            }
        }
    }
    return $options
}


proc vTcl:python_nb_tab_configure {target tab} {
    # Ttk version of program to handle the setting of options for
    # tTnotebook.
    global vTcl
    set output ""
    set vTcl(encoding) ""
    set tab_options [$target tab $tab]
    foreach {opt val} $tab_options {
        set str [lindex $opt]
        # get rid of the - sign.
        set len [string length $str]
        set sub [string range $str 1 [expr $len -1]]
        switch $sub {
            underline -
            text {
                append output "$sub=\"$val\","
            }
            image {
                # Generate code for the image!
                if {[info exists vTcl(images,filename,$val)]} {
                    set file $vTcl(images,filename,$val)
                    set file_name [regsub [pwd]/ $file ""] ;# Relative path.
                    set vTcl(encoding) $file_name
                    #set encoding [base64::encode_file $file]
                    #set vTcl(encoding) $encoding
                }
                #                append output "$sub=\"$val\","
            }
            compound {
                # if {$val == "none"} {
                #     set val "left"
                # }
                append output "$sub=\"$val\","

            }
        }
    }
    return $output
}

proc vTcl:python_nb_page_configure {p widget widname name} {
    # Configures the option of the pageframe widget (TixNotebook)
    global vTcl
    set output ""
    set config [$widget pageconfigure $p]
    foreach c  $config {
        if {[llength $c] == 5 && [string first "cmd" [lindex $c 1]] ==  -1 } {
            if {[lindex $c 3] != [lindex $c 4]} {
                set str [lindex $c 0]
                # get rid of the - sign.
                set len [string length $str]
                set sub [string range $str 1 [expr $len -1]]
                append output \
                     ",$sub=\"[lindex $c 4]\""
            }
        }
    }
    return $output
}

proc vTcl:create_balloon_code {window} {
    # Generates a code string containing any of the balloon
    # code needed.
    global vTcl
    set balloon_widgets [vTcl:find_widgets_with_balloon_msg $window]
    set balloon_code ""
    if {[llength $balloon_widgets] > 0} {
        append balloon_code \
           "$vTcl(tab2)self.balloon = Tix.Balloon(master)\n"
        foreach w $balloon_widgets {
            set widname [vTcl:widget_2_widname $w]
            append balloon_code \
         "$vTcl(tab2)self.balloon.bind_widget(self.$widname,"\
         "balloonmsg=\"$vTcl($w,balloon_msg)\")\n"
        }
        append balloon_code \
           "$vTcl(tab2)self.balloon.configure(bg='blue', borderwidth=3)"
    }
    return $balloon_code
}

proc vTcl:widget_2_widname {target} {
    # See if there is an alias defined, if so return it.  Otherwise,
    # transform the widget name by replacing the periods with '_'.
    # Originally, it was written assuming that the first character was
    # "." but it maybe something like $top which would throw off the
    # the indices 2 and 3 below.
    global vTcl widget
    # in case target is an alias, then just return it!
    if {[info exists vTcl(alias_names)]} {
        if {[lsearch -exact $vTcl(alias_names) $target] > -1} {
            return $target
        }
    }
    if {[catch {set alias $widget(rev,$target)}]} {
        # This is the otherwise path: no alias
        set pieces [split $target ".$"]
        set no [llength $pieces]
        set first [lindex $pieces 2]
        set sublist [lrange $pieces 3 end]
        set widname $first
        # What I am doing is risky. NEEDS WORK
        foreach p $sublist {
            set p_trim [string trim $p \"]
            append widname "_" $p_trim
        }
    } else {
        # Work on the alias rather than the target value. Replace
        # blanks with '_' in the alias.
        set pieces [split $alias]
        set widname [lindex $pieces 0]
        if {[llength $pieces] > 1} {
            set sublist [lrange $pieces 1 end]
            foreach p $sublist {
                set p_trim [string trim $p]
                append widname "_" $p_trim
            }
        }
        lappend vTcl(alias_names) $widname
    }
    return $widname
}

proc vTcl:python_set_alias {target name} {
    # Sees if an alias exists and if so put out an assignment in the
    #  wrong place.  This needs to be fixed.  NEEDS WORK
    global vTcl widget
    if {[catch {set alias $widget(rev,$target)}]} {
        return
    } else {
        # Don't put out this statement, Try a comment instead.
        append vTcl(py_initfunc) \
                "$vTcl(tab2)$alias = $name  \# alias $target\n"
    }
}

proc vTcl:python_alias {alias target} {
    # Update the current value of alias when the
    # alias field in the attribute editor is changed.
    # Never called ??
    global vTcl widget
    catch {
        unset widget($was)
        unset widget(rev,$target)
    }
    if {$alias != ""} {
        set widget($alias) $target
        set widget(rev,$target) $alias
    }
}

proc vTcl:python_dump_bind {target widname} {
    # This is a take off from vTcl:dump_widget_bind
    global vTcl
    set class [vTcl:get_class $target]
    # set needle [string first "Scrolled" $class]
    # if {$needle > -1}  {
    #     set result [vTcl:python_dump_bind $target.01 $widname]
    #     return $result
    # }
    set result ""
    if {[catch {bindtags $target \{$vTcl(bindtags,$target)\}}]} {
        return ""
    }
    set bindlist [lsort [bind $target]]
    foreach i $bindlist {
        set command [bind $target $i]
        set command [string trim $command]
        if {[regexp "lambda.*:(.*)" $command match name]} {
            # We have a lambda function so there separate out the
            # callback name and add to the function list to be
            # created.

            # This is the only condition which will occur for popup
            # menus and so for a popup I call a special routine rather
            # than have a big if bock here.
            set class [vTcl:get_class $target]
            if {[string first "pop" $name] > -1} {
                # Binding refers to popup menu so we put out special
                # case code and leave.
                if {[string first "self" $name] == -1} {
                    regsub "popup" $command "self.popup" cmd
                } else {
                    set cmd $command
                }
                #set cmd [vTcl:prepend_import_name $command $widname]
                #set cmd "self.$command"
                if {$class == "Toplevel"} {
                    set b_name top
                } else {
                    set b_name self.$widname
                }
                append result \
"$vTcl(tab2)if (root.tk.call('tk', 'windowingsystem')=='aqua'):
$vTcl(tab2)$vTcl(tab)$b_name.bind('<Control-1>', $cmd)
$vTcl(tab2)$vTcl(tab)$b_name.bind('<Button-2>', $cmd)
$vTcl(tab2)else:
$vTcl(tab2)$vTcl(tab)$b_name.bind('<Button-3>', $cmd)
"
#return $result
                continue
}
            set name [string trim $name]
            lappend vTcl(funct_list) $name
        } else {
            # If I got here then the command is not a lambda function
            # but rather a function name is added it to the list of
            # functions to generate. However one still need to have at
            # least one parameter which is the event.  If there were
            # more parameters then we would have been in the lambda
            # branch above where there would have been the event
            # variable.
            if {$command != "_mouse_over" &&
                $command != "_button_press" &&
                $command != "_button_release"} {
                set name [string trim $command]
                append name "(e)"
                lappend vTcl(funct_list) $name
            }
        }
        if {"$vTcl(bind,ignore)" == "" ||
               ![regexp "^($vTcl(bind,ignore))" $command] } {
            if { ![regexp "focus" $command] } { # This if is another of
                                                # those tix hacks._e,
                # Special case for PNotebooks.  The command is in the GUI module.
                if {$class != "PNotebook"} {
                    set command [vTcl:prepend_import_name $command]
                } elseif {$command != "_mouse_over" &&
                          $command != "_button_press" &&
                          $command != "_button_release"} {
                    set command [vTcl:prepend_import_name $command]
                }
                if {$class == "Toplevel"} {
                    append result \
                        "$vTcl(tab2)top.bind('$i',$command)\n"
                } else {
                    append result \
                        "$vTcl(tab2)self.$widname.bind('$i',$command)\n"
}
            }
        }
    }
    bindtags $target vTcl(b)
    return $result
}

proc x_compare {a b} {
    set alast [lindex $a end]
    set blast [lindex $b end]/home/rozen/pkg/idleX/idlex-1.12
    if {$alast <= $blast} {
        return -1
    } else {
        return 1
    }
}

proc vTcl:python_process_menubutton {menubutton widname} {

}

proc vTcl:sort_menubuttons {} {
    global vTcl
    set sort_list {}
    foreach i $vTcl(menubutton_list) {
        set x [winfo x $i]
        set item [list $i $x]
        lappend sort_list $item
    }
    set new [lsort -command x_compare $sort_list
    return $new
}

proc vTcl:python_idle_checks {filename}  {
    global vTcl
return  ""
    if {$vTcl(gui_py_change_time) < $vTcl(gui_change_time)} {
        set question "GUI definition has been changed since GUI module created. Do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
                         question 0 "Cancel" "Proceed"]
        if {$choice == 0} {
            return "BAIL"
        }
    }
    if {[info exists vTcl(source_window)]} {
        set new_content [$vTcl(source_window) get 1.0 end] ;# Read
                                                            # contents
                                                            # of
                                                            # Python
                                                            # Console
        if {[vTcl:test_file_content $filename $new_content] == 1} {  NEEDS WORK
            set question "Python Console with GUI module has changed since last save; do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
                         question 0 "Cancel" "Proceed"]
            if {$choice == 0} {
                return "BAIL"
            }
        }
    }
    return ""
}

proc vTcl:load_python_idle {} {
    global vTcl
    if { $vTcl(ide_cmd) == ""} {
        tk_messageBox -title Error -message "No IDE command has been specified."
        return
    }
    if {! $vTcl(project_specified)} {
        set choice [tk_dialog .foo "ERROR" \
                        "No project specified. \nNot opening IDE." \
                        question 0 "OK"]
        return
    }
    set fg "[file rootname $vTcl(project,file)].py"
    set fs "[file rootname $vTcl(project,file)]_support.py"
    if {[vTcl:python_idle_checks $fg] == "BAIL"} return
    set fs_exists [file exists $fs]
    set fg_exists [file exists $fg]
    if {!$fs_exists && !$fg_exists} {
        set msg "No GUI or support files."
        tk_dialog .foo "Warning" \
            "No GUI or support module has been saved." \
            question 0 "OK"
        return
    }
    if {[winfo exists .vTcl.gui_console] &&
        $vTcl(gui_save_warning) != ""} {
        set question "GUI console contains unsaved changes. Do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
                         question 0 "Cancel" "Proceed"]
        if {$choice == 0} {
            return "BAIL"
        }
    }
    if {[winfo exists .vTcl.supp_console] &&
        $vTcl(supp_save_warning) != ""} {
        set question "Support console contains unsaved changes. Do you want to proceed or cancel?"
        set choice [tk_dialog .foo "Warning" $question \
                         question 0 "Cancel" "Proceed"]
        if {$choice == 0} {
            return "BAIL"
        }
    }
    set result ""
    if {[file exists $fs] && [file exists $fg]} {
        #catch {exec $vTcl(ide_cmd) $fs $fg} result
        exec $vTcl(ide_cmd) $fs $fg
        return
    }
    if {[file exists $fs]} {
        #catch {exec $vTcl(ide_cmd) $fs} result
        exec $vTcl(ide_cmd) $fs
        return
    }
    if {[file exists $fg]} {
        set show_gui 0
        #catch {exec $vTcl(ide_cmd) $fg} result
        exec $vTcl(ide_cmd) $fg
        return
    }
    tk_messageBox -title Error -message "No project files exist to be loaded."
}

proc vTcl:load_console {prefix file} {
    # This loads the console from memory.  I used to issue a warning
    # about overwriting an existing console but I abandoned that
    # because of too many messages.
    global vTcl
    vTcl:Window.py_console $prefix
    update
    $vTcl(${prefix}_source_window) delete 1.0 end
    $vTcl(${prefix}_output_window) delete 1.0 end
    set fid [open $file r]
    set contents [read $fid]
    set numbered [vTcl:add_line_numbers $contents]

    $vTcl(${prefix}_source_window) insert end $numbered
    set vTcl(${prefix}_search_pattern) ""
    close $fid
    if {$prefix == "supp"} {
        set vTcl(imported_variable) 0        ;# Moved init stuff here 12/18/15
        set vTcl(support_variable_list)  []
        set vTcl(support_function_list)  []
        set vTcl(import_filename) $file
    }
    vTcl:colorize_python $prefix
    set vTcl(${prefix}_save_warning) ""
    $vTcl(${prefix}_source_window) edit modified 0
}


proc vTcl:load_python_consoles {} {
    # Loads existing project into the two python consoles.
    global vTcl
    if {! $vTcl(project_specified)} {
        set choice [tk_dialog .foo "ERROR" \
                        "No project specified. \nExiting" \
                        question 0 "OK"]
        return
    }
    set fg "[file rootname $vTcl(project,file)].py"
    set fs "[file rootname $vTcl(project,file)]_support.py"
    if {[vTcl:python_idle_checks $fg] == "BAIL"} return
    set fs_exists [file exists $fs]
    set fg_exists [file exists $fg]
    if {!$fs_exists && !$fg_exists} {
        set msg "No GUI or support files."
        tk_dialog .foo "Warning" \
            "No GUI or support module has been saved." \
            question 0 "OK"
        return
    }
    if {[file exists $fs] && [file exists $fg]} {
        vTcl:load_console "gui" $fg
        vTcl:load_console "supp" $fs
        update
        set vTcl(gui_save_warning) ""
        set vTcl(supp_save_warning) ""
        return
    }
    if {[file exists $fs]} {
        vTcl:load_console "supp" $fs
        update
        set vTcl(gui_save_warning) ""
    }
    if {[file exists $fg]} {
        vTcl:load_console "gui" $fg
        update
        set vTcl(supp_save_warning) ""
    }
}

proc vTcl:clean_string {str} {
    # Replace characters that would be illegal in a Python2 identifier
    # with '_'.
    for {set i 0} {$i<[string length $str]} {incr i} {
        set char [string index $str $i]
        set ret [regexp {[0-9a-zA-Z_]} $char]
        if {$ret == 0} {
            set str [string replace $str $i $i "_"]
        }
    }
    return $str
}

# For debugging purposes.
proc printenv { args } {
    global env
    set maxl 0
    if {[llength $args] == 0} {
        set args [lsort [array names env]]
    }
    foreach x $args {
        if {[string length $x] > $maxl} {
            set maxl [string length $x]
        }
    }
    incr maxl 2
    foreach x $args {
        puts stdout [format "%*s = %s" $maxl $x $env($x)]
    }
}

proc vTcl:calc_relative_geometry {target} {
    global rel
    # Split the target geometry into w, h, x, y
    foreach {w h x y} [split [winfo geometry $target] "x+"] {}
    set x [expr $x - [expr $x % 5]]
    set y [expr $y - [expr $y % 5]]
    set parent_window [winfo parent $target]
    ### Have to play games with the TNotebook because only one of the
    ### children widgets is mapped and the geometry of unmapped widget
    ### is unusable. So we go to the grand parent and run thru the
    ### tabs to find the one that is mapped and use its geometry. 4/3/17
    set grand_parent_window [winfo parent $parent_window]
    if {$grand_parent_window != ""} {
        set gpc [winfo class $grand_parent_window]
    } else {
        set gpc ""
    }
    if {$gpc == "TNotebook"} {
        foreach t [$grand_parent_window tabs] {
            if {[set parent_geometry [winfo geometry $t]] != "1x1+0+0"} {
                break
            }
        }
    } else {
        set parent_geometry [winfo geometry $parent_window]
    }
    foreach {W H X Y} [split $parent_geometry "x+"] {}  ;# new 4/3/17
    set rel(x) $x
    set rel(y) $y
    set rel(h) $h
    set rel(w) $w
    set relx [expr $x / $W.0]
    set rel(relx) [expr {round($relx*1000)/1000.0}]
    set rely [expr $y / $H.0]
    set rel(rely) [expr {round($rely*1000)/1000.0}]
    set relw [expr $w / $W.0]
    set rel(relw) [expr {round($relw*1000)/1000.0}]
    set relh [expr $h / $H.0]
    set rel(relh) [expr {round($relh*1000)/1000.0}]
}
