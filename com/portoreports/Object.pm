#!/usr/bin/perl
use warnings;
use strict;

package Object;

sub new{
    my $class=shift;
    my ($self)={@_};
    bless $self,$class;
    return $self;
}

sub toString{
    my $self=shift;
    return $self;
}

sub equals{
    my $self=shift;
    my ($obj)=@_;
    if($self==$obj){
        return 1;
    }else{
        return 0;
    }
}
1;