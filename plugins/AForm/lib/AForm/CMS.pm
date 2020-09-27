# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AForm::CMS;

use strict;
use Fcntl;
use MT::Util qw( format_ts encode_html );
use File::Basename qw( dirname );

sub manage_aform {
    my $app = shift;

    if ($app->version_number >= 5.1) {
      return $app->redirect($app->uri( 
        mode => 'list', 
        args => {
            _type => 'aform',
            blog_id => $app->param('blog_id'),
        },
      ));
    } else {
      return _list_aform($app);
    }
}

sub _list_aform {
    my $app = shift;

    my $blog_id = $app->param('blog_id') || 0;

    return $app->return_to_dashboard( permission => 1 )
      unless can_list_aform();

    $app->{plugin_template_path} = 'plugins/AForm/tmpl';

    my %terms;
    if( $blog_id ){
        $terms{'blog_id'} = [0, $blog_id];
    }
    my $is_aform_superuser = aform_superuser_permission();
    my $html = $app->listing({
        Type => 'aform',
        Terms => \%terms,
        Args => { sort => 'id' },
        Code => \&_form_item_for_display,
        Params => {
          saved_deleted => ( $app->param('saved_deleted') || '' ),
          form_not_found => ( $app->param('form_not_found') || '' ),
          form_copied => ( $app->param('form_copied') || '' ),
#          help_url => plugin()->doc_link,
          can_create_aform => can_do($app, $blog_id, 'create_aform'),
          can_copy_aform => can_do($app, $blog_id, 'copy_aform'),
#          can_publish_aform => $is_aform_superuser,
          aform_manual_url => plugin()->manual_link,
          can_create_amember_form => &can_create_amember_form($app),
          is_amember_installed => &_is_amember_installed(),
          current_blog_id => ($app->blog ? $app->blog->id : ''),
          current_blog_name => ($app->blog ? $app->blog->name : ''),
        },
    });
    return $app->build_page($html);
}

sub _form_item_for_display {
    my $obj = shift;
    my $item_hash = shift;

    my $app = MT->app;
    $item_hash->{'disp_id'} = sprintf("%03d", $item_hash->{'id'});

#    $item_hash->{'title'} = MT::I18N::encode_text($item_hash->{'title'}, 'utf8');

    $item_hash->{'publish_term'} = sprintf("%s - %s", $item_hash->{'start_at'}, $item_hash->{'end_at'});

    my %status = (
        '0' => 'Unpublished',
        '1' => 'Waiting',
        '2' => 'Published',
        '3' => 'Closed' );

    $item_hash->{'status'} = $item_hash->{'status'} ? $item_hash->{'status'} : 0;
    $item_hash->{'status_label'} = plugin()->translate( $status{$item_hash->{'status'}} );

    # data count
    $item_hash->{'data_count'} = MT::App->model('aform_data')->count( { aform_id => $item_hash->{'id'} } );
    # session count
    my @aform_access = MT::App->model('aform_access')->load( { aform_id => $item_hash->{'id'} } );
    foreach my $access ( @aform_access ){
        $item_hash->{'session'} += $access->session;
        $item_hash->{'pv'} += $access->pv;
        $item_hash->{'cv'} += $access->cv;
    }
    if( $item_hash->{'pv'} && $item_hash->{'pv'} > 0 ){
        $item_hash->{'conversion_rate'} = sprintf("%0.2f", $item_hash->{'cv'} / $item_hash->{'pv'} * 100) . '%';
    }else{
        $item_hash->{'conversion_rate'} = '-.--';
    }
    $item_hash->{'is_superuser'} = aform_superuser_permission($obj->id);
    if( $obj->blog_id ){
        my $blog = MT::Blog->load($obj->blog_id);
        if ($blog) {
            $item_hash->{'blog_name'} = $blog->name;
        }
    }else{
        $item_hash->{'blog_name'} = plugin()->translate('Global'),
    }
    $item_hash->{'can_edit_aform'} = can_do($app, $obj->blog_id, 'edit_aform');
    $item_hash->{'can_delete_aform'} = can_do($app, $obj->blog_id, 'delete_aform');
    $item_hash->{'can_manage_aform_data'} = can_do($app, $obj->blog_id, 'manage_aform_data');
    $item_hash->{'can_list_aform_input_error'} = can_do($app, $obj->blog_id, 'list_aform_input_error');
    $item_hash->{'can_preview_aform'} = can_do($app, $obj->blog_id, 'preview_aform');
    $item_hash->{'can_list_aform_entry'} = can_do($app, $obj->blog_id, 'list_aform_entry');

    $item_hash->{'is_amember_form'} = &_is_amember_form($item_hash->{'id'});

    $item_hash->{'number_of_entry'} = MT::AFormEntry->count({
        aform_id => $item_hash->{'id'},
      },{
        'join' => ['MT::Entry', undef, {id => \'=aform_entry_entry_id'}, undef],
    });
}


sub _create_aform {
    my $app = shift;
    my $blog_id = $app->param('blog_id') || 0;
    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $blog_id, 'create_aform');

    my $q = $app->param;
    $app->{plugin_template_path} = 'plugins/AForm/tmpl';
    $q->param('_type', 'aform');

    my %param = (
      plugin_static_uri => _get_plugin_static_uri($app),
#      help_url => plugin()->doc_link,
      'a-member' => ($app->param('a-member') || ''),
      'langs' => &_get_langs($app),
      'default_lang' => MT->config('DefaultLanguage'),
      'blog_name' => ($app->blog ? $app->blog->name : ''),
    );
    my $html = $app->load_tmpl('create_aform.tmpl', \%param);
    return $app->build_page($html, \%param);
}


sub _edit_aform {
    my $app = shift;
    # check params
    my $blog_id = $app->param('blog_id') || '';
    my $aform_id = $app->param('id') || '';
    return $app->errtrans("Invalid request") unless $aform_id;
    my $aform = $app->model('aform')->load($aform_id);
    return $app->errtrans("Invalid request") unless $aform;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'edit_aform');

    return $app->return_to_dashboard()
      if ($blog_id && $aform->blog_id && $aform->blog_id ne $blog_id);

    my $q = $app->param;
    $app->{plugin_template_path} = 'plugins/AForm/tmpl';
    $q->param('_type', 'aform');

    # get webpage
    my %terms;
    $terms{class} = 'page';
    $terms{blog_id} = $blog_id if $blog_id;
    my @pages = $app->model('page')->load( \%terms );
    my $is_webpage = 0;
    my $amember_edit_form_is_webpage = 0;
    my @webpages;
    for(my $i =0; $i < scalar @pages; $i++ ){
       $webpages[$i]{'title'} = $pages[$i]->title;
       $webpages[$i]{'link'} = $pages[$i]->permalink;
       if( $pages[$i]->permalink eq $aform->thanks_url ){
         $webpages[$i]{'selected'} = 1;
         $is_webpage = 1;
       }
       if( $pages[$i]->permalink eq $aform->amember_edit_form_thanks_url ){
         $webpages[$i]{'amember_edit_form_selected'} = 1;
         $amember_edit_form_is_webpage = 1;
       }
    }
    my $thanks_type = '';
    if( $aform->thanks_url eq 'finish' ){
        $thanks_type = 'finish';
    }
    elsif( $aform->thanks_url ne '' ){
        if( $is_webpage ){
            $thanks_type = 'webpage';
        }else{
            $thanks_type = 'url';
        }
    }
    my $amember_edit_form_thanks_type = '';
    if( $aform->amember_edit_form_thanks_url eq 'finish' ){
        $amember_edit_form_thanks_type = 'finish';
    }
    elsif( $aform->amember_edit_form_thanks_url ne '' ){
        if( $amember_edit_form_is_webpage ){
            $amember_edit_form_thanks_type = 'webpage';
        }else{
            $amember_edit_form_thanks_type = 'url';
        }
    }

    my( $start_at_date, $start_at_time ) = split(' ', &_get_datetime_by_ts($aform->start_at));
    my( $end_at_date, $end_at_time ) = split(' ', &_get_datetime_by_ts($aform->end_at));
    my %param = (
      plugin_static_uri => _get_plugin_static_uri($app),
      exists_form_data => _exists_form_data($app, $aform_id),
      alert_save_msg => plugin()->translate('Your changes has not saved! Are you ok?'),
      alert_disable_tab_msg => plugin()->translate('alert disable tab'),
      webpages => \@webpages,
      display_title => $aform_id ? sprintf("%s(aform%03d)", plugin()->translate('Edit [_1]', $aform->title), $aform_id) : plugin()->translate('New A-Form'),
#      help_url => plugin()->doc_link,
      is_webpage => $is_webpage,
      data_id_offset => $aform->data_id_offset,
      start_at_date => $start_at_date,
      start_at_time => $start_at_time,
      end_at_date => $end_at_date,
      end_at_time => $end_at_time,
      receive_limit => $aform->receive_limit,
      check_immediate => $aform->check_immediate,
      current_blog_id => $blog_id,
      data_status_options => $aform->data_status_options,
      thanks_type => $thanks_type,
      langs => &_get_langs($app),
      is_amember_form => &_is_amember_form($aform->id),
      disable_preload => $aform->disable_preload,
      is_amember_installed => &_is_amember_installed(),
      member_already_send_redirect_url => $aform->member_already_send_redirect_url,
      amember_edit_form_is_webpage => $amember_edit_form_is_webpage,
      amember_edit_form_thanks_type => $amember_edit_form_thanks_type,
      aform_action_tabs => &get_aform_action_tabs($app, $blog_id, $aform_id, 'edit_aform'),
      mail_admin_from => $aform->mail_admin_from,
      use_users_mail_from => $aform->use_users_mail_from,
      thanks_message => $aform->thanks_message,
      enable_recaptcha => $aform->enable_recaptcha,
      ng_word => $aform->ng_word,
      ban_ip => $aform->ban_ip,
      status => $aform->status,
      ip_ua_to_admin => $aform->ip_ua_to_admin,
      ip_ua_to_customer => $aform->ip_ua_to_customer,
      amember_edit_form_thanks_message => $aform->amember_edit_form_thanks_message,
    );
    %param = (%{$aform->column_values}, %param);

    ## Load next and previous entries for next/previous links
    if( my $next = $aform->next ){
      $param{next_aform_id} = $next->id;
    }
    if( my $previous = $aform->previous ){
      $param{previous_aform_id} = $previous->id;
    }
    $param{aform_reserve_installed} = _aform_reserve_installed();
    $param{aform_payment_installed} = _aform_payment_installed();

#    my $html = $app->edit_object(
#      {
#        output => 'edit_aform.tmpl',
#        screen_class => 'edit-aform',
#      }
#    );
    my $html = $app->load_tmpl('edit_aform.tmpl', \%param);
    return $app->build_page($html, \%param);
}


