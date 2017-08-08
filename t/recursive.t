use Test2::V0 -no_srand => 1;
BEGIN { $ENV{FFI_CHECKLIB_TEST_OS} = 'linux' }
use FFI::CheckLib;

$FFI::CheckLib::system_path = [];

my @libs = find_lib(
  libpath   => File::Spec->catdir( 'corpus', 'unix', 'foo-1.00'  ),
  lib       => 'foo',
  recursive => 1,
);

is scalar(@libs), 1, "libs = @libs";
like $libs[0], qr{libfoo.so}, "libs[0] = $libs[0]";

done_testing;
