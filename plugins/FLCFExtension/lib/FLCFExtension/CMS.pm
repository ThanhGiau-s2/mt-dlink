package FLCFExtension::CMS;

use strict;
use warnings;

use MT::Util qw( encode_js encode_html remove_html trim );
use FLCFCommon::Util qw( load_asset_types );
use Scalar::Util qw( looks_like_number );

use JSON;

sub flcf_types {
    my $types = {
        spinner => {
            html => qq{
<input type="text" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" class="flcfex-spinner<mt:if name="class"> <mt:var name="class" encode_html="1"></mt:if>" />
            },
            validator => \&spinner_validator,
        },
        color => {
            html => qq{
<span class="flcfex-color-wrapper<mt:if name="class"> <mt:var name="class" encode_html="1"></mt:if>">
<input type="text" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" class="flcfex-color" />
</span>
            },
            js_set_value => 1,
            js_file => 'FLCFExtension/js/evol.colorpicker',
            js_order => 500,
            css_file => 'FLCFExtension/css/evol.colorpicker',
            css_order => 500,
        },
        simplecolor => {
            html => qq{
<span class="flcfex-simple-color<mt:if name="class"> <mt:var name="class" encode_html="1"></mt:if>" /><input type="text" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" class="flcfex-simplecolor" /><span class="flcfex-simplecolor-color"></span></span>
            },
            js_set_value => 1,
            js_file => 'FLCFExtension/js/jquery.simple-color-picker',
            js_order => 200,
            css_file => 'FLCFExtension/css/jquery.simple-color-picker',
            css_order => 200,
        },
        colorpicker => {
            html => qq{
<span class="flcfex-colpick-wrapper<mt:if name="class"> <mt:var name="class" encode_html="1"></mt:if>">#</span><input type="text" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" class="flcfex-colpick" /><span class="flcfex-colpick-color"></span></span>
            },
            js_set_value => 1,
            js_file => 'FLCFExtension/js/colpick',
            js_order => 400,
            css_file => 'FLCFExtension/css/colpick',
            css_order => 400,
        },
#        minicolor => {
#            html => qq{
#<span class="flcfex-simple-color" />
#<input type="text" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" class="flcfex-minicolor<mt:if name="class"> <mt:var name="class" encode_html="1"></mt:if>" />
#</span>
#            }
#        },
        multiselect => {
            html => qq{
<select name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" multiple="multiple" class="flcfex-dlist<mt:if name="class"> <mt:var name="class" encode_html="1"></mt:if>">
<mt:loop name="options">
    <option value="<mt:var name="value" encode_html="1">"<mt:if name="selected"> selected="selected"</mt:if>><mt:var name="label"></option>
</mt:loop>
</select>
            },
            set_options => \&multiselect_set_options,
            null_filter => \&multiselect_null_filter,
            check_null => \&multiselect_check_null,
            js_set_value => 1,
            js_file => 'FLCFExtension/js/ui.dropdownchecklist',
            js_order => 600,
            css_file => 'FLCFExtension/css/ui.dropdownchecklist.themeroller',
            css_order => 600,
        },
        multiselect_optgroup => {
            html => qq{
<select name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" multiple="multiple"<mt:if name="class"> class="<mt:var name="class" encode_html="1">"</mt:if>>
<mt:loop name="options">
    <mt:if name="group_first">
    <optgroup label="<mt:var name="group" encode_html="1">">
    </mt:if>
    <option value="<mt:var name="value" encode_html="1">"<mt:if name="selected"> selected="selected"</mt:if>><mt:var name="label"></option>
    <mt:if name="group_last">
    </optgroup>
    </mt:if>
</mt:loop>
</select>
            },
            set_options => \&multiselect_set_options,
            null_filter => \&multiselect_null_filter,
            check_null => \&multiselect_check_null,
            js_set_value => 1,
            js_file => 'FLCFExtension/js/ui.dropdownchecklist',
            js_order => 600,
            css_file => 'FLCFExtension/css/ui.dropdownchecklist.themeroller',
            css_order => 600,
        },
        richtext => {
            html => qq{
<textarea name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" class="flcf-richtext<mt:if name="class" encode_html="1"> <mt:var name="class"></mt:if>"><mt:var name="value" encode_html="1"></textarea>
            },
            tmpl_output => sub {
                my ($ctx, $args, $value) = @_;
                require FLCFExtension::ContextHandlers;
                return FLCFExtension::ContextHandlers::out_richtext($ctx, $args, $value);
            },
            null_filter => \&richtext_null_filter,
            check_null => \&richtext_check_null,
        },
        table => {
            html => qq{
<div class="flcf-table-wrapper">
    <input name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" type="hidden" value="<mt:var name="value" encode_html="1">" />
<table id="<mt:var name="id" encode_html="1">_appendgrid" class="flcf-table<mt:if name="class"> <mt:var name="class" encode_html="1"></mt:if>"></table>
</div>
            },
            set_params => \&table_set_params,
            null_filter => \&table_null_filter,
            always_filter => 1,
            check_null => \&table_check_null,
            pre_init_js => \&table_pre_init_js,
            restore_assets => \&table_restore_assets,
            js_set_value => 1,
            js_file => 'FLCFExtension/js/jquery.appendGrid',
            js_order => 100,
            css_file => 'FLCFExtension/css/jquery.appendGrid',
            css_order => 100,
        },
    };

    return $types;
}

