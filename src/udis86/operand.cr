require "../libudis86/types"
require "./operand_value"

module UDis86
  class Operand

    alias Type = LibUDis86::UDType

    def initialize(@operand : LibUDis86::UDOperand)
    end

    delegate type, to: @operand

    def is_mem?
      @operand.type == Type::OP_MEM
    end

    def is_seg_ptr?
      @operand.type == Type::OP_PTR
    end

    def is_imm?
      @operand.type == Type::OP_IMM
    end

    def is_jmp_imm?
      @operand.type = Type::OP_JIMM
    end

    def is_const?
      @operand.type == Type::OP_COONST
    end

    def is_reg?
      @operand.type == Type::OP_REG
    end

    delegate size, to: @operand

    def value
      case type
      when :ud_op_reg then nil
      when :ud_op_ptr then OperandPointer.new(@operand.value.ptr)
      else                 OperandValue.new(@operand.value)
      end
    end

    {% begin %}
    # Mappoing of libudis86 register UDTypes to Symbol names
    REGS = {
      {% for element in Type.constants %}
        {% if element.starts_with?("R_") %}
          Type::{{ element.id }} => :{{ element.stringify.gsub(/^R_/,"").downcase }},
        {% end %}
      {% end %}
    }
    {% end %}

    def base
      REGS[@operand.base]
    end

    @[AlwaysInline]
    def reg
      base
    end

    def index
      REGS[@operand.index]
    end

    def offset
      if @operand.offset > 0; OperandValue.new(@operand.value)
      else                    0
      end
    end

    @[AlwaysInline]
    def offset_size
      @operand.offset
    end

    delegate scale, to: @operand

  end
end
