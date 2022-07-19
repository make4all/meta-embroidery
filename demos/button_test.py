from metamaterial_generator import Generator

generator = Generator()
generator.add_path(
    'square', 'M 0 0 h 80 v 120 h -80 Z')
generator.scale_shape('square', 2.5)
generator.fill_shape_zigzag('square', 45, border=False)
generator.make_svg([], ['square'], 'square', 'mm')

# x 80 120
