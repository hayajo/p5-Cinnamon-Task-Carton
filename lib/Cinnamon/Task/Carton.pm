package Cinnamon::Task::Carton;

use warnings;
use strict;
use Carp ();

our $VERSION = '0.01';

# Module implementation here
use parent qw(Exporter);
use String::ShellQuote;

our @EXPORT = qw(
    carton_install
    carton_exec
);

sub carton_install ($) {
    my $carton_cwd = shell_quote shift;
    no strict 'refs';
    my $run = *{caller . '::run'}{CODE};
    $run->("cd $carton_cwd && carton install");
}

sub carton_exec (&$@) {
    my $code       = shift;
    my $carton_cwd = shell_quote shift;
    my @carton_lib = @_;

    no strict 'refs';
    no warnings 'redefine';

    my $caller   = caller;
    my $dsl      = "${caller}::run";
    my $orig_dsl = *{$dsl}{CODE};

    my $lib = '';
    $lib = join( ' ', map { '-I' . $_ } @carton_lib ) if (@carton_lib);

    local *{$dsl} = sub (@) {
        my @cmd = @_;
        my $carton_exec = ";cd $carton_cwd && carton exec $lib --";

        my $opts = undef;
        $opts = shift @cmd if ref $cmd[0] eq 'HASH';

        $orig_dsl->( ($opts) ? ( $opts, $carton_exec, @cmd ) : ( $carton_exec, @cmd ) );
    };

    $code->();
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Cinnamon::Task::Carton - [One line description of module's purpose here]


=head1 VERSION

This document describes Cinnamon::Task::Carton version 0.01


=head1 SYNOPSIS

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
              } $carton_cwd, qw/lib/;
          } $host;
      },
  };


=head1 DESCRIPTION

Cinnamon::Task::Carton is carton dsls for L<Cinnamon>

This is B<alpha> version.

=head1 DSL

=over 4

=item carton_install ( I<$carton_cwd: String> ): ( I<$stdout: String>, I<$stderr: String> )

=item carton_exec ( I<$sub: CODE> I<$carton_cwd: String> I<@lib: Array> ): Any

C<sudo> is not supported.

=back


=head1 AUTHOR

hayajo  C<< <hayajo@cpan.org> >>


=head1 SEE ALSO

L<Cinnamon>, L<Cinnamon::Task::Perlbrew>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, hayajo C<< <hayajo@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=cut
