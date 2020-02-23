require "../libudis86/types"

module UDis86
  class OperandPointer

    def initialize(@operand_pointer : LibUDis86::UDLValPtr)
    end

    delegate seg, to: @operand_pointer

    def segment
      seg
    end

    delegate off, to: @operand_pointer

    def offset
      off
    end

  end
end
