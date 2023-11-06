from cmath import sqrt
from svgpathtools import Path, Line, Arc, bbox2path, parse_path, wsvg
from datetime import date


class Generator:
    """
    CREATE a metamaterial SVG
    """

    def __init__(self, output="output"):
        """Stores parameters for the zigzag height and width and sets up the dictionary of shapes"""
        # an array of all the shapes that have been created
        self.shapes = {}
        # an array of shapes that have been filled. These should be
        # automatically updated when something is changed in self.shapes
        self.filled_shapes = {}

        # zigzag fill only
        # the width of the short zigzag
        self.short_zigzag_width = 12
        # the height of both zigzags is the same
        self.zigzag_height = 18
        # the width of the long zigzag
        self.long_zigzag_width = 24

        # lozenge grid infill only
        self.loz_long_side = 42.5/5
        self.loz_short_side = 29/5 
        self.loz_gap = 13.5/5 
        self.loz_spacing = self.loz_long_side + self.loz_short_side + self.loz_gap

        # the default output directory
        self.output_dir = output

        # the default name for a shape
        self.default_shape_name = 'rect'
        # the default fill style
        self.default_fill_name = 'zigzag'

        self.print_list = ["fill_shape_lozenge"]

    def fill_shape(self, shape_name="default", rotation=0, border=True, filltype="default", position=[0,0]):
        """ Files a shape with the type described in filltype"""

        name = self.default_shape_name if (
            shape_name == "default") else shape_name
        my_fill = self.default_fill_name if (
            filltype == "default") else filltype

        # find bounding box of shape to be filled
        shape_path = self.shapes[name]
        bbx = shape_path.bbox()
        # find longest side of bounding box
        xlength = bbx[1] - bbx[0]
        ylength = int(bbx[3] - bbx[2])
        diagonal = sqrt(xlength * xlength + ylength * ylength).real + 0.2
        self.print("fill_shape", diagonal)

        # diagonal/2 is the center of the rectangle;
        # bbx[0]+xlength/2 is the center of the shape
        # subtract to figure out how much to translate
        x_translate = (bbx[0] + xlength / 2) - diagonal / 2
        y_translate = 1j * ((bbx[2] + ylength / 2) - diagonal / 2)

        if (my_fill == 'zigzag'):
            # fill a rectangle that is as large as the bounding box
            rect = self.make_zigzag_rectangle(diagonal, diagonal)
        else:
            # fill a rectangle that is as large as the bounding box
            rect = self.make_loz_rectangle(diagonal, diagonal)

        rotated_rect = []
        for path in rect:
            if (rotation > 0):
                path = path.rotated(
                    rotation, diagonal / 2 + 1j * diagonal / 2)
            # calculate the amount to translate in x as the upper left corner
            # of this path minus the upper left corner of the shape's bounding box
            path = path.translated(x_translate + y_translate)
            rotated_rect.append(path)

        self.print("fill_shape","cropping ")
        # call crop to shape
        cropped_shape = self.crop_to_shape(shape_path, rotated_rect)
        
        self.print("fill_shape","adding border")
        # add border if needed
        if border:
            cropped_shape.append(shape_path)

        self.print("fill_shape", "translating shape")

        translated_shape = []
        for path in cropped_shape:
            path = path.translated(position[0]+position[1]*1j)
            translated_shape.append(path)
        
        # save in filled_shapes
        self.filled_shapes[name] = translated_shape

