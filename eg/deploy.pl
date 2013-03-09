use strict;
use warnings;

use Cinnamon::DSL;
use Cinnamon::Task::Carton;

my $carton_cwd = '/tmp/cinnamon_carton';

set user       => getpwuid($>);
set carton_cwd => $carton_cwd;

role development => [qw/localhost/];

task carton => {
    install => sub {
        my ( $host, @args ) = @_;
        my $carton_cwd = get('carton_cwd');
        remote {
            carton_install $carton_cwd;
        } $host;
    },
};

task myapp => {
    run => sub {
        my ( $host, @args ) = @_;
        my $carton_cwd = get('carton_cwd');
        remote {
            carton_exec {
                run "bin/myapp";
            } $carton_cwd, [qw/lib/];
        } $host;
    },
};

# # -- e.g. with C::T::Perlbrew

# use Cinnamon::DSL;
# use Cinnamon::Task::Perlbrew;
# use Cinnamon::Task::Carton;

# my $perlbrew_root = '/tmp/cinnamon_perlbrew';
# my $carton_cwd    = '/tmp/cinnamon_carton';

# # global options
# set user          => getpwuid($>);
# set perlbrew_root => $perlbrew_root;
# set carton_cwd    => $carton_cwd;

# role development => [qw/localhost/], {
    # perlbrew_perl_version => 'perl-5.17.9',
    # perlbrew              => 'perl-5.17.9@hoge',
    # cpanm_modules         => [qw/JSON::XS Carton/],
    # cpanm_options         => '--verbose --notest',
# };

# task carton => {
    # install => sub {
        # my ( $host, @args ) = @_;
        # my $perlbrew_root = get('perlbrew_root');
        # my $perlbrew      = get('perlbrew');
        # my $carton_cwd    = get('carton_cwd');
        # remote {
            # perlbrew_run {
                # carton_install $carton_cwd;
            # } $perlbrew_root, $perlbrew;
        # } $host;
    # },
# };

# task myapp => {
    # run => sub {
        # my ( $host, @args ) = @_;
        # my $perlbrew_root = get('perlbrew_root');
        # my $perlbrew      = get('perlbrew');
        # my $carton_cwd    = get('carton_cwd');
        # remote {
            # perlbrew_run {
                # carton_exec {
                    # run "bin/myapp";
                # } $carton_cwd, qw/lib/;
            # } $perlbrew_root, $perlbrew;
        # } $host;
    # },
# };

