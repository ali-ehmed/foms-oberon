module MyClass
	def speak_with_block(&block)
	  block.call
	end

	def speak_with_yield
	  yield
	end

	module_function :speak_with_block, :speak_with_yield
end