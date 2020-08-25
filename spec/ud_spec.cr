require "./spec_helper"

Spectator.describe UDis86::UD do
  let(string) { Fixtures["simple"] }
  let(uints) { string.bytes }
  let(bytes) { Bytes.new(uints.to_unsafe, uints.size) }

  describe ".create" do
    context "when given no arguments" do
      subject { described_class.create }

      it "should return a initialized UD object" do
        expect(subject).to be_a(UDis86::UD)
      end
    end

    context "when given syntax" do
      let(syntax) { :att }

      subject { described_class.create(syntax: syntax) }

      it "should set the #syntax" do
        expect(subject.syntax).to eq(syntax)
      end
    end

    context "when given vendor" do
      let(vendor) { :intel }

      subject { described_class.create(vendor: vendor) }

      it "should set the #vendor" do
        expect(subject.vendor).to eq(vendor)
      end
    end

    context "when given buffer" do
      let(buffer) { string }
      subject { described_class.create(buffer: buffer) }

      it "should set the #input_buffer" do
        expect(subject.input_buffer).to eq(bytes)
      end
    end

    context "when given pc" do
      let(pc) { 0x400000_u64 }
      subject { described_class.create(pc: pc) }

      it "should set the #pc" do
        expect(subject.pc).to eq(pc)
      end
    end

    context "when given a block" do
      let(input_callback) { ->(ud : UDis86::UD) { 0x90 } }

      subject { described_class.create(&input_callback) }

      it "should set #input_callback" do
        expect(subject.input_callback).to eq(input_callback)
      end
    end
  end

  describe ".open" do
    let(fixture) { "simple" }
    let(path)    { Fixtures.path(fixture) }
    let(hex)     { Fixtures[fixture].bytes.map(&.to_s(16)) }

    it "must open the file and read each byte" do
      described_class.open(path) do |ud|
        expect(ud.next_insn).to eq(true)
        expect(ud.to_hex).to be == hex[0]

        expect(ud.next_insn).to eq(true)
        expect(ud.to_hex).to be == hex[1]

        expect(ud.next_insn).to eq(true)
        expect(ud.to_hex).to be == hex[2]

        expect(ud.next_insn).to eq(false)
      end
    end
  end

  describe "#init" do
    let(mode)   { 32   }
    let(syntax) { :att }
    let(vendor) { :any }

    subject do
      described_class.new.tap do |ud|
        ud.mode = mode
        ud.syntax = syntax
        ud.vendor = vendor
      end
    end

    before_each { subject.init }

    it "must reset the underlying struct data" do
      expect(subject.mode).to_not eq(mode)
      expect(subject.syntax).to_not eq(syntax)
      expect(subject.vendor).to_not eq(vendor)
    end
  end

  describe "#input_buffer" do
    context "when the struct is blank" do
      subject { described_class.new }

      it { expect(subject.input_buffer).to be_nil }
    end
  end

  describe "#input_buffer=" do
    let(uints) { string.bytes }
    let(bytes) { Bytes.new(uints.to_unsafe, uints.size) }

    context "when given Bytes" do
      before_each { subject.input_buffer = bytes }

      it { expect(subject.input_buffer).to eq(bytes) }
    end

    context "when given a String" do
      before_each { subject.input_buffer = string }

      it { expect(subject.input_buffer).to eq(bytes) }
    end

    context "when given an Array(UInt8)" do
      before_each { subject.input_buffer = uints }

      it { expect(subject.input_buffer).to eq(bytes) }
    end
  end

  describe "#mode=" do
    let(modes) { UDis86::UD::MODES }

    sample modes do |mode|
      it "must set the UD mode" do
        subject.mode = mode

        expect(subject.mode).to eq(mode)
      end
    end

    context "when given an invalid mode" do
      it do
        expect { subject.mode = 1 }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#mode" do
    let(mode) { 16 }
    
    subject do
      described_class.new.tap do |ud|
        ud.mode = mode
      end
    end

    it "must return the set mode" do
      expect(subject.mode).to eq(mode)
    end
  end

  describe "#syntax=" do
    let(syntaxes) { UDis86::UD::SYNTAX.keys }

    sample syntaxes do |syntax|
      it "must set the UD syntax" do
        subject.syntax = syntax

        expect(subject.syntax).to eq(syntax)
      end
    end

    context "when given an invalid syntax" do
      it do
        expect { subject.syntax = :foo }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#syntax" do
    let(syntax) { :att }
    before_each { subject.syntax = syntax }

    it "must return the set syntax" do
      expect(subject.syntax).to eq(syntax)
    end

    context "when the underlying struct is blank" do
      before_each { subject.init }

      it { expect(subject.syntax).to eq(nil) }
    end
  end

  describe "#vendor=" do
    let(vendors) { UDis86::UD::VENDORS.keys }

    sample vendors do |vendor|
      it "must set the UD vendor" do
        subject.vendor = vendor

        expect(subject.vendor).to eq(vendor)
      end
    end

    context "when given an invalid vendor" do
      it do
        expect { subject.vendor = :foo }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#vendor" do
    let(vendor) { :any }
    before_each { subject.vendor = vendor }

    it "must return the set vendor" do
      expect(subject.vendor).to eq(vendor)
    end
  end

  describe "#input_index" do
    subject do
      described_class.new.tap do |ud|
        ud.input_buffer = string
      end
    end

    context "at the beginning" do
      it { expect(subject.input_index).to eq(0) }
    end

    context "after disassembling the first instruction" do
      before_each { subject.next_insn }

      it { expect(subject.input_index).to eq(1) }
    end

    context "after an instruction has been disassembled" do
      before_each do
        subject.next_insn
        subject.next_insn
      end

      it "should advance the #input_index" do
        expect(subject.input_index).to eq(2)
      end
    end
  end

  describe "#input_skip" do
    subject do
      described_class.new.tap do |ud|
        ud.mode = 32
        ud.syntax = :intel
        ud.input_buffer = string
      end
    end

    before_each do
      subject.next_insn
      subject.input_skip(1)
      subject.next_insn
    end

    it "should skip over the given number of bytes" do
      expect(subject.to_asm).to eq("ret")
    end
  end

  describe "#input_end?" do
    subject do
      described_class.new.tap do |ud|
        ud.syntax = :intel
        ud.input_buffer = string
      end
    end

    context "when the input is not fully read" do
      it do
        subject.next_insn

        expect(subject.input_end?).to be_false
      end
    end

    context "when the input has been exhausted" do
      it do
        (string.size + 1).times do
          subject.next_insn
        end

        expect(subject.input_end?).to be_true
      end
    end
  end

  describe "#pc" do
    context "when #pc is not set" do
      it { expect(subject.pc).to eq(0) }
    end

    context "when #pc is set" do
      let(pc) { 0x40000_u64 }

      subject do
        described_class.new.tap do |ud|
          ud.pc = pc
        end
      end

      it "should return the set pc value" do
        expect(subject.pc).to eq(pc)
      end
    end
  end

  describe "#pc=" do
    let(pc) { 0x40000_u64 }

    it "should return the set pc value" do
      subject.pc = pc

      expect(subject.pc).to eq(pc)
    end
  end

  describe "#insn_mnemonic" do
    subject do
      described_class.new.tap do |ud|
        ud.input_buffer = string
      end
    end

    before_each { subject.next_insn }

    it "should return the UDMnemonicCode for the disassembled instruction" do
      expect(subject.insn_mnemonic).to eq(:nop)
    end
  end

  describe "#mnemonic" do
    subject do
      described_class.new.tap do |ud|
        ud.input_buffer = string
      end
    end

    before_each { subject.next_insn }

    it "should return the mnemonic string" do
      expect(subject.mnemonic).to eq("nop")
    end
  end

  describe "#operands" do
    let(string) { Fixtures["operands_simple"] }

    subject do
      described_class.new.tap do |ud|
        ud.mode = 32
        ud.vendor = :any
        ud.syntax = :att
        ud.input_buffer = string
      end
    end

    before_each { subject.next_insn }

    context "when the instruction has operands" do
      it "must return an Array of Operands" do
        operands = subject.operands

        expect(operands).to_not be_empty
        expect(operands).to all(be_a(UDis86::Operand))
      end
    end

    context "when the instruction has no operands" do
      let(string) { "\x90" }

      it "must return an empty Array" do
        expect(subject.operands).to be_empty
      end
    end
  end

  describe "#next_insn" do
    context "when it is not at the end of the input" do
      subject do
        described_class.new.tap do |ud|
          ud.input_buffer = "\x90"
        end
      end

      it do
        expect(subject.next_insn).to eq(true)
      end
    end

    context "when it is at the end of the input" do
      subject do
        described_class.new.tap do |ud|
          ud.input_buffer = "\x90"
        end
      end

      it do
        subject.next_insn

        expect(subject.next_insn).to eq(false)
      end
    end
  end

  describe "#insn_length" do
    subject do
      described_class.new.tap do |ud|
        ud.mode = 32
        ud.input_buffer = string
      end

      before_each { subject.next_insn }

      it "must return the length of the previously disassembled instruction" do
        expect(subject.insn_length).to eq(1)
      end
    end
  end

  describe "#insn_offset" do
    subject do
      described_class.new.tap do |ud|
        ud.mode = 32
        ud.input_buffer = string
      end

      before_each do
        subject.next_insn
        subject.next_insn
        subject.next_insn
      end

      it "must return the length of the previously disassembled instruction" do
        expect(subject.insn_offset).to eq(3)
      end
    end
  end

  describe "#insn_opr" do
    let(string) { Fixtures["operands_simple"] }

    subject do
      described_class.new.tap do |ud|
        ud.input_buffer = string
      end
    end

    before_each { subject.next_insn }

    context "when given no arguments" do
      it "must return the first operand" do
        expect(subject.insn_opr).to be_a(UDis86::Operand)
      end
    end

    context "when given the index of an operand" do
      it do
        expect(subject.insn_opr(0)).to be_a(UDis86::Operand)
      end
    end

    context "when given an index that does not map to an operand" do
      it do
        expect(subject.insn_opr(3)).to eq(nil)
      end
    end

    context "when given an index greater than 3" do
      it do
        expect(subject.insn_opr(4)).to eq(nil)
      end
    end
  end

  describe "#to_hex" do
    subject do
      described_class.new.tap do |ud|
        ud.input_buffer = string
      end
    end

    before_each { subject.next_insn }

    it "should return the hexademical bytes of the instruction" do
      expect(subject.to_hex).to eq("90")
    end
  end

  describe "#to_asm" do
    subject do
      described_class.new.tap do |ud|
        ud.syntax = :intel
        ud.input_buffer = string
      end
    end

    it "should return the assembly code of the instruction" do
      subject.next_insn

      expect(subject.to_asm).to eq("nop")
    end
  end
end
