# News.pm
# by John Heidemann
# Copyright (C) 1996 by USC/ISI
# $Id: News.pm,v 1.4 2003-03-30 17:34:28-05 kingpin Exp kingpin $
#
# Complete copyright notice follows below.

=head1 NAME

WWW::Search::AltaVista::News - class for Alta Vista news searching


=head1 SYNOPSIS

    require WWW::Search;
    $search = new WWW::Search('AltaVista::News');


=head1 DESCRIPTION

This class implements the AltaVista news search
(specializing AltaVista and WWW::Search).
It handles making and interpreting AltaVista news searches
F<http://www.altavista.com>.

Details of AltaVista can be found at L<WWW::Search::AltaVista>.

This class exports no public interface; all interaction should
be done through WWW::Search objects.


=head1 AUTHOR

C<WWW::Search> is written by John Heidemann, <johnh@isi.edu>.


=head1 COPYRIGHT

Copyright (c) 1996 University of Southern California.
All rights reserved.

Redistribution and use in source and binary forms are permitted
provided that the above copyright notice and this paragraph are
duplicated in all such forms and that any documentation, advertising
materials, and other materials related to such distribution and use
acknowledge that the software was developed by the University of
Southern California, Information Sciences Institute.  The name of the
University may not be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut

#####################################################################

package WWW::Search::AltaVista::News;

require Exporter;
@EXPORT = qw();
@EXPORT_OK = qw();
@ISA = qw(WWW::Search::AltaVista Exporter);
use WWW::Search::AltaVista;

# private
sub native_setup_search
  {
  my $self = shift;
  my $sQuery = shift;
  if (!defined($self->{_options})) {
    $self->{_options} = {
                         'nbq' => '50',
                         'q' => $sQuery,
                         'search_host' => 'http://news.altavista.com',
                         'search_path' => '/news/search',
                        };
    };
  # Let AltaVista.pm finish up the hard work:
  return $self->SUPER::native_setup_search($sQuery, @_);
  } # native_setup_search

1;
