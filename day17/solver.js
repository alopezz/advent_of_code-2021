
// An iterator that yields the initial velocities for which the target area is hit.
function* searchIterator(target, startingYVel = 15000) {
  for (let yVel = startingYVel; yVel >= target.minY; yVel--) {
    // Get integer step values for which we'd fall within the target area's y range
    const minStep = Math.ceil(stepForHeight(yVel, target.maxY));
    const maxStep = Math.floor(stepForHeight(yVel, target.minY));
    const candidateSteps = Array.from(Array(maxStep - minStep + 1).keys()).map(n => n + minStep);

    // If we don't have any, that means we'd never touch the target for this initial y velocity
    if (candidateSteps.length === 0) {
      continue;
    }
    for (let xVel = 0; xVel <= target.maxX; xVel++) {
      // Here we only need to check the X coordinate for the previously calculated candidate steps
      // and yield the initial velocity if we hit the target.
      const xCandidates = candidateSteps.map(step => calculatePosition({y: yVel, x: xVel}, step).x);
      if (xCandidates.some(x => x <= target.maxX && x >= target.minX)) {
        yield {y: yVel, x: xVel};
      }
    }
  }
}

// Solves part 1
function searchHighest(target, startingYVel = 15000) {
  for (let {y: yVel} of searchIterator(target, startingYVel)) {
    return maxDistance(yVel);
  }
  // Just in case we don't find any
  return NaN;
}

// Solves part 2
function searchAll(target, startingYVel = 15000) {
  let validStarts = 0;
  for (let {y: yVel} of searchIterator(target, startingYVel)) {
    validStarts++;
  }
  return validStarts;
}

function calculatePosition(initialVelocity, steps) {
  const offset = seriesSum(steps - 1);
  const x = steps <= initialVelocity.x ? steps * initialVelocity.x - offset : maxDistance(initialVelocity.x);
  return {
    x,
    y: steps * initialVelocity.y - offset,
  };
}

// Calculates the max distance reached based on a given initial velocity,
// assuming an acceleration of -1. Valid for both X and Y in this problem.
function maxDistance(initial) {
  return (initial**2 + initial) / 2;
}

// Calculates the sum of 1..x
function seriesSum(x) {
  return x * (x + 1) / 2;
}

// Returns the latest step on which we reach the given height, given the initial velocity
function stepForHeight(initialYVel, y) {
  // This is a matter of solving a quadratic equation:
  // s^2 + (-2*Vi - 1)*s + 2*y = 0
  // Which is based on the calculation for y (see `calculatePosition`)
  // This has logically two solutions, but we only care about the hightest one.
  b = (-2*initialYVel - 1);
  return (-b + Math.sqrt(b**2 - 8*y)) / 2;
}


function testSuite() {

  console.log('Run tests...');

  const tests = [];

  test('seriesSum', ({assertEquals}) => {
    assertEquals(10, seriesSum(4));
    assertEquals(15, seriesSum(5));
  });

  test('stepForHeight', ({assertEquals}) => {
    assertEquals(7, stepForHeight(2, -7));
  });

  test('calculatePosition, x', ({assertEquals}) => {
    const initialSpeed = {x: 7, y: 2};
    assertEquals(7, calculatePosition(initialSpeed, 1).x);
    assertEquals(28, calculatePosition(initialSpeed, 7).x);
    // Test that we never go back in x
    assertEquals(28, calculatePosition(initialSpeed, 9).x);
  });

  test('calculatePosition, y', ({assertEquals}) => {
    const initialSpeed = {x: 7, y: 2};
    assertEquals(2, calculatePosition(initialSpeed, 1).y);
    assertEquals(-7, calculatePosition(initialSpeed, 7).y);
  });

  test('searchHighest, example', ({assertEquals}) => {
    const target = {minX: 20, maxX: 30, minY: -10, maxY: -5};
    assertEquals(45, searchHighest(target));
  });

  test('searchHighest, puzzle input', ({assertEquals}) => {
    const target = {minX: 88, maxX: 125, minY: -157, maxY: -103};
    assertEquals(12246, searchHighest(target));
  });

  test('searchAll, example', ({assertEquals}) => {
    const target = {minX: 20, maxX: 30, minY: -10, maxY: -5};
    assertEquals(112, searchAll(target));
  });

  test('searchAll, puzzle input', ({assertEquals}) => {
    const target = {minX: 88, maxX: 125, minY: -157, maxY: -103};
    assertEquals(3528, searchAll(target));
  });

  // Testing 'framework'
  function test(name, func) {
    function assert(value) {
      if (!value) {
        throw new Error(`${name} failed: Expected ${value} to be truthy`);
      }
    }
    function assertEquals(expected, actual) {
      if (expected !== actual) {
        throw new Error(`${name} failed: Expected ${actual} to equal ${expected}`);
      }
    }
    func({assert, assertEquals});
    console.log(`${name} passed`);
  }

  console.log('All tests passed!');
}

// Run the tests!
testSuite();
