# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormLoggerCGI;

use strict;
use Fcntl;
use MT;
use MT::App;
use MT::AForm;
use MT::AFormField;
use MT::AFormData;
use MT::AFormInputError;
use MT::AFormAccess;
use MT::AFormCounter;
use MT::AFormEntry;
use MT::AFormFile;

@AFormLoggerCGI::ISA = qw(MT::App);

sub script {
  return 'aform_logger.cgi';
}

sub init_request {
    my $app = shift;
    $app->SUPER::init_request(@_);
    $app->add_methods( AFormLoggerCGI => \&_AFormLoggerCGI );
    $app->{default_mode} = 'AFormLoggerCGI';
    $app->{requires_login} = 0;
    $app;
}

sub _AFormLoggerCGI {
    my $app = shift;
    my $q = $app->param;

    $q->param('_type', 'aform');

    # check params
    my $aform_id = $app->param('aform_id');
    return "Invalid request: aform_id" unless $aform_id;
    my $aform_url = $app->param('aform_url');
    return "Invalid request: aform_url" unless $aform_url;

    # check mode
    my $mode = $q->param('run_mode');
    return "Invalid request: mode" if ( ! ( $mode eq 'access' || $mode eq 'error' ) );

    # if access mode
    if ( $mode eq 'access' ) {
        return AFormLoggerCGI::save_accesslog($app, $q);
    } elsif ( $mode eq 'error' ) {
        return AFormLoggerCGI::save_errorlog($app, $q);
    }
}

sub save_accesslog
{
  my $app = shift;
  my $q = shift;

  my $is_mobile = $q->param('mobile') ? 1 : 0;

  my $model = $is_mobile ? 'aform_mobile_access' : 'aform_access';
  my $aform_access = $app->model($model)->load(
                       {
                         aform_id => $q->param('aform_id'),
                         aform_url => $q->param('aform_url'),
                       });
  if( ! $aform_access ){
    $aform_access = $app->model($model)->new;
  }

  $aform_access->set_values(
      {
        aform_id => $q->param('aform_id'),
        aform_url => $q->param('aform_url'),
        pv => $aform_access->pv + 1,
        session => $aform_access->session + ($q->param('first_access') ? 1 : 0),
      }
  );
  $aform_access->save();

  if ($is_mobile) {
    return AFormLoggerCGI::_dummy_image($app);
  }else{
    return 'true';
  }
}

sub _dummy_image {
  my $app = shift;

  $app->{no_print_body} = 1;

  my $image = $app->mt_dir . '/plugins/AForm/images/1x1.gif';
  sysopen(IMG, $image, O_RDONLY) or return;
  binmode IMG;
  binmode STDOUT;
  print "Content-type: image/gif\n\n";
  print while(<IMG>);
  close(IMG);
  return 1;
}

sub save_errorlog
{
  my $app = shift;
  my $q = shift;

  my $aform_field = $app->model('aform_field')->load($q->param('error_field_id'));

  my $aform_input_error = $app->model('aform_input_error')->new;

  $aform_input_error->set_values(
    {
      type => $q->param('type'),
      aform_id => $q->param('aform_id'),
      aform_url => $q->param('aform_url'),
      field_id => $q->param('error_field_id'),
      field_label => ($aform_field ? $aform_field->label : ''),
      error_value => $q->param('error_value'),
      error_ip => $ENV{'REMOTE_ADDR'},
    }
  );
  $aform_input_error->save();

  # delete old data
  my $MAX_ERROR_LOG = 1000;
  my $count = $app->model('aform_input_error')->count();
  if( $count > $MAX_ERROR_LOG ){
    my @aform_input_errors = $app->model('aform_input_error')->load(
                           {},
                           { sort => "created_on",
                             limit => $count - $MAX_ERROR_LOG,
                           });
    foreach $aform_input_error ( @aform_input_errors ){
      $aform_input_error->remove;
    }
  }

  return 'true';
}

1;
