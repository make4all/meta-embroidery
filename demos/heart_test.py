from metamaterial_generator import Generator

generator = Generator()
generator.add_path(
    'heart', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
heart = generator.scale_shape('heart', .4)
heart = generator.fill_shape_zigzag('heart', 45, border=True)
border = generator.add_path(
    'border', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
# border = generator.fill_offset_curve('border', 5)
# print(border)
# print(f"border: {border.d()}")
# generator.make_svg(['heart','border'], 'heart', 'mm', attributes=[{},{'fill-rule':'even-odd'}])
generator.make_svg([], ['heart'], 'heart', 'mm')
