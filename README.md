# FFI::CheckLib ![linux](https://github.com/PerlFFI/FFI-CheckLib/workflows/linux/badge.svg) ![macos](https://github.com/PerlFFI/FFI-CheckLib/workflows/macos/badge.svg) ![cygwin](https://github.com/PerlFFI/FFI-CheckLib/workflows/cygwin/badge.svg)

Check that a library is available for FFI

# SYNOPSIS

```perl
use FFI::CheckLib;

check_lib_or_exit( lib => 'jpeg', symbol => 'jinit_memory_mgr' );
check_lib_or_exit( lib => [ 'iconv', 'jpeg' ] );

# or prompt for path to library and then:
print "where to find jpeg library: ";
my $path = <STDIN>;
check_lib_or_exit( lib => 'jpeg', libpath => $path );
```

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

```perl
my(@libs) = find_lib(%args);
```

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

    ```perl
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
    ```

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

    An example is libyaml on Red Hat based Linux distributions.  On Debian
    these are handled with symlinks and no trickery is required.

- alien

    \[version 0.25\]

    If no libraries can be found, try the given aliens instead.  The Alien
    classes specified must provide the [Alien::Base](https://metacpan.org/pod/Alien::Base) interface for dynamic
    libraries, which is to say they should provide a method called
    `dynamic_libs` that returns a list of dynamic libraries.

## assert\_lib

```
assert_lib(%args);
```

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that instead of returning empty list of failure it throws an
exception.

## check\_lib\_or\_exit

```
check_lib_or_exit(%args);
```

This behaves exactly the same as [assert\_lib](https://metacpan.org/pod/FFI::CheckLib#assert_lib),
except that instead of dying, it warns (with exactly the same error
message) and exists.  This is intended for use in `Makefile.PL` or
`Build.PL`

## find\_lib\_or\_exit

\[version 0.05\]

```perl
my(@libs) = find_lib_or_exit(%args);
```

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that if the library is not found, it will call exit with an
appropriate diagnostic.

## find\_lib\_or\_die

\[version 0.06\]

```perl
my(@libs) = find_lib_or_die(%args);
```

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that if the library is not found, it will die with an appropriate
diagnostic.

## check\_lib

```perl
my $bool = check_lib(%args);
```

This behaves exactly the same as [find\_lib](https://metacpan.org/pod/FFI::CheckLib#find_lib),
except that it returns true (1) on finding the appropriate libraries or
false (0) otherwise.

## which

\[version 0.17\]

```perl
my $path = where($name);
```

Return the path to the first library that matches the given name.

Not exported by default.

## where

\[version 0.17\]

```perl
my @paths = where($name);
```

Return the paths to all the libraries that match the given name.

Not exported by default.

## has\_symbols

\[version 0.17\]

```perl
my $bool = has_symbols($path, @symbol_names);
```

Returns true if _all_ of the symbols can be found in the dynamic library located
at the given path.  Can be useful in conjunction with `verify` with `find_lib`
above.

Not exported by default.

## system\_path

\[version 0.20\]

```perl
my $path = FFI::CheckLib::system_path;
```

Returns the system path as a list reference.  On some systems, this is `PATH`
on others it might be `LD_LIBRARY_PATH` on still others it could be something
completely different.  So although you _may_ add items to this list, you should
probably do some careful consideration before you do so.

This function is not exportable, even on request.

# FAQ

- Why not just use `dlopen`?

    Calling `dlopen` on a library name and then `dlclose` immediately can tell
    you if you have the exact name of a library available on a system.  It does
    have a number of drawbacks as well.

    - No absolute or relative path

        It only tells you that the library is _somewhere_ on the system, not having
        the absolute or relative path makes it harder to generate useful diagnostics.

    - POSIX only

        This doesn't work on non-POSIX systems like Microsoft Windows. If you are
        using a POSIX emulation layer on Windows that provides `dlopen`, like
        Cygwin, there are a number of gotchas there as well.  Having a layer written
        in Perl handles this means that developers on Unix can develop FFI that will
        more likely work on these platforms without special casing them.

    - inconsistent implementations

        Even on POSIX systems you have inconsistent implementations.  OpenBSD for
        example don't usually include symlinks for `.so` files meaning you need
        to know the exact `.so` version.

    - non-system directories

        By default `dlopen` only works for libraries in the system paths.  Most
        platforms have a way of configuring the search for different non-system
        paths, but none of them are portable, and are usually discouraged anyway.
        [Alien](https://metacpan.org/pod/Alien) and friends need to do searches for dynamic libraries in
        non-system directories for `share` installs.

- My 64-bit Perl is misconfigured and has 32-bit libraries in its search path.  Is that a bug in [FFI::CheckLib](https://metacpan.org/pod/FFI::CheckLib)?

    Nope.

- The way [FFI::CheckLib](https://metacpan.org/pod/FFI::CheckLib) is implemented it won't work on AIX, HP-UX, OpenVMS or Plan 9.

    I know for a fact that it doesn't work on AIX _as currently implemented_
    because I used to develop on AIX in the early 2000s, and I am aware of some
    of the technical challenges.  There are probably other systems that it won't
    work on.  I would love to add support for these platforms.  Realistically
    these platforms have a tiny market share, and absent patches from users or
    the companies that own these operating systems (patches welcome), or hardware
    / CPU time donations, these platforms are unsupportable anyway.

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

Petr Pisar (ppisar)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014-2018 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
