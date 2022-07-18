from metamaterial_generator import Generator

generator = Generator()
generator.add_path(
    'square', 'M 24 24 l 50 h 50 l -50 Z')
generator.scale_shape('button', 2.5)
# generator.fill_shape_zigzag('button', 45, border=True)
generator.make_svg([], ['square'], 'button', 'mm')
