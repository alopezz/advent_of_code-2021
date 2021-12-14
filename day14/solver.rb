module Day13
  class Polymer
    def initialize(chain)
      @chain_end = chain[-1]
      @pairs = Hash.new(0)

      chain.each_index do |idx|
        if chain[idx + 1]
          @pairs[chain[idx] + chain[idx+1]] += 1
        end
      end
    end

    def self.from_string(str)
      Polymer.new(str.split(''))
    end

    def step(insertion_table)
      @pairs.to_a.each do |pair, count|
        new_elt = insertion_table[pair]
        if new_elt and count > 0
          @pairs[pair[0] + new_elt] += count
          @pairs[new_elt + pair[1]] += count
          @pairs[pair] -= count
        end
      end

      @frequencies = nil
    end

    def most_common
      frequencies.values.max
    end

    def least_common
      frequencies.values.min
    end

    def frequencies
      return @frequencies if @frequencies

      @frequencies = Hash.new(0)
      @frequencies[@chain_end] = 1
      @pairs.each do |pair, count|
        if count > 0
          @frequencies[pair[0]] += count
        end
      end

      @frequencies
    end
  end

  def parse_instructions(str)
    template, substitutions = str.split("\n\n")
    polymer = Polymer.from_string(template)

    substitution_table = substitutions.lines(chomp: true).map do |line|
      line.split(' -> ')
    end.to_h

    [polymer, substitution_table]
  end
end


require 'minitest/autorun'

class TestDay13 < Minitest::Test
  include Day13

  def setup
    @example = <<~EXAMPLE
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
    EXAMPLE
  end

  def test_parse_instructions
    polymer, substitutions = parse_instructions(@example)

    assert_equal polymer.frequencies['N'], 2
    assert_equal substitutions['CH'], 'B'
    assert_equal substitutions['NN'], 'C'
  end

  def test_step
    polymer, insertions = parse_instructions(@example)

    polymer.step(insertions)

    assert_equal polymer.frequencies['N'], 2
    assert_equal polymer.frequencies['C'], 2
    assert_equal polymer.frequencies['B'], 2
    assert_equal polymer.frequencies['H'], 1
  end

  def test_part1_example
    polymer, insertions = parse_instructions(@example)

    10.times { polymer.step(insertions) }

    assert_equal 1588, polymer.most_common - polymer.least_common
  end

  def test_part1_puzzle
    polymer, insertions = parse_instructions(File.read('input'))

    10.times { polymer.step(insertions) }

    assert_equal 2745, polymer.most_common - polymer.least_common
  end

  def test_part2_example
    polymer, insertions = parse_instructions(@example)

    40.times { polymer.step(insertions) }

    assert_equal 2188189693529, polymer.most_common - polymer.least_common
  end

  def test_part2_puzzle
    polymer, insertions = parse_instructions(File.read('input'))

    40.times { polymer.step(insertions) }

    assert_equal 3420801168962, polymer.most_common - polymer.least_common
  end
end
