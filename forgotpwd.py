#! /usr/bin/env python
#  -*- coding: utf-8 -*-
#
# GUI module generated by PAGE version 4.19
#  in conjunction with Tcl version 8.6
#    Dec 31, 2018 01:45:40 PM IST  platform: Windows NT

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

import forgotpwd_support

def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = tk.Tk()
    forgotpwd_support.set_Tk_var()
    top = Toplevel1 (root)
    forgotpwd_support.init(root, top)
    root.mainloop()

w = None
def create_Toplevel1(root, *args, **kwargs):
    '''Starting point when module is imported by another program.'''
    global w, w_win, rt
    rt = root
    w = tk.Toplevel (root)
    forgotpwd_support.set_Tk_var()
    top = Toplevel1 (w)
    forgotpwd_support.init(w, top, *args, **kwargs)
    return (w, top)

def destroy_Toplevel1():
    global w
    w.destroy()
    w = None


class Toplevel1:
    def reset(self):
          self.epass.insert(0,"Data is wrong")	
    def pwd(self):
        username=self.euser.get()
        question=self.cques.get()
        answer=self.eans.get()
        import pymysql
        conn=pymysql.connect(host='localhost',user='root', passwd='admin',db='school')
        cursor=conn.cursor()

        cursor.execute('select * from tbadmin where username="%s" and question="%s" and answer="%s"'  % \
		           (username,question,answer))
        self.reset()
  
        cursor.description
        for rows in cursor:
          self.epass.delete(0,"end")		
          self.epass.insert(0,rows[1])
	
		   
        cursor.close()
        conn.close()
		
		   
		   
	
	
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

        top.geometry("600x450+296+145")
        top.title("New Toplevel")
        top.configure(background="#d9d9d9")
        top.configure(highlightbackground="#d9d9d9")
        top.configure(highlightcolor="black")

        self.cques = ttk.Combobox(top)
        self.cques.place(relx=0.4, rely=0.222, relheight=0.047, relwidth=0.272)
        self.value_list = ['whats your fathers name?','whichs your place of birth?','whos your best friend?','whichs your favourite book?','whats your favourite hobby?',]
        self.cques.configure(values=self.value_list)
        self.cques.configure(textvariable=forgotpwd_support.combobox)
        self.cques.configure(takefocus="")

        self.style.configure('TSizegrip', background=_bgcolor)
        self.TSizegrip1 = ttk.Sizegrip(top)
        self.TSizegrip1.place(anchor='se', relx=1.0, rely=1.0)

        self.Label1 = tk.Label(top)
        self.Label1.place(relx=0.167, rely=0.333, height=21, width=43)
        self.Label1.configure(activebackground="#f9f9f9")
        self.Label1.configure(activeforeground="black")
        self.Label1.configure(background="#d9d9d9")
        self.Label1.configure(disabledforeground="#a3a3a3")
        self.Label1.configure(foreground="#000000")
        self.Label1.configure(highlightbackground="#d9d9d9")
        self.Label1.configure(highlightcolor="black")
        self.Label1.configure(text='''answer''')

        self.Label2 = tk.Label(top)
        self.Label2.place(relx=0.167, rely=0.222, height=21, width=52)
        self.Label2.configure(activebackground="#f9f9f9")
        self.Label2.configure(activeforeground="black")
        self.Label2.configure(background="#d9d9d9")
        self.Label2.configure(disabledforeground="#a3a3a3")
        self.Label2.configure(foreground="#000000")
        self.Label2.configure(highlightbackground="#d9d9d9")
        self.Label2.configure(highlightcolor="black")
        self.Label2.configure(text='''question''')

        self.bcheck = tk.Button(top)
        self.bcheck.place(relx=0.5, rely=0.489, height=24, width=42)
        self.bcheck.configure(activebackground="#ececec")
        self.bcheck.configure(activeforeground="#000000")
        self.bcheck.configure(background="#d9d9d9")
        self.bcheck.configure(disabledforeground="#a3a3a3")
        self.bcheck.configure(foreground="#000000")
        self.bcheck.configure(highlightbackground="#d9d9d9")
        self.bcheck.configure(highlightcolor="black")
        self.bcheck.configure(pady="0")
        self.bcheck.configure(text='''check''')
        self.bcheck.configure(command=self.pwd)

        self.Label3 = tk.Label(top)
        self.Label3.place(relx=0.167, rely=0.111, height=21, width=58)
        self.Label3.configure(activebackground="#f9f9f9")
        self.Label3.configure(activeforeground="black")
        self.Label3.configure(background="#d9d9d9")
        self.Label3.configure(disabledforeground="#a3a3a3")
        self.Label3.configure(foreground="#000000")
        self.Label3.configure(highlightbackground="#d9d9d9")
        self.Label3.configure(highlightcolor="black")
        self.Label3.configure(text='''username''')
        
        self.euser = tk.Entry(top)
        self.euser.place(relx=0.4, rely=0.111,height=20, relwidth=0.273)
        self.euser.configure(background="white")
        self.euser.configure(disabledforeground="#a3a3a3")
        self.euser.configure(font="TkFixedFont")
        self.euser.configure(foreground="#000000")
        self.euser.configure(highlightbackground="#d9d9d9")
        self.euser.configure(highlightcolor="black")
        self.euser.configure(insertbackground="black")
        self.euser.configure(selectbackground="#c4c4c4")
        self.euser.configure(selectforeground="black")
		
        self.Menu = tk.Menu(top)
        self.Menu.configure(background="white")
        self.submenu=tk.submenu(top)
        self.submenu.configure(background="white")
		self.menu.add_cascade(label="file",menu="submenu")
		
        self.eans = tk.Entry(top)
        self.eans.place(relx=0.4, rely=0.333,height=20, relwidth=0.273)
        self.eans.configure(background="white")
        self.eans.configure(disabledforeground="#a3a3a3")
        self.eans.configure(font="TkFixedFont")
        self.eans.configure(foreground="#000000")
        self.eans.configure(highlightbackground="#d9d9d9")
        self.eans.configure(highlightcolor="black")
        self.eans.configure(insertbackground="black")
        self.eans.configure(selectbackground="#c4c4c4")
        self.eans.configure(selectforeground="black")

        self.Label4 = tk.Label(top)
        self.Label4.place(relx=0.183, rely=0.667, height=21, width=56)
        self.Label4.configure(activebackground="#f9f9f9")
        self.Label4.configure(activeforeground="black")
        self.Label4.configure(background="#d9d9d9")
        self.Label4.configure(disabledforeground="#a3a3a3")
        self.Label4.configure(foreground="#000000")
        self.Label4.configure(highlightbackground="#d9d9d9")
        self.Label4.configure(highlightcolor="black")
        self.Label4.configure(text='''password''')

        self.epass = tk.Entry(top)
        self.epass.place(relx=0.4, rely=0.667,height=20, relwidth=0.273)
        self.epass.configure(background="white")
        self.epass.configure(disabledforeground="#a3a3a3")
        self.epass.configure(font="TkFixedFont")
        self.epass.configure(foreground="#000000")
        self.epass.configure(highlightbackground="#d9d9d9")
        self.epass.configure(highlightcolor="black")
        self.epass.configure(insertbackground="black")
        self.epass.configure(selectbackground="#c4c4c4")
        self.epass.configure(selectforeground="black")
        self.epass.configure(text='''''')

        self.Label5 = tk.Label(top)
        self.Label5.place(relx=0.4, rely=0.555, height=50, width=50)
        self.Label5.configure(activebackground="#f9f9f9")
        self.Label5.configure(activeforeground="black")
        self.Label5.configure(background="#d9d9d9")
        self.Label5.configure(disabledforeground="#a3a3a3")
        self.Label5.configure(foreground="#000000")
        self.Label5.configure(highlightbackground="#d9d9d9")
        self.Label5.configure(highlightcolor="black")
        self.Label5.configure(text='''''')
	   
	   

        self.label = tk.Label(top)
        self.label.configure(activebackground="#f9f9f9")
        self.label.configure(activeforeground="black")
        self.label.configure(background="#d9d9d9")
        self.label.configure(disabledforeground="#a3a3a3")
        self.label.configure(foreground="#000000")
        self.label.configure(highlightbackground="#d9d9d9")
        self.label.configure(highlightcolor="black")
        self.label.configure(text='''''')
		

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

 

if __name__ == '__main__':
    vp_start_gui()