sub spinner_validator {
    my ($cf_name, $field_name, $field_value, $flcf_def, $ug, $group_no, $errors) = @_;
    my $plugin = MT->component('FLCFExtension');

    my $max = $flcf_def->{fields}->{$field_name}->{max};
    my $min = $flcf_def->{fields}->{$field_name}->{min};
    my $err = spinner_check_value($field_value, $min, $max);
    if ($err) {
        if ($flcf_def->{options}->{multiple}) {
            push @$errors, $plugin->translate(
                'Field [_1] in [_3] [_2] [_4] of customfield [_3] must be [_5].',
                $flcf_def->{fields}->{$field_name}->{label}, $group_no, $cf_name, $ug, $err
            );
        }
        else {
            push @$errors, $plugin->translate(
                'Field [_1] of customfield [_2] must be [_3].',
                $flcf_def->{fields}->{$field_name}->{label}, $cf_name, $err
            );
        }
    }
}

sub spinner_check_value {
    my ($value, $min, $max) = @_;
    my $plugin = MT->component('FLCFExtension');

    if (!looks_like_number($value)) {
        return $plugin->translate('a number');
    }
    elsif (defined($min) && !defined($max) && $value < $min) {
        return $plugin->translate('[_1] and over', $min);
    }
    elsif (!defined($min) && defined($max) && $value > $max) {
        return $plugin->translate('[_1] or less', $max);
    }
    elsif (defined($min) && defined($max) &&
           ($value < $min || $value > $max)) {
        return $plugin->translate('between [_1] and [_2]', $min, $max);
    }
}

sub multiselect_set_options {
    my ($opt_g, $field_name, $group_no, $field_def, $value) = @_;

    my %value_h;
    if (!ref $value) {
        $value = [];
    }
    for my $val (@$value) {
        $value_h{$val} = 1;
    }
    my $opts = $field_def->{options};
    my $flcf_type = $field_def->{type};
    _multiselect_set_options_sub($flcf_type, $opt_g, $opts, \%value_h);
}

