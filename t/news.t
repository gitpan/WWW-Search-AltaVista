
use ExtUtils::testlib;
use Test::More no_plan;
BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test') };
BEGIN { use_ok('WWW::Search::AltaVista') };

&my_engine('AltaVista::News');
# goto DEBUG_NOW;

# goto SKIP_NEWS;
my $iDebug = 0;
my $iDump = 0;
# These tests return no results (but we should not get an HTTP error):
&my_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
&my_test(0, "+perl +$WWW::Search::Test::bogus_query", 0, 0, $iDebug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
DEBUG_NOW:
$iDebug = 0;
$iDump = 0;
&my_test(0, 'Japan', 31, undef, $iDebug, $iDump);
cmp_ok(31, '<=', $WWW::Search::Test::oSearch->approximate_hit_count,
       'approximate_hit_count');
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
&my_engine('AltaVista::AdvancedNews');
goto SKIP_ADVANCEDNEWS;
$iDebug = 0;
# These tests return no results (but we should not get an HTTP error):
&my_test(0, $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
&my_test(0, "+perl +$WWW::Search::Test::bogus_query", 0, 0, $iDebug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
# This query returns 3 (or more) pages of results:
$iDebug = 0;
&my_test(0, 'li'.'nux', 61, undef, $iDebug);
cmp_ok(61, '<=', $WWW::Search::Test::oSearch->approximate_hit_count,
       'approximate_hit_count');
SKIP_ADVANCEDNEWS:
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
  } # my_test

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
