#############################################################
# AdvancedWeb.pm
# by Jim Smyser
# Copyright (c) 1999 by Jim Smyser & USC/ISI
# $Id: AdvancedWeb.pm,v 1.5 2001/11/30 22:03:26 mthurn Exp mthurn $
#############################################################


#package WWW::Search::AdvancedWeb; # use this if mod is placed in Search dir.
package WWW::Search::AltaVista::AdvancedWeb;

=head1 NAME

WWW::Search::AltaVista::AdvancedWeb - class for advanced Alta Vista web searching

=head1 SYNOPSIS

  use WWW::Search;
 my $search = new WWW::Search('AltaVista::AdvancedWeb');
 $search->native_query(WWW::Search::escape_query('(bmw AND mercedes) AND NOT (used OR Ferrari)'));
 $search->maximum_to_retrieve('100'); 
  while (my $result = $search->next_result())
    { 
    print $result->url, "\n"; 
    }

=head1 DESCRIPTION

Class hack for Advance AltaVista web search mode originally written by  
John Heidemann F<http://www.altavista.com>. 

This hack now allows for AltaVista AdvanceWeb search results
to be sorted and relevant results returned first. Initially, this 
class had skiped the 'r' option which is used by AltaVista to sort
search results for relevancy. Sending advance query using the 
'q' option resulted in random returned search results which made it 
impossible to view best scored results first.  

This class exports no public interface; all interaction should
be done through WWW::Search objects.

=head1 HELP

Use AND to join two terms that must both be present for a
document to count as a match.

Use OR to join two terms if either one counts.

Use AND NOT to join two terms if the first must be present and
the second must NOT.

Use NEAR to join two terms if they both must appear and be within
10 words of each other.

Try this example:

cars AND bmw AND mercedes 

You don't have to capitalize the "operators" AND, OR, AND NOT, or
NEAR. But many people do to make it clear what is a query term
and what is an instruction to the search engine.

One other wrinkle that's very handy: you can group steps together
with parentheses to tell the system what order you want it to
perform operations in.

(bmw AND mercedes) NEAR cars AND NOT (used OR Ferrari) 

Keep in mind that grouping should be used as much as possible
because if you attempt to enter a long query using AND to join
the words you may not receive any results because the entire
query would be like one long phrase. For best reuslts follow
the example herein.

=head1 AUTHOR

C<WWW::Search> hack by Jim Smyser, <jsmyser@bigfoot.com>.

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

=head1 VERSION HISTORY

2.06 - do not use URI::URL

2.02 - Added HELP POD. Misc. Clean-up for latest changes.

2.01 - Additional query modifiers added for even better results.

2.0 - Minor change to set lowercase Boolean operators to uppercase.

1.9 - First hack version release.

=cut
#'

#####################################################################

require Exporter;
@EXPORT = qw();
@EXPORT_OK = qw();
@ISA = qw(WWW::Search::AltaVista Exporter);
$VERSION = '2.06';
use WWW::Search::AltaVista;
use WWW::Search(generic_option);



