begin
  require 'spec/rake/spectask'
rescue LoadError
  task :spec do
    $stderr.puts '`gem install rspec` to run specs'
  end
else
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(--color)
  end
end

