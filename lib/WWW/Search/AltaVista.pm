# AltaVista.pm
# by John Heidemann
# Copyright (C) 1996-1998 by USC/ISI
# $Id: AltaVista.pm,v 1.9 2002/08/21 13:21:55 mthurn Exp $
#
# Complete copyright notice follows below.

package WWW::Search::AltaVista;

=head1 NAME

WWW::Search::AltaVista - class for searching www.altavista.com


=head1 SYNOPSIS

    require WWW::Search;
    $search = new WWW::Search('AltaVista');


=head1 DESCRIPTION

This class is an AltaVista specialization of WWW::Search.
It handles making and interpreting AltaVista searches
F<http://www.altavista.com>.

This class exports no public interface; all interaction should
be done through WWW::Search objects.


=head1 OPTIONS

The default is for simple web queries.
Specialized back-ends for simple and advanced web and news searches
are available (see
L<WWW::Search::AltaVista::Web>,
L<WWW::Search::AltaVista::AdvancedWeb>,
L<WWW::Search::AltaVista::News>,
L<WWW::Search::AltaVista::AdvancedNews>).
These back-ends set different combinations following options.

=over 8

=item search_url=URL

Specifies whom to query with the AltaVista protocol.
The default is at
C<http://www.altavista.com/cgi-bin/query>;
you may wish to retarget it to
C<http://www.altavista.telia.com/cgi-bin/query>
or other hosts if you think that they're ``closer''.

=item search_debug, search_parse_debug, search_ref
Specified at L<WWW::Search>.

=item pg=aq

Do advanced queries.
(It defaults to simple queries.)

=item what=news

Search Usenet instead of the web.
(It defaults to search the web.)

=back


=head1 SEE ALSO

To make new back-ends, see L<WWW::Search>,
or the specialized AltaVista searches described in options.


=head1 AUTHOR

C<WWW::Search::AltaVista> was written by John Heidemann,
<johnh@isi.edu>.
C<WWW::Search::AltaVista> is maintained by Martin Thurn,
<mthurn@cpan.org>.

=head1 COPYRIGHT

Copyright (c) 1996-1998 University of Southern California.
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

require Exporter;
@EXPORT = qw();
@EXPORT_OK = qw();
@ISA = qw(WWW::Search Exporter);
$VERSION = '2.26';

use Carp ();
use WWW::Search qw( generic_option unescape_query );
require WWW::SearchResult;


sub undef_to_emptystring
  {
  return defined($_[0]) ? $_[0] : "";
  }


# private
sub native_setup_search
  {
  my($self, $native_query, $native_options_ref) = @_;
  $self->user_agent('user');
  $self->{_next_to_retrieve} = 0;
  # set the text=yes option to provide next links with <a href>
  # (suggested by Guy Decoux <decoux@moulon.inra.fr>).
  if (!defined($self->{_options}))
    {
    $self->{_options} = {
                         'pg' => 'q',
                         'text' => 'yes',
                         'what' => 'web',
                         'fmt' => 'd',
                         'nbq' => '50',
                         'search_url' => 'http://www.altavista.com/cgi-bin/query',
                        };
    } # if
  my($options_ref) = $self->{_options};
  if (defined($native_options_ref))
    {
    # Copy in new options.
    foreach (keys %$native_options_ref)
      {
      $options_ref->{$_} = $native_options_ref->{$_};
      } # foreach
    } # if
  # Process the options.
  my $options = '';
  # For Intranet search to work, mss option must be first:
  if (exists $options_ref->{'mss'})
    {
    $options .= 'mss=' . $options_ref->{'mss'} . '&';
    } # if
  foreach my $key (keys %$options_ref)
    {
    # printf STDERR "option: $_ is " . $options_ref->{$_} . "\n";
    next if (generic_option($key));
    next if $key eq 'mss';
    $options .= $key . '=' . $options_ref->{$key} . '&';
    } # foreach
  $self->{_debug} = $options_ref->{'search_debug'};
  $self->{_debug} = 2 if ($options_ref->{'search_parse_debug'});
  $self->{_debug} = 0 if (!defined($self->{_debug}));

  # Finally figure out the url.
  $self->{_base_url} =
  $self->{_next_url} =
  $self->{_options}{'search_url'} .'?'. $options .'q='. $native_query;
  print STDERR $self->{_base_url} . "\n" if ($self->{_debug});
  } # native_setup_search


# private
sub save_old_hit {
    my($self) = shift;
    my($old_hit) = shift;
    my($old_raw) = shift;

    if (defined($old_hit)) {
    $old_hit->raw($old_raw) if (defined($old_raw));
    push(@{$self->{cache}}, $old_hit);
    };

    return(undef, undef);
}

# private
sub begin_new_hit
{
    my($self) = shift;
    my($old_hit) = shift;
    my($old_raw) = shift;

    $self->save_old_hit($old_hit, $old_raw);

    # Make a new hit.
    return (new WWW::SearchResult, '');
}


