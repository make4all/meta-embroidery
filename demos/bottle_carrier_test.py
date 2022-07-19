from metamaterial_generator import Generator

generator = Generator()

############# HANDLE ####################################
# handle is now output as a separate file. Could consider
# replacing this with a simple rect...
generator.add_path('handle', 'M 0 0, h 90, v 30, h -90, z')
# generator.translate('handle',0+70j)
generator.fill_shape_zigzag('handle', 0, border=2)
generator.make_svg([], ['handle'], 'handle', 'mm')


circle = generator.add_circle('circle', 100+50j)
generator.fill_shape_zigzag('circle', 30, border=2)

########### SLEEVE ######################################
generator.add_path('sleeve', 'M 0 0, h 175, v 60, h -175, z')
generator.fill_shape_zigzag('sleeve', 90, border=False)

# for path in cup_holder:
#    rotated_cup_holder.append(path.rotated(90, 100+100j))
# )
# bottle_carrier, intersections = generator.crop_and_rotate_to_shape(bottle_panel, rectangle12_24, True,
generator.make_svg([], ['sleeve'], 'sleeve', 'mm')
