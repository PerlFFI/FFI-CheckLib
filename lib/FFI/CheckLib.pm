package FFI::CheckLib;

use strict;
use warnings;
use v5.10;
use File::Spec;
use Carp qw( croak );
use base qw( Exporter );

our @EXPORT = qw( find_lib assert_lib check_lib check_lib_or_exit );

# ABSTRACT: Check that a library is available for FFI
# VERSION

=head1 SYNOPSIS

  use FFI::CheckLib::FFI;
  
  check_lib_or_exit( lib => 'jpeg', symbol => 'jinit_memory_mgr' );
  check_lib_or_exit( lib => [ 'iconv', 'jpeg' ] );
  
  # or prompt for path to library and then:
  print "where to find jpeg library: ";
  my $path = <STDIN>;
  check_lib_or_exit( lib => 'jpeg', libpath => $path );

=head1 DESCRIPTION

This module checks whether a particular dynamic library is available for FFI to use.
It is modeled heavily on L<Devel::CheckLib>, but will find dynamic libraries
even when development packages are not installed.  It also provides a 
L<find_lib|FFI::CheckLib#find_lib> function that will return the full path to
the found dynamic library, which can be feed directly into L<FFI::Raw>.

=cut

our $system_path;

if($^O eq 'MSWin32')
{
  $system_path = eval q{
    use Env qw( @PATH );
    \\@PATH;
  }; die $@ if $@;
}
else
{
  $system_path = eval q{
    require DynaLoader;
    \\@DynaLoader::dl_library_path;
  }; die $@ if $@;
}

our $pattern = [ qr{^lib(.*?)\.so.*$} ];

if($^O eq 'cygwin')
{
  push @$pattern, qr{^cyg(.*?)(?:-[0-9]+)?\.dll$};
}
elsif($^O eq 'MSWin32')
{
  $pattern = [ qr{^(?:lib)?(.*?)(?:-[0-9]+)?\.dll$} ];
}
elsif($^O eq 'darwin')
{
  push @$pattern, qr{^lib(.*?)\.dylib$};
}

sub _matches
{
  my($filename, $path) = @_;
  foreach my $regex (@$pattern)
  {
    return [ $1, File::Spec->catfile($path, $filename) ] if $filename =~ $regex;
  }
  return ();
}

=head1 FUNCTIONS

All of these take the same named parameters and are exported by default.

=head2 find_lib

This will return a list of dynamic libraries, or empty list if none were found.

=head3 lib

Must be either a string with the name of a single library or a reference to an array
of strings of library names.  Depending on your platform, C<CheckLib> will prepend
C<lib> or append C<.dll> or C<.so> when searching.

=head3 libpath

A string or array of additional paths to search for libraries.

=head3 symbol

A string or a list of symbol names that must be found.

=cut

sub find_lib
{
  my(%args) = @_;
  
  croak "find_lib requires lib argument" unless defined $args{lib};

  # make arguments be lists.
  foreach my $arg (qw( lib libpath symbol ))
  {
    next if ref $args{$arg};
    if(defined $args{$arg})
    {
      $args{$arg} = [ $args{$arg} ];
    }
    else
    {
      $args{$arg} = [];
    }
  }
  
  my %missing = map { $_ => 1 } @{ $args{lib} };
  my %symbols = map { $_ => 1 } @{ $args{symbol} };
  my @path = (@{ $args{libpath} }, @$system_path);
  my @found;

  foreach my $path (@path)
  {
    next unless -d $path;
    my $dh;
    opendir $dh, $path;
    my @maybe = 
      # prefer non-symlinks
      sort { -l $a->[1] <=> -l $b->[1] }
      # filter out the items that do not match
      # the name that we are looking for
      grep { $missing{$_->[0]} }
      # get [ name, full_path ] mapping,
      # each entry is a 2 element list ref
      map { _matches($_,$path) } 
      # read all files from the directory
      readdir $dh;
    closedir $dh;
    
    # TODO: the FFI::Sweet implementation
    # has some aggresive techniques for
    # finding .dlls from .a files that may
    # be worth adopting.
    
    foreach my $lib (@maybe)
    {
      next unless delete $missing{$lib->[0]};
      
      foreach my $symbol (keys %symbols)
      {
        next unless eval q{
          use FFI::Raw;
          FFI::Raw->new($lib->[1], $symbol, FFI::Raw::void);
          1;
        };
        delete $symbols{$symbol};
      }
      
      push @found, $lib->[1];
    }    
  }
  
  %symbols ? () : @found;
}

=head2 assert_lib

This behaves exactly the same as L<find_lib|FFI::CheckLib#find_lib>,
except that instead of returning empty list of failure it throws
an exception.

=cut

sub assert_lib
{
  die 'library not found' unless check_lib(@_);
}

=head2 check_lib_or_exit

This behaves exactly the same as L<assert_lib|FFI::CheckLib#assert_lib>,
except that instead of dying, it warns (with exactly the same error message)
and exists.  This is intended for use in C<Makefile.PL> or C<Build.PL>

=cut

sub check_lib_or_exit
{
  unless(check_lib(@_))
  {
    # TODO: could probably work on
    # diagnostics
    warn "library not found";
    exit;
  }
}

=head2 check_lib

This behaves exactly the same as L<find_lib|FFI::CheckLib#find_lib>, except that
it returns true (1) on finding the appropriate libraries or false (0) otherwise.

=cut

sub check_lib
{
  find_lib(@_) ? 1 : 0;
}

1;
