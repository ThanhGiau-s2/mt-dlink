# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormEngineCGI::FormMail;

use strict;
use Fcntl;
use Time::Local;
use AFormEngineCGI::Common;
use MT::Mail;
use MT::I18N;
use File::Copy;
use File::Basename;
use File::Temp;
use SendAttachedMail;


sub validate_param {
    my $app = shift;
    my $aform = shift;

    my $plugin = MT->component('AForm');
    my %error_msgs;

    my $fields = &_inject_param_value($app, &_get_fields($app, $aform), '');

    MT->run_callbacks('aform_before_validate', scalar $app->param('id'), $fields, \%error_msgs, $app);

    my $ng_words = $aform->ng_word_check($fields);
    if (ref $ng_words eq 'ARRAY' && scalar @$ng_words > 0) {
      push(@{$error_msgs{ng_words}}, $plugin->translate('There are NG words in your post content.'));
    }

    foreach my $field ( @$fields ){
        my $parts_id = $field->{'parts_id'};
        # Necessary
        if( $field->{'is_necessary'} ) {
          if( $field->{'type'} eq 'upload' ){
            if( !$field->{'value'} || !-e &_get_upload_tmp_dir($app) . $field->{'value'} ){
              push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] failed to upload.', $field->{'label'}));
            }
          }else{
            if( !&AFormEngineCGI::Common::must_check( $field->{'label_value'} ) ) {
              if( $field->{'type'} eq 'privacy' ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please agree to [_1]. Please check if you agree. (It is not possible to send if you do not agree.)', $field->{'label'}));
              }else{
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] is not input.', $field->{'label'}));
              }
            }
          }
        }

        # require twice
        if( $field->{'require_twice'} ){
          if( $field->{'value'} ne $field->{'confirm_value'} ){
            push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter same value to [_1]-confirm.', $field->{'label'}));
          }
        }

        # other text check
        if( $field->{'type'} eq 'checkbox' ){
          foreach my $option_id (keys %{$field->{'hash_values'}}) {
            if( $field->{'options'}[$option_id-1]->{'use_other'} ){
              if( !&AFormEngineCGI::Common::must_check($field->{'hash_other_texts'}{$option_id}) ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('please input [_1] text.', $field->{'options'}[$option_id-1]->{'label'}));
              }
            }
          }
        }elsif( $field->{'type'} eq 'radio' ){
          my $option_id = 0;
          for (my $i = 0; $i < @{$field->{'options'}}; $i++) {
            if ($field->{'value'} eq $field->{'options'}[$i]->{'value'}) {
              $option_id = $i + 1;
              last;
            }
          }
          if( $option_id > 0 && $field->{'options'}[$option_id-1]->{'use_other'} ){
            if( !&AFormEngineCGI::Common::must_check($field->{'hash_other_texts'}{$option_id}) ){
              push(@{$error_msgs{$parts_id}}, $plugin->translate('please input [_1] text.', $field->{'options'}[$option_id-1]->{'label'}));
            }
          }
        }

        # If any value not received, Go next!
        next if( !defined $field->{'label_value'} || $field->{'label_value'} eq "" );

        # E-Mail
        if ( $field->{'type'} eq 'email' ) {
            if( !&AFormEngineCGI::Common::mail_check( $field->{'label_value'} ) ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1]([_2]) format is invalid. ex) foo@example.com (ascii character only)', $field->{'label'}, $field->{'label_value'}));
            }
        }
        # Tel
        if ( $field->{'type'} eq 'tel' ) {
            if( !&AFormEngineCGI::Common::num_check( $field->{'label_value'} ) ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1]([_2]) format is invalid. ex) 03-1234-5678 (numbers and "-" only)', $field->{'label'}, $field->{'label_value'}));
            }
        }
        # URL
        if ( $field->{'type'} eq 'url' ) {
            if( !&AFormEngineCGI::Common::url_check( $field->{'label_value'} ) ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1]([_2]) format is invalid. ex) http://www.example.com/ (ascii character only)', $field->{'label'}, $field->{'label_value'}));
            }
        }
        # Zipcode
        if ( $field->{'type'} eq 'zipcode' ) {
            if( !&AFormEngineCGI::Common::zipcode_check( $field->{'label_value'} ) ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1]([_2]) format is invalid. ex) 123-4567 (numbers and "-" only)', $field->{'label'}, $field->{'label_value'}));
            }
        }
        # password
        if ( $field->{'type'} eq 'password' ) {
            if( !&AFormEngineCGI::Common::password_check( $field->{'value'} ) ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1]([_2]) format is invalid. ex) abc123 (ascii characters only)', $field->{'label'}, $field->{'label_value'}));
            }
        }
        # kana
        if ( $field->{'type'} eq 'kana' ) {
            if (!&AFormEngineCGI::Common::kana_check($field->{'lastname_kana'}) || 
                !&AFormEngineCGI::Common::kana_check($field->{'firstname_kana'}) ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('please input [_1] in katakana', $field->{'label'}));
            }
        }

        # min length
        if ( defined $field->{'min_length'} && $field->{'min_length'} gt 0 ) {
          if( $field->{'type'} eq 'name' ){
            $field->{'lastname'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'lastname'}) < $field->{'min_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] at least [_2] characters.', $field->{'label'} .'('. $plugin->translate('Last name') .')', $field->{'min_length'}) );
            }
            $field->{'firstname'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'firstname'}) < $field->{'min_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] at least [_2] characters.', $field->{'label'} .'('. $plugin->translate('First name') .')', $field->{'min_length'}) );
            }
          }elsif( $field->{'type'} eq 'kana' ){
            $field->{'lastname_kana'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'lastname_kana'}) < $field->{'min_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] at least [_2] characters.', $field->{'label'} .'('. $plugin->translate('Last name kana') .')', $field->{'min_length'}) );
            }
            $field->{'firstname_kana'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'firstname_kana'}) < $field->{'min_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] at least [_2] characters.', $field->{'label'} .'('. $plugin->translate('First name kana') .')', $field->{'min_length'}) );
            }
          }else{
            $field->{'label_value'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'label_value'}) < $field->{'min_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] at least [_2] characters.', $field->{'label'}, $field->{'min_length'}) );
            }
          }
        }

        # max length
        if ( defined $field->{'max_length'} && $field->{'max_length'} > 0 ) {
          if( $field->{'type'} eq 'name' ){
            $field->{'lastname'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'lastname'}) > $field->{'max_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] of [_2] characters.', $field->{'label'} .'('. $plugin->translate('Last name') .')', $field->{'max_length'}) );
            }
            $field->{'firstname'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'firstname'}) > $field->{'max_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] of [_2] characters.', $field->{'label'} .'('. $plugin->translate('First name') .')', $field->{'max_length'}) );
            }
          }elsif( $field->{'type'} eq 'kana' ){
            $field->{'lastname_kana'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'lastname_kana'}) > $field->{'max_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] of [_2] characters.', $field->{'label'} .'('. $plugin->translate('Last name kana') .')', $field->{'max_length'}) );
            }
            $field->{'firstname_kana'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'firstname_kana'}) > $field->{'max_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] of [_2] characters.', $field->{'label'} .'('. $plugin->translate('First name kana') .')', $field->{'max_length'}) );
            }
          }else{
            $field->{'label_value'} =~ s/\x0D\x0A|\x0D|\x0A//g;
            if( MT::I18N::length_text($field->{'label_value'}) > $field->{'max_length'} ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('Please enter [_1] of [_2] characters.', $field->{'label'}, $field->{'max_length'}) );
            }
          }
        }

        # ascii
        if (defined $field->{'only_ascii'} && $field->{'only_ascii'}) {
            my $error_chars = &AFormEngineCGI::Common::ascii_check( $field->{'value'} );
            if( $error_chars ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('You can not use [_2] to [_1].', $field->{'label'}, $error_chars));
            }
        }

        # require-hyphen
        if (defined $field->{'require_hyphen'} && $field->{'require_hyphen'}) {
            if( $field->{'value'} !~ m/\-/ ) {
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] required hyphen.', $field->{'label'}));
            }
        }

        # upload
        if ( $field->{'type'} eq 'upload' ) {
            if( $field->{'upload_size_numeric'} > 0 ){
                if( $field->{'filesize'} > $field->{'upload_size_numeric'} ){
                    push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : file size over(limit [_2]bytes)', $field->{'label'}, $field->{'upload_size_numeric'}) );
                }
            }
            if( $field->{'upload_type'} ne '' ){
                my @types = split(',', $field->{'upload_type'});
                for( my $i = 0; $i < @types; $i++ ){
                    $types[$i] = '\.' . $types[$i];
                }
                my $match_pattern = '(' . join('|', @types) . ')$';
                if( $field->{'label_value'} !~ m/$match_pattern/i ){
                    push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : file type error(only [_2])', $field->{'label'}, $field->{'upload_type'}) );
                }
            }
            if( &is_bmp_file($field->{'label_value'}) ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : BMP file cannot upload', $field->{'label'}) );
            }
            if( ! &check_image_file($app, $field) ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : this file cannot upload', $field->{'label'}) );
            }
        }

        # calendar
        if( $field->{'type'} eq 'calendar' ){
            my $input_ymd = sprintf("%04d%02d%02d", $field->{'yy'}, $field->{'mm'}, $field->{'dd'});
            if( !&AFormEngineCGI::Common::date_check( $field->{'yy'}, $field->{'mm'}, $field->{'dd'} ) ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1]([_2]) : Invalid date.', $field->{'label'}, $field->{'label_value'}) );
            }
            elsif ($field->{'abs_range_from'} && $field->{'abs_range_from'} ne "") {
                my ($ss,$ii,$hh,$dd,$mm,$yy) = localtime(time + $field->{'abs_range_from'} * 60*60*24);
                $yy += 1900; $mm += 1;
                my $range_from = sprintf("%04d%02d%02d", $yy, $mm, $dd);
                if ($input_ymd lt $range_from) {
                    push(@{$error_msgs{$parts_id}}, $field->{'label'} .' : '. $plugin->translate('Please enter date after [_1].', sprintf("%0d/%0d/%0d", $yy,$mm,$dd)) );
                }
            }
            # check disable dates
            my %disable_dates = %{$field->{'disable_dates'}};
            foreach my $ymd (keys %disable_dates) {
                if ($input_ymd eq $ymd) {
                    push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : Disable date.', $field->{'label'}) );
                }
            }
        }

        # name
        if( $field->{'type'} eq 'name' ){
            if( $field->{'lastname'} =~ m/%/ ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : The character % can not use in [_2].', $field->{'label'}, $plugin->translate('Last name')) );
            }
            if( $field->{'firstname'} =~ m/%/ ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : The character % can not use in [_2].', $field->{'label'}, $plugin->translate('First name')) );
            }
            if( $field->{'firstname'} ne "" && $field->{'lastname'} eq "" ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : Lastname is empty.', $field->{'label'}) );
            }
            if( $field->{'firstname'} eq "" && $field->{'lastname'} ne "" ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : Firstname is empty.', $field->{'label'}) );
            }
        }

        # kana
        if( $field->{'type'} eq 'kana' ){
            if( $field->{'lastname_kana'} =~ m/%/ ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : The character % can not use in [_2].', $field->{'label'}, $plugin->translate('Last name(kana)')) );
            }
            if( $field->{'firstname_kana'} =~ m/%/ ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : The character % can not use in [_2].', $field->{'label'}, $plugin->translate('First name(kana)')) );
            }
            if( $field->{'firstname_kana'} ne "" && $field->{'lastname_kana'} eq "" ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : Lastname(kana) is empty.', $field->{'label'}) );
            }
            if( $field->{'firstname_kana'} eq "" && $field->{'lastname_kana'} ne "" ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : Firstname(kana) is empty.', $field->{'label'}) );
            }
        }

        # payment
        if( $field->{'type'} eq 'payment' ){
            if( !_aform_payment_installed() ){
                push(@{$error_msgs{$parts_id}}, $plugin->translate('[_1] : Cannot use this field', $field->{'label'}));
            } else {
                require AFormPayment::Plugin;
                AFormPayment::Plugin::validate_param($app, $field, \%error_msgs, $fields);
            }
        }
    }

    MT->run_callbacks('aform_after_validate', scalar $app->param('id'), $fields, \%error_msgs, $app);

    return %error_msgs;
}

