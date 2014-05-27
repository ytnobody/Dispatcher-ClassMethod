# NAME

Dispatcher::ClassMethod - A dispatcher that force a rule about routing like Catalyst.

# SYNOPSIS

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

# DESCRIPTION

Dispatcher::ClassMethod is inspired from a dispatcher of Catalyst.

It has a rule for dispatching, and forces it to developper of application. 

# CLASS METHOD

## new

    my $dispatcher = Dispatcher::ClassMethod->new(basename => 'Some::Class::Name');

Instantiate a dispatcher. `$basename` is required.

# INSTANCE METHOD

## match

    my $matched = $dispatcher->match($env_of_psgi);

Fetch a data that matches to dispatch rule.

Please see DISPATCH RULE section for more information about this rule.

# MATCHED DATA

    $matched->{action}       # coderef of matched method
    $matched->{class_method} # string of matched class method
    $matched->{env}          # hashref (same as psgi env)

# DISPATCH RULE

## dispatching class name

Class name is built from PATH\_INFO of psgi env.

First, split PATH\_INFO by '/'. Then, remove undefined items. 

Next, remove a last item of these. Then, camelize all other items. If it isn't defined in this step, a class name is a string that join basename and 'Root' with '::'.

Finally, join basename and these with '::'. This string is a class name that matches.

Example, a basename is 'MyApp::Web::C'. 

When PATH\_INFO is ...

'/' : a class name is 'MyApp::Web::C::Root'.

'/hoge' : a class name is 'Myapp::Web::C::Root' too.

'/user/note' : a class name is 'MyApp::Web::C::User'.

'/user\_favorite/music/list' : a class name is 'MyApp::Web::C::UserFavorite::Music'.

## dispatching method name

Method name is built from PATH\_INFO and REQUEST\_METHOD of psgi env.

First, split PATH\_INFO by '/'. Then, remove undefined items. 

Next, pop a last item of these and it becomes as a method name suffix. If it isn't defined, a method name is a 'index'.

Finally, join a lowercased string of REQUEST\_METHOD and method name suffix with '\_'.

If a method that specified is not exists, a method name changes to 'error\_404'.

Example.

When REQUEST\_METHOD and PATH\_INFO are ...

GET '/' : a method name is 'get\_index'.

POST '/mail' : a method name is 'post\_mail'.

PUT '/api/order' : a method name is 'put\_order'.

HEAD '/api/ping' : a method name is 'head\_ping'.

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody@gmail.com>
