#!/usr/bin/perl
use warnings;
use strict;
use lib './com/portoreports/LoopRefiner/FileManager/';
use lib './com/portoreports/LoopRefiner/Model';
use lib './com/portoreports/LoopRefiner/MODELLER/';
use lib './com/portoreports/';
use FileManager;
use MODELLER;
use Async;
use ModelFactory;

package LoopRefiner;
use parent 'Object';

my $notImproved=0;

# Constructor
sub new{
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    $self->setFileManager(FileManager->new());
    $self->setModelFactory(ModelFactory->new());
    return $self;
}

#"Public" Getters and Setters
sub getPrefix{
    my $self=shift;
    if(exists($self->{prefix})){
        return $self->{prefix};
    }else{
        return "MyModel";
    }
}
sub setPrefix{
    my $self=shift;
    my ($prefix)=@_;
    $self->{prefix}=$prefix;
}
sub getTargetScore{
    my $self=shift;
    return $self->{targetScore};
}
sub setTargetScore{
    my $self=shift;
    my ($targetScore)=@_;
    $self->{targetScore}=$targetScore;
}
sub getPDB{
    my $self=shift;
    return $self->{pdb};
}
sub setPDB{
    my $self=shift;
    my ($pdb)=@_;
    $self->{pdb}=$pdb;
}
sub getMethod{
    my $self=shift;    
    return $self->{method};
}
sub setMethod{
    my $self=shift;    
    my ($method)=@_;
    $self->{method}=$method;
}
sub getWindow{
    my $self=shift;    
    if($self->{window}%2==0){
        return $self->{window}/2;
    }
    return ($self->{window}-1)/2;
}
sub setWindow{
    my $self=shift;   
    my ($window)=@_;
    $self->{window}=$window;
}
sub getModellerVersion{
    my $self=shift;    
    return $self->{modellerVersion};
}
sub setModellerVersion{
    my $self=shift;
    my ($modellerVersion)=@_;
    $self->{modellerVersion}=$modellerVersion;    
}
sub getTotalModels{
    my $self=shift;
    return $self->{totalModels};
}
sub setTotalModels{
    my $self=shift;    
    my ($totalModels)=@_;
    $self->{totalModels}=$totalModels;
}
sub setIteration{
    my $self=shift;
    my ($iteration)=@_;
    $self->{iteration}=$iteration;
}
sub getIteration{
    my $self=shift;
    if(exists($self->{iteration})){
        return $self->{iteration};
    }else{
        return 0;
    }
}
sub setEmail{
    my $self=shift;
    my ($email)=@_;
    $self->{email}=$email;
}
sub getEmail{
    my $self=shift;
    return $self->{email};
}
#"Private "Getters and Setters
sub getModel{
    my $self=shift;
    return $self->{model};
}
sub setModel{
    my $self=shift;
    my ($model)=@_;
    $self->{model}=$model;
}
sub getFileManager{
    my $self=shift;
    return $self->{FileManager};
}
sub setFileManager{
    my $self=shift;
    my ($FileManager)=@_;
    $self->{FileManager}=$FileManager;
}
sub getRefModels{
    my $self=shift;
    return $self->{refModels};
}
sub setRefModels{
    my $self=shift;
    my ($refModels)=@_;
    $self->{refModels}=$refModels;
}
sub setModelFactory{
    my $self=shift;
    my ($factory)=@_;
    $self->{ModelFactory}=$factory;
}
sub getModelFactory{
    my $self=shift;
    return $self->{ModelFactory};
}
#Facade Functions
sub reset{
    my $self=shift;
    my $fm=$self->getFileManager();
    if($fm->list("tmp*")){
        $fm->remove("tmp.*");
    }
}

sub load{
    my $self=shift;
    print "loading...\n";
    if(-e "tmp.lrsr"){
        $self->reset();
    }
    $self->setModel(
        $self->getModelFactory->create(
            $self->getPDB(),$self->getMethod(),$self->getEmail()
        )
    );
    $self->getModel()->submit();
    print $self->getModel->toString;
}

sub init{
    my $self=shift;
    print "running...\n";
    while($self->getModel->getScore() < $self->getTargetScore()){
        foreach(@{$self->getModel->getResidues}){
            my $start=($_-$self->getWindow<1)?1:$_-$self->getWindow;
            my $end=($_+4>$self->getModel->getLength)?$self->getModel->getLength:$_+$self->getWindow;
            print "refining interval $start-$end\n";
            $self->refine($start,$end);
            print "assessing models\n";
            $self->assess();
            $self->compare();
            $self->reset();
        }
    }
    print $self->getModel->toString;
}

sub refine{
    my $self=shift;
    my ($start,$end)=@_;
    my $ref=MODELLER->new(
        version=>$self->getModellerVersion(),
        start=>$start,
        end=>$end,
        structure=>$self->getModel->getModel(),
        totalModels=>$self->getTotalModels()
    );
    my $AsyncRefinement=Async->new(
        sub{
            $ref->refine();
        }
    );
    sleep 5;
}

sub assess{
    my $self=shift;
    my $cont=1;
    my @refModels=();
    my $wait=1;
    while($self->getTotalModels()!=$cont-1){
        my $currentFile="tmp.BL".(sprintf '%04s',$cont)."0001.pdb";
        if(-e $currentFile){#Only submits if the next model is ready or the refinement is complete
            sleep 10;
            print "Running QMEAN for $currentFile\n";
            push(@refModels,
                $self->getModelFactory->create(
                    $currentFile,
                    $self->getMethod(),
                    $self->getEmail(),
                )
            );
            if($refModels[$cont-1]->submit()){
                $cont++;
                $wait=1;
            }else{
                print "Please verify your internet connection and try again.\n";
                exit;
            }
        }else{#Waits 10 seconds to recheck
            if($wait){
                print "waiting for $currentFile\n";
                sleep 10;
                $wait=0;
            }	
        }
    }
    $self->setRefModels(\@refModels);
}

sub compare{
    my $self=shift;
    $notImproved++;
    foreach (@{$self->getRefModels()}){
        if($_->higherThan($self->getModel())){
            $notImproved=0;
            $self->setModel($_);
            $self->setIteration($self->getIteration()+1);
            print "\n\nnew best score: ".$_->getScore."\n\n\n";
            
            $self->getFileManager->rename($self->getModel->getModel(),$self->getPrefix().$self->getIteration().".pdb");
            $self->getModel->setModel($self->getPrefix().$self->getIteration().".pdb");
            sleep 5;
        }
        if($notImproved==scalar(@{$self->getModel->getResidues})){
            $self->setTotalModels($self->getTotalModels+10);
        }
    }
}

1;
