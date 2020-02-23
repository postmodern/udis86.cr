# udis86.cr

* [Source](http://github.com/postmodern/crystal-udis86/)
* [Issue](http://github.com/postmodern/crystal-udis86/)

Crystal bindings for [libudis86]. Inspired by the Ruby [ffi-udis86] gem.

## Installation

1. Install libudis86:

   * Debian / Ubuntu

         ????

   * RedHat / Fedora:

         $ sudo apt install udis86-devel

   * Brew:

         $ brew install udis86

2. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     udis86:
       github: postmodern/udis86.cr
   ```

3. Run `shards install`

## Examples

Create a new disassembler:

```crystal
require "udis86"

ud = UDis86::UD.create(syntax: :att, mode: 64)
```

Set the input buffer:

```crystal
ud.input_buffer = "\x90\x90\xc3"
```

Add an input callback:

```crystal
ud.input_callback { |ud| ops.shift? || -1 }
```

Read from a file:

```crystal
UD.open(path) do |ud|
  ...
end
```

Disassemble and print instructions:

```crystal
ud.disas do |insn|
  puts insn
end
```

Disassemble and print information about the instruction and operands:

```crystal
asm = "\x75\x62\x48\x83\xc4\x20\x5b\xc3\x48\x8d\x0d\x23\x0c\x01\x00\x49\x89\xf0"
    
ud = FFI::UDis86::UD.create(
  buffer: asm,
  mode: 64,
  vendor: :amd,
  syntax: :att
)
    
ud.disas do |insn|
  puts insn
  puts "  * Offset: #{insn.insn_offset}"
  puts "  * Length: #{insn.insn_length}"
  puts "  * Mnemonic: #{insn.mnemonic}"
    
  operands = insn.operands.reverse.map do |operand|
    if operand.is_mem?
      ptr = [operand.base]
      ptr << operand.index if operand.index
      ptr << operand.scale if operand.scale
    
      "Memory Access (#{ptr.join(',')})"
    elsif operand.is_imm?     ; "Immediate Data"
    elsif operand.is_jmp_imm? ; "Relative Offset"
    elsif operand.is_const?   ; "Constant"
    elsif operand.is_reg?     ; "Register (#{operand.reg})"
    end
  end
    
  puts "  * Operands: " + operands.join(" -> ")
end
```

## Contributing

1. Fork it (<https://github.com/postmodern/udis86/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Postmodern](https://github.com/postmodern) - creator and maintainer

[libudis86]: http://udis86.sourceforge.net/
[ffi-udis86]: https://github.com/sophsec/ffi-udis86#readme)
