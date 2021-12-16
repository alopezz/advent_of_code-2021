class String
  def split_at(idx)
    [self[0, idx], self[idx..]]
  end

  def bin_as_int
    to_i(2)
  end
end


module Day16
  module Packet
    class Literal
      attr_reader :version

      def initialize(version)
        @version = version
        @bin_number = ""
      end

      # Updates packet with payload and returns unused part
      def parse(payload)
        loop do
          next_number, payload = payload.split_at(5)
          @bin_number << next_number[1..]
          return payload if next_number[0] == '0'
        end
      end

      def eval
        @bin_number.bin_as_int
      end
    end

    module Operator
      def initialize(version)
        @version = version
        @subpackets = []
      end

      # Adds all version numbers including subpackets
      def version
        @version + @subpackets.map(&:version).sum
      end

      # Updates packet with payload and returns unused part
      def parse(payload)
        length_type, payload = payload.split_at(1)

        if length_type == '0'
          parse_bits(payload)
        else
          parse_packets(payload)
        end
      end

      private

      def parse_bits(payload)
        n_bits, payload = payload.split_at(15)
        n_bits = n_bits.bin_as_int

        payload, rest = payload.split_at(n_bits)
        loop do
          new_packet, payload = Packet.read_packet(payload)
          break unless new_packet
          @subpackets << new_packet
        end

        rest
      end

      def parse_packets(payload)
        n_packets, payload = payload.split_at(11)
        n_packets = n_packets.bin_as_int

        n_packets.times do
          new_packet, payload = Packet.read_packet(payload)
          @subpackets << new_packet
        end

        payload
      end

      def self.make(&block)
        Class.new do
          include Operator
          define_method(:eval) { block.call(@subpackets.map(&:eval)) }
        end
      end
    end

    Sum = Operator.make(&:sum)
    Product = Operator.make { |operands| operands.reduce(&:*) }
    Minimum = Operator.make(&:min)
    Maximum = Operator.make(&:max)
    GreaterThan = Operator.make { |operands| operands[0] > operands[1] ? 1 : 0 }
    LessThan = Operator.make { |operands| operands[0] < operands[1] ? 1 : 0 }
    EqualTo = Operator.make { |operands| operands[0] == operands[1] ? 1 : 0 }

    class << self
      TYPES = {
        0 => Sum,
        1 => Product,
        2 => Minimum,
        3 => Maximum,
        4 => Literal,
        5 => GreaterThan,
        6 => LessThan,
        7 => EqualTo
      }

      def read_hex(hex)
        read_packet(Day16.parse_hex(hex))
      end

      def read_packet(bin)
        # Deal with trailing 0's or empty packets
        return [nil, ''] if bin =~ /^0*$/

        header, payload = bin.split_at(6)
        version, type = header.split_at(3).map(&:bin_as_int)

        packet = TYPES[type].new(version)
        rest = packet.parse(payload)

        [packet, rest]
      end
    end
  end

  # Parse an input line (in hex) to a string representation of the binary number
  def self.parse_hex(line)
    line.to_i(16).to_s(2).rjust(4*line.length, '0')
  end
end


require 'minitest/autorun'

class TestDay16 < Minitest::Test
  include Day16

  def test_parse_hex
    assert_equal '11101110000000001101010000001100100000100011000001100000',
                 Day16.parse_hex('EE00D40C823060')

    # Tricky! with leading zeros:
    assert_equal '00111000000000000110111101000101001010010001001000000000',
                 Day16.parse_hex('38006F45291200')
  end

  def test_parse_literal_payload
    # Directly parse the payload without the header
    packet = Packet::Literal.new(1)
    result = packet.parse('101111111000101000')
    assert_equal '000', result
    assert_equal 2021, packet.eval

    # Whole process including identification of packet type
    packet, rest = Packet.read_packet('110100101111111000101000')
    assert_equal 6, packet.version
    assert_equal 2021, packet.eval
    assert_equal '000', rest
  end

  def test_version_sums
    # A.K.A. Examples for part 1

    packet, rest = Packet.read_hex('8A004A801A8002F478')
    assert_equal 16, packet.version

    # Problem
    packet, rest = Packet.read_hex('620080001611562C8802118E34')
    assert_equal 12, packet.version

    packet, rest = Packet.read_hex('C0015000016115A2E0802F182340')
    assert_equal 23, packet.version

    packet, rest = Packet.read_hex('A0016C880162017C3686B18A3D4780')
    assert_equal 31, packet.version
  end

  def test_puzzle_part1
    input = File.read('input').chomp
    packet, _ = Packet.read_hex(input)

    assert_equal 871, packet.version
  end

  def test_ops
    # From puzzle examples
    packet, rest = Packet.read_hex('C200B40A82')
    assert_equal 3, packet.eval

    packet, rest = Packet.read_hex('04005AC33890')
    assert_equal 54, packet.eval

    packet, rest = Packet.read_hex('880086C3E88112')
    assert_equal 7, packet.eval

    packet, rest = Packet.read_hex('CE00C43D881120')
    assert_equal 9, packet.eval

    packet, rest = Packet.read_hex('D8005AC2A8F0')
    assert_equal 1, packet.eval

    packet, rest = Packet.read_hex('F600BC2D8F')
    assert_equal 0, packet.eval

    packet, rest = Packet.read_hex('9C005AC2F8F0')
    assert_equal 0, packet.eval

    packet, rest = Packet.read_hex('9C0141080250320F1802104A08')
    assert_equal 1, packet.eval
  end

  def test_puzzle_part2
    input = File.read('input').chomp

    packet, rest = Packet.read_hex(input)
    assert_equal 68703010504, packet.eval
  end
end
