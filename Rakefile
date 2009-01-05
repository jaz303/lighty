task :dump_manifest do
  files = Dir["{bin,lib,skel}/**/*"]
  files = files.reject { |f| File.directory?(f) }
  puts '"' + files.join('","') + '"'
end
