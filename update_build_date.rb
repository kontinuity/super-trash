#!/usr/bin/ruby

file = 'build/Release/SuperTrash.app/Contents/Info.plist'

t = Time.now
tm_build_date = t.strftime("%m%d%Y")

buffer = File.new(file,'r').read.gsub(/\$TM_BUILD_DATE/,tm_build_date)
File.open(file,'w') {|fw| fw.write(buffer)}

puts "TM Build Date successfully updated to #{tm_build_date}"
