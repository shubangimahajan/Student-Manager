#! /usr/bin/env python
#  -*- coding: utf-8 -*-
#
# GUI module generated by PAGE version 4.19
#  in conjunction with Tcl version 8.6
#    Dec 28, 2018 03:45:30 PM IST  platform: Windows NT

import sys
from tkinter import messagebox
 

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

import newstudent_support

def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = tk.Tk()
    newstudent_support.set_Tk_var()
    top = Toplevel1 (root)
    newstudent_support.init(root, top)
    root.mainloop()

w = None
def create_Toplevel1(root, *args, **kwargs):
    '''Starting point when module is imported by another program.'''
    global w, w_win, rt,gender
    rt = root
    w = tk.Toplevel (root)
    newstudent_support.set_Tk_var()
    top = Toplevel1 (w)
    newstudent_support.init(w, top, *args, **kwargs)
    return (w, top)

def destroy_Toplevel1():
    global w
    w.destroy()
    w = None

class Toplevel1:
    def male(self):
	    global gender
	    gender="Male"
    def female(self):
	    global gender
	    gender="Female"
    def student(self):
	    import pymysql;
	    admissionNo=self.eadm.get()
	    classs=self.cclass.get();
	    name=self.ename.get();
	    rollno=self.erollno.get();
	    if(self.rmale.select()):
		    male();
		    messagebox.showinfo("gender", "male")
	    if(self.rfemale.select()):
		    female();
		    messagebox.showinfo("gender", "female")
	    fathername=self.efather.get();
	    mothername=self.emother.get();
	    address=self.eadd.get();
	    phoneno=self.ephone.get();
	    eemail=self.email.get();
	    conn=pymysql.connect(host='localhost', user='root', passwd='admin', db='school');
	    cur=conn.cursor();
	    cur.execute('insert into tbstudent (id,rollno,name,classs,fathername,gender,mothername,address,phone,email) values ("%s","%s","%s","%s","%s","%s","%s","%s","%s","%s")' % \
              (admissionNo,rollno,name,classs,fathername,gender,mothername,address,phoneno,eemail));
	    conn.commit()
	    messagebox.showinfo("Student Record", "Data is saved")
		
	      

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

        top.geometry("600x448+400+186")
        top.title("New Toplevel")
        top.configure(background="#d9d9d9")
        top.configure(highlightbackground="#d9d9d9")
        top.configure(highlightcolor="black")

        self.Label1 = tk.Label(top)
        self.Label1.place(relx=0.217, rely=0.045, height=21, width=77)
        self.Label1.configure(activebackground="#f9f9f9")
        self.Label1.configure(activeforeground="black")
        self.Label1.configure(background="#d9d9d9")
        self.Label1.configure(disabledforeground="#a3a3a3")
        self.Label1.configure(foreground="#000000")
        self.Label1.configure(highlightbackground="#d9d9d9")
        self.Label1.configure(highlightcolor="black")
        self.Label1.configure(text='''admission no''')

        self.Label2 = tk.Label(top)
        self.Label2.place(relx=0.217, rely=0.179, height=21, width=31)
        self.Label2.configure(activebackground="#f9f9f9")
        self.Label2.configure(activeforeground="black")
        self.Label2.configure(background="#d9d9d9")
        self.Label2.configure(disabledforeground="#a3a3a3")
        self.Label2.configure(foreground="#000000")
        self.Label2.configure(highlightbackground="#d9d9d9")
        self.Label2.configure(highlightcolor="black")
        self.Label2.configure(text='''class''')

        self.Label3 = tk.Label(top)
        self.Label3.place(relx=0.217, rely=0.357, height=21, width=78)
        self.Label3.configure(activebackground="#f9f9f9")
        self.Label3.configure(activeforeground="black")
        self.Label3.configure(background="#d9d9d9")
        self.Label3.configure(disabledforeground="#a3a3a3")
        self.Label3.configure(foreground="#000000")
        self.Label3.configure(highlightbackground="#d9d9d9")
        self.Label3.configure(highlightcolor="black")
        self.Label3.configure(text='''father's name''')

        self.Label4 = tk.Label(top)
        self.Label4.place(relx=0.217, rely=0.268, height=21, width=36)
        self.Label4.configure(activebackground="#f9f9f9")
        self.Label4.configure(activeforeground="black")
        self.Label4.configure(background="#d9d9d9")
        self.Label4.configure(disabledforeground="#a3a3a3")
        self.Label4.configure(foreground="#000000")
        self.Label4.configure(highlightbackground="#d9d9d9")
        self.Label4.configure(highlightcolor="black")
        self.Label4.configure(text='''name''')

        self.Label5 = tk.Label(top)
        self.Label5.place(relx=0.217, rely=0.446, height=21, width=86)
        self.Label5.configure(activebackground="#f9f9f9")
        self.Label5.configure(activeforeground="black")
        self.Label5.configure(background="#d9d9d9")
        self.Label5.configure(disabledforeground="#a3a3a3")
        self.Label5.configure(foreground="#000000")
        self.Label5.configure(highlightbackground="#d9d9d9")
        self.Label5.configure(highlightcolor="black")
        self.Label5.configure(text='''mother's name''')

        self.Label6 = tk.Label(top)
        self.Label6.place(relx=0.217, rely=0.536, height=21, width=43)
        self.Label6.configure(activebackground="#f9f9f9")
        self.Label6.configure(activeforeground="black")
        self.Label6.configure(background="#d9d9d9")
        self.Label6.configure(disabledforeground="#a3a3a3")
        self.Label6.configure(foreground="#000000")
        self.Label6.configure(highlightbackground="#d9d9d9")
        self.Label6.configure(highlightcolor="black")
        self.Label6.configure(text='''gender''')

        self.Label7 = tk.Label(top)
        self.Label7.place(relx=0.217, rely=0.625, height=21, width=46)
        self.Label7.configure(activebackground="#f9f9f9")
        self.Label7.configure(activeforeground="black")
        self.Label7.configure(background="#d9d9d9")
        self.Label7.configure(disabledforeground="#a3a3a3")
        self.Label7.configure(foreground="#000000")
        self.Label7.configure(highlightbackground="#d9d9d9")
        self.Label7.configure(highlightcolor="black")
        self.Label7.configure(text='''address''')

        self.Label8 = tk.Label(top)
        self.Label8.place(relx=0.217, rely=0.714, height=21, width=40)
        self.Label8.configure(activebackground="#f9f9f9")
        self.Label8.configure(activeforeground="black")
        self.Label8.configure(background="#d9d9d9")
        self.Label8.configure(disabledforeground="#a3a3a3")
        self.Label8.configure(foreground="#000000")
        self.Label8.configure(highlightbackground="#d9d9d9")
        self.Label8.configure(highlightcolor="black")
        self.Label8.configure(text='''phone''')

        self.Label9 = tk.Label(top)
        self.Label9.place(relx=0.217, rely=0.804, height=21, width=35)
        self.Label9.configure(activebackground="#f9f9f9")
        self.Label9.configure(activeforeground="black")
        self.Label9.configure(background="#d9d9d9")
        self.Label9.configure(disabledforeground="#a3a3a3")
        self.Label9.configure(foreground="#000000")
        self.Label9.configure(highlightbackground="#d9d9d9")
        self.Label9.configure(highlightcolor="black")
        self.Label9.configure(text='''email''')

        self.bsave = tk.Button(top)
        self.bsave.place(relx=0.683, rely=0.915, height=24, width=34)
        self.bsave.configure(activebackground="#ececec")
        self.bsave.configure(activeforeground="#000000")
        self.bsave.configure(background="#d9d9d9")
        self.bsave.configure(disabledforeground="#a3a3a3")
        self.bsave.configure(foreground="#000000")
        self.bsave.configure(highlightbackground="#d9d9d9")
        self.bsave.configure(highlightcolor="black")
        self.bsave.configure(pady="0")
        self.bsave.configure(text='''save''')
        self.bsave.configure(command=self.student)

        self.eadm = tk.Entry(top)
        self.eadm.place(relx=0.483, rely=0.045,height=20, relwidth=0.273)
        self.eadm.configure(background="white")
        self.eadm.configure(disabledforeground="#a3a3a3")
        self.eadm.configure(font="TkFixedFont")
        self.eadm.configure(foreground="#000000")
        self.eadm.configure(highlightbackground="#d9d9d9")
        self.eadm.configure(highlightcolor="black")
        self.eadm.configure(insertbackground="black")
        self.eadm.configure(selectbackground="#c4c4c4")
        self.eadm.configure(selectforeground="black")

        self.ename = tk.Entry(top)
        self.ename.place(relx=0.483, rely=0.268,height=20, relwidth=0.273)
        self.ename.configure(background="white")
        self.ename.configure(disabledforeground="#a3a3a3")
        self.ename.configure(font="TkFixedFont")
        self.ename.configure(foreground="#000000")
        self.ename.configure(highlightbackground="#d9d9d9")
        self.ename.configure(highlightcolor="black")
        self.ename.configure(insertbackground="black")
        self.ename.configure(selectbackground="#c4c4c4")
        self.ename.configure(selectforeground="black")

        self.efather = tk.Entry(top)
        self.efather.place(relx=0.483, rely=0.357,height=20, relwidth=0.273)
        self.efather.configure(background="white")
        self.efather.configure(disabledforeground="#a3a3a3")
        self.efather.configure(font="TkFixedFont")
        self.efather.configure(foreground="#000000")
        self.efather.configure(highlightbackground="#d9d9d9")
        self.efather.configure(highlightcolor="black")
        self.efather.configure(insertbackground="black")
        self.efather.configure(selectbackground="#c4c4c4")
        self.efather.configure(selectforeground="black")

        self.emother = tk.Entry(top)
        self.emother.place(relx=0.483, rely=0.446,height=20, relwidth=0.273)
        self.emother.configure(background="white")
        self.emother.configure(disabledforeground="#a3a3a3")
        self.emother.configure(font="TkFixedFont")
        self.emother.configure(foreground="#000000")
        self.emother.configure(highlightbackground="#d9d9d9")
        self.emother.configure(highlightcolor="black")
        self.emother.configure(insertbackground="black")
        self.emother.configure(selectbackground="#c4c4c4")
        self.emother.configure(selectforeground="black")

        self.eadd = tk.Entry(top)
        self.eadd.place(relx=0.483, rely=0.625,height=20, relwidth=0.273)
        self.eadd.configure(background="white")
        self.eadd.configure(disabledforeground="#a3a3a3")
        self.eadd.configure(font="TkFixedFont")
        self.eadd.configure(foreground="#000000")
        self.eadd.configure(highlightbackground="#d9d9d9")
        self.eadd.configure(highlightcolor="black")
        self.eadd.configure(insertbackground="black")
        self.eadd.configure(selectbackground="#c4c4c4")
        self.eadd.configure(selectforeground="black")

        self.ephone = tk.Entry(top)
        self.ephone.place(relx=0.483, rely=0.714,height=20, relwidth=0.273)
        self.ephone.configure(background="white")
        self.ephone.configure(disabledforeground="#a3a3a3")
        self.ephone.configure(font="TkFixedFont")
        self.ephone.configure(foreground="#000000")
        self.ephone.configure(highlightbackground="#d9d9d9")
        self.ephone.configure(highlightcolor="black")
        self.ephone.configure(insertbackground="black")
        self.ephone.configure(selectbackground="#c4c4c4")
        self.ephone.configure(selectforeground="black")

        self.email = tk.Entry(top)
        self.email.place(relx=0.483, rely=0.804,height=20, relwidth=0.273)
        self.email.configure(background="white")
        self.email.configure(disabledforeground="#a3a3a3")
        self.email.configure(font="TkFixedFont")
        self.email.configure(foreground="#000000")
        self.email.configure(highlightbackground="#d9d9d9")
        self.email.configure(highlightcolor="black")
        self.email.configure(insertbackground="black")
        self.email.configure(selectbackground="#c4c4c4")
        self.email.configure(selectforeground="black")

        self.rmale = tk.Radiobutton(top)
        self.rmale.place(relx=0.483, rely=0.536, relheight=0.056, relwidth=0.09)
        self.rmale.configure(activebackground="#ececec")
        self.rmale.configure(activeforeground="#000000")
        self.rmale.configure(background="#d9d9d9")
        self.rmale.configure(disabledforeground="#a3a3a3")
        self.rmale.configure(foreground="#000000")
        self.rmale.configure(highlightbackground="#d9d9d9")
        self.rmale.configure(highlightcolor="black")
        self.rmale.configure(justify='left')
        self.rmale.configure(variable='v')
        self.rmale.configure(text='''male''')
        self.rmale.configure(value="male")
        self.rmale.configure(command=self.male)

        self.rfemale = tk.Radiobutton(top)
        self.rfemale.place(relx=0.65, rely=0.536, relheight=0.056
                , relwidth=0.107)
        self.rfemale.configure(activebackground="#ececec")
        self.rfemale.configure(activeforeground="#000000")
        self.rfemale.configure(background="#d9d9d9")
        self.rfemale.configure(disabledforeground="#a3a3a3")
        self.rfemale.configure(foreground="#000000")
        self.rfemale.configure(highlightbackground="#d9d9d9")
        self.rfemale.configure(highlightcolor="black")
        self.rfemale.configure(justify='left')
        self.rfemale.configure(variable='v')
        self.rfemale.configure(text='''female''')
        self.rfemale.configure(value="female")
        self.rfemale.configure(command=self.female)

        self.cclass = ttk.Combobox(top)
        self.cclass.place(relx=0.483, rely=0.179, relheight=0.047
                , relwidth=0.272)
        self.value_list = [1,2,3,4,5,6,7,8,9,10,]
        self.cclass.configure(values=self.value_list)
        self.cclass.configure(textvariable=newstudent_support.combobox)
        self.cclass.configure(takefocus="")

        self.erollno = tk.Entry(top)
        self.erollno.place(relx=0.483, rely=0.112,height=20, relwidth=0.273)
        self.erollno.configure(background="white")
        self.erollno.configure(disabledforeground="#a3a3a3")
        self.erollno.configure(font="TkFixedFont")
        self.erollno.configure(foreground="#000000")
        self.erollno.configure(insertbackground="black")

        self.Label10 = tk.Label(top)
        self.Label10.place(relx=0.217, rely=0.112, height=21, width=40)
        self.Label10.configure(background="#d9d9d9")
        self.Label10.configure(disabledforeground="#a3a3a3")
        self.Label10.configure(foreground="#000000")
        self.Label10.configure(text='''roll no''')

if __name__ == '__main__':
    vp_start_gui()