sub _save_aform {
    my $app = shift;
    my $aform_id = $app->param('id') || '';
    my $blog_id = $app->param('blog_id') || 0;

    my $is_new_aform = 0;
    my $check_immediate = $app->param('check_immediate') || 0;
    my $aform;
    if( $aform_id ){
      $aform = $app->model('aform')->load($aform_id);
    }else{
      $is_new_aform = 1;
      $aform = $app->model('aform')->new;
      $aform->blog_id($blog_id);
      $check_immediate = $aform->check_immediate;
      $app->param('thanks_url_setting', 'finish');
    }
    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'edit_aform');

    # check params
    if( $app->param('title') eq '' ){
      return $app->error( $app->translate( "Please enter Title." ) );
    }

    MT->run_callbacks('aform_before_save_aform', $app)
      or return $app->error($app->errstr);

    # save data
    my $mail_to_changed = ( $aform->mail_to ne $app->param('mail_to') ) ? 1 : 0;

    my $thanks_url = '';
    if( $app->param('thanks_url_setting') eq 'url' ){
      $thanks_url = $app->param('thanks_url');
    }elsif( $app->param('thanks_url_setting') eq 'webpage' ){
      $thanks_url = $app->param('thanks_url_select');
    }elsif( $app->param('thanks_url_setting') eq 'finish' ){
      $thanks_url = 'finish';
    }
    my $amember_edit_form_thanks_url = '';
    if( $app->param('amember_edit_form_thanks_url_setting') eq 'url' ){
      $amember_edit_form_thanks_url = $app->param('amember_edit_form_thanks_url');
    }elsif( $app->param('amember_edit_form_thanks_url_setting') eq 'webpage' ){
      $amember_edit_form_thanks_url = $app->param('amember_edit_form_thanks_url_select');
    }elsif( $app->param('amember_edit_form_thanks_url_setting') eq 'finish' ){
      $amember_edit_form_thanks_url = 'finish';
    }

    my $start_at = '';
    my $end_at = '';
    if( $app->param('start_at_date') ){
      my $start_at_time = $app->param('start_at_time');
      if ($start_at_time =~ m/^\d{2}:\d{2}$/) {
        $start_at_time .= ':00';
      }
      elsif ($start_at_time !~ m/^\d{2}:\d{2}:\d{2}$/) {
        $start_at_time = '00:00:00';
      }
      $start_at = $app->param('start_at_date') .' '. $start_at_time;
    }
    if( $app->param('end_at_date') ){
      my $end_at_time = $app->param('end_at_time');
      if ($end_at_time =~ m/^\d{2}:\d{2}$/) {
        $end_at_time .= ':00';
      }
      elsif ($end_at_time !~ m/^\d{2}:\d{2}:\d{2}$/) {
        $end_at_time = '23:59:59';
      }
      $end_at = $app->param('end_at_date') .' '. $end_at_time;
    }

    $aform->set_values(
      {
        title => $app->param('title'),
        status =>  ( $app->param('status') || 0 ),
        mail_to => ( $app->param('mail_to') || '' ),
        mail_from => ( $app->param('mail_from') || '' ),
        mail_cc => ( $app->param('mail_cc') || '' ),
        mail_bcc => ( $app->param('mail_bcc') || '' ),
        mail_subject => ( $app->param('mail_subject') || $app->param('title') || '' ),
        mail_admin_subject => ( $app->param('mail_admin_subject') || $app->param('title') || '' ),
#        is_replyed_to_customer => ( $app->param('is_replyed_to_customer') || 0 ),
        is_replyed_to_customer => 1,
        thanks_url => ( $thanks_url || '' ),
        mail_header => ( $app->param('mail_header') || '' ),
        mail_footer => ( $app->param('mail_footer') || '' ),
        admin_mail_header => ( $app->param('admin_mail_header') || '' ),
        admin_mail_footer => ( $app->param('admin_mail_footer') || '' ),
        action_url => ( $app->param('action_url') || '' ),
        data_id_offset => ( $app->param('data_id_offset') || 0 ),
        start_at => $start_at,
        end_at => $end_at,
        receive_limit => int($app->param('receive_limit')),
        msg_before_start => ( $app->param('msg_before_start') || '' ),
        msg_limit_over => ( $app->param('msg_limit_over') || '' ),
        msg_after_end => ( $app->param('msg_after_end') || '' ),
        check_immediate => $check_immediate,
        data_status_options => ( $app->param('data_status_options') || '' ),
        lang => ($app->param('lang') || ''),
        disable_preload => ($app->param('disable_preload') || 0),
        member_already_send_redirect_url => ($app->param('member_already_send_redirect_url') || ''),
        amember_edit_form_title => ($app->param('amember_edit_form_title') || ''),
        amember_edit_form_thanks_url => ($amember_edit_form_thanks_url || ''),
        mail_admin_from => ($app->param('mail_admin_from') || ''),
        use_users_mail_from => ($app->param('use_users_mail_from') || 0),
        thanks_message => ($app->param('thanks_message') || ''),
        enable_recaptcha => ($app->param('enable_recaptcha') || 0),
        ng_word => ($app->param('ng_word') || ''),
        ban_ip => ($app->param('ban_ip') || ''),
        ip_ua_to_admin => ($app->param('ip_ua_to_admin') || 0),
        ip_ua_to_customer => ($app->param('ip_ua_to_customer') || 0),
        amember_edit_form_thanks_message => ($app->param('amember_edit_form_thanks_message') || ''),
      }
    );
    if( $app->param('reset_data_id') ){
      $aform->set_values({ 'data_id' => 0 });
    }
    if( $is_new_aform ){
      $aform->set_values({ 'blog_id' => $blog_id });
      $aform->set_values({ 'data_status_options' => $app->translate('data_status_options_default') });
    }
  eval {
    $aform->save() 
      or die $app->translate( "Saving aform object failed: [_1]", $aform->errstr );

    MT->run_callbacks('aform_after_save_aform', $app, $aform->id)
      or die "error at aform_after_save_aform: ". $app->errstr;
  };
  if ($@) {
    MT->log('AForm: ' . $@);
    return $app->error($@);
  }

    my $msg_key;
    if( $app->param('mail_to') eq '' ){
        $msg_key = 'saved_changes_mail_to_is_null';
    }elsif( $mail_to_changed ){
        $msg_key = 'saved_changes_mail_to_changed';
    }else{
        $msg_key = 'saved_changes';
    }

    if( $aform_id ){
      $app->log({message => $app->translate('[_1](ID:[_2]) has been saved by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});
      return &_rebuild_aform_entry( 
          $app, 
          [ $aform_id ], 
          'edit_aform', 
          (id => $aform->id, $msg_key => 1, blog_id => $app->param('blog_id')) 
      );
    }else{
      $app->log({message => $app->translate('[_1](ID:[_2]) has been created by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});
      return 'success:' . $aform->id;
    }
}


sub _copy_aform {
    my $app = shift;

    my $blog_id = $app->param('blog_id') || 0;
    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $blog_id, 'copy_aform');

    for my $id ( $app->param('id') ) {
        # load orignal aform
        my $aform = MT::AForm->load($id);
        return $app->redirect( $app->uri( mode => 'manage_aform', args => { blog_id => $app->param('blog_id') || '', form_not_found => 1} ) )
          if ( !$aform );

        # copy aform
        my $new_aform = $aform->clone({except => {'id'}});
        $new_aform->set_values({
            id => undef,
            title => $app->translate('Copied ') . $aform->title,
            status => 0,	# Unpulished
            data_id => undef,
            blog_id => $blog_id,
        });
        $new_aform->save()
          or return $app->error(
            $app->translate( "Coping aform object failed: [_1]", $new_aform->errstr ) );

        # load original aform fields
        my @aform_fields = MT::AFormField->load( { aform_id => $aform->id }, { 'sort' => 'sort_order' } );

        # copy aform fields
        foreach my $aform_field ( @aform_fields ){
            my $new_aform_field = MT::AFormField->new;
            $new_aform_field->set_values({
                aform_id => int($new_aform->id),
                type => $aform_field->type,
                label => $aform_field->label,
                is_necessary => int($aform_field->is_necessary),
                sort_order => int($aform_field->sort_order),
                property => $aform_field->property,
                parts_id => $aform_field->parts_id,
            });
            $new_aform_field->save()
              or return $app->error(
                $app->translate( "Coping aform field object failed: [_1]", $new_aform_field->errstr ) );
        }

        $app->log({message => $app->translate('[_1](ID:[_2]) has been copied as [_3](ID:[_4]) by [_5](ID:[_6]).', $aform->title, $aform->id, $new_aform->title, $new_aform->id, $app->user->name, $app->user->id), blog_id => $new_aform->blog_id});
    }

    return $app->redirect( $app->uri( mode => 'manage_aform', args => { blog_id => $app->param('blog_id') || '', form_copied => 1} ) );
}


sub _delete_aform {
    my $app = shift;

    my $q   = $app->param;
    my $type = 'aform';
    my $class = $app->model($type);

    for my $id ( $q->param('id') ) {
      my $obj = $class->load($id);
      return $app->redirect( $app->uri( mode => 'manage_aform', args => { blog_id => $app->param('blog_id') || '', form_not_found => 1} ) )
        if ( !$obj );
      return $app->return_to_dashboard( permission => 1 )
        unless can_do($app, $obj->blog_id, 'delete_aform');
    }

    my @delete_ids;
    for my $id ( $q->param('id') ) {
        next unless $id;    # avoid 'empty' ids
        my $obj = $class->load($id);
        next unless $obj;
        my $blog_id = $obj->blog_id;
        my $title = $obj->title;
        $app->run_callbacks( 'cms_delete_permission_filter.' . $type,
            $app, $obj )
          || return $app->error(
            $app->translate( "Permission denied: [_1]", $app->errstr() ) );
        $obj->remove
          or return $app->errtrans(
            'Removing [_1] failed: [_2]',
            $app->translate($type),
            $obj->errstr
          );

        # delete fields & data
        MT::AFormField->remove({ aform_id => $id });
        MT::AFormData->remove({ aform_id => $id });
        MT::AFormInputError->remove({ aform_id => $id });
        MT::AFormAccess->remove({ aform_id => $id });
        MT::AFormCounter->remove({ aform_id => $id });

        MT->run_callbacks('aform_after_delete_aform', $app, $id)
          or return $app->error($app->errstr);

        $app->log({message => $app->translate('[_1](ID:[_2]) has been deleted by [_3](ID:[_4]).', $title, $id, $app->user->name, $app->user->id), blog_id => $blog_id});

        push(@delete_ids, $id);
    }

    my $return = &_rebuild_aform_entry( 
        $app, 
        \@delete_ids, 
        'manage_aform', 
        (saved_deleted => 1, blog_id => $app->param('blog_id')) 
    );
    # remove aform_entry
    for my $id ( $q->param('id') ) {
        next unless $id;    # avoid 'empty' ids
        MT::AFormEntry->remove({aform_id => $id});
    }
    return $return;
}


sub _edit_aform_field {
    my $app = shift;
    # check params
    my $blog_id = $app->param('blog_id') || '';
    my $aform_id = $app->param('id');
    return $app->errtrans("Invalid request") unless $aform_id;
    my $aform = MT::AForm->load($aform_id);
    return $app->errtrans("Invalid request") unless $aform;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'edit_aform_field');

    return $app->return_to_dashboard()
      if ($blog_id && $aform->blog_id && $aform->blog_id ne $blog_id);

    $app->session('aform_id', $aform_id);

    my $q = $app->param;
    $app->{plugin_template_path} = 'plugins/AForm/tmpl';
    $q->param('_type', 'aform_field');

    # get AFormField data
    my @aform_fields = MT::AFormField->load(
      # where
      {
        aform_id => $aform_id,
      },
      # order by
      { 'sort' => 'sort_order' },
    );

    # make json data
    require AFormEngineCGI::Common;
    my @fields;
    foreach my $aform_field ( @aform_fields ){
      push(@fields, {
        id => int($aform_field->id),
        type => $aform_field->type,
        label => $aform_field->label,
        is_necessary => int($aform_field->is_necessary),
        sort_order => int($aform_field->sort_order),
        property => $aform_field->_get_property,  # property is saved json format
        parts_id => ($aform_field->parts_id || ''),
      });
    }
    my $json_data = { fields => \@fields };
    my $json_aform_fields = &AFormEngineCGI::Common::obj_to_json($json_data);


    # make json phrases for javascript
    my $prefecture_list = plugin()->translate('PrefectureList');
    $prefecture_list = '' if $prefecture_list eq 'PrefectureList';
    my %phrases = (
      'Undefined' => plugin()->translate('Undefined'),
      'type label' => plugin()->translate('AForm Field Type Label'),
      'type note' => plugin()->translate('AForm Field Type Note'),
      'type text' => plugin()->translate('AForm Field Type Text'),
      'type textarea' => plugin()->translate('AForm Field Type Textarea'),
      'type select' => plugin()->translate('AForm Field Type Select'),
      'type checkbox' => plugin()->translate('AForm Field Type Checkbox'),
      'type radio' => plugin()->translate('AForm Field Type Radio'),
      'type upload' => plugin()->translate('AForm Field Type Upload'),
      'type parameter' => plugin()->translate('AForm Field Type Parameter'),
      'necessary' => plugin()->translate('necessary'),
      'not necessary' => plugin()->translate('not necessary'),
      'necessary description' => plugin()->translate('necessary description'),
      'privacy policy warning' => plugin()->translate('privacy policy warning'),
      'edit label' => plugin()->translate('edit label'),
      'copy' => plugin()->translate('copy'),
      'delete' => plugin()->translate('delete'),
      'move-up' => plugin()->translate('up'),
      'move-down' => plugin()->translate('down'),
      'add value' => plugin()->translate('add value'),
      'edit' => plugin()->translate('edit'),
      'delete' => plugin()->translate('delete'),
      'Value' => plugin()->translate('Value'),
      'Email' => plugin()->translate('Email'),
      'Tel' => plugin()->translate('Tel'),
      'URL' => plugin()->translate('URL'),
      'ZipCode' => plugin()->translate('ZipCode'),
      'Prefecture' => plugin()->translate('Prefecture'),
      'PrefectureList' => eval('[' . $prefecture_list .']'),
      'please select' => plugin()->translate('please select'),
      'use default' => plugin()->translate('use default'),
      'Privacy' => plugin()->translate('Privacy'),
      'privacy_link' => plugin()->translate('privacy_link'),
      'Edit Privacy Link' => plugin()->translate('Edit Privacy Link'),
      'Agree' => plugin()->translate('Agree'),
      'delete default' => plugin()->translate('delete default'),
      'At least one option is required.' => plugin()->translate('At least one option is required.'),
      'description when there is no field' => plugin()->translate('description when there is no field'),
      'is replyed to customer' => plugin()->translate('is replyed to customer'),
      'check status is reflected in default check status of form.' => plugin()->translate('check status is reflected in default check status of form.'),
      'input example is not displayed' => plugin()->translate('input example is not displayed'),
      'edit input example' => plugin()->translate('edit input example'),
      'Example:' => plugin()->translate('Example:'),
      'edit max length' => plugin()->translate('edit max length'),
      'Max Length:' => plugin()->translate('Max Length:'),
      'undefined max length' => plugin()->translate('undefined max length'),
      'Upload Type:' => plugin()->translate('Upload Type:'),
      'undefined upload type' => plugin()->translate('undefined upload type'),
      'edit upload type' => plugin()->translate('edit upload type'),
      'Upload Size:' => plugin()->translate('Upload Size:'),
      'undefined upload size' => plugin()->translate('undefined upload size'),
      'edit upload size' => plugin()->translate('edit upload size'),
      'reset default checked' => plugin()->translate('reset default checked'),
      'Delete upload parts warning' => plugin()->translate('Delete upload parts warning'),
      'Parameter Name:' => plugin()->translate('Parameter Name:'),
      'show parameter' => plugin()->translate('show parameter'),
      'edit parameter name' => plugin()->translate('edit parameter name'),
      'Invalid file type.' => plugin()->translate('Invalid file type.'),
      'Invalid file size.' => plugin()->translate('Invalid file size.'),
      'Invalid max length.' => plugin()->translate('Invalid max length.'),
      'Bytes' => plugin()->translate('Bytes'),
      'Characters' => plugin()->translate('Characters'),
      'upload file size description' => plugin()->translate('upload file size description'),
      'upload file type description' => plugin()->translate('upload file type description'),
      'type reserve' => plugin()->translate('AForm Field Extra Type Reserve'),
      'reserve parts already exists' => plugin()->translate('reserve parts already exists'),
      'type payment' => plugin()->translate('AForm Field Extra Type Payment'),
      'payment parts already exists' => plugin()->translate('payment parts already exists'),
      'payment parts description' => plugin()->translate('payment parts description'),
      'Payment' => plugin()->translate('Payment'),
      'type calendar' => plugin()->translate('AForm Field Extra Type Calendar'),
      'default value' => plugin()->translate('default value'),
      'plaese select' => plugin()->translate('please select'),
      'today' => plugin()->translate('today'),
      'tomorrow' => plugin()->translate('tomorrow'),
      'month later' => plugin()->translate('month later'),
      'years ago' => plugin()->translate('years ago'),
      'selectable range' => plugin()->translate('selectable range'),
      'selectable range from' => plugin()->translate('selectable range from'),
      'selectable range to' => plugin()->translate('selectable range to'),
      'parts id' => plugin()->translate('parts id'),
      'edit parts id' => plugin()->translate('edit parts id'),
      'invalid parts id: ' => plugin()->translate('invalid parts id: '),
      'duplicate parts id exists.' => plugin()->translate('duplicate parts id exists.'),
      'Password' => plugin()->translate('Password'),
      'use other' => plugin()->translate('use other'),
      'not use other' => plugin()->translate('not use other'),
      'parts id is null' => plugin()->translate('parts id is null'),
      'email field not found.' => plugin()->translate('email field not found.'),
      'password field not found.' => plugin()->translate('password field not found.'),
      'parameter name is null' => plugin()->translate('parameter name is null'),
      'invalid parameter name' => plugin()->translate('invalid parameter name'),
      'require twice to confirmation' => plugin()->translate('require twice to confirmation'),
      'Name' => plugin()->translate('Name'),
      'First name' => plugin()->translate('First name'),
      'Last name' => plugin()->translate('Last name'),
      'Kana' => plugin()->translate('Kana'),
      'First name(kana)' => plugin()->translate('First name(kana)'),
      'Last name(kana)' => plugin()->translate('Last name(kana)'),
      'Complement address input' => plugin()->translate('Complement address input'),
      'Do not use' => plugin()->translate('Do not use'),
      'Use(4fields: prefecture + city + area + street)' => plugin()->translate('Use(4fields: prefecture + city + area + street)'),
      'Use(3fields: prefecture + city + street)' => plugin()->translate('Use(3fields: prefecture + city + street)'),
      'Use(2fields: prefecture + city)' => plugin()->translate('Use(2fields: prefecture + city)'),
      'Prefecture Parts ID' => plugin()->translate('Prefecture Parts ID'),
      'City Parts ID' => plugin()->translate('City Parts ID'),
      'Area Parts ID' => plugin()->translate('Area Parts ID'),
      'Street Parts ID' => plugin()->translate('Street Parts ID'),
      'CityArea Parts ID' => plugin()->translate('CityArea Parts ID'),
      'CityStreet Parts ID' => plugin()->translate('CityStreet Parts ID'),
      'Use Mail Setting' => plugin()->translate('Use Mail Setting'),
      'type linkedselect' => plugin()->translate('AForm Field Type Linked Select'),
      'linked-select parts already exists' => plugin()->translate('linked-select parts already exists'),
      'send attached files to admin' => plugin()->translate('send attached files to admin'),
      'send attached files to customers' => plugin()->translate('send attached files to customers'),
      'Disable dates' => plugin()->translate('Disable dates'),
      'Disable dates description' => plugin()->translate('Disable dates description'),
      'move-top' => plugin()->translate('move-top'),
      'move-bottom' => plugin()->translate('move-bottom'),
      'Only ascii characters' => plugin()->translate('Only ascii characters'),
      'Allow ascii characters' => plugin()->translate('Allow ascii characters'),
      'Require Hyphen' => plugin()->translate('Require Hyphen'),
      'Invalid ascii chars.' => plugin()->translate('Invalid ascii chars.'),
      'You cannot change login parts because AMember users exists.' => plugin()->translate('You cannot change login parts because AMember users exists.'),
      'Use this parts for amember login ID.' => plugin()->translate('Use this parts for amember login ID.'),
      'Amember login ID description for email parts.' => plugin()->translate('Amember login ID description for email parts.'),
      'You can set the initial value here.' => plugin()->translate('You can set the initial value here.'),
      'Arrange vertically' => plugin()->translate('Arrange vertically'),
      'Arrange horizontally' => plugin()->translate('Arrange horizontally'),
      'Display condition' => plugin()->translate('Display condition'),
      'Parts ID' => plugin()->translate('Parts ID'),
      ' value is ' => plugin()->translate(' value is '),
      'Equal' => plugin()->translate('Equal'),
      'Not equal' => plugin()->translate('Not equal'),
      'Greater equal' => plugin()->translate('Greater equal'),
      'Greater than' => plugin()->translate('Greater than'),
      'Less equal' => plugin()->translate('Less equal'),
      'Less than' => plugin()->translate('Less than'),
      'Required' => plugin()->translate('Required'),
      'Parts ID' => plugin()->translate('Parts ID'),
      'Not allowed to change' => plugin()->translate('Not allowed to change'),
      '%%min%%-%%max%% characters' => plugin()->translate('%%min%%-%%max%% characters'),
      'min %%min%% characters' => plugin()->translate('min %%min%% characters'),
      'max %%max%% characters' => plugin()->translate('max %%max%% characters'),
      'Duplicate parts label found.' => plugin()->translate('Duplicate parts label found.'),
      'Duplicate parts label found in content type Members.' => plugin()->translate('Duplicate parts label found in content type Members.'),
      'Cant get AMember content fields.' => plugin()->translate('Cant get AMember content fields.'),
      'Privacy policy default' => plugin()->translate('Privacy policy default'),
      'Selectable range from' => plugin()->translate('Selectable range from'),
      'selectable abs range from' => plugin()->translate('selectable abs range from'),
      'Page break' => plugin()->translate('Page break'),
      'Prev' => plugin()->translate('Prev'),
      'Next' => plugin()->translate('Next'),
    );
    my $json_phrases = AFormEngineCGI::Common::obj_to_json(\%phrases);

    my $is_amember_form = &_is_amember_form($aform_id);
    my %param = (
      aform_id => $aform_id,
      plugin_static_uri => _get_plugin_static_uri($app),
      json_aform_fields => $json_aform_fields,
      json_phrases => $json_phrases,
      object_label => plugin()->translate('aform_field'),
      saved_changes => ( $app->param('saved_changes') || '' ),
      status_changed => ( $app->param('status_changed') || '' ),
      exists_form_data => _exists_form_data($app,$aform_id) ? 1 : 0,
      display_title => sprintf("%s(aform%03d)", plugin()->translate('Edit [_1]', $aform->title), $aform_id),
      edit_field_help_url => plugin()->manual_link_edit_field,
      alert_save_msg => plugin()->translate('Your changes has not saved! Are you ok?'),
      aform_status => $aform->status,
      is_amember_form => $is_amember_form,
      aform_action_tabs => &get_aform_action_tabs($app, $blog_id, $aform_id, 'edit_aform_field'),
      exists_amember_user => ($is_amember_form ? &_exists_amember_user() : 0),
      amember_user_id_field => ($is_amember_form ? &_amember_user_id_field() : ''),
    );

    ## Load next and previous entries for next/previous links
    if( my $next = $aform->next ){
      $param{next_aform_id} = $next->id;
    }
    if( my $previous = $aform->previous ){
      $param{previous_aform_id} = $previous->id;
    }
    $param{aform_reserve_installed} = _aform_reserve_installed();
    $param{aform_payment_installed} = _aform_payment_installed();

    my $html = $app->load_tmpl('edit_aform_field.tmpl', \%param);
    return $app->build_page($html, \%param);
}


sub _save_aform_field {
    my $app = shift;
    # check params
    my $aform_id = $app->param('id');
    return $app->errtrans("Invalid request") unless $aform_id;
    my $aform = MT::AForm->load($aform_id);
    return $app->errtrans("Invalid request") unless $aform;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'edit_aform_field');

    $app->{plugin_template_path} = 'plugins/AForm/tmpl';

###    return $app->errtrans("Status is published. Cannot edit fields.") if( $aform->status == '2' );

    require Encode;
    require AFormEngineCGI::Common;
    my $json_data = AFormEngineCGI::Common::json_to_obj($app->param('json_aform_fields'));
    my @fields = @{$json_data->{fields}};

    # check field exists
    my @old_fields = MT::AFormField->load({ 'aform_id' => $aform_id });
    foreach my $old_field ( @old_fields ){
      my $exists_id = 0;
      foreach my $field ( @fields ){
        if( $field->{id} eq $old_field->id ){
          $exists_id = 1;
          last;
        }
      }
      # remove if not exists
      if( !$exists_id ){
        MT::AFormField->remove({'id' => $old_field->id});
      }
    }

    # save fields data
    foreach my $field ( @fields ){
        my $aformField = undef;
        if( $field->{id} =~ m/^\d*$/ ){
            $aformField = MT::AFormField->load($field->{id});
        }
        if( !$aformField ){
          $aformField = new MT::AFormField;
        }

        my $label = $field->{label};
        my $property = AFormEngineCGI::Common::obj_to_json($field->{property});
        $aformField->set_values(
          {
            aform_id   => int($aform_id),
            type   => $field->{type},
            label => $label,
            is_necessary => int($field->{is_necessary}),
            sort_order => int($field->{sort_order}),
            property => $property,
            parts_id => $field->{parts_id},
          }
        );
        $aformField->save();
    }

    MT->run_callbacks('aform_after_save_aform_field', $app, $aform->id)
      or return $app->error($app->errstr);

    $app->log({message => $app->translate('[_1](ID:[_2]) has been saved by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});

    return &_rebuild_aform_entry( 
        $app, 
        [ $aform_id ], 
        'edit_aform_field', 
        (id => $aform->id, saved_changes => 1, blog_id => $app->param('blog_id')) 
    );
#    return $app->redirect( $app->uri( mode => 'edit_aform_field', args => { id => $aform_id, saved_changes => 1 } ) );
}


sub _manage_aform_data {
    my $app = shift;
    # check params
    my $blog_id = $app->param('blog_id') || '';
    my $aform_id = $app->param('id');
    return $app->errtrans("Invalid request") unless $aform_id;
    my $aform = MT::AForm->load($aform_id);
    return $app->errtrans("Invalid request") unless $aform;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'manage_aform_data');

    return $app->return_to_dashboard()
      if ($blog_id && $aform->blog_id && $aform->blog_id ne $blog_id);

    if ($app->version_number >= 5.14) {
      $app->session('aform_id', $aform_id);

      return $app->redirect($app->uri( 
        mode => 'list', 
        args => {
            _type => 'aform_data',
            blog_id => $app->param('blog_id'),
            aform_id => $aform_id
        },
      ));
    } else {
      $app->{plugin_template_path} = 'plugins/AForm/tmpl';

      my @upload_fields = $app->model('aform_field')->load({'aform_id' => $aform_id, 'type' => 'upload'}, {'sort' => 'sort_order'});

      my $is_aform_superuser = aform_superuser_permission($aform_id);
      my $amember = &_get_amember;
      my $user_blog_id = $amember ? $amember->user_blog_id : undef;
      my $html = $app->listing({
        Type => 'aform_data',
        Terms => {
          aform_id => $aform_id,
        },
        Args => { sort => 'id', direction => 'descend'  },
        Code => \&_form_data_item_for_display,
        Params => {
          saved_deleted => ( $app->param('saved_deleted') || '' ),
          aform_manual_url => plugin()->manual_link,
          upload_fields => \@upload_fields,
          aform_id => $aform_id,
          data_status_options => $aform->data_status_options_array,
          is_amember_installed => &_is_amember_installed,
          user_blog_id => $user_blog_id,
        },
      });
      my $html_list = $app->build_page($html);

      my %param = (
        id => $aform_id,
        plugin_static_uri => _get_plugin_static_uri($app),
        saved_deleted => ( $app->param('saved_deleted') || '' ),
        display_title => sprintf("%s(aform%03d)", plugin()->translate('Manage [_1] Data', $aform->title), $aform_id),
#        help_url => plugin()->doc_link,
        html_list => $html_list,
        object_type => 'aform_data',
        saved_changes => ( $app->param('saved_changes') || '' ),
        aform_action_tabs => get_aform_action_tabs($app, $blog_id, $aform_id, 'manage_aform_data'),
        can_export_aform_data => can_do($app, $aform->blog_id, 'export_aform_data'),
        can_delete_aform_data => can_do($app, $aform->blog_id, 'delete_aform_data'),
      );

      ## Load next and previous entries for next/previous links
      if( my $next = $aform->next({exclude_amember => 1}) ){
        $param{next_aform_id} = $next->id;
      }
      if( my $previous = $aform->previous({exclude_amember => 1}) ){
        $param{previous_aform_id} = $previous->id;
      }
      $param{aform_reserve_installed} = _aform_reserve_installed();
      $param{aform_payment_installed} = _aform_payment_installed();

      $html = $app->load_tmpl('manage_aform_data.tmpl', \%param);
      return $app->build_page($html, \%param);
    }
}

sub _form_data_item_for_display {
    my $app = shift;
    my $item_hash = shift;

    my $aform = MT::App->model('aform')->load($item_hash->{'aform_id'});
    my @values = _csv_to_array($item_hash->{'values'});
    $item_hash->{'disp_id'} = &_get_disp_aform_data_id($values[0], 0);

    my($y, $mo, $d, $h, $m, $s) = $item_hash->{'created_on'} =~ /(\d\d\d\d)[^\d]?(\d\d)[^\d]?(\d\d)[^\d]?(\d\d)[^\d]?(\d\d)[^\d]?(\d\d)/;
    $item_hash->{'date'} = sprintf("%04d/%02d/%02d", $y, $mo, $d);

    my @upload_fields = MT::App->model('aform_field')->load( { aform_id => $item_hash->{'aform_id'}, type => 'upload' }, { sort => 'sort_order' });
    my @files;
    foreach my $field ( @upload_fields ){
      my $file = MT::App->model('aform_file')->load( { aform_data_id => $item_hash->{'id'}, field_id => $field->id } );
      push @files, $file;
    }
    $item_hash->{'files'} = \@files;
}

sub _export_aform_data {
    my $app = shift;
    my $aform_id = $app->param('id')
      or return $app->error( $app->translate("Invalid request") );
    my $aform = MT::AForm->load($aform_id)
      or return $app->error( $app->translate("Invalid request") );

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'export_aform_data');

    my $charset = $app->param('charset') || '';
    if ($charset ne 'shift_jis' && $charset ne 'utf-8') {
        $charset = ($aform->lang eq 'ja' || $aform->lang eq 'en_us') ? 'shift_jis' : 'utf-8';
    }
    my $ext = 'csv';

    my @aform_fields = MT::AFormField->load({ aform_id => $aform->id() }, { sort => 'sort_order' });

    my $range = $app->param('range') || 'all';
    my $range_target = $app->param('range_target') || 'created_on';
    my $range_from = $app->param('range_from') || undef;
    my $range_to = $app->param('range_to') || undef;

    my $terms = {aform_id => $aform_id};
    my $args = {sort => 'created_on'};
    if ($range eq 'range' && $range_target eq 'created_on' && ($range_from || $range_to)) {
        $range_to .= ' 23:59:59' if ($range_to);
        $terms->{'created_on'} = [$range_from, $range_to];
        $args->{'range'} = {created_on => 1};
    }
    my @aform_datas = MT::AFormData->load($terms, $args);
    if ($range eq 'range' && $range_target eq 'reserve_date' && ($range_from || $range_to)) {
        @aform_datas = grep { $_->reserve_date_range_check($range_from, $range_to) } @aform_datas;
    }

    $app->validate_magic() or return;

    my @ts = localtime(time);
    my $file = sprintf("export-%06d-%04d%02d%02d%02d%02d%02d.%s", $app->param('id'), $ts[5] + 1900, $ts[4] + 1, @ts[ 3, 2, 1, 0 ], $ext);

    local $| = 1;
    $app->{no_print_body} = 1;
    $app->set_header( "Cache-Control" => "public" );
    $app->set_header( "Pragma" => "public" );
    $app->set_header( "Content-Disposition" => "attachment; filename=$file" );
    $app->send_http_header(
        $charset
        ? "application/excel; charset=$charset"
        : 'application/excel'
    );

    # put utf8 bom

    my @field_labels;
    push( @field_labels, $app->translate('Received Status'));
    push( @field_labels, $app->translate('Received Comment'));
    push( @field_labels, $app->translate('Received Data ID'));
    push( @field_labels, $app->translate('Received Datetime'));
    foreach my $aform_field ( @aform_fields ){
      if (MT::AFormData::is_aform_data_field_type($aform_field->type)) {
        push( @field_labels, $aform_field->label );
      }
    }
     
    my $param_fields = &AFormEngineCGI::FormMail::_get_fields($app, $aform);

    my $buf = '';
    $buf = "\x{feff}" if ($charset eq 'utf-8');
    foreach my $field_label ( @field_labels ){
        $field_label =~ s/"/""/g;
        $buf .= qq("$field_label",);
    }
    $buf =~ s/,$//;
    $buf .= "\n";
    $app->print(MT::I18N::encode_text($buf, 'utf-8', $charset));

    foreach my $aform_data ( @aform_datas ){
        $buf = "";
        my $status = $aform_data->status;
        $status =~ s/"/""/g;
        $buf .= qq("$status",);
        my $comment = $aform_data->comment;
        $comment =~ s/"/""/g;
        $buf .= qq("$comment");
        my @fields = @{$aform_data->fields($app,$param_fields)};
        MT->run_callbacks('aform_before_export_aform_data_output', $app, \@fields);

        foreach my $field ( @fields ){
            if (!MT::AFormData::is_aform_data_field_type($field->{'type'})) {
                next;
            }
            my $value = $field->{'value'};
            if ($field->{'type'} eq 'receive_id') {
                $value = &_get_disp_aform_data_id($value, 0);
            }
            elsif ($field->{'type'} eq 'upload' && $field->{'upload_path'}) {
                $value .= '('. $field->{'upload_path'} .')';
            }
            $value =~ s/"/""/g;
            $buf .= qq(,"$value");
        }
        $buf .= "\n";
        $app->print(MT::I18N::encode_text($buf, 'utf-8', $charset));
    }

    $app->log({message => $app->translate('[_1](ID:[_2]) CSV downloaded by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});
    1;
}


sub _clear_aform_data {
    my $app = shift;
    my $aform_id = $app->param('id')
      or return $app->error( $app->translate("Invalid request") );
    my $aform = MT::AForm->load($aform_id)
      or return $app->error( $app->translate("Invalid request") );
    $app->validate_magic() or return;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'delete_aform_data');

    # delete data
    my $iter = MT::AFormData->load_iter({aform_id => $aform_id});
    while (my $aform_data = $iter->()) {
        $aform_data->remove;
    }

    $app->log({message => $app->translate('[_1](ID:[_2]) CSV cleared by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});

    return $app->redirect( $app->uri( mode => 'manage_aform_data', args => { id => $aform_id, saved_deleted => 1, blog_id => $app->param('blog_id')} ) );
}


sub _exists_form_data {
    my $app = shift;
    my( $aform_id ) = @_;
    my $data_count = MT::AFormData->count( { aform_id => $aform_id });
    return( $data_count > 0 );
}


sub check_entry_has_aform {
    my( $eh, $app, $entry ) = @_;

    # remove first
    &_remove_aform_entry($app, $entry->id);

    my $meta = $entry->meta;

    my @texts;
    push @texts, $entry->text;
    push @texts, $entry->text_more;
    foreach my $key (keys %$meta) {
        push @texts, $meta->{$key};
    }

    foreach my $text (@texts) {
        &_relate_aform_entry($app, $entry, $text, '<\!--', '-->');
        &_relate_aform_entry($app, $entry, $text, '\[\[', '\]\]');
    }
}

sub _relate_aform_entry {
    my( $app, $entry, $text, $pattern_pre, $pattern_post, $type ) = @_;

    return unless $text;
    while( $text =~ m/${pattern_pre}aform(\d+)${pattern_post}/gi ){
        my $match_no = $1;
        my $aform_id = int($match_no);
        if( $aform_id ){
            &_regist_aform_entry($app, $entry->blog_id, $entry->id, $aform_id, $type);
        }
    }
}

sub remove_aform_entry {
    my( $eh, $app, $entry ) = @_;

    &_remove_aform_entry($app, $entry->id);
}

sub _build_form {
    my( $entry_text, $args, $ctx ) = @_;

    require AFormEngineCGI::FormMail;

    my $app = MT->instance;
    $app->{plugin_template_path} = 'plugins/AForm/tmpl';

    $entry_text = _replace_form($app, $ctx, $entry_text, '<\!--', '-->');
    $entry_text = _replace_form($app, $ctx, $entry_text, '\[\[', '\]\]');

    return $entry_text;
}

sub _replace_form {
    my( $app, $ctx, $entry_text, $pattern_pre, $pattern_post ) = @_;

    my $blog = $ctx->stash('blog');
    while( $entry_text =~ m/${pattern_pre}aform(\d+)${pattern_post}/gi ){
        my $match_no = $1;
        my $aform_id = int($match_no);

        # get aform
        my $aform = MT::AForm->load( $aform_id );
        if( !$aform ){
          $entry_text =~ s/${pattern_pre}aform${match_no}${pattern_post}//gi;
          next;
        }

        if( $aform->blog_id && $aform->blog_id != $blog->id ){
          my $blog_permission_error = plugin()->translate("The Form [_1] does not have permission for Blog [_2].", sprintf("%03d", $aform_id), $blog->name);
          $entry_text =~ s/${pattern_pre}aform${match_no}${pattern_post}/${blog_permission_error}/gi;
          next;
        }

        # generate form
        my $buf = AFormEngineCGI::FormMail::generate_form_view($app, $aform, $ctx);

        # replace
        $entry_text =~ s/${pattern_pre}aform${match_no}${pattern_post}/$buf/gi;
    }
    return $entry_text;
}


sub _hide_aform {
    my( $entry_text, $args, $ctx ) = @_;

    $entry_text =~ s/<\!--aform(\d+)-->//gi;
    $entry_text =~ s/\[\[aform(\d+)\]\]//gi;

    return $entry_text;
}


sub _regist_aform_entry {
    my $app = shift;
    my $blog_id = shift;
    my $entry_id = shift;
    my $aform_id = shift;
    my $type = shift;
    $type = 'entry' unless $type;

    if( ! MT::AFormEntry->count( { blog_id => $blog_id, entry_id => $entry_id, aform_id => $aform_id, type => $type } ) ) {
        my $aform_entry = MT::AFormEntry->new;
        $aform_entry->set_values( {
            blog_id => $blog_id,
            entry_id => $entry_id,
            aform_id => $aform_id,
            type => $type,
        });
        $aform_entry->save;
    }
}


sub _remove_aform_entry {
    my $app = shift;
    my $entry_id = shift;
    my $type = shift;
    $type = 'entry' unless $type;

    MT::AFormEntry->remove({ entry_id => $entry_id, 'type' => $type });
}


sub _disp_aform {
    my $app = shift;

    $app->{plugin_template_path} = 'plugins/AForm/tmpl';

    # check params
    my $aform_id = $app->param('id');
    return $app->errtrans("Invalid request") unless $aform_id;

    # get aform
    my $aform = MT::AForm->load( $aform_id );

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'preview_aform');

    # generate form
    require AFormEngineCGI::FormMail;
    return AFormEngineCGI::FormMail::generate_form_preview($app, $aform);
}


sub _get_plugin_static_uri {
    my $app = shift;

    require AFormEngineCGI::FormMail;
    my $path = AFormEngineCGI::FormMail::_get_static_uri($app);
    $path .= '/' unless $path =~ m#/$#;
    $path .= plugin()->envelope . "/";

    return $path;
}

sub plugin {
  return MT->component('AForm');
}


sub _list_aform_input_error {
    my $app = shift;
    # check params
    my $blog_id = $app->param('blog_id') || '';
    my $aform_id = $app->param('id');
    return $app->errtrans("Invalid request") unless $aform_id;
    my $aform = $app->model('aform')->load($aform_id);
    return $app->errtrans("Invalid request") unless $aform;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'list_aform_input_error');

    return $app->return_to_dashboard()
      if ($blog_id && $aform->blog_id && $aform->blog_id ne $blog_id);

    $app->session('aform_id', $aform_id);

    my $q = $app->param;
    $app->{plugin_template_path} = 'plugins/AForm/tmpl';
    $q->param('_type', 'aform_input_error');

    my $html = $app->listing({
        Type => 'aform_input_error',
        Terms => {
          aform_id => $aform_id,
        },
        Args => { sort => 'created_on', direction => 'descend' },
        Code => \&_error_item_for_display,
        Params => {
        },
    });

    # access count
    my @aform_access = $app->model('aform_access')->load( { aform_id => $aform_id } );
    my( $session, $pv, $conversion_count);
    foreach my $access ( @aform_access ){
        $session += $access->session;
        $pv += $access->pv;
        $conversion_count += $access->cv;
    }

    # conversion rate
    my $conversion_rate;
    if( $pv > 0 ){
        $conversion_rate = sprintf("%0.2f", $conversion_count / $pv * 100) . '%';
    }


    my %param = (
      id => $aform_id,
      plugin_static_uri => _get_plugin_static_uri($app),
      session => $session || 0,
      pv => $pv || 0,
      conversion_count => $conversion_count || 0,
      conversion_rate => $conversion_rate || '-.--',
      display_title => sprintf("%s(aform%03d)", MT::Util::encode_html($aform->title), $aform_id),
      display_title => sprintf("%s(aform%03d)", plugin()->translate('[_1] List Input Error', $aform->title), $aform_id),
#      help_url => plugin()->doc_link,
       listing_screen => 0,
      is_amember_form => &_is_amember_form($aform_id),
      cleared_aform_access => $app->param('cleared_aform_access') || 0,
      cleared_aform_input_error => $app->param('cleared_aform_input_error') || 0,
      charset => (($aform->lang eq 'ja' || $aform->lang eq 'en_us') ? 'shift_jis' : 'utf-8'),
      can_clear_aform_access => can_do($app, $aform->blog_id, 'clear_aform_access'),
      can_clear_aform_input_error => can_do($app, $aform->blog_id, 'clear_aform_input_error'),
      can_export_aform_input_error => can_do($app, $aform->blog_id, 'export_aform_input_error'),
    );
    if (_is_aform_mobile_installed()) {
      _set_mobile_info_for_list_aform_input_error($aform_id, \%param);
    }

    ## Load next and previous entries for next/previous links
    if( my $next = $aform->next ){
      $param{next_aform_id} = $next->id;
    }
    if( my $previous = $aform->previous ){
      $param{previous_aform_id} = $previous->id;
    }
    $param{aform_reserve_installed} = _aform_reserve_installed();
    $param{aform_payment_installed} = _aform_payment_installed();
    $param{aform_action_tabs} = get_aform_action_tabs($app, $blog_id, $aform_id, 'list_aform_input_error');

    return $app->build_page($html, \%param);
}

sub _error_item_for_display {
    my $app = shift;
    my $item_hash = shift;

    $item_hash->{'created_on'} =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;

    $item_hash->{'type'} = plugin()->translate( $item_hash->{'type'} );
}

sub _change_aform_status {
    my $app = shift;
    # check params
    my $q = $app->param;
    my $aform_id = $app->param('id');
    return $app->errtrans("Invalid request") unless $aform_id;
    my $aform = $app->model('aform')->load($aform_id);
    return $app->errtrans("Invalid request") unless $aform;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'edit_aform');

    # change status
    $aform->set_values( {
        status => ($aform->status == 2 ? 0 : 2),
    } );
    $aform->save();

    # redirect
    my $redirect_mode = $app->param('redirect_mode') || 'manage_aform';

    my $message = $aform->status == 2 ? '[_1](ID:[_2]) was enabled by [_3](ID:[_4]).' : '[_1](ID:[_2]) was disabled by [_3](ID:[_4]).';
    $app->log({message => $app->translate($message, $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});

    return &_rebuild_aform_entry(
        $app,
        [ $aform_id ],
        $redirect_mode,
        ( id => $aform->id, blog_id => $app->param('blog_id'), status_changed => 1)
    );
#    return $app->redirect( $app->uri( mode => $redirect_mode, args => { id => $aform->id, blog_id => $app->param('blog_id'), status_changed => 1 } ) );
}


sub aform_superuser_permission {
    my $aform_id = shift;

    my $app = MT->app;
    my $blog_id = 0;
    if( $aform_id ){
        my $aform = MT::AForm->load($aform_id);
        $blog_id = $aform->blog_id;
    }
    if( $blog_id ){
        my $perms = $app->user->blog_perm($blog_id);
        return( $perms && $perms->can_rebuild );
    }else{
        my $perms = $app->user->permissions;
        return( $perms && $perms->can_create_blog );
    }
}


sub _rebuild_aform_entry {
    my $app = shift;
    my $aform_ids = shift;
    my $return_mode = shift;
    my (%return_args) = @_;

    # get entry_ids and content_data_ids
    my %entry_ids;
    my %content_data_ids;
    foreach my $aform_id ( @$aform_ids ){
        my @aform_entries = $app->model('aform_entry')->load({ aform_id => $aform_id });
        foreach my $aform_entry ( @aform_entries ){
            if ($aform_entry->type eq 'content_data') {
                my $content_data = MT::ContentData->load({id => $aform_entry->entry_id});
                if( ! $content_data ){
                    next;
                }
                push @{$content_data_ids{$content_data->blog_id}}, $content_data->id;
            }
            else {
                my $entry = MT::Entry->load({id => $aform_entry->entry_id, status => MT::Entry::RELEASE()});
                if( ! $entry ){
                    next;
                }
                push @{$entry_ids{$entry->blog_id}}, $entry->id;
            }
        }
    }


    if( %entry_ids || %content_data_ids ){
        # make entry_ids string
        my @tmp;
        foreach my $blog_id (keys %entry_ids) {
            push @tmp, sprintf("%d@%s", $blog_id, join(",", @{$entry_ids{$blog_id}}));
        }
        my $entry_ids = join(":", @tmp);
        # make content_ids string
        my @tmp2;
        foreach my $blog_id (keys %content_data_ids) {
            push @tmp2, sprintf("%d@%s", $blog_id, join(",", @{$content_data_ids{$blog_id}}));
        }
        my $content_data_ids = join(":", @tmp2);

        # retrun args
        my $return_args = $app->uri_params(args => \%return_args);
        $return_args =~ s/^\?//;
        # redirect to rebuild_aform_entry
        return $app->redirect($app->uri(
            mode => 'rebuild_aform_entry',
            args => {
                blog_id     => $app->param('blog_id') || "",
                entry_ids   => $entry_ids,
                content_data_ids => $content_data_ids,
                return_mode => $return_mode,
                return_args => $return_args,
            },
        ));
    }else{
        # redirect to orig mode
        return $app->redirect($app->uri(
            mode    => $return_mode,
            args    => \%return_args,
            blog_id => $app->param('blog_id') || "",
        ));
    }
}

sub rebuild_aform_entry {
    my $app = shift;

    my $entry_ids = $app->param('entry_ids') || "";
    my $content_data_ids = $app->param('content_data_ids') || "";
    my $orig_return_mode = $app->param('return_mode') || "";
    my $orig_return_args = $app->param('return_args') || "";
    my $orig_uri = $app->uri(mode => $orig_return_mode) .'&'. $orig_return_args;

    # parse entry_ids
    my @entry_ids;
    if ($entry_ids ne "") {
        @entry_ids = split(":", $entry_ids);
    }
    # parse content_data_ids
    my @content_data_ids;
    if ($content_data_ids ne "") {
        @content_data_ids = split(":", $content_data_ids);
    }
    return $app->redirect($orig_uri) if (!@entry_ids && !@content_data_ids);

    # parse current ids
    my $current_type = undef;
    my $current_blog_id = undef;
    my @ids;
    if (@entry_ids) {
        $current_type = 'entry';
        my $current_data = shift @entry_ids;
        my ($blog_id, $current_entry_ids) = split("@", $current_data);
        $current_blog_id = $blog_id;
        if ($current_entry_ids ne "") {
            @ids = split(",", $current_entry_ids);
        }
    } elsif (@content_data_ids) {
        $current_type = 'content_data';
        my $current_data = shift @content_data_ids;
        my ($blog_id, $current_content_data_ids) = split("@", $current_data);
        $current_blog_id = $blog_id;
        if ($current_content_data_ids ne "") {
            @ids = split(",", $current_content_data_ids);
        }
    }
    return $app->redirect($orig_uri) unless @ids;

    # set return_args to rebuild_phase
    my $return_args = "";
    if (@entry_ids > 0 || @content_data_ids > 0) {
        # return rebuild_aform_entry again, and process next entry_ids
        $return_args = $app->uri_params(
            mode => 'rebuild_aform_entry',
            args => {
                entry_ids   => join(":", @entry_ids),
                content_data_ids => join(":", @content_data_ids),
                return_mode => $orig_return_mode,
                return_args => $orig_return_args,
            },
        );
    } else {
        # return orig_mode
        $return_args = $app->uri_params(mode => $orig_return_mode) .'&'. $orig_return_args;
    }
    $return_args =~ s/^\?//;

    # redirect to rebuild_phase
    return $app->redirect($app->uri(
        mode => 'rebuild_phase',
        args => {
            _type       => $current_type,
            id          => \@ids,
            blog_id     => $current_blog_id,
            return_args => $return_args,
            magic_token => $app->current_magic,
        }
    ));
}


sub _disp_aform_data {
  my $app = shift;

  my $q = $app->param;
  $app->{plugin_template_path} = 'plugins/AForm/tmpl';
  $q->param('_type', 'aform');

  my $aform_id = $app->param('aform_id');
  return $app->error("Invalid request") unless $aform_id;
  my $aform = MT::AForm->load($aform_id);
  return $app->error("Invalid request") unless $aform;
  my $aform_data_id = $app->param('aform_data_id');
  return $app->error("Invalid request") unless $aform_data_id;

  return $app->return_to_dashboard( permission => 1 )
    unless can_do($app, $aform->blog_id, 'disp_aform_data');

  my @fields = MT::AFormField->load({'aform_id' => $aform_id}, {'sort' => 'sort_order'});
  my $aform_data = MT::AFormData->load($aform_data_id);
  my @values = _csv_to_array($aform_data->values);
  $values[0] = &_get_disp_aform_data_id($values[0], 0);

  my @datas;
  push( @datas, { 
                  'label' => plugin()->translate('Received Data ID'),
                  'value' => shift @values,
                });
  push( @datas, { 
                  'label' => plugin()->translate('Received Datetime'),
                  'value' => shift @values,
                });

  for( my $i = 0; $i < @fields; $i++ ){
    if (!MT::AFormData::is_aform_data_field_type($fields[$i]->type)) {
      next;
    }
    my %param = ( 
                    'id'    => $fields[$i]->id,
                    'type'  => $fields[$i]->type,
                    'label' => $fields[$i]->label,
                    'value' => shift @values,
                );
    if( $fields[$i]->type eq "upload" ){
      my $aform_file = MT::AFormFile->load({
                             'aform_id' => $aform_id, 
                             'field_id' => $fields[$i]->id, 
                             'aform_data_id' => $aform_data_id});
      if( $aform_file ){
        $param{'file_id'} = $aform_file->id;
        $param{'upload_id'} = $aform_file->upload_id;
        $param{'upload_size'} = $aform_file->size_text;
        $param{'upload_path'} = $aform_file->get_path;
      }
    }
    push @datas, \%param;
  }

  push @datas, { 'label' => plugin()->translate('IP'), 'value' => $aform_data->ip };
  push @datas, { 'label' => plugin()->translate('User Agent'), 'value' => $aform_data->ua };

  # 降順なのでnextとprev、topとlastが逆になる
  my $next_data = $aform_data->previous;
  my $prev_data = $aform_data->next;
  my $top_data  = $aform_data->last;
  my $last_data = $aform_data->top;

  my %param = (
    plugin_static_uri => _get_plugin_static_uri($app),
    aform_id      => $aform_id,
    aform_disp_id => sprintf("aform%03d", $aform_id),
    aform_name    => $aform->title,
    aform_data_id => $aform_data_id,
    datas         => \@datas,
    top_id        => ($top_data && $aform_data_id != $top_data->id) ? $top_data->id : undef,
    last_id       => ($last_data && $aform_data_id != $last_data->id) ? $last_data->id : undef,
    next_id       => $next_data ? $next_data->id : undef,
    prev_id       => $prev_data ? $prev_data->id : undef,
    count_all     => MT::AFormData->count({aform_id => $aform_id}),
    current_pos   => $aform_data->current_pos('descend'),
    status        => $aform_data->status,
    comment       => $aform_data->comment,
    data_status_options => $aform->data_status_options_array,
    manage_return_args => $app->param('manage_return_args'),
    can_change_aform_data_status => can_do($app, $aform->blog_id, 'change_aform_data_status'),
  );
  MT->run_callbacks('aform_before_disp_aform_data_build', $app, \%param);

  my $html = $app->load_tmpl('disp_aform_data.tmpl', \%param);

  $app->log({message => $app->translate('[_1](ID:[_2]) data #[_3] has been viewed by [_4](ID:[_5]).', $aform->title, $aform->id, $aform_data->disp_data_id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});

  return $app->build_page($html, \%param);
}


sub _csv_to_array {
  my $csv = shift;

  $csv .= ',';
  my @values = map {/^"(.*)"$/s ? scalar($_ = $1, s/""/"/g, $_) : $_}
                ($csv =~ /("[^"]*(?:""[^"]*)*"|[^,]*),/g);

  # 先頭が日付なら旧フォーマット
  if ($values[0] =~ m/^\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}$/) {
    # 受付番号の分カラムを追加
    unshift @values, "";
  }

  return @values;
}


sub _download_aform_file {
  my $app = shift;

  my $aform_file_id = $app->param('id');

  my $aform_file = MT::AFormFile->load($aform_file_id);
  return $app->error('invalid request') unless $aform_file;
  my $aform = MT::AForm->load($aform_file->aform_id);
  return $app->error('invalid request') unless $aform;

  return $app->return_to_dashboard( permission => 1 )
    unless can_do($app, $aform->blog_id, 'download_aform_file');

  require AFormEngineCGI::FormMail;
  my $filepath = AFormEngineCGI::FormMail::_get_upload_file_path($app, $aform_file);
  sysopen( FILE, $filepath, O_RDONLY )
    or die 'cant open ' . $filepath;
  binmode(FILE);
  my $filename = sprintf("%03d_%d-%d%s", $aform_file->aform_id, $aform_file->aform_data_id, $aform_file->field_id, $aform_file->ext);

  local $| = 1;
  $app->{no_print_body} = 1;
  $app->set_header( "Content-Disposition" => "attachment; filename=". $filename );
  $app->send_http_header(
      'application/octet-tream'
  );
  while( <FILE> ){
    $app->print($_);
  }
  close(FILE);

  return 1;
}

sub post_remove_aform_data {
  my( $eh, $aform_data ) = @_;

  my @aform_files = MT::AFormFile->load({
        aform_id => $aform_data->aform_id,
        aform_data_id => $aform_data->id, 
  });
  foreach my $aform_file ( @aform_files ){
    $aform_file->remove;
  }
}

sub post_remove_aform_file {
  my( $eh, $aform_file ) = @_;

  my $app = MT::App::CMS->new;
  require AFormEngineCGI::FormMail;
  my $filepath = AFormEngineCGI::FormMail::_get_upload_file_path($app, $aform_file);
  MT->log({"message" => "delete aform file:" . $filepath});
  unlink($filepath);
}

sub _get_datetime_by_ts {
  my $ts = shift;

  my $datetime = format_ts("%Y-%m-%d %H:%M:%S", $ts);
  if( _is_null_datetime($datetime) ){
    return '';
  }
  return $datetime;
}

sub _is_null_datetime {
  my $datetime = shift;

  return( $datetime eq '0000-00-00 00:00:00' );
}

sub _get_disp_aform_data_id {
  my $aform_data_id = shift;
  my $offset = shift;

  return sprintf("%06d", $aform_data_id + $offset);
}

sub _aform_reserve_installed {
    require AFormEngineCGI::FormMail;
    return AFormEngineCGI::FormMail::_aform_reserve_installed();
}

sub _aform_payment_installed {
    require AFormEngineCGI::FormMail;
    return AFormEngineCGI::FormMail::_aform_payment_installed();
}

# <MTAFormFieldLabel>
sub hdlr_aform_field_label {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    my $parts_id = $args->{parts_id};
    return MT->translate('aform_id is empty') unless $aform_id;
    return MT->translate('parts_id is empty') unless $parts_id;
    my $field = MT::AFormField->load({aform_id => $aform_id, parts_id => $parts_id});
    return "" unless $field;
    my $aform = MT::AForm->load($aform_id);
    return "" unless $aform;
    MT->set_language($aform->lang);

    MT->run_callbacks('aform_before_field_label', $ctx, $args, $field);

    my $args_tag = $args->{tag} || "label";
    my $for = "";
    if ($args_tag eq "label") {
        $for = ' for="'. encode_html($parts_id) .'"';
    }

    my $required_tag = '';
    if( $field->is_necessary ){
        $required_tag = '<span class="aform-required">'. plugin()->translate('required') .'</span>';
    }

    my $tag;
    if( $field->type eq 'checkbox' || $field->type eq 'radio' ){
        $tag = '<span class="aform-label '. encode_html($parts_id) .'">'.  encode_html($field->label) . $required_tag .'</span>';
    }elsif( $field->type eq 'privacy' ){
        $tag = '<span class="aform-label '. encode_html($parts_id) .'">';
        if( $field->privacy_link ne "" ){
            my $icon = plugin()->translate('icon_new_windows');
            if ($icon eq '' || $icon eq 'icon_new_windows') {
                $icon = _get_plugin_static_uri(MT::App->instance) . 'images/icons/icon_new_windows.gif';
            }
            $tag .= '<a target="_blank" href="'. encode_html($field->privacy_link) .'">'. encode_html($field->label) .'<img src="'. $icon . '" alt="'. encode_html(plugin()->translate('new window open')) .'"></a>';
        }else{
            $tag .= encode_html($field->label);
        }
        $tag .= $required_tag . '</span>';
    }elsif( $field->type eq 'parameter' ){
        if( $field->show_parameter ){
            $tag = '<'. $args_tag . $for .' class="aform-label '. encode_html($parts_id) .'">'.  encode_html($field->label) . $required_tag .'</'. $args_tag .'>';
        }
    }else{
        $tag = '<'. $args_tag . $for .' class="aform-label '. encode_html($parts_id) .'">'.  encode_html($field->label) . $required_tag .'</'. $args_tag .'>';
    }
    MT->run_callbacks('aform_after_field_label', $ctx, $args, \$tag, $field);
    return $tag;
}

# <MTAFormFieldValidation>
sub hdlr_aform_field_validation {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    my $parts_id = $args->{parts_id};
    my $args_tag = $args->{tag} || 'span';
    return MT->translate('aform_id is empty') unless $aform_id;
    return MT->translate('parts_id is empty') unless $parts_id;
    my $field = MT::AFormField->load({aform_id => $aform_id, parts_id => $parts_id});
    return "" unless $field;
    my $aform = MT::AForm->load($aform_id);
    return "" unless $aform;
    MT->set_language($aform->lang);

    my @tags;

    if ($field->only_ascii) {
        push @tags, plugin()->translate('Only ascii characters');
    }

    if ($field->min_length && $field->max_length) {
        push @tags, '<span class="max-length">'. encode_html(plugin()->translate('[_1]-[_2] characters', $field->min_length, $field->max_length)) .'</span>';
    }
    elsif( $field->min_length ){
        push @tags, '<span class="max-length">'. encode_html(plugin()->translate('minimum [_1] characters', $field->min_length)) .'</span>';
    }
    elsif( $field->max_length ){
        push @tags, '<span class="max-length">'. encode_html(plugin()->translate('max [_1] characters', $field->max_length)) .'</span>';
    }
    my $tag = '';
    if( @tags > 0 ){
      $tag = '<'.$args_tag.' class="aform-validation '. encode_html($parts_id) .'">('. join('', @tags) .')</'.$args_tag.'>';
    }
    MT->run_callbacks('aform_after_field_validation', $ctx, $args, \$tag, $field);
    return $tag;
}

# <MTAFormFieldInputExample>
sub hdlr_aform_field_input_example {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    my $parts_id = $args->{parts_id};
    my $args_tag = $args->{tag} || 'div';
    return MT->translate('aform_id is empty') unless $aform_id;
    return MT->translate('parts_id is empty') unless $parts_id;
    my $field = MT::AFormField->load({aform_id => $aform_id, parts_id => $parts_id});
    return "" unless $field;
    return "" unless $field->input_example;
    my $aform = MT::AForm->load($aform_id);
    return "" unless $aform;
    MT->set_language($aform->lang);

    my $tag = '<'.$args_tag.' class="aform-input-example '. encode_html($parts_id) .'">'. $field->input_example .'</'.$args_tag.'>';
    MT->run_callbacks('aform_after_field_input_example', $ctx, $args, \$tag, $field);
    return $tag;
}

# <MTAFormFieldError>
sub hdlr_aform_field_error {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    my $parts_id = $args->{parts_id};
    my $args_tag = $args->{tag} || 'div';
    return MT->translate('aform_id is empty') unless $aform_id;
    return MT->translate('parts_id is empty') unless $parts_id;
    my $field = MT::AFormField->load({aform_id => $aform_id, parts_id => $parts_id});
    return "" unless $field;
    my $aform = MT::AForm->load($aform_id);
    return "" unless $aform;
    MT->set_language($aform->lang);

    my $tag;
    if( $field->type eq 'calendar' ){
        $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-yy-error"></'.$args_tag.'>'.
               '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-mm-error"></'.$args_tag.'>'.
               '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-dd-error"></'.$args_tag.'>';
    }elsif( $field->type eq 'reserve' ){
        $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-date-error"></'.$args_tag.'>'.
               '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-plan-id-error"></'.$args_tag.'>'.
               '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-option-value-id-error"></'.$args_tag.'>';
    }elsif( $field->type eq 'name' ){
        $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-lastname-error"></'.$args_tag.'>'.
               '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-firstname-error"></'.$args_tag.'>';
    }elsif( $field->type eq 'kana' ){
        $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-lastname-kana-error"></'.$args_tag.'>'.
               '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-firstname-kana-error"></'.$args_tag.'>';
    }else{
        $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-error"></'.$args_tag.'>';
    }
    MT->run_callbacks('aform_after_field_error', $ctx, $args, \$tag, $field);
    return $tag;
}

# <MTAFormFieldInput>
sub hdlr_aform_field_input {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    my $parts_id = $args->{parts_id};
    return MT->translate('aform_id is empty') unless $aform_id;
    return MT->translate('parts_id is empty') unless $parts_id;
    my $app = MT::App->instance;
    my $aform = MT::AForm->load({id => $aform_id});
    return "" unless $aform;
    my $fields = &AFormEngineCGI::FormMail::_get_fields($app, $aform, $parts_id);
    if( ref($app) eq 'AFormEngineCGI' && $app->param('run_mode') ){
      $fields = &AFormEngineCGI::FormMail::_inject_param_value($app, $fields);
    }
    return "" if @$fields == 0;
    my $field = shift @$fields;
    MT->set_language($aform->lang);

    MT->run_callbacks('aform_before_field_input', $ctx, $args, $field);

    my $tag;
    if( $field->{'type'} eq 'label' ){
        $tag = &_make_label_tag($field);
    }elsif( $field->{'type'} eq 'note' ){
        $tag = &_make_note_tag($field);
    }elsif( $field->{'type'} eq 'text' ){
        $tag = &_make_text_tag($field);
    }elsif( $field->{'type'} eq 'textarea' ){
        $tag = &_make_textarea_tag($field);
    }elsif( $field->{'type'} eq 'radio' ){
        $tag = &_make_radio_tag($field);
    }elsif( $field->{'type'} eq 'checkbox' ){
        $tag = &_make_checkbox_tag($field);
    }elsif( $field->{'type'} eq 'select' ){
        $tag = &_make_select_tag($field);
    }elsif( $field->{'type'} eq 'prefecture' ){
        $tag = &_make_select_tag($field);
    }elsif( $field->{'type'} eq 'email' ){
        $tag = &_make_text_tag($field, ['hankaku', 'validate-email']);
    }elsif( $field->{'type'} eq 'tel' ){
        $tag = &_make_text_tag($field, ['hankaku', 'validate-tel']);
    }elsif( $field->{'type'} eq 'zipcode' ){
        $tag = &_make_zipcode_tag($field);
    }elsif( $field->{'type'} eq 'url' ){
        $tag = &_make_text_tag($field, ['hankaku', 'validate-url']);
    }elsif( $field->{'type'} eq 'privacy' ){
        $tag = &_make_checkbox_tag($field, ['validate-privacy']);
    }elsif( $field->{'type'} eq 'upload' ){
        $tag = &_make_upload_tag($field);
    }elsif( $field->{'type'} eq 'parameter' ){
        $tag = &_make_parameter_tag($field);
    }elsif( $field->{'type'} eq 'calendar' ){
        $tag = &_make_calendar_tag($field);
    }elsif( $field->{'type'} eq 'password' ){
        $tag = &_make_password_tag($field);
    }elsif( $field->{'type'} eq 'name' ){
        $tag = &_make_name_tag($field);
    }elsif( $field->{'type'} eq 'kana' ){
        $tag = &_make_kana_tag($field);
    }elsif( $field->{'type'} eq 'payment' ){
        if (_aform_payment_installed()) { 
            require AFormPayment::Plugin;
            $tag = &AFormPayment::Plugin::make_payment_tag($app, $field);
        }
    }
    MT->run_callbacks('aform_after_field_input', $ctx, $args, \$tag, $field);

    return $tag;
}

# label
sub _make_label_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-hdln', $field->{'parts_id'});
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    my $tag = '<div
        class="'. encode_html(join(' ', @classes)) .'">'. 
        $field->{'label'} . '</div>';
    return $tag;
}

# note
sub _make_note_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-note', $field->{'parts_id'});
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    my $tag = '<div
        class="'. encode_html(join(' ', @classes)) .'">'. 
        $field->{'label'} . '</div>';
    return $tag;
}

# text
sub _make_text_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'min_length'} || $field->{'max_length'} ){ push @classes, 'validate-length'; }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }
    if( $field->{'only_ascii'} ){ push @classes, 'hankaku'; push @classes, 'validate-ascii'; }
    if( $field->{'require_hyphen'} ){ push @classes, 'require-hyphen'; }
	my $type = 'text';
	if ($field->{'type'} eq 'email') {
		$type = 'email';
	}
	elsif ($field->{'type'} eq 'tel') {
		$type = 'tel';
	}
	elsif ($field->{'type'} eq 'url') {
		$type = 'url';
	}

    my $pattern = _make_field_pattern($field);

    my $tag = '<input 
        id="'. encode_html($field->{'parts_id'}) .'"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'" 
        type="'. $type .'" 
        '. put_attr_value($field->{'value'}) .' 
        size="40" 
        title="'. encode_html(&_get_tag_title($field)) .'"
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($pattern ? $pattern : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .' />';
    if ($field->{'require_twice'}) {
        $tag .= _make_reenter_tag($type, $field, @classes);
    }
    return $tag;
}

# text
sub _make_zipcode_tag {
    my( $field ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'hankaku', 'validate-zipcode', 'aform-validate');
    if( $field->{'min_length'} || $field->{'max_length'} ){ push @classes, 'validate-length'; }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }
    if( $field->{'require_hyphen'} ){ push @classes, 'require-hyphen'; }

    my $onkeyup = '';
    if ($field->{'use_ajaxzip'} eq '4') {
        my $prefecture_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_prefecture_parts_id'}});
        my $city_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_city_parts_id'}});
        my $area_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_area_parts_id'}});
        my $street_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_street_parts_id'}});
        if ($prefecture_field && $city_field && $area_field && $street_field) {
            $onkeyup = sprintf(q( onKeyUp="AjaxZip2.zip2addr(this,'aform-field-%d','aform-field-%d',null,'aform-field-%d','aform-field-%d');"), $prefecture_field->id, $city_field->id, $street_field->id, $area_field->id);
        }
    }
    elsif ($field->{'use_ajaxzip'} eq '3') {
        my $prefecture_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_prefecture_parts_id'}});
        my $city_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_city_parts_id'}});
        my $street_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_street_parts_id'}});
        if ($prefecture_field && $city_field && $street_field) {
            $onkeyup = sprintf(q( onKeyUp="AjaxZip2.zip2addr(this,'aform-field-%d','aform-field-%d',null,'aform-field-%d');"), $prefecture_field->id, $city_field->id, $street_field->id);
        }
    }
    elsif ($field->{'use_ajaxzip'} eq '2') {
        my $prefecture_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_prefecture_parts_id'}});
        my $city_field = MT::AFormField->load({'aform_id' => $field->{'aform_id'}, 'parts_id' => $field->{'ajaxzip_city_parts_id'}});
        if ($prefecture_field && $city_field) {
            $onkeyup = sprintf(q( onKeyUp="AjaxZip2.zip2addr(this,'aform-field-%d','aform-field-%d',null,'aform-field-%d');"), $prefecture_field->id, $city_field->id, $city_field->id);
        }
    }
    my $tag = '<input 
        id="'. encode_html($field->{'parts_id'}) .'"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'" 
        type="text" 
        '. put_attr_value($field->{'value'}) .' 
        size="40" 
        title="'. encode_html(&_get_tag_title($field)) .'"
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .
        $onkeyup .' />';
    return $tag;
}

# textarea
sub _make_textarea_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-textarea', $field->{'parts_id'}, 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'min_length'} || $field->{'max_length'} ){ push @classes, 'validate-length'; }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }

    my $pattern = _make_field_pattern($field);

    my $tag = '<textarea 
        id="'. encode_html($field->{'parts_id'}) .'"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'" 
        cols="40" 
        rows="6" 
        title="'. encode_html(&_get_tag_title($field)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .'>'. encode_html(defined $field->{'value'} ? $field->{'value'} : "") .'</textarea>';
    return $tag;
}

# radio
sub _make_radio_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-radio', $field->{'parts_id'}, 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'is_necessary'} ){ push @classes, 'validate-one-required'; }

    my $additional_ul_class = $field->{'options_horizontally'} ? 'aform-horizontal-ul' : 'aform-vertical-ul';
    my $tag = '<ul class="aform-radio-ul aform-field-'. $field->{'id'} .' '. $field->{'parts_id'} .' '. $additional_ul_class .'">';
    foreach my $option( @{$field->{'options'}} ){
        my $checked = '';
        if( $field->{'value'} ){
            if( $field->{'value'} eq $$option{value} ){
                $checked = ' checked="checked"';
            }
        }
        elsif( $$option{checked} ){
            $checked = ' checked="checked"';
        }

        my $other_text = '';
        if( $$option{use_other} ){
            $other_text = '<input 
                type="text" 
                class="aform-validate aform-field-option-text validate-option-text '. $field->{'parts_id'} .'"
                id="'. encode_html($field->{'parts_id'}) .'-'. $$option{index} .'-text"
                name="aform-field-'. $field->{'id'} .'-'. $$option{index} .'-text"
                title="'. encode_html(plugin()->translate("please input [_1] text.", $$option{label})) .'"
                '. put_attr_value($field->{'hash_other_texts'}{$$option{value}}) .'
            />';
        }
        $tag .= '<li><input
            class="'. encode_html(join(' ', @classes)) .'" 
            id="'. encode_html($field->{'parts_id'}) .'-'. $$option{index} .'" 
            name="aform-field-'. encode_html($field->{'id'}) .'"
            type="radio" 
            value="'. encode_html($$option{value}) .'" 
            '. ($field->{'is_necessary'} ? 'required' : '') .'
            title="'. encode_html(&_get_tag_title($field)) .'"'.
            $checked .' />';
        $tag .= '<label for="'. encode_html($field->{'parts_id'}) .'-'. encode_html($$option{index}) .'">'. encode_html($$option{label}) .'</label>'. $other_text .'</li>';
    }
    $tag .= '</ul>';
    return $tag;
}

# checkbox
sub _make_checkbox_tag {
    my( $field, $additional_class ) = @_;

    my $values = $field->{'values'};
    my @classes = ('aform-input', 'aform-checkbox', $field->{'parts_id'}, 'aform-validate');
    if( $field->{'type'} eq 'checkbox' && $field->{'is_necessary'} ){ 
        push @classes, 'validate-one-required';
    }
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }

    my $additional_ul_class = $field->{'options_horizontally'} ? 'aform-horizontal-ul' : 'aform-vertical-ul';
    my $tag = '<ul class="aform-checkbox-ul aform-field-'. $field->{'id'} .' '. $field->{'parts_id'} .' '. $additional_ul_class .'">';
    foreach my $option( @{$field->{'options'}} ){
        my $checked = '';
        if( ref $values eq 'ARRAY' ){
            my $found = grep $_ eq $$option{index}, @$values;
            if( $found ){
                $checked = ' checked="checked"';
            }
        }
        elsif( $$option{checked} ){
            $checked = ' checked="checked"';
        }

        my $other_text = '';
        if( $$option{use_other} ){
            $other_text = '<input 
                type="text" 
                class="aform-validate aform-field-option-text validate-option-text '. $field->{'parts_id'} .'"
                id="'. encode_html($field->{'parts_id'}) .'-'. $$option{index} .'-text"
                name="aform-field-'. $field->{'id'} .'-'. $$option{index} .'-text"
                title="'. encode_html(plugin()->translate("please input [_1] text.", $$option{label})) .'"
                '. put_attr_value($field->{'hash_other_texts'}{$$option{index}}) .'
            />';
        }
        $tag .= '<li><input
            class="'. encode_html(join(' ', @classes)) .'" 
            id="'. encode_html($field->{'parts_id'}) .'-'. $$option{index} .'" 
            name="aform-field-'. $field->{'id'} .'-'. $$option{index} .'"
            type="checkbox" 
            value="'. encode_html($$option{index}) .'" 
            '. ($field->{'is_necessary'} ? '' : '') .'
            title="'. encode_html(&_get_tag_title($field)) .'"'.
            $checked .' />';
        $tag .= '<label for="'. encode_html($field->{'parts_id'}) .'-'. encode_html($$option{index}) .'">'. encode_html($$option{label}) .'</label>'. $other_text .'</li>';
    }
    $tag .= '</ul>';
    return $tag;
}

