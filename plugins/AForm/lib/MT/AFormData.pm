# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormData;

use strict;
use MT::Object;
use MT::AForm;
use MT::AFormField;
use MT::AFormData;
use MT::AFormInputError;
use MT::AFormAccess;
use MT::AFormCounter;
use MT::AFormEntry;
use MT::AFormFile;
use AForm::CMS;
use AFormEngineCGI::FormMail;

@MT::AFormData::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
                'id' => 'integer not null auto_increment',
                'aform_id' => 'integer not null',
                'values' => 'text',
                'aform_url' => 'string(255) not null',
                'status' => 'string(255)',
                'comment' => 'text',
                'member_id' => 'integer',
                'cd_id' => 'integer',
                'additional_info' => 'text',
                'ip' => 'string(255)',
                'ua' => 'text',
	},
	indexes => {
                'id' => 1,
                'aform_id' => 1,
                'aform_url' => 1,
                'member_id' => 1,
                'cd_id' => 1,
                'ip' => 1,
	},
        defaults => {
        },
	audit => 1,
	datasource => 'aform_data',
	primary_key => 'id'
});

sub fields {
    my $obj = shift;
    my ($app,$param_fields) = @_;

    if (!$obj->{"FIELDS"}) {
        my @fields;
        if (!$param_fields) {
            my $aform = MT::AForm->load($obj->aform_id);
            @fields = @{AFormEngineCGI::FormMail::_get_fields($app, $aform)};
        }else{
            @fields = @$param_fields;
        }
        my @array_values = @{$obj->array_values};

        my $id_field;
        $id_field->{'type'} = 'receive_id';
        $id_field->{'value'} = shift @array_values;
        push @{$obj->{"FIELDS"}}, $id_field;

        my $date_field;
        $date_field->{'type'} = 'receive_date';
        $date_field->{'value'} = shift @array_values;
        push @{$obj->{"FIELDS"}}, $date_field;

        foreach my $field (@fields) {
            if (is_aform_data_field_type($field->{'type'})) {
                $field->{'value'} = shift @array_values;
            }
            if ($field->{'type'} eq 'reserve') {
                my ($plan_id, $option_value_id, $reserve_date, $plan_name, $option_value) = split(" ", $field->{'value'});
                $field->{'plan_id'}         = $plan_id;
                $field->{'option_value_id'} = $option_value_id;
                $field->{'reserve_date'}    = $reserve_date;
                $field->{'plan_name'}       = $plan_name;
                $field->{'option_value'}    = $option_value;
            }
            elsif ($field->{'type'} eq 'upload') {
                my $aform_file = MT::AFormFile->load({field_id => $field->{'id'}, aform_data_id => $obj->id});
                if ($aform_file) {
                    $field->{'upload_path'} = $aform_file->get_path;
                } else {
                    $field->{'upload_path'} = "";
                }
            }
            push @{$obj->{"FIELDS"}}, $field;
        }
    }
    return $obj->{"FIELDS"};
}

my %AFORM_FIELDS;
sub aform_fields {
    my $obj = shift;
    my($aform_id) = @_;

    if (!$AFORM_FIELDS{$aform_id}) {
        @{$AFORM_FIELDS{$aform_id}} = MT::AFormField->load({aform_id => $aform_id}, {'sort' => 'sort_order'});
    }
    return $AFORM_FIELDS{$aform_id};
}

sub get_col_number {
    my $obj = shift;
    my($aform_id, $field_id, $fields) = @_;

    my $col_number = 2;		# 0:id, 1:datetime
#    my $fields = $obj->aform_fields($aform_id);
    foreach my $field (@$fields) {
        if (!is_aform_data_field_type($field->type)) {
            next;
        }
        if ($field->id == $field_id) {
            return $col_number;
        }
        $col_number++;
    }
    return -1;	# not found
}