sub generate_form_preview {
    my $app = shift;
    my $aform = shift;

    my $plugin = MT->component('AForm');
    my $for_business = &is_business();
    my $checked_sn = int($plugin->get_config_value('checked_sn'));
    my $fields = &_get_fields($app, $aform);
    my $pages = &_get_page_info($app, $fields);
    my $count_page = scalar @$pages;
    my %param = (
        id => $aform->id,
        title => $aform->title,
        fields => &_get_fields($app, $aform),
        action_url => &_get_action_url($app),
        logger_url => &_get_logger_url($app),
        charset => uc($app->charset),
        preview => 1,
        aform_is_active => 'published',
        static_uri => $app->static_path,
        aform_lang => $aform->lang,
        hide_demo_warning => (!$for_business || $checked_sn),
        hide_powered_by => ($for_business || $checked_sn),
        aform_pages => MT::Util::to_json($pages),
        aform_page_max => $count_page,
    );

    $plugin = new MT::Plugin::AForm({ id => 'AForm', l10n_class => 'AForm::L10N' });
    MT->set_language($aform->lang);

    my $html = $app->load_tmpl(&_get_tmpl_file_path($app, $aform->id, 'preview_aform_form.tmpl'), \%param);
    my $ctx = $html->context;
    $ctx->stash('aform_preview', 1);
    $html->text($plugin->translate_templatized($html->text));
    return $app->build_page($html, \%param);
}

sub generate_form_view {
    my $app = shift;
    my $aform = shift;
    my $ctx = shift;

    my $blog_id   = $ctx->stash('blog_id');
    my $aform_url = $ctx->stash('entry') ? $ctx->stash('entry')->permalink : "";
    my $entry_id  = $ctx->stash('entry') ? $ctx->stash('entry')->id : "";
    
    MT->run_callbacks('aform_generate_form_view', $app, $aform, $ctx);

    return _generate_form($app, $blog_id, $aform, $aform_url, $entry_id, $ctx);
}

sub _generate_form {
    my $app       = shift;
    my $blog_id   = shift;
    my $aform     = shift;
    my $aform_url = shift;
    my $entry_id = shift;
    my $ctx = shift;

    if( !$aform ){
        return '';
    }
    if( $aform->status != 2 ){
        return '';
    }

    my( $status, $message ) = &check_aform_is_active($aform);

    my $plugin = MT->component('AForm');
    my $for_business = &is_business();
    my $checked_sn = int($plugin->get_config_value('checked_sn'));
    require URI::Split;
    my ($scheme, $auth, $path, $query, $frag) = URI::Split::uri_split($aform_url);
    my $fields = &_get_fields($app, $aform);
    my $pages = &_get_page_info($app, $fields);
    my $count_page = scalar @$pages;

    my $recaptcha_site_key = $plugin->get_config_value('recaptcha_site_key');

    my %param = (
        blog_id => $blog_id,
        id => $aform->id,
        title => $aform->title,
        fields => $fields,
        action_url => &_get_action_url($app),
        logger_url => &_get_logger_url($app),
        checker_url => &_get_checker_url($app),
        upload_script_url => &_get_upload_script_url($app),
        aform_url => $aform_url,
        charset => uc($app->charset),
        preview => 0,
        static_uri => &_get_static_uri($app, $blog_id),
        aform_is_active => $status,
        aform_message => $message,
        require_ajax_check => ( $aform->start_at > 0 || $aform->end_at > 0 || $aform->receive_limit > 0 ),
        hide_demo_warning => (!$for_business || $checked_sn),
        hide_powered_by => ($for_business || $checked_sn),
        check_immediate => $aform->check_immediate,
        aform_path => $path,
        aform_lang => $aform->lang,
        hidden_params => "",
        entry_id => $entry_id,
        is_systmpl => ($app->param('is_systmpl') || 0),
        require_ajaxzip => &_require_ajaxzip($fields),
        is_installed_mtml => &is_installed_mtml,
        is_static => 1,
        enable_recaptcha => $aform->enable_recaptcha,
        recaptcha_site_key => $recaptcha_site_key,
        aform_pages => MT::Util::to_json($pages),
        aform_page_max => $count_page,
        aform_auto_status => $aform->auto_status,
    );

    MT->set_language($aform->lang);
    my $html = $app->load_tmpl(&_get_tmpl_file_path($app, $aform->id, 'aform_form.tmpl'), \%param);
    $html->text($plugin->translate_templatized($html->text));

    MT->run_callbacks('aform_before_build_form_view', $app, $aform, $ctx, $html, \%param);

    unless ($html->context()->stash('blog') && $blog_id) {
        $html->context()->stash('blog', MT::Blog->load($blog_id));
    }
    return $app->build_page($html, \%param);
}

sub generate_confirmation_view {
    my $app = shift;
    my $aform = shift;

    my $blog_id = int($app->param('blog_id'));
    my $entry_id = int($app->param('entry_id'));

    my $authenticity_token = $app->make_magic_token;
    $app->bake_cookie(
        -path => '/',
        -name => 'authenticity_token',
        -value => $authenticity_token,
    );
    MT::AFormToken::regist_token($app, $authenticity_token);

    my $fields = &_inject_param_value($app, &_get_fields($app, $aform), 'html');
    my %param = (
        id => $aform->id,
        title => $app->blog->name,
        aform_title => $aform->title,
        fields => $fields,
        blog_id => $blog_id,
        use_xhr => ($aform->thanks_url eq '') ? 1 : 0,
        blog_top => $app->blog->site_url,
        action_url => &_get_action_url($app),
        logger_url => &_get_logger_url($app),
        aform_url => $app->param('aform_url') || '',
        aform_path => $app->param('aform_path') || '',
        app_version_id => $app->version_id,
        template_set => $app->blog->template_set,
        use_mt_blog_template_set_ver42 => &_use_mt_blog_template_set_ver42($app, $blog_id),
        static_uri => &_get_static_uri($app, $blog_id),
        hidden_params => &_get_hidden_params_for_confirmation($app, $fields),
        authenticity_token => $authenticity_token,
        aform_lang => $aform->lang,
        module_html_head => _get_template_module_name($app, 'HTML Head'),
        module_banner_header => _get_template_module_name($app, 'Banner Header'),
        module_banner_footer => _get_template_module_name($app, 'Banner Footer'),
        module_header => _get_template_module_name($app, 'Header'),
        module_footer => _get_template_module_name($app, 'Footer'),
        entry_id => $entry_id,
        use_mt_blog_template_set_sp => &_use_mt_blog_template_set_sp($app, $blog_id),
        module_html_head_mobile => _get_template_module_name($app, 'HTML Head - Mobile'),
        module_menu => _get_template_module_name($app, 'Menu'),
        module_menu_mobile => _get_template_module_name($app, 'Menu - Mobile'),
        module_js_footer_mobile => _get_template_module_name($app, 'JavaScript Footer - Mobile'),
        is_installed_mtml => &is_installed_mtml,
        is_smartphone => &is_smartphone($app),
    );

    my $plugin = MT->component('AForm');
    my $tmpl = $app->load_tmpl(&_get_tmpl_file_path($app, scalar $app->param('id'), 'aform_confirm.tmpl'), \%param);
    $tmpl->text($plugin->translate_templatized($tmpl->text));
    $tmpl->context->stash('blog_id', $blog_id);

    MT->run_callbacks('aform_before_build_confirmation_view', $app, $aform, $tmpl, \%param);

    return $app->build_page($tmpl, \%param);
}

