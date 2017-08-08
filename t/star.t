use Test2::V0 -no_srand => 1;
BEGIN { $ENV{FFI_CHECKLIB_TEST_OS} = 'linux' }
use FFI::CheckLib;

$FFI::CheckLib::system_path = [];

my @libs = find_lib(
  libpath   => File::Spec->catdir( 'corpus', 'unix', 'foo-1.00'  ),
  lib       => '*',
  recursive => 1,
);

is scalar(@libs), 3, "libs = @libs";

my @fn = sort map { (File::Spec->splitpath($_))[2] } @libs;
is \@fn, [qw( libbar.so libbaz.so libfoo.so )], "fn = @fn";

done_testing;