# select
sub _make_select_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'aform-validate');
    if( $field->{'is_necessary'} ){ push @classes, 'validate-selection'; }
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }

    my $tag = '<select 
        id="'. encode_html($field->{'parts_id'}) .'"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'"
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        title="'. encode_html(&_get_tag_title($field)) .'">';
    if( $field->{'use_default'} ){
        $tag .= '<option value="">'. plugin()->translate('Please select') .'</option>';
    }
    foreach my $option( @{$field->{'options'}} ){
        my $selected = '';
        if( $field->{'value'} ){
            if( $field->{'value'} eq $$option{value} ){
                $selected = ' selected';
            }
        }
        $tag .= '<option value="'. encode_html($$option{value}) .'"'. $selected .'>'. encode_html($$option{label}) .'</option>';
    }
    $tag .= '</select>';
    return $tag;
}

# upload
sub _make_upload_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }

    my $tag = '<input 
        id="'. encode_html($field->{'parts_id'}) .'"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'"
        type="file" 
        size="40" 
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        title="'. encode_html(&_get_tag_title($field)) .'" />';
    return $tag;
}

# parameter
sub _make_parameter_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }

    my $tag = '<input
        class="'. encode_html(join(' ', @classes)) .'" 
        title="'. encode_html(&_get_tag_title($field)) .'"
        type="hidden" 
        id="'. encode_html($field->{'parts_id'}) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'"
        '. put_attr_value($field->{'value'}) .' />';
    if( $field->{'show_parameter'} ){
        $tag .= '<span id="'. encode_html($field->{'parts_id'}) .'-text"></span>';
    }
    $tag .= '<script type="text/javascript">
      aform.parameters["' . encode_html($field->{'parts_id'}) . '"] = "' . encode_html($field->{'parameter_name'}) .'";
    </script>';
    return $tag;
}

