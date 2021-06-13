package FLCFCommon::Util;

use strict;
use warnings;
use base qw( Exporter );

use MT::Util::YAML;
use MT::Template::Context;
use JSON;

our @EXPORT_OK = qw(
    load_asset_types check_used_ctrls check_null validate_fields
);

sub load_asset_types {
    require MT::Asset;
    my $asset_types_org = MT::Asset->class_labels;
    my %asset_types;
    for my $asset_type (keys %$asset_types_org) {
        if ($asset_type =~ /^asset\.(\w+)/) {
            $asset_types{$1} = 1;
        }
        else {
            $asset_types{$asset_type} = 1;
        }
    }
    return %asset_types;
}

sub check_used_ctrls {
    my $field = shift;
    my $no_die = shift;
    my $plugin = MT->component('FLCFCommon');

    my $flcf_def;
    eval {
        $flcf_def = MT::Util::YAML::Load($field->flcf_def);
    };
    if ($@) {
        if ($no_die) {
        }
        else {
            if ($field->id) {
                die $plugin->translate('[_1] Field (ID = [_2]) definition YAML parse error. [_3]', $field->name, $field->id, $@);
            }
            else {
                die $plugin->translate('[_1] Field definition YAML parse error. [_2]', $field->name, $@);
            }
        }
    }
    my $field_units = $flcf_def->{units};

    # split units
    my $unit_htmls = {};
    if (defined($field_units)) {
        my @lines = split /\r?\n/, $field->flcf_html;
        my $unit_name = '';
        for my $line (@lines) {
            if ($line =~ /<\!--\s*?\{\{unit\s*?:\s*?([^-]*?)\}\}\s*?-->/) {
                $unit_name = $1;
            }
            elsif ($unit_name) {
                $unit_htmls->{$unit_name} .= $line;
            }
        }
    }
    else {
        $unit_htmls->{main} = $field->flcf_html;
    }

    my $unused_ctrls = {};
    my $used_ctrls = {};
    for my $unit_name (keys %$unit_htmls) {
        my (%ctrls, %u_ctrls);
        map { $ctrls{$_} = 1 } keys %{$flcf_def->{fields}};
        for my $ctrl (keys %ctrls) {
            if ($unit_htmls->{$unit_name} =~ /\{\{$ctrl\}\}/) {
                delete $ctrls{$ctrl};
                $u_ctrls{$ctrl} = 1;
            }
        }
        $unused_ctrls->{$unit_name} = \%ctrls;
        $used_ctrls->{$unit_name} = \%u_ctrls;
    }
    $field->flcf_used_ctrls(to_json($used_ctrls));
    $field->flcf_unused_ctrls(to_json($unused_ctrls));
}

sub check_null {
    my ($obj, $field_values, $flcf_def, $used_ctrls) = @_;

    my $flcf_types = MT->registry('flcf_types');
    my $row_count = scalar(@$field_values);
    my $is_null = 1;

    for (my $i = 0; $i < $row_count; $i++) {
        my $field_value = $field_values->[$i];
        my $unit_name = $field_value->{flcf_unit_name};
        my $row_is_null = 1;
        for my $field_name (keys %$field_value) {
            next if ($field_name eq 'flcf_unit_name' ||
                     $field_name eq 'flcf_row_is_null');
            next if ($unit_name && !$used_ctrls->{$unit_name}->{$field_name});
            my $type = $flcf_def->{fields}->{$field_name}->{type};
            my $code = $flcf_types->{$type}->{check_null};
            if ($code) {
                $row_is_null = $code->($field_value->{$field_name}, $flcf_def, $field_name);
            }
            else {
                $row_is_null = ($field_value->{$field_name} eq '');
            }
            last if (!$row_is_null);
        }
        $field_value->{flcf_row_is_null} = $row_is_null;
        if (!$row_is_null) {
            $is_null = 0;
        }
    }
    return $is_null;
}