sub multiselect_check_null {
    my ($field_value, $flcf_def, $field_name) = @_;

    if (
        !$field_value
        ||
        (ref($field_value) eq 'ARRAY' && !scalar(@$field_value))
    ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub multiselect_null_filter {
    my ($cf_name, $field_name, $field_value, $flcf_def, $ug, $group_no, $errors) = @_;
    my $f_plugin = MT->component('FreeLayoutCustomField');

    if (multiselect_check_null($field_value, $flcf_def, $field_name)) {
        if ($flcf_def->{options}->{multiple}) {
            push @$errors, $f_plugin->translate(
                'Field [_1] in [_3] [_2] [_4] of customfield [_3] is required.',
                $flcf_def->{fields}->{$field_name}->{label}, $group_no, $cf_name, $ug
            );
        }
        else {
            push @$errors, $f_plugin->translate(
                'Field [_1] of customfield [_2] is required.',
                $flcf_def->{fields}->{$field_name}->{label}, $cf_name
            );
        }
    }
}

sub richtext_check_null {
    my ($field_value, $flcf_def, $field_name) = @_;

    my $v = trim(remove_html($field_value));
    return ($v eq '') ? 1 : 0;
}

sub richtext_null_filter {
    my ($cf_name, $field_name, $field_value, $flcf_def, $ug, $group_no, $errors) = @_;
    my $f_plugin = MT->component('FreeLayoutCustomField');

    if (richtext_check_null($field_value, $flcf_def, $field_name)) {
        if ($flcf_def->{options}->{multiple}) {
            push @$errors, $f_plugin->translate(
                'Field [_1] in [_3] [_2] [_4] of customfield [_3] is required.',
                $flcf_def->{fields}->{$field_name}->{label}, $group_no, $cf_name, $ug
            );
        }
        else {
            push @$errors, $f_plugin->translate(
                'Field [_1] in customfield [_2] is required.',
                $flcf_def->{fields}->{$field_name}->{label}, $cf_name
            );
        }
    }
}


sub table_set_params {
    my ($param_options, $field_name, $group_no, $field_def, $val) = @_;

    my $app = MT->instance;
    my $req = MT->request;

    my $asset_ids = $req->stash('FLCFExtension::AssetIDs') || {};

    for my $column (@{$field_def->{columns}}) {
        my $ctrl_attrs = {};
        # set placeholder
        if ($column->{type} eq 'text' || $column->{type} eq 'textarea' ||
            $column->{type} eq 'number') {
            $ctrl_attrs->{placeholder} = $column->{placeholder} 
                if (defined($column->{placeholder}));
        }
        # set pattern
        if ($column->{type} eq 'text') {
            $ctrl_attrs->{pattern} = $column->{pattern} 
                if (defined($column->{pattern}));
        }
        # set minlength / maxlength
        if ($column->{type} eq 'text' || $column->{type} eq 'textarea') {
            $ctrl_attrs->{minlength} = $column->{minlength} 
                if (defined($column->{minlength}));
            $ctrl_attrs->{maxlength} = $column->{maxlength} 
                if (defined($column->{maxlength}));
        }

        # check asset ids
        if (($column->{type} eq 'image' || $column->{type} eq 'audio' ||
            $column->{type} eq 'video' || $column->{type} eq 'file') &&
            ref $val) {
            for my $row (@$val) {
                my $asset_id = $row->{$column->{name}};
                if ($asset_id && !$asset_ids->{$asset_id}) {
                    $asset_ids->{$asset_id} = 1;
                }
            }
        }
        # set option of number / range
        elsif ($column->{type} eq 'number' || $column->{type} eq 'range') {
            $ctrl_attrs->{min} = $column->{min} if (defined($column->{min}));
            $ctrl_attrs->{max} = $column->{max} if (defined($column->{max}));
            $ctrl_attrs->{step} = $column->{step} if (defined($column->{step}));
        }
        # set option of optgroup
        elsif ($column->{type} eq 'optgroup') {
            if (!$column->{options_setuped}) {
                my $opts = $column->{options};
                my $count = scalar(@$opts);
                my $group_seen = 0;
                for (my $i = 0; $i < $count; $i++) {
                    if ($opts->[$i]->{group}) {
                        $opts->[$i]->{group_first} = 1;
                        $group_seen = 1;
                    }
                    if (($i == $count - 1 ||
                        $opts->[$i + 1]->{group}) &&
                        $group_seen) {
                        $opts->[$i]->{group_last} = 1;
                    }
                    if (!$opts->[$i]->{label}) {
                        $opts->[$i]->{label} = $opts->[$i]->{value};
                    }
                }
                $column->{option_setuped} = 1;
            }
        }
        # set option of multiselect
        elsif ($column->{type} eq 'multiselect' ||
               $column->{type} eq 'multiselect_optgroup') {
            my $opts = $column->{options};
            $val = [] if (!$val);
            my %values_h;
            for my $v (@$val) {
                $values_h{$v} = 1;
            }
            if (!$column->{options_setuped}) {
                my $opt_g = [];
                _multiselect_set_options_sub($column->{type}, $opt_g, $opts, \%values_h);
                $column->{options} = $opt_g;
                $column->{options_setuped} = 1;
            }
            else {
                for (my $i = 0; $i < scalar(@{$column->{options}}); $i++) {
                    $column->{options}->[$i]->{selected} =
                        $values_h{$column->{options}->[$i]->{value}};
                }
            }
        }
        # set ctrlAttr
        if (scalar(keys %$ctrl_attrs)) {
            $column->{ctrlAttr} = $ctrl_attrs;
        }
    }

    $req->stash('FLCFExtension::AssetIDs', $asset_ids);
}

sub table_pre_init_js {
    my $req = MT->request;

    my $asset_ids = $req->stash('FLCFExtension::AssetIDs') || {};
    my @assets = MT->model('asset')->load({ id => [ keys %$asset_ids ] });
    my %asset_info = ();
    my $t = MT::Template->new(
        type => 'scalarref',
    );
    my $ctx = $t->context;
    $t->text('<mt:asseturl>|<mt:assetthumbnailurl width="100">|<mt:assetlabel>');
    for my $asset (@assets) {
        $ctx->stash('asset', $asset);
        my $out = $t->output();
        my @info = split /\|/, $out;
        $asset_info{$asset->id} = {
            url => $info[0],
            thumb => ($asset->class eq 'image') ? $info[1] : '',
            filename => $info[2]
        };
    }
    return 'FLCFExtension.appendgrid.asset_buf = ' . to_json(\%asset_info) . ";\n";
}

sub table_check_null {
    my ($field_value, $flcf_def, $field_name) = @_;

    return 1 
        if (
            !$field_value
            ||
             (ref($field_value) eq 'ARRAY' && !scalar(@$field_value))
        );
    my $columns = $flcf_def->{fields}->{$field_name}->{columns};
    my $pseudo_def = { fields => {} };
    for my $column (@$columns) {
        $pseudo_def->{fields}->{$column->{name}} = $column;
    }
    my $flcf_types = MT->registry('flcf_types');
    my $table_is_null = 1;
    for my $row (@$field_value) {
        my $row_is_null = 1;
        for my $column (@$columns) {
            my $column_is_null;
            my $type = $column->{type};
            my $code = $flcf_types->{$type}->{check_null};
            if ($code) {
                $column_is_null = $code->($row->{$column->{name}}, $pseudo_def, $field_name);
            }
            else {
                $column_is_null = ($row->{$column->{name}} eq '');
            }
            if (!$column_is_null) {
                $row_is_null = 0;
                last;
            }
        }
        $row->{flcf_row_is_null} = $row_is_null;
        if (!$row_is_null) {
            $table_is_null = 0;
        }
    }
    return $table_is_null;
}

sub table_null_filter {
    my ($cf_name, $field_name, $rows, $flcf_def, $ug, $group_no, $errors) = @_;
    my $plugin = MT->component('FLCFExtension');

    my $columns = $flcf_def->{fields}->{$field_name}->{columns};

    # create pseudo def
    my $pseudo_def = { fields => {} };
    for my $column (@$columns) {
        $pseudo_def->{fields}->{$column->{name}} = $column;
    }
    my $row_count = (ref $rows eq 'ARRAY') ? scalar @$rows : 0;
    my $flcf_types = MT->registry('flcf_types');
    my $field_label = $flcf_def->{fields}->{$field_name}->{label};

    # check required
    for (my $i = 0; $i < $row_count; $i++) {
        my $row = $rows->[$i];
        for my $column (@$columns) {
            my $type = $column->{type};
            my $col_name = $column->{name};
            if ($column->{required} || $flcf_def->{options}->{required}) {
                my $is_null;
                my $code = $flcf_types->{$type}->{check_null};
                if ($code) {
                    $is_null =  $code->($row->{$col_name}, $pseudo_def, $field_name);
                }
                else {
                    $is_null = ($row->{$col_name} eq '');
                }
                if ($is_null) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] is required.',
                            $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Row [_1] column [_2] of Field [_3] in customfield [_4] is required.',
                            $i + 1, $column->{label}, $field_label, $cf_name
                        );
                    }
                }
            }
            if (
                ($type eq 'text' || $type eq 'textarea')
                &&
                $column->{maxlength}
                &&
                length($row->{$col_name}) > $column->{maxlength}
            ) {
                if ($flcf_def->{options}->{multiple}) {
                    push @$errors, $plugin->translate(
                        'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] must be shorter than [_7] character(s) string.',
                        $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug, $column->{maxlength}
                    );
                }
                else {
                    push @$errors, $plugin->translate(
                        'Row [_1] column [_2] of Field [_3] in customfield [_4] must be shorter than [_5] character(s) string.',
                        $i + 1, $column->{label}, $field_label, $cf_name, $column->{maxlength}
                    );
                }
            }
            if (
                ($type eq 'text' || $type eq 'textarea')
                &&
                $column->{minlength}
                &&
                length($row->{$col_name}) < $column->{minlength}
            ) {
                if ($flcf_def->{options}->{multiple}) {
                    push @$errors, $plugin->translate(
                        'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] must be longer than [_7] character(s) string.',
                        $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug, $column->{minlength}
                    );
                }
                else {
                    push @$errors, $plugin->translate(
                        'Row [_1] column [_2] of Field [_3] in customfield [_4] must be longer than [_5] character(s) string.',
                        $i + 1, $column->{label}, $field_label, $cf_name, $column->{minlength}
                    );
                }
            }
            if ($type eq 'text' && $column->{pattern}) {
                my $pattern = '^' . $column->{pattern} . '$';
                if ($row->{$col_name} !~ /$pattern/) {
                    my $pattern_errmsg =
                        $column->{pattern_errmsg} ||
                        $plugin->translate('has illegal format');
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] [_7].',
                            $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug, $pattern_errmsg
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Row [_1] column [_2] of Field [_3] in customfield [_4] [_5].',
                            $i + 1, $column->{label}, $field_label, $cf_name, $pattern_errmsg
                        );
                    }
                }
            }
            if ($type eq 'number' || $type eq 'range') {
                my $min = $column->{min};
                if (defined($min) && $row->{$col_name} != '' && $row->{$col_name} < $min) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] must be greater or equal than [_7].',
                            $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug, $min
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Row [_1] column [_2] of Field [_3] in customfield [_4] must be greater or equal than [_5].',
                            $i + 1, $column->{label}, $field_label, $cf_name, $min
                        );
                    }
                }
                my $max = $column->{max};
                if (defined($max) && $row->{$col_name} != '' && $row->{$col_name} > $max) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] must be smaller or equal than [_7].',
                            $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug, $max
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Row [_1] column [_2] of Field [_3] in customfield [_4] must be smaller or equal than [_5].',
                            $i + 1, $column->{label}, $field_label, $cf_name, $max
                        );
                    }
                }
                my $step = $column->{step} || 1;
                $min = 0 if (!defined($min));
                my $v = $row->{$col_name} - $min;
                my $d = int($v / $step);
                if (defined($step) && $row->{$col_name} ne '' &&
                    $v - $step * $d != 0) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] must be [_7] interval from [_8].',
                            $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug, $step, $min
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Row [_1] column [_2] of Field [_3] in customfield [_4] must be [_5] interval from [_6].',
                            $i + 1, $column->{label}, $field_label, $cf_name, $step, $min
                        );
                    }
                }
            }
            if (($type eq 'datetime' || $type eq 'date' || $type eq 'time')
                &&
                $row->{$col_name} =~ /error/) {
                if ($flcf_def->{options}->{multiple}) {
                    push @$errors, $plugin->translate(
                        'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] has invalid format.',
                        $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug
                    );
                }
                else {
                    push @$errors, $plugin->translate(
                        'Row [_1] column [_2] of Field [_3] in customfield [_4] has invalid format.',
                        $i + 1, $column->{label}, $field_label, $cf_name
                    );
                }
            }
            if ($type eq 'spinner' && $row->{$col_name} != '') {
                my $err = spinner_check_value($row->{$col_name}, $column->{min}, $column->{max});
                if ($err) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] row [_2] column [_3] in [_4] [_5] [_6] of customfield [_4] must be [_7].',
                            $field_label, $i + 1, $column->{label}, $cf_name, $group_no, $ug, $err
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Row [_1] column [_2] of Field [_3] in customfield [_4] must be [_5].',
                            $i + 1, $column->{label}, $field_label, $cf_name, $err
                        );
                    }
                }
            }
        }
    }
}