# calendar
sub _make_calendar_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'aform-validate');
    if( $field->{'is_necessary'} ){ push @classes, 'validate-selection'; }
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }

    my $default_value = $field->{'default_value'};
    # year
    my $tag = '<select
        class="'. encode_html(join(' ', @classes)) .'" 
        id="'. encode_html($field->{'parts_id'}) .'-yy" 
        name="aform-field-'. encode_html($field->{'id'}) .'-yy" 
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        title="'. encode_html(plugin()->translate('please select year')) .'">';
    $tag .= '<option value="">----</option>';
    for( my $yy = $field->{'range_from'}; $yy <= $field->{'range_to'}; $yy++ ){
        my $selected = '';
        if( $field->{'yy'} ){
            if( $field->{'yy'} eq $yy ){
                $selected = ' selected';
            }
        }
        $tag .= sprintf('<option value="%d"%s>%d</option>', $yy, $selected, $yy);
    }
    $tag .= '</select><label for="'. encode_html($field->{'parts_id'}) .'-yy">'. encode_html(plugin()->translate('year')) .'</label>';

    # month
    $tag .= '<select
        class="'. encode_html(join(' ', @classes)) .'" 
        id="'. encode_html($field->{'parts_id'}) .'-mm" 
        name="aform-field-'. encode_html($field->{'id'}) .'-mm" 
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        title="'. encode_html(plugin()->translate('please select month')) .'">';
    $tag .= '<option value="">--</option>';
    for( my $mm = 1; $mm <= 12; $mm++ ){
        my $selected = '';
        if( $field->{'mm'} ){
            if( $field->{'mm'} eq $mm ){
                $selected = ' selected';
            }
        }
        $tag .= sprintf('<option value="%d"%s>%d</option>', $mm, $selected, $mm);
    }
    $tag .= '</select><label for="'. encode_html($field->{'parts_id'}) .'-mm">'. encode_html(plugin()->translate('month')) .'</label>';

    # day
    $tag .= '<select
        class="'. encode_html(join(' ', @classes)) .'" 
        id="'. encode_html($field->{'parts_id'}) .'-dd" 
        name="aform-field-'. encode_html($field->{'id'}) .'-dd" 
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        title="'. encode_html(plugin()->translate('please select day')) .'">';
    $tag .= '<option value="">--</option>';
    for( my $dd = 1; $dd <= 31; $dd++ ){
        my $selected = '';
        if( $field->{'dd'} ){
            if( $field->{'dd'} eq $dd ){
                $selected = ' selected';
            }
        }
        $tag .= sprintf('<option value="%d"%s>%d</option>', $dd, $selected, $dd);
    }
    $tag .= '</select><label for="'. encode_html($field->{'parts_id'}) .'-dd">'. encode_html(plugin()->translate('day')) .'</label>';

    $tag .= '<span><input type="hidden" id="'. encode_html($field->{'parts_id'}) .'" name="aform-field-'. encode_html($field->{'id'}) .'" ></span>';

    # disable dates
    my $disable_dates = '';
    my %disable_dates = %{$field->{'disable_dates'}};
    foreach my $ymd (keys %disable_dates) {
        my $disable_date = $disable_dates{$ymd};
        $disable_dates .= '"'. $ymd .'": {"title": "'. $disable_date->{'title'} .'"},';
    }
    $disable_dates =~ s/,$//;

    $tag .= '<script type="text/javascript">
