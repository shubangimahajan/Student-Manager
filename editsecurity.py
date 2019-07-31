#! /usr/bin/env python
#  -*- coding: utf-8 -*-
#
# GUI module generated by PAGE version 4.19
#  in conjunction with Tcl version 8.6
#    Jan 03, 2019 11:15:43 AM IST  platform: Windows NT

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

import editsecurity_support

def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = tk.Tk()
    top = Toplevel1 (root)
    editsecurity_support.init(root, top)
    root.mainloop()

w = None
def create_Toplevel1(root, *args, **kwargs):
    '''Starting point when module is imported by another program.'''
    global w, w_win, rt
    rt = root
    w = tk.Toplevel (root)
    top = Toplevel1 (w)
    editsecurity_support.init(w, top, *args, **kwargs)
    return (w, top)

def destroy_Toplevel1():
    global w
    w.destroy()
    w = None

class Toplevel1:
    def change(self):
       if
    
    def __init__(self, top=None):
        '''This class configures and populates the toplevel window.
           top is the toplevel containing window.'''
        _bgcolor = '#d9d9d9'  # X11 color: 'gray85'
        _fgcolor = '#000000'  # X11 color: 'black'
        _compcolor = '#d9d9d9' # X11 color: 'gray85'
        _ana1color = '#d9d9d9' # X11 color: 'gray85' 
        _ana2color = '#ececec' # Closest X11 color: 'gray92' 

        top.geometry("600x450+371+165")
        top.title("New Toplevel")
        top.configure(background="#d9d9d9")
        top.configure(highlightbackground="#d9d9d9")
        top.configure(highlightcolor="black")

        self.Label1 = tk.Label(top)
        self.Label1.place(relx=0.2, rely=0.156, height=21, width=58)
        self.Label1.configure(activebackground="#f9f9f9")
        self.Label1.configure(activeforeground="black")
        self.Label1.configure(background="#d9d9d9")
        self.Label1.configure(disabledforeground="#a3a3a3")
        self.Label1.configure(foreground="#000000")
        self.Label1.configure(highlightbackground="#d9d9d9")
        self.Label1.configure(highlightcolor="black")
        self.Label1.configure(text='''username''')

        self.Label2 = tk.Label(top)
        self.Label2.place(relx=0.2, rely=0.267, height=21, width=52)
        self.Label2.configure(activebackground="#f9f9f9")
        self.Label2.configure(activeforeground="black")
        self.Label2.configure(background="#d9d9d9")
        self.Label2.configure(disabledforeground="#a3a3a3")
        self.Label2.configure(foreground="#000000")
        self.Label2.configure(highlightbackground="#d9d9d9")
        self.Label2.configure(highlightcolor="black")
        self.Label2.configure(text='''question''')

        self.Label3 = tk.Label(top)
        self.Label3.place(relx=0.2, rely=0.378, height=21, width=43)
        self.Label3.configure(activebackground="#f9f9f9")
        self.Label3.configure(activeforeground="black")
        self.Label3.configure(background="#d9d9d9")
        self.Label3.configure(disabledforeground="#a3a3a3")
        self.Label3.configure(foreground="#000000")
        self.Label3.configure(highlightbackground="#d9d9d9")
        self.Label3.configure(highlightcolor="black")
        self.Label3.configure(text='''answer''')

        self.eusername = tk.Entry(top)
        self.eusername.place(relx=0.333, rely=0.156,height=20, relwidth=0.29)
        self.eusername.configure(background="white")
        self.eusername.configure(disabledforeground="#a3a3a3")
        self.eusername.configure(font="TkFixedFont")
        self.eusername.configure(foreground="#000000")
        self.eusername.configure(highlightbackground="#d9d9d9")
        self.eusername.configure(highlightcolor="black")
        self.eusername.configure(insertbackground="black")
        self.eusername.configure(selectbackground="#c4c4c4")
        self.eusername.configure(selectforeground="black")
        self.eusername.configure(width=174)

        self.equestion = tk.Entry(top)
        self.equestion.place(relx=0.333, rely=0.267,height=20, relwidth=0.29)
        self.equestion.configure(background="white")
        self.equestion.configure(disabledforeground="#a3a3a3")
        self.equestion.configure(font="TkFixedFont")
        self.equestion.configure(foreground="#000000")
        self.equestion.configure(highlightbackground="#d9d9d9")
        self.equestion.configure(highlightcolor="black")
        self.equestion.configure(insertbackground="black")
        self.equestion.configure(selectbackground="#c4c4c4")
        self.equestion.configure(selectforeground="black")
        self.equestion.configure(width=174)

        self.eanswer = tk.Entry(top)
        self.eanswer.place(relx=0.333, rely=0.378,height=20, relwidth=0.29)
        self.eanswer.configure(background="white")
        self.eanswer.configure(disabledforeground="#a3a3a3")
        self.eanswer.configure(font="TkFixedFont")
        self.eanswer.configure(foreground="#000000")
        self.eanswer.configure(highlightbackground="#d9d9d9")
        self.eanswer.configure(highlightcolor="black")
        self.eanswer.configure(insertbackground="black")
        self.eanswer.configure(selectbackground="#c4c4c4")
        self.eanswer.configure(selectforeground="black")
        self.eanswer.configure(width=174)

        self.bdetail = tk.Button(top)
        self.bdetail.place(relx=0.4, rely=0.556, height=24, width=90)
        self.bdetail.configure(activebackground="#ececec")
        self.bdetail.configure(activeforeground="#000000")
        self.bdetail.configure(background="#d9d9d9")
        self.bdetail.configure(disabledforeground="#a3a3a3")
        self.bdetail.configure(foreground="#000000")
        self.bdetail.configure(highlightbackground="#d9d9d9")
        self.bdetail.configure(highlightcolor="black")
        self.bdetail.configure(pady="0")
        self.bdetail.configure(text='''Change Details''')

if __name__ == '__main__':
    vp_start_gui()




