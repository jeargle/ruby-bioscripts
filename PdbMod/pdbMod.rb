#!/usr/bin/ruby -w

# John Eargle - 11 Dec 07
#   read in a PDB file and renumber its residue IDs

def padLine(lineCount)
  lineStr = lineCount.to_s
  padLength = 4 - lineStr.length
  padStr = " " * padLength
  return padStr + lineStr
end


if ARGV.length == 0
  print "  Read in a PDB file and renumber its residue IDs sequentially starting with 1.\n"
  print "usage -- pdbMod <infile> <outfile>\n"
  print "  <infile>  - the PDB file to read in\n"
  print "  <outfile> - the new PDB file\n"
  exit
end

inFileName = ARGV[0]
outFileName = ARGV[1]

print "inFileName: #{inFileName}\n"
print "outFileName: #{outFileName}\n"

inFile = File.open(inFileName, "r")
outFile = File.new(outFileName, "w")

lineCount = 0
currentResId = -1

inFile.each_line {|line|
  if (line =~ /^ATOM/)
    #print "Hey" + line
    print "currentResId " + currentResId.to_s + "\n"
    print "  " + line.slice(22..25) + "\n"
    if (line.slice(22..25).to_i != currentResId)
      currentResId = line.slice(22..25).to_i
      lineCount += 1
    end
    if (lineCount == 10000)
      lineCount = 1
    end
    outFile.print line.slice(0..21) + padLine(lineCount) + line.slice(26..-1)
  else
    #print "Yo " + line
  end
}

inFile.close
outFile.close

#return
