
function addShape (shape) {
  const workspace = document.getElementById("workspace");
  path = getShapePathInfo(shape);
  console.log("Path: " + path);

  workspace.innerHTML+=` <svg id="`+shape+`" class="drag-drop-svg" version="1.1"
     xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <path d="`+ path +`" />
  <g transform="scale(0.25)">
  </g>
</svg>`

}

function getShapePathInfo (shape) {

      //GROSS PUT THIS SHT INTO AN ARRAY OR OBJECT PLEASE
      if (shape == 'star') {
      let path ="M 24 0 l 6 17 h 18 l -14 11 l 5 17 l -15 -10 l -15 10 l 5 -17 l -14 -11 h 18 Z";
      return path;
       }

    else if (shape == 'heart') {
      let path="M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z";
      return path;
    }

    else if (shape == 'square') {
      let path ="M 0 0 h 80 v 120 h -80 Z";
      return path;
    }

}


function dragMoveListener (event) {
  var target = event.target
  // keep the dragged position in the data-x/data-y attributes
  var x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
  var y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy

  // translate the element
  target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'

  // update the posiion attributes
  target.setAttribute('data-x', x)
  target.setAttribute('data-y', y)
}


// Return SVG with proper in-fill
function returnPatternedSVG (pattern, path, dropzoneElement) {
  const download_btn = document.getElementById("download-btn");
  const data = [pattern, path];
  console.log(data);
  if (pattern == "zigzag") {
    fetch('/pattern', {
    method: 'POST',
    headers: {
    'Content-Type': 'application/json'
    },
    body: JSON.stringify({data: data})
    })
    .then(response => response.text())
    .then(result => {
      console.log(result);
      download_btn.classList.remove("disabled");
      download_btn.classList.add("active");
    fetch('../static/output/latest.svg')
    .then(response => response.text())
    .then((data) => {
    console.log(data)
    dropzoneElement.outerHTML = data;
    })
    })
    .catch(error => {
      console.error('Error:', error);
      });
    }

  else if (pattern == "lozenge") {
    fetch('/pattern', {
    method: 'POST',
    headers: {
    'Content-Type': 'application/json'
    },
    body: JSON.stringify({data: data})
    })
    .then(response => response.text())
    .then(result => {
      console.log(result);
      download_btn.classList.remove("disabled");
      download_btn.classList.add("active");
      fetch('../static/output/latest.svg')
    .then(response => response.text())
    .then((data) => {
    console.log(data)
    dropzoneElement.outerHTML = data;
    })
    })
    .catch(error => {
      console.error('Error:', error);
      });
  }


  else {
    return 
  }
}

// this function is used later in the resizing and gesture demos
window.dragMoveListener = dragMoveListener




/* The dragging code for '.draggable' from the demo above
 * applies to this demo as well so it doesn't have to be repeated. */

// enable draggables to be dropped into this
interact('.dropzone').dropzone({
  // only accept elements matching this CSS selector
  accept: '.drag-drop-svg',
  // Require a 75% element overlap for a drop to be possible
  overlap: 0.05,

  // listen for drop related events:

  ondropactivate: function (event) {
    // add active dropzone feedback
    event.target.classList.add('drop-active')
  },
  ondragenter: function (event) {
    var draggableElement = event.relatedTarget
    var dropzoneElement = event.target

    // feedback the possibility of a drop
    dropzoneElement.classList.add('drop-target')
    draggableElement.classList.add('can-drop')
    //draggableElement.textContent = 'Dragged in'
  },
  ondragleave: function (event) {
    // remove the drop feedback style
    event.target.classList.remove('drop-target')
    event.relatedTarget.classList.remove('can-drop')
  },
  ondrop: function (event) {
    //event.relatedTarget.textContent = 'Dropped'
    event.relatedTarget.classList.add('materialed')
      
  },
  ondropdeactivate: function (event) {
    // remove active dropzone feedback
    event.target.classList.remove('drop-active')
    event.target.classList.remove('drop-target')
    event.relatedTarget.classList.add('svg-dropzone')
  }
})

interact('.svg-dropzone').dropzone({
  // only accept elements matching this CSS selector
  accept: '.material',
  // Require a 75% element overlap for a drop to be possible
  overlap: 0.05,

  // listen for drop related events:

  ondropactivate: function (event) {
    // add active dropzone feedback
    event.target.classList.add('drop-active')
  },
  ondragenter: function (event) {
    var draggableElement = event.relatedTarget
    var dropzoneElement = event.target

    // feedback the possibility of a drop
    dropzoneElement.classList.add('drop-target')
    draggableElement.classList.add('can-drop')
    console.log("Dragged in")
    //draggableElement.textContent = 'Dragged in'
  },
  ondragleave: function (event) {
    // remove the drop feedback style
    event.target.classList.remove('drop-target')
    event.relatedTarget.classList.remove('can-drop')
  },
  ondrop: function (event) {
    var draggableElement = event.relatedTarget
    var dropzoneElement = event.target
    console.log("Dragged in")

    console.log(draggableElement.id);
    console.log(dropzoneElement.id);

    pattern = draggableElement.id;
    path = getShapePathInfo(dropzoneElement.id);


    console.log("PATH: " + path);
    returnPatternedSVG(pattern, path, dropzoneElement)

  },
  ondropdeactivate: function (event) {
    // remove active dropzone feedback
    event.target.classList.remove('drop-active')
    event.target.classList.remove('drop-target')
  }
})



interact('.drag-drop')
  .draggable({
    inertia: true,
    /*modifiers: [
      interact.modifiers.restrictRect({
        restriction: 'parent',
        endOnly: true
      })
    ],*/
    autoScroll: true,
    // dragMoveListener from the dragging demo above
    listeners: { move: dragMoveListener }
  })

const position = { x: 0, y: 0 }

interact('.drag-drop-svg').draggable({
  listeners: {
    start (event) {
      console.log(event.type, event.target)
    },
    move (event) {
      position.x += event.dx
      position.y += event.dy

      event.target.style.transform =
        `translate(${position.x}px, ${position.y}px)`
    },
  }
}).resizable({
    // resize from all edges and corners
    edges: { left: true, right: true, bottom: true, top: true },

    listeners: {
      move (event) {
        var target = event.target
        var x = (parseFloat(target.getAttribute('data-x')) || 0)
        var y = (parseFloat(target.getAttribute('data-y')) || 0)

        // update the element's style
        target.style.width = event.rect.width + 'px'
        target.style.height = event.rect.height + 'px'

        // translate when resizing from top or left edges
        x += event.deltaRect.left
        y += event.deltaRect.top

        target.style.transform = 'translate(' + x + 'px,' + y + 'px)'

        target.setAttribute('data-x', x)
        target.setAttribute('data-y', y)
      }
    },
    modifiers: [
      // keep the edges inside the parent
     /** interact.modifiers.restrictEdges({
        outer: 'parent'
      }),**/

      // minimum size
      interact.modifiers.restrictSize({
        min: { width: 100, height: 50 }
      })
    ],

    inertia: true
  })