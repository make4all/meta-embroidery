from metamaterial_generator import Generator

generator = Generator()
# list of printouts to keep
generator.set_print_list(["fill_shape"])

generator.add_path(
    'heart', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
generator.add_path(
    'heart2', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
generator.scale_shape('heart', .4)
generator.scale_shape('heart2', .8)
generator.fill_shape(shape_name='heart', rotation=45, filltype="lozenge")
generator.fill_shape(shape_name='heart2', rotation=45, filltype="lozenge", position=[0,100])

generator.make_svg([], ['heart','heart2'], 'heart1', 'mm')
# generator.make_svg(['border'], [], 'border1', 'mm')
# generator.scale_shape('border', .3)
# generator.make_svg(['border'], [], 'border2', 'mm')
# generator.scale_shape('border', .5)
# generator.make_svg(['border'], [], 'border3', 'mm')
