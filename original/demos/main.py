from mod_gen import Generator

from flask import Flask, render_template, request
from flask import Markup
from genem import *


app = Flask(__name__)

@app.route('/')
def welcome():


  generator = Generator()
  # list of printouts to keep
  generator.set_print_list(["fill_shape"])
  path1 = "M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z"
  path2 = "M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z"

  '''generator.add_path(
      'heart', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
  generator.add_path(
      'heart2', 'M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z')
  generator.scale_shape('heart', .4)
  generator.scale_shape('heart2', .8)
  generator.fill_shape(shape_name='heart', rotation=45, filltype="lozenge")
  generator.fill_shape(shape_name='heart2', rotation=45, filltype="lozenge", position=[0,100])

  generator.make_svg([], ['heart','heart2'], 'heart1', 'mm')'''

  return render_template('index.html', filename="", shape="Enter a shape", color="1")

@app.route('/renderSVG', methods=['POST'])
def renderSVG():
  path1 = request.form['dpath1']
  return render_template('index.html', path1=path1)

@app.route('/generateSVG', methods=['POST'])
def generateSVG():
  print("This was triggered")
  data = request.json['data']
  shape = data[0]
  color = data[1]
  path = data[2]
  path = lets_gen(shape)
  render_template('index.html', path1=path)
  pattern_choice = "zigzag"
  print(type(pattern_choice))
  rotation = int(0)

  print(pattern_choice)
  print(path)
  print(type(path))

  generator = Generator()
  generator.output_dir = "static/output"
  generator.add_path('heart', path)

  generator.scale_shape('heart', .4)
  generator.fill_shape(shape_name='heart', rotation=rotation, filltype=pattern_choice)

  filename = 'static/output/latest.svg'

  generator.make_svg([], ['heart'], filename, 'mm')

  print(filename)
  filepath = "latest"

  return render_template('index.html', filename=filepath, shape=shape, color=color, path=path)



@app.route('/pattern', methods=['POST'])
def pattern():

  data = request.json['data']
  pattern_choice = data[0]
  path = data[1]
  print(type(pattern_choice))
  rotation = int(0)

  print(pattern_choice)
  print(path)

  generator = Generator()
  generator.output_dir = "static/output"
  generator.add_path('heart', path)

  generator.scale_shape('heart', .4)
  generator.fill_shape(shape_name='heart', rotation=rotation, filltype=pattern_choice)

  filename = 'static/output/latest.svg'

  generator.make_svg([], ['heart'], filename, 'mm')

  print(filename)


  return render_template('index.html', filename=filename)

app.run(debug=True)

