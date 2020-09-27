my @CRCTABLE = (0..255);
for my $c (@CRCTABLE) {
  $c = $c & 1 ? 0xedb88320 ^ ($c >> 1) : $c >> 1 for 0..7;
}

sub _crc32 {
  my $v = shift;
  my( $format ) = @_;

  my $w = ref $v ? $v : \$v;
  my $r = 0xFFFFFFFF;
  for my $c ( unpack 'C*', $$w ) {
    $r = ( $r >> 8 ) ^ $CRCTABLE[ $r & 0xFF ^ $c ];
  }

  $format = "%08X" unless $format;
  return sprintf($format, $r ^ 0xFFFFFFFF);
}

1;
