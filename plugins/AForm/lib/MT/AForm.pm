# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AForm;

use strict;
use MT::Util qw(trim encode_html);

use MT::Object;
@MT::AForm::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',
		'title' => 'string(255) not null',
		'status' => 'string(20) not null',
		'thanks_url' => 'string(255)',
		'start_at' => 'datetime',
		'end_at' => 'datetime',
		'mail_to' => 'string(100)',
		'mail_from' => 'string(100)',
		'mail_cc' => 'string(100)',
		'mail_bcc' => 'string(100)',
		'mail_subject' => 'string(255)',
		'mail_header' => 'text',
		'mail_footer' => 'text',
		'is_replyed_to_customer' => 'boolean not null',
		'action_url' => 'string(255)',
		'data_id' => 'integer',
		'data_id_offset' => 'integer',
		'receive_limit' => 'integer',
		'msg_before_start' => 'text',
		'msg_limit_over' => 'text',
		'msg_after_end' => 'text',
		'auto_status' => 'integer',
		'check_immediate' => 'integer',
		'mail_admin_subject' => 'string(255)',
		'blog_id' => 'integer',
        'data_status_options' => 'text',
        'lang' => 'string(10) not null',
        'disable_preload' => 'integer not null',
        'member_already_send_redirect_url' => 'string(255)',
        'amember_edit_form_title' => 'string(255)',
        'amember_edit_form_thanks_url' => 'string(255)',
        'admin_mail_header' => 'text',
        'admin_mail_footer' => 'text',
        'mail_admin_from' => 'string(255)',
        'use_users_mail_from' => 'integer',
        'thanks_message' => 'text',
        'enable_recaptcha' => 'boolean not null',
        'ng_word' => 'text',
        'ban_ip' => 'text',
        'ip_ua_to_admin' => 'integer',
        'ip_ua_to_customer' => 'integer',
        'amember_edit_form_thanks_message' => 'text',
	},
	indexes => {
		'id' => 1,
                'title' => 1,
                'status' => 1,
                'start_at' => 1,
                'end_at' => 1,
                'auto_status' => 1,
                'blog_id' => 1,
	},
        defaults => {
                'is_replyed_to_customer' => 0,
                'data_id' => 0,
                'data_id_offset' => 0,
		'check_immediate' => 1,
        'blog_id' => 0,
        'lang' => 'ja',
        'disable_preload' => 0,
        'use_users_mail_from' => 1,
        'enable_recaptcha' => 0,
        'ip_ua_to_admin' => 0,
        'ip_ua_to_customer' => 0,
        },
	audit => 1,
	datasource => 'aform',
	primary_key => 'id'
});

my %STATUS = (
  0 => 'Unpublished',
  1 => 'Waiting',
  2 => 'Published',
  3 => 'Closed');

sub next {
  my $aform = shift;
  my ($options) = @_;
  my @next_aform = MT::App->model('aform')->load( 
                     { id => [ $aform->id, undef ] },
                     { 
                       sort => 'id',
                       direction => 'ascend',
                       range => { id => 1},
#                       limit => 1,
                     }
                   );
  foreach my $next (@next_aform) {
    if ($options->{'exclude_amember'} && $next->id == 999) {
      next;
    }
    if( AForm::CMS::aform_superuser_permission($next->id) ){
      return $next;
    }
  }
  return "";
}

sub previous {
  my $aform = shift;
  my ($options) = @_;
  my @prev_aform = MT::App->model('aform')->load( 
                     { id => [ undef, $aform->id ] },
                     { 
                       sort => 'id',
                       direction => 'descend',
                       range => { id => 1},
                       limit => 1,
                     }
                   );
  foreach my $prev (@prev_aform) {
    if ($options->{'exclude_amember'} && $prev->id == 999) {
      next;
    }
    if( AForm::CMS::aform_superuser_permission($prev->id) ){
      return $prev;
    }
  }
  return "";
}

sub set_status {
  my $aform = shift;
  my $status = shift;

  if( $status ne $aform->status ){
    $aform->set_values({status => $status});
    $aform->save;
  }
}

sub published {
  my $aform = shift;

  $aform->set_status(2);
}

sub unpublished {
  my $aform = shift;

  $aform->set_status(0);
}

