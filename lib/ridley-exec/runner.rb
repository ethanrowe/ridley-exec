module RidleyExec
  module Runner

		class Context
			attr_reader :api, :parameters

			def initialize(api, args)
				@api = api
				@parameters = args
			end

			def run(&target)
				instance_eval { target.call(binding) }
			end
		end

    def self.run_target(api, target, args)
			Context.new(api, args).run(&target)
      0
    end
  end
end
