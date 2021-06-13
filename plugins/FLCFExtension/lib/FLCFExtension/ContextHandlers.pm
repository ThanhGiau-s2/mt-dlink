package FLCFExtension::ContextHandlers;

use strict;
use warnings;

use MT::Util qw( deep_copy );

sub out_richtext {
    my ($ctx, $args, $value) = @_;

    return $value;
}

sub flcf_table {
    my ($ctx, $args, $cond) = @_;

    my $app = MT->instance;
    my $f_plugin = MT->component('FreeLayoutCustomField');

    # load field value
    my $field_value = $ctx->stash('flcf_field_value');
    unless (defined($field_value)) {
        return $ctx->error($f_plugin->translate('Not in FreeLayoutCustomField block.'));
    }
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($f_plugin->translate('Please specify name modifier.'));
    }

    # check null
    my $rows = $field_value->{$name};
    my $flcf_def = $ctx->stash('flcf_def');
    $rows = [] if (!ref $rows);
    my $count  = scalar @$rows;
    my $is_null = 1;
    if ($count && !defined($rows->[0]->{flcf_row_is_null})) {
        require FLCFExtension::CMS;
        $is_null = FLCFExtension::CMS::table_check_null($rows, $flcf_def, $name);
    }
    else {
        for (my $i = 0; $i < $count; $i++) {
            if (!$rows->[$i]->{flcf_row_is_null}) {
                $is_null = 0;
                last;
            }
        }
    }
    if ($args->{skip_null}) {
        @$rows = grep { !$_->{flcf_row_is_null} } @$rows;
        $count = scalar @$rows;
    }

    # out rows
    my $builder    = $ctx->stash('builder');
    my $tokens     = $ctx->stash('tokens');
    my $res        = '';
    my $vars       = $ctx->{__stash}{vars} ||= {};
    my $i          = 0;
    my $glue       = $args->{glue} || '';
    my $table_def = $flcf_def->{fields}->{$name};
    my $pseudo_def = { fields => {} };
    for my $column (@{$table_def->{columns}}) {
        $pseudo_def->{fields}->{$column->{name}} = $column;
    }
    local $ctx->{__stash}{flcf_def_orig} = $ctx->stash('flcf_def');
    local $ctx->{__stash}{flcf_def} = $pseudo_def;
    my $fv_backup = $ctx->stash('flcf_field_value');
    if (!$is_null) {
        for (my $i = 0; $i < $count; $i++) {
            $ctx->stash('flcf_field_value', $rows->[$i]);
            local $vars->{__first__} = !$i;
            local $vars->{__last__} = ($i == $count - 1);
            local $vars->{__odd__} = ($i % 2 == 0);
            local $vars->{__even__} = ($i % 2 == 1);
            local $vars->{__counter__} = $i + 1;
            defined( my $out = $builder->build( $ctx, $tokens, $cond ) )
                or return $ctx->error( $builder->errstr );
            $res .= $out;
            $res .= $glue if ($i != $count - 1);
        }
    }
    else {
        $res = $ctx->else($args, $cond);
    }
    $ctx->stash('flcf_field_value', $fv_backup);
    return $res;
}

sub flcf_selected_options {
    my ($ctx, $args, $cond) = @_;

    my $app = MT->instance;
    my $f_plugin = MT->component('FreeLayoutCustomField');

    # load field def
    my $flcf_def = $ctx->stash('flcf_def');
    unless (defined($flcf_def)) {
        return $ctx->error($f_plugin->translate('Not in FreeLayoutCustomField block.'));
    }

    # check name
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($f_plugin->translate('Please specify name modifier.'));
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

    # find selected options
    my $options  = deep_copy($flcf_def->{fields}->{$name}->{options} || []);
    my $group = '';
    for my $option (@$options) {
        if (!$option->{label}) {
            $option->{label} = $option->{value};
        }
        if ($option->{group}) {
            $group = $option->{group};
        }
        else {
            $option->{group} = $group;
        }
        $option->{selected} = $value_h{$option->{value}};
    }
    $options = [ grep { $_->{selected} } @$options ];

    # out
    my $builder    = $ctx->stash('builder');
    my $tokens     = $ctx->stash('tokens');
    my $res        = '';
    my $vars       = $ctx->{__stash}{vars} ||= {};
    my $i          = 0;
    my $count      = scalar @$options;
    my $glue       = $args->{glue} || '';
    if ($count) {
        for my $option (@$options) {
            local $ctx->{__stash}{flcf_option_label} = $options->[$i]->{label};
            local $ctx->{__stash}{flcf_option_value} = $options->[$i]->{value};
            local $ctx->{__stash}{flcf_option_group} = $options->[$i]->{group};
            local $ctx->{__stash}{flcf_option_selected} = 1;
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

sub flcf_selected_option_count {
    my ($ctx, $args) = @_;
    my $f_plugin = MT->component('FreeLayoutCustomField');

    # check name
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($f_plugin->translate('Please specify name modifier.'));
    }
    my $field_values = $ctx->stash('flcf_field_value');
    my $field_value = $field_values->{$name};
    if (ref $field_value eq 'ARRAY') {
        return scalar(@$field_value);
    }
    else {
        return $field_value ? 1 : 0;
    }
}

1;
