#!/usr/bin/env perl

use strict;
use warnings;

use List::MoreUtils qw/ uniq /;
use Term::ANSIColor;
use constant GREEN => 'green';
use constant RED   => 'red';

my %CONF;

@ARGV = sort @ARGV;

sub process_line {
  my ($line, $conf_file) = @_;
  chomp $line;

  return if substr($line, 0, 1) eq '#';    # ignore comments
  return unless $line;                     # ignore empty lines

  my ($key, $val) = split '=', $line;
  $CONF{$key}->{$conf_file} = $val;
}

for my $file (@ARGV) {
  open my $fh, '<', $file or die "could not open $file";
  process_line $_, $file while <$fh>;
}

printf "KEY\t%s\n", join "\t", @ARGV;
for my $key (sort keys %CONF) {
  my @values = map { $CONF{$key}->{$_} } @ARGV;

  my $equal = 1;
  $equal = @ARGV == grep { defined $_ } @values;    # empty values
  $equal = $equal && @ARGV != uniq @values;         # diff values

  print colored [$equal ? GREEN : RED], join("\t", $key, map { $_ || 'NULL' } @values), "\n";
}
