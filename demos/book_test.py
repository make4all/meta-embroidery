from metamaterial_generator import Generator

generator = Generator()
generator.add_path(
    'book', 'M 0 0 h 50 v 60 h -50 Z')
generator.scale_shape('book', 2.5)
#generator.fill_shape_zigzag('book', 0, border=True)
#generator.fill_shape_lozenge('book', 0, border=True)
generator.fill_shape(shape_name='book', rotation=45, filltype="lozenge")

generator.make_svg([], ['book'], 'book', 'mm')

# x 80 120
