#!/usr/bin/perl
use warnings;
use strict;
use lib "com/portoreports/LoopRefiner/";
use LoopRefiner;

my $a=LoopRefiner->new(
    method=>"QMEAN",
    targetScore=>-2,
    pdb=>"model.pdb",
    window=>9,
    modellerVersion=>'10.1',
    totalModels=>100,
    #Optional settings
    #prefix=>"MyModel",
    iteration=>1,
    email=>'youremail@yourserver.com'
);

$a->load();
$a->init();
