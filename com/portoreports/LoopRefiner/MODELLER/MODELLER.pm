#!/usr/bin/perl
use warnings;
use strict;
use lib './com/portoreports/';

package MODELLER;
use parent 'Object';

#"Public" getters and Setters
sub setVersion{
    my $self=shift;
    my ($version)=@_;
    $self->{version}=$version;
}

sub getVersion{
    my $self=shift;
    return $self->{version};
}

sub setStart{
    my $self=shift;
    my ($start)=@_;
    $self->{start}=$start;
}

sub getStart{
    my $self=shift;
    return $self->{start};
}

sub setEnd{
    my $self=shift;
    my ($end)=@_;
    $self->{end}=$end;
}

sub getEnd{
    my $self=shift;
    return $self->{end};
}

sub setStructure{
    my $self=shift;
    my ($structure)=@_;
    $self->{structure}=$structure;
}

sub getStructure{
    my $self=shift;
    return $self->{structure};
}

sub setTotalModels{
    my $self=shift;
    my ($totalModels)=@_;
    $self->{totalModels}=$totalModels;
}

sub getTotalModels{
    my $self=shift;
    return $self->{totalModels};
}

#Class methods

sub getCommand{
    my $self=shift;
    return "mod".$self->getVersion." ./com/portoreports/LoopRefiner/MODELLER/loop.py ".$self->getStart.": ".$self->getEnd.": ".$self->getStructure." ".$self->getTotalModels;
}

sub refine{
    my $self=shift;
    my $cmd=$self->getCommand;
    system($cmd);
}

1;