sub _get_hidden_params_for_confirmation {
    my $app = shift;
    my $fields = shift;

    my $buf = '';
    foreach my $field ( @$fields ){
        if( $field->{'type'} eq 'checkbox' ){
            my %hash_values = %{$field->{'hash_values'}};
            foreach my $key (keys %hash_values) {
                $buf .= sprintf('<input type="hidden" name="aform-field-%s-%s" value="%s" />'."\n", $field->{'id'}, $key, $hash_values{$key});
            }
            my %hash_other_texts = %{$field->{'hash_other_texts'}};
            foreach my $key (keys %hash_other_texts) {
                $buf .= sprintf('<input type="hidden" name="aform-field-%s-%s-text" value="%s" />'."\n", $field->{'id'}, $key, $hash_other_texts{$key});
            }
        }
        elsif( $field->{'type'} eq 'upload' ){
            $buf .= sprintf('<input type="hidden" name="aform-field-%s" value="%s" />'."\n", $field->{'id'}, $field->{'value'});
            $buf .= sprintf('<input type="hidden" name="aform-upload-name-%s" value="%s" />'."\n", $field->{'id'}, $field->{'label_value'});
        }
        elsif( $field->{'type'} eq 'calendar' ){
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-yy" value="%s" />'."\n", $field->{'id'}, $field->{'yy'});
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-mm" value="%s" />'."\n", $field->{'id'}, $field->{'mm'});
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-dd" value="%s" />'."\n", $field->{'id'}, $field->{'dd'});
        }
        elsif( $field->{'type'} eq 'reserve' ){
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-date" value="%s" />'."\n", $field->{'id'}, $field->{'date'});
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-plan-id" value="%s" />'."\n", $field->{'id'}, $field->{'plan_id'});
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-option-value-id" value="%s" />'."\n", $field->{'id'}, $field->{'option_value_id'});
        }
        elsif( $field->{'type'} eq 'privacy' ){
            my %hash_values = %{$field->{'hash_values'}};
            foreach my $key (keys %hash_values) {
                $buf .= sprintf('<input type="hidden" name="aform-field-%s-%s" value="%s" />'."\n", $field->{'id'}, $key, $hash_values{$key});
            }
        }
        elsif( $field->{'type'} eq 'name' ){
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-lastname" value="%s" />'."\n", $field->{'id'}, $field->{'lastname'});
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-firstname" value="%s" />'."\n", $field->{'id'}, $field->{'firstname'});
        }
        elsif( $field->{'type'} eq 'kana' ){
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-lastname-kana" value="%s" />'."\n", $field->{'id'}, $field->{'lastname_kana'});
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-firstname-kana" value="%s" />'."\n", $field->{'id'}, $field->{'firstname_kana'});
        }
        elsif( $field->{'type'} eq 'payment' && _aform_payment_installed()) {
            require AFormPayment::Plugin;
            $buf .= AFormPayment::Plugin::get_hidden_params_for_confirmation($app, $field);
        }
        else{
            $buf .= sprintf('<input type="hidden" name="aform-field-%s" value="%s" />'."\n", $field->{'id'}, $field->{'value'});
            if( defined $field->{'hash_other_texts'} ){
                my %hash_other_texts = %{$field->{'hash_other_texts'}};
                foreach my $key (keys %hash_other_texts) {
                    $buf .= sprintf('<input type="hidden" name="aform-field-%s-%s-text" value="%s" />'."\n", $field->{'id'}, $key, $hash_other_texts{$key});
                }
            }
        }
        if ($field->{'require_twice'}) {
            $buf .= sprintf('<input type="hidden" name="aform-field-%s-confirm" value="%s" />'."\n", $field->{'id'}, $field->{'confirm_value'});
        }
    }
    return $buf;
}

sub back_form {
    my $app = shift;
    my $aform = shift;

    return generate_error_view($app, undef, $aform);
}

sub generate_finish_view {
    my $app = shift;
    my $aform = shift;
    my $received_id = shift;

    my $blog_id = int($app->param('blog_id'));
    my $entry_id = int($app->param('entry_id'));

    my $fields = &_inject_param_value($app, &_get_fields($app, $aform), 'html');
    my %param = (
        title => $app->blog->name,
        aform_title => $aform->title,
        blog_id => $blog_id,
        blog_top => $app->blog->site_url,
        app_version_id => $app->version_id,
        template_set => $app->blog->template_set,
        use_mt_blog_template_set_ver42 => &_use_mt_blog_template_set_ver42($app, $blog_id),
        static_uri => &_get_static_uri($app, $blog_id),
        received_id => $received_id,
        aform_lang => $aform->lang,
        aform_path => $app->param('aform_path') || '',
        id => $aform->id,
        fields => $fields,
        module_html_head => _get_template_module_name($app, 'HTML Head'),
        module_banner_header => _get_template_module_name($app, 'Banner Header'),
        module_banner_footer => _get_template_module_name($app, 'Banner Footer'),
        module_header => _get_template_module_name($app, 'Header'),
        module_footer => _get_template_module_name($app, 'Footer'),
        entry_id => $entry_id,
        use_mt_blog_template_set_sp => &_use_mt_blog_template_set_sp($app, $blog_id),
        module_html_head_mobile => _get_template_module_name($app, 'HTML Head - Mobile'),
        module_menu => _get_template_module_name($app, 'Menu'),
        module_menu_mobile => _get_template_module_name($app, 'Menu - Mobile'),
        module_js_footer_mobile => _get_template_module_name($app, 'JavaScript Footer - Mobile'),
        is_installed_mtml => &is_installed_mtml,
        is_smartphone => &is_smartphone($app),
        aform_thanks_message => ($app->param('amember_edit_mode') ? $aform->amember_edit_form_thanks_message : $aform->thanks_message),
    );

    my $plugin = MT->component('AForm');
    my $tmpl = $app->load_tmpl(&_get_tmpl_file_path($app, scalar $app->param('id'), 'aform_finish.tmpl'), \%param);
    $tmpl->text($plugin->translate_templatized($tmpl->text));
    $tmpl->context->stash('blog_id', $blog_id);

    MT->run_callbacks('aform_before_build_finish_view', $app, $aform, $tmpl, \%param);

    return $app->build_page($tmpl, \%param);
}

sub generate_error_view {
    my $app = shift;
    my $error_msgs = shift;
    my $aform = shift;

    my $blog_id = int($app->param('blog_id'));
    my $aform_url = $app->param('aform_url');
    my $entry_id = int($app->param('entry_id'));

    my $aform_html = '';
    if( $aform ){
        $app->param('is_systmpl', 1);
        $aform_html = _generate_form($app, $blog_id, $aform, $aform_url, $entry_id);
    }

    my %msgs = %$error_msgs;
    my @errors;
    if ($aform) {
        my $fields = &_inject_param_value($app, &_get_fields($app, $aform), 'html');
        foreach my $field (@$fields) {
            my $error = delete $msgs{$field->{parts_id}};
            if ($error) {
                push @errors, @$error;
            }
        }
    }
    foreach my $key (keys %msgs) {
        push @errors, $msgs{$key};
    }

    my %param = (
        id => ($aform ? $aform->id : ''),
        title => $app->blog->name,
        blog_id => $blog_id,
        errors => \@errors,
        error_msgs => $error_msgs,
        app_version_id => $app->version_id,
        template_set => $app->blog->template_set,
        use_mt_blog_template_set_ver42 => &_use_mt_blog_template_set_ver42($app, $blog_id),
        static_uri => &_get_static_uri($app, $blog_id),
        aform_html => $aform_html,
        aform_lang => ($aform ? $aform->lang : ''),
        aform_path => $app->param('aform_path') || '',
        aform_title => ($aform ? $aform->title : ''),
        module_html_head => _get_template_module_name($app, 'HTML Head'),
        module_banner_header => _get_template_module_name($app, 'Banner Header'),
        module_banner_footer => _get_template_module_name($app, 'Banner Footer'),
        module_header => _get_template_module_name($app, 'Header'),
        module_footer => _get_template_module_name($app, 'Footer'),
        hidden_params => "",
        entry_id => $entry_id,
        use_mt_blog_template_set_sp => &_use_mt_blog_template_set_sp($app, $blog_id),
        module_html_head_mobile => _get_template_module_name($app, 'HTML Head - Mobile'),
        module_menu => _get_template_module_name($app, 'Menu'),
        module_menu_mobile => _get_template_module_name($app, 'Menu - Mobile'),
        module_js_footer_mobile => _get_template_module_name($app, 'JavaScript Footer - Mobile'),
        is_installed_mtml => &is_installed_mtml,
        is_smartphone => &is_smartphone($app),
    );

    my $plugin = MT->component('AForm');
    my $tmpl = $plugin->load_tmpl(&_get_tmpl_file_path($app, scalar $app->param('id'), 'aform_error.tmpl'), \%param);
    $tmpl->text($plugin->translate_templatized($tmpl->text));
    $tmpl->context->stash('blog_id', $blog_id);

    MT->run_callbacks('aform_before_build_error_view', $app, $aform, $tmpl, \%param);

    return $app->build_page($tmpl, \%param);
}