sub array_values {
    my $obj = shift;

    if (!$obj->{'array_values'}) {
        my $csv = $obj->values;

        $csv .= ',';
        my @values = map {/^"(.*)"$/s ? scalar($_ = $1, s/""/"/g, $_) : $_}
                      ($csv =~ /("[^"]*(?:""[^"]*)*"|[^,]*),/g);
        # 先頭が日付なら旧フォーマット
        if ($values[0] =~ m/^\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}$/) {
            # 受付番号の分カラムを追加
            unshift @values, "";
        }
        @{$obj->{'array_values'}} = @values;
    }

    return $obj->{'array_values'};
}

sub data_id {
    my $obj = shift;

    my @values = @{$obj->array_values};
    return shift @values;
}

sub disp_data_id {
    my $obj = shift;

    return AForm::CMS::_get_disp_aform_data_id($obj->data_id, 0);
}

sub top {
  my $aform_data = shift;
  my @top_aform_data = MT::App->model('aform_data')->load(
                     { 
                       aform_id => $aform_data->aform_id, 
                     },
                     {
                       sort => 'id',
                       direction => 'ascend',
                       limit => 1,
                     }
                   );
  return @top_aform_data ? $top_aform_data[0] : "";
}

sub last {
  my $aform_data = shift;
  my @last_aform_data = MT::App->model('aform_data')->load(
                     { 
                       aform_id => $aform_data->aform_id, 
                     },
                     {
                       sort => 'id',
                       direction => 'descend',
                       limit => 1,
                     }
                   );
  return @last_aform_data ? $last_aform_data[0] : "";
}

sub next {
  my $aform_data = shift;
  my @next_aform_data = MT::App->model('aform_data')->load(
                     { 
                       aform_id => $aform_data->aform_id, 
                       id => [ $aform_data->id, undef ] 
                     },
                     {
                       sort => 'id',
                       direction => 'ascend',
                       range => { id => 1},
                       limit => 1,
                     }
                   );
  return @next_aform_data ? $next_aform_data[0] : "";
}

sub previous {
  my $aform_data = shift;
  my @prev_aform_data = MT::App->model('aform_data')->load(
                     {
                       aform_id => $aform_data->aform_id,
                       id => [ undef, $aform_data->id ]
                     },
                     {
                       sort => 'id',
                       direction => 'descend',
                       range => { id => 1},
                       limit => 1,
                     }
                   );
  return @prev_aform_data ? $prev_aform_data[0] : "";
}

sub current_pos {
  my $aform_data = shift;
  my $descend = shift;

  my $count = MT::App->model('aform_data')->count(
                     {
                       aform_id => $aform_data->aform_id,
                       id => $descend ? [$aform_data->id, undef] : [undef, $aform_data->id],
                     },
                     {
                       sort => 'id',
                       range => { id => 1 },
                     });
  return $count + 1;
}

sub list_props {
    my $plugin = shift;

    my $props = {
        id => {
            label => 'id',
            auto => 1,
            display => 'none',
        },
        data_id => {
            label => $plugin->translate('Received Data ID'),
            display => 'force',
            order => 100,
            raw => sub {
                my $prop = shift;
                my ($obj, $app, $opts) = @_;

                return $obj->disp_data_id;
            },
            filter_tmpl => '<mt:var name="filter_form_string">',
            terms => 0,
            'grep' => sub { return string_filter_by_grep(@_); },
            bulk_sort => sub { return bulk_sort_string(@_); },
        },
        status => {
            label => $plugin->translate('Data Status'),
            base  => '__virtual.single_select',
            display => 'default',
            order => 200,
            raw => sub {
                my $prop = shift;
                my ($obj, $app, $opts) = @_;
                return $obj->status;
            },
            single_select_options => sub {
                my ($prop)     = shift;

                my $app = MT->app;
                my $aform_id = MT->app->param('aform_id') || '';
                return $app->error('aform_id is null') unless $aform_id;
                my $aform = MT::AForm->load($aform_id);
                my @status = split(',', $aform->data_status_options);
                my @options;
                push @options, {label => '', value => ''};
                foreach my $status (@status) {
                    push @options, {label => $status, value => $status};
                }
                return \@options;
            },
            bulk_sort => sub { return bulk_sort_string(@_); },
        },
        created_on => {
            label => $plugin->translate('Received Datetime'),
            auto => 1,
            display => 'default',
            order => 300,
        },
        detail_link => {
            label => $plugin->translate('Detail'),
            display => 'force',
            order => 999999,
            html => sub {
                my $prop = shift;
                my ($obj, $app, $opts) = @_;

                my $blog_id = $app->blog ? $app->blog->id : '';
                my $aform_id = $app->param('aform_id') || '';
                my $link = $app->uri(
                    mode => 'disp_aform_data',
                    args => {
                        blog_id => $blog_id,
                        aform_id => $aform_id,
                        aform_data_id => $obj->id,
                        manage_return_args => "__mode=list&_type=aform_data&blog_id=$blog_id&aform_id=$aform_id",
                    },
                );

                return '<a href="'. $link .'" class="mt-open-dialog mt-modal-open" data-mt-modal-large>'. $plugin->translate('Detail') .'</a>';
            },
        },
        ip => {
            label => $plugin->translate('IP'),
            auto => 1,
            order => 999100,
        },
        ua => {
            label => $plugin->translate('User Agent'),
            auto => 1,
            order => 999200,
        },
    };

    my $app = MT->app;
    my $aform_id = AForm::CMS::init_request_aform_id($app);
    return $app->error('aform_id is null') unless $aform_id;

    my $order = 1000;
    my @fields = MT::AFormField->load({aform_id => $aform_id}, {'sort' => 'sort_order'});
    foreach my $field (@fields) {
        # ignore label or note fields
        if (!is_aform_data_field_type($field->type)) {
            next;
        }
        # add fields to props
        $props->{'field' . $field->id} = {
            label => $field->label,
            display => 'optional',
            order => $order,
            raw => sub {
                my $prop = shift;
                my ($obj, $app, $opts) = @_;

                $app = MT->app unless $app;
                my $aform_id = $app->param('aform_id') || '';
                return $app->error('aform_id is null') unless $aform_id;
                my $field_id = $prop->id;
                $field_id =~ s/^field//;

                my $col_number = $obj->get_col_number($aform_id, $field_id, \@fields);
                if ($col_number < 0) {
                    return 'invalid col_number';
                }

                my @values = @{$obj->array_values};
                my $value = $values[$col_number];

                MT->run_callbacks('aform_data_before_list_prop_raw', $app, $aform_id, $field_id, \$value);

                return $value;
            },
            html => sub {
                my $prop = shift;
                my ($obj, $app, $opts) = @_;

                $app = MT->app unless $app;
                my $value = $prop->raw($obj, $app, $opts);
                $value = MT::Util::encode_html($value);
                if ($field->type eq 'upload' && $value ne '') {
                    my $aform_id = $app->param('aform_id') || '';
                    return $app->error('aform_id is null') unless $aform_id;
                    my $aform_file = MT::AFormFile->load({
                        aform_id => $aform_id,
                        field_id => $field->id,
                        aform_data_id => $obj->id,
                    });
                    my $aform_file_id = $aform_file ? $aform_file->id : undef;
                    my $blog_id = $app->param('blog_id') || '';
                    my $link = $app->uri(
                        mode => 'download_aform_file',
                        args => {blog_id => $blog_id, id => $aform_file_id});
                    $value = sprintf('<a href="%s">%s</a>', $link, $value);
                }
                return $value;
            },
            filter_tmpl => &field_filter_tmpl($app, $field),
            terms => 0,
            'grep' => sub { return string_filter_by_grep(@_, $field); },
            bulk_sort => sub { return bulk_sort_string(@_); },
        };
        $order += 100;
    }

    &add_member_id_to_list_props($plugin, $props);

    return $props;
}

sub field_filter_tmpl {
    my ($app, $field) = @_;

    my $filter_tmpl = '<mt:var name="filter_form_string">';
    MT->run_callbacks('aform_data_field_filter_tmpl', $app, $field, \$filter_tmpl);
    return $filter_tmpl;
}

sub cms_pre_load_filtered_list {
    my ( $cb, $app, $filter, $load_options, $cols ) = @_;

    my $aform_id = $app->param('aform_id') || '';
    return $app->error('aform_id is null') unless $aform_id;

    $$load_options{'terms'}{'aform_id'} = $aform_id;	# force filtered by aform_id
    if ($$load_options{'sort_by'} eq "") {
        $$load_options{'sort_by'} = 'created_on';
        $$load_options{'sort_order'} = 'descend';
    }
}

sub list_template_param {
    my ($cb, $app, $param, $tmpl) = @_;

    my $blog_id = $app->param('blog_id') || '';
    my $aform_id = $app->param('aform_id') || '';
    return $app->error('aform_id is null') unless $aform_id;
    my $aform = MT::AForm->load($aform_id);
    return $app->error('aform is null') unless $aform;

    # include aform_data_list_header.tmpl
    if (MT->version_id >= 5.13) {
        push @{$param->{'list_headers'}}, { filename => AForm::CMS::get_aform_dir() . '/tmpl/cms/listing/aform_data_list_header.tmpl', component => 'AForm'};
    }else{
        push @{$param->{'list_headers'}}, AForm::CMS::get_aform_dir() . '/tmpl/cms/listing/aform_data_list_header.tmpl';
    }

    # params for aform_data_list_header.tmpl
    $param->{'id'} = $aform_id;
    $param->{'plugin_static_uri'} = AForm::CMS::_get_plugin_static_uri($app);
    $param->{'object_type'} = 'aform_data';
    $param->{'saved_deleted'} = ( $app->param('saved_deleted') || '' );
    $param->{'saved_changes'} = ( $app->param('saved_changes') || '' );
    ## Load next and previous entries for next/previous links
    if( my $next = $aform->next({exclude_amember => 1}) ){
        $param->{'next_aform_id'} = $next->id;
    }
    if( my $previous = $aform->previous({exclude_amember => 1}) ){
        $param->{'previous_aform_id'} = $previous->id;
    }
    $param->{'aform_reserve_installed'} = AForm::CMS::_aform_reserve_installed();
    $param->{'aform_payment_installed'} = AForm::CMS::_aform_payment_installed();
    $param->{'page_title'} = sprintf("%s(aform%03d)", $app->translate('Manage [_1] Data', $aform->title), $aform_id);
    $param->{'aform_action_tabs'} = AForm::CMS::get_aform_action_tabs($app, $blog_id, $aform_id, 'manage_aform_data');

    my @aform_fields = MT::AFormField->load({aform_id => $aform_id});
    foreach my $aform_field (@aform_fields) {
        if ($aform_field->type eq 'reserve') {
            $param->{'exists_reserve_field'} = 1;
            last;
        }
    }
    if (AForm::CMS::can_do($app, $aform->blog_id, 'export_aform_data')) {
        $param->{'can_export_aform_data'} = 1;
    }
    if (AForm::CMS::can_do($app, $aform->blog_id, 'delete_aform_data')) {
        $param->{'can_delete_aform_data'} = 1;
    }
    $param->{'return_args'} .= "&aform_id=$aform_id";

    $param->{'charset'} = ($aform->lang eq 'ja' || $aform->lang eq 'en_us') ? 'shift_jis' : 'utf-8';
}

sub list_actions {
    my $app = MT->app;
    my $aform_id = $app->param('aform_id') || '';
    my $aform = MT::AForm->load($aform_id);
    if (!$aform || !AForm::CMS::can_do($app, $aform->blog_id, 'delete_aform_data')) {
        return;
    }

    return {
        'delete' => {
            label      => 'Delete',
            code       => "Common::delete",
            mode       => 'delete',
            order      => 100,
            js_message => 'delete',
            button     => 1,
        },
    }
}

sub string_filter_by_grep {
    my $prop = shift;
    my ($args, $objs, $opts, $field) = @_;

    my @return;
    my $string = $args->{string};
    if ($args->{option} eq 'contains') {
        @return = grep { $prop->{raw}($prop, $_) =~ m/$string/ } @$objs;
    }
    elsif ($args->{option} eq 'not_contains') {
        @return = grep { $prop->{raw}($prop, $_) !~ m/$string/ } @$objs;
    }
    elsif ($args->{option} eq 'equal') {
        @return = grep { $prop->{raw}($prop, $_) eq $string } @$objs;
    }
    elsif ($args->{option} eq 'beginning') {
        @return = grep { $prop->{raw}($prop, $_) =~ m/^$string/ } @$objs;
    }
    elsif ($args->{option} eq 'end') {
        @return = grep { $prop->{raw}($prop, $_) =~ m/$string$/ } @$objs;
    }
    else {
        @return = @$objs;
    }
    MT->run_callbacks('aform_data_string_filter_by_grep', $prop, $field, $args, $objs, $opts, \@return);
    return @return;
}

sub bulk_sort_string {
    my $prop = shift;
    my ($objs, $opts) = @_;

    return sort { $prop->{raw}($prop, $a) cmp $prop->{raw}($prop, $b) } @$objs;
}

# amember
my $AMEMBER;
sub amember {
    if (!$AMEMBER) {
        $AMEMBER = AForm::CMS::_get_amember();
    }
    return $AMEMBER;
}

sub add_member_id_to_list_props {
    my ($plugin, $props) = @_;

    if (!AForm::CMS::_is_amember_installed()) {
        return;
    }

    $props->{'cd_id'} = {
        label => $plugin->translate('Member ID'),
        auto  => 1,
        order => 150,
        raw => sub {
            my ($prop, $obj) = @_;

            my $cd_id = $obj->cd_id;
            return undef unless $cd_id;
            my $cd = MT::ContentData->load($cd_id);
            return undef unless $cd;
            return $cd->label;
        },
        html_link => sub {
            my $prop = shift;
            my ($obj, $app, $opts) = @_;

            my $cd_id = $obj->cd_id;
            return undef unless $cd_id;
            my $amember = amember();
            return undef unless $amember;
            my $cd = MT::ContentData->load($cd_id);
            return undef unless $cd;

            return $app->uri(
                mode => 'view',
                args => {
                    _type => 'content_data',
                    blog_id => $cd->blog_id,
                    id => $cd->id,
                    content_type_id => $cd->content_type->id,
                });
        },
    };
}

sub cms_post_delete {
    my ($cb, $app, $aform_data) = @_;

    my $aform = MT::AForm->load($aform_data->aform_id);
    $app->log({message => $app->translate('[_1](ID:[_2]) data #[_3] was deleted by [_4](ID:[_5]).', $aform->title, $aform->id, $aform_data->disp_data_id, $app->user->name, $app->user->id), blog_id => $aform->blog_id});
}

sub cms_delete_permission_filter {
    my ($cb, $app, $aform_data) = @_;

    my $aform = MT::AForm->load($aform_data->aform_id);
    return AForm::CMS::can_do($app, $aform->blog_id, 'delete_aform_data');
}

sub reserve_date_range_check {
    my $obj = shift;
    my ($range_from, $range_to) = @_;

    my $reserve_field;
    foreach my $field (@{$obj->fields}) {
        if ($field->{'type'} eq 'reserve') {
            $reserve_field = $field;
            last;
        }
    }
    return 0 unless $reserve_field;

    my $reserve_date = $reserve_field->{'reserve_date'};
    $reserve_date =~ s/\D//g;
    $range_from =~ s/\D//g;
    $range_to =~ s/\D//g;
    if ($range_from && $range_from gt $reserve_date) {
        return 0;
    }
    if ($range_to && $range_to lt $reserve_date) {
        return 0;
    }
    return 1;
}

sub is_aform_data_field_type {
    my ($type) = @_;

    if ($type eq 'label' || $type eq 'note' || $type eq 'pagebreak') {
        return 0;
    }
    return 1;
}

1;

