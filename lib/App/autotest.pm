package App::autotest;
{
  $App::autotest::VERSION = '0.001';
}

# ABSTRACT: main package for the autotest tool

use strict;
use warnings;

use Moose;
use File::Find;
use File::Spec;
use Cwd;
use File::ChangeNotify;
use TAP::Harness;

has harness => (
    is      => 'rw',
    isa     => 'TAP::Harness',
    default => sub { _default_harness() }
);

has test_directory => ( is => 'rw', isa => 'Str', default => 't' );

has watcher => (
    is      => 'rw',
    isa     => 'File::ChangeNotify::Watcher',
    default => sub {
        File::ChangeNotify->instantiate_watcher(
            directories => ['t'],
            filter      => qr/\.t$/
        );
    }
);

has after_change_or_new_hook => (
    is      => 'rw',
    isa     => 'CodeRef',
    default => sub {
        sub { 0 }
    }
);

has harness_runtests_result => (
    is  => 'rw',
    isa => 'TAP::Parser::Aggregator'
);

sub run {
    my ($self) = @_;

    $self->run_tests_upon_startup;
    $self->run_tests_upon_change_or_creation;

    return 1;
}

sub number_of_test_programs {
    my ($self) = @_;

    return scalar @{ $self->all_test_programs };
}

sub number_of_test_programs_run {
    my ($self) = @_;

    return scalar @{ $self->test_programs_run };
}

sub test_programs_run {
    my ($self) = @_;

    my $result = $self->harness_runtests_result;
    return [] unless $result;
    my @parsers = $result->parsers;

    # filter it to get the names
    return \@parsers;
}

sub run_tests_upon_startup {
    my ($self) = @_;

    my $all_test_programs = $self->all_test_programs( $self->test_directory );

    # do we have test programs at all?
    return 1 unless @$all_test_programs;

    $self->harness_runtests_result(
        $self->harness->runtests(@$all_test_programs) );
    return 1;
}

sub run_tests_upon_change_or_creation {
    my ($self) = @_;

    while (1) {
        $self->harness->runtests( @{ $self->changed_and_new_files } );
        last if $self->after_change_or_new_hook->();
    }
    return 1;
}

sub changed_and_new_files {
    my ($self) = @_;

    my @files;
    for my $event ( $self->watcher->wait_for_events() ) {
        my $type = $event->type();
        my $file_changed = $type eq 'create' || $type eq 'modify';
        push @files, $event->path() if $file_changed;
    }

    return \@files;
}

{
    my @files;

    sub all_test_programs {
        my ($self) = @_;

        @files = ();    # throw away result of last call
        find( { wanted => \&_wanted, no_chdir => 1 },
            './' . $self->test_directory );

        return \@files;
    }

    sub _wanted {
        my $cwd  = getcwd();
        my $name = $File::Find::name;

        push @files, File::Spec->catfile( $cwd, $name ) if $name =~ m{\.t$};
    }

}

sub _default_harness {
    my $args = {
        verbosity => -3,
        lib       => [ 'lib', 'blib/lib', 'blib/arch' ],
    };
    return TAP::Harness->new($args);
}

1;

__END__
=pod

=head1 NAME

App::autotest - main package for the autotest tool

=head1 VERSION

version 0.001

=head1 AUTHOR

Gregor Goldbach <glauschwuffel@nomaden.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Gregor Goldbach.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

