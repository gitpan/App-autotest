
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Run test programs as soon as they are modified",
  "AUTHOR" => "Gregor Goldbach <glauschwuffel\@nomaden.org>",
  "BUILD_REQUIRES" => {
    "File::Basename" => 0,
    "TAP::Parser::Aggregator" => 0,
    "Test::Differences" => 0,
    "Test::Spec" => 0,
    "constant" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "App-autotest",
  "EXE_FILES" => [
    "scripts/autotest"
  ],
  "LICENSE" => "perl",
  "NAME" => "App::autotest",
  "PREREQ_PM" => {
    "Cwd" => 0,
    "File::ChangeNotify" => 0,
    "File::Find" => 0,
    "File::Spec" => 0,
    "FindBin" => 0,
    "Moose" => 0,
    "TAP::Harness" => 0,
    "Test::Spec" => "0.46",
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.004",
  "test" => {
    "TESTS" => "t/*.t t/features/*.t t/integration/*.t t/unit/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



