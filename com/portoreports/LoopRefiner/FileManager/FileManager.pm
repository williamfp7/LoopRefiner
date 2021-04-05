#!/usr/bin/perl
use warnings;
use strict;
use lib "./com/portoreports/";

package FileManager;
use parent "Object";

sub remove{
    my $self=shift;
    my ($str)=@_;
    my $cmd="rm ".$str;
    return $self->evalCmd($cmd);
}

sub rename{
    my $self=shift;
    my ($str1,$str2)=@_;
    my $cmd="mv ".$str1." ".$str2;
    return $self->evalCmd($cmd);
}

sub list{
    my $self=shift;
    my ($str)=@_;
    my $cmd="ls ".$str;
    return $self->evalCmd($cmd);  
}

sub evalCmd{
    my $self=shift;
    my ($cmd)=@_;
    eval {qx($cmd)};
    if(!$@){
        return 1;
    }
    return 0;  
}
1;