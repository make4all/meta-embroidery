from PIL import ImageTk, Image

from metamaterial_generator import Generator
generator = Generator()

def shapeCommand(value):
    if value=="heart":
        print("heart is selected")
    elif value=="book":
        print("book is selected")
    elif value=="star":
        print("star is selected")
    elif value=="square":
        print("square is selected")

def infillCommand(value):
    if value=="zigzag":
        print("zigzag infill is selected")
    elif value=="lozenge":
        print("lozenge infill is selected")

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
    elif shape == "book":
        generator.add_path(
            'book', 'M 0 0 h 50 v 60 h -50 Z')
        generator.scale_shape('book', 2.5)
    elif shape == "square":
        generator.add_path(
            'square', 'M 0 0 h 80 v 120 h -80 Z')
        generator.scale_shape('square', 2.5)

    if infill == "zigzag":
        generator.fill_shape_zigzag(shape, rotationDeg, border=True)
    elif infill == "lozenge":
        generator.fill_shape_lozenge(shape, rotationDeg, border=True)

    generator.make_svg([], [shape], shape+str(1), 'mm')
    print("Woohoo! I got this far!")


#make the GUI
import tkinter
from tkinter import ttk

gui = tkinter.Tk(screenName='Meta Generator')
gui.geometry("800x600")

h=50
#setup the grid
f1 = tkinter.Frame(gui,width=100,height=h)
f2= tkinter.Frame(gui,width=100,height=h)
f3 = tkinter.Frame(gui,width=100,height=h)
f4 = tkinter.Frame(gui,width=100,height=h)
f5 = tkinter.Frame(gui,width=100,height=h)
f6 = tkinter.Frame(gui,width=100,height=h)
f7 = tkinter.Frame(gui,width=100,height=h)
f8 = tkinter.Frame(gui,width=100,height=h)
f9 = tkinter.Frame(gui,width=100,height=h)
f10 = tkinter.Frame(gui,width=100,height=h)
f11 = tkinter.Frame(gui,width=100,height=h)
f12 = tkinter.Frame(gui,width=100,height=h)
f13 = tkinter.Frame(gui,width=100,height=h)
f14 = tkinter.Frame(gui,width=100,height=h)
f15 = tkinter.Frame(gui,width=100,heigh=h)

f1.grid(row=0,column=0, sticky="nsew",columnspan=6)
f2.grid(row=1,column=0, sticky="nsew",columnspan=6)
f3.grid(row=2,column=0, sticky="nsew")
f4.grid(row=2,column=1, sticky="nsew")
f5.grid(row=3,column=0, sticky="nsew")
f6.grid(row=3,column=1, sticky="nsew")
f7.grid(row=4,column=0, sticky="nsew",columnspan=6)
f8.grid(row=5,column=0, sticky="nsew",columnspan=6)
f9.grid(row=6,column=0, sticky="nsew",columnspan=6)

f11.grid(row=2,column=2, sticky="nsew")
f12.grid(row=2,column=3, sticky="nsew")
f13.grid(row=2,column=4, sticky="nsew")
f14.grid(row=2,column=5, sticky="nsew")

f10.grid(row=7,column=0, sticky="nsew",columnspan=6)
f15.grid(row=8,column=0, sticky="nsew",columnspan=6)

gui.columnconfigure(0,weight=1)
gui.rowconfigure(2,weight=0)
gui.rowconfigure(3,weight=0)

#title
title = tkinter.Label(gui, text = "Welcome to the Meta Generator!", font=("Arial",25))
subtitle = tkinter.Label(gui, text = "Please select from the following options below and click GENERATE when ready.",font=("Arial",12))
title.grid(row=0, column=0,columnspan=6)
subtitle.grid(row=1, column=0,columnspan=6)
#
#
# #add a dropdown menu for shapes
shapesLabel = tkinter.Label(gui, text="Select the outline shape:", font=("Arial",10))
shapesLabel.grid(row=2,column=0, sticky=tkinter.E)
variableShape = tkinter.StringVar(gui)
variableShape.set("") #default value
shapesMenu = tkinter.OptionMenu(gui,variableShape,"heart","book","star","square",command=shapeCommand)
shapesMenu.grid(row=2,column=1, sticky=tkinter.W)

