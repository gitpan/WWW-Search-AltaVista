
use inc::Module::Install;

name('WWW-Search-AltaVista');
version(2.12);

author('Martin Thurn <mthurn@cpan.org>');
license('perl');

requires('Date::Manip');
requires('HTML::TreeBuilder');
requires('WWW::Search');

# Test::More is needed for `make test`:
include_deps('Test::More', 5.004);
requires('Test::More');

check_nmake();      # check and download nmake.exe for Win32
&Makefile->write;
