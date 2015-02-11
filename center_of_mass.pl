#! /usr/bin/perl

# Compute center-of-mass of an object from STL file.
# See here for explanation:
#   http://stackoverflow.com/questions/2083771/a-method-to-calculate-the-centre-of-mass-from-a-stl-stereo-lithography-file

use strict;
use warnings;

sub read_stl {
  my ($file) = @_;
  open F, '<', $file
      or die "Could not open file '$file' : $!\n";

  my $M = [ ];
  my $t;

  while (<F>) {
    chomp;
    if (/facet normal ([^ ]+) ([^ ]+) ([^ ]+)/) {
      my ($x, $y, $z) = ($1, $2, $3);
      $t = { N => [$x, $y, $z] };
    } elsif (/vertex ([^ ]+) ([^ ]+) ([^ ]+)/) {
      my ($x, $y, $z) = ($1, $2, $3);
      if (!exists($t->{A})) {
        $t->{A} = [$x, $y, $z];
      } elsif (!exists($t->{B})) {
        $t->{B} = [$x, $y, $z];
      } else {
        $t->{C} = [$x, $y, $z];
        push @$M, $t;
        undef $t;
      }
    }
  }
  return $M;
}


sub center_of_mass {
  my ($M) = @_;

  my $tot_vol = 0;
  my $cx = 0;
  my $cy = 0;
  my $cz = 0;

  for my $t (@$M) {
    my ($x1, $y1, $z1) = @{$t->{A}};
    my ($x2, $y2, $z2) = @{$t->{B}};
    my ($x3, $y3, $z3) = @{$t->{C}};
    my $d = $x1*$y2*$z3 - $x1*$y3*$z2 - $x2*$y1*$z3 + $x2*$y3*$z1 + $x3*$y1*$z2 - $x3*$y2*$z1;
    my $vol = $d/6;

    $cx += ($x1 + $x2 + $x3)/4*$vol;
    $cy += ($y1 + $y2 + $y3)/4*$vol;
    $cz += ($z1 + $z2 + $z3)/4*$vol;
    $tot_vol += $vol;
  }

  return ($cx/$tot_vol, $cy/$tot_vol, $cz/$tot_vol, $tot_vol);
}


my $M = read_stl($ARGV[0]);

print "Number of faces: ", scalar(@$M), "\n";

my ($x, $y, $z, $v) = center_of_mass($M);

print "Volume: $v\n";
print "Center-of-mass: ($x, $y, $z)\n";
