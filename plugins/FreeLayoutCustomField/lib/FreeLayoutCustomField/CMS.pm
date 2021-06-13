package FreeLayoutCustomField::CMS;

use strict;
use warnings;
use MT::Template;
use MT::Template::Context;
use MT::Util qw( encode_html encode_js remove_html deep_copy );
use MT::Util::YAML;
use FLCFCommon::Util qw( load_asset_types check_null validate_fields );
use FLCFCommon::CMS qw( field_html_params_common );
use JSON;

sub field_html_params {
    my ($key, $tmpl_key, $tmpl_param) = @_;
    my $app = MT->instance;

    return field_html_params_common($app, $tmpl_param);
}

sub save_filter_entry {
    save_filter( 'entry', @_ );
}

sub save_filter_page {
    save_filter( 'page', @_ );
}

sub save_filter_category {
    save_filter( 'category', @_ );
}

sub save_filter_folder {
    save_filter( 'folder', @_ );
}

sub save_filter_asset {
    save_filter( 'asset', @_ );
}

sub save_filter_comment {
    save_filter( 'comment', @_ );
}

sub save_filter_template {
    save_filter( 'template', @_ );
}

sub save_filter_blog {
    save_filter( 'blog', @_ );
}

sub save_filter_website {
    save_filter( 'website', @_ );
}

sub save_filter_author {
    save_filter( 'author', @_ );
}

sub save_filter {
    my ( $obj_type, $eh, $app ) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');

    my $q = $app->param;
    return 1 if !$q->param('customfield_beacon');

    my $blog_id = $q->param('blog_id') || 0;
    $obj_type = 'website'
        if $obj_type eq 'blog' && $app->blog && !$app->blog->is_blog;

    # load flcf customfields
    my $iter = MT->model('field')->load_iter(
        {
            $blog_id ? ( blog_id => [ $blog_id, 0 ] ) : (),
            $obj_type eq 'asset'
            ? ( obj_type => $q->param('asset_type') )
            : ( obj_type => $obj_type ),
            type => 'flcf',
        }
    );

    # load used / unused ctrls
    my $unused_ctrls = from_json($app->param('flcf_unused_ctrls') || '{}');
    my $used_ctrls = from_json($app->param('flcf_used_ctrls') || '{}');

    # check required and valid date
    my $cfs = {};
    my @errors = ();
    my $flcf_types = $app->registry('flcf_types');
    while (my $field = $iter->()) {
        validate_fields($app, $blog_id, 'customfield', $field, $used_ctrls, $unused_ctrls, $cfs, \@errors);
=for comment
        my $field_name = "customfield_" . $field->basename;
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
                        $code->($field->name, $f_name, $value->{$f_name}, $flcf_def, $ug, $num, \@errors);
                    }
                    elsif ($value->{$f_name} eq '' || !defined($value->{$f_name})) {
                        if ($flcf_def->{options}->{multiple}) {
                            push @errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4] of customfield [_3] is required.',
                                $field_def->{$f_name}->{label}, $num, $field->name, $ug
                            );
                        }
                        else {
                            push @errors, $plugin->translate(
                                'Field [_1] of customfield [_2] is required.',
                                $field_def->{$f_name}->{label}, $field->name
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
                                push @errors, $plugin->translate(
                                    'Field [_1] in [_3] [_2] [_4] of customfield [_3] [_5].',
                                    $field_def->{$f_name}->{label}, $num, $field->name, $ug, $pattern_errmsg
                                );
                            }
                            else {
                                push @errors, $plugin->translate(
                                    'Field [_1] of customfield [_2] [_3].',
                                    $field_def->{$f_name}->{label}, $field->name, $pattern_errmsg
                                );
                            }
                        }
                    }
                    my $maxlength = $field_def->{$f_name}->{maxlength};
                    if (defined($maxlength) && $value->{$f_name} ne '') {
                        if (length($value->{$f_name}) > $maxlength) {
                            if ($flcf_def->{options}->{multiple}) {
                                push @errors, $plugin->translate(
                                    'Field [_1] in [_3] [_2] [_4] of customfield must be shorter than [_5] character(s) string.',
                                    $field_def->{$f_name}->{label}, $num, $field->name, $ug, $maxlength
                                );
                            }
                            else {
                                push @errors, $plugin->translate(
                                    'Field [_1] of customfield [_2] must be shorter than [_3] character(s) string.',
                                    $field_def->{$f_name}->{label}, $field->name, $maxlength
                                );
                            }
                        }
                    }
                    my $minlength = $field_def->{$f_name}->{minlength};
                    if (defined($minlength) && $value->{$f_name} ne '') {
                        if (length($value->{$f_name}) < $minlength) {
                            if ($flcf_def->{options}->{multiple}) {
                                push @errors, $plugin->translate(
                                    'Field [_1] in [_3] [_2] [_4] of customfield must be longer than [_5] character(s) string.',
                                    $field_def->{$f_name}->{label}, $num, $field->name, $ug, $minlength
                                );
                            }
                            else {
                                push @errors, $plugin->translate(
                                    'Field [_1] of customfield [_2] must be longer than [_3] character(s) string.',
                                    $field_def->{$f_name}->{label}, $field->name, $minlength
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
                                push @errors, $plugin->translate(
                                    'Field [_1] in [_3] [_2] [_4] of customfield [_3] must be greater or equal than [_5].',
                                    $field_def->{$f_name}->{label}, $num, $field->name, $ug, $min
                                );
                            }
                            else {
                                push @errors, $plugin->translate(
                                    'Field [_1] of customfield [_2] must be greater or equal than [_3].',
                                    $field_def->{$f_name}->{label}, $field->name, $min
                                );
                            }
                        }
                    }
                    my $max = $field_def->{$f_name}->{max};
                    if (defined($max) && $value->{$f_name} ne '') {
                        if ($value->{$f_name} > $max) {
                            if ($flcf_def->{options}->{multiple}) {
                                push @errors, $plugin->translate(
                                    'Field [_1] in [_3] [_2] [_4] of customfield [_3] must be smaller or equal than [_5].',
                                    $field_def->{$f_name}->{label}, $num, $field->name, $ug, $max
                                );
                            }
                            else {
                                push @errors, $plugin->translate(
                                    'Field [_1] of customfield [_2] must be smaller or equal than [_3].',
                                    $field_def->{$f_name}->{label}, $field->name, $max
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
                            push @errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4] of customfield [_3] must be [_5] interval from [_6].',
                                $field_def->{$f_name}->{label}, $num, $field->name, $ug, $step, $min
                            );
                        }
                        else {
                            push @errors, $plugin->translate(
                                'Field [_1] of customfield [_2] must [_3] be interval from [_4].',
                                $field_def->{$f_name}->{label}, $field->name, $step, $min
                            );
                        }
                    }

                }
                if ($type eq 'datetime' || $type eq 'date' || $type eq 'time') {
                    my $c_val = $value->{$f_name};
                    if ($c_val =~ /error/) {
                        if ($flcf_def->{options}->{multiple}) {
                            push @errors, $plugin->translate(
                                'Field [_1] in [_3] [_2] [_4]of customfield [_3] has invalid format.',
                                $field_def->{$f_name}->{label}, $num, $field->name, $ug
                            );
                        }
                        else {
                            push @errors, $plugin->translate(
                                'Field [_1] of customfield [_2] has invalid format.',
                                $field_def->{$f_name}->{label}, $field->name
                            );
                        }
                    }
                }
                elsif ($flcf_types->{$type}->{validator}) {
                    my $code =  $flcf_types->{$type}->{validator};
                    $code->($field->name, $f_name, $value->{$f_name}, $flcf_def, $ug, $num, \@errors);
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
                push @errors, @v_errors;
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
        };