sub set_values {
  my $obj = shift;
  my ($values) = @_;
  for my $col (keys %$values) {
    if( $col eq 'start_at' || $col eq 'end_at' ){
      if( $$values{$col} eq '' ){
        $$values{$col} = '1970-01-01 00:00:00';
      }
    }
  }
  return $obj->SUPER::set_values($values);
}

sub start_at {
  my $obj = shift;
  if (@_) {
    return $obj->SUPER::start_at(@_);
  }else{
    return $obj->_get_ts('start_at');
  }
}

sub end_at {
  my $obj = shift;
  if (@_) {
    return $obj->SUPER::end_at(@_);
  }else{
    return $obj->_get_ts('end_at');
  }
}

sub _get_ts {
  my $obj = shift;
  my $col = shift;

  my %values = %{ $obj->column_values };
  my $ts = $values{$col};
  if( $ts eq '19700101000000' ){
    $ts = '00000000000000';
  }
  return $ts;
}

sub increment_data_id {
  my $obj = shift;

  my $app = MT->instance;
  my $data_id = $obj->data_id;
  $data_id++;
  $obj->data_id($data_id);
  if (!$obj->save) {
    $app->log("AForm: MT::AForm::incremant_data_id was failed." . $obj->errstr);
    return undef;
  }
  return $data_id;
}

sub data_status_options_array {
  my $obj = shift;

  my @data_status_options = map{trim($_)} split(',', $obj->data_status_options);
  unless (grep {$_ eq 'ERROR'} @data_status_options) {
    push @data_status_options, 'ERROR';
  }
  return \@data_status_options;
}

sub data_status_option_default {
  my $obj = shift;

  my @data_status_options = map{trim($_)} split(',', $obj->data_status_options);
  return shift @data_status_options;
}

sub new_id {
  my $obj = shift;

  my $last_aform = MT::AForm->load({id => {not => 999}}, {sort => 'id', direction => 'descend', limit => 1});
  if (!$last_aform) {
    $last_aform = MT::AForm->new;
  }
  my $new_id = $last_aform->id + 1;
  if ($new_id == 999) {
    $new_id = 1000;
  }
  return $new_id;
}

sub save {
  my $obj = shift;

  if (!$obj->id) {
    $obj->id($obj->new_id);
  }
  $obj->SUPER::save(@_);
}