sub table_restore_assets {
    my ($value, $field_def, $field_name, $assets) = @_;

    my $columns = $field_def->{$field_name}->{columns};
    my %asset_types = load_asset_types();
    return if (!$value->{$field_name});
    my $row_count = scalar(@{$value->{$field_name}});
    for (my $i = 0; $i < $row_count; $i++) {
        for my $column (@$columns) {
            my $old_asset_id = $value->{$field_name}->[$i]->{$column->{name}};
            if ($asset_types{$column->{type}} && $old_asset_id) {
                $value->{$field_name}->[$i]->{$column->{name}} = $assets->{$old_asset_id};
            }
        }
    }
}

sub asset_insert {
    my ($cb, $app, $param, $tmpl) = @_;

    my $edit_field = encode_js($app->param('edit_field'));
    return 1 unless ($edit_field =~ /^flcfex_apg_(.*)$/);

    my $block = $tmpl->getElementById('insert_script');
    return 1 unless $block;
    my $asset_url = '';
    my $thumb_url = '';
    my $asset_filename = '';
    my $ctx = $tmpl->context;
    my $asset_id = 0;
    if ($edit_field =~ /^flcfex_apg_cu/) {
        $edit_field =~ s/^flcfex_apg_cu/customfield/;
    }
    elsif ($edit_field =~ /^flcfex_apg_ct/) {
        $edit_field =~ s/^flcfex_apg_ct/content-field/;
    }
    my $asset = $ctx->stash('asset');
    if (!$asset) {
        my $assets = $ctx->stash('assets');
        if ($assets && ref($assets) eq 'ARRAY') {
            my $count = scalar @$assets;
            if ($count) {
                $asset = $assets->[$count - 1];
            }
        }
    }
    if ($asset) {
        $asset_id = $asset->id;
        my $a_ctx = MT::Template::Context->new;
        my $blog = $app->blog;
        $a_ctx->stash('asset', $asset);
        $a_ctx->stash('blog', $blog);
        $a_ctx->stash('blog_id', $blog->id);
        $a_ctx->var('asset_type', $asset->class_type);
        $a_ctx->var('asset_id', $asset->id);
        my $a_tmpl = MT::Template->new;
        my $tmpl_text = <<HERE;
<mt:Asset id="\$asset_id">
  <mt:AssetLabel setvar="filename">
  <mt:AssetURL setvar="url">
  <mt:If name="asset_type" eq="image">
    <mt:AssetThumbnailURL width="100" setvar="thumb">
  </mt:If>
</mt:Asset>
HERE
        $a_tmpl->text($tmpl_text);
        $a_tmpl->build($a_ctx, {});
        $asset_url = $a_ctx->var('url');
        $asset_filename = $a_ctx->var('filename');
        $thumb_url = $a_ctx->var('thumb');
        $block->innerHTML(
            qq{
top.FLCFExtension.appendgrid.asset.insert_asset('$edit_field', '$asset_url', '$thumb_url', '$asset_filename', $asset_id);
            }
        );
    }
}

