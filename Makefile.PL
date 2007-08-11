# $rcs = ' $Id: Makefile.PL,v 1.8 2007/08/11 15:06:21 Daddy Exp $ ' ;

use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.147);

author('Martin Thurn <mthurn@cpan.org>');
license('perl');

requires( perl => 5.004 );
requires('Date::Manip');
requires('HTML::TreeBuilder');
build_requires('Test::More');
# We need the version with tm_run_test():
requires('WWW::Search::Test' => 2.263);

&WriteAll;

__END__
