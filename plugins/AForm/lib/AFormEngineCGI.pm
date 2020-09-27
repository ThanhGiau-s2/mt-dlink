# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormEngineCGI;

use strict;
use Fcntl;
use MT;
use MT::App;
use MT::Blog;
use MT::Entry;
use MT::Builder;
use MT::Template;
use MT::TemplateMap;
use MT::Template::Context;
use MT::PluginData;
use MT::AForm;
use MT::AFormField;
use MT::AFormData;
use MT::AFormInputError;
use MT::AFormAccess;
use MT::AFormCounter;
use MT::AFormEntry;
use MT::AFormFile;
use MT::Util;
use AFormEngineCGI::FormMail;
use HTTP::Date;
use AFormEngineCGI::reCAPTCHA;

@AFormEngineCGI::ISA = qw(MT::App);

sub script {
  return 'aform_engine.cgi';
}

sub init_request {
    my $app = shift;
    $app->SUPER::init_request(@_);
    $app->add_methods( AFormEngineCGI => \&_AFormEngineCGI );
    $app->{default_mode} = 'AFormEngineCGI';
    $app->{requires_login} = 0;
    MT->run_callbacks('aform_after_aform_engine_init_request', $app);
    $app;
}

sub _AFormEngineCGI {
    my $app = shift;
    my $q = $app->param;
    my $request = $ENV{"REDIRECT_URL"};

#    $AFormEngineCGI::plugin = new MT::Plugin::AForm({ id => 'AForm', l10n_class => 'AForm::L10N' });
    return 'Invalid request' unless $app->param('blog_id');
    return 'Invalid request' unless $app->blog;

    my $plugin = MT->component('AForm');

    $app->{plugin_template_path} = 'plugins/AForm/tmpl';
    $q->param('_type', 'aform');

    # check mode
    my $mode = $q->param('run_mode');
    if( $app->param('Back') ){
        $mode = 'form';
    }
    if ( ! ( $mode eq 'confirm' || $mode eq 'complete' || $mode eq 'form' ) ) {
      return AFormEngineError($app, $plugin->translate('Invalid request'));
    }

    # check params
    my $aform_id = int($app->param('id'));
    return AFormEngineError($app, $plugin->translate('Invalid request')) unless $aform_id;

    if ($mode eq 'complete') {
      my $error = undef;
      # lock
      my $data_dir = AFormEngineCGI::FormMail::_get_upload_dir($app);
      if (!-w $data_dir) {
        $error = $plugin->translate('Error: Cannot write to [_1]', $data_dir);
      } else {
        my $lock_file = $data_dir . 'lock';
        if ((-e $lock_file && !-w $lock_file) || !&aform_lock($app, $lock_file)) {
          $error = $plugin->translate('Error: Cannot write to [_1]', $lock_file);
        }
      }
      if ($error) {
        my $aform_for_error = $app->model('aform')->load($aform_id);
        return AFormEngineError($app, $plugin->translate('Invalid request')) unless $aform_for_error;
        return AFormEngineError($app, $error, $aform_for_error);
      }
    }

    # aform should load after lock_file
    my $aform = $app->model('aform')->load($aform_id);
    return AFormEngineError($app, $plugin->translate('Invalid request')) unless $aform;

    if (!$aform->ip_check()) {
        return AFormEngineError($app, $plugin->translate('Access denied.'));
    }

    MT->set_language($aform->lang);
    if( !$aform || $aform->status ne '2' ){
###        &AFormEngineCGI::FormMail::sendmail_unpublished_form_access($app, $aform);
        return AFormEngineError($app, $plugin->translate('Acceptance end'));
    }
    my($auto_status, $message) = AFormEngineCGI::FormMail::check_aform_is_active($aform);
    if( $auto_status ne 'published' ){
        return AFormEngineError($app, $message, $aform);
    }

    # reCAPTCHA check
    if ($mode eq 'confirm' && $aform->enable_recaptcha) {
      if (!AFormEngineCGI::reCAPTCHA::check($app, $plugin)) {
        return AFormEngineError($app, $plugin->translate('Invalid post.'), $aform);
      }
    }

    # token check
    if ($mode eq 'complete' && !$app->param('aform_is_mobile') && !$app->param('nocheck_token')) {
      my $ret_check_token = AFormEngineCGI::FormMail::check_authenticity_token($app);
      if ($ret_check_token == MT::AFormToken::INVALID()) {
        return AFormEngineError($app, $plugin->translate('Invalid access.'), $aform);
      }
      elsif ($ret_check_token == MT::AFormToken::FINISHED()) {
        return AFormEngineError($app, $plugin->translate('Already sent.'), $aform);
      }
    }

    # back
    if ($mode eq 'form') {
      return AFormEngineCGI::FormMail::back_form($app, $aform);
    }

    # upload
    if( $mode eq 'confirm' ){
      AFormEngineCGI::FormMail::upload_to_tmp_dir($app, $aform);
    }

    # validation
    my %error_msgs = AFormEngineCGI::FormMail::validate_param($app, $aform);

    if ($error_msgs{'redirect_url'}) {
        return $app->redirect($error_msgs{'redirect_url'});
    }

    if ( %error_msgs > 0 ) {
        return AFormEngineError($app, \%error_msgs, $aform);
    }

    # counter
    &AFormCountUp($app);

    # if confirmation mode
    if ( $mode eq 'confirm' ) {
        return AFormEngineCGI::FormMail::generate_confirmation_view($app, $aform);
    } elsif ( $mode eq 'complete' ) {
        my $ret;
        # check double registration
        if ( ! AFormEngineCGI::FormMail::check_double_submit($app, $aform) ) {
            # store inquiry data
            $ret = AFormEngineCGI::FormMail::store($app, $aform);
            if (!$ret) {
                my $aform_errors = "";
                if ($app->param('aform_errors') && ref $app->param('aform_errors') eq 'ARRAY') {
#                    $aform_errors = join(' ', @{$app->param('aform_errors')});
                }
                return AFormEngineError($app, $plugin->translate('Failed to Store. Please try again for a while.') . $aform_errors, $aform);
            }
            # notify by email to admin
#            if ( $aform->mail_to ne '' ) {
                AFormEngineCGI::FormMail::send_mail($app, $aform, $ret->{'aform_data_id'});
                if ($app->errstr) {
                    return AFormEngineError($app, $plugin->translate('Failed to Send mail.') . $app->errstr, $aform);
                }
#            }
            # notify by email to customer
#            if ( $aform->is_replyed_to_customer ) {
                AFormEngineCGI::FormMail::reply_to_customer($app, $aform, $ret->{'aform_data_id'});
                if ($app->errstr) {
                    return AFormEngineError($app, $plugin->translate('Failed to Send mail.') . $app->errstr, $aform);
                }
#            }
        } else {
            return AFormEngineError($app, $plugin->translate('Double submit warning. Please try again for a while.'), $aform);
        }

        # unlock
        &aform_unlock($app);

        # redirect to thanks_url
        my $thanks_url = ($app->param('amember_edit_mode') ? $aform->amember_edit_form_thanks_url : $aform->thanks_url);
        if( $thanks_url eq 'finish' ){
          return AFormEngineCGI::FormMail::generate_finish_view($app, $aform, $ret->{'received_id'});
        }elsif( $thanks_url ne '' ){
          return $app->redirect($thanks_url);
        }else{
          if( $app->param('use_js') ){
            return $plugin->translate('The data was sent. <a href="[_1]">Back to top page</a>', $app->blog->site_url);
          }else{
            return AFormEngineCGI::FormMail::generate_finish_view($app, $aform, $ret->{'received_id'});
          }
        }
    }
}

