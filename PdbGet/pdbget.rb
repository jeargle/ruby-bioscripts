#!/usr/bin/ruby -w
require 'net/http'

#module PDB
  # Returns a PDB record for the given id
  def self.get_record id
    Net::HTTP.get_response('www.rcsb.org', "/pdb/files/#{id}.pdb").body
  end
#end

if ARGV.length != 1
  print "need exactly 1 PDBID\n"
end

id = ARGV[-1]
pdbFile = File.open("#{id}.pdb","w")
pdbFile.puts get_record(id)
pdbFile.close

exit
