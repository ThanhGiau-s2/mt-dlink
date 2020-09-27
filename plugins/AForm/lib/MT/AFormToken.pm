# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormToken;

use strict;
use MT::Util;

use MT::Object;
@MT::AFormToken::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',
		'token' => 'string(255) not null',
		'status' => 'integer',
		'expired_at' => 'datetime',
	},
	indexes => {
		'id' => 1,
		'token' => 1,
		'status' => 1,
	},
	defaults => {
	},
	audit => 1,
	datasource => 'aform_token',
	primary_key => 'id'
});

sub INVALID () {0}
sub READY () {1}
sub FINISHED () {2}

sub get_date {
	my ($ts) = @_;

	my ($ss, $ii, $hh, $dd, $mm, $yy) = localtime($ts);
	$yy += 1900;
	$mm += 1;
	return sprintf("%04d-%02d-%02d %02d:%02d:%02d", $yy, $mm, $dd, $hh, $ii, $ss);
}

sub regist_token {
	my ($app, $token) = @_;

	clear_old_tokens($app);

	my $aform_token = MT::AFormToken->new;
	$aform_token->set_values({
		token => $token,
		status => MT::AFormToken::READY(),
		expired_at => get_date(time + 60*60*1),
	});
	$aform_token->save or return $app->error($aform_token->errstr);
	return 1;
}

sub finish_token {
	my ($app, $token) = @_;

	clear_old_tokens($app);

	my @aform_tokens = MT::AFormToken->load({token => $token});
	foreach my $aform_token (@aform_tokens) {
		$aform_token->status(MT::AFormToken::FINISHED());
		$aform_token->save or return $app->error($aform_token->errstr);
	}
}

sub check_token {
	my ($app, $token) = @_;

	clear_old_tokens($app);

	my $aform_token = MT::AFormToken->load({token => $token});
	if (!$aform_token) {
		return MT::AFormToken::INVALID();
	}
	return $aform_token->status;
}

sub clear_old_tokens {
	my ($app) = @_;

	my @aform_tokens = MT::AFormToken->load(
		{expired_at => [undef, get_date(time)]}, 
		{range => {expired_at => 1}}
	);
	foreach my $aform_token (@aform_tokens) {
		$aform_token->remove or return $app->error($aform_token->errstr);
	}
	return 1;
}

1;