aform.datepickers["'. encode_html($field->{'parts_id'}) .'"] = {
  range_from: "'. encode_html($field->{'range_from'}) .'",
  range_to: "'. encode_html($field->{'range_to'}) .'",
  default_value: "'. encode_html($field->{'default_value'}{'text'}) .'",
  disable_dates: {'. $disable_dates .'}
};
</script>';

    if ($field->{'abs_range_from'} && $field->{'abs_range_from'} ne '') {
    $tag .= '<script type="text/javascript">
if (typeof aform.range_from === "undefined") {
  aform.range_from = new Object;
  aform.range_from_msg = "'. plugin()->translate("Please enter date after [_1].", "%date%") .'";
}
today = new Date();
aform.range_from["'. encode_html($field->{'parts_id'}) .'"] = new Date(today.getFullYear(), today.getMonth(), today.getDate() + '. $field->{'abs_range_from'} .');
</script>';
    }

    return $tag;
}

# text
sub _make_password_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'min_length'} || $field->{'max_length'} ){ push @classes, 'validate-length'; }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }

    my $pattern = _make_field_pattern($field);

    my $tag = '<input 
        id="'. encode_html($field->{'parts_id'}) .'"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'" 
        type="password" 
        size="40" 
        title="'. encode_html(&_get_tag_title($field)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .' />';
    if ($field->{'require_twice'}) {
        $tag .= _make_reenter_tag('password', $field, @classes);
    }
    return $tag;
}

