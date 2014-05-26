package 
    t::DummyApp::Pages::Root;

use strict;
use warnings;

sub get_index {
    my ($class, $env) = @_;
    [200, ['Content-Type' => 'text/html'], ['Hello, world!']];
}

sub error_404 {
    my ($class, $env) = @_;
    [404, ['Content-Type' => 'text/html'], ['not found']];
}


1;
