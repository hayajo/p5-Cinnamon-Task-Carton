use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception::LessClever;

use Cinnamon::DSL;
use Cinnamon::Task::Carton;
use String::ShellQuote;
use Cwd;

my $host       = 'localhost';
my $carton_cwd = getcwd;

{
    no strict 'refs';
    no warnings 'redefine';
    *Cinnamon::Remote::execute = sub {
        my ( $self, @cmd ) = @_;
        my $opt = shift @cmd;
        +{ stdout => join( ' ', @cmd ) };
    };
}

subtest 'carton_install' => sub {
    my $opts = [qw/--cached --path=extlib/];

    dies_ok { carton_install $carton_cwd, $opts } "die on local";

    remote {
        my ($stdout) = carton_install $carton_cwd, $opts;
        is $stdout,
        # "cd $carton_cwd && carton install " . join( " ", map { shell_quote $_ } @$opts );
        "cd $carton_cwd && carton install --cached '--path=extlib'";
    } $host;
};

subtest 'carton_exec' => sub {
    my $exec_cmd = "bin/myapp --verbose --config=conf/myapp.conf";
    my $libs = [qw{lib extend/lib}];

    dies_ok { carton_exec { run $exec_cmd } $carton_cwd, $libs } "die on local";

    remote {
        my ($stdout) = carton_exec {
            run $exec_cmd;
        } $carton_cwd, $libs;

        my $opts = join( ' ', map { shell_quote("-I$_") } @$libs );
        is $stdout,
           # "cd $carton_cwd && carton exec $opts -- $exec_cmd";
           "cd $carton_cwd && carton exec -Ilib -Iextend/lib -- $exec_cmd";
    } $host;
};
