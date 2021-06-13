package FLCFCommon::ContextHandlers;

use strict;
use warnings;
use base qw( Exporter );

use MT::Util qw( html_text_transform trim );
use FLCFCommon::Util qw( load_asset_types check_null );

our @EXPORT_OK = qw( flcf_block_common );

sub flcf_block_common {
    my ($ctx, $args, $cond, $field_values, $flcf_def, $used_ctrls) = @_;

    # check null values
    my $is_null = 1;
    my $row_count = scalar(@$field_values);
    if ($row_count && !defined($field_values->[0]->{flcf_row_is_null})) {
        $is_null = check_null(undef, $field_values, $flcf_def, $used_ctrls);
    }
    else {
        for (my $i = 0; $i < $row_count; $i++) {
            my $field_value = $field_values->[$i];
            if (!$field_value->{flcf_row_is_null}) {
                $is_null = 0;
                last;
            }
        }
    }

    return $ctx->else($args, $cond) if ($is_null);

    if ($args->{skip_null}) {
        @$field_values = [ grep { !$_->{flcf_row_is_null} } @$field_values ];
    }

    # out values
    my $builder    = $ctx->stash('builder');
    my $tokens     = $ctx->stash('tokens');
    my $res        = '';
    my $vars       = $ctx->{__stash}{vars} ||= {};
    my $i          = 0;
    my $glue       = $args->{glue} || '';
    my $old_unit   = '';
    my $unit_count = 0;
    my ($unit_first, $unit_last);
    if ($row_count) {
        local $ctx->{__stash}{flcf_field_count} = $row_count;
        for my $field_value (@$field_values) {
            if ($field_value->{flcf_unit_name}) {
                if ($field_value->{flcf_unit_name} ne $old_unit) {
                    $old_unit = $field_value->{flcf_unit_name};
                    $unit_count = 0;
                    $unit_first = 1;
                }
                else {
                    $unit_first = 0;
                }
                my $next_unit;
                if ($i < $row_count - 1) {
                    $next_unit = $field_values->[$i + 1]->{flcf_unit_name};
                    $unit_last = ($next_unit ne $old_unit) ? 1 : 0;
                }
                else {
                    $unit_last = 1;
                }
            }
            local $ctx->{__stash}{flcf_field_value} = $field_value;
            local $ctx->{__stash}{flcf_def} = $flcf_def;
            local $vars->{__first__} = !$i;
            local $vars->{__last__} = ($i == $row_count - 1);
            local $vars->{__unit_first__} = $unit_first;
            local $vars->{__unit_last__} = $unit_last;
            local $vars->{__odd__} = ($i % 2 == 0);
            local $vars->{__even__} = ($i % 2 == 1);
            local $vars->{__unit_odd__} = ($unit_count % 2 == 0) ? 1 : 0;
            local $vars->{__unit_even__} = ($unit_count % 2 == 1) ? 1 : 0;
            local $vars->{__unit_counter__} = $unit_count + 1;
            local $vars->{__counter__} = $i + 1;
            local $vars->{__unit__} = $field_value->{flcf_unit_name};
            local $vars->{__is_null__} = $field_value->{flcf_row_is_null};
            defined( my $out = $builder->build( $ctx, $tokens, $cond ) )
                or return $ctx->error( $builder->errstr );
            $res .= $out;
            $res .= $glue if ($i != $row_count - 1);
            $i++;
            $unit_count++;
        }
        return $res;
    }
}

sub flcf_value {
    my ($ctx, $args, $cond) = @_;
    my $app = MT->instance;
    my $plugin = MT->component('FLCFCommon');

    # load field value
    my $field_value = $ctx->stash('flcf_field_value');
    unless (defined($field_value)) {
        return $ctx->error($plugin->translate('Not in FreeLayoutCustomField / FreeLayoutContentField block.'));
    }
    my $name;
    if (lc $ctx->stash('tag') eq 'flcfunitname') {
        $name = 'flcf_unit_name';
    }
    else {
        $name = $args->{name} || $args->{field};
    }
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }

    # out field value
    my $tag = lc $ctx->stash('tag');
    if ($tag eq 'flcfrawvalue' || $tag eq 'flcfunitname') {
        return $field_value->{$name} || '';
    }
    else {
        my %asset_types = load_asset_types();
        my $flcf_types = $app->registry('flcf_types');
        my $flcf_def = $ctx->stash('flcf_def');
        my $type = $flcf_def->{fields}->{$name}->{type} || 'text';
        my $meth = $flcf_types->{$type}->{tmpl_output} ||
                   $flcf_def->{fields}->{$name}->{tmpl_output} || '';
        if ($meth) {
            $meth = $app->handler_to_coderef($meth);
            return $meth->($ctx, $args, $field_value->{$name}) || '';
        }
        elsif ($type eq 'textarea') {
            return html_text_transform($field_value->{$name} || '');
        }
        elsif ($type eq 'datetime' || $type eq 'date' || $type eq 'time') {
            $args->{ts} = $field_value->{$name} || '';
            return $args->{ts} ? $ctx->_hdlr_date($args) : '';
        }
        elsif ($asset_types{$type} && lc $ctx->stash('tag') eq 'flcfasset') {
#            my $asset = MT->model('asset')->load($field_value->{$name});
            my $val = $field_value->{$name};
            my $asset = defined($val) && $val
                      ? MT->model('asset')->load($field_value->{$name})
                      : undef;
            if ($asset) {
                my $builder = $ctx->stash('builder');
                my $tokens  = $ctx->stash('tokens');
                local $ctx->{__stash}{asset} = $asset;
                defined( my $res = $builder->build( $ctx, $tokens, $cond ) )
                    or return $ctx->error( $builder->errstr );
                return $res;
            }
            else {
                return $ctx->else($args, $cond);
            }
        }
        else {
            return defined($field_value->{$name}) ? $field_value->{$name} : '';
        }
    }
}

