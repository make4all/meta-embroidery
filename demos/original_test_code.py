from metamaterial_generator import Generator
from cmath import rect
from sqlite3 import enable_shared_cache
from turtle import circle
from svgpathtools import Path, Line, Arc, bbox2path, parse_path, disvg, wsvg
from datetime import date

generator = Generator()

#circle = Path(Arc(start=10 + 120j, rotation=0, radius=100+100j,large_arc=1, sweep=180, end=210 + 120j), Arc(start=210 + 120j, rotation=180, radius=100+100j,large_arc=1,sweep=180, end=10 + 120j))
circle = Path(Arc(start=0 + 120j, rotation=0, radius=100+50j,large_arc=1, sweep=180, end=200 + 120j), Arc(start=200 + 120j, rotation=180, radius=100+50j,large_arc=1,sweep=180, end=0 + 120j))
rectangle = generator.make_zigzag_rectangle(12,18,24,200,200)
line = Line(0 + 0j, 300 + 200j)
zigzag = generator.make_zigzag_column(15,40,200,0,0)
shaped_paths = generator.crop_and_rotate_to_shape(circle, rectangle, True, 30)

sleeve_path = parse_path('M 0 0, h 175, v 60, h -175, z')
handle_path = parse_path('M 0 0, h 90, v 30, h -90, z')
cup_sleeve = generator.crop_and_rotate_to_shape(sleeve_path, rectangle, False, 90)
#cup_handle = generator.move_paths(generator.crop_and_rotate_to_shape(handle_path, rectangle, True, 0+0j), 0+70j)
#cup_holder = cup_sleeve+cup_handle

#rotated_cup_holder = []
#for path in cup_holder:
#    rotated_cup_holder.append(path.rotated(90, 100+100j))

star_path = parse_path('M 24 0 l 6 17 h 18 l -14 11 l 5 17 l -15 -10 l -15 10 l 5 -17 l -14 -11 h 18 Z')
star = generator.crop_and_rotate_to_shape(star_path.scaled(2.5), rectangle, True, 30) #has but for some reason one thing not cropped properly--need to explore more

heart_path = parse_path('M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
heart = generator.crop_and_rotate_to_shape(heart_path.scaled(.4).translated(50+50j), rectangle, True, 45)
#bottle_carrier, intersections = crop_and_rotate_to_shape(bottle_panel, rectangle, True, 90)
#wsvg(paths=[line], filename='../output/line_test.svg')
wsvg(paths=heart, filename='../output/heart_test.svg', baseunit="mm")
#wsvg(paths=[zigzag], filename='../output/zigzag_test.svg')
#wsvg(paths=bottle_carrier, filename='../output/shape_test.svg')
