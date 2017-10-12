use lib 't/lib';
use Test2::V0 -no_srand => 1;
use Test2::Mock;
use Test2::Plugin::FauxOS 'linux';
use FFI::CheckLib qw( find_lib which );

subtest 'recursive' => sub {

  $FFI::CheckLib::system_path = [];

  my @libs = find_lib(
    libpath   => File::Spec->catdir( 'corpus', 'unix', 'foo-1.00'  ),
    lib       => 'foo',
    recursive => 1,
  );

  is scalar(@libs), 1, "libs = @libs";
  like $libs[0], qr{libfoo.so}, "libs[0] = $libs[0]";
};

subtest 'star' => sub {

  $FFI::CheckLib::system_path = [];

  my @libs = find_lib(
    libpath   => File::Spec->catdir( 'corpus', 'unix', 'foo-1.00'  ), 
    lib       => '*',
    recursive => 1,
  );

  is scalar(@libs), 3, "libs = @libs";

  my @fn = sort map { (File::Spec->splitpath($_))[2] } @libs;
  is \@fn, [qw( libbar.so libbaz.so libfoo.so )], "fn = @fn";

};

subtest 'which' => sub {

  my %find_lib_args;

  my $mock = Test2::Mock->new(
    class => 'FFI::CheckLib',
    override => [
      find_lib => sub {
        %find_lib_args = @_;
        my @ret = qw( /usr/lib/libfoo.so.1.2.3 /usr/lib/libbar.so.1.2.3 );
        wantarray ? @ret : $ret[0];
      },
    ],
  );

  is( which('foo'), '/usr/lib/libfoo.so.1.2.3' );
  is(
    \%find_lib_args,
    hash {
      field 'lib' => 'foo';
      end;
    }
  );

};

done_testing;
