<?php
function smarty_block_mtflcfoptions($args, $content, &$ctx, &$repeat) {
    $localvars = array(array('_flcf_options', '_flcf_selected_options', '_flcf_options_counter', '_flcf_options_group', 'conditional' ,'else_content', 'flcf_option_value', 'flcf_option_label', 'flcf_option_group', 'flcf_option_selected'), common_loop_vars());
    $counter = 0;
    $group = '';

    if (!isset($content)) {
        $ctx->localize($localvars);

        $field_value = $ctx->stash('flcf_field_value');
        if (!isset($field_value)) {
            return '';
        }
        $name = $args['name'];
        if (!isset($name)) {
            $name = $args['field'];
        }
        if (!isset($name)) {
            return '';
        }
        $flcf_def = $ctx->stash('flcf_def');
        $options = $flcf_def['fields'][$name]['options'];
        $val = $field_value->$name;
        $values_h = array();
        if (is_array($val)) {
            for ($i = 0; $i < count($val); $i++) {
                $values_h[$val[$i]] = 1;
            }
        }
        else {
            $values_h[$val] = 1;
        }
        if (isset($args['glue'])) {
            $glue = $args['glue'];
        } else {
            $glue = '';
        }
        $ctx->stash('_flcf_options', $options);
        $ctx->stash('_flcf_selected_options', $values_h);
        $ctx->stash('_flcf_options_counter', $counter);
        $ctx->stash('_flcf_options_group', $group);
        $ctx->stash('glue', $glue);
        $ctx->stash('__out', false);
    }
    else {
        $options = $ctx->stash('_flcf_options');
        $values_h = $ctx->stash('_flcf_selected_options');
        $counter = $ctx->stash('_flcf_options_counter');
        $group = $ctx->stash('_flcf_options_group');
        $glue = $ctx->stash('glue');
        $out = $ctx->stash('__out');
    }

    $option_count = count($options);
    $is_empty = empty($options) || !$option_count;
    $ctx->stash('conditional', $is_empty ? 0 : 1);
    if ($is_empty) {
        $ret = $ctx->_hdlr_if($args, $content, $ctx, $repeat, 0);
        if (!$repeat)
              $ctx->restore($localvars);
        return $ret;
    }

    if ($counter < $option_count) {
        $repeat = true;
        $count = $counter + 1;
        $value = $options[$counter]['value'];
        $label = $options[$counter]['label']
               ? $options[$counter]['label'] : $value;
        if ($options[$counter]['group']) {
            $group = $options[$counter]['group'];
        }
        $ctx->stash('flcf_option_value', $value);
        $ctx->stash('flcf_option_label', $label);
        $ctx->stash('flcf_option_group', $group);
        $ctx->stash('flcf_option_selected', $values_h[$value]);
        $ctx->stash('_flcf_options_counter', $counter + 1);
        $ctx->stash('_flcf_options_group', $group);
        $ctx->__stash['vars']['__counter__'] = $count;
        $ctx->__stash['vars']['__odd__'] = ($count % 2) == 1;
        $ctx->__stash['vars']['__even__'] = ($count % 2) == 0;
        $ctx->__stash['vars']['__first__'] = $count == 1;
        $ctx->__stash['vars']['__last__'] = ($count == $option_count);
        if (!empty($glue) && !empty($content)) {
            if ($out) {
                $content = $glue . $content;
            }
            else {
                $ctx->stash('__out', true);
            }
        }
    }
    else {
        if (!empty($glue) && $out && !empty($content)) {
            $content = $glue . $content;
        }
        $ctx->restore($localvars);
        $repeat = false;
    }
    return $content;

}
?>
