
use ExtUtils::testlib;
use Test::More no_plan;
BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test') };
BEGIN { use_ok('WWW::Search::AltaVista') };
BEGIN { use_ok('WWW::Search::AltaVista::DE') };

# goto DEBUG_NOW;

# goto SKIP_BASIC;
&my_engine('AltaVista::DE');
my $debug = 0;
# These tests return no results (but we should not get an HTTP error):
&my_test(0, $WWW::Search::Test::bogus_query, 0, 0, $debug);
# The following query returns one page of results:
$debug = 0;
&my_test(0, '"Martin Thurn-Mit'.'hoff"', undef, 49, $debug);
# The following query returns many pages of results:
$debug = 0;
&my_test(0, 'Thurn', 101, undef, $debug);
# all done
exit 0;

sub my_engine
  {
  my $sEngine = shift;
  $WWW::Search::Test::oSearch = new WWW::Search($sEngine);
  ok(ref($WWW::Search::Test::oSearch), "instantiate WWW::Search::$sEngine object");
  } # my_engine

sub my_test
  {
  # Same arguments as WWW::Search::Test::count_results()
  my ($sType, $sQuery, $iMin, $iMax, $iDebug, $iPrintResults) = @_;
  my $iCount = &WWW::Search::Test::count_results(@_);
  cmp_ok($iCount, '>=', $iMin, qq{lower-bound num-hits for query=$sQuery}) if defined $iMin;
  cmp_ok($iCount, '<=', $iMax, qq{upper-bound num-hits for query=$sQuery}) if defined $iMax;
  } # my_test

__END__
