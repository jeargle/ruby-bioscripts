#!/usr/bin/ruby -w

# autoNamdRun.rb
# John Eargle - 1 June 2009

def printUsageMessage()

  print "Check the last NAMD log file in a directory to make sure the run either completed\n"
  print "successfully or died after all necessary restart files were written.  Then restart\n"
  print "the run or print an error message.\n"
  print "  autoNamdRun.rb <configFile>\n"
  print "    <configFile> - file listing all NAMD jobs to check\n"

  return
end


# Read necessary information from the previous log file
def digestPrevLogFile(logFileName)
  
  lastTimestep = 0
  # get ending step
  #   keep looking until a valid ending is found
  logTail = `tail -n 20 #{logFileName}`
  #print logTail
  
  logLines = logTail.split("\n")
  logLines.each do |line|
    #print "--- #{line}\n"
    if line =~ /WRITING VELOCITIES TO OUTPUT FILE AT STEP (\d*)/ then
      lastTimestep = $1
      #print "last timestep: #{lastTimestep}\n"
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
    
    #print line
    outfile.print line
  end
  
  template.close
  outfile.close

  return outFileName
end


# Check log file for successful or unsuccessful completion
def logCheck(logfile)

  numLines = 20
  maxNumLines = 1280
  
  # Use tail to get last lines of logfile
  logfileTail = `tail -n #{numLines} #{logfile}`
  
  #print "logfileTail: #{logfileTail}\n"

  print "  logfile: #{logfile}\n"

  logStatus = logCheckPerfect(logfileTail)
  if logStatus == "perfect" then
    print "PERFECT\n"
    return logStatus
  end

  while numLines <= maxNumLines do

    print "  numLines: #{numLines}\n"
    logStatus = logCheckUsable(logfileTail)
    if logStatus == "usable" then
      print "USABLE\n"
      return logStatus
    elsif logStatus == "broken" then
      print "BROKEN\n"
      return logStatus
    end

    # Exponentially increase the tail segment until all restart files are found
    numLines *= 2
    logfileTail = `tail -n #{numLines} #{logfile}`
  end
  
  print "UNKNOWN\n"
  return "unknown"
    
end


