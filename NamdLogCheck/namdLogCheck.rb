#!/usr/bin/ruby -w

# John Eargle - 6 May 2009
#   read in a NAMD logfile and check to make sure
#   the run either completed successfully or died
#   after all necessary restart files were written


def printUsageMessage()

  print "Check all NAMD log files in a directory to make sure the runs either completed\n"
  print "successfully or died after all necessary restart files were written.\n"
  print "  namdLogCheck.rb <logDir>\n"
  print "    <logDir> - directory with NAMD log files (.log)\n"

  return
end


# Check log file for successful or unsuccessful completion
def namdLogCheck(logfile)

  numLines = 20
  maxNumLines = 1280
  
  # Use tail to get last lines of logfile
  logfileTail = `tail -n #{numLines} #{logfile}`
  
  #print "logfileTail: #{logfileTail}\n"

  print "#{logfile}\n"

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
      print "  wroteVel\n"
      fileStatus["wroteVel"] = true
      currentFrame = $1.to_i
    elsif i =~ /CLOSING COORDINATE DCD FILE/ then
      print "  closedCoor\n"
      fileStatus["closedCoor"] = true
    elsif i =~ /WRITING COORDINATES TO OUTPUT FILE AT STEP (\d+)/ then
      print "  wroteCoor\n"
      fileStatus["wroteCoor"] = true
      currentFrame = $1.to_i
    elsif i =~ /CLOSING EXTENDED SYSTEM TRAJECTORY FILE/ then
      print "  closedXsc\n"
      fileStatus["closedXsc"] = true
    elsif i =~ /WRITING EXTENDED SYSTEM TO OUTPUT FILE AT STEP (\d+)/ then
      print "  wroteXsc\n"
      fileStatus["wroteXsc"] = true
      currentFrame = $1.to_i
    elsif i =~ /FINISHED WRITING RESTART VELOCITIES/ then
      print "  finishedRestartVel\n"
      fileStatus["finishedRestartVel"] = true
    elsif i =~ /WRITING VELOCITIES TO RESTART FILE AT STEP (\d+)/ then
      print "  wroteRestartVel\n"
      fileStatus["wroteRestartVel"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING EXTENDED SYSTEM TO RESTART FILE AT STEP (\d+)/ then
      print "  wroteRestartXsc\n"
      fileStatus["wroteRestartXsc"] = true
      currentFrame = $1.to_i
    elsif i =~ /FINISHED WRITING RESTART COORDINATES/ then
      print "  finishedRestartCoor\n"
      fileStatus["finishedRestartCoor"] = true
    elsif i =~ /WRITING COORDINATES TO RESTART FILE AT STEP (\d+)/ then
      print "  wroteRestartCoor\n"
      fileStatus["wroteRestartCoor"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING COORDINATES TO DCD FILE AT STEP (\d+)/ then
      print "  wroteDcd\n"
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
      print "  finishedRestartVel\n"
      fileStatus["finishedRestartVel"] = true
    elsif i =~ /WRITING VELOCITIES TO RESTART FILE AT STEP (\d+)/ then
      print "  wroteRestartVel\n"
      fileStatus["wroteRestartVel"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING EXTENDED SYSTEM TO RESTART FILE AT STEP (\d+)/ then
      print "  wroteRestartXsc\n"
      fileStatus["wroteRestartXsc"] = true
      currentFrame = $1.to_i
    elsif i =~ /FINISHED WRITING RESTART COORDINATES/ then
      print "  finishedRestartCoor\n"
      fileStatus["finishedRestartCoor"] = true
    elsif i =~ /WRITING COORDINATES TO RESTART FILE AT STEP (\d+)/ then
      print "  wroteRestartCoor\n"
      fileStatus["wroteRestartCoor"] = true
      currentFrame = $1.to_i
    elsif i =~ /WRITING COORDINATES TO DCD FILE AT STEP (\d+)/ then
      print "  wroteDcd\n"
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



################
# Main Program #
################

if ARGV.length == 1
  logdir = ARGV[0]
else
  printUsageMessage
  exit
end

logResults = Hash["perfect" => 0, "usable" => 0, "unknown" => 0, "broken" => 0]
logfiles = `ls #{logdir}*log`.split("\n")

logfiles.each do |logfile|
  logStatus = logCheck(logfile)
  logResults.each_key do |key|
    if logStatus == key then
      logResults[key] += 1
    end
  end
end

print "\n"
print "LOG RESULTS\n"
totalResults = 0
logResults.each_pair do |key,val|
  print "  #{key}: #{val}\n"
  totalResults += val
end

print "  TOTAL: #{logfiles.length}\n"

if totalResults != logfiles.length then
  print "ERROR: number of log files (#{logfiles.length}) does not agree with number of results (#{totalResults})\n"
end

