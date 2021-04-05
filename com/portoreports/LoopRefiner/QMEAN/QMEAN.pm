#!/usr/bin/perl
use warnings;
use strict;
use LWP::UserAgent;
use JSON;
use Async;
use lib './com/portoreports/';
use lib './com/portoreports/LoopRefiner/QMEAN';

package QMEAN;
use parent 'iQMEAN',"Object";

my $internetFailure=0;

#Constructor
sub new{
    my $class=shift;
    my $self=$class->SUPER::new(@_);
    $self->setJsonParser(JSON->new->allow_nonref);
    $self->setLink(undef);
    $self->setJson(undef);
    return $self;
}

#"Public" Getters and Setters
sub getJson{
    my $self=shift;
    $self->isJsonReady();
    return $self->{json};
}

sub setJson{
    my $self=shift;
    my ($json)=@_;
    $self->{json}=$json;
}

sub getAsyncJson{
    my $self=shift;
    return $self->{asyncJson};
}

sub setAsyncJson{
    my $self=shift;
    my ($asyncJson)=@_;
    return $self->{asyncJson}=$asyncJson;
}

sub setLink{
    my $self=shift;
    my ($link)=@_;
    $self->{link}=$link;
}

sub getLink{
    my $self=shift;
    return $self->{link};
}

sub getJsonParser{
    my $self=shift;
    return $self->{jsonParser};
}
sub setJsonParser{
    my $self=shift;
    my ($jsonParser)=@_;
    $self->{jsonParser}=$jsonParser;
}

sub getEmail{
    my $self=shift;
    return $self->{email};
}

sub setEmail{
    my $self=shift;
    my ($email)=@_;
    $self->{email}=$email;
}
sub getForm{
    my $self=shift;
    my ($model)=@_;
    return [
        'structure'=>[$model->getModel()],
		'email'=>$self->getEmail(),
		'method'=>'qmean'
    ];
}

#Class Methods

sub submit{
    my $self=shift;
    my ($model)=@_;
    
    my $ua = LWP::UserAgent->new;

    my $post=$ua->post(
		"https://swissmodel.expasy.org/qmean/submit/",
		'Content-type'=>"multipart/form-data",
		'Content'=>$self->getForm($model)
	);
	if($post->is_success){
        $internetFailure=0;
		my $json=$post->content;
		$self->setLink($self->getJsonParser()->decode($json)->{"results_json"});
        $self->setAsyncJson(
            Async->new(
                sub{$self->waitJson()}
            )
        );
        return 1;
	}else{
		$internetFailure++;
		if($internetFailure<10){#Se falhar tenta reenviar mais 10x
            sleep 10;
            #print "antigo redo da 116\n";
			return $model->submit();#redo;
		}else{
            die "Internet error, please verify your connection\n";
			return 0;
		}
	}
}

sub getScore{
    my $self=shift;
    my ($model)=@_;
	my $score= eval {$self->getJsonParser()->decode($self->getJson)->{"models"}->{"model_001"}->{"scores"}->{"global_scores"}->{"qmean4_z_score"}};
    if(!$@){
        $model->setScore($score);
    }else{
        $model->submit();
        $model->getScore();
    }
}

sub getResidues{
    my $self=shift;
    my ($model)=@_;
    #print "GETRESIDUES\n";
    my @local_scores=eval{@{$self->getJsonParser()->decode($self->getJson)->{"models"}->{"model_001"}->{"scores"}->{"local_scores"}->{"A"}}};
    if(!$@){
    my @res=();
    for(my $i=0;$i<@local_scores;$i++){
        if($local_scores[$i]<0.6){
            push(@res,($i+1));
        }
    }
    my $res=\@res;
    $model->setResidues($res);
    }else{
        die "Error: cannot load the json file.";
    }
}

sub getLength{
    my $self=shift;
    my ($model)=@_;
    my @local_scores=eval{@{$self->getJsonParser()->decode($self->getJson)->{"models"}->{"model_001"}->{"scores"}->{"local_scores"}->{"A"}}};
    if(!$@){
        $model->setLength(scalar @local_scores);
    }else{
        die "Error: cannot load the json file.";
    }    
}

#Auxiliar Methods
sub isJsonReady{
    my $self=shift;
    while(!$self->getAsyncJson()->ready()){
        if($self->getAsyncJson()->error){
            die 'error: '. $self->getAsyncJson()->error ."\n";
        }else{
            sleep 5;
        }
    }
    $self->setJson($self->getAsyncJson()->result);
}

sub waitJson{
    my $self=shift;
    my $ua = LWP::UserAgent->new;
    my $status="";
    my $get="";
    while($status ne "COMPLETED"){
        $get=$ua->get($self->getLink());
        my $cont=0;
        if($get->is_success){
            $status=$self->getJsonParser()->decode($get->content)->{"status"};
        }else{
            $cont++;
            if($cont<10){#Se falhar tenta requisitar mais 10x
                sleep 5;
                redo;
            }
        }
        sleep 10 if($status ne "COMPLETED");
    }
    return $get->content;
}


1;