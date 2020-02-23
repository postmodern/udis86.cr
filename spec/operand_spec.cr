require "./spec_helper"

Spectator.describe UDis86::Operand do
  describe "TYPES" do
    subject { UDis86::Operand::TYPES }

    it "should define mappings from OP_ UDType to Symbols" do
      subject.each do |op_type,name|
        expect(subject[op_type].to_s).to eq(op_type.to_s.sub("OP_","").downcase)
      end
    end
  end

  describe "#type" do
    let(ud_operand) do
      ud_op = LibUDis86::UDOperand.new
      ud_op.type = LibUDis86::UDType::OP_REG
      ud_op
    end

    subject { described_class.new(ud_operand) }

    it "must return the operand type name as a Symbol" do
      expect(subject.type).to eq(:reg)
    end
  end

  describe "REGS" do
    subject { UDis86::Operand::REGS }

    it "should define mappings from :ud_type to register names" do
      subject.each do |reg,name|
        expect(subject[reg].to_s).to eq(reg.to_s.sub("R_","").downcase)
      end
    end
  end

  #  it "should provide the type of the operand" do
  #    operands = ud_operands('operands_simple')
  #
  #    expect(operands[0].type).to eq(:ud_op_reg)
  #    expect(operands[1].type).to eq(:ud_op_imm)
  #  end
  #
  #  it "should provide the size of the operand" do
  #    operands = ud_operands('operands_simple')
  #
  #    expect(operands[1].size).to be == 32
  #  end
  #
  #  it "should provide the value of the operand" do
  #    operands = ud_operands('operands_simple')
  #
  #    expect(operands[1].value.signed_byte).to be == 0x10
  #    expect(operands[1].value.unsigned_byte).to be == 0x10
  #  end
  #
  #  it "should specify value as nil for register operands" do
  #    operands = ud_operands('operands_simple')
  #
  #    expect(operands[0].value).to be_nil
  #  end
  #
  #  it "should provide the base of memory operands" do
  #    operands = ud_operands('operands_memory')
  #
  #    expect(operands[1].type).to be(:ud_op_mem)
  #    expect(operands[1][:base]).to be(:ud_r_esp)
  #    expect(operands[1].base).to be(:esp)
  #  end
  #
  #  it "should provide the index of memory operands" do
  #    operands = ud_operands('operands_index_scale')
  #
  #    expect(operands[1].type).to be(:ud_op_mem)
  #    expect(operands[1][:index]).to be(:ud_r_eax)
  #    expect(operands[1].index).to be(:eax)
  #  end
  #
  #  it "should provide the offset of memory operands" do
  #    operands = ud_operands('operands_offset')
  #
  #    expect(operands[1].type).to be(:ud_op_mem)
  #    expect(operands[1].offset.byte).to be == 0x10
  #  end
  #
  #  it "should provide the scale of memory operands" do
  #    operands = ud_operands('operands_index_scale')
  #
  #    expect(operands[1].type).to be(:ud_op_mem)
  #    expect(operands[1].scale).to be == 2
  #  end
  #
  #  it "should provide the register name for register operands" do
  #    operands = ud_operands('operands_simple')
  #
  #    expect(operands[0][:base]).to be(:ud_r_eax)
  #    expect(operands[0].reg).to be(:eax)
  #  end
end
