# FFI::CheckLib [![Build Status](https://secure.travis-ci.org/Perl5-FFI/FFI-CheckLib.png)](http://travis-ci.org/Perl5-FFI/FFI-CheckLib)

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

This module checks whether a particular dynamic library is available for
FFI to use. It is modeled heavily on [Devel::CheckLib](https://metacpan.org/pod/Devel::CheckLib), but will find
dynamic libraries even when development packages are not installed.  It
also provides a [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib) function that will
return the full path to the found dynamic library, which can be feed
directly into [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) or another FFI system.

Although intended mainly for FFI modules via [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) and
similar, this module does not actually use any FFI to do its detection
and probing.  This module does not have any non-core runtime dependencies.
The test suite does depend on [Test2::Suite](https://metacpan.org/pod/Test2::Suite).

# FUNCTIONS

All of these take the same named parameters and are exported by default.

## find\_lib

    my(@libs) = find_lib(%args);

This will return a list of dynamic libraries, or empty list if none were
found.

\[version 0.05\]

If called in scalar context it will return the first library found.

Arguments are key value pairs with these keys:

- lib

    Must be either a string with the name of a single library or a reference
    to an array of strings of library names.  Depending on your platform,
    `CheckLib` will prepend `lib` or append `.dll` or `.so` when
    searching.

    \[version 0.11\]

    As a special case, if `*` is specified then any libs found will match.

- libpath

    A string or array of additional paths to search for libraries.

- systempath

    \[version 0.11\]

    A string or array of system paths to search for instead of letting
    [FFI::CheckLib](https://metacpan.org/pod/FFI::CheckLib) determine the system path.  You can set this to `[]`
    in order to not search _any_ system paths.

- symbol

    A string or a list of symbol names that must be found.

- verify

    A code reference used to verify a library really is the one that you
    want.  It should take two arguments, which is the name of the library
    and the full path to the library pathname.  It should return true if it
    is acceptable, and false otherwise.  You can use this in conjunction
    with [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) to determine if it is going to meet your needs.
    Example:

        use FFI::CheckLib;
        use FFI::Platypus;
        
        my($lib) = find_lib(
          lib => 'foo',
          verify => sub {
            my($name, $libpath) = @_;
            
            my $ffi = FFI::Platypus->new;
            $ffi->lib($libpath);
            
            my $f = $ffi->function('foo_version', [] => 'int');
            
            return $f->call() >= 500; # we accept version 500 or better
          },
        );

- recursive

    \[version 0.11\]

    Recursively search for libraries in any non-system paths (those provided
    via `libpath` above).

- try\_linker\_script

    \[version 0.24\]

    Some vendors provide `.so` files that are linker scripts that point to
    the real binary shared library.  These linker scripts can be used by gcc
    or clang, but are not directly usable by [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) and friends.
    On select platforms, this options will use the linker command (`ld`)
    to attempt to resolve the real `.so` for non-binary files.  Since there
    is extra overhead this is off by default.

    An example is libyaml on RedHat based Linux distributions.  On Debian
    these are handled with symlinks and no trickery is required.

## assert\_lib

    assert_lib(%args);

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that instead of returning empty list of failure it throws an
exception.

## check\_lib\_or\_exit

    check_lib_or_exit(%args);

This behaves exactly the same as [assert\_lib](https://metacpan.org/pod/FFI::CheckLib#assert_lib),
except that instead of dying, it warns (with exactly the same error
message) and exists.  This is intended for use in `Makefile.PL` or
`Build.PL`

## find\_lib\_or\_exit

\[version 0.05\]

    my(@libs) = find_lib_or_exit(%args);

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that if the library is not found, it will call exit with an
appropriate diagnostic.

## find\_lib\_or\_die

\[version 0.06\]

    my(@libs) = find_lib_or_die(%args);

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that if the library is not found, it will die with an appropriate
diagnostic.

## check\_lib

    my $bool = check_lib(%args);

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that it returns true (1) on finding the appropriate libraries or
false (0) otherwise.

## which

\[version 0.17\]

    my $path = where($name);

Return the path to the first library that matches the given name.

Not exported by default.

## where

\[version 0.17\]

    my @paths = where($name);

Return the paths to all the libraries that match the given name.

Not exported by default.

## has\_symbols

\[version 0.17\]

    my $bool = has_symbols($path, @symbol_names);

Returns true if _all_ of the symbols can be found in the dynamic library located
at the given path.  Can be useful in conjunction with `verify` with `find_lib`
above.

Not exported by default.

## system\_path

\[version 0.20\]

    my $path = FFI::CheckLib::system_path;

Returns the system path as a list reference.  On some systems, this is `PATH`
on others it might be `LD_LIBRARY_PATH` on still others it could be something
completely different.  So although you _may_ add items to this list, you should
probably do some careful consideration before you do so.

This function is not exportable, even on request.

# SEE ALSO

- [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)

    Call library functions dynamically without a compiler.

- [Dist::Zilla::Plugin::FFI::CheckLib](https://metacpan.org/pod/Dist::Zilla::Plugin::FFI::CheckLib)

    [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin for this module.

# AUTHOR

Author: Graham Ollis <plicease@cpan.org>

Contributors:

Bakkiaraj Murugesan (bakkiaraj)

Dan Book (grinnz, DBOOK)

Ilya Pavlov (Ilya, ILUX)

Shawn Laffan (SLAFFAN)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014-2018 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
