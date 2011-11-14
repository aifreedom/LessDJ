#!/usr/bin/env ruby
# generate a build number (123) to xcode project's info.plist file
# by xhan @ 2011-11-13



# USage  script PlistPath version 


plist,version = ARGV[0], ARGV[1]
# puts plist
# puts version

# File.open('/Users/less/Desktop/aaa.txt', "w") {|f| f.puts("hh" + plist + " --- " + version)}


f = File.open(plist, "r").read
re = /([\t ]+<key>CFBundleVersion<\/key>\n[\t ]+<string>)(.*?)(<\/string>)/
f =~ re

# Get the version info from the source Info.plist file
# If the script has already been run we need to remove the git sha
# from the bundle's Info.plist.
open = $1
orig_version = $2
close = $3

# If the git hash has not already been injected into the Info.plist, this will set version to nil
# version = $2.sub!(/\s*git sha [\w]+/, '')
# if (!version)
#   version = orig_version
# end

# Inject the git hash into the bundle's Info.plist
sub = "#{open}#{version}#{close}"
# puts sub
f.gsub!(re, sub)
File.open(plist, "w") { |file| file.write(f) }