################### ZIGZAG HELPER CODE #####################
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

    def make_zigzag_rectangle(self, rectangle_width, rectangle_height):
        """makes a rectangle out of small and large zigzag columns at 0, 0 that is the given size. basically generates the base auxetic material pattern"""

        num_repeats = int(
            rectangle_width/(self.long_zigzag_width - self.short_zigzag_width) + 1)
        rectangle_of_zigzags = []
        start_x = 0
        y = 0
        for i in range(num_repeats):
            rectangle_of_zigzags.append(self.make_zigzag_column(
                self.short_zigzag_width, self.zigzag_height, rectangle_height, start_x, y))
            start_x = start_x
            rectangle_of_zigzags.append(self.make_zigzag_column(
                self.long_zigzag_width, self.zigzag_height, rectangle_height, start_x, y))
            start_x = start_x+self.long_zigzag_width-self.short_zigzag_width
        return rectangle_of_zigzags

    ################### LOZENGE HELPER CODE #####################
        
    def make_loz_line(self, total_length, start_x, start_y, direction="row", flip=False):
        """ Makes one of four possible lines: a row, a flipped row, a column, or a flipped column. 
            direction spefies row or column. """
        path = Path()

        # Calculates number of repeats within a line
        num_repeats = int(total_length/(2*self.loz_long_side)+1) 
        self.print("make_loz_line",f"creating {direction} at ({start_x}, {start_y}) that is {flip} with {num_repeats} repeated per line of length {total_length}")
        
        # unflipped row start
        unflipped_row_start = [start_x, start_y]  # start at start_x, start_y
        # flipped row start
        flipped_row_start = [start_x, start_y+self.loz_short_side]
        # unflipped col start
        unflipped_col_start = [start_x-1.5, start_y+7] # where did these numbers come from
        # flipped col start
        flipped_col_start = [start_x-1.5, start_y+7] # where did these numbers come from

        # when to apply changes to x, and when to apply them to y
        row_order = [[1,0],[0,1],[1,0],[0,1],[1,0]]
        col_order = [[0,1],[1,0],[0,1],[1,0],[0,1]]
        
        increase_first = [self.loz_long_side/2,
                          self.loz_short_side,  # increase 
                          self.loz_long_side,
                          -self.loz_short_side, # decrease
                          self.loz_long_side/2]
        decrease_first = [self.loz_long_side/2,
                          -self.loz_short_side, # decrease
                          self.loz_long_side,
                          self.loz_short_side,  # increase
                          self.loz_long_side/2]

        if (direction == "row"): 
            cursor = flipped_row_start if flip else unflipped_row_start
            changes = decrease_first if flip else increase_first
            order = row_order
        else:
            cursor = flipped_col_start if flip  else unflipped_col_start
            changes = increase_first if flip  else decrease_first
            order = col_order
            
        # turn that information into a list of x and y changes
        # in the format [[x1, y1],[x2, y2],[x3, y3]...]
        change_list = list(map(lambda change, item: 
                               list(map(lambda val: change*val, item)),
                               changes,
                               order))
        
        self.print("make_loz_line",change_list)

        # repeatedly execute the changes until num_repeats
        for i in range(num_repeats):
            for change in change_list:
                self.print("make_loz_line", cursor)
                path.append(Line(cursor[0]+cursor[1]*1j,
                                 (cursor[0]+change[0])+(cursor[1]+change[1])*1j))
                cursor[0] = cursor[0]+change[0]
                cursor[1] = cursor[1]+change[1]
        return path
                
    def make_loz_rectangle(self, rectangle_width, rectangle_height):
        """ Makes a rectangle of width, height and fills it with a lozenge grid. loz_orizontal_len is the length of a single lozenge on the horizental lines. loz_short_side. loz_spacing is the distance between things that are the same  """

        # Calculate number of repeats across the whole rectangle
        num_repeats_y = int(2+rectangle_width/self.loz_spacing)
        num_repeats_x = int(2+rectangle_height/self.loz_spacing)

        self.print("make_loz_rectangle",f"making rectangle with width {rectangle_width}, height {rectangle_height} with {num_repeats_y} horizontal and {num_repeats_x} vertical lines ")
        
        
        return_rect = []
        start_x = 0  # increments by
        start_y = 0
        start_y_flipped = 0 + self.loz_short_side + self.loz_gap
        start_x_column = 0
        start_y_column = 0
        start_x_column_flipped = 0 + self.loz_gap

        for i in range(num_repeats_y):
                self.print("make_loz_rectangle",f"{i} rows")
                return_rect.append(self.make_loz_line(rectangle_width, start_x, start_y))
                return_rect.append(self.make_loz_line(rectangle_width, start_x, start_y_flipped, flip=True))
                start_y = start_y + self.loz_spacing
                start_y_flipped = start_y_flipped + self.loz_spacing
        for i in range(num_repeats_x):
                self.print("make_loz_rectangle",f"{i} columns")
                return_rect.append(self.make_loz_line(rectangle_height, start_x_column, start_y_column,
                                                      direction="column"))
                return_rect.append(self.make_loz_line(rectangle_height, start_x_column_flipped, start_y_column,
                                                      direction="column", flip=True))
                start_x_column = start_x_column + self.loz_spacing
                start_x_column_flipped = start_x_column_flipped + self.loz_spacing
                start_x = start_x+self.loz_spacing

        return return_rect

    ############################# OTHER HELPERS #############################

    def crop_to_shape(self, shape_path, rectangle_paths):
        """crops a given shape(path outline) to a filled rectangle."""
        cropped_paths = []

        xmin, xmax, ymin, ymax = shape_path.bbox()
        pt_outside_shape = (xmin-1) + (ymin-1)*1j
        shape_path = shape_path.translated(-0.1 - 0.1j)
        for path in rectangle_paths:
            pt = 0
            for (T1, seg1, t1), T2 in path.intersect(shape_path):
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
        result = print(f"{name}: {text}") if name in self.print_list else False
        result = print(f"{text}: {self.shapes[name]}") if name in self.shapes else False

    def make_svg(self, names, filled_names, filename, units='mm', svg_attributes=None, attributes=None):
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

        filename=f"{self.output_dir}/{filename}_zig{self.short_zigzag_width}.{self.zigzag_height}.{self.long_zigzag_width}_loz{self.loz_long_side}.{self.loz_short_side}.{self.loz_gap}_{date.today().isoformat()}.svg"
        raw_o

        # if (len(attributes) is 0): attributes = np.full(len(names)+1, {})
        wsvg(paths=paths, filename=filename,
             baseunit=units, svg_attributes=svg_attributes, attributes=attributes)

        return paths

        

################### Setters and Getters ####################

    def set_default_shape_name(self, name):
        self.default_shape_name = name

    def set_default_fill_name(self, name):
        self.default_fill_name = name

    def set_print_list(self, list):
        self.print_list = list

################### Shape making functions (standard graphics stuff) ####################

    def add_path(self, name, path):
        """ Adds a path to the dictionary. Path should be specified using a d string and is then parsed. """
        path = parse_path(path)
        self.shapes[name] = path

    def add_shape(self, name, shape):
        """ Adds a shape to the dictionary, specified as a d string"""
        self.shapes[name] = shape

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

    def move_new_location(self, name, xnew, ynew, middle=True):
        bbx = self.shapes[name].bbox()

        translate = -bbx[1]-1j*bbx[2]

        if middle:
            translate = translate - xnew - 1j*ynew

        self.translate_shape(name, middle)
