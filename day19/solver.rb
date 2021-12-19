require 'set'

module Day19
  class Rotation
    # A manually derived set of 24 orientations.
    ROTATIONS = [
      # Starting with X
      'x,y,z',
      'x,-z,y',
      'x,-y,-z',
      'x,z,-y',
      # Starting with -X
      '-x,y,-z',
      '-x,z,y',
      '-x,-y,z',
      '-x,-z,-y',
      # Starting with Y
      'y,-x,z',
      'y,-z,-x',
      'y,x,-z',
      'y,z,x',
      # Starting with -Y
      '-y,x,z',
      '-y,-z,x',
      '-y,-x,-z',
      '-y,z,-x',
      # Starting with Z
      'z,y,-x',
      'z,x,y',
      'z,-y,x',
      'z,-x,-y',
      # Starting with -Z
      '-z,y,x',
      '-z,-x,y',
      '-z,-y,-x',
      '-z,x,-y'
    ]

    # orientation_spec is a string specifying the new orientation
    # using the letters x, y, z in some order and with a sign applied.
    def initialize(orientation_spec)
      @order = []
      @signs = []
      orientation_spec.split(',').each do |coord|
        @signs << (coord.start_with?('-') ? -1 : 1)
        @order << case coord[-1]
                  when 'x' then 0
                  when 'y' then 1
                  when 'z' then 2
                  end
      end
    end

    # Apply rotation to a coordinate
    def apply(coords)
      @order.zip(@signs).map { |i, sign| coords[i] * sign }
    end

    # Iterator that yields every possible rotation
    def self.every_orientation
      ROTATIONS.each { |spec| yield Rotation.new(spec) }
    end
  end

  class Scanner
    attr_reader :beacons, :position

    def initialize(beacons, is_origin: false)
      @beacons = beacons
      @position = [0, 0, 0] if is_origin
    end

    def self.from_string(s, is_origin: false)
      beacons = s.lines(chomp: true).reject(&:empty?).map do |line|
        line.split(',').map { |x| x.to_i }
      end
      Scanner.new(beacons, is_origin: is_origin)
    end

    def [](key)
      @beacons[key]
    end

    # Manhattan distance to another scanner
    def distance_to(other)
      @position.zip(other.position).map { |a, b| (a - b).abs }.sum
    end

    # Match scanner against reference. Returns a boolean with the
    # result of the match, and if the match as positive, it modifies
    # the scanner with translation and rotation to be relative to the
    # reference.
    def match(reference)
      ref_beacon_set = Set.new(reference.beacons)

      Rotation.every_orientation do |rot|
        beacons = @beacons.map { |beacon| rot.apply(beacon) }

        # Only translations that result in at least one beacon
        # overlapping make sense. We find those by matching all
        # possible combinations of reference beacons with beacons of
        # this scanner.
        reference.beacons.product(beacons).map do |ref, this|
          translation = ref.zip(this).map { |r, t| r - t }

          translated_beacons = beacons.map do |beacon|
            beacon.zip(translation).map { |coord, offset| coord + offset }
          end

          # Use sets to match reference beacons with translated beacons
          # and check matching condition
          overlapping_set = ref_beacon_set & translated_beacons
          if overlapping_set.size >= 12
            @beacons = translated_beacons
            @position = translation
            return true
          end
        end
      end

      false
    end
  end

  # Read input into an ordered list of scanners
  def parse_input(input)
    input.split(/--- scanner (?:\d+) ---/).reject(&:empty?).map.with_index do |s, i|
      Scanner.from_string(s.chomp, is_origin: i == 0)
    end
  end

  def resolve_scanners(scanners)
    queue = [scanners[0]]
    unreferenced = scanners[1..]
    finished = []

    while queue.length > 0
      ref = queue.pop

      matched, unreferenced = unreferenced.partition do |scanner|
        scanner.match(ref)
      end

      queue = matched + queue

      finished.push(ref)
    end

    finished
  end

  def solve_part1(scanners)
    finished_scanners = resolve_scanners(scanners)
    beacons = Set.new(finished_scanners.map(&:beacons).sum([]))
    beacons.size
  end

  def solve_part2(scanners)
    finished_scanners = resolve_scanners(scanners)

    finished_scanners.product(finished_scanners).map do |a, b|
      a.distance_to(b)
    end.max
  end
end


require 'minitest/autorun'

class Day19Test < Minitest::Test
  include Day19

  def test_parse_input
    scanners = parse_input(File.read('example'))

    assert_equal 5, scanners.length
    assert_equal [-838, 591, 734], scanners[0][2]
    assert_equal [-30, 6, 44],  scanners[2][5]
    assert_equal [0, 0, 0], scanners[0].position
    assert_nil scanners[1].position
  end

  def test_rotation_apply
    rotation = Rotation.new('-z,y,x')
    assert_equal [-734, 591, -838], rotation.apply([-838, 591, 734])
  end

  def test_all_rotations
    count = 0
    Rotation.every_orientation do |rot|
      count += 1
      assert rot.is_a?(Rotation)
    end

    assert_equal 24, count
  end

  def test_match
    scanners = example

    assert scanners[1].match(scanners[0])
    assert scanners[1].beacons.include?([-618, -824, -621])
    assert_equal [68, -1246, -43], scanners[1].position
  end

  def test_part1_example
    assert_equal 79, solve_part1(example)
  end

  def test_part1_puzzle
    assert_equal 376, solve_part1(puzzle_input)
  end

  def test_part2_example
    assert_equal 3621, solve_part2(example)
  end

  def test_part2_example
    assert_equal 10772, solve_part2(puzzle_input)
  end

  def example
    parse_input(File.read('example'))
  end

  def puzzle_input
    parse_input(File.read('input'))
  end
end
