from cmath import rect
from sqlite3 import enable_shared_cache
from turtle import circle
from svgpathtools import Path, Line, Arc, wsvg, bbox2path, parse_path, disvg


def make_zigzag_column(zigzag_width, zigzag_height, total_length, start_x, start_y):
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

def make_rectangle(short_zigzag_width, zigzag_height, long_zigzag_width, rectangle_width, rectangle_height):
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
    cropped_paths = []
    intersections = []
    xmin, xmax, ymin, ymax = shape_path.bbox()
    rotate_around_pt = 100 + 100j
    pt_outside_shape = (xmin-1) + (ymin-1)*1j
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


#circle = Path(Arc(start=10 + 120j, rotation=0, radius=100+100j,large_arc=1, sweep=180, end=210 + 120j), Arc(start=210 + 120j, rotation=180, radius=100+100j,large_arc=1,sweep=180, end=10 + 120j))
circle = Path(Arc(start=0 + 120j, rotation=0, radius=100+50j,large_arc=1, sweep=180, end=200 + 120j), Arc(start=200 + 120j, rotation=180, radius=100+50j,large_arc=1,sweep=180, end=0 + 120j))
rectangle = make_rectangle(8,18,24,90,124)
line = Line(0 + 0j, 300 + 200j)
zigzag = make_zigzag_column(15,40,200,0,0)
shaped_paths = crop_and_rotate_to_shape(circle, rectangle, True, 30)

r_handle_top = parse_path('M -0.1 -0.1 h 20.1 v 5.1 h -20.1 z')
r_handle_side = parse_path('M -0.1 5.1 h 5.1 v 20.1 h -5.1 z')
r_handle_bottom = parse_path('M -0.1 25.1 h 20.1 v 5.1 h -20.1 z')
bottle_panel = parse_path('M 20.1 -0.1 h 100.1 v 30.1 h -100.1 z')
l_handle_top = parse_path('M 120.1 -0.1 h 20.1 v 5.1 h -20.1 z')
l_handle_side = parse_path('M 140.1 5.1 h -5.1 v 20.1 h 5.1 z')
l_handle_bottom = parse_path('M 120.1 25.1 h 20.1 v 5.1 h -20.1 z')

bottle_carrier = crop_and_rotate_to_shape(r_handle_top, rectangle, True, 90) + crop_and_rotate_to_shape(r_handle_side, rectangle, True, 0) + crop_and_rotate_to_shape(r_handle_bottom, rectangle, True, 90) + crop_and_rotate_to_shape(bottle_panel, rectangle, True, 90) + crop_and_rotate_to_shape(l_handle_top, rectangle, True, 90) + crop_and_rotate_to_shape(l_handle_side, rectangle, True, 0) + crop_and_rotate_to_shape(l_handle_bottom, rectangle, True, 90)
#bottle_carrier, intersections = crop_and_rotate_to_shape(bottle_panel, rectangle, True, 90)
#wsvg(paths=[line], filename='./line_test.svg')
wsvg(paths=rectangle, filename='./rectangle_test.svg', baseunit="mm")
#wsvg(paths=[zigzag], filename='./zigzag_test.svg')
#wsvg(paths=bottle_carrier, filename='./shape_test.svg')
