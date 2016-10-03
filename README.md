# ruby-bioscripts

Bunch of small scripts for messing around with biology data files.

## AutoNamdConfig

### autoNamdConfig.rb

Write the next NAMD config file in an ongoing sequence.

### autoNamdRun.rb

Check the last NAMD log file in a directory to make sure the run either completed
successfully or died after all necessary restart files were written. Then,
restart the run or print an error message.

## CatdcdList

### catdcdList.rb

Use catdcd to stitch many DCD files together.  DCD filenames are listed in a separate files.  Uses stepSize parameter to set the stride.

### catdcdIndexList.rb

Use catdcd to stitch many DCD files together.  DCD filenames are listed in a separate files. Uses indexFileName to specify indices of atoms to include in the final trajectory.

## NamdLogCheck

Check all NAMD log files in a directory to make sure the runs either completed successfully or died after all necessary restart files were written.

## NucleicMutate

Create the initial PDB file and psfgen "mutate" commands to mutate one nucleic acid structure into another.

## PdbGet

### pdbget.rb

Retrieve the PDB file for a given ID.

### scopget.rb

Retrieve the SCOP PDB file for a given SCOP ID.

## PdbMod

Read in a PDB file and renumber its residue IDs sequentially starting with 1.
