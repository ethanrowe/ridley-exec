module RidleyExec
	module CLI
		def self.run args
			api, target = Configuration.resolve_args(args)
			Runner.run_target(api, target)
		end
	end
end
