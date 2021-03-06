use Mojo::Base -strict;

use Test::More;

use Mojolicious::Lite;
use Test::Mojo;

### INIT
plugin 'RemoteAddr';
plugin 'BindSessionToIP';

get '/fill_session' => sub {
    my $self = shift;
    $self->session( 'status' => 'AUTHENTICATED' );
    $self->render( text => 'DONE' );
};

get '/check_session' => sub {
    my $self = shift;
    $self->render( text => $self->session( 'status') );
};


### TESTS
my $t = Test::Mojo->new;
$t->get_ok('/fill_session')->status_is(200)->content_is('DONE');
$t->get_ok('/check_session')->status_is(200)->content_is('AUTHENTICATED');
$t->get_ok('/check_session')->status_is(200)->content_is('AUTHENTICATED');

# Change IP
$t->ua->on( start => sub {
    my ( $ua, $tx ) = @_;
    $tx->req->headers->header( 'X-Real-IP', '1.1.1.1' );
});

$t->get_ok('/check_session')->status_is(302)->header_like('Location' => qr'^(?:https?://[^/]+/|/)$');
$t->get_ok('/check_session')->status_is(200);


done_testing;