sub AFormEngineError {
  my $app = shift;
  my $msg = shift;
  my $aform = shift;

  &aform_unlock($app);
  if( $app->param('use_js') ){
    if( ref $msg eq 'HASH' ){
      my $buf = "";
      foreach my $key (keys %$msg) {
        $buf .= join("<br />", @{$$msg{$key}});
      }
      $buf = MT::Util::encode_html($buf);
      return $buf;
    }
    return $msg;
  }else{
    if( ref $msg eq 'HASH' ){
      return AFormEngineCGI::FormMail::generate_error_view($app, $msg, $aform);
    }else{
      my %msgs = ('other_error' => [$msg]);
      return AFormEngineCGI::FormMail::generate_error_view($app, \%msgs, $aform);
    }
  }
}


sub AFormCountUp {
  my $app = shift;

  my $aform_counter = $app->model('aform_counter')->load(
                       {
                         aform_id => int($app->param('id')),
                         aform_url => $app->param('aform_url'),
                       });
  if( ! $aform_counter ){
    $aform_counter = $app->model('aform_counter')->new;
    $aform_counter->set_values(
                       {
                          aform_id => int($app->param('id')),
                          aform_url => $app->param('aform_url'),
                       });
  }

  if( $app->param('run_mode') eq 'confirm'){
    $aform_counter->set_values(
       {
          confirm_pv => $aform_counter->confirm_pv + 1,
       });
  }elsif( $app->param('run_mode') eq 'complete'){
    $aform_counter->set_values(
      { 
          complete_pv => $aform_counter->complete_pv + 1,
      }
    );
  }
  $aform_counter->save();
}

sub aform_lock {
    my $app = shift;
    my $lock_file = shift;

    sysopen(AFORM_LOCK, $lock_file, O_WRONLY | O_CREAT);
    for (my $i = 0; $i < 30; $i++) {
        if (flock(AFORM_LOCK, 6)) {
            return 1;
        }
        sleep 1;
    }
    return 0;
}

sub aform_unlock {
    my $app = shift;

    close(AFORM_LOCK);
}

1;