sub edit_entry {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT->component('FLCFExtension');

    my $incl_node = $tmpl->getElementById('footer_include');
    if ($incl_node) {
        my $node = $tmpl->createElement('setvarblock', { name => 'jq_js_include', append => 1 });
        my $innerHTML = <<HERE;
jQuery('#sortable').on('sortstop', FLCFExtension.renewRichtext);
HERE
        $node->innerHTML($innerHTML);
        $tmpl->insertBefore($node, $incl_node);
    }
}

sub setup_editor_param {
    my ($cb, $app, $param, $tmpl) = @_;

    return 1 if (MT->version_number lt '5.2');

    my $object_type;
    if ($app->mode eq 'cfg_prefs') {
        $object_type = $app->blog->class;
    }
    else {
        $object_type = $app->param('_type');
    }
    my $addjs = $app->registry('flcfext_richtext_addjs');
    if (!$addjs->{$object_type}) {
        return 1;
    }

    my $req = MT->request;
    my $used_flcf_types = $req->stash('FreeLayoutCustomField::USED_FLCF_TYPES') || {};
    my $flag = 0;
    for my $type (keys %$used_flcf_types) {
        if ($type eq 'richtext') {
            $flag = 1;
            last;
        }
    }
    return 1 if !$flag;

    my $includes = $tmpl->getElementsByTagName('include');
    my $host_node;
    for my $element (@$includes) {
        if ($element->attributes->{name} eq 'layout/default.tmpl') {
            $host_node = $element;
            last;
        }
    }
    if ($host_node) {
        my $node = $tmpl->createElement('include', { 'name' => 'include/editor_script.tmpl', 'id' => 'editor_script_include' });
        $tmpl->insertBefore($node, $host_node);

        $app->setup_editor_param($param);
        $param->{search_type}  = 'entry';
        $param->{search_label} = $app->translate('Entry');
        $param->{content_css} = '';
    }
}

