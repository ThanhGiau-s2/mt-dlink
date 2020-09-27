# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::Plugin::AForm;

use strict;
use MT;
use MT::AForm;
use MT::AFormField;
use MT::AFormData;
use MT::AFormInputError;
use MT::AFormAccess;
use MT::AFormCounter;
use MT::AFormEntry;
use MT::AFormFile;
use MT::AFormToken;
use AForm::CMS;

use vars qw( $VERSION $SCHEMA_VERSION $AFORM_TYPE1 $AFORM_TYPE2 );
$VERSION = '4.0.3';
$SCHEMA_VERSION = '1.31044003';
$AFORM_TYPE1 = 'F';
$AFORM_TYPE2 = 'P';

use base qw( MT::Plugin );

###################################### Init Plugin #####################################

my $plugin = new MT::Plugin::AForm({
    id => 'AForm',
    name => 'A-Form',
    author_name => '<MT_TRANS phrase=\'_PLUGIN_AUTHOR\'>',
    author_link => 'http://www.ark-web.jp/',
    version => $VERSION,
    schema_version => $SCHEMA_VERSION,
    description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
    doc_link => 'http://www.ark-web.jp/movabletype/',
    object_classes => [
        'MT::AForm',
        'MT::AFormField',
        'MT::AFormData',
        'MT::AFormInputError',
        'MT::AFormAccess',
        'MT::AFormCounter',
        'MT::AFormEntry',
        'MT::AFormFile',
        'MT::AFormToken',
    ],
    l10n_class => 'AForm::L10N',
    system_config_template => 'system_config.tmpl',
    settings => new MT::PluginSettings([
      [ 'script_url_dir', { Default => '', Scope => 'system' }],
      [ 'alert_mail', { Default => '', Scope => 'system' }],
      [ 'check_when_first_access', { Default => '', Scope => 'system' }],
      [ 'check_interval', { Default => '24h', Scope => 'system' }],
      [ 'alert_min_confirm_pv', { Default => '1', Scope => 'system' }],
      [ 'alert_min_complete_pv', { Default => '1', Scope => 'system' }],
      [ 'last_count_check_date', { Default => '', Scope => 'system' }],
      [ 'upload_dir', { Default => '', Scope => 'system' }],
      [ 'serialnumber', { Default => '', Scope => 'system' }],
      [ 'checked_sn', { Default => '', Scope => 'system' }],
      [ 'for_business', { Default => '', Scope => 'system' }],
      [ 'type1', { Default => $AFORM_TYPE1, Scope => 'system' }],
      [ 'type2', { Default => $AFORM_TYPE2, Scope => 'system' }],
      [ 'recaptcha_site_key', { Default => '', Scope => 'system' }],
      [ 'recaptcha_secret_key', { Default => '', Scope => 'system' }],
    ]),
});
MT->add_plugin($plugin);

sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        'backup_instructions' => {
            'aform'             => { 'skip' => 1 },
            'aform_field'       => { 'skip' => 1 },
            'aform_data'        => { 'skip' => 1 },
            'aform_input_error' => { 'skip' => 1 },
            'aform_access'      => { 'skip' => 1 },
            'aform_counter'     => { 'skip' => 1 },
            'aform_entry'       => { 'skip' => 1 },
            'aform_file'        => { 'skip' => 1 },
            'aform_token'       => { 'skip' => 1 },
        },
        'object_types' => {
            'aform' => 'MT::AForm',
            'aform_field' => 'MT::AFormField',
            'aform_data' => 'MT::AFormData',
            'aform_input_error' => 'MT::AFormInputError',
            'aform_access' => 'MT::AFormAccess',
            'aform_counter' => 'MT::AFormCounter',
            'aform_entry' => 'MT::AFormEntry',
            'aform_file' => 'MT::AFormFile',
            'aform_token' => 'MT::AFormToken',
        },
        'listing_screens' => {
            aform_data => {
                object_label => 'AFormData',
                object_label_plural => 'AFormData',
                object_type      => 'aform_data',
                primary          => 'id',
                default_sort_key => 'id',
                scope_mode       => 'none', # ignore blog_id
                condition        => sub {
                    my $app = MT->app;
                    return 0 if ref($app) ne 'MT::App::CMS';
                    my $blog_id = $app->param('blog_id');
                    my $aform_id = AForm::CMS::init_request_aform_id($app);
                    return 0 unless $aform_id;
                    my $aform = MT::AForm->load($aform_id);
                    return 0 unless $aform;
                    return 0 if ($blog_id && $aform->blog_id && $aform->blog_id ne $blog_id);
                    return AForm::CMS::can_do($app, $aform->blog_id, 'manage_aform_data');
                },
                template => (MT->version_number >= 7 ? undef : ((MT->version_number >= 5.14 ? '' : 'plugins/AForm/') . 'tmpl/cms/list_aform_data.tmpl')),
            },
            aform => {
                object_label => 'A-Form',
                object_label_plural => 'A-Form',
                object_type      => 'aform',
                primary          => 'title',
                scope_mode       => 'none',
                condition        => sub {
                    my $app = MT->app;
                    return 0 if ref($app) ne 'MT::App::CMS';
                    return AForm::CMS::can_list_aform();
                },
            },
        },
        'list_properties' => {
            aform_data => '$AForm::MT::AFormData::list_props',
            aform      => '$AForm::MT::AForm::list_props',
        },
        'system_filters' => {
            aform_data => '$AForm::MT::AFormData::system_filters',
        },
        'list_actions' => {
            aform_data => '$AForm::MT::AFormData::list_actions',
        },
        'applications' => {
            'cms' => {
                content_actions => {
                    aform_data => '$AForm::MT::AFormData::content_actions',
                },
                'methods' => {
                    'manage_aform' => '$AForm::AForm::CMS::manage_aform',
                    'create_aform' => '$AForm::AForm::CMS::_create_aform',
                    'edit_aform' => '$AForm::AForm::CMS::_edit_aform',
                    'save_aform' => '$AForm::AForm::CMS::_save_aform',
                    'delete_aform' => '$AForm::AForm::CMS::_delete_aform',
                    'copy_aform' => '$AForm::AForm::CMS::_copy_aform',
                    'edit_aform_field' => '$AForm::AForm::CMS::_edit_aform_field',
                    'save_aform_field' => '$AForm::AForm::CMS::_save_aform_field',
                    'manage_aform_data' => '$AForm::AForm::CMS::_manage_aform_data',
                    'export_aform_data' => '$AForm::AForm::CMS::_export_aform_data',
                    'clear_aform_data' => '$AForm::AForm::CMS::_clear_aform_data',
                    'list_aform_input_error' => '$AForm::AForm::CMS::_list_aform_input_error',
                    'disp_aform' => '$AForm::AForm::CMS::_disp_aform',
                    'change_aform_status' => '$AForm::AForm::CMS::_change_aform_status',
                    'disp_aform_data' => '$AForm::AForm::CMS::_disp_aform_data',
                    'download_aform_file' => '$AForm::AForm::CMS::_download_aform_file',
                    'update_aform_data_status_all' => '$AForm::AForm::CMS::_update_aform_data_status_all',
                    'update_aform_data_status_and_comment' => '$AForm::AForm::CMS::_update_aform_data_status_and_comment',
                    'rebuild_aform_entry' => '$AForm::AForm::CMS::rebuild_aform_entry',
                    'list_aform_entry' => '$AForm::AForm::CMS::_list_aform_entry',
                    'clear_aform_access' => '$AForm::AForm::CMS::_clear_aform_access',
                    'clear_aform_input_error' => '$AForm::AForm::CMS::_clear_aform_input_error',
                    'export_aform_input_error' => '$AForm::AForm::CMS::_export_aform_input_error',
                    'save_aform_data' => sub{},
                    'save_aform_input_error' => sub{},
                    'save_aform_access' => sub{},
                    'save_aform_counter' => sub{},
                    'save_aform_entry' => sub{},
                    'save_aform_file' => sub{},
                    'delete_aform_field' => sub{},
                    'delete_aform_input_error' => sub{},
                    'delete_aform_access' => sub{},
                    'delete_aform_counter' => sub{},
                    'delete_aform_entry' => sub{},
                    'delete_aform_file' => sub{},
                    'install_aform_js_template' => '$AForm::AForm::CMS::install_aform_js_template',
                    'get_amember_content_fields_json' => '$AForm::AForm::CMS::get_amember_content_fields_json',
                },
                menus => {
                    'system:aform' => {
                        label => 'AForm',
                        order => 10000,
                        mode => 'manage_aform',
                        condition  => sub { AForm::CMS::can_list_aform() },
                    },
                    'aform' => {
                        label => 'AForm',
                        order => 10000,
                        condition  => sub { AForm::CMS::can_list_aform() },
                    },
                    'aform:list' => {
                        label => 'List',
                        mode => 'manage_aform',
                        condition  => sub { AForm::CMS::can_list_aform() },
                        view => [ "blog", 'website', 'system' ],
                        order => 1000,
                    },
                    'aform:aform_js' => {
                        label => 'Install aform_js',
                        order => 10000,
                        mode => 'install_aform_js_template',
                        view => ['system'],
                    },
                },
                enable_object_methods => {
                    aform_data => {
                        delete => 1,
                    },
                },
            },
            aform_engine => {
                handler => 'AFormEngineCGI',
                script => sub { return 'aform_engine.cgi' },
                cgi_path => '$AForm::AForm::CMS::cgi_path',
            },
            aform_logger => {
                handler => 'AFormLoggerCGI',
                script => sub { return 'aform_logger.cgi' },
                cgi_path => '$AForm::AForm::CMS::cgi_path',
            },
            aform_checker => {
                handler => 'AFormCheckerCGI',
                script => sub { return 'aform_checker.cgi' },
                cgi_path => '$AForm::AForm::CMS::cgi_path',
            },
            selenium_test => {
                handler => 'SeleniumTestCGI',
                script => sub { return 'selenium_test.cgi' },
                cgi_path => '$AForm::AForm::CMS::cgi_path',
            },
        },
        tags => {
            modifier => {
                'aform' => \&AForm::CMS::_build_form,
                'hide_aform' => \&AForm::CMS::_hide_aform,
            },
            function => {
                'AFormFieldLabel' => '$AForm::AForm::CMS::hdlr_aform_field_label',
                'AFormFieldValidation' => '$AForm::AForm::CMS::hdlr_aform_field_validation',
                'AFormFieldInputExample' => '$AForm::AForm::CMS::hdlr_aform_field_input_example',
                'AFormFieldError' => '$AForm::AForm::CMS::hdlr_aform_field_error',
                'AFormFieldInput' => '$AForm::AForm::CMS::hdlr_aform_field_input',
                'AFormFieldConfirm' => '$AForm::AForm::CMS::hdlr_aform_field_confirm',
                'AFormFieldConfirmAll' => '$AForm::AForm::CMS::hdlr_aform_field_confirm_all',
                'AFormReceiveRemain' => sub{},
                'AFormFieldRelationScript' => '$AForm::AForm::CMS::hdlr_aform_field_relation_script',
            },
        },
        callbacks => {
            'aform_check_entry_has_aform' => {
                callback => 'MT::Entry::post_save',
                handler => '$AForm::AForm::CMS::check_entry_has_aform',
            },
            'aform_check_page_has_aform' => {
                callback => 'MT::Page::post_save',
                handler => '$AForm::AForm::CMS::check_entry_has_aform',
            },
            'aform_remove_aform_entry' => {
                callback => 'MT::Entry::post_remove',
                handler => '$AForm::AForm::CMS::remove_aform_entry',
            },
            'aform_remove_aform_page' => {
                callback => 'MT::Page::post_remove',
                handler => '$AForm::AForm::CMS::remove_aform_entry',
            },
            'aform_remove_aform_data' => {
                callback => 'MT::AFormData::post_remove',
                handler => '$AForm::AForm::CMS::post_remove_aform_data',
            },
            'aform_remove_aform_file' => {
                callback => 'MT::AFormFile::post_remove',
                handler => '$AForm::AForm::CMS::post_remove_aform_file',
            },
            'cms_pre_load_filtered_list.aform_data' => '$AForm::MT::AFormData::cms_pre_load_filtered_list',
            'cms_pre_load_filtered_list.aform' => '$AForm::MT::AForm::cms_pre_load_filtered_list',
            'list_template_param.aform_data' => '$AForm::MT::AFormData::list_template_param',
            'list_template_param.aform' => '$AForm::MT::AForm::list_template_param',
            'cms_delete_permission_filter.aform_data' => '$AForm::MT::AFormData::cms_delete_permission_filter',
            'cms_post_delete.aform_data' => '$AForm::MT::AFormData::cms_post_delete',
            'MT::ContentData::post_save' => '$AForm::AForm::CMS::post_save_content_data',
            'MT::ContentData::post_remove' => '$AForm::AForm::CMS::post_remove_content_data',
        },
        upgrade_functions => {
            'aform_upgrade_fix_mail_from' => {
                version_limit => 1.2001,
                updater => {
                    type => 'aform',
                    label => 'setting aform mail from',
                    code => sub {
                        my $aform = shift;
                        if( $aform->mail_from eq '' ){
                            $aform->set_values({
                                 mail_from => $aform->mail_to,
                            });
                            $aform->save;
                        }
                    },
                },
            },
            'aform_upgrade_fix_mail_subject' => {
                version_limit => '1.2002',	# AForm-2.0.2
                updater => {
                    type => 'aform',
                    label => 'setting aform mail subject',
                    code => sub {
                        my $aform = shift;
                        if( $aform->mail_admin_subject eq '' ){
                            $aform->set_values({
                                 mail_admin_subject => $aform->mail_subject,
                            });
                            $aform->save;
                        }
                    },
                },
            },
            'aform_upgrade_set_parts_id' => {
                version_limit => '1.31016',	# AForm-3.0.0
                updater => {
                    type => 'aform_field',
                    label => 'setting aform field parts_id',
                    code => sub {
                        my $aform_field = shift;
                        if( $aform_field->parts_id eq '' ){
                            my $parts_id = 'parts-'. $aform_field->id;
                            $aform_field->set_values({
                                 parts_id => $parts_id,
                            });
                            $aform_field->save;
                        }
                    },
                },
            },
            'aform_upgrade_set_aform_access_cv' => {
                version_limit => '1.31016',	# AForm-3.0.0
                updater => {
                    type => 'aform_access',
                    label => 'setting aform_access_cv',
                    code =>  sub {
                        my $aform_access = shift;
                        my $cv = MT::AFormData->count({
                            aform_id => $aform_access->aform_id,
                            aform_url => $aform_access->aform_url,
                        });
                        $aform_access->cv($cv);
                        $aform_access->save;
                    },
                },
            },
            'aform_upgrade_set_permissions' => {
                version_limit => '1.31031',	# AForm-3.5
                updater => {
                    type => 'author',
                    label => 'setting aform permission',
                    code => sub {
                        my $author = shift;

                        # create | load role
                        require MT::Role;
                        my $role_name = $plugin->translate('View AForm');
                        my $role = MT::Role->load({name => $role_name});
                        if (!$role) {
                            $role = MT::Role->new;
                            $role->name($role_name);
                            $role->clear_full_permissions;
                            $role->set_these_permissions(('view_aform'));
                            $role->save or return 0;
                        }

                        if (!$author->is_superuser) {
                            # grant permissions
                            my @blogs = MT::Blog->load();
                            foreach my $blog (@blogs) {
                                my %opts;
                                $opts{blog_id} = $blog->id;
                                $opts{at_least_one} = 1;
                                if ($author->can_do('create_post', %opts)) {
                                    $author->add_role($role, $blog);
                                }
                            }
                        }
                    },
                },
            },
            'aform_upgrade_set_admin_mail_header_footer' => {
                version_limit => '1.31032',	# AForm-3.6
                updater => {
                    type => 'aform',
                    label => 'setting admin_mail_header and footer',
                    code => sub {
                        my $aform = shift;
                        $aform->admin_mail_header($aform->mail_header);
                        $aform->admin_mail_footer($aform->mail_footer);
                        $aform->save or return 0;
                        return 1;
                    },
                },
            },
        },
        permissions => {
            'blog.view_aform' => {
                label => "View AForm",
                group => 'blog_admin',
                order => 10000,
                permitted_action => {
                    list_aform => 1,
                    preview_aform => 1,
                    list_aform_input_error => 1,
                    list_aform_entry => 1,
                },
            },
            'blog.manage_aform' => {
                label => "Create and Edit AForm",
                group => 'blog_admin',
                order => 10010,
                inherit_from     => [
                    'blog.view_aform',
                    'blog.edit_all_posts',
                    'blog.manage_pages',
                    'blog.update_aform_reserve_remaining_quantity',
                ],
                permitted_action => {
                    'create_aform' => 1,
                    'edit_aform'   => 1,
                    'copy_aform'   => 1,
                    'delete_aform' => 1,
                    'edit_aform_field' => 1,
                    'aform_reserve' => 1,
                    'aform_payment' => 1,
                    'list_aform_reserve_plan' => 1,
                    'edit_aform_reserve_plan' => 1,
                    'delete_aform_reserve_plan' => 1,
                    'list_aform_reserve_remaining_quantity' => 1,
                },
            },
            'blog.view_aform_data' => {
                label => "View and Export AForm data",
                group => 'blog_admin',
                order => 10020,
                inherit_from => [
                    'blog.view_aform',
                ],
                permitted_action => {
                    'manage_aform_data' => 1,
                    'disp_aform_data'   => 1,
                    'export_aform_data' => 1,
                    'download_aform_file' => 1,
                },
            },
            'blog.update_aform_data' => {
                label => "Update AForm data",
                group => 'blog_admin',
                order => 10030,
                inherit_from => [
                    'blog.view_aform_data',
                ],
                permitted_action => {
                    'change_aform_data_status' => 1,
                },
            },
            'blog.delete_aform_data' => {
                label => "Delete AForm data",
                group => 'blog_admin',
                order => 10040,
                inherit_from => [
                    'blog.view_aform_data',
                ],
                permitted_action => {
                    'delete_aform_data' => 1,
                },
            },
            'blog.manage_aform_access' => {
                label => "Manage AForm access report",
                group => 'blog_admin',
                order => 10050,
                inherit_from => [
                    'blog.view_aform',
                ],
                permitted_action => {
                    'clear_aform_access' => 1,
                    'export_aform_input_error' => 1,
                    'clear_aform_input_error' => 1,
                },
            },
        },
    });
}

