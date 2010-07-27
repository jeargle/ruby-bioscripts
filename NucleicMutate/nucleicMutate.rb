#!/usr/bin/ruby -w

# John Eargle - 5 Apr 06
#   create the initial PDB and "mutate" psfgen commands to
#   mutate one nucleic acid structure into another


def validateArgs()
  
  return true
end


def printUsageMessage()

  print "usage -- nucleicMutate <fastaFile> <pdbFile>\n"
  print "  <fastaFile> - FASTA file with two aligned nucleic acid sequences\n"
  print "  <pdbFile>   - PDB file with structure for first sequence\n"

  return
end


def mutatePrep(nuc1, nuc2, pdbString)

  if (nuc1 == nuc2)
    print "Error: trying to mutate from " + nuc1 + " to " + nuc2 + "\n"
  end

  mutateString = ""

  if (nuc1 == "C" && nuc2 == "A" ||
      nuc1 == "C" && nuc2 == "G" ||
      nuc1 == "U" && nuc2 == "A" ||
      nuc1 == "U" && nuc2 == "G")

    mutateStrings = pdbString.split(/\n/)
    mutateStrings.each do |string|
      if (string =~ /(P|O1P|O2P|C1\*|C2\*|C3\*|C4\*|C5\*|O2\*|O3\*|O4\*|O5\*)/)
	mutateString += string + "\n"
      elsif (string =~ /N9/)
	mutateString += string.gsub(/N9/,"N1") + "\n"
      elsif (string =~ /C4/)
	mutateString += string.gsub(/C4/,"C2") + "\n"
      elsif (string =~ /C8/)
	mutateString += string.gsub(/C8/,"C6") + "\n"
      end
    end
  elsif (nuc1 == "A" && nuc2 == "C" ||
	 nuc1 == "A" && nuc2 == "U" ||
	 nuc1 == "G" && nuc2 == "C" ||
	 nuc1 == "G" && nuc2 == "U")
    mutateStrings = pdbString.split(/\n/)
    mutateStrings.each do |string|
      if (string =~ /(P|O1P|O2P|C1\*|C2\*|C3\*|C4\*|C5\*|O2\*|O3\*|O4\*|O5\*)/)
	mutateString += string + "\n"
      elsif (string =~ /N1/)
	mutateString += string.gsub(/N1/,"N9") + "\n"
      elsif (string =~ /C2/)
	mutateString += string.gsub(/C2/,"C4") + "\n"
      elsif (string =~ /C6/)
	mutateString += string.gsub(/C6/,"C8") + "\n"
      end
    end
  else
    mutateString = pdbString
  end

  return mutateString
end



# Main Program

if ARGV.length != 2
  printUsageMessage
  exit
end

fastaFileName = ARGV[-2]
pdbFileName = ARGV[-1]

outFileName = ""

if outFileName == ""
  outFileName = pdbFileName + ".new"
end

print "fastaFileName: #{fastaFileName}\n"
print "pdbFileName: #{pdbFileName}\n"
print "outFileName: #{outFileName}\n"

if (!validateArgs)
  print "ERROR -- invalid command-line parameter\n"
  printUsageMessage
  exit
end


# Read in 2 aligned FASTA sequences
fastaFile = File.open(fastaFileName, "r")
seqs = Array.new(2,"")
seqCount = -1

print "seqs[0]: " << seqs[0] << "\n"
print "seqs[1]: " << seqs[1] << "\n"

fastaFile.each_line {|line|
  if (line =~ /^\>/)
    seqCount += 1
  else
    if (seqCount < 0)
      print "Error: FASTA file does not start with a valid sequence line\n"
    else
      seqs[seqCount] += line.chomp
    end
  end
}

fastaFile.close

print "seqs[0]: " << seqs[0] << "\n"
print "seqs[1]: " << seqs[1] << "\n"

# Read PDB file and write new PDB file with some atom names changed and some atoms deleted
pdbFile = File.new(pdbFileName, "r")
outFile = File.new(outFileName, "w")
resid = 0
columnNum = 0
tempString = ""
firstTimeThrough = true

pdbFile.each_line {|line|
  #if (line =~ /^ATOM *\D+ *.* +[ACGU] /)
  #if (line =~ /^ATOM/ &&
      #line.slice(17..19) =~ /(A  | A |  A|C  | C |  C|G  | G |  G|U  | U |  U)/)
  if (line =~ /^ATOM/)
    if (firstTimeThrough)
      resid = line.slice(22..25).to_i
      while (seqs[0][columnNum,1] == "-" || seqs[1][columnNum,1] == "-")
	columnNum += 1
      end
      tempString = line
      firstTimeThrough = false
    elsif (line.slice(17..19) !~ /(A  | A |  A|C  | C |  C|G  | G |  G|U  | U |  U)/)
      if (tempString != "")
	if (seqs[0][columnNum,1] != seqs[1][columnNum,1])
	  nucString = ""
	  if (seqs[0][columnNum,1] == "A")
	    nucString = "ADE"
	  elsif (seqs[0][columnNum,1] == "C")
	    nucString = "CYT"
	  elsif (seqs[0][columnNum,1] == "G")
	    nucString = "GUA"
	  elsif (seqs[0][columnNum,1] == "U")
	    nucString = "URA"
	  end
	  print "mutate " + resid.to_s + " " + nucString + "\n"
	  outFile.print mutatePrep(seqs[0][columnNum,1], seqs[1][columnNum,1], tempString)
	else
	  outFile.print tempString
	end
	columnNum += 1
	while (seqs[0][columnNum,1] == "-" || seqs[1][columnNum,1] == "-")
	  columnNum += 1
	end
	resid = line.slice(22..25).to_i
	tempString = ""
      end
      outFile.print line
    elsif (resid == line.slice(22..25).to_i)
      tempString += line
    else
      if (seqs[0][columnNum,1] != seqs[1][columnNum,1])
	nucString = ""
	if (seqs[0][columnNum,1] == "A")
	  nucString = "ADE"
	elsif (seqs[0][columnNum,1] == "C")
	  nucString = "CYT"
	elsif (seqs[0][columnNum,1] == "G")
	  nucString = "GUA"
	elsif (seqs[0][columnNum,1] == "U")
	  nucString = "URA"
	end
	print "mutate " + resid.to_s + " " + nucString + "\n"
	outFile.print mutatePrep(seqs[0][columnNum,1], seqs[1][columnNum,1], tempString)
      else
	outFile.print tempString
      end
      columnNum += 1
      while (seqs[0][columnNum,1] == "-" || seqs[1][columnNum,1] == "-")
	columnNum += 1
      end
      resid = line.slice(22..25).to_i
      tempString = line
    end
  else
    print line
    outFile.print line
  end
}

pdbFile.close
outFile.close

exit
