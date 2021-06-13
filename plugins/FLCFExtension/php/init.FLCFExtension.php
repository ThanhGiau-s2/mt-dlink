<?php
$mt = MT::get_instance();
$ctx = &$mt->context();
$ctx->conditionals['mtflcftable'] = 1;
$ctx->conditionals['mtflcfselectedoptions'] = 1;

if (VERSION >= 6.3) {
    $flcf_tmpl_output = $ctx->getTemplateVars('flcf_tmpl_output');
    if (!isset($flcf_tmpl_output)) {
        $flcf_tmpl_output = array();
        $ctx->assign('flcf_tmpl_output', $flcf_tmpl_output);
    }
    $flcf_tmpl_output['richtext'] = 'out_richtext';
}
else {
    if (!isset($ctx->flcf_tmpl_output)) {
        $ctx->flcf_tmpl_output = array();
    }
    $ctx->flcf_tmpl_output['richtext'] = 'out_richtext';
}

function out_richtext($args, &$ctx, $value) {
    return isset($value) ? $value : '';
}
?>
