package FreeLayoutCustomField::ContextHandlers;

use strict;
use warnings;

use MT::Util qw( html_text_transform trim );
use MT::Util::YAML;
use CustomFields::Template::ContextHandlers;
use CustomFields::Util qw( get_meta load_meta_to_cache );
use FLCFCommon::Util qw( load_asset_types check_null );
use FLCFCommon::ContextHandlers qw( flcf_block_common );
use JSON;

sub install_tags {
    my ($cb, $app) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');

    my $reg = $plugin->registry();
    my $tags = $reg->{tags};
    $tags->{block} ||= {};

    # load fields
    my @fields = MT->model('field')->load({
        type => 'flcf'
    });

    # add tags
    my %fields_by_tag;
    for my $field (@fields) {
        my $tag = lc $field->tag;
        $fields_by_tag{$tag} ||= {};
        $fields_by_tag{$tag}->{$field->blog_id} = $field;
    }
    for my $tag (keys %fields_by_tag) {
        $tags->{block}->{"${tag}Block"} = sub {
            local $_[0]->{__stash}{tag} = $tag . 'block';
            local $_[0]->{__stash}{flcf_fields} = $fields_by_tag{$tag};
            return flcf_block(@_);
        }
    }
    $reg->{tags} = $tags;
    $plugin->registry($reg);
}

sub flcf_block {
    my ($ctx, $args, $cond) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');
    my $c_plugin = MT->component('FLCFCommon');
    my $app = MT->instance;

    # load object
    my $fields = $ctx->stash('flcf_fields');
    my $blog = $ctx->stash('blog');
    my $field = $fields->{$blog->id} || $fields->{0};
    return $ctx->error($plugin->translate('Can\'t find field related to [_1] tag.', 'MT' . lc($ctx->stash('tag')))) if (!$field);
    my $class = $field->{obj_class};
    my $obj;
    eval { $obj = CustomFields::Template::ContextHandlers::find_stashed_by_type( $ctx, $field->obj_type ) };
    return $ctx->error($@) if $@;

    return $ctx->error(
        MT->translate(
            "Are you sure you have used a '[_1]' tag in the correct context? We could not find the [_2]",
            $ctx->stash('tag'),
            $field->obj_type
        )
    ) unless ref $obj;

    # parse field definition
    my $flcf_def;
    eval {
        $flcf_def = MT::Util::YAML::Load($field->flcf_def);
    };
    if ($@) {
        return $ctx->error($c_plugin->translate('Field definition YAML parse error. [_1]', $@));
    }

    # parse used fields
    my $used_ctrls = from_json($field->flcf_used_ctrls);

    # get value
    load_meta_to_cache($obj);
    my $field_value_str = get_meta($obj, $field->basename);
    return $ctx->else($args, $cond) if (!$field_value_str);
    my $field_values;
    eval {
        $field_values = from_json($field_value_str);
    };
    if ($@) {
        return $ctx->error($c_plugin->translate('Decode JSON error. [_1]', $@));
    }

    return flcf_block_common($ctx, $args, $cond, $field_values, $flcf_def, $used_ctrls);
}

1;
