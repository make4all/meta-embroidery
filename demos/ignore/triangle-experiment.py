from metamaterial_generator import Generator

generator = Generator()
generator.add_path(
    'triangle_experiment', 'M 0 0 h 90 v 120 h -90 Z')
# generator.scale_shape('triangle_experiment', 2.5)
generator.fill_shape_zigzag('triangle_experiment', 0, border=False)
generator.make_svg([], ['triangle_experiment'], 'triangle_experiment')

# x 80 120