sub instance {$plugin}

sub manual_link {
    return 'http://groups.google.co.jp/group/mt-a-form/web/a-form-top';
}

sub manual_link_edit_field {
    return 'http://www.ark-web.jp/movabletype/a-form/docs/';
}

sub config_template {
  my $plugin = shift;
  my ($param, $scope) = @_;

  require AFormEngineCGI::FormMail;

  my $for_business = AFormEngineCGI::FormMail::is_business();
  $plugin->set_config_value('for_business', $for_business, 'system');
  $$param{'for_business'} = $for_business;

  my $checked_sn = &AFormEngineCGI::FormMail::check_serialnumber();
  $plugin->set_config_value('checked_sn', $checked_sn, 'system');
  $$param{'checked_sn'} = $checked_sn;

  return $plugin->SUPER::config_template($param, $scope);
}

sub save_config {
  my $plugin = shift;
  my( $args, $scope ) = @_;

  $plugin->SUPER::save_config(@_);

  if( $AFORM_TYPE1 ne $plugin->get_config_value('type1') ){
    $plugin->set_config_value('type1', $AFORM_TYPE1, 'system');
  }
  if( $AFORM_TYPE2 ne $plugin->get_config_value('type2') ){
    $plugin->set_config_value('type2', $AFORM_TYPE2, 'system');
  }

  require AFormEngineCGI::FormMail;
  my $checked_sn = &AFormEngineCGI::FormMail::check_serialnumber();
  $plugin->set_config_value('checked_sn', $checked_sn, 'system');
}

sub init_request {
  my $plugin = shift;
  my $app = MT->instance;
  $plugin->SUPER::init_request(@_);
  my $mode = $app->param('__mode') || '';
  my $type = $app->param('_type') || '';
  my $datasource = $app->param('datasource') || '';
  if (($mode eq 'list' && $type eq 'aform_data') ||
      ($mode eq 'filtered_list' && $datasource eq 'aform_data')){
    $app->reboot;
  }
  elsif (($mode eq 'list' && $type eq 'aform') ||
         ($mode eq 'filtered_list' && $datasource eq 'aform')){
    $app->reboot;
  }
}
1;
