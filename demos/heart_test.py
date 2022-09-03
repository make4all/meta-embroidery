from metamaterial_generator import Generator

generator = Generator()
generator.add_path(
    'heart', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
generator.scale_shape('heart', .4)
# generator.fill_shape_zigzag('heart', 45, border=True)
generator.fill_shape_lozenge('heart', 0, border=True)

generator.make_svg([], ['heart'], 'heart1', 'mm')
# generator.make_svg(['border'], [], 'border1', 'mm')
# generator.scale_shape('border', .3)
# generator.make_svg(['border'], [], 'border2', 'mm')
# generator.scale_shape('border', .5)
# generator.make_svg(['border'], [], 'border3', 'mm')

