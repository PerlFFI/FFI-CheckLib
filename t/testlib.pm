package
  FFI::Raw;

use strict;
use warnings;
use constant void => '::void::';

$INC{'FFI/Raw.pm'} = __FILE__;

sub new
{
  my($class, $filename, $symbol, $ret) = @_;
  my $dll = TestDLL->new($filename);
  die "not found" unless $dll->has_symbol($symbol);
  bless {}, $class;
}

package
  TestDLL;

sub new
{
  my($class, $filename) = @_;
  
  my $fh;
  open $fh, '<', $filename;
  my @list = <$fh>;
  close $fh;
  
  chomp @list;
  
  my $name = shift @list;
  my $version = shift @list;
  my %symbols = map { $_ => 1 } @list;
  
  bless {
    filename => $filename,
    name     => $name,
    version  => $version,
    symbols  => \%symbols,
  }, $class;
}

sub filename { shift->{filename} }
sub name { shift->{name} }
sub version { shift->{version} }
sub has_symbol { $_[0]->{symbols}->{$_[1]} }

1;
