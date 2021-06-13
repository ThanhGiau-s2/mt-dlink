package GoogleMapsCustomFields::ContentField;

use strict;
use MT;

use GoogleMapsCustomFields::ContextHandlers;

sub gmcf_registry {
    my $plugin = MT->component('GoogleMapsCustomFields');
    my $reg = {
        gmap => {
            label => $plugin->translate('Google Maps'),
            field_html => 'gmcf_field.tmpl',
            field_html_params => \&field_html_params,
            data_type => 'varchar',
            order => 200,
            options_html => 'gmcf_options.tmpl',
            options => [
                qw(
                    label
                    description
                    required
                    display
                    admin_width
                    admin_height
                    site_width
                    site_height
                )
            ],
#            ss_validator => \&ss_validator,
            tag_handler => \&gmcf_tag_handler
        },
    };
    return $reg;
}

sub field_html_params {
    my ( $app, $field_data ) = @_;

    # create param
    $DB::signal = 1;
    my $param = {};
    my $pseudo_id = 'content-field-' . $field_data->{content_field_id};
    $param->{field_name} = $pseudo_id;
    $param->{field_id} = $pseudo_id;
    $param->{field_value} = $field_data->{value};
    $param->{fjgmcf_map_width} =
        $field_data->{options}->{admin_width} ||
        $field_data->{options}->{site_width} || 500;
    $param->{fjgmcf_map_height} =
        $field_data->{options}->{admin_height} ||
        $field_data->{options}->{site_height} || 200;
    $param->{fjgmcf_map_height_hide} = $param->{fjgmcf_map_height} + 200;
    my @values = split '|', $field_data->{value};
    $param->{fjgmcf_showmap} = $values[0];

    require MT::Request;
    my $req = MT::Request->instance;
    my $fields = $req->stash('fjgmcf::fields');
    if ($fields) {
        push @$fields, $pseudo_id;
    }
    else {
        $fields = [ $pseudo_id ];
    }
    $req->stash('fjgmcf::fields', $fields);

    return $param;
}

sub gmcf_tag_handler {
    my ($ctx, $args, $cond, $field_data, $value) = @_;
    my $plugin = MT->component('GoogleMapsCustomFields');

    local $ctx->{__stash}{gmcf_content_data} = $field_data;
    local $ctx->{__stash}{gmcf_content_value} = $value;

    # out map
    my $params = GoogleMapsCustomFields::ContextHandlers::_get_params($ctx, $args);
    if ($params && $params->{show}) {
        local $ctx->{__stash}{fjgmcf_params} = $params;
        return $ctx->slurp($args, $cond);
    }
    else {
        return $ctx->else($args, $cond);
    }
}

1;
