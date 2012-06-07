#!/usr/bin/ruby -w
require 'net/http'

#module PDB
  # Returns a PDB record for the given id
  def self.get_record id
    Net::HTTP.get_response('scop.berkeley.edu', "/astral/pdbstyle/?id=#{id}&output=html").body
  end
#end

if ARGV.length < 1
  print "need at least 1 SCOP ID\n"
end

print "retrieving:\n"

ARGV.each do |id|
  #id = ARGV[-1]
  print "  #{id}\n"
  pdbFile = File.open("#{id}.pdb","w")
  pdbFile.puts get_record(id)
  pdbFile.close
end

exit
