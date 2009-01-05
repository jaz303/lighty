task :dump_manifest do
  files = Dir["{bin,lib,skel}/**/*"]
  files = files.reject { |f| File.directory?(f) }
  puts '"' + files.join('","') + '"'
end

task :clean do
  `sudo gem uninstall lighty`
  `rm -f lighty-*.gem`
end

task :rebuild => :clean do
  `gem build lighty.gemspec`
  `sudo gem install lighty-0.1.1.gem`
end