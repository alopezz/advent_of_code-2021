// Global variables for visualization
let mapping;
let points = [];
let initialVelocity = {x: 0, y: 0};
let trajectoryIsValid = false;

const canvasSize = {x:800, y:800};

function setup() {
  createCanvas(canvasSize.x, canvasSize.y);
  mapping = targetAreaRect(canvasSize.x, canvasSize.y);
}

function draw() {
  background(220);
   
  fill(123);
  mapping = targetAreaRect(640, 640);

  const startingPos = mapping(0, 0);
  ellipse(startingPos.x, startingPos.y, 10, 10);

  noFill();
  // Draw curve
  push();
  beginShape();
  if (trajectoryIsValid) {
    stroke(0, 100, 0);
    strokeWeight(3);
  } else {
    stroke(240, 10, 10);
  }
  curveVertex(startingPos.x, startingPos.y);
  for (let point of points) {
    curveVertex(point.x, point.y);
  }
  endShape();
  pop();

  fill(250);
  // Draw individual points
  for (let point of points) {
    if (point.hitsTarget) {
      push();
      fill(255, 234, 0);
      translate(point.x, point.y);
      rotate(frameCount / -100.0);
      star(0, 0, 6, 15, 5);
      pop();
    } else {
      ellipse(point.x, point.y, 8, 8);
    }
  }

  // Display current initial velocity
  fill(0, 102, 153);
  textSize(20);
  text(`Initial velocity: x=${initialVelocity.x}, y=${initialVelocity.y}`, 10, 60);
}

function mousePressed() {
  updateHeightBasedOnMouse();
}

function mouseDragged() {
  updateHeightBasedOnMouse();
}

function updateHeightBasedOnMouse() {
  // We find an initial velocity vector that has this point as the max,
  // and update the points in the trajectory to plot it.
  const point = mapping.inverse(mouseX, mouseY);
  const height = Math.round(point.y);
  const x = Math.round(point.x);

  // All points should be pretty much determined.
  const vy0 = (-1 + Math.sqrt(1 + 8*height))/2;
  const step = stepForHeight(vy0, height);
  const vx0 = (x + step*(step - 1)/2)/step;

  initialVelocity.x = Math.round(vx0 * 100) / 100;
  initialVelocity.y = Math.round(vy0 * 100) / 100;

  trajectoryIsValid = Math.round(vy0) === vy0 && Math.round(vx0) === vx0;

  // Now we need the trajectory
  points = [];
  const target = getTargetArea();
  for (let step = 0; step < 50; step++) {
    const newPoint = calculatePosition({x: vx0, y: vy0}, step);
    const mappedPoint = mapping(newPoint.x, newPoint.y);

    if (target.has(newPoint)) {
      mappedPoint.hitsTarget = true;
    }
    points.push(mappedPoint);
  }
}

function getTargetArea() {
  const target = {};
  ['minX', 'maxX', 'minY', 'maxY'].forEach(name => {
    target[name] = parseInt(document.getElementById(name).value);
  });
  target.has = point => (
    point.x >= target.minX && point.x <= target.maxX &&
      point.y >= target.minY && point.y <= target.maxY
  );
  return target;
}

function targetAreaRect(canvasWidth, canvasHeight) {
  const {minX, maxX, minY, maxY} = getTargetArea();

  const mapping = (x, y) => {
    return {
      x: 40 + x/maxX*(canvasWidth - 80),
      y: 9/10*canvasHeight + y/minY*(1/4*canvasHeight),
    };
  };

  mapping.inverse = (x, y) => {
    return {
      x: (x - 40)*maxX/(canvasWidth - 80),
      y: (y - 9/10*canvasHeight)*minY/(1/4*canvasHeight),
    };
  };

  const minPos = mapping(minX, minY);
  const maxPos = mapping(maxX, maxY);
  
  rect(minPos.x, minPos.y, maxPos.x - minPos.x, maxPos.y - minPos.y);

  return mapping;
}

// https://p5js.org/examples/form-star.html
function star(x, y, radius1, radius2, npoints) {
  let angle = TWO_PI / npoints;
  let halfAngle = angle / 2.0;
  beginShape();
  for (let a = 0; a < TWO_PI; a += angle) {
    let sx = x + cos(a) * radius2;
    let sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a + halfAngle) * radius1;
    sy = y + sin(a + halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
