from cmath import rect
from sqlite3 import enable_shared_cache
from turtle import circle
from svgpathtools import Path, Line, Arc, bbox2path, parse_path, disvg, wsvg

class Generator:
    """
    CREATE a metamaterial SVG
    """
    
    def __init__(self, w1=12, h=18, w2=24):
        """Stores parameters for the zigzag height and width and sets up the dictionary of shapes"""
        self.shapes = {}
        self.short_zigzag_width = w1
        self.zigzag_height = h
        self.long_zigzag_width = w2

    def add_path(self, name, path):
        """ Adds a path to the dictionary """
        self.shapes[name] = parse_path(path)
        return self.shapes[name]

    def add_rect(self, name, w, h):
        """ Adds a rectangle to the dictionary """
        self.shapes[name] = self.make_zigzag_rectangle(self.short_zigzag_width,
                                                       self.zigzag_height,
                                                       self.long_zigzag_width, w, h)
        return self.shapes[name]

    def add_line(self, name, start, end):
        """ Adds a rectangle to the dictionary """
        self.shapes[name] = self.make_zigzag_rectangle(self.short_zigzag_width,
                                                       self.zigzag_height,
                                                       self.long_zigzag_width, w, h)
        return self.shapes[name]


    def add_shape(self, name, shape):
        """ Adds a shape to the dictionary """
        self.shapes[name] = shape
        return self.shapes[name]
        
    
    def add_circle(self, name, radius):
        """ Adds a circle to the dictionary"""
        circle = Path(Arc(start=0 + 120j, rotation=0, radius=radius,large_arc=1, sweep=180, end=200 + 120j), Arc(start=200 + 120j, rotation=180, radius=radius,large_arc=1,sweep=180, end=0 + 120j))
        
        self.shapes[name]  = circle;
        return circle;
        
    def scale_shape(self, name, fraction):
        """Scales an existing shapes to a fraction of its current size"""
        self.shapes[name] = self.shapes[name].scaled(fraction)

    def scale_shapes(self, names, fraction):
        """Scales an array of existing shapes to a fraction of their current size """
        for name in names: 
            scale_shape(shape, fraction)
        

    def move_shape(self, name, move_by):
        """ Moves a shapy by move_by """
        self.shapes[name].translated(move_by)

    def move_shapes(self, names, move_by):
        """ Moves an array of shapes by move_by """
        for name in names:
            move_shape(name);
        
    def move_paths(self, paths, move_by):
        """moves every path in a list by the complex coordinates given"""
        moved_paths = []
        for path in paths:
            moved_paths.append(self.shapes[path].translated(move_by))
        return moved_paths

    def fill_shape_zigzag(self, name, rotation, border):
        """Fills a shape with zigzags"""
        bbx = self.shape_bbx(name)
        longest_side = max(bbx[3]-bbx[1], bbx[2]-bbx[0])
        rect = self.make_zigzag_rectangle(self.short_zigzag_width, self.zigzag_height, self.long_zigzag_width,
                                          longest_side, longest_side)
        shape = self.shapes[name].translated(longest_side/2) 
        rotated_rect = self.crop_and_rotate_to_shape(shape, rect, border, rotation)
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
            box1 = sa.bbox()
            box2 = sb.bbox()
            bbx1 = min(box1[0],box2[0], bbx1)
            bbx2 = max(box1[2],box2[2], bbx2)
            bby1 = min(box1[1],box2[1], bby1) 
            bby2 = max(box1[3],box2[3], bby2) 
        return (bbx1, bby1, bbx2, bby2)
    
    def make_svg(self, names, filename, units):
        """Saves a list of shapes as an svg"""
        paths = []
        for name in names:
            paths += self.shapes[name]
        wsvg(paths=paths, filename=f"output/{filename}_{self.short_zigzag_width}_{self.zigzag_height}_{self.long_zigzag_width}.svg", baseunit=units)
    
    def make_zigzag_column(self, zigzag_width, zigzag_height, total_length, start_x, start_y):
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

    def make_zigzag_rectangle(self, short_zigzag_width, zigzag_height, long_zigzag_width, rectangle_width, rectangle_height):
        """makes a rectangle out of small and large zigzag columns at 0,0 that is the given size. basically generates the base auxetic material pattern"""
        num_repeats = int(rectangle_width/(long_zigzag_width - short_zigzag_width) + 1)
        rectangle_of_zigzags = []
        start_x = 0
        y = 0
        for i in range (num_repeats):
            rectangle_of_zigzags.append(self.make_zigzag_column(short_zigzag_width, zigzag_height, rectangle_height, start_x, y))
            start_x = start_x
            rectangle_of_zigzags.append(self.make_zigzag_column(long_zigzag_width, zigzag_height, rectangle_height, start_x, y))
            start_x = start_x+long_zigzag_width-short_zigzag_width
        return rectangle_of_zigzags

    def crop_and_rotate_to_shape(self, shape_path, rectangle_paths, shape_outline, rotate_amt):
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

    