sub _get_fields {
    my $app = shift;
    my $aform = shift;
    my $parts_id = shift;

    my %conditions = ('aform_id' => $aform->id());
    if( $parts_id ){
        $conditions{'parts_id'} = $parts_id;
    }
    my @aform_fields = MT::AFormField->load(\%conditions, { sort => 'sort_order' });

    my $current_page = 1;
    my @fields;
    for my $aform_field (@aform_fields) {
        my $param = {
            id => $aform_field->id,
            aform_id => $aform_field->aform_id,
            type => $aform_field->type,
            label => $aform_field->label,
            is_necessary =>  $aform_field->is_necessary,
            options => $aform_field->options,
            use_default => $aform_field->use_default,
            default_label => $aform_field->default_label,
            privacy_link => $aform_field->privacy_link,
            is_replyed => $aform_field->is_replyed,
            only_ascii => $aform_field->only_ascii,
            allow_ascii_chars => $aform_field->allow_ascii_chars,
            input_example => $aform_field->input_example,
            min_length => $aform_field->min_length,
            max_length => $aform_field->max_length,
            upload_type => $aform_field->upload_type,
            upload_size => $aform_field->upload_size,
            upload_size_numeric => $aform_field->upload_size_numeric,
            parameter_name => $aform_field->parameter_name,
            show_parameter => $aform_field->show_parameter,
            range_from => $aform_field->range_from,
            range_to => $aform_field->range_to,
            abs_range_from => $aform_field->abs_range_from,
            default_value => $aform_field->default_value,
            parts_id => $aform_field->parts_id,
            require_twice => $aform_field->require_twice,
            use_ajaxzip => $aform_field->use_ajaxzip,
            ajaxzip_prefecture_parts_id => $aform_field->ajaxzip_prefecture_parts_id,
            ajaxzip_city_parts_id => $aform_field->ajaxzip_city_parts_id,
            ajaxzip_area_parts_id => $aform_field->ajaxzip_area_parts_id,
            ajaxzip_street_parts_id => $aform_field->ajaxzip_street_parts_id,
            use_linked => $aform_field->use_linked,
            disable_dates => $aform_field->disable_dates,
            value => $aform_field->default_text,
            options_horizontally => $aform_field->options_horizontally,
            relations => $aform_field->relations,
            require_hyphen => $aform_field->require_hyphen,
            next_text => $aform_field->next_text,
        };
        if ($aform_field->type eq 'pagebreak') {
            $param->{current_page} = $current_page;
            $param->{next_page} = $current_page + 1;
            $current_page++;
        }
        push(@fields, $param);
    }

    return \@fields;
}


sub _get_script_url_dir {
    my $app = shift;

    my $plugin = MT->component('AForm');
    my $script_url_dir = _add_slash_if_not_exist($plugin->get_config_value('script_url_dir'));
    if( ! &AFormEngineCGI::Common::url_check( $script_url_dir ) ){
        $script_url_dir = $app->mt_path . 'plugins/AForm/';
        $script_url_dir =~ s#(https?://[^/:]+(:\d+)?)##;
    }
    return $script_url_dir;
}


sub _get_action_url {
    my $app = shift;

    return &_get_script_url_dir($app) . 'aform_engine.cgi';
}

sub _get_logger_url {
    my $app = shift;

    return &_get_script_url_dir($app) . 'aform_logger.cgi';
}

sub _get_checker_url {
    my $app = shift;

    return &_get_script_url_dir($app) . 'aform_checker.cgi';
}

sub _get_upload_script_url {
    my $app = shift;

    return &_get_script_url_dir($app) . 'aform_uploader.cgi';
}

sub _get_upload_dir {
    my $app = shift;

    my $plugin = MT->component('AForm');
    my $upload_dir = $plugin->get_config_value('upload_dir');
    if( !$upload_dir ){
      $upload_dir = AForm::CMS::get_aform_dir() . '/data/';
    }

    return _add_slash_if_not_exist($upload_dir);
}

sub _add_slash_if_not_exist {
  my $str = shift;
  if( $str !~ m#\/$# ){
    $str .= '/';
  }
  return $str;
}

sub _get_upload_tmp_dir {
    my $app = shift;

    return &_get_upload_dir($app) . '__tmp/';
}

sub _get_static_uri {
    my $app = shift;
    my $blog_id = shift;

    my $static_uri = $app->static_path;
    $static_uri =~ s#(https?://[^/:]+(:\d+)?)##;
    return $static_uri;
}

sub _inject_param_value {
    my $app = shift;
    my $fields = shift;
    my $mode = shift;
    my $action = shift;
    my $ignore_relation = shift;

    require 'convert_dependence_char.pl';

    for my $field (@$fields) {
        if (  $field->{'type'} eq 'checkbox' || $field->{'type'} eq 'privacy' ) {
            my $options = $field->{'options'};
            if ( ref($options) eq 'ARRAY' ) {
                my @values;
                my %hash_values;
                my %hash_other_texts;
                for ( my $i=0; $i<@$options; $i++ ) {
                    my $value = convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}, $i+1)));
                    $value = convert_dependence_char($value);
                    if( $value ne '' && $value =~ /\d+/ ){
                      push(@values, $value);
                      $hash_values{$i+1} = $value;
                   }
                   if( @$options[$i]->{'use_other'} ){
                     $hash_other_texts{$i+1} = convert_dependence_char(convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}, $i+1).'-text')));
                   }
                }
                $field->{'values'} = \@values;
                $field->{'hash_values'} = \%hash_values;
                $field->{'label_value'} = join("\n", map { $field->{'options'}->[$_-1]->{'label'} . ($field->{'options'}->[$_-1]->{use_other} ? sprintf('(%s)', convert_dependence_char(convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}, $_) . '-text')))) : '') } @values);
                $field->{'hash_other_texts'} = \%hash_other_texts;
            } else {
                return $app->error(
                $app->translate( "Checkbox field always require array data structure. Illegal data structure is found." ) );
            }
        } elsif( $field->{'type'} eq 'upload' ){
            my $upload_id = convert_crlf(scalar $app->param(&_get_field_key($field->{'id'})));
            if( $upload_id ){
              $field->{'value'} = $upload_id;
              $field->{'label_value'} = convert_crlf(scalar $app->param('aform-upload-name-' . $field->{'id'}));
              if( !Encode::is_utf8($field->{'label_value'}) ){
                $field->{'label_value'} = Encode::decode( $app->charset, $field->{'label_value'} );
              }
              my @wk_path = split(/\\/, $field->{'label_value'});
              $field->{'label_value'} = pop @wk_path;
              $field->{'filesize'} = ( -s &_get_upload_tmp_dir($app) . $upload_id );
              $field->{'filesize_text'} = &_get_filesize_text( -s &_get_upload_tmp_dir($app) . $upload_id );
            }
        } elsif( $field->{'type'} eq 'calendar' ){
            my $yy = convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-yy'));
            my $mm = convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-mm'));
            my $dd = convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-dd'));
            my $value = ((!$yy && !$mm && !$dd) ? '' : sprintf("%04d/%02d/%02d", $yy, $mm, $dd));
            $field->{'values'} = $value;
            $field->{'label_value'} = $value;
            $field->{'yy'} = $yy;
            $field->{'mm'} = $mm;
            $field->{'dd'} = $dd;
        } elsif( $field->{'type'} eq 'name' ){
            my $firstname = convert_dependence_char(convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-firstname')));
            my $lastname = convert_dependence_char(convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-lastname')));
            if ($firstname ne "" || $lastname ne "") {
                $field->{'value'} = $lastname ." ". $firstname;
            }else{
                $field->{'value'} = "";
            }
            $field->{'label_value'} = $field->{'value'};
            $field->{'firstname'} = $firstname;
            $field->{'lastname'} = $lastname;
        } elsif( $field->{'type'} eq 'kana' ){
            my $firstname_kana = convert_dependence_char(convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-firstname-kana')));
            my $lastname_kana = convert_dependence_char(convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-lastname-kana')));
            if ($firstname_kana ne "" || $lastname_kana ne "") {
                $field->{'value'} = $lastname_kana ." ". $firstname_kana;
            }else{
                $field->{'value'} = "";
            }
            $field->{'label_value'} = $field->{'value'};
            $field->{'firstname_kana'} = $firstname_kana;
            $field->{'lastname_kana'} = $lastname_kana;
        } elsif( $field->{'type'} eq 'reserve' ){
            my $reserve_date = convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}).'-date'));
            my $plan_id = int($app->param(&_get_field_key($field->{'id'}).'-plan-id'));
            my $option_value_id = int($app->param(&_get_field_key($field->{'id'}).'-option-value-id'));
            my $value = '';
            if( $reserve_date && $plan_id ){
                my $plan = MT::AFormReservePlan->load($plan_id);
                my $option_value = MT::AFormReserveOptionValue->load($option_value_id);
                if( $option_value ){
                    $value = sprintf("%s %s %s", $reserve_date, $plan->name, $option_value->value);
                }else{
                    $value = sprintf("%s %s", $reserve_date, $plan->name);
                }
            }
            $field->{'values'} = $value;
            $field->{'label_value'} = $value;
            $field->{'date'} = $reserve_date;
            $field->{'plan_id'} = $plan_id;
            $field->{'option_value_id'} = $option_value_id;
        } elsif( $field->{'type'} eq 'payment' && _aform_payment_installed()) {
            require AFormPayment::Plugin;
            AFormPayment::Plugin::inject_param_value($app, $field, $action);
        } else {
            my $value = $app->param(&_get_field_key($field->{'id'}));
            $value = '' unless defined $value;
            if ($field->{'type'} ne 'textarea') {
                $value = convert_crlf($value);
            }
            $value = convert_dependence_char($value);
            if ( $field->{'type'} eq 'radio' || $field->{'type'} eq 'select' || $field->{'type'} eq 'prefecture' ) {
                if( $value ne '' && $value =~ /\d+/ ){
                    $field->{'value'} = $value;
                    my $options = $field->{'options'};
                    if ( ref($options) eq 'ARRAY' ) {
                        foreach my $option (@$options) {
                            if( $option->{'value'} eq $value ){
                                $field->{'label_value'} = $option->{'label'};
                                $field->{'selected_label'} = $option->{'label'};
                                if ($option->{'use_mail_setting'}) {
                                  $field->{'linked_mail_from'} = $option->{'mail_from'};
                                  $field->{'linked_mail_to'} = $option->{'mail_to'};
                                  $field->{'linked_mail_cc'} = $option->{'mail_cc'};
                                  $field->{'linked_mail_bcc'} = $option->{'mail_bcc'};
                                }
                                if( $option->{'use_other'} ){
                                  my $other_text = convert_dependence_char(convert_crlf(scalar $app->param(&_get_field_key($field->{'id'}, $option->{'index'}).'-text')));
                                  $field->{'hash_other_texts'}{$option->{'index'}} = $other_text;
                                  $field->{'label_value'} .= sprintf('(%s)', $other_text);
                                }
                                last;
                            }
                        }
                    } else {
                        return $app->error(
                        $app->translate( "Radio or Select field always require array data structure. Illegal data structure is found." ) );
                    }
                }
            } elsif( $field->{'type'} eq 'password' ) {
                $field->{'value'} = $value;
                $field->{'label_value'} = "*" x length($value);
            } else {
                $field->{'value'} = $value;
                $field->{'label_value'} = $value;
            }
        }
        if( $field->{'require_twice'} ){
            $field->{'confirm_value'} = convert_crlf(scalar $app->param(&_get_field_key($field->{'id'} . '-confirm')));
        }
    }

    # remove pagebreak
    @$fields = grep { $_->{'type'} ne 'pagebreak' } @$fields;

    # fix payment parts price
    foreach my $field (@$fields) {
        if($field->{"type"} eq 'payment' && _aform_payment_installed()) {
            require AFormPayment::Plugin;
            AFormPayment::Plugin::fix_price($app, $field, $fields);
        }
    }

    # fix by relations
    if (!$ignore_relation) {
        foreach my $field (@$fields) {
            $field->{'available'} = &_field_is_available($field, $fields);
        }
        @$fields = grep { $_->{'available'} } @$fields;
    }

    # convert html
    if( defined $mode && $mode eq 'html' ){
      foreach my $field (@$fields) {
        if (MT::AFormData::is_aform_data_field_type($field->{'type'})) {
           foreach my $key (keys %$field) {
               $field->{$key} = _encode_html($field->{$key});
           }
           $field->{'label_value'} = &_crlf2br($field->{'label_value'});
        }
      }
    }
    return $fields;
}

