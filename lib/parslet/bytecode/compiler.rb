require 'parslet/atoms/visitor'

module Parslet::Bytecode
  class Compiler
    def initialize
      @buffer = []
    end
    
    class Address
      attr_reader :address
      def initialize(address=nil)
        @address
      end
      def resolve(vm)
        @address = vm.buffer_pointer
      end
    end
    
    def compile(atom)
      atom.accept(self)
      @buffer
    end
    def add(instruction)
      @buffer << instruction
    end
    
    def fwd_address
      Address.new
    end
    def buffer_pointer
      @buffer.size
    end
    
    def visit_str(str)
      add Match.new(str)
    end
    def visit_sequence(parslets)
      parslets.each do |atom|
        atom.accept(self)
      end
      add PackSequence.new(parslets.size)
    end
    def visit_alternative(alternatives)
      adr_end = fwd_address
      
      alternatives.each_with_index do |alternative, idx|
        alternative.accept(self)
        add BranchOnSuccess.new(adr_end)
      end
      
      adr_end.resolve(self)
    end
  end
end