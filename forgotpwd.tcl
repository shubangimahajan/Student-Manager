#############################################################################
# Generated by PAGE version 4.19
#  in conjunction with Tcl version 8.6
#  Dec 31, 2018 01:45:33 PM IST  platform: Windows NT
set vTcl(timestamp) ""


if {!$vTcl(borrow)} {

set vTcl(actual_gui_bg) #d9d9d9
set vTcl(actual_gui_fg) #000000
set vTcl(actual_gui_analog) #ececec
set vTcl(actual_gui_menu_analog) #ececec
set vTcl(actual_gui_menu_bg) #d9d9d9
set vTcl(actual_gui_menu_fg) #000000
set vTcl(complement_color) #d9d9d9
set vTcl(analog_color_p) #d9d9d9
set vTcl(analog_color_m) #ececec
set vTcl(active_fg) #000000
set vTcl(actual_gui_menu_active_bg)  #ececec
set vTcl(active_menu_fg) #000000
}

#################################
#LIBRARY PROCEDURES
#


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top42
    global vTcl
    set base $vTcl(btop)
    if {$base == ""} {
        set base .top42
    }
    namespace eval ::widgets::$base {
        set dflt,origin 0
        set runvisible 1
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# GENERATED GUI PROCEDURES
#
    menu .pop46 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -font {{Segoe UI} 9} -foreground black \
        -tearoff 1 
    vTcl:DefineAlias ".pop46" "Popupmenu1" vTcl:WidgetProc "" 1
    menu .pop47 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -font {{Segoe UI} 9} -foreground black \
        -tearoff 1 
    vTcl:DefineAlias ".pop47" "Popupmenu2" vTcl:WidgetProc "" 1
    menu .pop48 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -font {{Segoe UI} 9} -foreground black \
        -tearoff 1 
    vTcl:DefineAlias ".pop48" "Popupmenu3" vTcl:WidgetProc "" 1
    menu .pop49 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -font {{Segoe UI} 9} -foreground black \
        -tearoff 1 
    vTcl:DefineAlias ".pop49" "Popupmenu4" vTcl:WidgetProc "" 1

proc vTclWindow.top42 {base} {
    if {$base == ""} {
        set base .top42
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl::widgets::core::toplevel::createCmd $top -class Toplevel \
        -background {#d9d9d9} -highlightbackground {#d9d9d9} \
        -highlightcolor black 
    wm focusmodel $top passive
    wm geometry $top 600x450+296+145
    update
    # set in toplevel.wgt.
    global vTcl
    global img_list
    set vTcl(save,dflt,origin) 0
    wm maxsize $top 1370 749
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "New Toplevel"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    ttk::combobox $top.tCo43 \
        -font TkTextFont -textvariable combobox -foreground {} -background {} \
        -takefocus {} 
    vTcl:DefineAlias "$top.tCo43" "cques" vTcl:WidgetProc "Toplevel1" 1
    ttk::style configure TSizegrip -background #d9d9d9
    vTcl::widgets::ttk::sizegrip::CreateCmd $top.tSi51 \
        -cursor size_nw_se 
    vTcl:DefineAlias "$top.tSi51" "TSizegrip1" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab52 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -disabledforeground {#a3a3a3} \
        -font TkDefaultFont -foreground {#000000} \
        -highlightbackground {#d9d9d9} -highlightcolor black -text answer 
    vTcl:DefineAlias "$top.lab52" "Label1" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab53 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -disabledforeground {#a3a3a3} \
        -font TkDefaultFont -foreground {#000000} \
        -highlightbackground {#d9d9d9} -highlightcolor black -text question 
    vTcl:DefineAlias "$top.lab53" "Label2" vTcl:WidgetProc "Toplevel1" 1
    button $top.but54 \
        -activebackground {#ececec} -activeforeground {#000000} \
        -background {#d9d9d9} -disabledforeground {#a3a3a3} \
        -font TkDefaultFont -foreground {#000000} \
        -highlightbackground {#d9d9d9} -highlightcolor black -pady 0 \
        -text check 
    vTcl:DefineAlias "$top.but54" "bcheck" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab55 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -disabledforeground {#a3a3a3} \
        -font TkDefaultFont -foreground {#000000} \
        -highlightbackground {#d9d9d9} -highlightcolor black -text username 
    vTcl:DefineAlias "$top.lab55" "Label3" vTcl:WidgetProc "Toplevel1" 1
    entry $top.ent56 \
        -background white -disabledforeground {#a3a3a3} -font TkFixedFont \
        -foreground {#000000} -highlightbackground {#d9d9d9} \
        -highlightcolor black -insertbackground black \
        -selectbackground {#c4c4c4} -selectforeground black 
    vTcl:DefineAlias "$top.ent56" "euser" vTcl:WidgetProc "Toplevel1" 1
    entry $top.ent57 \
        -background white -disabledforeground {#a3a3a3} -font TkFixedFont \
        -foreground {#000000} -highlightbackground {#d9d9d9} \
        -highlightcolor black -insertbackground black \
        -selectbackground {#c4c4c4} -selectforeground black 
    vTcl:DefineAlias "$top.ent57" "eans" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab58 \
        -activebackground {#f9f9f9} -activeforeground black \
        -background {#d9d9d9} -disabledforeground {#a3a3a3} \
        -font TkDefaultFont -foreground {#000000} \
        -highlightbackground {#d9d9d9} -highlightcolor black -text password 
    vTcl:DefineAlias "$top.lab58" "Label4" vTcl:WidgetProc "Toplevel1" 1
    entry $top.ent59 \
        -background white -disabledforeground {#a3a3a3} -font TkFixedFont \
        -foreground {#000000} -highlightbackground {#d9d9d9} \
        -highlightcolor black -insertbackground black \
        -selectbackground {#c4c4c4} -selectforeground black 
    vTcl:DefineAlias "$top.ent59" "epass" vTcl:WidgetProc "Toplevel1" 1
    button $top.but60 \
        -activebackground {#ececec} -activeforeground {#000000} \
        -background {#d9d9d9} -disabledforeground {#a3a3a3} \
        -font TkDefaultFont -foreground {#000000} \
        -highlightbackground {#d9d9d9} -highlightcolor black -pady 0 \
        -text save 
    vTcl:DefineAlias "$top.but60" "bsave" vTcl:WidgetProc "Toplevel1" 1
    ###################
    # SETTING GEOMETRY
    ###################
    place $top.tCo43 \
        -in $top -x 240 -y 100 -width 163 -relwidth 0 -height 21 -relheight 0 \
        -anchor nw -bordermode ignore 
    place $top.tSi51 \
        -in $top -x 0 -relx 1 -y 0 -rely 1 -anchor se -bordermode inside 
    place $top.lab52 \
        -in $top -x 100 -y 150 -anchor nw -bordermode ignore 
    place $top.lab53 \
        -in $top -x 100 -y 100 -anchor nw -bordermode ignore 
    place $top.but54 \
        -in $top -x 300 -y 220 -anchor nw -bordermode ignore 
    place $top.lab55 \
        -in $top -x 100 -y 50 -anchor nw -bordermode ignore 
    place $top.ent56 \
        -in $top -x 240 -y 50 -anchor nw -bordermode ignore 
    place $top.ent57 \
        -in $top -x 240 -y 150 -anchor nw -bordermode ignore 
    place $top.lab58 \
        -in $top -x 110 -y 300 -anchor nw -bordermode ignore 
    place $top.ent59 \
        -in $top -x 240 -y 300 -anchor nw -bordermode ignore 
    place $top.but60 \
        -in $top -x 300 -y 370 -anchor nw -bordermode ignore 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}

set btop ""
if {$vTcl(borrow)} {
    set btop .bor[expr int([expr rand() * 100])]
    while {[lsearch $btop $vTcl(tops)] != -1} {
        set btop .bor[expr int([expr rand() * 100])]
    }
}
set vTcl(btop) $btop
Window show .
Window show .top42 $btop
if {$vTcl(borrow)} {
    $btop configure -background plum
}