sub _field_is_available {
    my ($field, $fields) = @_;

    if (ref $field->{'relations'} eq "ARRAY") {
        foreach my $relation (@{$field->{'relations'}}) {
            if ($relation->{"parts_id"} ne "") {
                my @target_fields = grep {$_->{"parts_id"} eq $relation->{"parts_id"}} @$fields;
                my $target_field = shift @target_fields;
                if ($target_field) {
                    my $value = defined $target_field->{'selected_label'} ? $target_field->{'selected_label'} : $target_field->{'label_value'};
                    if (($relation->{"cond"} eq "eq" && $relation->{"value"} eq $value) ||
                        ($relation->{"cond"} eq "ne" && $relation->{"value"} ne $value) ||
                        ($relation->{"cond"} eq "ge" && $relation->{"value"} ge $value) ||
                        ($relation->{"cond"} eq "gt" && $relation->{"value"} gt $value) ||
                        ($relation->{"cond"} eq "le" && $relation->{"value"} le $value) ||
                        ($relation->{"cond"} eq "lt" && $relation->{"value"} lt $value)) {
                        ;	# nothing to do
                    } else {
                        return 0;
                    }
                }
            }
        }
    }
    return 1;
}

sub _encode_html {
    my $value = shift;

    if (ref $value eq 'HASH') {
        foreach my $key (keys %$value) {
            $$value{$key} = &_encode_html($$value{$key});
        }
    }else{
        $value = MT::Util::encode_html($value);
    }
    return $value;
}

sub _get_field_key {
    my $id = shift;
    my $index = shift;
    $index = '' unless defined $index;
    return $index ne '' ? 'aform-field-' . $id . '-' . $index : 'aform-field-' . $id;
}

sub _crlf2br {
    my $str = shift;
    $str = '' unless defined $str;
    $str =~ s/\x0D\x0A/<br\/>/g;
    $str =~ s/\x0D/<br\/>/g;
    $str =~ s/\x0A/<br\/>/g;
    return $str;
}

sub _get_csv_record {
	my ($data_id, $fields, $aform) = @_;
        my $datetime = &AFormEngineCGI::Common::get_date(); 

	my $spliter = ",";
	my $data = qq("$data_id");
	$data .= qq($spliter"$datetime");
	foreach my $field ( @$fields ){
        if (MT::AFormData::is_aform_data_field_type($field->{'type'})) {
            my $csv_value = $field->{'label_value'} || '';

            MT->run_callbacks('aform_before_csv_value', $aform, $field, \$csv_value);

            $csv_value =~ s/"/""/g;
            $data .= qq($spliter"$csv_value");
        }
	}

	return $data;
}

sub check_double_submit
{
	my $app = shift;
	my $aform = shift;

	my ($data, $cmp_date, $compare, $double_submit_flag);

	my $fields = &_inject_param_value($app, &_get_fields($app, $aform), '');
	$data = &_get_csv_record($aform->data_id_offset + $aform->data_id, $fields, $aform);
	$data =~ s/.*?\",(.*)/$1/; # remove first column
	$data =~ s/.*?\",(.*)/$1/; # remove 2nd column

	# get last post data
	my $last_data = MT::AFormData->load( 
		{ aform_id => $aform->id }, 
		{ sort_order => 'created_on', direction => 'descend', limit => 1 } );
	if( !$last_data ){
		return 0;
	}

	$compare = $last_data->values;
	$compare =~ s/.*?\",(.*)/$1/; # remove first column
	$compare =~ /\"(.*?)\",(.*)/; # divine datetime and datas
	$cmp_date = $1;
	$compare  = $2;

	my $DOUBLE_SUBMIT_TIME_RANGE = 30;	# sec
	if ($data eq $compare
	and _datetime2timelocal($cmp_date)+$DOUBLE_SUBMIT_TIME_RANGE - time() > 0) {
		return 1;
	}

	return 0;
}

sub _datetime2timelocal {
	my ($date) = @_;
	
	$date =~ /^(\d+)\/(\d+)\/(\d+) (\d+):(\d+):(\d+)$/;
	my ($year) = $1;
	my ($mon)  = $2;
	my ($day)  = $3;
	my ($hour) = $4;
	my ($min)  = $5;
	my ($sec)  = $6;
	
	return timelocal($sec, $min, $hour, $day, $mon-1, $year);
}

sub _get_customer_mail {
	my( $fields ) = @_;

        my @customer_mails;
	foreach my $field ( @$fields ){
		if( $field->{'type'} eq 'email' && $field->{'is_replyed'} && &AFormEngineCGI::Common::mail_check($field->{'value'}) ){
			push( @customer_mails, $field->{'value'} );
		}
	}
	return( \@customer_mails );
}

sub _find_first_customer_mail {
	my( $fields ) = @_;

    my @customer_mails;
    foreach my $field ( @$fields ){
        if( $field->{'type'} eq 'email' && &AFormEngineCGI::Common::mail_check($field->{'value'}) ){
            return $field->{'value'};
        }
    }
    return undef;
}

sub _set_fields_upload_path {
    my $app = shift;
    my $aform_id = shift;
    my $aform_data_id = shift;
    my $fields = shift;

    # set upload path
    for (my $i = 0; $i < @$fields; $i++) {
        if ($$fields[$i]->{'type'} eq 'upload') {
            my $aform_file = MT::AFormFile->load({aform_id => $aform_id, field_id => $$fields[$i]->{'id'}, aform_data_id => $aform_data_id});
            if ($aform_file) {
                $$fields[$i]->{'upload_path'} = $aform_file->get_path;
            }
        }
    }
    return $fields;
}

