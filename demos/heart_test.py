from metamaterial_generator import Generator

generator = Generator()
generator.add_path('heart', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
heart = generator.scale_shape('heart', .4)
heart = generator.fill_shape_zigzag('heart', 45, border=True)
generator.make_svg(['heart'], 'heart', 'mm')

