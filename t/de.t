
# $Id: de.t,v 1.9 2005/12/15 03:55:51 Daddy Exp $

use ExtUtils::testlib;
use Test::More no_plan;

BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test', qw( tm_new_engine tm_run_test )) };
BEGIN { use_ok('WWW::Search::AltaVista') };
BEGIN { use_ok('WWW::Search::AltaVista::DE') };

# goto SKIP_BASIC;
&tm_new_engine('AltaVista::DE');

# goto DEBUG_NOW;

my $iDebug = 0;
diag("Sending 0-page query...");
# These tests return no results (but we should not get an HTTP error):
&tm_run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
diag("Sending 1-page query...");
# The following query returns one page of results:
$iDebug = 0;
&tm_run_test(0, '"Martin Thurn-Mitt'.'hoff"', 1, 49, $iDebug);
my @ao = $WWW::Search::Test::oSearch->results();
cmp_ok(0, '<=', scalar(@ao), 'got any results');
foreach my $oResult (@ao)
  {
  like($oResult->url, qr{\Ahttp://},
       'result URL is http');
  cmp_ok($oResult->title, 'ne', '',
         'result Title is not empty');
  cmp_ok($oResult->description, 'ne', '',
         'result description is not empty');
  } # foreach
DEBUG_NOW:
diag("Sending multi-page query...");
# The following query returns many pages of results:
$iDebug = 0;
&tm_run_test(0, 'Berlin', 101, undef, $iDebug);
# all done
exit 0;

__END__

