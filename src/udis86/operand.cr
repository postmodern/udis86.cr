require "../libudis86/types"
require "./operand_value"

module UDis86
  class Operand

    alias UDType = LibUDis86::UDType

    {% begin %}
    TYPES = {
      {% for element in UDType.constants %}
        {% if element.starts_with?("OP_") %}
          UDType::{{ element.id }} => :{{ element.stringify.gsub(/^OP_/,"").downcase }},
        {% end %}
      {% end %}
    }
    {% end %}

    #
    # Initializes the operand object.
    #
    def initialize(@operand : LibUDis86::UDOperand)
    end

    #
    # The type of the operand.
    #
    def type : Symbol
      TYPES[@operand.type]
    end

    #
    # Determines if the operand is a memory access.
    #
    def is_mem? : Bool
      @operand.type == UDType::OP_MEM
    end

    #
    # Determines if the operand is Segment:Offset pointer.
    #
    def is_seg_ptr? : Bool
      @operand.type == UDType::OP_PTR
    end

    #
    # Determines if the operand is immediate data.
    #
    def is_imm? : Bool
      @operand.type == UDType::OP_IMM
    end

    #
    # Determines if the operand is a relative offset used in a jump.
    #
    def is_jmp_imm? : Bool
      @operand.type = UDType::OP_JIMM
    end

    #
    # Determines if the operand is a data constant.
    #
    def is_const? : Bool
      @operand.type == UDType::OP_COONST
    end

    #
    # Determines if the operand is a register.
    #
    def is_reg? : Bool
      @operand.type == UDType::OP_REG
    end

    #
    # The size of the operand.
    #
    delegate size, to: @operand

    #
    # The value of the operand.
    #
    def value : OperandPointer | OperandValue | Nil
      if    is_reg?; nil
      elsif is_ptr?; OperandPointer.new(@operand.value.ptr)
      else           OperandValue.new(@operand.value)
      end
    end

    {% begin %}
    # Mappoing of libudis86 register UDTypes to Symbol names
    REGS = {
      {% for element in UDType.constants %}
        {% if element.starts_with?("R_") %}
          UDType::{{ element.id }} => :{{ element.stringify.gsub(/^R_/,"").downcase }},
        {% end %}
      {% end %}
    }
    {% end %}

    #
    # The base register used by the operand.
    #
    def base : Symbol
      REGS[@operand.base]
    end

    @[AlwaysInline]
    def reg
      base
    end

    #
    # The index register used by the operand.
    #
    def index : Symbol
      REGS[@operand.index]
    end

    #
    # The offset value used by the operand.
    #
    def offset : OperandValue | Int32
      if @operand.offset > 0; OperandValue.new(@operand.value)
      else                    0
      end
    end

    #
    # The word-length of the offset used with the operand.
    #
    @[AlwaysInline]
    def offset_size
      @operand.offset
    end

    #
    # The scale value used by the operand.
    #
    delegate scale, to: @operand

  end
end
