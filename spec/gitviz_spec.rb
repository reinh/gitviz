require File.dirname(__FILE__) + '/spec_helper.rb'

class Git; include GitViz::GitCommands; end

describe GitViz::GitCommands do
  before(:each) do
    @g = Git.new
  end
  describe "git command" do
    it "gets the git version" do
      GitViz::GitCommands.git(:version).should =~ /^git version [\d\.a-z]*$/
    end
  end
end

describe GitViz::Digraph do
  describe "initialized with a valid reference" do  
    before(:each) do
      GitViz::GitCommands.should_receive(:valid_ref?).and_return(true)
      @d = GitViz::Digraph.new
      @log_string = "<123456><abcdef fedcba>"
      @heads_parents = [["123456", ["abcdef", "fedcba"]]]
    end
    
    it "has a pretty inspect" do
      @d.inspect.should == %Q{#<GitViz::Digraph "ref: master">}
    end
  
    it "takes heads and their parents from the log" do
      GitViz::GitCommands.should_receive(:git).with(:log, "master", "--pretty=format:\"<%h><%p>\"").and_return(@log_string)
      @d.send(:heads_parents).should == @heads_parents
    end
  
    it "creates a dot graph from the heads and their parents" do
      @d.should_receive(:heads_parents).and_return(@heads_parents)
    
      @d.to_dot_graph.should == "digraph {\n\trankdir=TB;\n\t\"123456\" -> \"abcdef\";\n\t\"123456\" -> \"fedcba\";\n};\n"
    end
  end
  
  describe "initialized with an invalid reference" do
    before(:each) do
      GitViz::GitCommands.should_receive(:valid_ref?).and_return(false)
    end
    it "raises an error" do
      initializing_invalid_digraph = lambda { GitViz::Digraph.new("invalid")}
      
      initializing_invalid_digraph.should raise_error(GitViz::InvalidGitRefError)
    end
  end
end
