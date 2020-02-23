require "../libudis86/types"
require "./operand_pointer"

module UDis86
  class OperandValue

    #
    # Initializes the operand value object.
    #
    def initialize(@operand_value : LibUDis86::UDLVal)
    end

    #
    # The signed byte value of the operand.
    #
    delegate sbyte, to: @operand_value

    @[AlwaysInline]
    def char
      sbyte
    end

    @[AlwaysInline]
    def signed_byte
      sbyte
    end

    #
    # The unsigned byte value of the operand.
    #
    delegate ubyte, to: @operand_value

    @[AlwaysInline]
    def byte
      ubyte
    end

    @[AlwaysInline]
    def unsigned_byte
      ubyte
    end

    #
    # The signed word value of the operand.
    #
    delegate sword, to: @operand_value

    @[AlwaysInline]
    def signed_word
      sword
    end

    #
    # The unsigned word value of the operand.
    #
    delegate uword, to: @operand_value

    @[AlwaysInline]
    def word
      uword
    end

    @[AlwaysInline]
    def unsigned_word
      uword
    end

    #
    # The signed double-word value of the operand.
    #
    delegate sdword, to: @operand_value

    @[AlwaysInline]
    def signed_double_word
      sdword
    end

    #
    # The unsigned double-word value of the operand.
    #
    delegate udword, to: @operand_value

    @[AlwaysInline]
    def double_word
      udword
    end

    @[AlwaysInline]
    def unsigned_double_word
      udword
    end

    #
    # The signed quad-word value of the operand.
    #
    delegate sqword, to: @operand_value

    @[AlwaysInline]
    def signed_quad_word
      sqword
    end

    #
    # The unsigned quad-word value of the operand.
    #
    delegate uqword, to: @operand_value

    @[AlwaysInline]
    def quad_word
      uqword
    end

    @[AlwaysInline]
    def unsigned_quad_word
      uqword
    end

    #
    # The pointer value of the operand.
    #
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
