use strict;
use Test::More;
use Capture::Tiny ':all';
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

subtest 'error_404' => sub {
    my $env = {PATH_INFO => '/foobar/nothing', REQUEST_METHOD => 'GET'};

    my ($stdout, $stderr, $matched) = capture { $dispatcher->match($env) };
    like($stderr, qr|could not load a class t::DummyApp::Pages::Foobar : Can't locate t/DummyApp/Pages/Foobar.pm in \@INC|);
    is $matched->{class_method}, 't::DummyApp::Pages::Root#error_404';
    isa_ok $matched->{action}, 'CODE';

    my $res = $matched->{action}->($env);
    is_deeply $res, [404, ['Content-Type' => 'text/html'], ['not found']];
};

done_testing;