# name
sub _make_name_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'validate-name', 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'min_length'} || $field->{'max_length'} ){ push @classes, 'validate-length'; }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }

    my $pattern = _make_field_pattern($field);

    my $title_label = sprintf("%s(%s)", $field->{'label'}, plugin->translate('Last name'));
    my $tag = '<ul class="aform-name-ul">';
    $tag .= '<li>';
    $tag .= '<label for="'. $field->{'parts_id'} .'-lastname">'. plugin()->translate('Last name') .'</label>
      <input 
        id="'. encode_html($field->{'parts_id'}) .'-lastname"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'-lastname" 
        type="text" 
        '. put_attr_value($field->{'lastname'}) .'
        size="20" 
        title="'. encode_html(&_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .' />';
    $tag .= '</li>';

    $title_label = sprintf("%s(%s)", $field->{'label'}, plugin->translate('First name'));
    $tag .= '<li>';
    $tag .= '<label for="'. $field->{'parts_id'} .'-firstname">'. plugin()->translate('First name') .'</label>
      <input 
        id="'. encode_html($field->{'parts_id'}) .'-firstname"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'-firstname" 
        type="text" 
        '. put_attr_value($field->{'firstname'}) .'
        size="20" 
        title="'. encode_html(&_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .' />';
    $tag .= '</li>';
    $tag .= '</ul>';
    return $tag;
}

