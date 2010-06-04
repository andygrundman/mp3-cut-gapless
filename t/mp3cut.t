use strict;

use File::Spec::Functions;
use FindBin ();
use Test::More tests => 22;

use MP3::Cut::Gapless;

### TODO
# silence frame
# silence frame with MPEG CRC
# preframe with mdss < 511

# 128k/44.1 LAME CBR
_test_read(
    file   => 'cbr-128-lame.mp3',
    name   => 'CBR 128k/44.1kHz LAME',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 147k/44.1 LAME VBR
_test_read(
    file   => 'vbr-147-lame.mp3',
    name   => 'VBR 147k/44.1kHz LAME',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 112k/44.1 non-LAME CBR with ID3v2 (iTunes-encoded)
_test_read(
    file   => 'cbr-112-itunes.mp3',
    name   => 'CBR 112k/44.1kHz non-LAME (iTunes)',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 118k/44.1 non-LAME VBR (iTunes-encoded)
_test_read(
    file   => 'vbr-118-itunes.mp3',
    name   => 'VBR 118k/44.1kHz non-LAME (iTunes)',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 128k/44.1 LAME CBR with MPEG CRC
_test_read(
    file   => 'cbr-128-lame-crc.mp3',
    name   => 'CBR 128k/44.1kHz LAME with MPEG CRC',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 96k/22.05 LAME CBR MPEG2
_test_read(
    file   => 'cbr-96-22050hz-MPEG2-lame.mp3',
    name   => 'CBR 96k/22.05kHz LAME MPEG2',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 80k/11.025 LAME CBR MPEG2.5
_test_read(
    file   => 'cbr-80-11025hz-MPEG25-lame.mp3',
    name   => 'CBR 80k/11.025kHz LAME MPEG2.5',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 128k/44.1 LAME CBR with an existing PCUT tag
_test_read(
    file   => 'cbr-128-lame-pcut.mp3',
    name   => 'CBR 128k/44.1kHz LAME PCUT',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 56k/32kHz mono LAME ABR
_test_read(
    file   => 'abr-56-mono-32khz-lame.mp3',
    name   => 'ABR 56k/32kHz mono LAME',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 112k/48kHz LAME ABR
_test_read(
    file   => 'abr-112-48khz-lame.mp3',
    name   => 'ABR 112k/48kHz LAME',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

# 128k/44.1 LAME with invalid LAME CRC
_test_read(
    file   => 'cbr-128-lame-invalid-crc.mp3',
    name   => '128k/44.1kHz invalid LAME CRC',
    splits => [
        [ 0, 1000 ],
        [ 1000, 2000 ],
    ],
);

sub _test_read {
    my %args = @_;
    
    for my $split ( @{ $args{splits} } ) {
        my ($start, $end) = @{$split};
        
        my $c = MP3::Cut::Gapless->new(
            file     => _f( $args{file} ),
            start_ms => $start,
            end_ms   => $end,
        );

        my $out;
        while ( $c->read( my $buf, 4096 ) ) {
            $out .= $buf;
        }

        is( _compare(\$out, $args{file} . "_${start}-${end}"), 1, $args{name} . " ${start}ms - ${end}ms ok" );
    }
}

sub _f {    
    return catfile( $FindBin::Bin, 'mp3', shift );
}

sub _load {
    my $path = shift;
    
    open my $fh, '<', $path or die "Cannot open $path";
    my $data = do { local $/; <$fh> };
    close $fh;
    
    return \$data;
}    

sub _compare {
    my ( $test, $path ) = @_;
    
    my $ref = _load( catfile( $FindBin::Bin, 'ref', $path ) );
    
    return $$ref eq $$test;
}

sub _out {
    my $ref = shift;
    
    open my $fh, '>', 'out.mp3';
    print $fh $$ref;
    close $fh;
}
