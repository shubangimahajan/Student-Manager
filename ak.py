#! /usr/bin/env python
#  -*- coding: utf-8 -*-
#
# GUI module generated by PAGE version 4.19
#  in conjunction with Tcl version 8.6
#    Dec 28, 2018 09:44:40 AM IST  platform: Windows NT

import sys

try:
    import Tkinter as tk
except ImportError:
    import tkinter as tk

try:
    import ttk
    py3 = False
except ImportError:
    import tkinter.ttk as ttk
    py3 = True

import ak_support

def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = tk.Tk()
    ak_support.set_Tk_var()
    top = Toplevel1 (root)
    ak_support.init(root, top)
    root.mainloop()

w = None
def create_Toplevel1(root, *args, **kwargs):
    '''Starting point when module is imported by another program.'''
    global w, w_win, rt
    rt = root
    w = tk.Toplevel (root)
    ak_support.set_Tk_var()
    top = Toplevel1 (w)
    ak_support.init(w, top, *args, **kwargs)
    return (w, top)

def destroy_Toplevel1():
    global w
    w.destroy()
    w = None

class Toplevel1:
    def __init__(self, top=None):
        '''This class configures and populates the toplevel window.
           top is the toplevel containing window.'''
        _bgcolor = '#d9d9d9'  # X11 color: 'gray85'
        _fgcolor = '#000000'  # X11 color: 'black'
        _compcolor = '#d9d9d9' # X11 color: 'gray85'
        _ana1color = '#d9d9d9' # X11 color: 'gray85' 
        _ana2color = '#ececec' # Closest X11 color: 'gray92' 
        self.style = ttk.Style()
        if sys.platform == "win32":
            self.style.theme_use('winnative')
        self.style.configure('.',background=_bgcolor)
        self.style.configure('.',foreground=_fgcolor)
        self.style.configure('.',font="TkDefaultFont")
        self.style.map('.',background=
            [('selected', _compcolor), ('active',_ana2color)])

        top.geometry("600x450+451+169")
        top.title("New Toplevel")
        top.configure(background="#d9d9d9")

        self.TCombobox1 = ttk.Combobox(top)
        self.TCombobox1.place(relx=0.2, rely=0.089, relheight=0.047
                , relwidth=0.238)
        self.value_list = [10,20,30,40,]
        self.TCombobox1.configure(values=self.value_list)
        self.TCombobox1.configure(textvariable=ak_support.combobox)
        self.TCombobox1.configure(takefocus="")

        self.rmale = tk.Radiobutton(top)
        self.rmale.place(relx=0.3, rely=0.244, relheight=0.056, relwidth=0.09)
        self.rmale.configure(activebackground="#ececec")
        self.rmale.configure(activeforeground="#000000")
        self.rmale.configure(background="#d9d9d9")
        self.rmale.configure(disabledforeground="#a3a3a3")
        self.rmale.configure(foreground="#000000")
        self.rmale.configure(highlightbackground="#d9d9d9")
        self.rmale.configure(highlightcolor="black")
        self.rmale.configure(justify='left')
        self.rmale.configure(text='''Male''')
        self.rmale.configure(value="Male")

        self.rfemale = tk.Radiobutton(top)
        self.rfemale.place(relx=0.467, rely=0.244, relheight=0.056
                , relwidth=0.11)
        self.rfemale.configure(activebackground="#ececec")
        self.rfemale.configure(activeforeground="#000000")
        self.rfemale.configure(background="#d9d9d9")
        self.rfemale.configure(disabledforeground="#a3a3a3")
        self.rfemale.configure(foreground="#000000")
        self.rfemale.configure(highlightbackground="#d9d9d9")
        self.rfemale.configure(highlightcolor="black")
        self.rfemale.configure(justify='left')
        self.rfemale.configure(text='''Female''')
        self.rfemale.configure(value="Female")

        self.style.configure('TSizegrip', background=_bgcolor)
        self.TSizegrip1 = ttk.Sizegrip(top)
        self.TSizegrip1.place(anchor='se', relx=1.0, rely=1.0)

    @staticmethod
    def popup1(event, *args, **kwargs):
        Popupmenu1 = tk.Menu(root, tearoff=0)
        Popupmenu1.configure(activebackground="#f9f9f9")
        Popupmenu1.configure(activeborderwidth="1")
        Popupmenu1.configure(activeforeground="black")
        Popupmenu1.configure(background="#d9d9d9")
        Popupmenu1.configure(borderwidth="1")
        Popupmenu1.configure(disabledforeground="#a3a3a3")
        Popupmenu1.configure(font="{Segoe UI} 9")
        Popupmenu1.configure(foreground="black")
        Popupmenu1.post(event.x_root, event.y_root)

    @staticmethod
    def popup2(event, *args, **kwargs):
        Popupmenu2 = tk.Menu(root, tearoff=0)
        Popupmenu2.configure(activebackground="#f9f9f9")
        Popupmenu2.configure(activeborderwidth="1")
        Popupmenu2.configure(activeforeground="black")
        Popupmenu2.configure(background="#d9d9d9")
        Popupmenu2.configure(borderwidth="1")
        Popupmenu2.configure(disabledforeground="#a3a3a3")
        Popupmenu2.configure(font="{Segoe UI} 9")
        Popupmenu2.configure(foreground="black")
        Popupmenu2.post(event.x_root, event.y_root)

    @staticmethod
    def popup3(event, *args, **kwargs):
        Popupmenu3 = tk.Menu(root, tearoff=0)
        Popupmenu3.configure(activebackground="#f9f9f9")
        Popupmenu3.configure(activeborderwidth="1")
        Popupmenu3.configure(activeforeground="black")
        Popupmenu3.configure(background="#d9d9d9")
        Popupmenu3.configure(borderwidth="1")
        Popupmenu3.configure(disabledforeground="#a3a3a3")
        Popupmenu3.configure(font="{Segoe UI} 9")
        Popupmenu3.configure(foreground="black")
        Popupmenu3.post(event.x_root, event.y_root)

    @staticmethod
    def popup4(event, *args, **kwargs):
        Popupmenu4 = tk.Menu(root, tearoff=0)
        Popupmenu4.configure(activebackground="#f9f9f9")
        Popupmenu4.configure(activeborderwidth="1")
        Popupmenu4.configure(activeforeground="black")
        Popupmenu4.configure(background="#d9d9d9")
        Popupmenu4.configure(borderwidth="1")
        Popupmenu4.configure(disabledforeground="#a3a3a3")
        Popupmenu4.configure(font="{Segoe UI} 9")
        Popupmenu4.configure(foreground="black")
        Popupmenu4.post(event.x_root, event.y_root)

if __name__ == '__main__':
    vp_start_gui()




