from metamaterial_generator import Generator

generator = Generator()
generator.add_path(
    'star', 'M 24 0 l 6 17 h 18 l -14 11 l 5 17 l -15 -10 l -15 10 l 5 -17 l -14 -11 h 18 Z')
generator.scale_shape('star', 2.5)
generator.fill_shape_zigzag('star', 45, border=True)
generator.make_svg([], ['star'], 'star', 'mm')