sub flcf_type {
    my ($ctx, $args, $cond) = @_;
    my $app = MT->instance;
    my $plugin = MT->component('FLCFCommon');

    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }
    my $flcf_def = $ctx->stash('flcf_def');
    my $type = $flcf_def->{fields}->{$name}->{type} || 'text';
    return $type;
}

sub flcf_count {
    my ($ctx, $args, $cond) = @_;

    return $ctx->stash('flcf_field_count') || '0';
}

sub flcf_options {
    my ($ctx, $args, $cond) = @_;

    my $app = MT->instance;
    my $plugin = MT->component('FLCFCommon');

    # load field def
    my $flcf_def = $ctx->stash('flcf_def');
    unless (defined($flcf_def)) {
        return $ctx->error($plugin->translate('Not in FreeLayoutCustomField / FreeLayoutContentField block.'));
    }

    # check name
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }

    # load field options
    my $field_values = $ctx->stash('flcf_field_value');
    my $field_value = $field_values->{$name};
    my %value_h;
    if (ref $field_value eq 'ARRAY') {
        map { $value_h{$_} = 1 } @$field_value;
    }
    else {
        $value_h{$field_value} = 1;
    }
    my $options    = $flcf_def->{fields}->{$name}->{options} || [];
    my $builder    = $ctx->stash('builder');
    my $tokens     = $ctx->stash('tokens');
    my $res        = '';
    my $vars       = $ctx->{__stash}{vars} ||= {};
    my $i          = 0;
    my $count      = scalar @$options;
    my $glue       = $args->{glue} || '';
    if ($count) {
        my $group = '';
        for my $option (@$options) {
            my $value = $options->[$i]->{value};
            my $label = $options->[$i]->{label} ?
                        $options->[$i]->{label} : $value;
            $group = $options->[$i]->{group}
                if ($options->[$i]->{group});
            local $ctx->{__stash}{flcf_option_label} = $label;
            local $ctx->{__stash}{flcf_option_value} = $value;
            local $ctx->{__stash}{flcf_option_group} = $group;
            local $ctx->{__stash}{flcf_option_selected} = $value_h{$value};
            local $vars->{__first__} = !$i;
            local $vars->{__last__} = ($i == $count - 1);
            local $vars->{__odd__} = ($i % 2 == 0);
            local $vars->{__even__} = ($i % 2 == 1);
            local $vars->{__counter__} = $i + 1;
            defined( my $out = $builder->build( $ctx, $tokens, $cond ) )
                or return $ctx->error( $builder->errstr );
            $res .= $out;
            $res .= $glue if ($i != $count - 1);
            $i++;
        }
        return $res;
    }
    else {
        return $ctx->else($args, $cond);
    }
}

sub flcf_option_label {
    my ($ctx, $args) = @_;

    my $app = MT->instance;
    my $plugin = MT->component('FLCFCommon');

    # out pre defined label
    my $label = $ctx->stash('flcf_option_label');
    return $label if (defined($label));

    # load field value
    my $field_value = $ctx->stash('flcf_field_value');
    unless (defined($field_value)) {
        return $ctx->error($plugin->translate('Not in FreeLayoutCustomField / FreeLayoutContentField block.'));
    }
    my $flcf_def = $ctx->stash('flcf_def');
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }
    my $options = $flcf_def->{fields}->{$name}->{options} || [];
    for my $option (@$options) {
        if (defined($option->{value}) &&
            defined($field_value->{$name}) &&
            $option->{value} eq $field_value->{$name}) {
            return $option->{label} ? $option->{label} : $option->{value};
        }
    }
    return '';
}

