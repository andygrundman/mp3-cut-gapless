use strict;

use ExtUtils::MakeMaker qw(WriteMakefile);
use File::Spec::Functions;

my @INC;
my $DEFINES = '-Wall' unless $^O =~ /sun|solaris/i;
$DEFINES .= ' -Wno-unused-value -Wno-format-security' unless $^O =~ /Win32|sun|solaris/i;

unshift @INC, '-I. -I.. -Isrc -Iinclude';

my $inc_files = join(' ', glob 'include/*.h');
my $src_files = join(' ', glob 'src/*.c');

WriteMakefile(
    NAME              => 'MP3::Cut::Gapless',
    VERSION_FROM      => 'lib/MP3/Cut/Gapless.pm',
    PREREQ_PM         => {
        'Audio::Cuefile::Parser' => 0,
        'Digest::MD5'            => 0,
        'File::Path'             => 0,
        'File::Spec'             => 0,
    },
    ABSTRACT_FROM     => 'lib/MP3/Cut/Gapless.pm',
    AUTHOR            => 'Andy Grundman <andy@slimdevices.com>',
    INC               => join(' ', @INC),
    LIBS              => '',
    DEFINE            => $DEFINES,
    depend            => { 'Gapless.c' => "$inc_files $src_files" },
);
