module Day12
  module Cave
    class << self
      def is_big?(cave)
        cave.upcase == cave
      end

      def is_small?(cave)
        cave.downcase == cave
      end
    end
  end

  module Path
    def initialize(cave_map)
      @cave_map = cave_map
      @path = ['start']
    end

    def walk_all
      if last == 'end'
        return [@path]
      end

      @cave_map[last].filter { |dst| can_walk_to?(dst) }
        .map { |dst| dup.walk(dst).walk_all }
        .flatten(1)
    end

    def include?(val)
      @path.include?(val)
    end

    def initialize_copy(other)
      @path = other.path.dup
    end

    def to_a
      @path.dup
    end

    protected

    attr_reader :path

    def walk(dst)
      @path << dst
      self
    end

    def last
      @path.last
    end
  end

  class PathPart1
    include Path

    def can_walk_to?(dst)
      Cave.is_big?(dst) || !include?(dst)
    end
  end

  class PathPart2
    include Path

    def can_walk_to?(dst)
      Cave.is_big?(dst) || !@twice_used || !include?(dst)
    end

    def walk(dst)
      if Cave.is_small?(dst) && include?(dst)
        @twice_used = true
      end
      super(dst)
    end
  end

  class CaveMap
    def initialize
      @connections = []
    end

    def add_connection(src, dest)
      @connections.push([src, dest])
    end

    def <<(src, dest)
      add_connection(src, dest)
    end

    def self.from_string(input)
      new_map = CaveMap.new
      input.each_line do |line|
        src, dest = line.chomp.split('-')
        new_map.add_connection(src, dest)
      end
      new_map
    end

    def [](key)
      @connections
        .filter { |src, dst| src === key && !(dst === 'start') }
        .map { |src, dst| dst } +
        @connections
          .filter { |src, dst| dst === key && !(src === 'start') }
          .map { |src, dst| src }
    end
  end
end


require 'minitest/autorun'

class TestDay12 < Minitest::Test
  include Day12

  def test_cave_is_big
    assert Cave.is_big?('AB')
  end

  def test_cave_is_small
    assert Cave.is_small?('ab')
  end

  def test_cave_map_from_string
    cave_map = CaveMap.from_string(<<~EXAMPLE)
start-A
start-b
A-c
A-b
b-d
A-end
b-end
    EXAMPLE

    assert_equal ['A', 'b'], cave_map['start']
    assert_equal ['c', 'b', 'end'], cave_map['A']
  end

  def test_path_walk_all_part1
    cave_map = CaveMap.from_string(<<~EXAMPLE)
start-A
start-b
A-c
A-b
b-d
A-end
b-end
    EXAMPLE

    expected = [['start', 'A', 'c', 'A', 'b', 'end'],
                ['start', 'A', 'c', 'A', 'b' ,'A', 'end'],
                ['start', 'A', 'c', 'A' ,'end'],
                ['start', 'A', 'b', 'end'],
                ['start', 'A' , 'b' ,'A', 'c', 'A', 'end'],
                ['start', 'A', 'b', 'A', 'end'],
                ['start', 'A', 'end'],
                ['start', 'b', 'end'],
                ['start', 'b', 'A', 'c', 'A', 'end'],
                ['start', 'b', 'A', 'end']]

    result = PathPart1.new(cave_map).walk_all.to_a

    assert_equal expected.size, result.size
    assert_equal expected, result
  end

  def test_path_walk_all_part2
    cave_map = CaveMap.from_string(<<~EXAMPLE)
start-A
start-b
A-c
A-b
b-d
A-end
b-end
    EXAMPLE

    result = PathPart2.new(cave_map).walk_all.to_a
    assert_equal 36, result.size
  end

  def test_puzzle_part1
    cave_map = CaveMap.from_string(File.read('input'))
    assert_equal 5178, PathPart1.new(cave_map).walk_all.size
  end

  def test_puzzle_part2
    cave_map = CaveMap.from_string(File.read('input'))
    assert_equal 130094, PathPart2.new(cave_map).walk_all.size
  end

end