sub flcf_option_value {
    my ($ctx, $args) = @_;

    return $ctx->stash('flcf_option_value') || '';
}

sub flcf_option_group {
    my ($ctx, $args) = @_;

    return $ctx->stash('flcf_option_group') || '';
}

sub flcf_option_count {
    my ($ctx, $args) = @_;
    my $plugin = MT->component('FLCFCommon');

    # load field def
    my $flcf_def = $ctx->stash('flcf_def');
    unless (defined($flcf_def)) {
        return $ctx->error($plugin->translate('Not in FreeLayoutCustomField / FreeLayoutContentField block.'));
    }

    # check name
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }
    my $options = $flcf_def->{fields}->{$name}->{options};
    return ref($options) eq 'ARRAY' ? scalar(@$options) : 0;
}

sub flcf_if_option_selected {
    my ($ctx, $args, $cond) = @_;

    if ($ctx->stash('flcf_option_selected')) {
        return $ctx->slurp($args, $args);
    }
    else {
        return $ctx->else($args, $cond);
    }
}

sub flcf_if_unit_name {
    my ($ctx, $args, $cond) = @_;
    my $app = MT->instance;
    my $plugin = MT->component('FLCFCommon');

    # load field value
    my $field_value = $ctx->stash('flcf_field_value');
    unless (defined($field_value)) {
        return $ctx->error($plugin->translate('Not in FreeLayoutCustomField / FreeLayoutContentField block.'));
    }

    # name modifier
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }
    if ($field_value->{flcf_unit_name} eq $name) {
        return $ctx->slurp($args, $cond);
    }
    else {
        return $ctx->else($args, $cond);
    }
}

sub flcf_validate {
    my ($ctx, $args, $cond) = @_;
    my $plugin = MT->component('FLCFCommon');

    # load field values
    my $field_values = $ctx->stash('flcf_field_values');
    unless (defined($field_values)) {
        return $ctx->error($plugin->translate('Can\'t use FLCFValidate tag in general template.'));
    }
    
    # check values
    my $builder    = $ctx->stash('builder');
    my $tokens     = $ctx->stash('tokens');
    my $res        = '';
    my $vars       = $ctx->{__stash}{vars} ||= {};
    my $i          = 0;
    my $count      = scalar @$field_values;
    if ($count) {
        for my $field_value (@$field_values) {
            $ctx->stash('flcf_field_value', $field_value);
            local $vars->{__first__} = !$i;
            local $vars->{__last__} = ($i == $count - 1);
            local $vars->{__odd__} = ($i % 2 == 0);
            local $vars->{__even__} = ($i % 2 == 1);
            local $vars->{__counter__} = $i + 1;
            local $vars->{__unit__} = $field_value->{flcf_unit_name};
            defined( my $out = $builder->build( $ctx, $tokens, $cond ) )
                or return $ctx->error( $builder->errstr );
            $res .= $out;
            $i++;
        }
    }
    return $res;
}

sub flcf_if_value {
    my ($ctx, $args, $cond) = @_;
    my $plugin = MT->component('FLCFCommon');

    # load field value
    my $field_value = $ctx->stash('flcf_field_value');
    unless (defined($field_value)) {
        return $ctx->error($plugin->translate('Not in FreeLayoutCustomField / FreeLayoutContentField block.'));
    }

    # get name modifier
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }

    # check value
    my $value = $field_value->{$name};
    my $vars = $ctx->{__stash}{vars} ||= {};
    local $vars->{__flcf_if_value} = $value;
    $args->{name} = '__flcf_if_value';
    my $r = $ctx->tag('if', $args, $cond);
    if (lc $ctx->stash('tag') eq 'flcfifvalue') {
        return $r ? $ctx->slurp($args, $cond) : $ctx->else($args, $cond);
    }
    else {
        return !$r ? $ctx->slurp($args, $cond) : $ctx->else($args, $cond);
    }
}

sub flcf_validate_error {
    my ($ctx, $args, $cond) = @_;
    my $plugin = MT->component('FLCFCommon');

    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');
    my $out = $builder->build($ctx, $tokens, $cond);
    return $ctx->error($builder->errstr)
        unless(defined($out));
    my $errors = $ctx->stash('flcf_errors');
    push @$errors, trim($out);
    return '';
}

sub flcf_set_value {
    my ($ctx, $args, $cond) = @_;
    my $plugin = MT->component('FLCFCommon');

    if (!$ctx->stash('flcf_field_values')) {
        return $ctx->error($plugin->translate('Can\'t use FLCFSetValue tag in general template.'));
    }

    my $field_value = $ctx->stash('flcf_field_value');
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');
    my $value = $builder->build($ctx, $tokens, $cond);
    return $ctx->error($builder->errstr)
        unless(defined($value));
    $field_value->{$name} = $value;
    return '';
}

1;
