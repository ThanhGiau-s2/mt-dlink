<?php
function _fjgmapcf_get_params($value, $options) {
    if (!is_array($options)) {
        $options = explode(',', $options);
    }
    $params = explode('|', $value);
    if (count($params)) {
        $address = $params[4]
            ? $params[4]
            : $params[1] . ', ' . $params[2];
        $params = array(
            'show' => $params[0],
            'lat' => $params[1],
            'lng' => $params[2],
            'zoom' => $params[3],
            'address' => $address,
            'address_raw' => $params[4],
            'width' => $options[0] ? $options[0] : 500,
            'height' => $options[1] ? $options[1] : 200,
        );
    }
    return $params;
}

function _fjgmapcf_static(&$ctx, &$args, $tag) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }

    $width  = $args['width'] ? $args['width'] : $params['width'];
    $height = $args['height'] ? $args['height'] : $params['height'];
    $zoom   = $args['zoom'] ? $args['zoom'] : $params['zoom'];
    $address = $args['address'] ? $args['address'] : $params['address'];
    $lat = $params['lat'];
    $lng = $params['lng'];

    $url = "http://maps.google.com/maps/api/staticmap?center=${lat},${lng}&amp;zoom=${zoom}&amp;size=${width}x${height}&amp;markers=${lat},${lng}&amp;sensor=false";
    if ($tag == 'gmapcfstaticurl') {
        return $url;
    }
    else if ($tag == 'gmapcfstatic') {
        return <<<HERE
<img src="$url" width="$width" height="$height" alt="$address" title="$address" />
HERE;
    }
}
?>
