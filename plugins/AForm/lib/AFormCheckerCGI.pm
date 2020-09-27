# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormCheckerCGI;

use strict;
use MT;
use MT::App;
use MT::Mail;
use AFormEngineCGI::Common;
use MT::AForm;
use MT::AFormField;
use MT::AFormData;
use MT::AFormInputError;
use MT::AFormAccess;
use MT::AFormCounter;
use MT::AFormEntry;
use MT::AFormFile;

@AFormCheckerCGI::ISA = qw(MT::App);

sub script {
  return 'aform_checker.cgi';
}

sub init_request {
    my $app = shift;
    $app->SUPER::init_request(@_);
    $app->add_methods( AFormCheckerCGI => \&_AFormCheckerCGI );
    $app->add_methods( rebuild_aform => \&_rebuild_aform );
    $app->{default_mode} = 'AFormCheckerCGI';
    $app->{requires_login} = 0;
    $app;
}

sub _AFormCheckerCGI {
    my $app = shift;

    my $fixed_callback = MT::Util::encode_js($app->param('callback'));
    $app->param('callback', $fixed_callback);

    my $q = $app->param;
    my $web_access_mode = ($ARGV[0] ne 'cron') ? 1 : 0;
    if( ! $web_access_mode ){
        $app->{no_print_body} = 1;
    }

    # get config values and check
    my $plugin = MT->component('AForm');
    my $check_when_first_access = $plugin->get_config_value('check_when_first_access');
    if( $web_access_mode && ! $check_when_first_access ){
        return 'false';
    }
    my $alert_mail = $plugin->get_config_value('alert_mail');
    if( !&AFormEngineCGI::Common::mail_check( $alert_mail ) ){
        return 'false';
    }
    my $last_count_check_date = int($plugin->get_config_value('last_count_check_date'));
    my $check_interval = _get_check_interval($plugin->get_config_value('check_interval'));
    my $now = time;
    if( $web_access_mode && ($last_count_check_date + $check_interval) > $now ){
        return 'false';
    }

    # check counts
    my $ret_confirm .= &AFormCheckerCGI::_check_count($app, $plugin, $alert_mail, 'confirm');
    my $ret_complete .= &AFormCheckerCGI::_check_count($app, $plugin, $alert_mail, 'complete');
    my $ret_msg = sprintf("confirm:%s\ncomplete:%s\n", $ret_confirm, $ret_complete);


    # remove counters
    $app->model('aform_counter')->remove_all;

    # set last check date
    $plugin->set_config_value('last_count_check_date', $now);

    if( $web_access_mode ){
        return $app->param('callback')."('$ret_msg')";
    }else{
        print $ret_msg;
    }
}