# private
sub native_setup_search
{
    my($self, $native_query, $native_options_ref) = @_;
    $self->user_agent('user');
    $self->{_next_to_retrieve} = 0;
    # Upper case all lower case Boolean operators. Be nice if
    # I could just uppercase the entire string, but this may
    # have undesirable search side effects. 
    if (!defined($self->{_options})) {
    $self->{_options} = {
        'pg' => 'aq',
        'kl' => 'XX',
	    'nbq' => '50',
        'q' => $native_query,
         'search_url' => 'http://www.altavista.com/cgi-bin/query',
        }
        }
    my($options_ref) = $self->{_options};
    if (defined($native_options_ref)) {
    # Copy in new options.
    foreach (keys %$native_options_ref) {
        $options_ref->{$_} = $native_options_ref->{$_};
    };
    };
    # Process the options.
    my($options) = '';
    foreach (keys %$options_ref) {
    # printf STDERR "option: $_ is " . $options_ref->{$_} . "\n";
    next if (generic_option($_));
    $options .= $_ . '=' . $options_ref->{$_} . '&';
    };
    $self->{_debug} = $options_ref->{'search_debug'};
    $self->{_debug} = 2 if ($options_ref->{'search_parse_debug'});
    $self->{_debug} = 0 if (!defined($self->{_debug}));
    # Finally figure out the url.

    # Here I remove known Boolean operators from the 'r' query option 
    # which is used by AltaVista to sort the results. Finally, clean 
    # up by removing as many of the double ++'s as possibe left behind.
    $native_query =~ s/AND//ig;
    $native_query =~ s/OR//ig;
    $native_query =~ s/NOT//ig;
    $native_query =~ s/NEAR//ig;
    $native_query =~ s/"//g;
    $native_query =~ s/%28//g;
    $native_query =~ s/%29//g;
    $native_query =~ s/(\w)\053\053/$1\053/g;
    # strip down the query words
    $native_query =~ s/\W*(\w+\W+\w+\w+\W+\w+).*/$1/;
    $self->{_base_url} = 
    $self->{_next_url} =
    $self->{_options}{'search_url'} .
    "?" . $options .
    "r=" . $native_query;
    }

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
sub native_retrieve_some {
    my ($self) = @_;

    # fast exit if already done
    return undef if (!defined($self->{_next_url}));

    # get some
    print STDERR "WWW::Search::AltaVista::native_retrieve_some: fetching " . $self->{_next_url} . "\n" if ($self->{_debug});
    my($response) = $self->http_request('GET', $self->{_next_url});
    $self->{response} = $response;
    if (!$response->is_success) {
    return undef;
    };
    # parse the output
    my($HEADER, $HITS, $INHIT, $TRAILER, $POST_NEXT) = (1..10);  # order matters
    my($hits_found) = 0;
    my($state) = ($HEADER);
    my($hit) = undef;
    my($raw) = '';
    foreach ($self->split_lines($response->content())) {
        next if m@^$@; # short circuit for blank lines
    ######
    # HEADER PARSING: find the number of hits
    #
    if (0) {
    } elsif ($state == $HEADER && /We found.*?([\d,]+) results:/i) {
        # Modified by Jim
        my($n) = $1;
        $n =~ s/,//g;
        $self->approximate_result_count($n);
        $state = $HITS;
        print STDERR "PARSE(10:HEADER->HITS): $n documents found.\n" if ($self->{_debug} >= 2);
    ######
    # HITS PARSING: find each hit
    #
    } elsif ($state == $HITS && /r=(.*?)"\s.*?">(.*)<\/a>/i) {
        $raw .= $_;
        my($url,$title) = ($1,$2);
        ($hit, $raw) = $self->begin_new_hit($hit, $raw);
        $hits_found++;
        $hit->add_url(&WWW::Search::unescape_query($url));
        $hit->title($title);
        print STDERR "PARSE(13:INHIT): title: $1.\n" if ($self->{_debug} >= 2);
    } elsif ($state == $HITS && /^<br>/i) {
    } elsif ($state == $HITS && /^([\d|\w|<b>|\.].+)<br>/i) {
        $raw .= $_;
        ($hit, $raw) = $self->begin_new_hit($hit, $raw) unless ref($hit);
        $hit->description($1);
        print STDERR "PARSE(13:INHIT): description.\n" if ($self->{_debug} >= 2);
    } elsif ($state == $HITS && /^URL:\s(.*)$/i) { #"
        $raw .= $_;
        ($hit, $raw) = $self->begin_new_hit($hit, $raw) unless ref($hit);
        $hit->add_url($url);
        print STDERR "PARSE(13:INHIT): url: $1.\n" if ($self->{_debug} >= 2);
    } elsif ($state == $HITS && /^<!-- res_extend.wm -->/i) {
        $raw .= $_;
        ($hit, $raw) = $self->save_old_hit($hit, $raw);
        $state = $TRAILER;
        print STDERR "PARSE(13:INHIT->HITS): end hit.\n" if ($self->{_debug} >= 2);
    } elsif ($state == $HITS) {
        # other random stuff in a hit---accumulate it
        $raw .= $_;
        print STDERR "PARSE(14:INHIT): no match.\n" if ($self->{_debug} >= 2);
            print STDERR ' 'x 12, "$_\n" if ($self->{_debug} >= 3);
    } elsif ($hits_found && ($state == $TRAILER || $state == $HITS) && /<a[^>]+href="([^"]+)".*\&gt;\&gt;/i) { # "
        # (above, note the trick $hits_found so we don't prematurely terminate.)
        # set up next page
        my($relative_url) = $1;
        # hack:  make sure fmt=d stays on news URLs
        $relative_url =~ s/what=news/what=news\&fmt=d/ if ($relative_url !~ /fmt=d/i);
        $self->{_next_url} = $HTTP::URI_CLASS->new_abs($relative_url, $self->{_base_url});
        $state = $POST_NEXT;
        print STDERR "PARSE(15:->POST_NEXT): found next, $n.\n" if ($self->{_debug} >= 2);
    } else {
        # accumulate raw
        $raw .= $_;
        print STDERR "PARSE(RAW): $_\n" if ($self->{_debug} >= 3);
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
}
1;

