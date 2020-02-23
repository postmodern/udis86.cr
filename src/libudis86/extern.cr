require "./types"

@[Link("udis86")]
lib LibUDis86
  fun ud_init(ud : UD*)
  fun ud_set_mode(ud : UD*, mode : UInt8)
  fun ud_set_pc(ud : UD*, pc : UInt64)
  fun ud_set_input_hook(ud : UD*, callback : InputHook)
  fun ud_set_input_buffer(ud : UD*, buffer : UInt8*, size : SizeT)
  fun ud_set_input_file(ud : UD*, file : Void*) # TODO: support FILE*
  fun ud_set_vendor(ud : UD*, vendor : UInt)
  fun ud_set_syntax(ud : UD*, syntax : Translator)
  fun ud_input_skip(ud : UD*, count : SizeT)
  fun ud_input_end(ud : UD*) : Int
  fun ud_decode(ud : UD*) : UInt
  fun ud_disassemble(ud : UD*) : UInt
  fun ud_translate_intel(ud : UD*)
  fun ud_translate_att(ud : UD*)
  fun ud_insn_asm(ud : UD*) : Char*
  fun ud_isns_ptr(ud : UD*) : UInt8*
  fun ud_insn_off(ud : UD*) : UInt64
  fun ud_insn_hex(ud : UD*) : Char*
  fun ud_insn_len(ud : UD*) : UInt
  fun ud_insn_opr(ud : UD*, n : UInt) : UDOperand*
  fun ud_opr_is_sreg(opr : UDOperand*) : Int
  fun ud_opr_is_gpr(opr : UDOperand*) : Int
  fun ud_insn_mnemonic(ud : UD*) : UDMnemonicCode
  fun ud_lookup_mnemonic(c : UDMnemonicCode) : Char*
  fun ud_set_user_opaque_data(ud : UD*, data : Void*)
  fun ud_get_user_opaque_data(ud : UD*) : Void*
  fun ud_set_asm_buffer(ud : UD*, buffer : Char*, size : SizeT)
  fun ud_set_sym_resolver(ud : UD*, callback : SymResolver)
end