sub validate_fields {
    my ($app, $blog_id, $cf_type, $field, $used_ctrls, $unused_ctrls, $cfs, $errors) = @_;
    my $plugin = MT->component('FLCFCommon');

    my $flcf_types = $app->registry('flcf_types');
    my $cf_type_label = $plugin->translate($cf_type);

    my $field_name;
    if ($cf_type eq 'customfield') {
        $field_name = "customfield_" . $field->basename;
    }
    elsif ($cf_type eq 'contentfield') {
        $field_name = "content-field-" . $field->id;
    }
    my $flcf_def_str = $field->flcf_def;
    my ($flcf_def, $field_def, $field_units);
    eval {
        $flcf_def = MT::Util::YAML::Load($flcf_def_str) || {};
    };
    $field_def = $flcf_def->{fields} || {};
    $field_units = $flcf_def->{units} || {};
    my %field_units;
    for my $field_unit (@{$field_units->{names}}) {
        if (ref $field_unit->{required} eq 'ARRAY') {
            my @required_fields = @{$field_unit->{required}};
            $field_unit->{required} = {};
            map { $field_unit->{required}->{$_} = 1 } @required_fields;
        }
        $field_units{$field_unit->{name}} = $field_unit;
    }
    my $values;
    eval {
        $values = from_json($app->param($field_name) || '[]');
    };
    $values = [] if ($@);
    my $num = 1;
    for my $value (@$values) {
        my $unit_name = $value->{flcf_unit_name} || '';
        my $ug = $plugin->translate($unit_name ? 'unit' : 'group');
        for my $f_name (keys %$field_def) {
            next if ($unit_name && $unused_ctrls->{$field_name}->{$unit_name}->{$f_name});
            my $type = $field_def->{$f_name}->{type};
            if ($field_def->{$f_name}->{required} ||
                $flcf_types->{$type}->{always_filter} ||
                $field_units{$unit_name}->{required}->{$f_name}) {
                if ($flcf_types->{$type}->{null_filter}) {
                    my $code =  $flcf_types->{$type}->{null_filter};
                    $code->($field->name, $f_name, $value->{$f_name}, $flcf_def, $ug, $num, $errors);
                }
                elsif ($value->{$f_name} eq '' || !defined($value->{$f_name})) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] in [_3] [_2] [_4] of [_5] [_3] is required.',
                            $field_def->{$f_name}->{label}, $num, $field->name, $ug, $cf_type_label
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Field [_1] of [_3] [_2] is required.',
                            $field_def->{$f_name}->{label}, $field->name, $cf_type_label
                        );
                    }
                }
            }
            if ($type eq 'text') {
                my $pattern = $field_def->{$f_name}->{pattern};
                if (defined($pattern) && $value->{$f_name} ne '' && $type eq 'text') {
                    $pattern = "^${pattern}\$";
                    if ($value->{$f_name} !~ /$pattern/) {
                        my $pattern_errmsg =
                            $field_def->{$f_name}->{pattern_errmsg} ||
                            $plugin->translate('has illegal format');
                        if ($flcf_def->{options}->{multiple}) {
                            push @$errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4] of [_6] [_3] [_5].',
                                $field_def->{$f_name}->{label}, $num, $field->name,
                                $ug, $pattern_errmsg, $cf_type_label
                            );
                        }
                        else {
                            push @$errors, $plugin->translate(
                                'Field [_1] of [_4] [_2] [_3].',
                                $field_def->{$f_name}->{label}, $field->name,
                                $pattern_errmsg, $cf_type_label
                            );
                        }
                    }
                }
                my $maxlength = $field_def->{$f_name}->{maxlength};
                if (defined($maxlength) && $value->{$f_name} ne '') {
                    if (length($value->{$f_name}) > $maxlength) {
                        if ($flcf_def->{options}->{multiple}) {
                            push @$errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4] of [_6] must be shorter than [_5] character(s) string.',
                                $field_def->{$f_name}->{label}, $num, $field->name,
                                $ug, $maxlength, $cf_type_label
                            );
                        }
                        else {
                            push @$errors, $plugin->translate(
                                'Field [_1] of [_4] [_2] must be shorter than [_3] character(s) string.',
                                $field_def->{$f_name}->{label}, $field->name,
                                $maxlength, $cf_type_label
                            );
                        }
                    }
                }
                my $minlength = $field_def->{$f_name}->{minlength};
                if (defined($minlength) && $value->{$f_name} ne '') {
                    if (length($value->{$f_name}) < $minlength) {
                        if ($flcf_def->{options}->{multiple}) {
                            push @$errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4] of [_6] must be longer than [_5] character(s) string.',
                                $field_def->{$f_name}->{label}, $num, $field->name,
                                $ug, $minlength, $cf_type_label
                            );
                        }
                        else {
                            push @$errors, $plugin->translate(
                                'Field [_1] of [_4] [_2] must be longer than [_3] character(s) string.',
                                $field_def->{$f_name}->{label}, $field->name,
                                $minlength, $cf_type_label
                            );
                        }
                    }
                }
            }
            if ($type eq 'number' || $type eq 'range') {
                my $min = $field_def->{$f_name}->{min};
                if (defined($min) && $value->{$f_name} ne '') {
                    if ($value->{$f_name} < $min) {
                        if ($flcf_def->{options}->{multiple}) {
                            push @$errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4] of [_6] [_3] must be greater or equal than [_5].',
                                $field_def->{$f_name}->{label}, $num, $field->name,
                                $ug, $min, $cf_type_label
                            );
                        }
                        else {
                            push @$errors, $plugin->translate(
                                'Field [_1] of [_4] [_2] must be greater or equal than [_3].',
                                $field_def->{$f_name}->{label}, $field->name,
                                $min, $cf_type_label
                            );
                        }
                    }
                }
                my $max = $field_def->{$f_name}->{max};
                if (defined($max) && $value->{$f_name} ne '') {
                    if ($value->{$f_name} > $max) {
                        if ($flcf_def->{options}->{multiple}) {
                            push @$errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4] of [_6] [_3] must be smaller or equal than [_5].',
                                $field_def->{$f_name}->{label}, $num, $field->name,
                                $ug, $max, $cf_type_label
                            );
                        }
                        else {
                            push @$errors, $plugin->translate(
                                'Field [_1] of [_4] [_2] must be smaller or equal than [_3].',
                                $field_def->{$f_name}->{label}, $field->name,
                                $max, $cf_type_label
                            );
                        }
                    }
                }
                my $step = $field_def->{$f_name}->{step} || 1;
                $min = 0 if (!defined($min));
                my $v = $value->{$f_name} - $min;
                my $d = int($v / $step);
                if (defined($step) && $value->{$f_name} ne '' &&
                    $v - $step * $d != 0) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] in [_3] [_2] [_4] of [_7] [_3] must be [_5] interval from [_6].',
                            $field_def->{$f_name}->{label}, $num, $field->name,
                            $ug, $step, $min, $cf_type_label
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Field [_1] of [_5] [_2] must [_3] be interval from [_4].',
                            $field_def->{$f_name}->{label}, $field->name,
                            $step, $min, $cf_type_label
                        );
                    }
                }

            }
            if ($type eq 'datetime' || $type eq 'date' || $type eq 'time') {
                my $c_val = $value->{$f_name};
                if ($c_val =~ /error/) {
                    if ($flcf_def->{options}->{multiple}) {
                        push @$errors, $plugin->translate(
                            'Field [_1] in [_3] [_2] [_4] of [_5] [_3] has invalid format.',
                            $field_def->{$f_name}->{label}, $num, $field->name,
                            $ug, $cf_type_label
                        );
                    }
                    else {
                        push @$errors, $plugin->translate(
                            'Field [_1] of [_3] [_2] has invalid format.',
                            $field_def->{$f_name}->{label}, $field->name, $cf_type_label
                        );
                    }
                }
            }
            elsif ($flcf_types->{$type}->{validator}) {
                my $code =  $flcf_types->{$type}->{validator};
                $code->($field->name, $f_name, $value->{$f_name}, $flcf_def, $ug, $num, $errors);
            }
        }
        $num++;
    }

    # custom validator
    if ($field->flcf_validator) {
        my $tmpl = MT->model('template')->new;
        $tmpl->text($field->flcf_validator);
        my $ctx = MT::Template::Context->new;
        if ($blog_id) {
            my $blog = MT->model('blog')->load($blog_id);
            $ctx->{__stash}{blog} = $blog;
            $ctx->{__stash}{blog_id} = $blog_id;
        }
        $ctx->{__stash}{field} = $field;
        $ctx->{__stash}{flcf_field_values} = $values;
        $ctx->{__stash}{flcf_field_count} = scalar @$values;
        $ctx->{__stash}{flcf_def} = $flcf_def;
        my @v_errors = ();
        $ctx->{__stash}{flcf_errors} = \@v_errors;
        $tmpl->context($ctx);
        my $out = $tmpl->build($ctx, {});
        if (!defined($out)) {
            die $tmpl->errstr;
        }
        if (scalar(@v_errors)) {
            push @$errors, @v_errors;
        }
        $app->param($field_name, to_json($values));
    }

    # buffer field info for pre_save
    $cfs->{$field_name} = {
        flcf_def => $flcf_def,
        field_def => $field_def,
        field_units => $field_units,
        used_ctrls => $used_ctrls->{$field_name},
        unused_ctrls => $unused_ctrls->{$field_name},
        values => $values
    };
}

1;
