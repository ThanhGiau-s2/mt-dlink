package CSVDataImExporter::ContentData;
use strict;

use base 'Exporter';
our @EXPORT_OK = qw( make_content_actions );
use Data::Dumper;

sub make_content_actions {
    my $app = MT->instance;
    return if !$app->can('core_content_actions');

    my $data = {
       'role' => {
            'create_role' => {
                mode  => 'view',
                class => 'icon-create',
                label => 'Create Role',
                icon  => 'ic_add',
                order => 100,
            }
        },
        'association' => {
            'grant_role' => {
                class => 'icon-create',
                label => 'Grant Permission',
                icon  => 'ic_add',
                mode  => 'dialog_grant_role',
                args  => {
                    _type => 'user',
                    type  => 'site',
                },
                return_args => 1,
                permit_action =>
                    { system_action => 'create_any_association', },
                order  => 100,
                dialog => 1,
            },
        },
        'member' => {
            'grant_role' => {
                class => 'icon-create',
                label => sub {
                    return $app->translate(
                        'Add a user to this [_1]',
                        lc $app->blog->class_label
                    );
                },
                icon => 'ic_add',
                mode => 'dialog_grant_role',
                args => sub {
                    if ( $app->blog->is_blog ) {
                        return {
                            type  => 'blog',
                            _type => 'user',
                        };
                    }
                    else {
                        return {
                            type  => 'website',
                            _type => 'user',
                        };
                    }
                },
                return_args => 1,
                order       => 100,
                dialog      => 1,
            },
        },
        'log' => {
            'reset_log' => {
                class       => 'icon-action',
                label       => 'Clear Activity Log',
                icon        => 'ic_setting',
                mode        => 'reset_log',
                order       => 100,
                confirm_msg => sub {
                    MT->translate(
                        'Are you sure you want to reset the activity log?');
                },
                permit_action => {
                    permit_action => 'reset_blog_log',
                    include_all   => 1,
                },
            },
            'download_log' => {
                class         => 'icon-download',
                label         => 'Download Log (CSV)',
                icon          => 'ic_download',
                mode          => 'export_log',
                order         => 200,
                permit_action => {
                    permit_action => 'export_blog_log',
                    include_all   => 1,
                    system_action => 'export_system_log',
                },
            },
        },
        'banlist' => {
            'ban_ip' => {
                class         => 'icon-create',
                label         => 'Add IP Address',
                id            => 'action-ban-ip',
                order         => 100,
                permit_action => 'save_banlist',
                icon          => 'ic_add',
                condition     => sub {
                    MT->app && MT->app->param('blog_id');
                },
            },
        },
        'notification' => {
            'add_contact' => {
                class      => 'icon-create',
                label      => 'Add Contact',
                id         => 'action-create-contact',
                order      => 100,
                permission => 'edit_notifications',
                icon       => 'ic_add',
                condition  => sub {
                    MT->app && MT->app->param('blog_id');
                },
            },
            'download_csv' => {
                class       => 'icon-download',
                label       => 'Download Address Book (CSV)',
                order       => 200,
                mode        => 'export_notification',
                return_args => 1,
                permission  => 'export_addressbook',
                icon        => 'ic_download',
                condition   => sub {
                    MT->app && MT->app->param('blog_id');
                }
            },
        },
        'group_member' => {
            'add_member' => {
                class             => 'icon-action',
                label             => 'Add user to group',
                mode              => 'dialog_select_group_user',
                system_permission => 'administer,manage_users_groups',
                condition         => sub {
                    my $app = MT->instance;
                    $app->config->ExternalGroupManagement ? 0 : 1;
                },
                dialog => 1,
            },
        },

        %{ CSVDataImExporter::ContentData::make_contentdata_content_actions() },
    };

    my $core = MT->component("core");
    $core->registry( "applications", "cms", "content_actions", $data );
}

sub make_contentdata_content_actions {
    my $plugin = MT->component("CSVDataImExporter");

    my $iter            = MT::ContentType->load_iter;
    my $content_actions = {};
    while ( my $ct = $iter->() ) {
        my $key = 'content_data.content_data_' . $ct->id;
        $content_actions->{$key} = {
            new => {
                label => sub {
                    MT->translate( 'Create new [_1]', $ct->name );
                },
                icon  => 'ic_add',
                order => 100,
                mode  => 'view',
                args  => {
                    blog_id         => $ct->blog_id,
                    content_type_id => $ct->id,
                },
                class => 'icon-create',
            },
            import => {
                label => sub {
                    $plugin->translate( 'Import [_1]', $ct->name );
                },
                icon  => 'ic_add',
                order => 200,
                mode  => 'import_contents_cd',
                args  => {
                    blog_id         => $ct->blog_id,
                    content_type_id => $ct->id,
                },
                class => 'icon-create',
            },
            export => {
                label => sub {
                    $plugin->translate( 'Export [_1]', $ct->name );
                },
                icon  => 'ic_add',
                order => 300,
                mode  => 'start_export_with_excel_cd',
                args  => {
                    blog_id         => $ct->blog_id,
                    content_type_id => $ct->id,
                },
                class => 'icon-create',
            }
        };
    }
    $content_actions;
}

1;
