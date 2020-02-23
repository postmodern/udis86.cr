require "./libudis86"
require "./udis86/ud"

module UDis86
  VERSION = "0.1.0"

  alias UDType = LibUDis86::UDType
  alias UDMnemonicCode = LibUDis86::UDMnemonicCode
end

bytes = [0x90, 0x90, 0xC3]

ud = UDis86::UD.new
ud.mode = 64
ud.syntax = :att
ud.input_callback = ->(ud : UDis86::UD) {
  unless bytes.empty?
    bytes.shift
  else
    -1
  end
}

puts typeof(ud.operands)

ud.disassemble do |ud|
  puts ud.to_asm
end
