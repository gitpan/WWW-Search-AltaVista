
=head1 NAME

WWW::Search::AltaVista::Web - deprecated, just use WWW::Search::AltaVista

=head1 SYNOPSIS

  use WWW::Search;
  $search = new WWW::Search('AltaVista');

=head1 DESCRIPTION

Details of searching AltaVista.com can be found at
L<WWW::Search::AltaVista>.

=cut

package WWW::Search::AltaVista::Web;

use WWW::Search::AltaVista;
@ISA = qw(WWW::Search::AltaVista);

my
$VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

1;

__END__
