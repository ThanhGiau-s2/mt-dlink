package GoogleMapsCustomFields::ContextHandlers;

use strict;
use warnings;
use base qw( Exporter );

use MT;
eval "use CustomFields::Template::ContextHandlers;";
eval "use AnotherCustomFields::Util;";

our @EXPORT_OK = qw( _get_params );

sub gmap_acf_tag_installer {
    my ($tags, $tag, $class, $field) = @_;

    $tags->{block}->{$tag . 'block'} = sub {
        $field->{obj_class} = $class;
        local $_[0]->{__stash}{tag} = $tag . 'block';
        local $_[0]->{__stash}{field} = $field;
        local $_[0]->{__stash}{gmap_acf} = 1;
        return gmap_block(@_);
    };
}

sub gmap_block {
    my ($ctx, $args, $cond) = @_;

    my $field;
    if ($ctx->stash('gmap_acf')) {
        $field = $ctx->stash('field');
    }
    else {
        my $tag = $ctx->stash('tag');
        $tag =~ s/block$//xmsi;
        $field = CustomFields::Template::ContextHandlers::find_field_by_tag($ctx, $tag)
            or return CustomFields::Template::ContextHandlers::_no_field($ctx);
    }
    local $ctx->{__stash}{field} = $field;
    my $params = _get_params($ctx, $args);

    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');
    if ($params && $params->{show}) {
        local $ctx->{__stash}{fjgmcf_params} = $params;
        return $ctx->slurp($args, $cond);
    }
    else {
        return $ctx->else($args, $cond);
    }
}

sub flcf_gmap {
    my ($ctx, $args, $cond) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');

    # load field value
    my $field_value = $ctx->stash('flcf_field_value');
    unless (defined($field_value)) {
        return $ctx->error($plugin->translate('Not in FreeLayoutCustomField block.'));
    }
    my $name = $args->{name} || $args->{field};
    if (!$name) {
        return $ctx->error($plugin->translate('Please specify name modifier.'));
    }

    # out map
    my $params = _get_params($ctx, $args);
    if ($params && $params->{show}) {
        local $ctx->{__stash}{fjgmcf_params} = $params;
        return $ctx->slurp($args, $cond);
    }
    else {
        return $ctx->else($args, $cond);
    }
}

sub gmap_static {
    my ($ctx, $args) = @_;

    my $params = $ctx->stash('fjgmcf_params');
    return '' if (!$params);

    my $tag = lc $ctx->stash('tag');
    my $width  = $args->{width} || $params->{width};
    my $height = $args->{height} || $params->{height};
    my $zoom   = $args->{zoom} || $params->{zoom};
    my $address = $args->{address} || $params->{address};
    my $plugin = MT->component('GoogleMapsCustomFields');
    my $blog = $ctx->stash('blog');
    my $api_key = $plugin->get_config_value('fjgmcf_api_key', 'blog:' . $blog->id);
    my $url = "//maps.googleapis.com/maps/api/staticmap?center=$params->{lat},$params->{lng}&amp;zoom=$zoom&amp;size=${width}x$height&amp;markers=$params->{lat},$params->{lng}&amp;key=${api_key}";
    if ($tag eq 'gmapcfstaticurl') {
        return $url;
    }
    elsif ($tag eq 'gmapcfstatic') {
        return <<HERE;
<img src="$url" width="$width" height="$height" alt="$address" title="$address" />
HERE
    }
}

sub gmap_url {
    my ($ctx, $args) = @_;

    my $params = $ctx->stash('fjgmcf_params');
    return '' if (!$params);
    my $zoom   = $args->{zoom} || $params->{zoom};
    return "http://maps.google.co.jp/maps?f=q&amp;source=s_q&amp;hl=ja&amp;q=$params->{lat},$params->{lng}&amp;z=$zoom&amp;&ie=UTF8";
}

