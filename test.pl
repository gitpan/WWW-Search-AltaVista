# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use ExtUtils::testlib;
use WWW::Search::Test qw( new_engine run_test );

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..25\n"; }
END { print "not ok 1\n" unless $loaded; }
use WWW::Search::AltaVista;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$WWW::Search::Test::iTest = 1;

&new_engine('AltaVista');
my $debug = 0;

# goto SKIP_BASIC;
# These tests return no results (but we should not get an HTTP error):
&run_test($WWW::Search::Test::bogus_query, 0, 0, $debug);
&run_test("+LSAM +$WWW::Search::Test::bogus_query", 0, 0, $debug);
&run_test('+LS'.'AM +IS'.'I +Heide'.'mann +Aut'.'oSearch', 1, 9, $debug);
&run_test('+Thu'.'rn +Ga'.'loob', 11, 19, $debug);
&run_test('Ma'.'rtin', 21, undef, $debug);
SKIP_BASIC:

# goto SKIP_WEB;
&new_engine('AltaVista::Web');
my $debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test($WWW::Search::Test::bogus_query, 0, 0, $debug);
&run_test('+LS'.'AM +IS'.'I +Heide'.'mann +Aut'.'oSearch', 1, 9, $debug);
&run_test('+Thu'.'rn +Ga'.'loob', 11, 19, $debug);
&run_test('Ma'.'rtin', 21, undef, $debug);
SKIP_WEB:

# goto SKIP_ADVANCEDWEB;
&new_engine('AltaVista::AdvancedWeb');
my $debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test($WWW::Search::Test::bogus_query, 0, 0, $debug);
# This query returns 1 page of results:
&run_test('LS'.'AM AND Aut'.'oSearch', 2, 9, $debug);
# This query returns 2 pages of results:
&run_test('LSA'.'M and IS'.'I and I'.'B', 11, 19, $debug);
# This query returns 3 (or more) pages of results:
&run_test('Ma'.'rtin', 21, undef, $debug);
SKIP_ADVANCEDWEB:

# goto SKIP_NEWS;
&new_engine('AltaVista::News');
$debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test($WWW::Search::Test::bogus_query, 0, 0, $debug);
&run_test("+perl +$WWW::Search::Test::bogus_query", 0, 0, $debug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
$debug = 0;
&run_test('li'.'nux', 31, undef, $debug);
SKIP_NEWS:

# goto SKIP_ADVANCEDNEWS;
&new_engine('AltaVista::AdvancedNews');
my $debug = 0;
# These tests return no results (but we should not get an HTTP error):
&run_test($WWW::Search::Test::bogus_query, 0, 0, $debug);
&run_test("+perl +$WWW::Search::Test::bogus_query", 0, 0, $debug);
# This query returns 1 page of results:
# This query returns 2 pages of results:
# This query returns 3 (or more) pages of results:
&run_test('li'.'nux', 61, undef, $debug);
SKIP_ADVANCEDNEWS:



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
