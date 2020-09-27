package SendAttachedMail;
use strict;
use utf8;

use Encode;
use MIME::Lite;
use MIME::Types;
our $MAX_LINE_OCTET = 998;

sub send {
	my ($params) = @_;

	my $app = MT->instance;
	my $mgr = MT->config;
	my $xfer = $mgr->MailTransfer;
	my $mail_enc = uc( $mgr->MailEncoding || $mgr->PublishCharset );
	$mail_enc = lc $mail_enc;

	eval "require MIME::EncWords;";
	my $enable_mime_encwords = $@ ? 0 : 1;
	if (!$enable_mime_encwords) {
		MT->log("AForm: Cannot use MIME::EncWords");
	}

	# encode body
	my $body = $params->{Body};
	$body = encode_text_encode($body, undef, $mail_enc);

	# encode headers
	if ($enable_mime_encwords) {
		$params->{Subject} = MIME::EncWords::encode_mimeword(encode_text_encode($params->{Subject}, undef, $mail_enc), 'b', $mail_enc);
		foreach my $key (("From","To","Cc","Bcc","Reply-To","Return-Path")) {
			my $val = $params->{$key};
			if(ref $val eq 'ARRAY') {
				foreach (@$val) {
					if (m/^(.+?)\s*(<[^@>]+@[^>]+>)\s*$/) {
						$_ = MIME::EncWords::encode_mimeword(
							encode_text_encode($1, undef, $mail_enc),
							'b',
							$mail_enc
						) . ' ' . $2;
					}
				}
			} else {
				if ( $val && $val =~ m/^(.+?)\s*(<[^@>]+@[^>]+>)\s*$/ ) {
					$params->{$key} = MIME::EncWords::encode_mimeword(
						encode_text_encode($1, undef, $mail_enc),
						'b',
						$mail_enc
					) . ' ' . $2;
				}
			}
		}
	} else {
		$params->{Subject} = encode_text_encode($params->{Subject}, undef, $mail_enc);
		$params->{From} = encode_text_encode($params->{From}, undef, $mail_enc);
	}

	my $body_encoding = ( ($mail_enc) !~ m/utf-?8/ ) ? '7bit' : '8bit';
    if ( $body =~ /^.{@{[$MAX_LINE_OCTET+1]},}/m && eval { require MIME::Base64 } ) {
        $body_encoding = 'base64';
    }


	my $msg;
	if ($params->{Attaches} && @{$params->{Attaches}}) {
		$msg = MIME::Lite->new(
			From => $params->{From},
			To => $params->{To},
			Cc => $params->{Cc},
			Bcc => $params->{Bcc},
			"Reply-To" => $params->{'Reply-To'},
			"Return-Path" => $params->{"Return-Path"},
			Subject => $params->{Subject},
			Type => 'multipart/mixed',
		);

		$msg->attach(
			Type => 'text/plain; charset=' . $mail_enc,
			Encoding => $body_encoding,
			Data => $body,
		);

		foreach my $attache (@{$params->{Attaches}}) {
			my $filename = encode_text_encode($attache->{Filename}, undef, $mail_enc);
			$filename = MIME::EncWords::encode_mimeword($filename, 'b', $mail_enc) if $enable_mime_encwords;
			my ($mime_type, ) = MIME::Types::by_suffix($attache->{Filename});
			$mime_type = 'application/octet-stream' unless $mime_type;
			$msg->attach(
				Type => $mime_type,
				Path => $attache->{Path},
				Filename => $filename,
				Disposition => 'attachment',
				Encoding => 'base64',
			);
		}
	} else {
		$msg = MIME::Lite->new(
			From => $params->{From},
			To => $params->{To},
			Cc => $params->{Cc},
			Bcc => $params->{Bcc},
			"Reply-To" => $params->{'Reply-To'},
 			"Return-Path" => $params->{"Return-Path"},
			Subject => $params->{Subject},
			Data => $body,
			Type => 'text/plain; charset=' . $mail_enc,
			Encoding => $body_encoding,
		);
	}

	my %hdrs;
	# ヘッダをセット
	# $msg->fieldsにヘッダが入っている
	# 全て小文字になっているので、頭1文字を大文字に変える
	foreach my $field (@{$msg->fields}) {
		my ($k, $v) = @$field;
		next if $v eq '';
		$k = ucfirst $k;
		# To, Cc, Bccは配列にする
		if ($k eq 'To' || $k eq 'Cc' || $k eq 'Bcc') {
			push @{$hdrs{$k}}, $v;
		} else {
			$hdrs{$k} = $v;
		}
	}
	# 古いMT対応
	# Toは配列ではなくカンマ区切り文字列とする
	if (MT->version_id lt '5.2') {
		$hdrs{'To'} = join(",", @{$hdrs{'To'}});
	}
	# ヘッダ以外の本文（添付ファイルを含んでいる）
	my $body_string = $msg->body_as_string();

	# 送信はMT::Mailに任せる
	my $mt_mail = MT::Mail->new;
	if ($xfer eq 'sendmail') {
		$mt_mail->_send_mt_sendmail(\%hdrs, $body_string, $mgr);
	}
	elsif ($xfer eq 'smtp') {
		$mt_mail->_send_mt_smtp(\%hdrs, $body_string, $mgr);
	}
	elsif ($xfer eq 'debug') {
		$mt_mail->_send_mt_debug(\%hdrs, $body_string, $mgr);
	}
	else {
		return $app->error(MT->translate("Unknown MailTransfer method '[_1]'", $xfer));
	}
	if ($mt_mail->errstr) {
		return $app->error($mt_mail->errstr);
	} else {
		return 1;
	}
}

sub encode_text_encode {
	my ($text, $from, $to) = @_;

	require MT::I18N::default;
	$text = Encode::encode_utf8($text) if Encode::is_utf8($text);
	$text = MT::I18N::default->encode_text_encode($text, $from, $to);
	return $text;
}

1;
