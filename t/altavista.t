
use ExtUtils::testlib;
use Test::More no_plan;
BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test') };
BEGIN { use_ok('WWW::Search::AltaVista') };

&my_engine('AltaVista');
my $iDebug = 0;
my $iDump = 0;

# goto DEBUG_NOW;

# goto SKIP_BASIC;
# These tests return no results (but we should not get an HTTP error):
diag("Sending 0-page query to altavista.com...");
&my_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
DEBUG_NOW:
$iDebug = 2;
$iDump = 1;
# &my_test(0, 'virus protease', undef, 55, $iDebug, $iDump);
# exit 99;
diag("Sending 1-page query to altavista.com...");
$iDebug = 0;
$iDump = 0;
&my_test(0, '"Rhon'.'da Thurn"', undef, 49, $iDebug, $iDump);
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
diag("Sending multi-page query to altavista.com...");
$iDebug = 0;
$iDump = 0;
&my_test(0, 'Martin '.'Thurn', 51, undef, $iDebug);
SKIP_BASIC:
;
# exit 0; # for debugging

&my_engine('AltaVista::Web');
# goto SKIP_WEB;
diag("Sending 0-page web query to altavista.com...");
$iDebug = 0;
# This test returns no results (but we should not get an HTTP error):
&my_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
diag("Sending 1-page web query to altavista.com...");
# This query returns 3 (or more) pages of results:
&my_test(0, 'Cheddar', 51, undef, $iDebug);
SKIP_WEB:
;
&my_engine('AltaVista::AdvancedWeb');
# goto SKIP_ADVANCEDWEB;
diag("Sending 0-page advanced web query to altavista.com...");
$iDebug = 0;
# These tests return no results (but we should not get an HTTP error):
&my_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
SKIP_ADVANCEDWEB:
;
# all done
exit 0;

sub my_engine
  {
  my $sEngine = shift;
  $WWW::Search::Test::oSearch = new WWW::Search($sEngine);
  ok(ref($WWW::Search::Test::oSearch), "instantiate WWW::Search::$sEngine object");
  $WWW::Search::Test::oSearch->env_proxy('yes');
  } # my_engine

sub my_test
  {
  # Same arguments as WWW::Search::Test::count_results()
  my ($sType, $sQuery, $iMin, $iMax, $iDebug, $iPrintResults) = @_;
  my $iCount = &WWW::Search::Test::count_results(@_);
  cmp_ok($iCount, '>=', $iMin, qq{lower-bound num-hits for query=$sQuery}) if defined $iMin;
  cmp_ok($iCount, '<=', $iMax, qq{upper-bound num-hits for query=$sQuery}) if defined $iMax;
  cmp_ok($iMin, '<=', $WWW::Search::Test::oSearch->approximate_result_count,
         qq{lower-bound approximate_result_count}) if defined $iMin;
  cmp_ok($WWW::Search::Test::oSearch->approximate_result_count, '<=', $iMax,
         qq{upper-bound approximate_result_count}) if defined $iMax;
  } # my_test

__END__