# kana
sub _make_kana_tag {
    my( $field, $additional_class ) = @_;

    my @classes = ('aform-input', 'aform-'. $field->{'type'}, $field->{'parts_id'}, 'validate-name-kana', 'aform-validate');
    if( ref($additional_class) eq 'ARRAY' ){
        @classes = (@classes, @$additional_class);
    }
    if( $field->{'min_length'} || $field->{'max_length'} ){ push @classes, 'validate-length'; }
    if( $field->{'is_necessary'} ){ push @classes, 'required'; }

    my $pattern = _make_field_pattern($field);

    my $title_label = sprintf("%s(%s)", $field->{'label'}, plugin->translate('Last name kana'));
    my $tag = '<ul class="aform-kana-ul">';
    $tag .= '<li>';
    $tag .= '<label for="'. $field->{'parts_id'} .'-lastname-kana">'. plugin()->translate('Last name(kana)') .'</label>
      <input 
        id="'. encode_html($field->{'parts_id'}) .'-lastname-kana"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'-lastname-kana" 
        type="text" 
        '. put_attr_value($field->{'lastname_kana'}) .' 
        size="20" 
        title="'. encode_html(&_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .' />';
    $tag .= '</li>';

    $title_label = sprintf("%s(%s)", $field->{'label'}, plugin->translate('First name kana'));
    $tag .= '<li>';
    $tag .= '<label for="'. $field->{'parts_id'} .'-firstname-kana">'. plugin()->translate('First name(kana)') .'</label>
      <input 
        id="'. encode_html($field->{'parts_id'}) .'-firstname-kana"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'-firstname-kana" 
        type="text" 
        '. put_attr_value($field->{'firstname_kana'}) .' 
        size="20" 
        title="'. encode_html(&_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->{'is_necessary'} ? 'required' : '') .'
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .' />';
    $tag .= '</li>';
    $tag .= '</ul>';
    return $tag;
}

sub _make_field_pattern {
    my ($field) = @_;
    my $chars = '';
    if ($field->{'only_ascii'}) {
         $chars = '[\\x21-\\x7E]';
    }
    my $length = '';
    if ($field->{'min_length'} || $field->{'max_length'}) {
        $chars = $chars ? $chars : '.';
        $length = sprintf('{%s,%s}', $field->{'min_length'}, $field->{'max_length'});
    }
    my $pattern = '';
    if ($chars || $length) {
        $pattern = sprintf('pattern="%s"', encode_html($chars . $length));
    }
    return $pattern;
}

# get tag title
sub _get_tag_title {
    my( $field, $label ) = @_;

    my $length_msg = '';
    if ($field->{'only_ascii'}) {
        $length_msg = plugin()->translate('Only ascii characters');
    }
    if ($field->{'min_length'} && $field->{'max_length'}) {
        $length_msg .= plugin()->translate('[_1]-[_2] characters', $field->{'min_length'}, $field->{'max_length'});
    }
    elsif ($field->{'min_length'}) {
        $length_msg .= plugin()->translate('minimum [_1] characters', $field->{'min_length'});
    }
    elsif ($field->{'max_length'}) {
        $length_msg .= plugin()->translate('max [_1] characters', $field->{'max_length'});
    }

    my $title = "";
    if( $field->{'type'} eq 'radio' || $field->{'type'} eq 'checkbox' || $field->{'type'} eq 'select' || $field->{'type'} eq 'prefecture' ){
        $title = plugin()->translate('please select');
    }elsif( $field->{'type'} eq 'email' ){
        if( $length_msg ){
            $title = plugin()->translate("please input [_1] (alphabet and numeric only. [_2].)", $field->{'label'}, $length_msg);
        }else{
            $title = plugin()->translate("please input [_1] (alphabet and numeric only.)", $field->{'label'});
        }
        $title .= ' ' . plugin()->translate('ex) foo@example.com');
    }elsif( $field->{'type'} eq 'tel' ){
        if( $length_msg ){
            $title = plugin()->translate("please input [_1] (numeric and hyphen only. [_2].)", $field->{'label'}, $length_msg);
        }else{
            $title = plugin()->translate("please input [_1] (numeric and hyphen only.)", $field->{'label'});
        }
        $title .= ' ' . plugin()->translate("ex) 03-1234-5678");
        if ($field->{'require_hyphen'}) {
            $title .= ' ' . plugin()->translate('(require hyphen)');
        }
    }elsif( $field->{'type'} eq 'zipcode' ){
        if( $length_msg ){
            $title = plugin()->translate("please input [_1] (numeric and hyphen only. [_2].)", $field->{'label'}, $length_msg);
        }else{
            $title = plugin()->translate("please input [_1] (numeric and hyphen only.)", $field->{'label'});
        }
        $title .= ' ' . plugin()->translate("ex) 123-4567");
        if ($field->{'require_hyphen'}) {
            $title .= ' ' . plugin()->translate('(require hyphen)');
        }
    }elsif( $field->{'type'} eq 'url' ){
        if( $length_msg ){
            $title = plugin()->translate("please input [_1] (alphabet and numeric only. [_2].)", $field->{'label'}, $length_msg);
        }else{
            $title = plugin()->translate("please input [_1] (alphabet and numeric only.)", $field->{'label'});
        }
        $title .= ' ' . plugin()->translate("ex) http://www.example.com/");
    }elsif( $field->{'type'} eq 'privacy' ){
        $title = plugin()->translate("please agree to [_1]. put a check to agree.", $field->{'label'});
    }elsif( $field->{'type'} eq 'upload' ){
        $title = plugin()->translate("please choose a file.");
    }elsif( $field->{'type'} eq 'parameter' ){
        $title = plugin()->translate("[_1] is empty", $field->{'label'});
    }elsif( $field->{'type'} eq 'text' || $field->{'type'} eq 'textarea' || $field->{'type'} eq 'password' || $field->{'type'} eq 'name' ){
        $label = $field->{'label'} unless $label;
        if( $length_msg ){
            $title = plugin()->translate("please input [_1] ([_2]).", $label, $length_msg);
        }else{
            $title = plugin()->translate("please input [_1]", $label);
        }
    }elsif( $field->{'type'} eq 'kana' ){
        $label = $field->{'label'} unless $label;
        if( $length_msg ){
            $title = plugin()->translate("please input [_1] ([_2]) in katakana", $label, $length_msg);
        }else{
            $title = plugin()->translate("please input [_1] in katakana", $label);
        }
    }


    return $title;
}

# <MTAFormFieldConfirm>
sub hdlr_aform_field_confirm {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    my $parts_id = $args->{parts_id};
    return MT->translate('aform_id is empty') unless $aform_id;
    return MT->translate('parts_id is empty') unless $parts_id;
    my $option = $args->{option} || "";

    my $app = MT::App->instance;

    my $stash_name = sprintf('aform%0d_fields', $aform_id);
    if (!$ctx->stash($stash_name)) {
      my $aform = MT::AForm->load({id => $aform_id});
      return "" unless $aform;
      my $get_fields = &AFormEngineCGI::FormMail::_get_fields($app, $aform);
      my $fields = &AFormEngineCGI::FormMail::_inject_param_value($app, $get_fields, 'html');
      $ctx->stash($stash_name, $fields);
    }
    my $fields = $ctx->stash($stash_name);

    my $tag;
    foreach my $field (@$fields){
        if( $field->{parts_id} eq $parts_id ){
             if( $field->{type} ne 'parameter' || $field->{show_parameter} ){
                 my $label_value = $field->{label_value};
                 if( $field->{type} eq 'upload' && $label_value ne ''){
                     $label_value .= sprintf('(%s)', encode_html($field->{filesize_text}));
                 }
                 if ($field->{type} eq 'name' || $field->{type} eq 'kana') {
                    my ($lastname, $firstname) = split(" ", $label_value);
                    if ($option eq 'firstname') {
                        $label_value = $firstname;
                    }
                    if ($option eq 'lastname') {
                        $label_value = $lastname;
                    }
                 }
                 $tag = sprintf('<span class="aform-confirm %s">%s</span>', encode_html($parts_id), $label_value);
             }
             last;
        }
    }
    return $tag;
}

# <MTAFormFieldConfirmAll>
sub hdlr_aform_field_confirm_all {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    return MT->translate('aform_id is empty') unless $aform_id;
    my $option = $args->{option} || "";

    my $app = MT::App->instance;
    my $aform = MT::AForm->load({id => $aform_id});
    return "" unless $aform;
    my $get_fields = &AFormEngineCGI::FormMail::_get_fields($app, $aform);
    my $fields = &AFormEngineCGI::FormMail::_inject_param_value($app, $get_fields, 'html');

    my $prefix = $args->{prefix} || '';
    my $suffix = $args->{suffix} || '';
    my $label_prefix = $args->{label_prefix} || '';
    my $label_suffix = $args->{label_suffix} || '';
    my $data_prefix = $args->{data_prefix} || '';
    my $data_suffix = $args->{data_suffix} || '';

    my $label_args;
    $label_args->{aform_id} = $aform_id;
    $label_args->{tag}      = $args->{label_tag} || 'span';

    my $tag;
    foreach my $field (@$fields){
        if( $field->{type} eq 'parameter' && !$field->{show_parameter} ){
            next;
        }

        if( $field->{type} eq 'label') {
            $tag .= _make_label_tag($field);
        } elsif( $field->{type} eq 'note') {
            $tag .= _make_note_tag($field);
        } else {
            # prefix
            $tag .= _replace_parts_id($prefix, $field->{parts_id});
            # label
            $label_args->{parts_id} = $field->{parts_id};
            $tag .= _replace_parts_id($label_prefix, $field->{parts_id}) . hdlr_aform_field_label($ctx, $label_args, $cond) . $label_suffix;

            # data
            my $label_value = $field->{label_value};
            if( $field->{type} eq 'upload' && $label_value ne ''){
                $label_value .= sprintf('(%s)', encode_html($field->{filesize_text}));
            }
            if ($field->{type} eq 'name' || $field->{type} eq 'kana') {
               my ($lastname, $firstname) = split(" ", $label_value);
               if ($option eq 'firstname') {
                   $label_value = $firstname;
               }
               if ($option eq 'lastname') {
                   $label_value = $lastname;
               }
            }
            $tag .= _replace_parts_id($data_prefix, $field->{parts_id}) . sprintf('<span class="aform-confirm %s">%s</span>', encode_html($field->{parts_id}), $label_value) . $data_suffix;
            # suffix
            $tag .= $suffix;
        }
    }
    return $tag;
}

sub _replace_parts_id {
    my ($str, $parts_id) = @_;

    $str =~ s/%%parts_id%%/$parts_id/g;
    return $str;
}

sub _update_aform_data_status_all {
    my $app = shift;

    my %params = $app->param_hash;
    foreach my $key (keys %params) {
        if( $key =~ m/^data_status_(\d+)$/i ){
            my $aform_data_id = $1;
            my $status = $params{$key};
            my $aform_data = MT::AFormData->load($aform_data_id);
            if( $aform_data && $aform_data->status ne $status ){
                $aform_data->set_values({
                    status => $status,
                });
                $aform_data->save;
                my $aform = MT::AForm->load($aform_data->aform_id);
                $app->log({message => $app->translate('[_1](ID:[_2]) data #[_3] status has been changed by [_4](ID:[_5]).', $aform->title, $aform->id, $aform_data->disp_data_id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});
            }
        }
    }

    return $app->redirect($app->return_uri . '&saved_changes=1');
}

sub _update_aform_data_status_and_comment {
    my $app = shift;

    my $aform_data_id = $app->param('aform_data_id');
    return $app->error("Invalid aform_data_id.") unless $aform_data_id;
    my $aform_data = MT::AFormData->load($aform_data_id);
    return $app->error("not found aform_data.") unless $aform_data;
    my $aform = MT::AForm->load($aform_data->aform_id);
    return $app->error("not found aform.") unless $aform;
    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'change_aform_data_status');
    my $aform_data_orig = $aform_data->clone;

    $aform_data->set_values({
        status  => ($app->param('status') || ''),
        comment => ($app->param('comment') || ''),
    });
    $aform_data->save or return $app->error($aform_data->errstr);

    $app->log({message => $app->translate('[_1](ID:[_2]) data #[_3] status and comment has been saved by [_4](ID:[_5]).', $aform->title, $aform->id, $aform_data->disp_data_id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});

    MT->run_callbacks('aform_after_update_aform_data_status_and_comment', $app, $aform, $aform_data, $aform_data_orig);

    return $app->redirect($app->return_uri . '&saved_changes=1');
}

sub can_create_amember_form {
  my $app = shift;

  if ($app->blog) {
    return 0;
  }
  my $amember = &_get_amember();
  if ($amember) {
    if (!$amember->aform_id) {
      my $perms = $app->user->permissions;
      return( $perms && $perms->can_create_website );
    }
  }
  return 0;
}

sub _is_amember_form {
  my $aform_id = shift;

  my $amember = &_get_amember();
  if ($amember) {
    return ($amember->aform_id eq $aform_id);
  }
  return 0;
}

sub _exists_amember_user {
  my $amember = &_get_amember();
  if ($amember) {
    my $count = MT::Entry->count({blog_id => $amember->user_blog_id});
    return 1 if $count > 0;
  }
  return 0;
}

sub _amember_user_id_field {
  my $amember = &_get_amember();
  if ($amember && $amember->user_id_field =~ m/^amember_(.*)$/) {
    return $1;
  }
  return '';
}

sub _get_langs {
  my $app = shift;

  my $plugin = MT->component('AForm');

  my %langs;
  my $lang_dir = &get_aform_dir . '/lib/AForm/L10N/';
  if (opendir(DIR, $lang_dir)) {
    while (my $file = readdir(DIR)) {
      if ($file =~ m/^(.*)\.pm$/) {
        my $code = $1;
        $langs{$code} = $plugin->translate($code);
      }
    }
    closedir(DIR);
  }

  return \%langs;
}

sub _is_aform_mobile_installed {
  return MT->component('AFormMobile');
}

sub _is_amember_installed {
  return MT->component('AMember');
}

sub _get_amember {
  if (!_is_amember_installed()) {
    return undef;
  }
  require MT::AMember;
  my $amember = MT::AMember->load({}, {'limit' => 1});
  if (!$amember) {
    $amember = MT::AMember->new;
  }
  return $amember;
}

sub _set_mobile_info_for_list_aform_input_error {
    my($aform_id, $param) = @_;

    # access count
    my @aform_access = MT::AFormMobileAccess->load({ aform_id => $aform_id });
    my( $session, $pv, $conversion_count);
    foreach my $access ( @aform_access ){
        $session += $access->session;
        $pv += $access->pv;
        $conversion_count += $access->cv;
    }

    # conversion rate
    my $conversion_rate;
    if( $pv > 0 ){
        $conversion_rate = sprintf("%0.2f", $conversion_count / $pv * 100) . '%';
    }

    $$param{'mobile_installed'} = 1;
    $$param{'mobile_session'} = $session || 0;
    $$param{'mobile_pv'} = $pv || 0;
    $$param{'mobile_conversion_count'} = $conversion_count || 0;
    $$param{'mobile_conversion_rate'} = $conversion_rate || '-.--';
}

sub can_edit_register_form {
    return 0 unless _is_amember_installed();
    return aform_superuser_permission();
}


sub _make_reenter_tag {
    my ($type, $field, @classes) = @_;

    push @classes, 'require-twice aform-validate';
    my $tag = '<br />
        <label for="'. encode_html($field->{'parts_id'}) .'-confirm" class="aform-twice-note">'. plugin()->translate('Please re-enter to confirmation') .'</label>
        <input
        id="'. encode_html($field->{'parts_id'}) .'-confirm"
        class="'. encode_html(join(' ', @classes)) .'" 
        name="aform-field-'. encode_html($field->{'id'}) .'-confirm" 
        type="'. $type .'" 
        size="40" 
        title="'. encode_html(plugin->translate('Please re-enter same value.')) .'"
        '. ($field->{'max_length'} ? 'maxlength="'. encode_html($field->{'max_length'}) .'"' : '') .' />';
    return $tag;
}

sub get_aform_action_tabs {
    my ($app, $blog_id, $aform_id, $mode) = @_;

    my %param = (
        current_blog_id => $blog_id,
        current_aform_id => $aform_id,
        current_mode => $mode,
        aform_reserve_installed => &_aform_reserve_installed,
        aform_payment_installed => &_aform_payment_installed,
        can_edit_aform_field => can_do($app, $blog_id, 'edit_aform_field'),
        can_edit_aform => can_do($app, $blog_id, 'edit_aform'),
        can_manage_aform_data => can_do($app, $blog_id, 'manage_aform_data'),
        can_list_aform_input_error => can_do($app, $blog_id, 'list_aform_input_error'),
        can_list_aform_entry => can_do($app, $blog_id, 'list_aform_entry'),
        can_aform_reserve => can_do($app, $blog_id, 'list_aform_reserve_plan'),
        can_aform_payment => can_do($app, $blog_id, 'aform_payment'),
    );
    my $tmpl = plugin()->load_tmpl("include/aform_action_tabs.tmpl", \%param);
    return $app->build_page($tmpl, \%param);
}

sub can_list_aform {
    my $app = MT->app;
    my $blog_id = $app->blog ? $app->blog->id : 0;
    return can_do($app, $blog_id, 'list_aform');
}

sub has_permission_in_some_blog {
    my ($app, $perm) = @_;

    my $blog_iter = MT::Blog->load_iter();
    while (my $blog = $blog_iter->()) {
        if ($app->user->permissions($blog->id)->can_do($perm)) {
           return 1;
        }
    }
    return 0;
}

sub can_do {
    my ($app, $blog_id, $perm) = @_;

    return 1 if aform_superuser_permission();
    if ($perm eq 'preview_aform') {
        return has_permission_in_some_blog($app, $perm);
    } else {
        return $app->user->permissions($blog_id)->can_do($perm) ? 1 : 0;
    }
}

sub _list_aform_entry {
    my ($app) = shift;
    # check params
    my $blog_id = $app->param('blog_id') || '';
    my $aform_id = $app->param('id') || '';
    return $app->errtrans("Invalid request") unless $aform_id;
    my $aform = $app->model('aform')->load($aform_id);
    return $app->errtrans("Invalid request") unless $aform;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'list_aform_entry');

    return $app->return_to_dashboard()
      if ($blog_id && $aform->blog_id && $aform->blog_id ne $blog_id);

    my @aform_entries = MT::AFormEntry->load({aform_id => $aform_id});
    foreach my $aform_entry (@aform_entries) {
        my $data;
        if ($aform_entry->type eq 'content_data') {
            $data = MT::ContentData->load($aform_entry->entry_id);
        } else {
            $data = MT::Entry->load($aform_entry->entry_id);
        } 
        if (!$data) {
            $aform_entry->remove or die $aform_entry->errstr;
        }
    }

    $app->{plugin_template_path} = 'plugins/AForm/tmpl';

    my %terms;
    $terms{'aform_id'} = $aform_id;
    if( $blog_id ){
        $terms{'blog_id'} = [0, $blog_id];
    }

    my %param;
    if( my $next = $aform->next({exclude_amember => 1}) ){
      $param{next_aform_id} = $next->id;
    }
    if( my $previous = $aform->previous({exclude_amember => 1}) ){
      $param{previous_aform_id} = $previous->id;
    }
    $param{aform_reserve_installed} = _aform_reserve_installed();
    $param{aform_payment_installed} = _aform_payment_installed();
    $param{aform_action_tabs} = &get_aform_action_tabs($app, $blog_id, $aform_id, 'list_aform_entry');
    $param{plugin_static_uri} = _get_plugin_static_uri($app);
    $param{display_title} = sprintf("%s(aform%03d)", plugin()->translate('Place [_1]', $aform->title), $aform_id);

    my $html = $app->listing({
        Type => 'aform_entry',
        Terms => \%terms,
        Args => { 'sort' => 'id',
#                  'join' => ['MT::Entry', undef, {id => \'=aform_entry_entry_id'}, undef],
        },
        Code => \&_aform_entry_item_for_display,
        Params => \%param,
    });
    return $app->build_page($html);
}

