from cmath import rect
from sqlite3 import enable_shared_cache
from turtle import circle
from svgpathtools import Path, Line, Arc, bbox2path, parse_path, disvg, wsvg
from datetime import date
import numpy as np


class Generator:
    """
    CREATE a metamaterial SVG
    """

    def __init__(self, w1=12, h=18, w2=24, output="output"):
        """Stores parameters for the zigzag height and width and sets up the dictionary of shapes"""
        self.shapes = {}
        self.short_zigzag_width = w1
        self.zigzag_height = h
        self.long_zigzag_width = w2
        self.output_dir = output

    def add_path(self, name, path):
        """ Adds a path to the dictionary. Path should be specified using a d string and is then parsed. """
        self.shapes[name] = parse_path(path)

    def add_shape(self, name, shape):
        """ Adds a shape to the dictionary, specified as a d string"""
        self.shapes[name] = shape

    def add_rect(self, name, w, h):
        """ Adds a rectangle to the dictionary"""
        self.shapes[name] = self.make_zigzag_rectangle(self.short_zigzag_width,
                                                       self.zigzag_height,
                                                       self.long_zigzag_width, w, h)

    def add_line(self, name, start, end):
        """ Adds a line to the dictionary """
        self.shapes[name] = Line(start, end)

    def add_line(self, name, x1, y1, x2, y2):
        """ Adds a line to the dictionary """
        self.shapes[name] = Line(x1+1j*y1, x2+1j*y2)

    def add_circle(self, name, radius):
        """ Adds a circle to the dictionary"""
        circle = Path(Arc(start=0 + 120j, rotation=0, radius=radius, large_arc=1, sweep=180, end=200 + 120j),
                      Arc(start=200 + 120j, rotation=180, radius=radius, large_arc=1, sweep=180, end=0 + 120j))
        # need to tie the start and end to the radius
        self.shapes[name] = circle
        return circle

    def scale_shape(self, name, fraction):
        """Scales an existing shape (or every path in a shape) to a fraction of its current size"""
        # add ability to scale differently in X and Y and to choose scale origin
        shapes = self.shapes[name]
        if (not isinstance(shapes, list)):
            shapes = [shapes]
        scaled_shapes = []
        for shape in shapes:
            scaled_shapes += shape.scaled(fraction)
        self.shapes[name] = scaled_shapes

    def move_shape(self, name, move_by):
        """ Moves a shapy (or every path in a shape) by the complex coordinates given"""
        shapes = self.shapes[name]
        if (not isinstance(shapes, list)):
            shapes = [shapes]
        moved_shapes = []
        for shape in shapes:
            moved_shapes += shape.translated(move_by)
        self.shapes[name] = moved_shapes

    def fill_shape_zigzag(self, name, rotation, border):
        """Fills a shape with zigzags"""
        # find bounding box of shape to be filled
        bbx = self.shape_bbx(name)
        # find longest side of bounding box
        longest_side = max(bbx[3]-bbx[1], bbx[2]-bbx[0])
        # make a rectangle that is as large as the bounding box
        rect = self.make_zigzag_rectangle(self.short_zigzag_width, self.zigzag_height, self.long_zigzag_width,
                                          longest_side, longest_side)
        # move the shape to the origin (broken?)
        shape = self.shapes[name].translated(longest_side/2)
        # crop and rotate
        rotated_rect = self.crop_and_rotate_to_shape(
            shape, rect, border, rotation)
        # save
        self.shapes[name] = rotated_rect
        return rotated_rect

    def shape_bbx(self, name):
        """Calculates the bounding box for a shape """
        shape = self.shapes[name]

        bbx1 = 0
        bby1 = 0
        bbx2 = 0
        bby2 = 0

        for i, (sa, sb) in enumerate(shape.joints()):
            # loop through all the paths in shape
            # find the bounding box of each path
            box1 = sa.bbox()
            box2 = sb.bbox()
            # save the smallest top left position
            bbx1 = min(box1[0], box2[0], bbx1)
            bbx2 = max(box1[2], box2[2], bbx2)
            # and the largest bottom right position
            bby1 = min(box1[1], box2[1], bby1)
            bby2 = max(box1[3], box2[3], bby2)
        return (bbx1, bby1, bbx2, bby2)

    def make_svg(self, names, filename, units, svg_attributes=None, attributes=None):
        """Saves a list of shapes as an svg"""
        paths = []
        for name in names:
            paths += self.shapes[name]

        #if (len(attributes) is 0): attributes = np.full(len(names)+1, {})
        wsvg(paths=paths, filename=f"{self.output_dir}/{filename}_{self.short_zigzag_width}_{self.zigzag_height}_{self.long_zigzag_width}_{date.today().isoformat()}.svg",
             baseunit=units, svg_attributes=svg_attributes, attributes=attributes)

    def make_zigzag_column(self, zigzag_width, zigzag_height, total_length, start_x, start_y):
        """generates a column of zigzags(with given width and height) at a specific coordinate (start_x, start_y) of a certain length(total_length)"""
        path = Path()
        x = start_x
        y = start_y
        x_end = start_x + zigzag_width
        num_repeats = int(total_length/zigzag_height + 1)
        for i in range(num_repeats):
            path.append(Line(x + y*1j, x_end+(y+zigzag_height/2)*1j))
            path.append(Line(x_end + (y+zigzag_height/2)
                        * 1j, x + (y+zigzag_height)*1j))
            y = y+zigzag_height
        return path

    def make_zigzag_rectangle(self, short_zigzag_width, zigzag_height, long_zigzag_width, rectangle_width, rectangle_height):
        """makes a rectangle out of small and large zigzag columns at 0,0 that is the given size. basically generates the base auxetic material pattern"""
        num_repeats = int(
            rectangle_width/(long_zigzag_width - short_zigzag_width) + 1)
        rectangle_of_zigzags = []
        start_x = 0
        y = 0
        for i in range(num_repeats):
            rectangle_of_zigzags.append(self.make_zigzag_column(
                short_zigzag_width, zigzag_height, rectangle_height, start_x, y))
            start_x = start_x
            rectangle_of_zigzags.append(self.make_zigzag_column(
                long_zigzag_width, zigzag_height, rectangle_height, start_x, y))
            start_x = start_x+long_zigzag_width-short_zigzag_width
        return rectangle_of_zigzags

    def crop_and_rotate_to_shape(self, shape_path, rectangle_paths, border, rotate_amt):
        """fills a given shape (path outline) with auxetic material. You can choose to add a keep the shape outline or remove it and also say what rotation the auxetic material should have (where 0 rotation is vertical columns of zigzags)"""
        cropped_paths = []
        intersections = []
        xmin, xmax, ymin, ymax = shape_path.bbox()
        rotate_around_pt = 100 + 100j
        pt_outside_shape = (xmin-1) + (ymin-1)*1j
        shape_path = shape_path.translated(-0.1 - 0.1j)
        for path in rectangle_paths:
            rotated_path = path.rotated(rotate_amt, rotate_around_pt)
            pt = 0
            for (T1, seg1, t1), (T2, seg2, t2) in rotated_path.intersect(shape_path):
                intersections.append(rotated_path.point(T1))
                if T1 < pt:
                    cropped_paths.append(
                        Line(rotated_path.point(pt), rotated_path.point(T1)))
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
        if border:
            final_version.append(shape_path)
            final_version.append(self.offset_curve(
                shape_path, border, steps=1000))

            # for i in rectangle_paths:
            #final_version.append(i.rotated(rotate_amt, rotate_around_pt))
        return final_version

    def offset_curve(self, path, offset_distance, steps=1000):
        """Takes in a Path object, `path`, and a distance,
        `offset_distance`, and outputs an piecewise-linear approximation 
        of the 'parallel' offset curve."""
        offpath = f"M "
        nls = []
        for seg in path:
            ct = 1
            for k in range(steps):
                t = k / steps
                offset_vector = offset_distance * seg.normal(t)
                offpath += f" {seg.point(t).real}, {seg.point(t).imag}"
                nl = Line(seg.point(t), seg.point(t) + offset_vector)
                nls.append(nl)
        connect_the_dots = [Line(nls[k].end, nls[k+1].end)
                            for k in range(len(nls)-1)]
        if path.isclosed():
            connect_the_dots.append(Line(nls[-1].end, nls[0].end))
            offpath += " Z"
        #offset_path = Path(*connect_the_dots)
        offset_path = parse_path(offpath)
        return offset_path

    def fill_offset_curve(self, shape, offset_distance, steps=1000):
        """Takes in a Path object, `path`, and a distance,
        `offset_distance`, and outputs an piecewise-linear approximation 
        of the 'parallel' offset curve."""
        path = self.shapes[shape]

        offset_path = self.offset_curve(path, offset_distance, steps)
        path.append(offset_path)
        # print(offset_path)
        #path = Path(*offset_path, *path)
        #path = Path(path.d())
        self.shapes[shape] = path

        return path
        # return offset_path
