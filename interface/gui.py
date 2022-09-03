from metamaterial_generator import Generator
generator = Generator()

def shapeCommand(value):
    if value=="heart":
        print("heart is selected")
    elif value=="book":
        print("book is selected")
    elif value=="star":
        print("star is selected")
    elif value=="handle":
        print("handle is selected")
    elif value=="button":
        print("button is selected")

def infillCommand(value):
    if value=="zigzag":
        print("zigzag infill is selected")



def generateCommand():
    shape = variableShape.get()
    infill = variableInfill.get()
    rotationDeg = int(rotationEntry.get())

    if shape == "heart":
        generator.add_path(
            'heart', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
        generator.scale_shape('heart', .4)
    elif shape == "star":
        generator.add_path(
            'star', 'M 24 0 l 6 17 h 18 l -14 11 l 5 17 l -15 -10 l -15 10 l 5 -17 l -14 -11 h 18 Z')
        generator.scale_shape('star', 2.5)
    if infill == "zigzag":
        generator.fill_shape_zigzag(shape, rotationDeg, border=True)

    generator.make_svg([], [shape], shape+str(1), 'mm')
    print("Woohoo! I got this far!")


#make the GUI
import tkinter
from tkinter import ttk

gui = tkinter.Tk(screenName='Meta Generator')
gui.geometry("800x400")

h=50
#setup the grid
f1 = tkinter.Frame(gui,width=100,height=h)
f2= tkinter.Frame(gui,width=100,height=h)
f3 = tkinter.Frame(gui,width=650,height=h)
f4 = tkinter.Frame(gui,width=350,height=h)
f5 = tkinter.Frame(gui,width=650,height=h)
f6 = tkinter.Frame(gui,width=350,height=h)
f7 = tkinter.Frame(gui,width=100,height=h)
f8 = tkinter.Frame(gui,width=100,height=h)
f9 = tkinter.Frame(gui,width=100,height=h)
f10 = tkinter.Frame(gui,width=100,height=h)

f1.grid(row=0,column=0, sticky="nsew",columnspan=2)
f2.grid(row=1,column=0, sticky="nsew",columnspan=2)
f3.grid(row=2,column=0, sticky="nsew")
f4.grid(row=2,column=1, sticky="nsew")
f5.grid(row=3,column=0, sticky="nsew")
f6.grid(row=3,column=1, sticky="nsew")
f7.grid(row=4,column=0, sticky="nsew",columnspan=2)
f8.grid(row=5,column=0, sticky="nsew",columnspan=2)
f9.grid(row=6,column=0, sticky="nsew",columnspan=2)
f10.grid(row=7,column=0, sticky="nsew",columnspan=2)

gui.columnconfigure(0,weight=1)
gui.rowconfigure(2,weight=0)
gui.rowconfigure(3,weight=0)

#title
title = tkinter.Label(gui, text = "Welcome to the Meta Generator!", font=("Arial",25))
subtitle = tkinter.Label(gui, text = "Please select from the following options below and click GENERATE when ready.",font=("Arial",12))
title.grid(row=0, column=0,columnspan=2)
subtitle.grid(row=1, column=0,columnspan=2)
#
#
# #add a dropdown menu for shapes
shapesLabel = tkinter.Label(gui, text="Select the outline shape:", font=("Arial",10))
shapesLabel.grid(row=2,column=0, sticky=tkinter.E)
variableShape = tkinter.StringVar(gui)
variableShape.set("") #default value
shapesMenu = tkinter.OptionMenu(gui,variableShape,"heart","book","star","handle","button",command=shapeCommand)
shapesMenu.grid(row=2,column=1, sticky=tkinter.W)

## dropdown menu for infill
infillLabel = tkinter.Label(gui, text="Select the infill shape:", font=("Arial",10))
infillLabel.grid(row=3,column=0, sticky=tkinter.E)
variableInfill = tkinter.StringVar(gui)
variableInfill.set("") #default value
infillMenu = tkinter.OptionMenu(gui,variableInfill,"zigzag","hourglass", command=infillCommand)
infillMenu.grid(row=3,column=1, sticky=tkinter.W)

## input field for rotation
rotationLabel = tkinter.Label(gui,text="Select the rotation of the infill (deg):", font=("Arial",10))
rotationLabel.grid(row=4,column=0, sticky=tkinter.E)
rotationEntry = tkinter.Entry(gui,bd=5)
rotationEntry.grid(row=4,column=1, sticky=tkinter.W)
#
#
# # Code to add widgets will go here...
#
generateButton = tkinter.Button(gui,text='GENERATE',font=("Arial",16),command=generateCommand)
generateButton.grid(row=6,column=0, columnspan=2)

# generateButton.pack()
gui.mainloop()