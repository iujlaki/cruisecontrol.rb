require 'singleton'
require 'fileutils'

class BuilderStarter

  include FileUtils
  
  @@run_builders_at_startup = true;
  
  def self.run_builders_at_startup=(value)
    @@run_builders_at_startup = value
  end

  def self.start_builders(verbose = false)
    if @@run_builders_at_startup
      Projects.load_all.each do |project|
        begin_builder(project.name, verbose)
      end
    end
  end
  
  def self.begin_builder(project_name, verbose)
    verbose_option = verbose ? "--trace" : ""
    if Platform.family == 'mswin32'
      Thread.new(project_name) { |my_project_name| system("cruise.cmd build #{project_name} #{verbose_option}") }
    else
      pid = fork || exec("#{RAILS_ROOT}/cruise build #{project_name} #{verbose_option}")
      project_pid_location = "#{RAILS_ROOT}/tmp/pids/builders"
      FileUtils.mkdir_p project_pid_location
      File.open("#{project_pid_location}/#{project_name}.pid", "w") {|f| f.write pid }
    end
  end
  
end