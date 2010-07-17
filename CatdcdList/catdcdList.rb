#!/usr/bin/ruby -w

# John Eargle - 21 Aug 08
#   use catdcd to stitch many dcd files together;
#   dcd filenames are listed in a separate file


def catdcdList(dcdListFileName, outFileName, stepSize)

  dcdListFile = File.open(dcdListFileName, "r")
  fileList = ""
  dcdListFile.each_line do |line|
    fileList += line.chomp + " "
  end
  dcdListFile.close

  #print "catdcd -o #{outFileName} -stride #{stepSize} #{fileList}"
  output = `catdcd -o #{outFileName} -stride #{stepSize} #{fileList}`
  print output
  return
end


def printUsageMessage()

  print "usage -- catdcdList.rb <dcdListFileName> <outFileName> <stepSize>\n"
  print "  <dcdListFileName> - file with all the dcd filenames\n"
  print "  <outFileName>     - name of final, combined dcd file\n"
  print "  <stepSize>        - passed to catdcd\n"

  return
end


# Main Program

if ARGV.length != 3
  printUsageMessage
  exit
end

dcdListFileName = ARGV[-3]
outFileName = ARGV[-2]
stepSize = ARGV[-1]

catdcdList(dcdListFileName, outFileName, stepSize)