sub _check_count {
    my $app = shift;
    my $plugin = shift;
    my $alert_mail = shift;
    my $mode = shift;

    my $alert_min_pv;
    if( $mode eq 'confirm' ){
        $alert_min_pv = $plugin->get_config_value('alert_min_confirm_pv');
    }elsif( $mode eq 'complete' ){
        $alert_min_pv = $plugin->get_config_value('alert_min_complete_pv');
    }
    if( !&AFormEngineCGI::Common::num_check( $alert_min_pv ) ){
         $alert_min_pv = 1;        # force set default value
    }

    # load all aforms
    my @aforms = $app->model('aform')->load();

    # make mail_body
    my $send_mail = 0;
    my $mail_body = '';
    foreach my $aform ( @aforms ){
        my $is_published = $aform->status eq '2' ? 1 : 0;
        $mail_body .= "\n";
        $mail_body .= sprintf("ID: %03d %s\n", $aform->id, $is_published ? '' : '(Unpublished)');
        my @aform_entries = $app->model('aform_entry')->load( {aform_id => $aform->id} );
        if( ! @aform_entries ){
            next;
        }

        foreach my $aform_entry ( @aform_entries ){
            my $entry = $app->model('entry')->load($aform_entry->entry_id);
            if( ! $entry ){
                # remove aform_entry & ignore
                $aform_entry->remove;
                next;
            }

            my $aform_counter = $app->model('aform_counter')->load({ aform_id => $aform->id, aform_url => $entry->permalink });
            my $count = 0;
            if( $aform_counter ){
                if( $mode eq 'confirm' ){
                    $count = $aform_counter->confirm_pv;
                }elsif( $mode eq 'complete' ){
                    $count = $aform_counter->complete_pv;
                }
            }
            my $check_status = '[OK]';
            if( $count < $alert_min_pv && $is_published ){
                $check_status = '[NG]';
                $send_mail = 1;
            }
            $mail_body .= sprintf("%s %s (%0d/%0d)\n", $check_status, $entry->permalink, $count, $alert_min_pv);
        }
    }

    my $subject;
    if( $mode eq 'confirm' ){
        $subject = $plugin->translate('[Important] A-Form Confirmation report');
    }elsif( $mode eq 'complete' ){
        $subject = $plugin->translate('[Important] A-Form Complete report');
    }
    # send mail
    if( $send_mail ){
        my %mail_headers = (
            'From' => $alert_mail,
            'To' => $alert_mail,
            'Subject' => $subject . &AFormEngineCGI::Common::get_date(),
            'Return-Path' => $alert_mail,
            'Reply-To' => $alert_mail,
        );
        MT::Mail->send(\%mail_headers, $mail_body);
    }

    return 'success';
}

sub _get_check_interval {
    my $check_interval = shift;

    my $interval;
    if( $check_interval =~ m/^(\d+)min$/i ){
        $interval = int($1) * 60;
    }elsif( $check_interval =~ m/^(\d+)h$/i ){
        $interval = int($1) * 60 * 60;
    }elsif( $check_interval =~ m/^(\d+)day$/i ){
        $interval = int($1) * 60 * 60 * 24;
    }else{
        $interval = 60 * 60 * 24;
    }
    return $interval;
}

sub _rebuild_aform{
  my $app = shift;
  my $q = $app->param;
  my $aform_id = $q->param('aform_id');

  my $fixed_callback = MT::Util::encode_js($app->param('callback'));
  $app->param('callback', $fixed_callback);

  if( !$aform_id ){
    return $app->param('callback'). "('invalid request')";
  }

  my $aform = MT::AForm->load($aform_id);
  my $auto_status = $q->param('aform_auto_status') || 0;
  require AFormEngineCGI::FormMail;
  &AFormEngineCGI::FormMail::check_aform_is_active($aform);
  # rebuild entries if status was changed
  if( $auto_status ne $aform->auto_status ){
    my $mt = MT->instance;
    my @aform_entries = MT::AFormEntry->load({aform_id => $aform->id});
    foreach my $aform_entry (@aform_entries){
      if ($aform_entry->type eq 'content_data') {
        MT->log({"message" => sprintf("rebuild content_data(ID:%s) by aform_checker.cgi", $aform_entry->entry_id)});
        $mt->publisher->start_time(time + 60*10);	# 
        if (!$mt->rebuild_content_data(ContentData => $aform_entry->entry_id, BuildDependencies => 1)) {
          MT->log({"message" => sprintf("failed to rebuild content_data(ID:%s) by aform_checker.cgi. %s", $aform_entry->entry_id, $mt->errstr)});
        }
      }
      else {
        MT->log({"message" => sprintf("rebuild entry(ID:%s) by aform_checker.cgi", $aform_entry->entry_id)});
        $mt->publisher->start_time(time + 60*10);	# 
        if (!$mt->rebuild_entry(Entry => $aform_entry->entry_id, BuildDependencies => 1)) {
          MT->log({"message" => sprintf("failed to rebuild entry(ID:%s) by aform_checker.cgi. %s", $aform_entry->entry_id, $mt->errstr)});
        }
      }

      MT->run_callbacks('aform_after_auto_rebuild', $app, $aform_entry->entry_id);
    }
    return $app->param('callback'). "('rebuild')";
  }
  return $app->param('callback'). "('not-rebuild')";
}

1;
