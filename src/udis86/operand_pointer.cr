require "../libudis86/types"

module UDis86
  class OperandPointer

    #
    # Initializes the operand pointer instance.
    #
    def initialize(@operand_pointer : LibUDis86::UDLValPtr)
    end

    #
    # Returns the pointer segment.
    #
    delegate seg, to: @operand_pointer

    def segment
      seg
    end

    #
    # Returns the offset within the segment of the pointer.
    #
    delegate off, to: @operand_pointer

    def offset
      off
    end

  end
end
