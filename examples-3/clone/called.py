#! /usr/bin/env python
#
# GUI module generated by PAGE version 4.8.7a
# In conjunction with Tcl version 8.6
#    Jan 09, 2017 09:53:55 PM
import sys

try:
    from Tkinter import *
except ImportError:
    from tkinter import *

try:
    import ttk
    py3 = 0
except ImportError:
    import tkinter.ttk as ttk
    py3 = 1

import called_support

def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = Tk()
    called_support.set_Tk_var()
    top = Called (root)
    called_support.init(root, top)
    root.mainloop()

w = None
def create_Called(root, *args, **kwargs):
    '''Starting point when module is imported by another program.'''
    global w, w_win, rt
    rt = root
    w = Toplevel (root)
    called_support.set_Tk_var()
    top = Called (w)
    called_support.init(w, top, *args, **kwargs)
    return (w, top)

def destroy_Called():
    global w
    w.destroy()
    w = None


class Called:
    def __init__(self, top=None):
        '''This class configures and populates the toplevel window.
           top is the toplevel containing window.'''
        _bgcolor = 'wheat'  # X11 color: #f5deb3
        _fgcolor = '#000000'  # X11 color: 'black'
        _compcolor = '#b2c9f4' # Closest X11 color: 'SlateGray2'
        _ana1color = '#eaf4b2' # Closest X11 color: '{pale goldenrod}' 
        _ana2color = '#f4bcb2' # Closest X11 color: 'RosyBrown2' 
        font10 = "-family {DejaVu Sans} -size 14 -weight normal -slant"  \
            " roman -underline 0 -overstrike 0"

        top.geometry("600x450+650+150")
        top.title("Called")
        top.configure(background="wheat")
        top.configure(highlightbackground="wheat")
        top.configure(highlightcolor="black")



        self.Button1 = Button(top)
        self.Button1.place(relx=0.35, rely=0.24, height=35, width=145)
        self.Button1.configure(activebackground="#f4bcb2")
        self.Button1.configure(background="wheat")
        self.Button1.configure(command=lambda:called_support.create_called(rt))
        self.Button1.configure(disabledforeground="#b8a786")
        self.Button1.configure(font=font10)
        self.Button1.configure(highlightbackground="wheat")
        self.Button1.configure(text='''Create Clone''')

        self.Button2 = Button(top)
        self.Button2.place(relx=0.42, rely=0.78, height=35, width=76)
        self.Button2.configure(activebackground="#f4bcb2")
        self.Button2.configure(background="wheat")
        self.Button2.configure(command=lambda:top.destroy())
        self.Button2.configure(disabledforeground="#b8a786")
        self.Button2.configure(font=font10)
        self.Button2.configure(highlightbackground="wheat")
        self.Button2.configure(text='''Close''')

        self.Label1 = Label(top)
        self.Label1.place(relx=0.35, rely=0.47, height=27, width=273)
        self.Label1.configure(activebackground="#ffffcd")
        self.Label1.configure(anchor=W)
        self.Label1.configure(background="wheat")
        self.Label1.configure(disabledforeground="#b8a786")
        self.Label1.configure(font=font10)
        self.Label1.configure(highlightbackground="wheat")
        self.Label1.configure(text='''Label''')
        self.instance = StringVar()
        self.Label1.configure(textvariable=self.instance)

        self.Button3 = Button(top)
        self.Button3.place(relx=0.82, rely=0.76, height=35, width=65)
        self.Button3.configure(activebackground="#f4bcb2")
        self.Button3.configure(background="wheat")
        self.Button3.configure(command=called_support.quit)
        self.Button3.configure(disabledforeground="#b8a786")
        self.Button3.configure(font=font10)
        self.Button3.configure(highlightbackground="wheat")
        self.Button3.configure(text='''Quit''')

        self.Label2 = Label(top)
        self.Label2.place(relx=0.18, rely=0.09, height=30, width=432)
        self.Label2.configure(activebackground="#ffffcd")
        self.Label2.configure(background="wheat")
        self.Label2.configure(disabledforeground="#b8a786")
        self.Label2.configure(font=font10)
        self.Label2.configure(highlightbackground="#f5deb3")
        self.Label2.configure(text='''Label''')
        self.Label2.configure(textvariable=called_support.created_by)






if __name__ == '__main__':
    vp_start_gui()



