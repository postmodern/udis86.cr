require "./itab"

lib LibUDis86
  enum UDType
    None

    # 8 bit GPRs
    R_AL; R_CL; R_DL; R_BL
    R_AH; R_CH; R_DH; R_BH
    R_SPL; R_BPL; R_SIL; R_DIL
    R_R8B; R_R9B; R_R10B; R_R11B
    R_R12B; R_R13B; R_R14B; R_R15B

    # 16 bit GPRs
    R_AX; R_CX; R_DX; R_BX
    R_SP; R_BP; R_SI; R_DI
    R_R8W; R_R9W; R_R10W; R_R11W
    R_R12W; R_R13W; R_R14W; R_R15W

    # 32 bit GPRs
    R_EAX; R_ECX; R_EDX; R_EBX
    R_ESP; R_EBP; R_ESI; R_EDI
    R_R8D; R_R9D; R_R10D; R_R11D
    R_R12D; R_R13D; R_R14D; R_R15D

    # 64 bit GPRs
    R_RAX; R_RCX; R_RDX; R_RBX
    R_RSP; R_RBP; R_RSI; R_RDI
    R_R8; R_R9; R_R10; R_R11
    R_R12; R_R13; R_R14; R_R15

    # segment registers
    R_ES; R_CS; R_SS; R_DS
    R_FS; R_GS

    # control registers
    R_CR0; R_CR1; R_CR2; R_CR3
    R_CR4; R_CR5; R_CR6; R_CR7
    R_CR8; R_CR9; R_CR10; R_CR11
    R_CR12; R_CR13; R_CR14; R_CR15

    # debug registers
    R_DR0; R_DR1; R_DR2; R_DR3
    R_DR4; R_DR5; R_DR6; R_DR7
    R_DR8; R_DR9; R_DR10; R_DR11
    R_DR12; R_DR13; R_DR14; R_DR15

    # mmx registers
    R_MM0; R_MM1; R_MM2; R_MM3
    R_MM4; R_MM5; R_MM6; R_MM7

    # x87 registers
    R_ST0; R_ST1; R_ST2; R_ST3
    R_ST4; R_ST5; R_ST6; R_ST7

    # extended multimedia registers
    R_XMM0; R_XMM1; R_XMM2; R_XMM3
    R_XMM4; R_XMM5; R_XMM6; R_XMM7
    R_XMM8; R_XMM9; R_XMM10; R_XMM11
    R_XMM12; R_XMM13; R_XMM14; R_XMM15

    # 256B multimedia registers
    R_YMM0; R_YMM1; R_YMM2; R_YMM3
    R_YMM4; R_YMM5; R_YMM6; R_YMM7
    R_YMM8; R_YMM9; R_YMM10; R_YMM11
    R_YMM12; R_YMM13; R_YMM14; R_YMM15

    R_RIP

    # Operand Types
    OP_REG; OP_MEM; OP_PTR; OP_IMM
    OP_JIMM; OP_CONST

    def is_op?
      self == OP_REG  ||
      self == OP_MEM  ||
      self == OP_PTR  ||
      self == OP_IMM  ||
      self == OP_JIMM ||
      self == OP_CONST
    end

    def none?
      self == None
    end

    def is_reg?
      !none? && !is_op?
    end
  end

  struct UDLValPtr
    seg : UInt16
    off : UInt32
  end

  union UDLVal
    sbyte : Int8
    ubyte : UInt8
    sword : Int16
    uword : UInt16
    sdword : Int32
    udword : UInt32
    sqword : Int64
    uqword : UInt64
    ptr : UDLValPtr
  end

  struct UDOperand
    type : UDType
    size : UInt16
    base : UDType
    index : UDType
    scale : UInt8
    offset : UInt8
    lval : UDLVal

    #
    # internal use only
    #
    _legacy : UInt64 # this will be removed in libudis86 1.8
    _oprcode : UInt8
  end

  alias Int = LibC::Int
  alias UInt = LibC::UInt
  alias SizeT = LibC::SizeT
  alias Char = LibC::Char

  alias InputHook = (UD*) -> Int
  alias Translator = (UD*) ->
  alias SymResolver = (UD*, UInt64, UInt64*) -> Char*

  struct UD
    #
    # Input Buffering
    #
    inp_hook : InputHook
    inp_file : Void* # TODO: support FILE*
    inp_buf : UInt8*
    inp_buf_size : SizeT
    inp_buf_index : SizeT
    inp_curr : UInt8
    inp_ctr : SizeT
    inp_sess : UInt8[64]
    inp_end : Int
    inp_peek : Int

    translator : Translator
    insn_offset : UInt64
    insn_hexcode : Char[64]

    #
    # Assembly Output Buffer
    #
    asm_buf : Char*
    asm_buf_size : SizeT
    asm_buf_fill : SizeT
    asm_buf_int : Char[128]

    # Symbol resolver for use in the translation phase.
    sym_resolver : SymResolver

    dis_mode : UInt8
    pc : UInt64
    vendor : UInt8
    mnemonic : UDMnemonicCode
    operand : UDOperand[4]
    error, _rex, pfx_rex, pfx_seg, pfx_opr, pfx_adr, pfx_lock, pfx_str, pfx_rep, pfx_repe, pfx_repne, opr_mode, adr_mode, br_far, br_near, have_modrm, modrm, modrm_offset, vex_op, vex_b1, vex_b2, primary_opcode : UInt8
    user_opaque_data : Void*
    itab_entry : Void* # struct ud_itab_entry *
    le : Void*         # struct ud_lookup_table_list_entry *
  end

  # TODO: function pointer
  # UD_SYN_INTEL          = ud_translate_intel
  # UD_SYN_ATT            = ud_translate_att
  UD_EOI          = (-1)
  UD_INP_CACHE_SZ = 32
  UD_VENDOR_AMD   =  0
  UD_VENDOR_INTEL =  1
  UD_VENDOR_ANY   =  2
end