# Check log file for perfect completion
def logCheckPerfect(logfileTail)

  lastFrame = -1
  currentFrame = -1
  fileStatus = Hash["wroteVel" => false,
    "closedCoor" => false,
    "wroteCoor" => false,
    "closedXsc" => false,
    "wroteXsc" => false,
    "finishedRestartVel" => false,
    "wroteRestartVel" => false,
    "wroteRestartXsc" => false,
    "finishedRestartCoor" => false,
    "wroteRestartCoor" => false,
    "wroteDcd" => false]

  # Use tail to get last lines of logfile
  #print "logfileTail: #{logfileTail}\n"
  tailList = logfileTail.split("\n").reverse

  # Check for completed case
  tailList.each do |i|
    #print "#{i}\n"
    if i =~ /WRITING VELOCITIES TO OUTPUT FILE AT STEP (\d+)/ then
      #print "  wroteVel\n"
      fileStatus["wroteVel"] = true
      currentFrame = $1.to_i
    elsif i =~ /CLOSING COORDINATE DCD FILE/ then
      #print "  closedCoor\n"
      fileStatus["closedCoor"] = true
    elsif i =~ /WRITING COORDINATES TO OUTPUT FILE AT STEP (\d+)/ then
      #print "  wroteCoor\n"
      fileStatus["wroteCoor"] = true
      currentFrame = $1.to_i
    elsif i =~ /CLOSING EXTENDED SYSTEM TRAJECTORY FILE/ then
      #print "  closedXsc\n"
      fileStatus["closedXsc"] = true
    elsif i =~ /WRITING EXTENDED SYSTEM TO OUTPUT FILE AT STEP (\d+)/ then
      #print "  wroteXsc\n"
      fileStatus["wroteXsc"] = true
      currentFrame = $1.to_i
    elsif i =~ /FINISHED WRITING RESTART VELOCITIES/ then
      #print "  finishedRestartVel\n"
      fileStatus["finishedRestartVel"] = true
    elsif i =~ /WRITING VELOCITIES TO RESTART FILE AT STEP (\d+)/ then
      #print "  wroteRestartVel\n"
      fileStatus["wroteRestartVel"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING EXTENDED SYSTEM TO RESTART FILE AT STEP (\d+)/ then
      #print "  wroteRestartXsc\n"
      fileStatus["wroteRestartXsc"] = true
      currentFrame = $1.to_i
    elsif i =~ /FINISHED WRITING RESTART COORDINATES/ then
      #print "  finishedRestartCoor\n"
      fileStatus["finishedRestartCoor"] = true
    elsif i =~ /WRITING COORDINATES TO RESTART FILE AT STEP (\d+)/ then
      #print "  wroteRestartCoor\n"
      fileStatus["wroteRestartCoor"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING COORDINATES TO DCD FILE AT STEP (\d+)/ then
      #print "  wroteDcd\n"
      fileStatus["wroteDcd"] = true
      currentFrame = $1.to_i
    end

    if (lastFrame < 0) & (currentFrame > 0) then
      lastFrame = currentFrame
    elsif lastFrame != currentFrame then
      print "  lastFrame: #{lastFrame}\n"
      print "  currentFrame: #{currentFrame}\n"
      return "broken"
    end

    fileStatusCount = 0
    fileStatus.each_value do |i|
      if i then
        fileStatusCount += 1
      end
    end

    if fileStatusCount == 11 then
      print "  last frame: #{lastFrame}\n"
      return "perfect"
    end
  end

  return "unknown"
end


# Check log file for imperfect, but usable completion
def logCheckUsable(logfileTail)

  lastFrame = -1
  currentFrame = -1
  fileStatus = Hash["finishedRestartVel" => false,
    "wroteRestartVel" => false,
    "wroteRestartXsc" => false,
    "finishedRestartCoor" => false,
    "wroteRestartCoor" => false,
    "wroteDcd" => false]
  
  # Use tail to get last lines of logfile  
  #print "logfileTail: #{logfileTail}\n"
  tailList = logfileTail.split("\n").reverse

  # Grab the last set of written restart files
  tailList.each do |i|
    if i =~ /FINISHED WRITING RESTART VELOCITIES/ then
      #print "  finishedRestartVel\n"
      fileStatus["finishedRestartVel"] = true
    elsif i =~ /WRITING VELOCITIES TO RESTART FILE AT STEP (\d+)/ then
      #print "  wroteRestartVel\n"
      fileStatus["wroteRestartVel"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING EXTENDED SYSTEM TO RESTART FILE AT STEP (\d+)/ then
      #print "  wroteRestartXsc\n"
      fileStatus["wroteRestartXsc"] = true
      currentFrame = $1.to_i
    elsif i =~ /FINISHED WRITING RESTART COORDINATES/ then
      #print "  finishedRestartCoor\n"
      fileStatus["finishedRestartCoor"] = true
    elsif i =~ /WRITING COORDINATES TO RESTART FILE AT STEP (\d+)/ then
      #print "  wroteRestartCoor\n"
      fileStatus["wroteRestartCoor"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING COORDINATES TO DCD FILE AT STEP (\d+)/ then
      #print "  wroteDcd\n"
      fileStatus["wroteDcd"] = true
      currentFrame = $1.to_i
    end
  
    if (lastFrame < 0) & (currentFrame > 0) then
      lastFrame = currentFrame
    elsif lastFrame != currentFrame then
      print "  missing\n"
      fileStatus.each_pair do |key,val|
        if !val then
          print "    #{key}\n"
        end
      end
      print "  currentFrame: #{currentFrame}\n"
      print "  lastFrame: #{lastFrame}\n"
      return "broken"
    end

    fileStatusCount = 0
    fileStatus.each_value do |i|
      if i then
        fileStatusCount += 1
      end
    end

    if fileStatusCount == 6 then
      print "  last frame: #{lastFrame}\n"
      return "usable"
    end
  end
  
  return "unknown"
end


# Return the name of the log file for the last round of the given simulation
def findLastLogfile (runName,logDir)

  runNamePrefix = ""
  runNameSuffix = ""
  lastRunNum = 0

  if runName =~ /(.*)RUNNUM(.*)/ then
    runNamePrefix = $1
    runNameSuffix = $2
  end

  logfiles = `ls #{logDir}*log`.split("\n")

  logfiles.each do |filename|
    if filename =~ /#{runNamePrefix}(\d+)#{runNameSuffix}/ then
      runNum = $1.to_i
      if runNum > lastRunNum then
        lastRunNum = runNum
      end
    end
  end

  return "#{runNamePrefix}#{lastRunNum}#{runNameSuffix}"
end


################
# Main Program #
################

if ARGV.length == 1
  configFileName = ARGV[0]
else
  printUsageMessage
  exit
end

configFile = File.open(configFileName,"r")
configFile.each_line do |line|
  runParams = line.split(" ")
  logDir = runParams[0]
  print "  logDir: #{logDir}\n"
  runName = runParams[1]
  print "  runName: #{runName}\n"
  numSteps = runParams[2].to_i
  print "  numSteps: #{numSteps}\n"
  numProcs = runParams[3]
  print "  numProcs: #{numProcs}\n"
  lastLogfile = findLastLogfile(runName,logDir)
  print "  lastLogfile: #{lastLogfile}\n"
  Dir.chdir(logDir) do
    logStatus = logCheck(lastLogfile)
    print "  logStatus: #{logStatus}\n"
    print "\n"
    if logStatus == "perfect" then
      nextConfigfile = writeConfigFile("template.namd",lastLogfile,numSteps)
      nextConfigfile =~ /(.*)namd/
      nextLogfile = $1 + "log"
      print "> namd2-IB #{nextConfigfile} #{nextLogfile} #{numProcs}\n"
    else
      print "ERROR: failed to create NAMD config file\n"
    end
    print "\n"
  end

end

exit 0