sub list_props {
  my $plugin = shift;

  my $props = {
    # ID
    id => {
      label => $plugin->translate('ID'),
      auto => 1,
      display => 'force',
      order => 100,
      html => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        return sprintf("%03d", $obj->id);
      },
    },
    # Form title
    title => {
      label => $plugin->translate('Title'),
      auto => 1,
      display => 'force',
      order => 200,
      html => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        my $link = "";
        if (AForm::CMS::can_do($app, $obj->blog_id, 'edit_aform')) {
          $link = $app->uri(mode => 'edit_aform_field', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
        }
        elsif (AForm::CMS::can_do($app, $obj->blog_id, 'manage_aform_data')) {
          $link = $app->uri(mode => 'manage_aform_data', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
        }
        elsif (AForm::CMS::can_do($app, $obj->blog_id, 'list_aform_input_error')) {
          $link = $app->uri(mode => 'list_aform_input_error', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
        }

        my $html = "";
        if ($link) {
          $html = '<a href="'. encode_html($link) .'">'. encode_html($obj->title) .'</a>';
          if (AForm::CMS::_is_amember_form($obj->id)) {
            $html .= ' (*)';
          }
        } else {
          $html = encode_html($obj->title);
        }
        return $html;
      },
    },
    # blog
    blog_id => {
      label => $plugin->translate('Blog'),
#      base => '__virtual.single_select',
      display => 'default',
      order => 250,
      html => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;
        
        my $blog_name = "";
        if ($obj->blog_id) {
          my $blog = MT::Blog->load($obj->blog_id);
          if ($blog) {
            $blog_name = $blog->name;
          }
        } else {
          $blog_name = $plugin->translate('Global');
        }
        return encode_html($blog_name);
      },
#      single_select_options => sub {
#        my $prop = shift;
#
#        my $app = MT->app;
#        my @blogs = MT::Blog->load();
#        my @options;
#        push @options, {label => $plugin->translate('Global'), value => ''};
#        foreach my $blog (@blogs) {
#          push @options, {label => $blog->name, value => $blog->id};
#        }
#        return \@options;
#      },
      bulk_sort => sub {
        my $prop = shift;
        my ($objs, $opts) = @_;

        return sort { $a->blog_id <=> $b->blog_id } @$objs;
      },
    },
    # website/blog for hide
    blog_name => {
      base => '__common.blog_name',
      display => 'none',
    },
    # status
    status => {
      label => $plugin->translate('Status'),
      base => '__virtual.single_select',
      display => 'default',
      order => 300,
      html => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        my $label = $plugin->translate($STATUS{$obj->status});

        my $link = "";
        if (AForm::CMS::can_do($app, $obj->blog_id, 'edit_aform')) {
          $link = $app->uri(mode => 'change_aform_status', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
        }

        my $html = "";
        if ($link) {
          $html = '<a href="'. encode_html($link) .'">'. encode_html($label) .'</a>';
        } else {
          $html = encode_html($label);
        }

        return $html;
      },
      single_select_options => sub {
        my $prop = shift;

        my @options;
        foreach my $key (sort keys %STATUS) {
          push @options, {label => $plugin->translate($STATUS{$key}), value => $key};
        }
        return \@options;
      },
    },
    # conversion
    conversion => {
      label => $plugin->translate('Conversion Rate'),
      display => 'default',
      order => 400,
      default_sort_order => 'descend',
      raw => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        my @aform_access = MT::AFormAccess->load({aform_id => $obj->id});
        my ($rate, $pv, $cv);
        foreach my $access (@aform_access) {
          $pv += $access->pv;
          $cv += $access->cv;
        }
        if ($pv && $pv > 0) {
          $rate = $cv / $pv * 100;
        } else {
          $rate = 0;
        }
        return $rate;
      },
      bulk_sort => sub {
        my $prop = shift;
        my ($objs, $opts) = @_;

        return sort { $prop->{raw}($prop, $a) <=> $prop->{raw}($prop, $b) } @$objs;
      },
      html => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        my $value = sprintf("%0.2f", $prop->{raw}($prop, @_)) . '%';
        my $link = "";
        if (AForm::CMS::can_do($app, $obj->blog_id, 'list_aform_input_error')) {
          $link = $app->uri(mode => 'list_aform_input_error', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
        }
        if ($link) {
          return '<a title="'.  encode_html($plugin->translate('conversion rate description')) .'" href="'. encode_html($link) .'">'. encode_html($value) .'</a>';
        } else {
          return encode_html($value);
        }
      },
    },
    # preview
    preview => {
      label => $plugin->translate('Preview'),
      display => 'force',
      order => 700,
      html => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        if (!AForm::CMS::can_do($app, $obj->blog_id, 'preview_aform')) {
          return;
        }
        my $link = $app->uri(mode => 'disp_aform', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
        my $image = $app->static_path . "images/sprite.svg#ic_permalink";
        return '<a class="action-link mt-open-dialog mt-modal-open status-view" data-mt-modal-large title="'. $plugin->translate('preview this form') .'" href="'. encode_html($link) .'"><svg role="img" class="mt-icon mt-icon--secondary"><use xlink:href="'. $image .'"></svg></a>';
      },
    },
    # place
    place => {
      label => $plugin->translate('Place AForm'),
      display => 'default',
      order => 600,
      default_sort_order => 'descend',
      raw => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        my $blog_id = $app->param('blog_id') || undef;

        my %terms;
        $terms{aform_id} = $obj->id;
        $terms{blog_id} = $blog_id if $blog_id;
          
        return MT::AFormEntry->count(\%terms);
      },
      html_link => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        if (!AForm::CMS::can_do($app, $obj->blog_id, 'list_aform_entry')) {
          return;
        }
        return $app->uri('mode' => 'list_aform_entry', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
      },
      bulk_sort => sub {
        my $prop = shift;
        my ($objs, $opts) = @_;

        return sort { $prop->{raw}($prop, $a) <=> $prop->{raw}($prop, $b) } @$objs;
      },
    },
    # operations
    operations => {
      label => $plugin->translate('Operation'),
      display => 'force',
      order => 50,
      html => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        my $html = "";
        # copy
        if (AForm::CMS::can_do($app, $obj->blog_id, 'copy_aform')) {
          my $copy_link = $app->uri(mode => 'copy_aform', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
          my $msg = $plugin->translate('Are you sure you want to Copy the A-Form?') . '\n\n';
          if ($app->blog) {
            $msg .= $plugin->translate('Warning: Copy a new form in the [_1].', $app->blog->name);
          } else {
            $msg .= $plugin->translate('Warning: Copy a new form in the System.');
          }
          my $image = $app->static_path . "images/sprite.svg#ic_duplicate";
          $html .= '<a href="javascript:void(0)" onclick="return exec_aform(\'copy_aform\', ' . $obj->id .', \''. encode_html($msg) .'\');" title="'. encode_html($plugin->translate('copy')) .'"><svg role="img" class="mt-icon mt-icon--secondary"><use xlink:href="'. $image .'"></svg></a>';
        }
        # delete
        if (AForm::CMS::can_do($app, $obj->blog_id, 'delete_aform')) {
          if (!AForm::CMS::_is_amember_form($obj->id)) {
            my $delete_link = $app->uri(mode => 'delete_aform', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
            my $msg = $plugin->translate('Are you sure you want to Delete the A-Form?');
            my $image = $app->static_path . "images/sprite.svg#ic_trash";
            $html .= ' <a href="javascript:void(0)" onclick="return exec_aform(\'delete_aform\', ' . $obj->id .', \''. encode_html($msg) .'\');" title="'. encode_html($plugin->translate('delete')) .'"><svg role="img" class="mt-icon mt-icon--secondary"><use xlink:href="'. $image .'"></svg></a>';
          }
        }

        return $html;
      },
    },
    # link to received data
    data => {
      label => $plugin->translate('Received Data'),
      display => 'default',
      order => 350,
      default_sort_order => 'descend',
      raw => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        return MT::AFormData->count({
            aform_id => $obj->id,
          });
      },
      html_link => sub {
        my $prop = shift;
        my ($obj, $app, $opts) = @_;

        if (!AForm::CMS::can_do($app, $obj->blog_id, 'manage_aform_data')) {
          return;
        }
        return $app->uri('mode' => 'manage_aform_data', args => {blog_id => $app->param('blog_id') || '', id => $obj->id});
      },
      bulk_sort => sub {
        my $prop = shift;
        my ($objs, $opts) = @_;

        return sort { $prop->{raw}($prop, $a) <=> $prop->{raw}($prop, $b) } @$objs;
      },
    },
  };
  return $props;
}

