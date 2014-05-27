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

Dispatcher::ClassMethod - A dispatcher that force a rule about routing like Catalyst.

=head1 SYNOPSIS

An example, In your psgi, 

    use Dispatcher::ClassMethod;
    use Plack::Request;
    
    my $dispatcher = Dispatcher::ClassMethod->new(basename => 'MyApp::Web::Controller');
    
    sub {
        my $env = shift;
        my $matched = Dispatcher->match($env);
        my $req = Plack::Request->new($env);
        my $res = $matched->{action}->($req);
        $res->finalize;
    };
    
    1;

Then, in your controller,

    package MyApp::Web::Controller::Root;
    use strict;
    use Plack::Response;
    
    sub get_index {
        my $req = shift;
        Plack::Response->new(200, ['Content-Type' => 'text/html'], ['<html><body>Hello!</body></html>']);
    }
    
    sub error_404 {
        my $req = shift;
        Plack::Response->new(404);
    }
    
    1;

=head1 DESCRIPTION

Dispatcher::ClassMethod is inspired from a dispatcher of Catalyst.

It has a rule for dispatching, and forces it to developper of application. 

=head1 CLASS METHOD

=head2 new

    my $dispatcher = Dispatcher::ClassMethod->new(basename => 'Some::Class::Name');

Instantiate a dispatcher. C<$basename> is required.

=head1 INSTANCE METHOD

=head2 match

    my $matched = $dispatcher->match($env_of_psgi);

Fetch a data that matches to dispatch rule.

Please see DISPATCH RULE section for more information about this rule.

=head1 MATCHED DATA

    $matched->{action}       # coderef of matched method
    $matched->{class_method} # string of matched class method
    $matched->{env}          # hashref (same as psgi env)

=head1 DISPATCH RULE

=head2 dispatching class name

Class name is built from PATH_INFO of psgi env.

First, split PATH_INFO by '/'. Then, remove undefined items. 

Next, remove a last item of these. Then, camelize all other items. If it isn't defined in this step, a class name is a string that join basename and 'Root' with '::'.

Finally, join basename and these with '::'. This string is a class name that matches.

Example, a basename is 'MyApp::Web::C'. 

When PATH_INFO is ...

'/' : a class name is 'MyApp::Web::C::Root'.

'/hoge' : a class name is 'Myapp::Web::C::Root' too.

'/user/note' : a class name is 'MyApp::Web::C::User'.

'/user_favorite/music/list' : a class name is 'MyApp::Web::C::UserFavorite::Music'.

=head2 dispatching method name

Method name is built from PATH_INFO and REQUEST_METHOD of psgi env.

First, split PATH_INFO by '/'. Then, remove undefined items. 

Next, pop a last item of these and it becomes as a method name suffix. If it isn't defined, a method name is a 'index'.

Finally, join a lowercased string of REQUEST_METHOD and method name suffix with '_'.

If a method that specified is not exists, a method name changes to 'error_404'.

Example.

When REQUEST_METHOD and PATH_INFO are ...

GET '/' : a method name is 'get_index'.

POST '/mail' : a method name is 'post_mail'.

PUT '/api/order' : a method name is 'put_order'.

HEAD '/api/ping' : a method name is 'head_ping'.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

