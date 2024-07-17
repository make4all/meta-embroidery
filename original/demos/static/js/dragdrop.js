// Function to add a shape to the workspace
function addShape(shape) {
  const workspace = document.getElementById("workspace");
  const path = getShapePathInfo(shape);
  console.log("Path: " + path);

  workspace.innerHTML += `
    <svg id="${shape}" class="drag-drop-svg" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <path d="${path}" />
      <g transform="scale(0.25)"></g>
    </svg>`;
}

// Function to update color input value
function updateColorInput(val) {
  document.getElementById('colorInput').value = val; 
}

// Function to update path input value
function updatePathInput(val) {
  document.getElementById('pathInput').value = val; 
}

// Function to import shape from GAI
function importShapeFromGAI() {
  const prompt = document.getElementById("shapeDesired").value;
  const color = document.getElementById('colorInput').value;
  const path = document.getElementById('pathInput').value; 

  console.log(prompt, color, path);

  const data = { prompt, color, path };
  const parentElement = document.getElementById("workspace");

  fetch('/generateSVG', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
  .then(response => response.text())
  .then(result => {
    console.log(result);
    download_btn.classList.remove("disabled");
    download_btn.classList.add("active");
    return fetch('../static/output/latest.svg');
  })
  .then(response => response.text())
  .then(data => {
    console.log(data);
    parentElement.innerHTML = data;
  })
  .catch(error => console.error('Error:', error));
}

// Function to get shape path information
function getShapePathInfo(shape) {
  const shapePaths = {
    star: "M 24 0 l 6 17 h 18 l -14 11 l 5 17 l -15 -10 l -15 10 l 5 -17 l -14 -11 h 18 Z",
    heart: "M 0 200 v -200 h 200 a 100 100 90 0 1 0 200 a 100 100 90 0 1 -200 0 Z",
    square: "M 0 0 h 80 v 120 h -80 Z"
  };

  return shapePaths[shape] || '';
}

// Drag move listener
function dragMoveListener(event) {
  const target = event.target;
  const x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx;
  const y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy;

  target.style.transform = `translate(${x}px, ${y}px)`;
  target.setAttribute('data-x', x);
  target.setAttribute('data-y', y);
}

// Function to return patterned SVG
function returnPatternedSVG(pattern, path, dropzoneElement) {
  const download_btn = document.getElementById("download-btn");
  const data = { pattern, path };
  console.log(data);

  fetch('/pattern', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
  .then(response => response.text())
  .then(result => {
    console.log(result);
    download_btn.classList.remove("disabled");
    download_btn.classList.add("active");
    return fetch('../static/output/latest.svg');
  })
  .then(response => response.text())
  .then(data => {
    console.log(data);
    dropzoneElement.outerHTML = data;
  })
  .catch(error => console.error('Error:', error));
}

// Setup dropzone and draggable interactions
function setupInteractions() {
  interact('.dropzone').dropzone({
    accept: '.drag-drop-svg',
    overlap: 0.05,
    ondropactivate(event) {
      event.target.classList.add('drop-active');
    },
    ondragenter(event) {
      const draggableElement = event.relatedTarget;
      const dropzoneElement = event.target;
      dropzoneElement.classList.add('drop-target');
      draggableElement.classList.add('can-drop');
    },
    ondragleave(event) {
      event.target.classList.remove('drop-target');
      event.relatedTarget.classList.remove('can-drop');
    },
    ondrop(event) {
      event.relatedTarget.classList.add('materialed');
    },
    ondropdeactivate(event) {
      event.target.classList.remove('drop-active');
      event.target.classList.remove('drop-target');
      event.relatedTarget.classList.add('svg-dropzone');
    }
  });

  interact('.svg-dropzone').dropzone({
    accept: '.material',
    overlap: 0.05,
    ondropactivate(event) {
      event.target.classList.add('drop-active');
    },
    ondragenter(event) {
      const draggableElement = event.relatedTarget;
      const dropzoneElement = event.target;
      dropzoneElement.classList.add('drop-target');
      draggableElement.classList.add('can-drop');
    },
    ondragleave(event) {
      event.target.classList.remove('drop-target');
      event.relatedTarget.classList.remove('can-drop');
    },
    ondrop(event) {
      const draggableElement = event.relatedTarget;
      const dropzoneElement = event.target;
      const pattern = draggableElement.id;
      const path = getShapePathInfo(dropzoneElement.id);
      console.log("PATH: " + path);
      returnPatternedSVG(pattern, path, dropzoneElement);
    },
    ondropdeactivate(event) {
      event.target.classList.remove('drop-active');
      event.target.classList.remove('drop-target');
    }
  });

  interact('.drag-drop').draggable({
    inertia: true,
    autoScroll: true,
    listeners: { move: dragMoveListener }
  });

  const position = { x: 0, y: 0 };

  interact('.drag-drop-svg').draggable({
    listeners: {
      start(event) {
        console.log(event.type, event.target);
      },
      move(event) {
        position.x += event.dx;
        position.y += event.dy;
        event.target.style.transform = `translate(${position.x}px, ${position.y}px)`;
      }
    }
  }).resizable({
    edges: { left: true, right: true, bottom: true, top: true },
    listeners: {
      move(event) {
        const target = event.target;
        let x = (parseFloat(target.getAttribute('data-x')) || 0);
        let y = (parseFloat(target.getAttribute('data-y')) || 0);
        target.style.width = event.rect.width + 'px';
        target.style.height = event.rect.height + 'px';
        x += event.deltaRect.left;
        y += event.deltaRect.top;
        target.style.transform = `translate(${x}px, ${y}px)`;
        target.setAttribute('data-x', x);
        target.setAttribute('data-y', y);
      }
    },
    modifiers: [
      interact.modifiers.restrictSize({
        min: { width: 100, height: 50 }
      })
    ],
    inertia: true
  });
}

window.dragMoveListener = dragMoveListener;
setupInteractions();
