
use ExtUtils::testlib;
use Test::More no_plan;
BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test') };
BEGIN { use_ok('WWW::Search::AltaVista') };
BEGIN { use_ok('WWW::Search::AltaVista::DE') };

# goto SKIP_BASIC;
&my_engine('AltaVista::DE');

# goto DEBUG_NOW;

my $debug = 0;
diag("Sending 0-page query...");
# These tests return no results (but we should not get an HTTP error):
&my_test(0, $WWW::Search::Test::bogus_query, 0, 0, $debug);
diag("Sending 1-page query...");
# The following query returns one page of results:
$debug = 0;
&my_test(0, '"Martin Thurn-Mit'.'hoff"', 1, 49, $debug);
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
$debug = 0;
&my_test(0, 'Berlin', 101, undef, $debug);
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
  cmp_ok($iMin, '<=', $iCount, qq{lower-bound num-hits for query=$sQuery}) if defined $iMin;
  cmp_ok($iCount, '<=', $iMax, qq{upper-bound num-hits for query=$sQuery}) if defined $iMax;
  cmp_ok($iMin, '<=', $WWW::Search::Test::oSearch->approximate_result_count,
         qq{lower-bound approximate_result_count}) if defined $iMin;
  cmp_ok($WWW::Search::Test::oSearch->approximate_result_count, '<=', $iMax,
         qq{upper-bound approximate_result_count}) if defined $iMax;
  } # my_test

__END__