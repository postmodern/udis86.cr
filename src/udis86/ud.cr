require "../libudis86"
require "./operand"

module UDis86

  class UD
    include Enumerable(self)

    #
    # Initializes the UD instance.
    #
    def initialize(@ud = LibUDis86::UD.new)
      init
    end

    #
    # Creates a new disassembler object.
    #
    def self.create(mode = 64, vendor = nil, syntax = nil, pc = nil, buffer = nil)
      ud = new

      ud.vendor = vendor if vendor
      ud.syntax = syntax if syntax
      ud.pc = pc if pc
      ud.input_buffer = buffer if buffer

      return ud
    end

    #
    # Creates a new disassembler object, with an input callback..
    #
    def self.create(**options, &block : InputCallback)
      ud = create(**options)
      ud.input_callback = block if block

      return ud
    end

    #
    # Opens a file and disassembles it.
    #
    def self.open(path,**options)
      File.open(path,"rb") do |file|
        ud = create(**options) do |ud|
          (file.read_byte || -1).to_i32
        end

        yield ud
      end
    end

    #
    # Initializes the disassembler.
    #
    def init
      LibUDis86.ud_init(pointerof(@ud))

      @input_buffer = nil
      @input_callback = nil
      @input_callback_box = nil
    end

    #
    # Returns the input buffer used by the disassembler.
    #
    getter input_buffer : Bytes?

    #
    # Sets the contents of the input buffer for the disassembler.
    #
    def input_buffer=(string : String)
      self.input_buffer = string.to_slice
    end

    #
    # Sets the contents of the input buffer for the disassembler.
    #
    def input_buffer=(ints : Array(UInt8))
      self.input_buffer = Bytes.new(ints.to_unsafe, ints.size)
    end

    #
    # Sets the contents of the input buffer for the disassembler.
    #
    def input_buffer=(bytes : Bytes)
      @input_buffer = bytes

      LibUDis86.ud_set_input_buffer(pointerof(@ud), bytes, bytes.size)
    end

    alias InputCallback = self -> Int32

    struct InputCallbackUserData
      def initialize(@ud : UD, @callback : InputCallback)
      end

      def call
        @callback.call(@ud)
      end
    end

    #
    # Returns the input callback for the disassembler.
    #
    getter input_callback : InputCallback?

    #
    # Sets the input callback for the disassembler.
    #
    def input_callback=(callback : InputCallback)
      @input_callback = callback
      @input_callback_box = Box.box(InputCallbackUserData.new(self, callback))

      LibUDis86.ud_set_user_opaque_data(pointerof(@ud), @input_callback_box)

      LibUDis86.ud_set_input_hook(pointerof(@ud), ->(ud : LibUDis86::UD*) {
        user_data = LibUDis86.ud_get_user_opaque_data(ud)
        input_callback = Box(InputCallbackUserData).unbox(user_data)

        input_callback.call
      })
    end

    # def hexdump
    #   Bytes.new(pointerof(@ud).as(UInt8*), sizeof(LibUDis86::UD)).hexdump
    # end

    MODES = Set{16, 32, 64}

    macro ud_delegate(method, ud_method = nil)
      @[AlwaysInline]
      def {{ method.id }}
        @ud.{{ (ud_method || method).id }}
      end
    end

    #
    # Returns the mode the disassembler is running in.
    #
    ud_delegate mode, dis_mode

    #
    # Sets the mode the disassembler will run in.
    #
    def mode=(mode : Int)
      unless MODES.includes?(mode)
        raise ArgumentError.new("invalid mode: #{mode}")
      end

      LibUDis86.ud_set_mode(pointerof(@ud), mode)
      return mode
    end

    SYNTAX = {
      :att   => ->LibUDis86.ud_translate_att,
      :intel => ->LibUDis86.ud_translate_intel,
    }

    #
    # Returns the syntax which the disassembler will emit.
    #
    def syntax
      unless @ud.translator.pointer.null?
        SYNTAX.invert[@ud.translator]
      end
    end

    #
    # Sets the syntax which the disassembler will emit.
    #
    def syntax=(syntax)
      ud_translator = SYNTAX.fetch(syntax) do
        raise ArgumentError.new("unknown syntax: #{syntax}")
      end

      LibUDis86.ud_set_syntax(pointerof(@ud), ud_translator)
    end

    VENDORS = {
      :amd   => LibUDis86::UD_VENDOR_AMD,
      :intel => LibUDis86::UD_VENDOR_INTEL,
      :any   => LibUDis86::UD_VENDOR_ANY,
    }

    #
    # The vendor of whose instructions are to be chosen from during
    # disassembly.
    #
    def vendor
      VENDORS.invert[@ud.vendor]
    end

    #
    # Sets the vendor, of whose instructions are to be chosen from
    # during disassembly.
    #
    def vendor=(vendor : Symbol)
      ud_vendor = VENDORS.fetch(vendor) do
        raise ArgumentError.new("unsupported vendor: #{vendor}")
      end

      LibUDis86.ud_set_vendor(pointerof(@ud), ud_vendor)
      return vendor
    end

    def input_index
      unless @ud.inp_buf.null?
        @ud.inp_buf_index
      end
    end

    def input_size
      unless @ud.inp_buf.null?
        @ud.inp_buf_size
      end
    end

    #
    # Causes the disassembler to skip a certain number of bytes in the
    # input stream.
    #
    def input_skip(count)
      LibUDis86.ud_set_mode(pointerof(@ud), count)
      return self
    end

    #
    # Tests for the end of input. You can use this function to test if the
    # input has been exhausted.
    #
    def input_end?
      LibUDis86.ud_input_end(pointerof(@ud)) > 0
    end

    #
    # Returns the current value of the Program Counter (PC).
    #
    ud_delegate pc

    #
    # Sets the value of the Program Counter (PC).
    #
    def pc=(value)
      LibUDis86.ud_set_pc(pointerof(@ud), value)
      return value
    end

    {% begin %}
    # Mapping of libudis86 mnemonic codes to Symbols names
    MNEMONICS = {
      {% for element in LibUDis86::UDMnemonicCode.constants %}
        LibUDis86::UDMnemonicCode::{{ element.id }} => :{{ element.stringify.gsub(/^I/,"") }},
      {% end %}
    }
    {% end %}

    #
    # The mnemonic code of the last disassembled instruction.
    #
    def insn_mnemonic
      MNEMONICS[LibUDis86.ud_insn_mnemonic(pointerof(@ud))]
    end

    @[AlwaysInline]
    def mnemonic_code
      insn_mnemonic
    end

    #
    # The mnemonic string of the last disassembled instruction.
    #
    def mnemonic
      String.new(LibUDis86.ud_lookup_mnemonic(@ud.mnemonic))
    end

    #
    # The 64-bit mode REX prefix of the last disassembled instruction.
    #
    ud_delegate rex_prefix, pfx_rex

    #
    # The segment register prefix of the last disassembled instruction.
    #
    ud_delegate segment_prefix, pfx_seg

    #
    # The operand-size prefix (66h) of the last disassembled instruction.
    #
    ud_delegate operand_prefix, pfx_opr

    #
    # The address-size prefix (67h) of the last disassembled instruction.
    #
    ud_delegate address_prefix, pfx_adr

    #
    # The lock prefix of the last disassembled instruction.
    #
    ud_delegate lock_prefix, pfx_lock

    #
    # The rep prefix of the last disassembled instruction.
    #
    ud_delegate rep_prefix, pfx_rep

    #
    # The repe prefix of the last disassembled instruction.
    #
    ud_delegate repe_prefix, pfx_repe

    #
    # The repne prefix of the last disassembled instruction.
    #
    ud_delegate repne_prefix, pfx_repne

    #
    # Returns the assembly syntax for the last disassembled instruction.
    #
    def to_asm
      String.new(LibUDis86.ud_insn_asm(pointerof(@ud)))
    end

    #
    # Returns the hexadecimal representation of the disassembled
    # instruction.
    #
    def to_hex
      String.new(LibUDis86.ud_insn_hex(pointerof(@ud)))
    end

    def to_s
      to_asm
    end

    def to_s(io : IO) : Nil
      io << to_asm
    end

    #
    # Returns the operands for the last disassembled instruction.
    #
    def operands
      @ud.operand.select { |operand|
        operand.type.is_op?
      }.map(&->Operand.new(LibUDis86::UDOperand))
    end

    #
    # Disassembles the next instruction in the input stream.
    #
    def next_insn
      LibUDis86.ud_disassemble(pointerof(@ud)) > 0
    end

    #
    # Returns the number of bytes that were disassembled.
    #
    def insn_length
      LibUDis86.ud_insn_len(pointerof(@ud))
    end

    #
    # Returns the starting offset of the disassembled instruction
    # relative to the initial value of the Program Counter (PC).
    #
    def insn_offset
      LibUDis86.ud_insn_offset(pointerof(@ud))
    end

    #
    # Returns the pointer to the buffer holding the disassembled
    # instruction bytes.
    #
    def insn_ptr
      LibUDis86.ud_insn_ptr(pointerof(@ud))
    end

    #
    # Returns the operand at the nth (starting with 0) position of the
    # instruction.
    #
    def insn_opr(index = 0)
      unless (opr_ptr = LibUDis86.ud_insn_opr(pointerof(@ud),index)).null?
        return Operand.new(opr_ptr.value)
      end
    end

    #
    # Reads each byte, disassembling each instruction.
    #
    def disassemble
      until next_insn
        yield self
      end

      return self
    end

    @[AlwaysInline]
    def disas(&block)
      disassemble(&block)
    end

    def each(&block : self ->)
      disassemble(&block)
    end
  end
end
