# $rcs = ' $Id: Makefile.PL,v 1.6 2007/05/20 14:07:23 Daddy Exp $ ' ;

use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.145);

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
