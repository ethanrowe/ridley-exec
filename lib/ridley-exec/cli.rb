module RidleyExec
	module CLI
		def self.run args
			api, target, params = Configuration.resolve_args(args)
			Runner.run_target(api, target, params)
		end
	end
end