## dropdown menu for infill
infillLabel = tkinter.Label(gui, text="Select the infill shape:", font=("Arial",10))
infillLabel.grid(row=4,column=0, sticky=tkinter.E)
variableInfill = tkinter.StringVar(gui)
variableInfill.set("") #default value
infillMenu = tkinter.OptionMenu(gui,variableInfill,"zigzag","lozenge", command=infillCommand)
infillMenu.grid(row=4,column=1, sticky=tkinter.W)

## input field for rotation
rotationLabel = tkinter.Label(gui,text="Select the rotation of the infill (deg):", font=("Arial",10))
rotationLabel.grid(row=6,column=0, sticky=tkinter.E)
rotationEntry = tkinter.Entry(gui,bd=5)
rotationEntry.grid(row=6,column=1, sticky=tkinter.W)
#
#
# # Code to add widgets will go here...
#
generateButton = tkinter.Button(gui,text='GENERATE',font=("Arial",16),command=generateCommand)
generateButton.grid(row=8,column=0, columnspan=6)

# Create an object of tkinter ImageTk
#star image
img_star = (Image.open("interface/star.jpg"))
star_resized = img_star.resize((70,70), Image.ANTIALIAS)
star_new= ImageTk.PhotoImage(star_resized)
image = tkinter.Label(gui, image = star_new)
image.grid(row=2,column = 2)
starLabel = tkinter.Label(gui,text="Star", font=("Arial",10))
starLabel.grid(row=3,column=2, sticky=tkinter.N)

#heart image
img_heart = (Image.open("interface/heart.jpg"))
heart_resized = img_heart.resize((70,70), Image.ANTIALIAS)
heart_new= ImageTk.PhotoImage(heart_resized)
image = tkinter.Label(gui, image = heart_new)
image.grid(row=2,column = 3)
heartLabel = tkinter.Label(gui,text="Heart", font=("Arial",10))
heartLabel.grid(row=3,column=3, sticky=tkinter.N)

#square image
img_square = (Image.open("interface/square.jpg"))
square_resized = img_square.resize((70,70), Image.ANTIALIAS)
square_new= ImageTk.PhotoImage(square_resized)
image = tkinter.Label(gui, image = square_new)
image.grid(row=2,column = 4)
squareLabel = tkinter.Label(gui,text="Square", font=("Arial",10))
squareLabel.grid(row=3,column=4, sticky=tkinter.N)

#book image
img_book = (Image.open("interface/book.jpg"))
book_resized = img_book.resize((70,90), Image.ANTIALIAS)
book_new= ImageTk.PhotoImage(book_resized)
image = tkinter.Label(gui, image = book_new)
image.grid(row=2,column = 5)
bookLabel = tkinter.Label(gui,text="Book", font=("Arial",10))
bookLabel.grid(row=3,column=5, sticky=tkinter.N)

#zigzag image
img_zigzag = (Image.open("interface/zigzag.jpg"))
zigzag_resized = img_zigzag.resize((70,70), Image.ANTIALIAS)
zigzag_new= ImageTk.PhotoImage(zigzag_resized)
image = tkinter.Label(gui, image = zigzag_new)
image.grid(row=4,column = 3)
zigzagLabel = tkinter.Label(gui,text="Zigzag", font=("Arial",10))
zigzagLabel.grid(row=5,column=3, sticky=tkinter.N)

#lozenge image
img_lozenge = (Image.open("interface/lozenge.jpg"))
lozenge_resized = img_lozenge.resize((70,70), Image.ANTIALIAS)
lozenge_new= ImageTk.PhotoImage(lozenge_resized)
image = tkinter.Label(gui, image = lozenge_new)
image.grid(row=4,column = 4)
lozengeLabel = tkinter.Label(gui,text="Lozenge", font=("Arial",10))
lozengeLabel.grid(row=5,column=4, sticky=tkinter.N)

# gui.configure(bg="#40E0D0")

# generateButton.pack()
gui.mainloop()
