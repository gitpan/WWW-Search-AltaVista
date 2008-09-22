# $rcs = ' $Id: Makefile.PL,v 1.18 2008/09/22 01:46:56 Martin Exp $ ' ;

use inc::Module::Install;

all_from('lib/WWW/Search/AltaVista.pm');
version(2.153);

requires( perl => 5.004 );
requires('Date::Manip');
requires('HTML::TokeParser');
# requires('HTML::TreeBuilder');
test_requires('Test::More');
test_recommends('Test::Pod');
test_recommends('Test::Pod::Coverage');
# We need the verson which correctly handles "old" backends which have
# parse_tree() rather than the new _parse_tree():
requires('WWW::Search' => 2.561);
# We need the version with tm_run_test():
requires('WWW::Search::Test' => 2.263);

WriteAll;

__END__
