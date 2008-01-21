# $rcs = ' $Id: Makefile.PL,v 1.12 2008/01/21 02:02:00 Daddy Exp $ ' ;

use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.149);

author('Martin Thurn <mthurn@cpan.org>');
license('perl');

requires( perl => 5.004 );
requires('Date::Manip');
requires('HTML::TokeParser');
# requires('HTML::TreeBuilder');
build_requires('Test::More');
build_recommends('Test::Pod');
build_recommends('Test::Pod::Coverage');
# We need the version with tm_run_test():
requires('WWW::Search::Test' => 2.263);

&WriteAll;

__END__
