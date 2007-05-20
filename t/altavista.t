# $rcs = ' $Id: altavista.t,v 1.10 2005/12/15 03:56:30 Daddy Exp $ ' ;

use ExtUtils::testlib;
use Test::More no_plan;

BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test', qw( tm_new_engine tm_run_test )) };
BEGIN { use_ok('WWW::Search::AltaVista') };

&tm_new_engine('AltaVista');
my $iDebug = 0;
my $iDump = 0;

# goto DEBUG_NOW;

# goto SKIP_BASIC;
# These tests return no results (but we should not get an HTTP error):
diag("Sending 0-page query to altavista.com...");
&tm_run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);

# DEBUG_NOW:
diag("Sending 1-page query to altavista.com...");
$iDebug = 0;
$iDump = 0;
&tm_run_test(0, 'noo'.'tebookks', 1, 49, $iDebug, $iDump);
my @ao = $WWW::Search::Test::oSearch->results();
cmp_ok(0, '<', scalar(@ao), 'got any results');
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
goto SKIP_PHRASE_TEST;
diag("Sending phrase query to altavista.com...");
$iDebug = 1;
$iDump = 0;
# $WWW::Search::Test::oSearch->{_allow_empty_query} = 1;
$WWW::Search::Test::oSearch->native_query('junk crap bile', {
                                               search_debug => $iDebug,
                                               # Clear out the "OR" query:
                                               aqo => '',
                                               # Put our query in the
                                               # "PHRASE" slot:
                                               aqp => 'Thurn Martin',
                                              });
for (1..49)
  {
  push @ao, $WWW::Search::Test::oSearch->next_result();
  } # for
@ao = grep { defined } @ao;
cmp_ok(10, '<', scalar(@ao), 'got any results');
foreach my $oResult (@ao)
  {
  like($oResult->url, qr{\Ahttp://},
       'result URL is http');
  cmp_ok($oResult->title, 'ne', '',
         'result Title is not empty');
  cmp_ok($oResult->description, 'ne', '',
         'result description is not empty');
  } # foreach
SKIP_PHRASE_TEST:
goto ALL_DONE; # for debugging

diag("Sending multi-page query to altavista.com...");
$iDebug = 0;
$iDump = 0;
&tm_run_test(0, 'Martin '.'Thurn', 51, undef, $iDebug);
SKIP_BASIC:
;

&tm_new_engine('AltaVista::Web');
# goto SKIP_WEB;
diag("Sending 0-page web query to altavista.com...");
$iDebug = 0;
# This test returns no results (but we should not get an HTTP error):
&tm_run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
diag("Sending multi-page web query to altavista.com...");
# This query returns 3 (or more) pages of results:
&tm_run_test(0, 'Cheddar', 51, undef, $iDebug);
SKIP_WEB:
;
&tm_new_engine('AltaVista::AdvancedWeb');
# goto SKIP_ADVANCEDWEB;
diag("Sending 0-page advanced web query to altavista.com...");
$iDebug = 0;
# These tests return no results (but we should not get an HTTP error):
&tm_run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
SKIP_ADVANCEDWEB:
;
ALL_DONE:
exit 0;

__END__

