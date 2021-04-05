#!/usr/bin/perl
use warnings;
use strict;
use lib './com/portoreports/';
use lib './com/portoreports/LoopRefiner/QMEAN';


package FakeQMEAN;
use parent "iQMEAN","Object";

sub submit{
    my $self=shift;
    my ($model)=@_;
}

sub getScore{
    my $self=shift;
    my ($model)=@_;
    $model->setScore(-2.0844910139);
}

sub getResidues{
    my $self=shift;
    my ($model)=@_;
    my $res=[266,292,293,327,329,338,339,383,415,419,488,491,526,533,536,556];
    $model->setResidues($res);
}

sub getLength{
    my $self=shift;
    my ($model)=@_;
    my $model->setLength(584);
}
1;
