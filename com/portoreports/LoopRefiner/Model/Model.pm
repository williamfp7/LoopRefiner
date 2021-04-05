#!/usr/bin/perl
use warnings;
use strict;
use LWP::UserAgent;
use lib './com/portoreports/';

package Model;
use parent 'Object';
my $erro=0;

sub new{
    my $class=shift;
    my $self=$class->SUPER::new(@_);
    my $model=$self->{model};
    if(-e $model){
        $self->setModel($model);
        return $self;
    }else{
        die "File ".$model." not found.\n";
    }
}

sub setMethod{
    my $self=shift;
    my ($method)=@_;
    $self->{method}=$method;
}

sub getMethod{
    my $self=shift;
    return $self->{method};
}

sub setModel{
    my $self=shift;
    my ($model)=@_;
    $self->{model}=$model;
}
sub getModel{
    my $self=shift;
    return $self->{model};
}

sub setScore{
    my $self=shift;
    my ($score)=@_;
    $self->{score}=$score;
}

sub getScore{
    my $self=shift;
    if(!exists($self->{score})){
        $self->getMethod()->getScore($self);
    }
    return $self->{score};
}

sub getResidues{
    my $self=shift;
    if(!exists($self->{residues})){
        $self->getMethod()->getResidues($self);
    }
    return $self->{residues};
}

sub setResidues{
    my $self=shift;
    my ($residues)=@_;
    $self->{residues}=$residues;
}

sub getLength{
    my $self=shift;
    if(!exists($self->{length})){
        $self->getMethod()->getLength($self);
    }
    return $self->{length};
}

sub setLength{
    my $self=shift;
    my ($length)=@_;
    $self->{length}=$length;
}

sub submit{
    my $self=shift;
    $self->{method}->submit($self);
}

sub compare{
    my $self=shift;
    my ($model)=@_;
    if($self->getScore()>=$model->getScore()){
        return 1;
    }
    return 0;
}
sub higherThan{
    my $self=shift;
    my ($model)=@_;
    return $self->getScore()>$model->getScore();
}

sub lessThan{
    my $self=shift;
    my ($model)=@_;
    return $self->getScore()<$model->getScore();
}

sub equals{
    my $self=shift;
    my ($model)=@_;
    return $self->getScore()==$model->getScore();
}

sub toString{
    my $self=shift;
    my $str="--------------------------------------\n";
    $str.="Model: ".$self->getModel()."\n";
    $str.="Score: ".$self->getScore()."\n";
    $str.="QMEAN Link: ".$self->getMethod->getLink()."\n";
    $str.="--------------------------------------\n";
    return $str;
}
1;
