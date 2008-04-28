module GitViz
  class Digraph
    def initialize(ref = "master", options = {})
      raise GitViz::InvalidGitRefError.new("\"#{ref}\" is not a valid ref") unless GitViz::GitCommands::valid_ref?(ref)
      @ref = ref
      @options = options
    end
    attr_reader :ref
    
    def to_dot_graph
      str = digraph_head
      
      heads_parents.each do |head, parents|
        parents.each do |parent|
          str << digraph_edge(head, parent)
        end
      end
      
      str << digraph_foot
    end
    alias_method :to_s, :to_dot_graph
    
    # Pretty object inspection
    def inspect
      %Q{#<GitViz::Digraph "ref: #{ref}">}
    end
    
    private
    
    def rankdir
      @options[:rankdir] || "TB"
    end
    
    def limit
      @options[:limit]
    end
    
    # TODO: tail log output instead of slicing array
    def heads_parents
      heads_parents_log = GitViz::GitCommands::git :log, @ref, "--pretty=format:\"<%h><%p>\""
      heads_parents = heads_parents_log.map{|line| line.scan(/^<(.*?)><(.*?)>/).flatten}
      heads_parents = heads_parents.map{|head, parents| [head, parents.split(' ')]}
      heads_parents = heads_parents.first(limit) if limit
      heads_parents
    end
    
    def digraph_head
      "digraph {\n\trankdir=#{rankdir};\n"
    end
    
    def digraph_foot
      "};\n"
    end
    
    def digraph_edge(to, from)
      "\t\"#{to}\" -> \"#{from}\";\n"
    end
  end

end