# $rcs = ' $Id: Makefile.PL,v 1.16 2008/07/14 03:32:44 Martin Exp $ ' ;

use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.152);

author('Martin Thurn <mthurn@cpan.org>');
license('perl');

requires( perl => 5.004 );
requires('Date::Manip');
requires('HTML::TokeParser');
# requires('HTML::TreeBuilder');
build_requires('Test::More');
build_recommends('Test::Pod');
build_recommends('Test::Pod::Coverage');
# We need the verson which correctly handles "old" backends which have
# parse_tree() rather than the new _parse_tree():
requires('WWW::Search' => 2.561);
# We need the version with tm_run_test():
requires('WWW::Search::Test' => 2.263);

&WriteAll;

__END__
