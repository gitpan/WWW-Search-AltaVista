
use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.14);

author('Martin Thurn <mthurn@cpan.org>');
license('perl');

requires( perl => 5.004 );
requires('Date::Manip');
requires('HTML::TreeBuilder');
requires('WWW::Search');

include_deps('Test::More', 5.004);
build_requires('Test::More');

check_nmake();      # check and download nmake.exe for Win32
&Makefile->write;
