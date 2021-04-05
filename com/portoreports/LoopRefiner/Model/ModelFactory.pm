#!/usr/bin/perl
use warnings;
use strict;
use lib './com/portoreports/LoopRefiner/QMEAN';
use lib './com/portoreports/LoopRefiner/Model';
use lib './com/portoreports/';
use Model;
use QMEAN;

package ModelFactory;
use parent 'Object';

sub create{
    my $self=shift;
    my ($model,$method,$email)=@_;
    if($method eq "QMEAN"){
        $method=QMEAN->new(email=>$email);
    }else{
        die "Unknown method\n";
    }
    $model=Model->new(model=>$model,method=>$method);
    return $model;
}

1;