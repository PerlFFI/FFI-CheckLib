package Test2::Plugin::FauxDynaLoader;

use strict;
use warnings;
use Test2::Mock;
use DynaLoader;

our $mock = Test2::Mock->new(
  class => 'DynaLoader',
);

{
  my @libref = ('null');

  $mock->override(dl_load_file => sub {
    my($filename, $flags) = @_;
    return undef unless -e $filename;
    my $libref = scalar @libref;
    $libref[$libref] = TestDLL->new($filename);
    $libref;
  });

  $mock->override(dl_unload_file => sub {
    my($libref) = @_;
    delete $libref[$libref];
  });

  $mock->override(dl_find_symbol => sub {
    my($libref, $symbol) = @_;
    my $lib = $libref[$libref];
    $lib->has_symbol($symbol);
  });
}

package
  TestDLL;

sub new
{
  my($class, $filename) = @_;
  
  my @list = do {
    my $fh;
    open $fh, '<', $filename;
    my @list = <$fh>;
    close $fh;
    @list;
  };
  
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