sub send_mail {
	my $app = shift;
	my $aform = shift;
    my $aform_data_id = shift;

	require 'convert_dependence_char.pl';

    my $aform_data = MT::AFormData->load($aform_data_id);

	my $fields = &_inject_param_value($app, &_get_fields($app, $aform), '');
    $fields = _set_fields_upload_path($app, $aform->id, $aform_data_id, $fields);
    MT->run_callbacks('aform_send_mail_inject_param_value', $aform->id, $fields, $app);
	my $customer_mails = &_get_customer_mail($fields);
    my $first_customer_mail = &_find_first_customer_mail($fields);
    my $linked_mail = &find_linked_mail($app, $fields);

	my %param = (
		datetime => &AFormEngineCGI::Common::get_date(),
		fields => $fields,
		entry_id => $app->param('entry_id') || '',
	);
    if ($aform->ip_ua_to_admin) {
        $param{'display_ip_ua'} = 1;
        $param{'ip'} = $aform_data->ip;
        $param{'ua'} = $aform_data->ua;
    }
    my $plugin = MT->component('AForm');
	my $html = $app->load_tmpl(&_get_tmpl_file_path($app, $aform->id, 'mail_aform_admin.tmpl'), \%param);
    $html->text($plugin->translate_templatized($html->text));
	my $body = $aform->admin_mail_header;
        $body .= "\n" if ($aform->admin_mail_header !~ m/\n$/);
	$body .= $app->build_page($html, \%param) . $aform->admin_mail_footer;
	$body = &_replace_aform_data_id($body, $aform, $fields);
	$body = &convert_dependence_char($body);

    my $mail_from = $first_customer_mail ? $first_customer_mail : $aform->mail_from;
    if ($aform->use_users_mail_from && $first_customer_mail) {
        $mail_from = $first_customer_mail;
    } elsif ($aform->mail_admin_from) {
        $mail_from = $aform->mail_admin_from;
    }
    my $reply_to = (@$customer_mails) ? join(',', @$customer_mails) : $mail_from;
    my $return_path = $mail_from;
    my $mail_to = $aform->mail_to;
    my $mail_cc = $aform->mail_cc;
    my $mail_bcc = $aform->mail_bcc;
    if ($linked_mail) {
        $mail_to = $linked_mail->{'to'} if $linked_mail->{'to'};
        $mail_cc = $linked_mail->{'cc'} if $linked_mail->{'cc'};
        $mail_bcc = $linked_mail->{'bcc'} if $linked_mail->{'bcc'};
    }
	my @mail_to = split(',', $mail_to);
	if( @mail_to == 0 ) {
		return;
	}
	my @mail_cc = split(',', $mail_cc);
	my @mail_bcc = split(',', $mail_bcc);
    my $subject = $aform->mail_admin_subject ? $aform->mail_admin_subject : $aform->mail_subject;

	my %headers = ( 
		'From' => $mail_from,
		'To' => \@mail_to,
		'Subject' => &convert_dependence_char(&_replace_aform_data_id($subject, $aform, $fields)),
		'Cc' => \@mail_cc,
		'Bcc' => \@mail_bcc,
		'Return-Path' => $return_path,
		'Reply-To' => $reply_to,
	);
#	if (MT->version_id ge '5.2') {
#		$headers{'To'} = \@mail_to;
#	} else {
#		$headers{'To'} = $aform->mail_to;
#	}

    utf8::encode($headers{'Subject'});
    utf8::encode($body);

    MT->run_callbacks('aform_before_send_mail', $app, \%headers, \$body, $aform);

    $body =~ s/\r\n/\n/g;
    $body =~ s/\r/\n/g;
    
    if ($body eq "") {
        return;
    }

    my $orig_mail_encoding = MT->config('MailEncoding');
    if ($aform->lang ne 'ja') {
        MT->config('MailEncoding', 'UTF-8');
    }
    SendAttachedMail::send({
        'From'     => $headers{'From'},
        'To'       => $headers{'To'},
        'Cc'       => $headers{'Cc'},
        'Bcc'      => $headers{'Bcc'},
        'Subject'  => $headers{'Subject'},
        'Reply-To' => $headers{'Reply-To'},
        'Return-Path' => $headers{'Return-Path'},
        'Body'     => $body,
        'Attaches' => _get_attaches($app, $aform_data_id, 'admin'),
    });
    if ($aform->lang ne 'ja') {
        MT->config('MailEncoding', $orig_mail_encoding);
    }
}


sub reply_to_customer {
	my $app = shift;
	my $aform = shift;
	my $aform_data_id = shift;

	require 'convert_dependence_char.pl';

    my $aform_data = MT::AFormData->load($aform_data_id);

	my $fields = &_inject_param_value($app, &_get_fields($app, $aform), '');
    $fields = _set_fields_upload_path($app, $aform->id, $aform_data_id, $fields);
	my $customer_mails = &_get_customer_mail($fields);

	if( @$customer_mails == 0 ) {
		return;
	}
    my $linked_mail = &find_linked_mail($app, $fields);

	my %param = (
		datetime => &AFormEngineCGI::Common::get_date(),
		fields => $fields,
		entry_id => $app->param('entry_id') || '',
	);
    if ($aform->ip_ua_to_customer) {
        $param{'display_ip_ua'} = 1;
        $param{'ip'} = $aform_data->ip;
        $param{'ua'} = $aform_data->ua;
    }
    my $plugin = MT->component('AForm');
	my $html = $app->load_tmpl(&_get_tmpl_file_path($app, $aform->id, 'mail_aform_customer.tmpl'), \%param);
    $html->text($plugin->translate_templatized($html->text));
	my $body = $aform->mail_header;
        $body .= "\n" if ($aform->mail_header !~ m/\n$/);
        $body .= $app->build_page($html, \%param) . $aform->mail_footer;
	$body = &_replace_aform_data_id($body, $aform, $fields);
	$body = &convert_dependence_char($body);
    my $attaches = _get_attaches($app, $aform_data_id, 'customer');

    my $orig_mail_encoding = MT->config('MailEncoding');
    if ($aform->lang ne 'ja') {
        MT->config('MailEncoding', 'UTF-8');
    }
        my $mail_from = ($linked_mail && $linked_mail->{'from'}) ? $linked_mail->{'from'} : $aform->mail_from;
	  my %headers = ( 
		'From' => $mail_from,
		'Subject' => &convert_dependence_char(&_replace_aform_data_id($aform->mail_subject, $aform, $fields)),
#		'Bcc' => '',
		'Return-Path' => $mail_from,
		'Reply-To' => $mail_from,
	  );

          MT->run_callbacks('aform_before_reply_to_customer', $app, \%headers, \$body, $aform, $attaches);

    utf8::encode($headers{'Subject'});
    utf8::encode($body);

    $body =~ s/\r\n/\n/g;
    $body =~ s/\r/\n/g;

          if ($body eq "") {
            return;
          }

    foreach my $customer_mail ( @$customer_mails ){
      $headers{'To'} = $customer_mail;
#      MT::Mail->send(\%headers, $body);
      SendAttachedMail::send({
            'From'     => $headers{'From'},
            'To'       => $headers{'To'},
            'Cc'       => $headers{'Cc'},
            'Bcc'      => $headers{'Bcc'},
            'Return-Path' => $headers{'Return-Path'},
            'Reply-To' => $headers{'Reply-To'},
            'Subject'  => $headers{'Subject'},
            'Body'     => $body,
            'Attaches' => $attaches,
      });
    }
    if ($aform->lang ne 'ja') {
        MT->config('MailEncoding', $orig_mail_encoding);
    }
}


sub _replace_aform_data_id {
    my $str = shift;
    my $aform = shift;
    my $fields = shift;

    my ($ss,$ii,$hh,$dd,$mm,$yy) = localtime(time);
    $yy += 1900;
    $mm += 1;
    $yy = sprintf("%04d", $yy);
    $mm = sprintf("%02d", $mm);
    $dd = sprintf("%02d", $dd);
    $hh = sprintf("%02d", $hh);
    $ii = sprintf("%02d", $ii);
    $ss = sprintf("%02d", $ss);
    while( $str =~ m/(__%aform-datetime(\[[^\]]*\])?%__)/gi ){
        my $match = quotemeta $1;
        my $datetime = $2;
        $datetime =~ s/\[|\]//g;
        $datetime = 'YY-MM-DD HH:II:SS' unless $datetime;
        $datetime =~ s/YY/$yy/g;
        $datetime =~ s/MM/$mm/g;
        $datetime =~ s/DD/$dd/g;
        $datetime =~ s/HH/$hh/g;
        $datetime =~ s/II/$ii/g;
        $datetime =~ s/SS/$ss/g;
        $str =~ s/$match/$datetime/gi;
    }

    my $data_id = $aform->data_id_offset + $aform->data_id;
    while( $str =~ m/__%aform-data-id(\d*)%__/gi ){
       my $keta = $1;
       my $format = $keta ? "%0".$keta."d" : "%0d";
       my $val = sprintf($format, $data_id);
       $str =~ s/__%aform-data-id${keta}%__/$val/g;
    }

    while( $str =~ m/__%([^%]*)%__/gi ){
       my $parts_id = $1;
       foreach my $field (@$fields){
           if( $field->{'parts_id'} eq $parts_id ){
               my $val = $field->{'label_value'};
               $str =~ s/__%${parts_id}%__/$val/gi;
           }
       }
    }
    $str =~ s/__%([^%]*)%__//g;

    return $str;
}