sub edit_content_data {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT->component('FreeLayoutContentField');

    if (!$param->{has_multi_line_text_field}) {
        my $req = MT->request;
        my $used_flcf_types = $req->stash('FreeLayoutCustomField::USED_FLCF_TYPES') || {};
        my $flag = 0;
        for my $type (keys %$used_flcf_types) {
            if ($type eq 'richtext') {
                $flag = 1;
                last;
            }
        }
        return 1 if !$flag;

        # search <mt:if name="has_multi_line_text_field"> tag
        my $host_node;
        my $ifs = $tmpl->getElementsByTagName('if');
        for my $element (@$ifs) {
            if ($element->attributes->{name} eq 'has_multi_line_text_field') {
                $host_node = $element;
                last;
            }
        }
        my $node = $tmpl->createElement('include', { 'name' => 'include/editor_script.tmpl', 'id' => 'editor_script_include' });
        $tmpl->insertAfter($node, $host_node);
    }
    return 1;
}


sub ext_js {
    my ($used_ctrls, $field_defs) = @_;
    my $app = MT->instance;

    my %js_files = ();
    $used_ctrls ||= {};
    $field_defs ||= {};
    my $js_ext = MT->config->DebugMode ? 'js' : 'min.js';
    my $flcf_types = $app->registry('flcf_types');
    for my $cf (keys %$used_ctrls) {
        for my $unit (keys %{$used_ctrls->{$cf}}) {
            for my $field (keys %{$used_ctrls->{$cf}->{$unit}}) {
                my $type = $field_defs->{$cf}->{$field}->{type};
                if ($type eq 'table') {
                    $js_files{$flcf_types->{table}->{js_file}} =
                        $flcf_types->{table}->{js_order};
                    for my $column (@{$field_defs->{$cf}->{$field}->{columns}}) {
                        my $c_type = $column->{type};
                        my $js_file = $flcf_types->{$c_type}->{js_file};
                        if ($js_file) {
                            $js_files{$js_file} =
                                $flcf_types->{$c_type}->{js_order};
                        }
                    }
                }
                else {
                    my $js_file = $flcf_types->{$type}->{js_file};
                    if ($js_file) {
                        $js_files{$js_file} =
                            $flcf_types->{$type}->{js_order};
                    }
                }
            }
        }
    }
    my $html = '';
    my @js_files =  sort { $js_files{$a} <=> $js_files{$b} } keys %js_files;
    for my $js_file (@js_files) {
        $html .= <<HERE;
<script type="text/javascript" src="<mt:var name="static_uri">plugins/${js_file}.${js_ext}"></script>
HERE
    }
    $html .= <<HERE;
<script type="text/javascript" src="<mt:var name="static_uri">plugins/FLCFExtension/js/flcf_extension.${js_ext}"></script>
HERE
    return $html;
}