sub cms_pre_load_filtered_list {
  my ($cb, $app, $filter, $load_options, $cols) = @_;

  my $blog_id = $app->param('blog_id') || '';
  if ($blog_id) {
    # always include blog_id=0
    $$load_options{'terms'}{'blog_id'} = [0, $blog_id];
  }
}

sub list_template_param {
  my ($cb, $app, $param, $tmpl) = @_;

  my $blog_id = $app->param('blog_id') || '';
  # include aform_data_list_header.tmpl
  if (MT->version_id >= 5.13) {
    push @{$param->{'list_headers'}}, { filename => AForm::CMS::get_aform_dir() . '/tmpl/cms/listing/aform_list_header.tmpl', component => 'AForm'};
  }else{
    push @{$param->{'list_headers'}}, AForm::CMS::get_aform_dir() . '/tmpl/cms/listing/aform_list_header.tmpl';
  }
  $param->{'aform_manual_url'} = AForm::CMS::plugin()->manual_link;
  $param->{'current_blog_id'} = $blog_id;
  $param->{'can_create_aform'} = AForm::CMS::can_do($app, $blog_id, 'create_aform');
  $param->{'is_amember_installed'} = AForm::CMS::_is_amember_installed();
}

sub ip_check {
  my ($obj) = @_;

  return 1 unless $obj->ban_ip;
  my $ip = $ENV{'REMOTE_ADDR'};
  my @ban_list = grep { $_ ne '' } map { MT::Util::trim($_) } split("\n", $obj->ban_ip);
  if (grep { $_ eq $ip } @ban_list) {
    return 0;
  }
  return 1;
}

sub ng_word_check {
  my ($obj, $fields) = @_;

  return undef unless $obj->ng_word;
  my @ng_words = grep { $_ ne '' } map { MT::Util::trim($_) } split("\n", $obj->ng_word);
  return undef unless @ng_words;

  my @errors;
  foreach my $ng_word (@ng_words) {
    my $reg_exp = quotemeta($ng_word);
    foreach my $field (@$fields) {
      my $value = $field->{'label_value'};
      if (defined $value && $value =~ m/$reg_exp/i) {
        push @errors, $ng_word;
        last;
      }
    }
  }
  return \@errors;
}

1;

