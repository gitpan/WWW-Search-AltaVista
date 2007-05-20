# DE.pm
# by Martin Thurn
# $Id: DE.pm,v 1.3 2007/05/20 14:05:44 Daddy Exp $

=head1 NAME

WWW::Search::AltaVista::DE - class for searching www.AltaVista.DE

=head1 SYNOPSIS

    require WWW::Search;
    $search = new WWW::Search('AltaVista::DE');

=head1 DESCRIPTION

This class handles making and interpreting AltaVista Germany searches
F<http://www.altavista.de>.

Details of AltaVista can be found at L<WWW::Search::AltaVista>.

This class exports no public interface; all interaction should
be done through WWW::Search objects.

=head1 AUTHOR

Martin Thurn C<mthurn@cpan.org>

=cut

#####################################################################

package WWW::Search::AltaVista::DE;

use strict;

use base 'WWW::Search::AltaVista';
our
$VERSION = sprintf("%d.%02d", q$Revision: 1.3 $ =~ /(\d+)\.(\d+)/o);

# private
sub native_setup_search
  {
  my $self = shift;
  my $sQuery = shift;
  if (!defined($self->{_options})) {
    $self->{_options} = {
                         'nbq' => '50',
                         'q' => $sQuery,
                         'search_host' => 'http://de.altavista.com',
                         'search_path' => '/web/results',
                        };
    };
  # Let AltaVista.pm finish up the hard work:
  return $self->SUPER::native_setup_search($sQuery, @_);
  } # native_setup_search

1;

__END__