sub ext_css {
    my ($used_ctrls, $field_defs) = @_;
    my $app = MT->instance;

    my %css_files = ();
    $used_ctrls ||= {};
    $field_defs ||= {};
    my $css_ext = MT->config->DebugMode ? 'css' : 'min.css';
    my $flcf_types = $app->registry('flcf_types');
    for my $cf (keys %$used_ctrls) {
        for my $unit (keys %{$used_ctrls->{$cf}}) {
            for my $field (keys %{$used_ctrls->{$cf}->{$unit}}) {
                my $type = $field_defs->{$cf}->{$field}->{type};
                if ($type eq 'table') {
                    $css_files{$flcf_types->{table}->{css_file}} =
                        $flcf_types->{table}->{css_order};
                    for my $column (@{$field_defs->{$cf}->{$field}->{columns}}) {
                        my $c_type = $column->{type};
                        my $css_file = $flcf_types->{$c_type}->{css_file};
                        if ($css_file) {
                            $css_files{$css_file} =
                                $flcf_types->{$c_type}->{css_order};
                        }
                    }
                }
                else {
                    my $css_file = $flcf_types->{$type}->{css_file};
                    if ($css_file) {
                        $css_files{$css_file} =
                            $flcf_types->{$type}->{css_order};
                    }
                }
            }
        }
    }
    my $html = '';
    my @css_files =  sort { $css_files{$a} <=> $css_files{$b} } keys %css_files;
    for my $css_file (@css_files) {
        $html .= <<HERE;
<link rel="stylesheet" type="text/css" href="<mt:var name="static_uri">plugins/${css_file}.${css_ext}" />
HERE
    }
    $html .= <<HERE;
<link rel="stylesheet" type="text/css" href="<mt:var name="static_uri">plugins/FLCFExtension/css/flcf_extension.${css_ext}" />
HERE
    return $html;
}

