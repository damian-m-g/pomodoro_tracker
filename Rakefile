#necessary for minitest tests
require 'rake/testtask'

#################TASKS#######################

#to execute minitest tests with `rake test`
Rake::TestTask.new do |t|
  #search recursively under the folder test for files called test*. You may have to create the folder manually.
  t.pattern = 'test/**/test*.rb'
end

desc 'to generate RDoc documentation'
task :rdoc do
  system('rdoc --all --tab-width=1 --force-output --main="ReadMe.md" --exclude="bin" --exclude="data" --exclude="ext" --exclude="share" --exclude="doc" --exclude="test" --exclude="cocot.gemspec" --exclude="Gemfile" --exclude="Gemfile.lock" --exclude="Rakefile"')
end

desc 'ocra --no-lzma(testing purpose)'
task :ocra_no_lzma, :version do |t, args|
  args.with_defaults(:version => '')
  system("ocra --chdir-first --no-lzma --icon './data/icon.ico' --output 'Pomodoro Tracker #{args[:version].!=('') ? "#{args[:version]}" : ''}.exe' './bin/pomodoro_tracker' './lib/**/*' './data/**/*.png' './ext/**/*'")
end

desc 'ocra'
task :ocra, :version do |t, args|
  args.with_defaults(:version => '')
  system("ocra --chdir-first --windows --icon './data/icon.ico' --output 'Pomodoro Tracker #{args[:version].!=('') ? "#{args[:version]}" : ''}.exe' './bin/pomodoro_tracker' './lib/**/*' './data/**/*.png' './ext/**/*'")
end

desc 'erase persisted data'
task :erase_persistence do
  # dropbox pd
  to_dropbox_pd = "#{ENV['HOME']}/Dropbox/pd.pt".gsub('\\', '/')
  if(File.exists?(to_dropbox_pd))
    File.delete(to_dropbox_pd)
  end
  # program data pd
  to_program_data_pd = "#{ENV['ProgramData'] || ENV['ALLUSERSPROFILE']}/Pomodoro Tracker/pd.pt".gsub('\\', '/')
  if(File.exists?(to_program_data_pd))
    File.delete(to_program_data_pd)
  end
end