sub store {
    my $app = shift;
    my $aform = shift;

    my $fields = &_inject_param_value($app, &_get_fields($app, $aform), '', 'store', 'ignore_relation');
    MT->run_callbacks('aform_before_store', scalar $app->param('id'), $fields, $app);
    if ($app->param('aform_errors')) {
        return undef;
    }

    my $aform_data_id = $aform->increment_data_id();
    if (!$aform_data_id) {
        return undef;
    }

    my $received_id = $aform->data_id_offset + $aform_data_id;
    my $csv_record = &_get_csv_record($received_id, $fields, $aform);

    my $ip_ua = get_ip_and_ua($app);

    my $aform_data = new MT::AFormData;
    $aform_data->set_values(
        {
            aform_id => int(scalar $app->param('id')),
            values => $csv_record,
            aform_url => scalar $app->param('aform_url'),
            status => $aform->data_status_option_default,
            ip => $ip_ua->{'ip'},
            ua => $ip_ua->{'ua'},
        }
    );
    $aform_data->save() or return undef;

	MT::AFormToken::finish_token($app, scalar $app->param('authenticity_token'));

    &countup_cv($app);

    &_store_upload_files($app, $fields, $aform_data->id);

    # get config values
    my $alert_mail = MT->component('AForm')->get_config_value('alert_mail');
    if( &AFormEngineCGI::Common::mail_check( $alert_mail ) ){
        # data was really saved ?
        if( ! $aform_data->count( { values => $csv_record } ) ){
            &_sendmail_save_data_failed($app, $aform, $fields, $alert_mail);
        }
    }
    MT->run_callbacks('aform_after_store', scalar $app->param('id'), $fields, $app, $aform_data);
    if ($app->param('aform_errors')) {
        $aform_data->status('ERROR');
        $aform_data->comment(join("\n", @{$app->param('aform_errors')}));
        $aform_data->save;
        return undef;
    }
    my %return = (
        received_id   => $received_id,
        aform_data_id => $aform_data->id
    );
    return \%return;
}

sub countup_cv {
    my($app) = @_;

    my $aform_id = int($app->param('id'));
    my $aform_url = $app->param('aform_url');
    my $model = ($app->param('aform_is_mobile') && !$app->param('aform_is_smartphone')) ? 'aform_mobile_access' : 'aform_access';

    my $aform_access = $app->model($model)->load({
        aform_id => $aform_id,
        aform_url => $aform_url,
    });
    if (!$aform_access) {
        $aform_access = $app->model($model)->new;
    }
    $aform_access->set_values({
        aform_id => $aform_id,
        aform_url => $aform_url,
        cv => $aform_access->cv + 1,
    });
    $aform_access->save();
}

sub _store_upload_files {
  my $app = shift;
  my $fields = shift;
  my $data_id = shift;

  my $aform_id = int($app->param('id'));
  my $upload_dir = &_get_upload_dir($app) . sprintf("%03d/", $aform_id);
  my $upload_tmp_dir = &_get_upload_tmp_dir($app);

  require File::Copy;
  require File::Basename;
  foreach my $field ( @$fields ){
    if( $field->{'type'} && $field->{'type'} eq 'upload' && $field->{'label_value'} && $field->{'label_value'} ne '' ){
      my $regex_ext = qw(\.[^\.]+$);
      my $ext = (File::Basename::fileparse($field->{'label_value'}, $regex_ext))[2];
      # store aform_files
      my $aform_file = new MT::AFormFile();
      $aform_file->set_values({
        'aform_id' => $aform_id,
        'field_id' => $field->{'id'},
        'aform_data_id' => $data_id,
        'upload_id' => $field->{'value'},
        'orig_name' => $field->{'label_value'},
        'size' => $field->{'filesize'},
        'size_text' => $field->{'filesize_text'},
        'ext' => $ext,
      });
      $aform_file->save or return $app->error($aform_file->errstr);

      my $filename = &_get_upload_file_path($app, $aform_file);
      if( !-e $upload_dir ){
        mkdir $upload_dir;
      }
      if( ! File::Copy::move($upload_tmp_dir . $field->{'value'}, $filename) ){
          return $app->error('failed to move upload file: '. $filename);
      }
      chmod 0644, $filename;
    }
  }
}

sub _get_upload_file_path {
  my $app = shift;
  my $aform_file = shift;

  return &_get_upload_dir($app) . $aform_file->get_path;
}

sub _sendmail_save_data_failed {
    my $app = shift;
    my $aform = shift;
    my $fields = shift;
    my $alert_mail = shift;

    my $plugin = MT->component('AForm');
    my %param = (
        aform_id => sprintf("%03d", $aform->id),
        datetime => &AFormEngineCGI::Common::get_date(),
        fields => $fields,
        aform_url => $app->param('aform_url'),
    );
    my $tmpl = $app->load_tmpl(&_get_tmpl_file_path($app, $aform->id, 'mail_save_data_failed.tmpl'), \%param);
    $tmpl->text($plugin->translate_templatized($tmpl->text));
    my $mail_body = $app->build_page($tmpl, \%param);

    my %headers = (
        'From'    => $alert_mail,
        'To'      => $alert_mail,
        'Subject' => $plugin->translate('[Important] A-Form The save was failed.') . &AFormEngineCGI::Common::get_date(),
        'Return-Path' => $alert_mail,
        'Reply-To' => $alert_mail,
    );
    MT::Mail->send(\%headers, $mail_body);
}


sub sendmail_unpublished_form_access {
    my $app = shift;
    my $aform = shift;

    # get config values
    my $alert_mail = MT->component('AForm')->get_config_value('alert_mail');
    if( ! &AFormEngineCGI::Common::mail_check( $alert_mail ) ){
        return;
    }

    my @fields;
    my %params = $app->param_hash;
    foreach my $param_key ( sort keys %params ){
        if( $param_key !~ m/^aform-field-(\d+)/ ){
            next;
        }
        my $aform_field = $app->model('aform_field')->load($1);
        my $field = {
            label => $aform_field ? $aform_field->label : $param_key,
            label_value => $app->param($param_key),
        };
        push(@fields, $field);
    }

    my %param = (
        aform_id => sprintf("%03d", int($app->param('id'))),
        datetime => &AFormEngineCGI::Common::get_date(),
        fields => \@fields,
    );
    my $plugin = MT->component('AForm');
    my $tmpl = $app->load_tmpl(&_get_tmpl_file_path($app, $aform->id, 'mail_unpublished_form_access.tmpl'), \%param);
    $tmpl->text($plugin->translate_templatized($tmpl->text));
    my $mail_body = $app->build_page($tmpl, \%param);

    my %headers = (
        'From'    => $alert_mail,
        'To'      => $alert_mail,
        'Subject' => '[A-Form Warning] Unpublished form was accessed.',
        'Return-Path' => $alert_mail,
        'Reply-To' => $alert_mail,
    );
    MT::Mail->send(\%headers, $mail_body);
}

sub _get_tmpl_file_path {
    my $app = shift;
    my $aform_id = shift;
    my $filename = shift;

    my $plugin_tmpl_dir = AForm::CMS::get_aform_dir() . '/tmpl/';
    my $tmpl = sprintf("%s%03d/%s", $plugin_tmpl_dir, $aform_id, $filename);
    if( ! -e $tmpl && $app->blog ){
      # seek themes dir
      my $theme_dir = $plugin_tmpl_dir .'themes/'. $app->blog->theme_id .'/';
      if (-e $theme_dir . $filename) {
        $tmpl = $theme_dir . $filename;
      }
    }
    if( ! -e $tmpl ){
      # use default template if custom template not exists
      $tmpl = $plugin_tmpl_dir . $filename;
    }
    MT->run_callbacks('aform_before_load_tmpl', $app, $aform_id, $filename, \$tmpl);
    require Cwd;
    $tmpl = Cwd::realpath($tmpl);
    return $tmpl;
}

sub _get_template_module_name {
    my $app = shift;
    my $name = shift;

    my $mt_lang = MT->current_language;
    my $blog_lang = $app->blog->language;
    if ($mt_lang ne $blog_lang) {
      MT->set_language($blog_lang);
    }

    my $plugin = MT->component('AForm');
    $name = $plugin->translate($name);

    if ($mt_lang ne $blog_lang) {
      MT->set_language($mt_lang);
    }

    return $name;
}

sub _use_mt_blog_template_set_ver42 {
    my $app = shift;
    my $blog_id = shift;

    my $html_head = _get_template_module_name($app, 'HTML Head');
    my $banner_header = _get_template_module_name($app, 'Banner Header');
    my $banner_footer = _get_template_module_name($app, 'Banner Footer');

    return ( ($app->blog->theme_id eq 'classic_blog' || $app->blog->theme_id eq 'classic_website' || $app->blog->theme_id eq 'pico' || $app->blog->theme_id eq 'rainier' || $app->blog->theme_id eq 'eiger')
          && $app->model('template')->count({name => $html_head, blog_id => $blog_id}) > 0 
          && $app->model('template')->count({name => $banner_header, blog_id => $blog_id}) > 0 
          && $app->model('template')->count({name => $banner_footer, blog_id => $blog_id}) > 0 );
}

sub _use_mt_blog_template_set_sp {
    my $app = shift;
    my $blog_id = shift;

    return ($app->blog->theme_id eq 'smart_blog');
}

