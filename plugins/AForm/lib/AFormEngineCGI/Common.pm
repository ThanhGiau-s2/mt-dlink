# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormEngineCGI::Common;

use MT::Util (days_in);

sub get_date {
    ( $sec, $min, $hour, $mday, $mon, $year ) = localtime( time );
    $year += 1900;
    $mon += 1;
    return sprintf("%d/%02d/%02d %02d:%02d:%02d", $year,$mon,$mday, $hour,$min,$sec);
}

sub must_check {
    my( $str ) = @_;
	# 全角スペースだけで構築された値は必須チェックでは
	# 許可させないため、まずは全角スペースを半角に変換する
    &z2h_space( \$str );
    return 0 if(not (defined($str) and not $str =~ /^\s*$/));
    return 1;
}

sub num_check {
    my( $str ) = @_;
    return 0 if(not (defined($str) and not $str =~ /^\s*$/));
    return( ( $str !~ m/[^\d-]/ ) );
}

sub int_check {
    my( $str ) = @_;
    return 0 if(not (defined($str) and not $str =~ /^\s*$/));
    return( ( $str !~ m/[^\d]/ ) );
}

sub mail_check {
    my( $str ) = @_;

    return ( $str =~ m/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/i );
}

sub url_check {
    my ( $url ) = @_;

    if( $url !~ m/^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i ){
        return 0;
    }
    return 1;
}

sub zipcode_check {
    my ( $zipcode ) = @_;

    if ( !( $zipcode =~ m/^\d{3}\-?\d{4}$/ ) ){
        return 0;
    }
    return 1;
}

sub date_check {
    my( $yy, $mm, $dd ) = @_;
    if( !$yy || !$mm || !$dd ){
        return 0;
    }
    if( $mm < 1 || $mm > 12 ){
        return 0;
    }
    if( $dd > days_in($mm, $yy) ){
        return 0;
    }
    return 1;
}

sub password_check {
    my($str) = @_;
    
    return ( $str =~ m/^[\x21-\x7E]*$/i );
}

sub ascii_check {
    my($str, $allow_chars) = @_;
    
    my $pattern = '[^\x21-\x7E]';
    my $errors = '';
    while ($str =~ m/($pattern)/g) {
        $errors .= $1;
    }
    return $errors;
}

sub kana_check {
    my($str) = @_;

    utf8::decode($str);
    if ($str !~ /^([\x{30A1}-\x{30FC}])+$/) {
      return 0;
    }
    return 1;
}

sub z2h_space {
    my( $r_str ) = @_;
    $$r_str =~ s/\xA1\xA1/\x20/g;
}

sub h2z_space {
    my( $r_str ) = @_;
    $$r_str =~ s/\x20/\xA1\xA1/g;
}

sub obj_to_json {
  my $obj = shift;

  if( MT->version_number >= 4.25 ){
    return MT::Util::to_json($obj);
  }else{
    require JSON;
    return JSON::objToJson($obj);
  }
}

sub json_to_obj {
  my $json = shift;

  require JSON;
  if( MT->version_number >= 4.25 ){
    return MT::Util::from_json($json);
  }else{
    return JSON::jsonToObj($json);
  }
}

sub decode_aform_chr {
  my $str = shift;
  
  if( Encode::is_utf8($str) ){
    utf8::encode($str);
  }
  $str =~ s/([^\x01-\x7f]*)/&_unpack_aform_chr($1)/ge;
  return $str;
}

sub _unpack_aform_chr {
  my $str = shift;

  if( $str ne '' ){
    $str = 'chr[' . join(':', unpack("C*", $str)) . ']';
  }
  return $str;
}

sub encode_aform_chr {
  my $str = shift;

  $str =~ s/chr\[([^\]]*)\]/&_pack_chr($1)/ge;
  if( ! Encode::is_utf8($str) ){
    utf8::decode($str);
  }
  return $str;
}

sub _pack_chr {
  my $chr = shift;
  return pack("C*", split(':', $chr));
}

sub encode_aform_chr_all {
    my ( $ref ) = @_;
    if ( 'ARRAY' eq ref($ref) ) {
        my @tmp;
        foreach ( @$ref ) {
            next unless defined $_;
            if ( ref($_) ) {
                push @tmp, encode_aform_chr_all($_);
            }
            else {
                # Do not decode numeric values because
                # they may be used as a boolean value in JavaScript.
                if ( $_ !~ /^\d+$/ ) {
                    push @tmp, &encode_aform_chr($_);
                }
                else {
                    push @tmp, 0 + $_;
                }
            }
        }
        return \@tmp;
    }
    elsif ( 'HASH' eq ref($ref) ) {
        my %tmp;
        while ( my ( $k, $v ) = each %$ref ) {
            next unless defined $v;
            if ( ref($v) ) {
                $tmp{$k} = encode_aform_chr_all($v);
            }
            else {
                # Do not decode numeric values because
                # they may be used as a boolean value in JavaScript.
                if ( $v !~ /^\d+$/ ) {
                    $tmp{$k} = &encode_aform_chr($v);
                }
                else {
                    $tmp{$k} = 0 + $v;
                }
            }
        }
        return \%tmp;
    }
    elsif ( 'SCALAR' eq ref($ref) ) {
        # Do not decode numeric values because
        # they may be used as a boolean value in JavaScript.
        my $tmp;
        if ( $$ref !~ /^\d+$/ ) {
            $tmp = &encode_aform_chr($$ref);
        }
        else {
            $tmp = 0 + $$ref;
        }
        return \$tmp;
    }
    return $ref;

}

sub _recurcive_encode {
    my ( $ref ) = @_;
    if ( 'ARRAY' eq ref($ref) ) {
        my @tmp;
        foreach ( @$ref ) {
            next unless defined $_;
            if ( ref($_) ) {
                push @tmp, _recurcive_encode($_);
            }
            else {
                # Do not decode numeric values because
                # they may be used as a boolean value in JavaScript.
                if ( $_ !~ /^\d+$/ ) {
                    push @tmp, MT::I18N::encode( MT->config->PublishCharset, $_ );
                }
                else {
                    push @tmp, 0 + $_;
                }
            }
        }
        return \@tmp;
    }
    elsif ( 'HASH' eq ref($ref) ) {
        my %tmp;
        while ( my ( $k, $v ) = each %$ref ) {
            next unless defined $v;
            if ( ref($v) ) {
                $tmp{$k} = _recurcive_encode($v);
            }
            else {
                # Do not decode numeric values because
                # they may be used as a boolean value in JavaScript.
                if ( $v !~ /^\d+$/ ) {
                    $tmp{$k} = MT::I18N::encode( MT->config->PublishCharset, $v );
                }
                else {
                    $tmp{$k} = 0 + $v;
                }
            }
        }
        return \%tmp;
    }
    elsif ( 'SCALAR' eq ref($ref) ) {
        # Do not decode numeric values because
        # they may be used as a boolean value in JavaScript.
        my $tmp;
        if ( $$ref !~ /^\d+$/ ) {
            $tmp = MT::I18N::encode( MT->config->PublishCharset, $$ref );
        }
        else {
            $tmp = 0 + $$ref;
        }
        return \$tmp;
    }
    return $ref;
}


1;
