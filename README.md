# Metamaterial Embroidery

This library is used to generate metamaterial embroidered lace objects.

## Installation

### Set up your virtual environment
```python3 -m venv venv```
```source venv/bin/activate```

### Install necessary packages
```pip3 install -r requirements.txt```

### Setup our modified version of svgpathtools
```cd svgpathtools```
```python3 setup.py bdist_wheel```
```pip3 install dist/svgpathtools-1.5.1-py2.py3-none-any.whl```
```pip3 uninstall svgpathtools```

### Run the demos
You can run one at a time
```python3 demos/heart_test.py```

Or you can run them all at once:
```python3 setup.py pytest```

## Documentation
Output files will show up in output.py and be labeled with the width and height of the zigzags and the current date.

Your original code can be found in: original_test.py
