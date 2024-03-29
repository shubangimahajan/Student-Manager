#! /usr/bin/env python
#  -*- coding: utf-8 -*-
#
# GUI module generated by PAGE version 4.19
#  in conjunction with Tcl version 8.6
#    Dec 28, 2018 02:45:06 PM IST  platform: Windows NT

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

import Receipt_support

def vp_start_gui():
    '''Starting point when module is the main routine.'''
    global val, w, root
    root = tk.Tk()
    Receipt_support.set_Tk_var()
    top = Toplevel1 (root)
    Receipt_support.init(root, top)
    root.mainloop()

w = None
def create_Toplevel1(root, *args, **kwargs):
    '''Starting point when module is imported by another program.'''
    global w, w_win, rt
    rt = root
    w = tk.Toplevel (root)
    Receipt_support.set_Tk_var()
    top = Toplevel1 (w)
    Receipt_support.init(w, top, *args, **kwargs)
    return (w, top)

def destroy_Toplevel1():
    global w
    w.destroy()
    w = None

class Toplevel1:
    def reset(self):
         self.eadmno.delete(0,'end');
         self.ename.delete(0,'end');
         self.etution.delete(0,'end');
         self.efine.delete(0,'end');       
         self.eannual.delete(0,'end');       
         self.eadmfees.delete(0,'end');   
         self.etotal.delete(0,'end');	   
         self.eroll.delete(0,'end');
         self.cclass.delete(0,'end');
         self.Label.configure(text='''data not found''')
        	    
    def search(self):
      import pymysql
      receipt=self.ereceipt.get()
      conn=pymysql.connect(host='localhost',user='root',passwd='admin',db='school')
      cur=conn.cursor()
      cur.execute('select * from tbfees where reciept="%s"' % \
              (receipt)	)
      cur.description
      self.reset()

      for row in cur:       
         self.eadmno.insert(0,row[8]);
         self.ename.insert(0,row[9]);
         self.etution.insert(0,row[4]);
         self.efine.insert(0,row[5]);       
         self.eannual.insert(0,row[3]);       
         self.eadmfees.insert(0,row[2]);   
         self.etotal.insert(0,row[6]);	   
         self.eroll.insert(0,row[7]);
         self.cclass.insert(0,row[1]);
         self.Label.configure(text='''''')         
	   
    def update(self):
       import pymysql
       conn=pymysql.connect(host='localhost',user='root',passwd='admin',db='school')
       cursor=conn.cursor()
       classs=self.cclass.get()
       admfees=self.eadmfees.get()
       name=self.ename.get()
       roll=self.eroll.get()
       total=self.etotal.get()
       tution=self.etution.get()
       annual=self.eannual.get()
       fine=self.efine.get()
       id=self.eadmno.get()
       receipt=self.ereceipt.get()
       total=int (admfees)+ int (annual) +int (tution)+ int (fine);
       try:
         cursor.execute('update tbfees set class="%s",name="%s",fine="%s",total="%s",annualfees="%s",rollno="%s",admissionfees="%s",id="%s",tutionfees="%s" where reciept="%s"' % \
                     (classs,name,fine,total,annual,roll,admfees,id,tution,receipt))
         conn.commit()
         print("data updated")
       except:
          conn.rollback()
          conn.close()
		  
    def delete(self):
      import pymysql;
      receipt=self.ereceipt.get()
      conn= pymysql.connect(host='localhost', user= 'root', passwd='admin', db= 'school');
      cur=conn.cursor();
      try:
        cur.execute( 'delete from tbfees where reciept="%s"' % \
                (receipt))
        conn.commit()	
        print("data deleted")
      except:
        conn.rollback() 
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

        top.geometry("600x450+292+189")
        top.title("New Toplevel")
        top.configure(background="#d9d9d9")

        self.Label1 = tk.Label(top)
        self.Label1.place(relx=0.317, rely=0.044, height=21, width=125)
        self.Label1.configure(background="#d9d9d9")
        self.Label1.configure(disabledforeground="#a3a3a3")
        self.Label1.configure(foreground="#000000")
        self.Label1.configure(text='''Fee  Update Collection''')

        self.Label2 = tk.Label(top)
        self.Label2.place(relx=0.15, rely=0.178, height=21, width=64)
        self.Label2.configure(background="#d9d9d9")
        self.Label2.configure(disabledforeground="#a3a3a3")
        self.Label2.configure(foreground="#000000")
        self.Label2.configure(text='''Receipt No''')

        self.ereceipt = tk.Entry(top)
        self.ereceipt.place(relx=0.367, rely=0.178,height=20, relwidth=0.273)
        self.ereceipt.configure(background="white")
        self.ereceipt.configure(disabledforeground="#a3a3a3")
        self.ereceipt.configure(font="TkFixedFont")
        self.ereceipt.configure(foreground="#000000")
        self.ereceipt.configure(insertbackground="black")

        self.bsearch = tk.Button(top)
        self.bsearch.place(relx=0.667, rely=0.178, height=24, width=77)
        self.bsearch.configure(activebackground="#ececec")
        self.bsearch.configure(activeforeground="#000000")
        self.bsearch.configure(background="#d9d9d9")
        self.bsearch.configure(disabledforeground="#a3a3a3")
        self.bsearch.configure(foreground="#000000")
        self.bsearch.configure(highlightbackground="#d9d9d9")
        self.bsearch.configure(highlightcolor="black")
        self.bsearch.configure(pady="0")
        self.bsearch.configure(text='''Search''')
        self.bsearch.configure(width=77)
        self.bsearch.configure(command=self.search)

        self.Label3 = tk.Label(top)
        self.Label3.place(relx=0.15, rely=0.267, height=21, width=109)
        self.Label3.configure(background="#d9d9d9")
        self.Label3.configure(disabledforeground="#a3a3a3")
        self.Label3.configure(foreground="#000000")
        self.Label3.configure(text='''Admission Number''')

        self.Label4 = tk.Label(top)
        self.Label4.place(relx=0.15, rely=0.333, height=21, width=34)
        self.Label4.configure(background="#d9d9d9")
        self.Label4.configure(disabledforeground="#a3a3a3")
        self.Label4.configure(foreground="#000000")
        self.Label4.configure(text='''Name''')

        self.Label5 = tk.Label(top)
        self.Label5.place(relx=0.15, rely=0.4, height=21, width=33)
        self.Label5.configure(background="#d9d9d9")
        self.Label5.configure(disabledforeground="#a3a3a3")
        self.Label5.configure(foreground="#000000")
        self.Label5.configure(text='''Class''')

        self.Label6 = tk.Label(top)
        self.Label6.place(relx=0.15, rely=0.533, height=21, width=84)
        self.Label6.configure(background="#d9d9d9")
        self.Label6.configure(disabledforeground="#a3a3a3")
        self.Label6.configure(foreground="#000000")
        self.Label6.configure(text='''Admission fees''')

        self.Label7 = tk.Label(top)
        self.Label7.place(relx=0.15, rely=0.6, height=21, width=70)
        self.Label7.configure(background="#d9d9d9")
        self.Label7.configure(disabledforeground="#a3a3a3")
        self.Label7.configure(foreground="#000000")
        self.Label7.configure(text='''Annual Fees''')

        self.Label8 = tk.Label(top)
        self.Label8.place(relx=0.15, rely=0.667, height=21, width=67)
        self.Label8.configure(background="#d9d9d9")
        self.Label8.configure(disabledforeground="#a3a3a3")
        self.Label8.configure(foreground="#000000")
        self.Label8.configure(text='''Tution Fees''')

        self.Label9 = tk.Label(top)
        self.Label9.place(relx=0.15, rely=0.733, height=21, width=28)
        self.Label9.configure(background="#d9d9d9")
        self.Label9.configure(disabledforeground="#a3a3a3")
        self.Label9.configure(foreground="#000000")
        self.Label9.configure(text='''Fine''')

        self.Label10 = tk.Label(top)
        self.Label10.place(relx=0.15, rely=0.8, height=21, width=33)
        self.Label10.configure(background="#d9d9d9")
        self.Label10.configure(disabledforeground="#a3a3a3")
        self.Label10.configure(foreground="#000000")
        self.Label10.configure(text='''Total''')
  	
	
        self.Label10 = tk.Label(top)
        self.Label10.place(relx=0.15, rely=0.467, height=21, width=40)
        self.Label10.configure(background="#d9d9d9")
        self.Label10.configure(disabledforeground="#a3a3a3")
        self.Label10.configure(foreground="#000000")
        self.Label10.configure(text='''Roll No.''')

        self.eadmno = tk.Entry(top)
        self.eadmno.place(relx=0.367, rely=0.267,height=20, relwidth=0.273)
        self.eadmno.configure(background="white")
        self.eadmno.configure(disabledforeground="#a3a3a3")
        self.eadmno.configure(font="TkFixedFont")
        self.eadmno.configure(foreground="#000000")
        self.eadmno.configure(insertbackground="black")

        self.ename = tk.Entry(top)
        self.ename.place(relx=0.367, rely=0.333,height=20, relwidth=0.273)
        self.ename.configure(background="white")
        self.ename.configure(disabledforeground="#a3a3a3")
        self.ename.configure(font="TkFixedFont")
        self.ename.configure(foreground="#000000")
        self.ename.configure(insertbackground="black")
		
        self.eroll = tk.Entry(top)
        self.eroll.place(relx=0.367, rely=0.467,height=20, relwidth=0.273)
        self.eroll.configure(background="white")
        self.eroll.configure(disabledforeground="#a3a3a3")
        self.eroll.configure(font="TkFixedFont")
        self.eroll.configure(foreground="#000000")
        self.eroll.configure(insertbackground="black")

        self.eadmfees = tk.Entry(top)
        self.eadmfees.place(relx=0.367, rely=0.533,height=20, relwidth=0.273)
        self.eadmfees.configure(background="white")
        self.eadmfees.configure(disabledforeground="#a3a3a3")
        self.eadmfees.configure(font="TkFixedFont")
        self.eadmfees.configure(foreground="#000000")
        self.eadmfees.configure(insertbackground="black")

        self.eannual = tk.Entry(top)
        self.eannual.place(relx=0.367, rely=0.6,height=20, relwidth=0.273)
        self.eannual.configure(background="white")
        self.eannual.configure(disabledforeground="#a3a3a3")
        self.eannual.configure(font="TkFixedFont")
        self.eannual.configure(foreground="#000000")
        self.eannual.configure(insertbackground="black")

        self.etution = tk.Entry(top)
        self.etution.place(relx=0.367, rely=0.667,height=20, relwidth=0.273)
        self.etution.configure(background="white")
        self.etution.configure(disabledforeground="#a3a3a3")
        self.etution.configure(font="TkFixedFont")
        self.etution.configure(foreground="#000000")
        self.etution.configure(insertbackground="black")

        self.efine = tk.Entry(top)
        self.efine.place(relx=0.367, rely=0.733,height=20, relwidth=0.273)
        self.efine.configure(background="white")
        self.efine.configure(disabledforeground="#a3a3a3")
        self.efine.configure(font="TkFixedFont")
        self.efine.configure(foreground="#000000")
        self.efine.configure(insertbackground="black")

        self.etotal = tk.Entry(top)
        self.etotal.place(relx=0.367, rely=0.8,height=20, relwidth=0.273)
        self.etotal.configure(background="white")
        self.etotal.configure(disabledforeground="#a3a3a3")
        self.etotal.configure(font="TkFixedFont")
        self.etotal.configure(foreground="#000000")
        self.etotal.configure(insertbackground="black")

        self.Button2 = tk.Button(top)
        self.Button2.place(relx=0.367, rely=0.889, height=24, width=44)
        self.Button2.configure(activebackground="#ececec")
        self.Button2.configure(activeforeground="#000000")
        self.Button2.configure(background="#d9d9d9")
        self.Button2.configure(disabledforeground="#a3a3a3")
        self.Button2.configure(foreground="#000000")
        self.Button2.configure(highlightbackground="#d9d9d9")
        self.Button2.configure(highlightcolor="black")
        self.Button2.configure(pady="0")
        self.Button2.configure(text='''Delete''')
        self.Button2.configure(command=self.delete)

        self.Button3 = tk.Button(top)
        self.Button3.place(relx=0.517, rely=0.889, height=24, width=49)
        self.Button3.configure(activebackground="#ececec")
        self.Button3.configure(activeforeground="#000000")
        self.Button3.configure(background="#d9d9d9")
        self.Button3.configure(disabledforeground="#a3a3a3")
        self.Button3.configure(foreground="#000000")
        self.Button3.configure(highlightbackground="#d9d9d9")
        self.Button3.configure(highlightcolor="black")
        self.Button3.configure(pady="0")
        self.Button3.configure(text='''Update''')
        self.Button3.configure(command=self.update)

        self.cclass = ttk.Combobox(top)
        self.cclass.place(relx=0.367, rely=0.4, relheight=0.047, relwidth=0.272)
        self.value_list = [1,2,3,4,5,6,7,8,9,10,]
        self.cclass.configure(values=self.value_list)
        self.cclass.configure(textvariable=Receipt_support.combobox)
        self.cclass.configure(width=163)
        self.cclass.configure(takefocus="")
		
        self.Label = tk.Label(top)
        self.Label.place(relx=0.783, rely=0.911, height=21, width=85)
        self.Label.configure(background="#d9d9d9")
        self.Label.configure(disabledforeground="#a3a3a3")
        self.Label.configure(foreground="#000000")
        self.Label.configure(text='''''')


if __name__ == '__main__':
    vp_start_gui()