sub _multiselect_set_options_sub {
    my ($type, $opt_g, $opts, $values) = @_;
    my $flcf_plugin = MT->component('FreeLayoutCustomField');

    if (scalar(@$opts)) {
        my $last_group = '';
        my $count = scalar(@$opts);
        for (my $opt_c = 0; $opt_c < $count; $opt_c++) {
            my $sel_value = $opts->[$opt_c]->{value};
            my $sel_label = $opts->[$opt_c]->{label}
                          ? $opts->[$opt_c]->{label}
                          : $opts->[$opt_c]->{value};
            if ($type eq 'multiselect_optgroup') {
                if ($opts->[$opt_c]->{group} &&
                    $opts->[$opt_c]->{group} ne $last_group) {
                    $opt_g->[$opt_c]->{group} = $opts->[$opt_c]->{group};
                    $opt_g->[$opt_c]->{group_first} = 1;
                    $last_group = $opts->[$opt_c]->{group};
                }
                if (
                    $opt_c == $count - 1
                    ||
                    (
                        defined($opts->[$opt_c + 1]->{group})
                        &&
                        (
                            !defined($opts->[$opt_c]->{group})
                            ||
                            $opts->[$opt_c]->{group} ne
                            $opts->[$opt_c + 1]->{group}
                        )
                    )
                ) {
                    $opt_g->[$opt_c]->{group_last} = 1;
                }
            }
            $opt_g->[$opt_c]->{value} = $sel_value;
            $opt_g->[$opt_c]->{label} = $sel_label;
            $opt_g->[$opt_c]->{selected} = $values->{$sel_value};
        }
    }
}

1;