sub _get_filesize_text(){
  my $size = shift;

  my $size_text = '';
  if( $size > 1024 * 1024 * 1024 ){
    $size_text = sprintf("%0.1fGbyte", $size / 1024 / 1024 / 1024);
  }elsif( $size > 1024 * 1024 ){
    $size_text = sprintf("%0.1fMbyte", $size / 1024 / 1024);
  }elsif( $size > 1024 ){
    $size_text = sprintf("%0.1fKbyte", $size / 1024);
  }else{
    $size_text = sprintf("%0dbyte", $size);
  }
  return $size_text;
}

sub check_aform_is_active {
  my $aform = shift;

  my($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
  my $now = sprintf("%04d%02d%02d%02d%02d%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec);
  my $received_count = MT::AFormData->count({aform_id => $aform->id});

  $aform->set_values({auto_status => 0});
  my $status = 'closed';
  my $message = '';
  if( $aform->status eq 2 ){
    $status = 'published';
    if( $aform->start_at > 0 || $aform->end_at > 0 || $aform->receive_limit > 0 ){
      if( $aform->start_at > 0 && $aform->start_at > $now ){
        $status = 'before start';
        $message = $aform->msg_before_start;
      }elsif( $aform->end_at > 0 && $aform->end_at < $now ){
        $status = 'after end';
        $message = $aform->msg_after_end;
      }elsif( $aform->receive_limit > 0 && $received_count >= $aform->receive_limit ){
        $status = 'limit over';
        $message = $aform->msg_limit_over;
      }else{
        $status = 'published';
        $aform->set_values({auto_status => 1});
      }
    }else{
      $status = 'published';
      $aform->set_values({auto_status => 1});
    }
  }
  $aform->save;	# update auto_status
  return($status, $message);
}

sub upload_to_tmp_dir {
  my $app = shift;
  my $aform = shift;
  my $q = $app->param;

  my %upload_fields;
  my $fields = &_get_fields($app, $aform);
  foreach my $field ( @$fields ){
    if( $field->{'type'} eq 'upload' ){
      my $field_key = &_get_field_key($field->{'id'});
      my $orig_filename = $app->param($field_key);
      if( $orig_filename eq "" ){
        next;
      }
      my( $fh, $info ) = $app->upload_info($field_key);
      my $temp_filename = $q->tmpFileName($fh);

      &delete_old_tmp_files($app);

      my $tmp_dir = &AFormEngineCGI::FormMail::_get_upload_tmp_dir($app);
      if( ! -d $tmp_dir ){
        mkdir $tmp_dir;
      }
      my( $fh_tmp, $filename ) = File::Temp::tempfile( DIR => $tmp_dir);
      File::Copy::copy($temp_filename, $filename) or die $!;

      $app->param($field_key, basename($filename));
      $app->param('aform-upload-name-' . $field->{'id'}, $orig_filename);
    }
  }
}

sub delete_old_tmp_files {
  my $app = shift;

  my $tmp_dir = &AFormEngineCGI::FormMail::_get_upload_tmp_dir($app);
  if( ! opendir(DIR, $tmp_dir) ){
    return;
  }
  while( my $file = readdir(DIR) ){
    if( $file eq '.' || $file eq '..' ){
      next;
    }
    my $mtime = -M "$tmp_dir$file";
    if( $mtime >= 1 ){
      unlink "$tmp_dir$file";
    }
  }
  closedir(DIR);
}

sub check_serialnumber {
  require AFormEngineCGI::CheckSerialNumber;
  return AFormEngineCGI::CheckSerialNumber::check_serialnumber();
}

sub is_business {
  my $app = MT->instance;

  my $file = AForm::CMS::get_aform_dir() . '/key/aform_nonprofitkey.txt';
  if( -e $file ){
    return 0;
  }else{
    return 1;
  }
}

sub _get_upload_tmp_file {
  my $app = shift;
  my $field = shift;

  return &_get_upload_tmp_dir($app) . $field->{'value'};
}

sub _get_file_ext {
  my $filename = shift;
  
  my $regex_ext = qw([^\.]+$);
  return (File::Basename::fileparse($filename, $regex_ext))[2];
}

sub is_bmp_file {
  my $filename = shift;

  return lc(&_get_file_ext($filename)) eq 'bmp';
}

sub check_image_file {
  my $app = shift;
  my $field = shift;

  my $ext = lc(&_get_file_ext($field->{'label_value'}));
  if( $ext =~ m/^(gif|jpeg|jpg|png)$/ ){
    my $tmp_file = &_get_upload_tmp_file($app, $field);
    return _check_magicbyte($tmp_file, $ext);
  }else{
    return 1;
  }
}

sub _check_magicbyte {
  my $filename = shift;
  my $type = shift;

  my $buf;
  sysopen(FH, $filename, O_RDONLY) or return 0;
  binmode(FH);
  read( FH, $buf, 30 ) or return 0;
  close FH;

  if( $type eq 'gif' ){
    return ($buf =~ m/^GIF8[79]a/ );
  }elsif( $type eq 'jpg' || $type eq 'jpeg' ){
    return ($buf =~ m/^\xFF\xD8/ );
  }elsif( $type eq 'png' ){
    return ($buf =~ m/^\x89PNG\x0D\x0A\x1A\x0A/ );
  }else{
    return 0;
  }
}

sub _aform_reserve_installed {
  my $aform_reserve = MT->component('AFormReserve');
  if( $aform_reserve ){
    return 1;
  }else{
    return 0;
  }
}

sub _aform_payment_installed {
  my $aform_payment = MT->component('AFormPayment');
  if( $aform_payment ){
    return 1;
  }else{
    return 0;
  }
}

sub check_authenticity_token {
  my $app = shift;

  my $posted_token = $app->param('authenticity_token');
  my $cookie_token = $app->cookie_val('authenticity_token');

  return MT::AFormToken::INVALID() if $posted_token eq "";
  return MT::AFormToken::INVALID() if $cookie_token eq "";
  return MT::AFormToken::INVALID() if $posted_token ne $cookie_token;
  return MT::AFormToken::check_token($app, $posted_token);
}

sub _require_ajaxzip {
  my $fields = shift;

  foreach my $field (@$fields) {
    if ($field->{'type'} eq 'zipcode' && $field->{'use_ajaxzip'}) {
      return 1;
    }
  }
  return 0;
}

sub add_aform_errors {
  my ($app, $msg) = @_;

  my @errors = $app->param('aform_errors');
  push @errors, $msg;
  $app->param('aform_errors', \@errors);
}

sub is_installed_mtml {
  return MT->component('DynamicMTML') ? 1 : 0;
}

sub is_smartphone {
    my ($app) = @_;

    if ($ENV{MOD_PERL}) {
        $_ = MT::App->instance->{apache}->subprocess_env('HTTP_USER_AGENT');
    } else {
        $_ = $ENV{HTTP_USER_AGENT};
    }
    return (/iPhone/i || /iPod/i || (/android/i && /mobile/i));
}

sub _get_attaches {
    my $app = shift;
    my $aform_data_id = shift;
    my $to = shift;

    my @attaches;
    my @aform_files = MT::AFormFile->load({aform_data_id => $aform_data_id});
    foreach my $aform_file (@aform_files) {
        my $aform_field = MT::AFormField->load($aform_file->field_id);
        if ($aform_field && $aform_field->type eq 'upload') {
          if (($to eq 'admin' && $aform_field->send_attached_files) || ($to eq 'customer' && $aform_field->send_attached_files_to_customer)) {
            push @attaches, {
                'Path' => _get_upload_file_path($app, $aform_file),
                'Filename' => $aform_file->orig_name,
            };
          }
        }
    }
    return \@attaches;
}

sub find_linked_mail {
    my ($app, $fields) = @_;

    foreach my $field (@$fields) {
        if ($field->{'type'} eq 'select' && $field->{'use_linked'}) {
            return {
				'from' => $field->{'linked_mail_from'},
				'to' => $field->{'linked_mail_to'},
				'cc' => $field->{'linked_mail_cc'},
				'bcc' => $field->{'linked_mail_bcc'},
			};
        }
    }
    return undef;
}

sub get_ip_and_ua {
    my ($app) = @_;

    my $ip = $ENV{'REMOTE_ADDR'};
    my $ua = $ENV{'HTTP_USER_AGENT'};

    return {
        ip => $ip,
        ua => $ua,
    };
}

sub convert_crlf {
    my ($value) = @_;

    $value =~ s/\x0D\x0A|\x0D|\x0A/ / if defined $value;
    return $value;
}

sub _get_page_info {
    my ($app, $fields) = @_;

    my @pages;
    my $current_page = 1;
    my @parts_ids;
    foreach my $field (@$fields) {
        next if ($field->{type} eq 'label' || $field->{type} eq 'note');
        if ($field->{type} eq 'pagebreak') {
            my @my_parts_ids = @parts_ids;
            push @pages, {
                prev => ($current_page > 1) ? {
                        btn => sprintf('aform_button_prev_%0d', $current_page),
                        page => sprintf('aform_page_%0d', $current_page - 1),
                    } : undef,
                next => {
                        btn => sprintf('aform_button_next_%0d', $current_page),
                        page => sprintf('aform_page_%0d', $current_page + 1),
                    },
                parts_ids => \@my_parts_ids,
            };
            $current_page++;
            @parts_ids = ();
        } else {
            push @parts_ids, $field->{parts_id};
        }
    }

    push @pages, {
        prev => ($current_page > 1) ? {
                btn => sprintf('aform_button_prev_%0d', $current_page),
                page => sprintf('aform_page_%0d', $current_page - 1),
            } : undef,
        next => undef,
        parts_id => \@parts_ids,
    };

    return \@pages;
}

1;
