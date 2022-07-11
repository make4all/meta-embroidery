from metamaterial_generator import Generator
generator = Generator()
generator.add_rect('rect',90,124)
generator.make_svg(['rect'], 'rect', 'mm')
