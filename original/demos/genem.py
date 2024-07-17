import requests
from svgpathtools import svg2paths, wsvg
from svgelements import *
import sys
from PIL import Image
from potrace import Bitmap, POTRACE_TURNPOLICY_MINORITY





def generate_image(filename: str):
    response = requests.post(
    f"https://api.stability.ai/v2beta/stable-image/generate/core",
    headers={
        "authorization": f"Bearer sk-UsGcJftNroc0QCw9YOIj0kuWUxT5GgYQcWEyMx9PnG2RohGk",
        "accept": "image/*"
    },
    files={
        "none": ''
    },
    data={
        "prompt": "A solid black silhouette of a " +filename +" (black:0.5) (white:0.5)",
        "negative_prompt": "No details, no complexity, no dimension",
        "output_format": "png",
    },
    )
    if response.status_code == 200:
        with open("./"+filename+".png", 'wb') as file:
            file.write(response.content)
    else:
        raise Exception(str(response.json()))



# PNG to svg
def file_to_svg(filename: str):
    try:

        image = Image.open(f"{filename}.png")
    except IOError:
        print("Image (%s) could not be loaded." % filename)
        return
    bm = Bitmap(image, blacklevel=0.5)
    # bm.invert()
    plist = bm.trace(
        turdsize=2,
        turnpolicy=POTRACE_TURNPOLICY_MINORITY,
        alphamax=1,
        opticurve=False,
        opttolerance=0.2,
    )
    with open(f"{filename}.svg", "w") as fp:
        fp.write(
            f'''<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{image.width}" height="{image.height}" viewBox="0 0 {image.width} {image.height}">''')
        parts = []
        for curve in plist:
            fs = curve.start_point
            parts.append(f"M{fs.x},{fs.y}")
            for segment in curve.segments:
                if segment.is_corner:
                    a = segment.c
                    b = segment.end_point
                    parts.append(f"L{a.x},{a.y}L{b.x},{b.y}")
                else:
                    a = segment.c1
                    b = segment.c2
                    c = segment.end_point
                    parts.append(f"C{a.x},{a.y} {b.x},{b.y} {c.x},{c.y}")
            parts.append("z")
        fp.write(f'<path stroke="none" fill="black" fill-rule="evenodd" d="{"".join(parts)}"/>')
        fp.write("</svg>")
        return("".join(parts))



def lets_gen(shape: str):
    # Convert
    filename = shape
    generate_image(filename)
    d_path = file_to_svg(filename)

    return d_path



