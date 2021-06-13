package FreeLayoutCustomField::BackupRestore;

use strict;
use warnings;
use MT;
use FLCFCommon::Util qw( load_asset_types );
use CustomFields::Util qw( get_meta save_meta );
use JSON;

sub restore {
    my ($cb, $objects, $deferred, $errors, $callback) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');

    # create asset type list
    my %asset_types = load_asset_types();

    # find asset ids
    my %assets;
    for my $key (keys %$objects) {
        if ($key =~ /^MT::Asset#(\d+)$/) {
            $assets{$1} = $objects->{$key}->id;
        }
    }

    # restore
    my $app = MT->instance;
    my $restore_classes = $app->registry('flcf_restore_classes');
    my $flcf_types = $app->registry('flcf_types');
    for my $class (keys %$restore_classes) {
        # load fields
        my @fields = MT->model('field')->load({
            obj_type => $restore_classes->{$class},
            type => 'flcf'
        });
        if (@fields) {
            $callback->($plugin->translate('Restoring item field of [_1]',
                        MT->model($class)->class_label_plural) . "\n");
            # split fields by blog_id
            my %fields_by_blogs = ();
            for my $field (@fields) {
                my $blog_id = $field->blog_id;
                $fields_by_blogs{$blog_id} = [] if (!$fields_by_blogs{$blog_id});
                push @{$fields_by_blogs{$blog_id}}, $field;
            }

            # check objects
            my @check_classes;
            my $i = 0;
            for my $check_class (@{$restore_classes->{$class}}) {
                $check_classes[$i] = '^' . MT->model($check_class) . '#(\d+)$';
                $i++;
            }

            # load flcf defs
            my $field_defs = {};
            for my $field (@fields) {
                my $flcf_def;
                eval {
                    $flcf_def = MT::Util::YAML::Load($field->flcf_def) || {};
                };
                if ($@) {
                    die $plugin->translate('Malformed field definition YAML string.');
                }
                $field_defs->{$field->basename} = $flcf_def->{fields};
            }

            # change id of object metas
            my $count = $i;
            for my $key (keys %$objects) {
                my $found_key;
                for (my $c = 0; $c < $count; $c++) {
                    if ($key =~ /$check_classes[$c]/) {
                        $found_key = $key;
                        last;
                    }
                }
                if ($found_key) {
                    my $obj = $objects->{$key};
                    my $meta = get_meta($obj);
                    my @c_fields = $fields_by_blogs{0}
                                 ? @{$fields_by_blogs{0}} : ();
                    if ($obj->has_column('blog_id') &&
                        $fields_by_blogs{$obj->blog_id}) {
                        push @c_fields, @{$fields_by_blogs{$obj->blog_id}};
                    }
                    for my $field (@c_fields) {
                        next if ($obj->has_column('class') &&
                                 $field->obj_type ne $obj->class);
                        my $values;
                        eval {
                            $values = from_json($meta->{$field->basename});
                        };
                        $values = [] if ($@);
                        for my $value (@$values) {
                            my $field_def = $field_defs->{$field->basename};
                            my @field_names = keys %$field_def;
                            for my $name (@field_names) {
                                my $type = $field_def->{$name}->{type};
                                if ($asset_types{$type} &&
                                    $value->{$name}) {
                                    $value->{$name} =  $assets{$value->{$name}};
                                }
                                elsif ($flcf_types->{$type}->{restore_assets}) {
                                    my $code = $flcf_types->{$type}->{restore_assets};
                                    $code->($value, $field_def, $name, \%assets);
                                }
                            }
                        }
                        $meta->{$field->basename} = to_json($values);
                    }
                    save_meta($obj, $meta);
                    $callback->(
                        $plugin->translate(
                            'Restored [_1] (ID = [_2])',
                            MT->model($class)->class_label_plural,
                            $obj->id
                        ) . "\n"
                    );
                }
            }
            $callback->(MT->translate("Done.") . "\n");
        }
    }
}

1;
