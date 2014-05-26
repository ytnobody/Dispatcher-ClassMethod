package 
    t::DummyApp::Pages::User;

use strict;
use warnings;

sub post_memo {
    my ($class, $env) = @_;
    my $post_data = $env->{'psgi.input'};
    [200, ['Content-Type' => 'text/html'], ['post req']];
}

1;
