from cmath import sqrt
from svgpathtools import Path, Line, Arc, bbox2path, parse_path, wsvg
from datetime import date


class Generator:
    """
    CREATE a metamaterial SVG
    """

    def __init__(self, w1=12, h=18, w2=24, output="output"):
        """Stores parameters for the zigzag height and width and sets up the dictionary of shapes"""
        # an array of all the shapes that have been created
        self.shapes = {}
        # an array of shapes that have been filled. These should be
        # automatically updated when something is changed in self.shapes
        self.filled_shapes = {}

        # zigzag fill only
        # the width of the short zigzag
        self.short_zigzag_width = w1
        # the height of both zigzags is the same
        self.zigzag_height = h
        # the width of the long zigzag
        self.long_zigzag_width = w2

        # the default output directory
        self.output_dir = output

        # the default name for a shape
        self.default_shape_name = 'rect'
        # the default fill style
        self.default_fill_name = 'zigzag'

    def add_path(self, name, path):
        """ Adds a path to the dictionary. Path should be specified using a d string and is then parsed. """
        path = parse_path(path)
        self.shapes[name] = path

    def add_shape(self, name, shape):
        """ Adds a shape to the dictionary, specified as a d string"""
        self.shapes[name] = shape

    def set_default_shape_name(self, name):
        default_shape_name = name

    def set_default_fill_name(self, name):
        default_fill_name = name

    def add_rect(self, name, w, h):
        """ Adds a rectangle to the dictionary"""
        self.add_path(name, f"M 0 0 h {w} v {h} h {-w} Z")

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
        shape = self.shapes[name]
        self.shapes[name] = shape.scaled(fraction)

    def translate_shape(self, name, translate):
        """ Translate a shapy (or every path in a shape) by the complex coordinates given"""
        shape = self.shapes[name]
        self.shapes[name] = shape.translated(translate)

    def move_to_origin(self, name, topleft=True, middle=False):
        """Moves the shape to the orgin. If topleft, move the top left of the bounding box
           to the origin, otherwise move the middle to the orgiin."""
        bbx = self.shapes[name].bbox()
        translate = -bbx[1]-1j*bbx[2]

        if middle:
            xlength = bbx[1]-bbx[0]
            ylength = int(bbx[3]-bbx[2])
            translate = translate - xlength/2-1j*ylength/2

        self.translate_shape(name, middle)

    def fill_shape_zigzag(self, name, rotation, border):
        """Fills a shape with zigzags. You can choose to add a keep the shape outline or remove it
           and also say what rotation the auxetic material should have(where 0 rotation is vertical columns of zigzags)"""
        # find bounding box of shape to be filled
        shape_path = self.shapes[name]
        bbx = shape_path.bbox()
        # find longest side of bounding box
        xlength = bbx[1]-bbx[0]
        ylength = int(bbx[3]-bbx[2])
        diagonal = sqrt(xlength*xlength+ylength*ylength).real + 0.2
        print(diagonal)

        # diagonal/2 is the center of the rectangle;
        # bbx[0]+xlength/2 is the center of the shape
        # subtract to figure out how much to translate
        x_translate = (bbx[0]+xlength/2)-diagonal/2
        y_translate = 1j*((bbx[2]+ylength/2)-diagonal/2)

        # make a rectangle that is as large as the bounding box
        rect = self.make_zigzag_rectangle(self.short_zigzag_width, self.zigzag_height, self.long_zigzag_width,
                                          diagonal, diagonal)

        # rotate the rectangle and translate to the center of the shape
        rotated_rect = []
        for path in rect:
            if (rotation > 0):
                path = path.rotated(rotation, diagonal/2+1j*diagonal/2)
            # calculate the amount to translate in x as the upper left corner
            # of this path minus the upper left corner of the shape's bounding box
            path = path.translated(x_translate+y_translate)
            rotated_rect.append(path)

        # call crop to shape
        shape = self.crop_to_shape(shape_path, rotated_rect)

        # add border if needed
        if border:
            shape.append(shape_path)

        # save in filled_shapes
        self.filled_shapes[name] = shape

    def make_svg(self, names, filled_names, filename, units, svg_attributes=None, attributes=None):
        """Saves a list of shapes as an svg"""
        paths = []
        for name in names:
            path = self.shapes[name]
            # self.print(path.bbox(), name)
            paths += path

        for name in filled_names:
            path = self.filled_shapes[name]
            # self.print(path.bbox(), name)
            paths += path

        # if (len(attributes) is 0): attributes = np.full(len(names)+1, {})
        wsvg(paths=paths, filename=f"{self.output_dir}/{filename}_{self.short_zigzag_width}_{self.zigzag_height}_{self.long_zigzag_width}_{date.today().isoformat()}.svg",
             baseunit=units, svg_attributes=svg_attributes, attributes=attributes)

    def make_zigzag_column(self, zigzag_width, zigzag_height, total_length, start_x, start_y):
        """generates a column of zigzags(with given width and height) at a specific coordinate(start_x, start_y) of a certain length(total_length)"""
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
        """makes a rectangle out of small and large zigzag columns at 0, 0 that is the given size. basically generates the base auxetic material pattern"""
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

    def crop_to_shape(self, shape_path, rectangle_paths):
        """crops a given shape(path outline) to a filled rectangle."""
        cropped_paths = []

        xmin, xmax, ymin, ymax = shape_path.bbox()
        pt_outside_shape = (xmin-1) + (ymin-1)*1j
        shape_path = shape_path.translated(-0.1 - 0.1j)
        for path in rectangle_paths:
            pt = 0
            for (T1, seg1, t1), (T2, seg2, t2) in path.intersect(shape_path):
                if T1 < pt:
                    cropped_paths.append(
                        Line(path.point(pt), path.point(T1)))
                elif T1 == pt:
                    continue
                else:
                    cropped_paths.append(path.cropped(pt, T1))
                pt = T1
        final_version = []
        for path in cropped_paths:
            pt = path.point(0.5)
            crosses = Path(Line(pt, pt_outside_shape)).intersect(shape_path)
            if len(crosses) % 2:
                final_version.append(path)
            # for i in rectangle_paths:
            # final_version.append(i.rotated(rotate_amt, rotate_around_pt))
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
        # offset_path = Path(*connect_the_dots)
        offset_path = parse_path(offpath)
        return offset_path

    def fill_offset_curve(self, shape, offset_distance, steps=1000):
        """Takes in a Path object, `path`, and a distance,
        `offset_distance`, and outputs an piecewise-linear approximation
        of the 'parallel' offset curve."""
        path = self.shapes[shape]

        offset_path = self.offset_curve(path, offset_distance, steps)
        path.append(offset_path)
        # path = Path(*offset_path, *path)
        # path = Path(path.d())
        self.shapes[shape] = path

        return path
        # return offset_path

    def print(self, name, text):
        print(f"{text}: {self.shapes[name]}")
