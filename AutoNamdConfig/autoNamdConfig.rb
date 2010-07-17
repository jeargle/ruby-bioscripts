#!/usr/bin/ruby -w

# autoNamdConfig.rb
#   write the next namd config file in an ongoing sequence



# Read necessary information from the previous log file
def digestPrevLogFile(logFileName)
  
  lastTimestep = 0
  # get ending step
  #   keep looking until a valid ending is found
  logTail = `tail -n 20 #{logFileName}`
  print logTail
  
  logLines = logTail.split("\n")
  logLines.each do |line|
    print "--- #{line}\n"
    if line =~ /WRITING VELOCITIES TO OUTPUT FILE AT STEP (\d*)/ then
      lastTimestep = $1
      print "last timestep: #{lastTimestep}\n"
    end
  end
  
  # check to see whether the job completed correctly or not
  
  return lastTimestep
end


# Read template file while writing the output config file
#   writeConfigFile(templateFileName,previousRunNum,lastTimestep)
def writeConfigFile(templateFileName, previousLogFileName, numRunSteps)
  # template file name - specific for the given system
  month = Hash[0 => "January",
	    1 => "February",
	    2 => "March",
	    3 => "April",
	    4 => "May",
	    5 => "June",
	    6 => "July",
	    7 => "August",
	    8 => "September",
	    9 => "October",
	    10 => "November",
	    11 => "December"]

  day = Time.now.day
  monthNum = Time.now.month
  year = Time.now.year
  date = "#{month[monthNum]} #{day}, #{year}"

  previousRunNum = 0
  if previousLogFileName =~ /eq(\d+)/ then
    previousRunNum = $1.to_i
  end
  currentRunNum = previousRunNum + 1

  lastTimestep = digestPrevLogFile(previousLogFileName).to_i
  nextTimestep = lastTimestep + numRunSteps
  
  outFileName = previousLogFileName
  outFileName = outFileName.gsub(/\.log/,".namd")
  outFileName = outFileName.gsub(/eq#{previousRunNum}/,"eq#{currentRunNum}")
  
  #template = File.open(templateFileName,"r") || die "Cannot open $templateFileName: $!"
  #outfile = File.open(outFileName,"w") || die "Cannot open $outFileName: $!"
  if !File.readable?(templateFileName) then
    print "Error: writeConfigFile - no \n"
    return
  end
  template = File.open(templateFileName,"r")
  outfile = File.open(outFileName,"w") 
  template.each_line do |line|
    line = line.gsub(/DATE/,date)
    line = line.gsub(/PREVRUN/,previousRunNum.to_s)
    line = line.gsub(/CURRRUN/,currentRunNum.to_s)
    line = line.gsub(/PREVTIMESTEP/,lastTimestep.to_s)
    line = line.gsub(/NEXTTIMESTEP/,nextTimestep.to_s)
    
    print line
    outfile.print line
  end
  
  template.close
  outfile.close

  return
end


########
# Main #
########

templateConfigFile = ""
previousLogFile = ""
numRunSteps = 5000000

# Read command line arguments
if ARGV[0] && ARGV[1] then
  templateConfigFile = ARGV[0]
  previousLogFile = ARGV[1]
else 
  print("Usage: autoNamdConfig.pl templateConfigFile previousLogFile [numRunSteps]\n")
  print("   templateConfigFile - the master namd config file that defines\n")
  print("      how all namd config files should look\n")
  print("   previousLogFile - the latest namd log file\n")
  print("   numRunSteps - number of simulation steps added to the config file;\n")
  print("      default 5,000,000\n")
  exit
end

if ARGV[2] then
  numRunSteps = ARGV[2].to_i
end

writeConfigFile(templateConfigFile,previousLogFile,numRunSteps)

exit 0