=cut
    }

    # if error then return error message
    my $req = MT->request;
    my $err_count = scalar @errors;
    if ($err_count) {
        $req->stash('FreeLayoutCustomField::EntryFilterError', 1);
        if ($err_count == 1) {
            return $eh->error($errors[0]);
        }
        else {
            my $errmsg = join('<br />', @errors);
            return $eh->error($errmsg);
        }
    }
    else {
        $req->stash('FreeLayoutCustomField::EntryFilterError', undef);
    }
    $req->stash('FreeLayoutCustomField::CFInfo', $cfs);
    return 1;
}

sub pre_save_entry {
    pre_save( 'entry', @_ );
}

sub pre_save_page {
    pre_save( 'page', @_ );
}

sub pre_save_category {
    pre_save( 'category', @_ );
}

sub pre_save_folder {
    pre_save( 'folder', @_ );
}

sub pre_save_asset {
    pre_save( 'asset', @_ );
}

sub pre_save_comment {
    pre_save( 'comment', @_ );
}

sub pre_save_template {
    pre_save( 'template', @_ );
}

sub pre_save_blog {
    pre_save( 'blog', @_ );
}

sub pre_save_website {
    pre_save( 'website', @_ );
}

sub pre_save_author {
    pre_save( 'author', @_ );
}

sub pre_save {
    my ($obj_type, $eh, $app, $obj) = @_;

    my $req = MT->request;
    my $cfs = $req->stash('FreeLayoutCustomField::CFInfo');
    for my $field_name (keys %$cfs) {
        my $field_values;
        eval {
            $field_values = from_json($app->param($field_name) || '[]');
        };
        $field_values = [] if ($@);
        my $flcf_def = $cfs->{$field_name}->{flcf_def};
        my $used_ctrls = $cfs->{$field_name}->{used_ctrls};
        check_null($obj, $field_values, $flcf_def, $used_ctrls);
        $app->param($field_name, to_json($field_values));
    }
    return 1;
}

1;
