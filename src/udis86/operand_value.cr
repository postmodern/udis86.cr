require "../libudis86/types"
require "./operand_pointer"

module UDis86
  class OperandValue

    def initialize(@operand_value : LibUDis86::UDLVal)
    end

    delegate sbyte, to: @operand_value

    @[AlwaysInline]
    def char
      sbyte
    end

    @[AlwaysInline]
    def signed_byte
      sbyte
    end

    delegate ubyte, to: @operand_value

    @[AlwaysInline]
    def byte
      ubyte
    end

    @[AlwaysInline]
    def unsigned_byte
      ubyte
    end

    delegate sword, to: @operand_value

    @[AlwaysInline]
    def signed_word
      sword
    end

    delegate uword, to: @operand_value

    @[AlwaysInline]
    def word
      uword
    end

    @[AlwaysInline]
    def unsigned_word
      uword
    end

    delegate sdword, to: @operand_value

    @[AlwaysInline]
    def signed_double_word
      sdword
    end

    delegate udword, to: @operand_value

    @[AlwaysInline]
    def double_word
      udword
    end

    @[AlwaysInline]
    def unsigned_double_word
      udword
    end

    delegate sqword, to: @operand_value

    @[AlwaysInline]
    def signed_quad_word
      sqword
    end

    delegate uqword, to: @operand_value

    @[AlwaysInline]
    def quad_word
      uqword
    end

    @[AlwaysInline]
    def unsigned_quad_word
      uqword
    end

    def ptr
      OperandPointer.new(@operand_value.ptr)
    end

    @[AlwaysInline]
    def pointer
      ptr
    end

    @[AlwaysInline]
    def to_i
      signed_quad_word
    end

  end
end
