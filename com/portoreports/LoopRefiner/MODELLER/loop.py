import sys
# Loop refinement of an existing model
from modeller import *
from modeller.automodel import *
#from modeller import soap_loop


log.verbose()
env = environ()

# directories for input atom files
env.io.atom_files_directory = ['.', '../atom_files']

# Create a new class based on 'loopmodel' so that we can redefine
# select_loop_atoms (necessary)
class MyLoop(loopmodel):
    # This routine picks the residues to be refined by loop modeling
    def select_loop_atoms(self):
        # One loop from residue 19 to 28 inclusive
        return selection(
                         self.residue_range(sys.argv[1], sys.argv[2]),
                        # self.residue_range('209:', '209:'),
                        # self.residue_range('1:', '1:'),
                        # self.residue_range('351:', '354:'),
                        # self.residue_range('379:', '383:'),
                        # self.residue_range('415:', '417:'),
                         )

m = MyLoop(env,
           inimodel=sys.argv[3],   # initial model of the target
           sequence='tmp')#,                 # code of the target
           #loop_assess_methods=assess.DOPE) # assess loops with DOPE
#          loop_assess_methods=soap_loop.Scorer()) # assess with SOAP-Loop

m.loop.starting_model= 1           # index of the first loop model
m.loop.ending_model  = int(sys.argv[4])         # index of the last loop model
m.loop.md_level = refine.very_fast  # loop refinement method

m.make()
