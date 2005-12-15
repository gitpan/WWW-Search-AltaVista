# $rcs = ' $Id: Makefile.PL,v 1.5 2005/12/15 02:00:17 Daddy Exp $ ' ;

use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.144);

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
