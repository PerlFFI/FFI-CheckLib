# FFI::CheckLib

Check that a library is available for FFI

# SYNOPSIS

    use FFI::CheckLib::FFI;
    
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

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
