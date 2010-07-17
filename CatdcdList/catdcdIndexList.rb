#!/usr/bin/ruby -w

# John Eargle - 21 Aug 08
#   use catdcd to stitch many dcd files together;
#   dcd filenames are listed in a separate file


def catdcdList(dcdListFileName, outFileName, indexFileName)

  dcdListFile = File.open(dcdListFileName, "r")
  fileList = ""
  dcdListFile.each_line do |line|
    fileList += line.chomp + " "
  end
  dcdListFile.close

  #print "catdcd -i #{indexFileName} -o #{outFileName} #{fileList}"
  `catdcd -i #{indexFileName} -o #{outFileName} #{fileList}`
end


def printUsageMessage()

  print "usage -- catdcdList.rb <dcdListFileName> <outFileName> <stepSize>\n"
  print "  <dcdListFileName> - file with all the dcd filenames\n"
  print "  <outFileName>     - name of final, combined dcd file\n"
  print "  <indexFileName>   - passed to catdcd\n"

  return
end


# Main Program

if ARGV.length != 3
  printUsageMessage
  exit
end

dcdListFileName = ARGV[-3]
outFileName = ARGV[-2]
indexFileName = ARGV[-1]

catdcdList(dcdListFileName, outFileName, indexFileName)
