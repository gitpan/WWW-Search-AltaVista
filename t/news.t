
# $Id: news.t,v 1.9 2005/12/15 03:57:49 Daddy Exp $

use ExtUtils::testlib;
use Test::More no_plan;

BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test', qw( tm_new_engine tm_run_test )) };
BEGIN { use_ok('WWW::Search::AltaVista') };

&tm_new_engine('AltaVista::News');
# goto DEBUG_NOW;

# goto SKIP_NEWS;
my $iDebug = 0;
my $iDump = 0;
# These tests return no results (but we should not get an HTTP error):
diag("Sending 0-page normal query...");
&tm_run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
diag("Sending 0-page normal query with plus...");
&tm_run_test(0, "+perl +$WWW::Search::Test::bogus_query", 0, 0, $iDebug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
DEBUG_NOW:
diag("Sending multi-page normal query...");
$iDebug = 0;
$iDump = 0;
&tm_run_test(0, 'Ashburn', 51, undef, $iDebug, $iDump);
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
  cmp_ok($oResult->source, 'ne', '',
         'result source is not empty');
  cmp_ok($oResult->change_date, 'ne', '',
         'result change_date is not empty');
  } # foreach
SKIP_NEWS:
;
# As of 2002-08, altavista.com does not have an Advanced search for
# news.
&tm_new_engine('AltaVista::AdvancedNews');
goto SKIP_ADVANCEDNEWS;
$iDebug = 0;
# These tests return no results (but we should not get an HTTP error):
&tm_run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
&tm_run_test(0, "+perl +$WWW::Search::Test::bogus_query", 0, 0, $iDebug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
# This query returns 3 (or more) pages of results:
$iDebug = 0;
&tm_run_test(0, 'li'.'nux', 61, undef, $iDebug);
SKIP_ADVANCEDNEWS:
;
# all done
exit 0;

__END__

