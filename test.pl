
use ExtUtils::testlib;
use Test::More no_plan;
BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test') };
BEGIN { use_ok('WWW::Search::AltaVista') };

# goto DEBUG_NOW;

# goto SKIP_BASIC;
&new_engine('AltaVista');
my $debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $debug);
# &run_test("+LSAM +$WWW::Search::Test::bogus_query", 0, 0, $debug);
# $debug = 1;
&run_test(0, '"Rhonda '.'Thurn"', undef, 49, $debug);
# $debug = 2;
&run_test(0, 'Martin '.'Thurn', 51, undef, $debug);
SKIP_BASIC:
;
# exit 0; # for debugging

# goto SKIP_WEB;
&new_engine('AltaVista::Web');
my $debug = 0;
# This test returns no results (but we should not get an HTTP error):
&run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $debug);
# This query returns 3 (or more) pages of results:
&run_test(0, 'Ch'.'eddar', 51, undef, $debug);
# &run_test(0, '+LS'.'AM +IS'.'I +Heide'.'mann +Aut'.'oSearch', 1, 9, $debug);
# &run_test(0, '+Thu'.'rn +Ga'.'loob', 11, 19, $debug);
# &run_test(0, 'Ma'.'rtin', 21, undef, $debug);
SKIP_WEB:
;
# goto SKIP_ADVANCEDWEB;
&new_engine('AltaVista::AdvancedWeb');
my $debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $debug);
SKIP_ADVANCEDWEB:
;
# goto SKIP_NEWS;
DEBUG_NOW:
&new_engine('AltaVista::News');
$debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $debug);
&run_test(0, "+perl +$WWW::Search::Test::bogus_query", 0, 0, $debug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
$debug = 0;
&run_test(0, 'Japan', 31, undef, $debug);
SKIP_NEWS:
;
# As of 2002-08, altavista.com does not have an Advanced search for
# news.
goto SKIP_ADVANCEDNEWS;
&new_engine('AltaVista::AdvancedNews');
$debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test(0, $WWW::Search::Test::bogus_query, 0, 0, $debug);
&run_test(0, "+perl +$WWW::Search::Test::bogus_query", 0, 0, $debug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
# This query returns 3 (or more) pages of results:
$debug = 99;
&run_test(0, 'li'.'nux', 61, undef, $debug);
SKIP_ADVANCEDNEWS:
;
# all done
exit 0;

sub new_engine
  {
  my $sEngine = shift;
  $WWW::Search::Test::oSearch = new WWW::Search($sEngine);
  ok(ref($WWW::Search::Test::oSearch), "instantiate WWW::Search::$sEngine object");
  } # new_engine

sub run_test
  {
  # Same arguments as WWW::Search::Test::count_results()
  my ($sType, $sQuery, $iMin, $iMax, $iDebug, $iPrintResults) = @_;
  my $iCount = &WWW::Search::Test::count_results(@_);
  cmp_ok($iCount, '>=', $iMin, qq{lower-bound num-hits for query=$sQuery}) if defined $iMin;
  cmp_ok($iCount, '<=', $iMax, qq{upper-bound num-hits for query=$sQuery}) if defined $iMax;
  } # run_test

__END__

Here is the original code

  $sSE = 'AltaVista';
  $sM = 'John Heidemann <johnh@isi.edu>';

  $file = 'zero_result_no_plus';
  $oTest->test($sSE, $sM, $file, $bogus_query, $TEST_EXACTLY);

  $file = 'zero_result';
  $query = '+LSAM +' . $bogus_query;
  $oTest->test($sSE, $sM, $file, $query, $TEST_EXACTLY);

  $file = 'one_page_result';
  $query = 
  $oTest->test($sSE, $sM, $file, $query, $TEST_RANGE, 2, 10);

  $file = 'two_page_result';
  $query = '+LS'.'AM +IS'.'I +Heide'.'mann';
  $oTest->test($sSE, $sM, $file, $query, $TEST_GREATER_THAN, 10);

  ######################################################################

  $sSE = 'AltaVista::Web';
  $sM = 'John Heidemann <johnh@isi.edu>';

  $file = 'zero_result';
  $query = '+LSA'.'M +' . $bogus_query;
  $oTest->test($sSE, $sM, $file, $query, $TEST_EXACTLY);

  $file = 'one_page_result';
  $query = '+LSA'.'M +AutoSea'.'rch';
  $oTest->test($sSE, $sM, $file, $query, $TEST_RANGE, 2, 10);

  $file = 'two_page_result';
  $query = '+LSA'.'M +IS'.'I +I'.'B';
  $oTest->test($sSE, $sM, $file, $query, $TEST_GREATER_THAN, 10);

  ######################################################################

  $sSE = 'AltaVista::AdvancedWeb';
  $sM = 'John Heidemann <johnh@isi.edu>';
  $oTest->not_working($sSE, $sM);
  # $query = 'LS'.'AM and ' . $bogus_query;
  # $oTest->test($sSE, $sM, 'zero', $query, $TEST_EXACTLY);
  # $query = 'LSA'.'M and AutoSea'.'rch';
  # $oTest->test($sSE, $sM, 'one', $query, $TEST_RANGE, 2, 11);
  # $query = 'LSA'.'M and IS'.'I and I'.'B';
  # $oTest->test($sSE, $sM, 'two', $query, $TEST_GREATER_THAN, 10);

  ######################################################################

  $sSE = 'AltaVista::News';
  $sM = 'John Heidemann <johnh@isi.edu>';
  $oTest->not_working($sSE, $sM);
  # $query = '+pe'.'rl +' . $bogus_query;
  # $oTest->test($sSE, $sM, 'zero', $query, $TEST_EXACTLY);
  # $query = '+Pe'.'rl +CP'.'AN';
  # $oTest->test($sSE, $sM, 'multi', $query, $TEST_GREATER_THAN, 30); # 30 hits/page

  ######################################################################

  $sSE = 'AltaVista::AdvancedNews';
  $sM = 'John Heidemann <johnh@isi.edu>';
  $oTest->not_working($sSE, $sM);
  # $query = 'per'.'l and ' . $bogus_query;
  # $oTest->test($sSE, $sM, 'zero', $query, $TEST_EXACTLY);
  # $query = 'Per'.'l and CP'.'AN';
  # $oTest->test($sSE, $sM, 'multi', $query, $TEST_GREATER_THAN, 70); # 30 hits/page

  ######################################################################

  $oTest->eval_test('AltaVista::Intranet');

__END__