# private
sub native_retrieve_some
{
    my ($self) = @_;

    # fast exit if already done
    return undef if (!defined($self->{_next_url}));

    # get some
    print STDERR "WWW::Search::AltaVista::native_retrieve_some: fetching " . $self->{_next_url} . "\n" if ($self->{_debug});
    my($response) = $self->http_request('GET', $self->{_next_url});
    $self->{response} = $response;
    if (!$response->is_success)
      {
      print STDERR " +   failed: $response\n" if ($self->{_debug});
      return undef;
      } # if

    # parse the output
    my($HEADER, $HITS, $INHIT, $TRAILER, $POST_NEXT) = (1..10);  # order matters
    my($hits_found) = 0;
    my($state) = ($HEADER);
    my($hit) = undef;
    my($raw) = '';
    foreach ($self->split_lines($response->content()))
      {
      next if m@^$@; # short circuit for blank lines
      print STDERR "PARSE(0:RAW): $_\n" if ($self->{_debug} >= 3);
      if (0) { }

      ######
      # HEADER PARSING: find the number of hits
      #
      elsif ($state == $HEADER && /(?:AltaVista|We)\s+found.*?([\d,]+)\s+(results?|headlines?)/i)
        {
        # Modified by Jim
        my($n) = $1;
        $n =~ s/,//g;
        $self->approximate_result_count($n);
        print STDERR "PARSE(10:HEADER->HITS): $n documents found.\n" if ($self->{_debug} >= 2);
        return 0 unless 0 < $n;
        $state = $HITS;
        }

        ######
        # HITS PARSING: find each hit
        #
      elsif ($state == $HITS && /r=(.*?)"\s.*?">(.*)<\/a>/i)
        {
        $raw .= $_;
        my ($url, $title) = (unescape_query($1), $2);
        ($hit, $raw) = $self->begin_new_hit($hit, $raw);
        $hits_found++;
        $hit->add_url($url);
        $hit->title($title);
        print STDERR "PARSE(13:INHIT): url+title: $title.\n" if ($self->{_debug} >= 2);
    } elsif ($state == $HITS && /^<br>/i) {
    } elsif ($state == $HITS && /^([\d|\w|<b>|\.].+)<br>/i)
      {
      # We are looking at a description...
      if (ref $hit)
        {
        # AND we have already seen a URL.
        $raw .= $_;
        $hit->description($1);
        } # if
      print STDERR "PARSE(13:INHIT): description.\n" if ($self->{_debug} >= 2);
      }
    elsif ($state == $HITS && /^URL:\s(.*)$/i) { #"
        $raw .= $_;
        print STDERR "PARSE(13:INHIT): url: $1.\n" if ($self->{_debug} >= 2);

        }
      # Look for end of hits list:
      elsif (($state == $HITS)
             &&
             (
              /^<!-- res_extend.wm -->/i
              ||
              m!<a\s+href="/r\?ext24"!i
              ||
              m!<a\s+href="http://jump.altavista.com/rlweb_ebay.go!i
             )
            )
        {
        ($hit, $raw) = $self->save_old_hit($hit, $raw);
        $state = $TRAILER;
        print STDERR "PARSE(13:INHIT->HITS): end hit.\n" if ($self->{_debug} >= 2);
        }
      elsif ($hits_found && ($state == $TRAILER || $state == $HITS) && /<a[^>]+href="([^"]+)".*\&gt;\&gt;/i) { # "
        # (above, note the trick $hits_found so we don't prematurely terminate.)
        # set up next page
        my($relative_url) = $1;
        # Actual line of input:
        # &nbsp; <a href="/cgi-bin/query?pg=q&amp;nbq=50&amp;what=web&amp;text=yes&amp;fmt=d&amp;q=Martin+Thurn&stq=50" target="_self">[Next &gt;&gt;]</a> 

        print STDERR "PARSE(15:->POST_NEXT): raw next_url is $relative_url\n" if ($self->{_debug} >= 2);
        # hack:  make sure fmt=d stays on news URLs
        $relative_url =~ s/what=news/what=news\&fmt=d/ if ($relative_url !~ /fmt=d/i);
        # Not sure why this is necessary.  BUT I *have* seen
        # altavista.com spit out double-encoded URLs!  I.e. they
        # contain &amp;amp; !!
        $relative_url =~ s!&amp;!&!g;
        $self->{_next_url} = $HTTP::URI_CLASS->new_abs($relative_url, $self->{_base_url});
        $state = $POST_NEXT;
        print STDERR "PARSE(15:->POST_NEXT): cooked next_url is $n.\n" if ($self->{_debug} >= 2);
    } elsif ($state == $HITS) {
        # other random stuff in a hit---accumulate it
        $raw .= $_;
        print STDERR "PARSE(14:INHIT): no match.\n" if ($self->{_debug} >= 2);
            print STDERR ' 'x 12, "$_\n" if ($self->{_debug} >= 3);
    } else {
        # accumulate raw
        $raw .= $_;
        # print STDERR "PARSE(RAW): $_\n" if ($self->{_debug} >= 3);
    };
    };
    if ($state != $POST_NEXT) {
    # end, no other pages (missed ``next'' tag)
    if ($state == $HITS) {
        $self->begin_new_hit($hit, $raw);   # save old one
        print STDERR "PARSE: never got to TRAILER.\n" if ($self->{_debug} >= 2);
    };
    $self->{_next_url} = undef;
    };

    # sleep so as to not overload altavista
    $self->user_agent_delay if (defined($self->{_next_url}));

    return $hits_found;
    } # native_retrieve_some

1;

