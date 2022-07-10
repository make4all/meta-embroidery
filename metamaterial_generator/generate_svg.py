from cmath import rect
from sqlite3 import enable_shared_cache
from turtle import circle
from svgpathtools import Path, Line, Arc, wsvg, bbox2path, parse_path, disvg


def make_zigzag_column(zigzag_width, zigzag_height, total_length, start_x, start_y):
    """generates a column of zigzags(with given width and height) at a specific coordinate (start_x, start_y) of a certain length(total_length)"""
    path = Path()
    x = start_x
    y = start_y
    x_end = start_x + zigzag_width
    num_repeats = int(total_length/zigzag_height +1)
    for i in range (num_repeats):
        path.append(Line(x + y*1j, x_end+(y+zigzag_height/2)*1j))
        path.append(Line(x_end + (y+zigzag_height/2)*1j, x + (y+zigzag_height)*1j))
        y = y+zigzag_height
    return path

def make_zigzag_rectangle(short_zigzag_width, zigzag_height, long_zigzag_width, rectangle_width, rectangle_height):
    """makes a rectangle out of small and large zigzag columns at 0,0 that is the given size. basically generates the base auxetic material pattern"""
    num_repeats = int(rectangle_width/(long_zigzag_width - short_zigzag_width) + 1)
    rectangle_of_zigzags = []
    start_x = 0
    y = 0
    for i in range (num_repeats):
        rectangle_of_zigzags.append(make_zigzag_column(short_zigzag_width, zigzag_height, rectangle_height, start_x, y))
        start_x = start_x
        rectangle_of_zigzags.append(make_zigzag_column(long_zigzag_width, zigzag_height, rectangle_height, start_x, y))
        start_x = start_x+long_zigzag_width-short_zigzag_width
    return rectangle_of_zigzags

def crop_and_rotate_to_shape(shape_path, rectangle_paths, shape_outline, rotate_amt):
    """fills a given shape (path outline) with auxetic material. You can choose to add a keep the shape outline or remove it and also say what rotation the auxetic material should have (where 0 rotation is vertical columns of zigzags)"""
    cropped_paths = []
    intersections = []
    xmin, xmax, ymin, ymax = shape_path.bbox()
    rotate_around_pt = 100 + 100j
    pt_outside_shape = (xmin-1) + (ymin-1)*1j
    shape_path = shape_path.translated(-0.1 -0.1j)
    for path in rectangle_paths:
        rotated_path = path.rotated(rotate_amt, rotate_around_pt)
        pt = 0
        for (T1, seg1, t1), (T2, seg2, t2) in rotated_path.intersect(shape_path):
            intersections.append(rotated_path.point(T1))
            if T1 < pt:
                cropped_paths.append(Line(rotated_path.point(pt), rotated_path.point(T1)))
            elif T1 == pt:
                continue
            else:
                cropped_paths.append(rotated_path.cropped(pt, T1))
            pt = T1
    final_version = []
    points = []
    points.append(pt_outside_shape)
    for path in cropped_paths:
        pt = path.point(0.5)
        crosses = Path(Line(pt, pt_outside_shape)).intersect(shape_path)
        if len(crosses) % 2:
            final_version.append(path)
    if shape_outline:
        final_version.append(shape_path)
        #for i in rectangle_paths:
            #final_version.append(i.rotated(rotate_amt, rotate_around_pt))
    return final_version

def move_paths(paths, move_by):
    """moves every path in a list by the complex coordinates given"""
    moved_paths = []
    for path in paths:
        moved_paths.append(path.translated(move_by))
    return moved_paths

#circle = Path(Arc(start=10 + 120j, rotation=0, radius=100+100j,large_arc=1, sweep=180, end=210 + 120j), Arc(start=210 + 120j, rotation=180, radius=100+100j,large_arc=1,sweep=180, end=10 + 120j))
circle = Path(Arc(start=0 + 120j, rotation=0, radius=100+50j,large_arc=1, sweep=180, end=200 + 120j), Arc(start=200 + 120j, rotation=180, radius=100+50j,large_arc=1,sweep=180, end=0 + 120j))
rectangle = make_zigzag_rectangle(12,18,24,200,200)
line = Line(0 + 0j, 300 + 200j)
zigzag = make_zigzag_column(15,40,200,0,0)
shaped_paths = crop_and_rotate_to_shape(circle, rectangle, True, 30)

sleeve_path = parse_path('M 0 0, h 175, v 60, h -175, z')
handle_path = parse_path('M 0 0, h 90, v 30, h -90, z')
cup_sleeve = crop_and_rotate_to_shape(sleeve_path, rectangle, False, 90)
cup_handle = move_paths(crop_and_rotate_to_shape(handle_path, rectangle, True, 0), 0+70j)
cup_holder = cup_sleeve+cup_handle

rotated_cup_holder = []
for path in cup_holder:
    rotated_cup_holder.append(path.rotated(90, 100+100j))

star_path = parse_path('M 24 0 l 6 17 h 18 l -14 11 l 5 17 l -15 -10 l -15 10 l 5 -17 l -14 -11 h 18 Z')
star = crop_and_rotate_to_shape(star_path.scaled(2.5), rectangle, True, 30) #has but for some reason one thing not cropped properly--need to explore more

heart_path = parse_path('M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
heart = crop_and_rotate_to_shape(heart_path.scaled(.4).translated(50+50j), rectangle, True, 45)
#bottle_carrier, intersections = crop_and_rotate_to_shape(bottle_panel, rectangle, True, 90)
#wsvg(paths=[line], filename='../output/line_test.svg')
wsvg(paths=heart, filename='../output/heart_test.svg', baseunit="mm")
#wsvg(paths=[zigzag], filename='../output/zigzag_test.svg')
#wsvg(paths=bottle_carrier, filename='../output/shape_test.svg')
