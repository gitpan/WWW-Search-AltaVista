
use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.142);

author('Martin Thurn <mthurn@cpan.org>');
license('perl');

requires( perl => 5.004 );
requires('Date::Manip');
requires('HTML::TreeBuilder');
build_requires('Test::More');
requires('WWW::Search');

check_nmake();      # check and download nmake.exe for Win32
&Makefile->write;