sub _aform_entry_item_for_display {
    my $obj = shift;
    my $item_hash = shift;

    my $app = MT->instance;
    my $type = $obj->type || 'entry';
    my $data;
    if ($type eq 'content_data') {
        $data = MT::ContentData->load($obj->entry_id) or return 0;
    } else {
        $data = MT::Entry->load($obj->entry_id) or return 0;
    } 
    my $blog = MT::Blog->load($data->blog_id) or return 0;

    $item_hash->{'entry_id'} = $data->id;
    $item_hash->{'entry_blog_id'} = $data->blog_id;
    $item_hash->{'type'} = $type;
    $item_hash->{'blog_name'} = $blog->name;
    $item_hash->{'entry_permalink'} = $data->permalink;
    if ($type eq 'entry') {
        $item_hash->{'entry_class'} = $data->class;
        $item_hash->{'entry_title'} = $data->title;
        $item_hash->{'entry_category'} = $data->category ? $data->category->label : "";
        $item_hash->{'edit_link'} = $app->uri(
            mode => 'view',
            args => {
                _type => $data->class,
                blog_id => $data->blog_id,
                id => $data->id,
            },
        );
    }
    elsif ($type eq 'content_data') {
#        $item_hash->{'entry_class'} = $data->class;
        $item_hash->{'entry_title'} = $data->label;
        $item_hash->{'entry_category'} = "";
        $item_hash->{'edit_link'} = $app->uri(
            mode => 'view',
            args => {
                blog_id => $data->blog_id,
                _type => 'content_data',
                content_type_id => $data->content_type_id,
                id => $data->id,
            },
        );
    }
}

sub get_aform_dir {
    return dirname(dirname(dirname(__FILE__)));
}

sub _clear_aform_access {
    my $app = shift;
    my $aform_id = $app->param('id')
      or return $app->error( $app->translate("Invalid request") );
    my $aform = MT::AForm->load($aform_id)
      or return $app->error( $app->translate("Invalid request") );
    $app->validate_magic() or return;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'clear_aform_access');

    # delete data
    my $iter = MT::AFormAccess->load_iter({aform_id => $aform_id});
    while (my $aform_access = $iter->()) {
        $aform_access->remove;
    }

    $app->log({message => $app->translate('[_1](ID:[_2]) access report was cleared by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});

    return $app->redirect( $app->uri( mode => 'list_aform_input_error', args => { id => $aform_id, cleared_aform_access => 1, blog_id => $app->param('blog_id')} ) );
}

sub _clear_aform_input_error {
    my $app = shift;
    my $aform_id = $app->param('id')
      or return $app->error( $app->translate("Invalid request") );
    my $aform = MT::AForm->load($aform_id)
      or return $app->error( $app->translate("Invalid request") );
    $app->validate_magic() or return;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'clear_aform_input_error');

    # delete data
    my $iter = MT::AFormInputError->load_iter({aform_id => $aform_id});
    while (my $aform_input_error = $iter->()) {
        $aform_input_error->remove;
    }

    $app->log({message => $app->translate('[_1](ID:[_2]) input error was cleared by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});

    return $app->redirect( $app->uri( mode => 'list_aform_input_error', args => { id => $aform_id, cleared_aform_input_error => 1, blog_id => $app->param('blog_id')} ) );
}

sub _export_aform_input_error {
    my $app = shift;
    my $aform_id = $app->param('id')
      or return $app->error( $app->translate("Invalid request") );
    my $aform = MT::AForm->load($aform_id)
      or return $app->error( $app->translate("Invalid request") );
    $app->validate_magic() or return;

    return $app->return_to_dashboard( permission => 1 )
      unless can_do($app, $aform->blog_id, 'export_aform_input_error');

    my $charset = $app->param('charset') || '';
    if ($charset ne 'shift_jis' && $charset ne 'utf-8') {
        $charset = ($aform->lang eq 'ja' || $aform->lang eq 'en_us') ? 'shift_jis' : 'utf-8';
    }
    my $ext = 'csv';

    my @ts = localtime(time);
    my $file = sprintf("export-%06d-%04d%02d%02d%02d%02d%02d.%s", $aform_id, $ts[5] + 1900, $ts[4] + 1, @ts[ 3, 2, 1, 0 ], $ext);

    local $| = 1;
    $app->{no_print_body} = 1;
    $app->set_header( "Cache-Control" => "public" );
    $app->set_header( "Pragma" => "public" );
    $app->set_header( "Content-Disposition" => "attachment; filename=$file" );
    $app->send_http_header(
        $charset
        ? "application/excel; charset=$charset"
        : 'application/excel'
    );

    my @labels = (
        $app->translate('Error Datetime'),
        $app->translate('Error Field'),
        $app->translate('Error Type'),
        $app->translate('Error Value'),
        $app->translate('Error Page'),
    );
    my $buf = _make_csv($app, @labels);
    # utf8 bom
    if ($charset eq 'utf-8') {
        $buf = "\x{feff}" . $buf;
    }
    $app->print(MT::I18N::encode_text($buf, 'utf-8', $charset));

    my $terms = {aform_id => $aform_id};
    my $args = {sort => 'created_on', direction => 'descend'};
    my $iter = MT::AFormInputError->load_iter($terms, $args);
    while (my $aform_input_error = $iter->()) {
        my $created_on = $aform_input_error->created_on;
        $created_on =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
        my $type = $app->translate($aform_input_error->type);
        my @values = (
            $created_on,
            $aform_input_error->field_label,
            $type,
            $aform_input_error->error_value,
            $aform_input_error->aform_url,
        );
        $buf = _make_csv($app, @values);
        $app->print(MT::I18N::encode_text($buf, 'utf-8', $charset));
    }

    $app->log({message => $app->translate('[_1](ID:[_2]) Input error CSV downloaded by [_3](ID:[_4]).', $aform->title, $aform->id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});
    1;
}

sub _make_csv {
    my $app = shift;
    my (@values) = @_;

    my $csv = "";
    foreach my $value (@values) {
        $value =~ s/"/""/g;
        $csv .= qq("$value",);
    }
    $csv =~ s/,$//;
    $csv .= "\n";
    return $csv;
}

sub hdlr_aform_field_relation_script {
    my ($ctx, $args, $cond) = @_;

    my $aform_id = $args->{aform_id};
    if (!$aform_id) { return ""; }

    my @fields = MT::AFormField->load({aform_id => $aform_id});
    if (!@fields) { return ""; }

    my %conds = (
        "eq" => "==",
        "ne" => "!=",
        "ge" => ">=",
        "gt" => ">",
        "le" => "<=",
        "lt" => "<",
    );


    my %targets;
    my %relations;
    foreach my $field (@fields) {
        if (ref $field->relations eq 'ARRAY') {
            foreach my $relation (@{$field->relations}) {
                if (!$targets{$relation->{"parts_id"}}) {
                    my $target_field = MT::AFormField->load({aform_id => $aform_id, parts_id => $relation->{"parts_id"}});
                    $targets{$relation->{"parts_id"}} = $target_field;
                }
                my $target_field = $targets{$relation->{"parts_id"}};
                if ($target_field) {
                    my $value = $relation->{"value"};
                    if ($target_field->options) {
                        foreach my $option (@{$target_field->options}) {
                            if ($option->{"label"} eq $value) {
                                $value = $option->{"value"};
                            }
                        }
                    }
                    my $cond = $conds{$relation->{"cond"}} ? $conds{$relation->{"cond"}} : "==";
                    if (ref $relations{$target_field->parts_id} ne "ARRAY") {
                        $relations{$target_field->parts_id} = ();
                    }
                    push @{$relations{$target_field->parts_id}}, {"parts_id" => $field->parts_id, "value" => $value, "cond" => $cond};
                }
            }
        }
    }

    my $script = 'aform.relations = '. MT::Util::to_json(\%relations);

    return $script;
}

sub init_request_aform_id {
    my ($app) = shift;

    my $aform_id = $app->param('aform_id') || $app->session('aform_id');
    $app->param('aform_id', $aform_id);
    $app->session('aform_id', $aform_id);
    return $aform_id;
}

sub post_save_content_data {
    my ($cb, $content) = @_;

    my $app = MT->instance;
    &_remove_aform_entry($app, $content->id, 'content_data');

    my $content_data = $content->data;
    foreach my $key (keys %$content_data) {
        my $text = $content_data->{$key};
        &_relate_aform_entry($app, $content, $text, '<\!--', '-->', 'content_data');
        &_relate_aform_entry($app, $content, $text, '\[\[', '\]\]', 'content_data');
    }
}

sub post_remove_content_data {
    my ($cb, $content) = @_;

    my $app = MT->instance;
    &_remove_aform_entry($app, $content->id, 'content_data');
}

sub install_aform_js_template {
    my ($app) = @_;

    my $template = MT::Template->load({blog_id => 0, identifier => 'aform_js'});
    if (!$template) {
        $template = MT::Template->new;
        $template->set_values({
             blog_id => 0,
             identifier => 'aform_js',
             name => 'aform_js',
             type => 'custom',
        });
    }
    $template->text( q(
<MTStaticWebPath setvar="static_uri">
<mt:unless name="exclude_jquery_js"><script src="<$mt:var name="static_uri"$>plugins/AForm/js/jquery.js" type="text/javascript"></script></mt:unless>
<script src="<$mt:var name="static_uri"$>plugins/AForm/js/jquery.validate.js" type="text/javascript"></script>
<script src="<$mt:var name="static_uri"$>plugins/AForm/js/jquery.cookie.js" type="text/javascript"></script>
<script type="text/javascript">jQuery.query = { numbers: false };</script>
<script src="<$mt:var name="static_uri"$>plugins/AForm/js/jquery.query.js" type="text/javascript"></script>
<script src="<$mt:var name="static_uri"$>plugins/AForm/js/jquery-ui.min.js" type="text/javascript"></script>
<mt:if name="aform_lang" eq="ja">
<script src="<$mt:var name="static_uri"$>plugins/AForm/js/jquery.ui.datepicker-ja.js" type="text/javascript"></script>
</mt:if>
<script src="<$mt:var name="static_uri"$>plugins/AForm/js/aform.js" type="text/javascript"></script>),
        );
    if (!$template->save) {
        $app->log({message => "AForm: failed to regist aform_js template. ". $template->errstr});
    }
    $app->log({message => "AForm: aform_js template was saved."});

    return $app->redirect($app->uri(
        mode => 'list_template',
        args => {
            blog_id => 0,
        },
    ));
}

sub get_amember_content_fields_json {
	my $app = shift;

	if (!_is_amember_installed()) {
		return $app->json_result(undef);
	}
	require AMember::Plugin;
	my $content_type = AMember::Plugin::load_amember_content_type($app);
	return $app->json_result($content_type->fields);
}

sub put_attr_value {
    my ($value) = @_;

    return (defined $value && $value ne "") ? 'value="'. encode_html($value) .'"' : '';
}

sub cgi_path {
    my $path = MT->config->CGIPath;
    $path =~ s!/$!!;
    $path =~ s!^https?://[^/]*!!;
    $path .= '/plugins/AForm';
    return $path;
}


sub dummy_method {
    return;
}

1;
