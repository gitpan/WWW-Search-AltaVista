use ExtUtils::MakeMaker;
WriteMakefile(
              'NAME'	=> 'WWW::Search::AltaVista',
              'VERSION' => 2.01,
              'PREREQ_PM' => {
                              'WWW::Search::Test' => 2.11,
                             },
             );
