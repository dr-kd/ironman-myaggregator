#!/usr/bin/perl -w
use strict;
use lib ('../MyAggregator/lib');
use MyAggregator;
use YAML::Syck;
my $agg = MyAggregator->new(context => LoadFile shift);
$agg->run;