sub gmap_web_elements {
    my ($ctx, $args) = @_;
    my $plugin = MT->component('GoogleMapsCustomFields');

    my $params = $ctx->stash('fjgmcf_params');
    return '' if (!$params);
    require MT::Util;
    my $address_enc = MT::Util::encode_url($params->{address} || $params->{address_raw});
    my $width  = $args->{width} || $params->{width};
    my $height = $args->{height} || $params->{height};
    my $zoom   = $args->{zoom} || $params->{zoom};
    my $lat = $params->{lat};
    my $lng = $params->{lng};
    my $view_msg = $plugin->translate('View on larger map');
    my $show_info = $args->{show_info} ? '' : '&amp;iwloc=B';
    my $map_type = $args->{type} ? $args->{type} : 'm';
    if (lc $ctx->stash('tag') eq 'gmapcfwebelements') {
        return <<HERE;
<iframe frameborder="0" marginwidth="0" marginheight="0" border="0" style="border:0;margin:0;width:${width}px;height:${height}px;" src="http://www.google.com/uds/modules/elements/mapselement/iframe.html?maptype=roadmap&amp;latlng=$params->{lat}%2C$params->{lng}&amp;mlatlng=$params->{lat}%2C$params->{lng}&amp;maddress1=$address_enc&amp;mtitle=$address_enc&amp;zoom=$zoom&amp;element=true" scrolling="no" allowtransparency="true"></iframe>
HERE
    }
    elsif (lc $ctx->stash('tag') eq 'gmapcfembed2') {
        my $blog = $ctx->stash('blog');
        my $api_key = $plugin->get_config_value('fjgmcf_api_key', 'blog:' . $blog->id);
        return <<HERE;
<iframe frameborder="0" marginwidth="0" marginheight="0" border="0" style="border:0;margin:0;width:${width}px;height:${height}px;" src="http://www.google.com/maps/embed/v1/place?key=${api_key}&amp;q=${address_enc}&amp;zoom=${zoom}" scrolling="no" allowtransparency="true"></iframe><br /><small><a href="//maps.google.co.jp/maps?f=q&amp;hl=ja&amp;q=${lat},${lng}(${address_enc})&amp;ll=${lat},${lng}&amp;ie=UTF8&amp;t=${map_type}&amp;z=${zoom}${show_info}" style="color:#0000FF;text-align:left">${view_msg}</a></small>
HERE
    }
    else {
        return <<HERE;
<iframe width="${width}" height="${height}" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="//maps.google.co.jp/maps?f=q&amp;hl=ja&amp;q=${lat},${lng}(${address_enc})&amp;ll=${lat},${lng}&amp;ie=UTF8&amp;t=${map_type}&amp;z=${zoom}${show_info}&amp;output=embed"></iframe><br /><small><a href="//maps.google.co.jp/maps?f=q&amp;hl=ja&amp;q=${lat},${lng}(${address_enc})&amp;ll=${lat},${lng}&amp;ie=UTF8&amp;t=${map_type}&amp;z=${zoom}${show_info}" style="color:#0000FF;text-align:left">${view_msg}</a></small>
HERE
    }
}

sub gmap_info {
    my ($ctx, $args) = @_;

    my $params = $ctx->stash('fjgmcf_params');
    return '' if (!$params);
    my $tag = lc $ctx->stash('tag');
    my %info_names = (
        'gmapcflatitude' => 'lat',
        'gmapcflongitude' => 'lng',
        'gmapcfzoom' => 'zoom',
        'gmapcfaddress' => 'address',
        'gmapcfaddressraw' => 'address_raw',
        'gmapcfwidth' => 'width',
        'gmapcfheight' => 'height',
    );
    return $params->{$info_names{$tag}};
}

sub _get_params {
    my ($ctx, $args) = @_;

    my ($value, @options);
    my $field = $ctx->stash('field');
    if ($ctx->stash('gmap_acf')) {
        my $class = $field->{obj_class};
        my $obj = AnotherCustomFields::Util::load_object($ctx, $class);
        $value = $obj->column($field->{field_name});
        @options = split ',', $field->{field_options};
    }
    elsif ($ctx->stash('gmcf_content_data')) {
        $value = $ctx->stash('gmcf_content_value');
        my $field_data = $ctx->stash('gmcf_content_data');
        $options[0] = $field_data->{options}->{site_width};
        $options[1] = $field_data->{options}->{site_height};
    }
    elsif ($ctx->stash('flcf_field_value')) {
        my $name = $args->{name} || $args->{field};
        my $field_value = $ctx->stash('flcf_field_value');
        $value = $field_value->{$name};
        my $flcf_def = $ctx->stash('flcf_def');
        my $field_def = $flcf_def->{fields}->{$name};
        $options[0] = $field_def->{width};
        $options[1] = $field_def->{height};
    }
    else {
        $value = CustomFields::Template::ContextHandlers::_hdlr_customfield_value($ctx, $args);
        @options = split ',', $field->options;
    }
    my @params = split '\|', $value;
    my $params;
    if (@params) {
        my $address = $params[4]
            ? $params[4]
            : $params[1] . ', ' . $params[2];

        $params = {
            show => $params[0],
            lat => $params[1],
            lng => $params[2],
            zoom => $params[3],
            address => $address,
            address_raw => $params[4],
            width => $options[0] || 500,
            height => $options[1] || 200,
        }
    }
    return $params;
}

1;
