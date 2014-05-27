package Dispatcher::ClassMethod;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw|basename|],
);
use Module::Load ();
use String::CamelCase ();
use Carp ();

sub match {
    my ($self, $env) = @_;
    my @path_parts = grep {$_} split /\//, $env->{PATH_INFO};

    my $actionname = join('_', lc($env->{REQUEST_METHOD}), pop @path_parts || 'index' );
    my $classname = @path_parts ?
        join('::', $self->{basename}, map {String::CamelCase::camelize($_)} @path_parts) : 
        join('::', $self->{basename}, 'Root')
    ;

    unless ($self->{loaded_plugins}{$classname}) {
        eval { Module::Load::load($classname) };
        if ($@) {
            Carp::carp(sprintf('could not load a class %s : %s', $classname, $@));
        }
        $self->{loaded_plugins}{$classname} = 1;
    }

    my $action = $classname->can($actionname);

    unless ($action) {
        Carp::carp(sprintf('class method "%s#%s" is undefined', $classname, $actionname));
        $classname = join('::', $self->{basename}, 'Root');
        $actionname = 'error_404';
        $action = $classname->can($actionname);
    }

    +{
        class_method => join('#', $classname, $actionname),
        action => $action,
        env => $env,
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Dispatcher::ClassMethod - It's new $module

=head1 SYNOPSIS

    use Dispatcher::ClassMethod;

=head1 DESCRIPTION

Dispatcher::ClassMethod is ...

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

