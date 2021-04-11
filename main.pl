#!/usr/bin/perl
use warnings;
use strict;
use lib "com/portoreports/LoopRefiner/";
use LoopRefiner;

my $a=LoopRefiner->new(
    method=>"QMEAN",    #Only QMEAN is available at the moment
    targetScore=>-2,    #The threshold to reach
    pdb=>"model.pdb",   #The initial model
    window=>9,          #The window lengh to be refined (e.g. if the target is the 15th residue, the window starts at 11th and ends at 19th residue)
    modellerVersion=>'10.1', #The modeller version
    totalModels=>100,   #The total models to perform for each round of refinement; it exhausted, the value is incremented by 10 on next iteration
    #Optional settings
    #prefix=>"MyModel", #The prefix of the saved models
    iteration=>1,       #The number of current best model
    email=>'youremail@yourserver.com' #Your e-mail
);

$a->load();
$a->init();
