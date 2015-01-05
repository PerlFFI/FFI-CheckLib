# FFI::CheckLib

Check that a library is available for FFI

# SYNOPSIS

    use FFI::CheckLib;
    
    check_lib_or_exit( lib => 'jpeg', symbol => 'jinit_memory_mgr' );
    check_lib_or_exit( lib => [ 'iconv', 'jpeg' ] );
    
    # or prompt for path to library and then:
    print "where to find jpeg library: ";
    my $path = <STDIN>;
    check_lib_or_exit( lib => 'jpeg', libpath => $path );

# DESCRIPTION

This module checks whether a particular dynamic library is available for FFI to use.
It is modeled heavily on [Devel::CheckLib](https://metacpan.org/pod/Devel::CheckLib), but will find dynamic libraries
even when development packages are not installed.  It also provides a 
[find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib) function that will return the full path to
the found dynamic library, which can be feed directly into [FFI::Raw](https://metacpan.org/pod/FFI::Raw).

Although intended mainly for FFI modules via [FFI::Raw](https://metacpan.org/pod/FFI::Raw) and similar, this module
does not actually use any FFI to do its detection and probing.  This module does
not have any non-core dependencies other than [Module::Build](https://metacpan.org/pod/Module::Build) on Perl 5.20 and
more recent.

# FUNCTIONS

All of these take the same named parameters and are exported by default.

## find\_lib

This will return a list of dynamic libraries, or empty list if none were found.

### lib

Must be either a string with the name of a single library or a reference to an array
of strings of library names.  Depending on your platform, `CheckLib` will prepend
`lib` or append `.dll` or `.so` when searching.

### libpath

A string or array of additional paths to search for libraries.

### symbol

A string or a list of symbol names that must be found.

### verify

A code reference used to verify a library really is the one that you want.  It 
should take two arguments, which is the name of the library and the full path to the
library pathname.  It should return true if it is acceptable, and false otherwise.  
You can use this in conjunction with [FFI::Raw](https://metacpan.org/pod/FFI::Raw) to determine if it is going to meet
your needs.  Example:

    use FFI::CheckLib;
    use FFI::Raw;
    
    my($lib) = find_lib(
      name => 'foo',
      verify => sub {
        my($name, $libpath) = @_;
        
        my $new = FFI::Raw->new(
          $lib, 'foo_new',
          FFI::Raw::ptr,
        );
        
        my $delete = FFI::Raw->new(
          $lib, 'foo_delete',
          FFI::Raw::void,
          FFI::Raw::ptr,
        );
        
        # return true if new returns
        # a pointer, not forgetting
        # to free it on success.
        my $ptr = $new->call();
        return 0 unless $ptr;
        $delete->call();
        return 1;
      },
    );

## assert\_lib

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that instead of returning empty list of failure it throws
an exception.

## check\_lib\_or\_exit

This behaves exactly the same as [assert\_lib](https://metacpan.org/pod/FFI::CheckLib#assert_lib),
except that instead of dying, it warns (with exactly the same error message)
and exists.  This is intended for use in `Makefile.PL` or `Build.PL`

## check\_lib

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib), except that
it returns true (1) on finding the appropriate libraries or false (0) otherwise.

# SEE ALSO

- [FFI::Raw](https://metacpan.org/pod/FFI::Raw)

    Call library functions dynamically without a compiler.

- [Dist::Zilla::Plugin::FFI::CheckLib](https://metacpan.org/pod/Dist::Zilla::Plugin::FFI::CheckLib)

    [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin for this module.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
