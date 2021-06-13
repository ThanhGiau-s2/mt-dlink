package FreeLayoutCustomField::Upgrade;

use strict;
use warnings;

use MT::Util::YAML;
use FLCFCommon::Util qw( check_used_ctrls check_null );
use CustomFields::Util qw( get_meta save_meta load_meta_to_cache );
use JSON;

sub add_used_ctrls {
    my $field = shift;
    my $plugin = MT->component('FreeLayoutCustomField');

    if ($field->type eq 'flcf') {
        check_used_ctrls($field);
        $field->save
            or die $plugin->translate('Can\'t set used field information.');
    }
}

sub update_flcf_objects {
    my $obj = shift;
    my $plugin = MT->component('FreeLayoutCustomField');

    my $req = MT->request;
    my $class;
    my %obj_classes = (
        'MT::Comment' => 'comment',
        'MT::Template' => 'template',
        'MT::Author' => 'author'
    );
    if ($obj_classes{ref $obj}) {
        $class = $obj_classes{ref $obj};
    }
    else {
        $class = $obj->class;
    }
    my $blog_id;
    if (ref $obj eq 'MT::Author') {
        $blog_id = 0;
    }
    elsif (ref $obj eq 'MT::Blog' || ref $obj eq 'MT::Website') {
        $blog_id = $obj->id;
    }
    else {
        $blog_id = $obj->blog_id;
    }

    # load fields
    my $all_fields = $req->stash('FreeLayoutCustomField::FieldsOnUpgrade') || {};
    if (!$all_fields->{$blog_id} || !$all_fields->{$blog_id}->{$class}) {
        $all_fields->{$blog_id} ||= {};
        my @fields = MT->model('field')->load({
            type => 'flcf',
            blog_id => [ 0, $blog_id ],
            obj_type => $class
        });
        for my $field (@fields) {
            my $flcf_def;
            eval {
                $field->{flcf_def_decoded} = MT::Util::YAML::Load($field->flcf_def);
            };
            if ($@) {
                die $plugin->translate('[_1] Field definition YAML parse error. [_2]', $field->name, $@);
            }
            $field->{used_ctrls_decoded} = from_json($field->flcf_used_ctrls);
        }
        $all_fields->{$blog_id}->{$class} = \@fields;
        $req->stash('FreeLayoutCustomField::FieldsOnUpgrade', $all_fields);
    }
    my $fields = $all_fields->{$blog_id}->{$class};

    # set flcf_row_is_null
    my $meta = {};
    load_meta_to_cache($obj);
    for my $field (@$fields) {
        my $flcf_def = $field->{flcf_def_decoded};
        my $used_ctrls = $field->{used_ctrls_decoded};
        my $field_value_str = get_meta($obj, $field->basename);
        my $field_values;
        eval {
            $field_values = from_json($field_value_str);
        };
        if ($@) {
            $field_values = [];
        }
        check_null($obj, $field_values, $flcf_def, $used_ctrls);
        $field_value_str = to_json($field_values);
        $meta->{$field->basename} = $field_value_str;
    }
    save_meta($obj, $meta);
}

1;
