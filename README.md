ruby-bioscripts
===============

Bunch of small scripts for messing around with biology data files.


AutoNamdConfig
--------------

autoNamdConfig.rb
~~~~~~~~~~~~~~~~~

Write the next NAMD config file in an ongoing sequence.

autoNamdRun.rb
~~~~~~~~~~~~~~

Check the last NAMD log file in a directory to make sure the run either completed
successfully or died after all necessary restart files were written. Then,
restart the run or print an error message.


CatdcdList
----------


NamdLogCheck
------------


NucleicMutate
-------------


PdbGet
------

Retrieve a PDB file for a given ID.


PdbMod
------

Read in a PDB file and renumber its residue IDs sequentially starting with 1.
