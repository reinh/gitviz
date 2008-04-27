module GitViz
  module GitCommands
    class << self
      # Thank you grit
      def git(cmd, *args)
        `git #{cmd} #{args.join(' ')}`.chomp
      end
    
      def valid_ref?(ref)
        not (git "show-ref", ref).empty?
      end
    end
  end
end