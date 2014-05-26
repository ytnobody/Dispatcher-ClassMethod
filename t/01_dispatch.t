use strict;
use Test::More;
use Dispatcher::ClassMethod;

my $dispatcher = Dispatcher::ClassMethod->new(basename => 't::DummyApp::Pages');

can_ok($dispatcher, qw/match/);

subtest 'get_index' => sub {
    my $env = {PATH_INFO => '/', REQUEST_METHOD => 'GET'};

    my $matched = $dispatcher->match($env);
    is $matched->{class_method}, 't::DummyApp::Pages::Root#get_index';
    isa_ok $matched->{action}, 'CODE';

    my $res = $matched->{action}->($env);
    is_deeply $res, [200, ['Content-Type' => 'text/html'], ['Hello, world!']];
};

subtest 'post_memo' => sub {
    my $env = {PATH_INFO => '/user/memo', REQUEST_METHOD => 'POST'};

    my $matched = $dispatcher->match($env);
    is $matched->{class_method}, 't::DummyApp::Pages::User#post_memo';
    isa_ok $matched->{action}, 'CODE';

    my $res = $matched->{action}->($env);
    is_deeply $res, [200, ['Content-Type' => 'text/html'], ['post req']];
};

done_testing;
