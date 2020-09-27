# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormEngineCGI::reCAPTCHA;
use strict;
use LWP::UserAgent;
use MT::Util;

sub siteverify_url {
	return 'https://www.google.com/recaptcha/api/siteverify';
}

sub check {
	my ($app, $plugin) = @_;

	my $blog_id = $app->param('blog_id') || 0;
	my $g_recaptcha_response = $app->param('g-recaptcha-response') || '';
	my $secret_key = $plugin->get_config_value('recaptcha_secret_key');
	my $remote_ip = $ENV{REMOTE_ADDR};

	$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
	my $ua = LWP::UserAgent->new();
	$ua->ssl_opts(verify_hostname => 0);
	my $response = $ua->post(siteverify_url(), {
		secret => $secret_key,
		response => $g_recaptcha_response,
		remoteip => $remote_ip,
	});
	if ($response->is_success()) {
		my $json = $response->decoded_content();
		my $result = MT::Util::from_json($json);
		if ($result->{success}) {
			return 1;
		} else {
			$app->log('AFormEngineCGI::reCAPTCHA ERROR: ' . $json);
		}
	} else {
		$app->log('AFormEngineCGI::reCAPTCHA ERROR: ' . $response->status_line);
	}
	return 0;
}

1;
