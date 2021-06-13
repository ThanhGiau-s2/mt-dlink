<?php
function smarty_block_mtflcfselectedoptions($args, $content, &$ctx, &$repeat) {
    $localvars = array(array('_flcf_options', '_flcf_selected_options', '_flcf_options_counter', 'conditional' ,'else_content', 'flcf_option_value', 'flcf_option_label', 'flcf_option_group', 'flcf_option_selected', 'glue'), common_loop_vars());
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
        $group = '';
        $selected = array();
        for ($i = 0; $i < count($options); $i++) {
            if ($options[$i]['group']) {
                $group = $options[$i]['group'];
            }
            if ($values_h[$options[$i]['value']]) {
                $v = $options[$i]['value'];
                $l = $options[$i]['label']
                   ? $options[$i]['label'] : $v;
                array_push($selected, array('value' => $v, 'label' => $l, 'group' => $group));
            }
        }
        if (isset($args['glue'])) {
            $glue = $args['glue'];
        } else {
            $glue = '';
        }
        $ctx->stash('_flcf_options', $options);
        $ctx->stash('_flcf_selected_options', $selected);
        $ctx->stash('_flcf_options_counter', $counter);
        $ctx->stash('glue', $glue);
        $ctx->stash('__out', false);
    }
    else {
        $options = $ctx->stash('_flcf_options');
        $selected = $ctx->stash('_flcf_selected_options');
        $counter = $ctx->stash('_flcf_options_counter');
        $glue = $ctx->stash('glue');
        $out = $ctx->stash('__out');
    }

    $selected_count = count($selected);
    $is_empty = empty($selected) || !$selected_count;
    $ctx->stash('conditional', $is_empty ? 0 : 1);
    if ($is_empty) {
        $ret = $ctx->_hdlr_if($args, $content, $ctx, $repeat, 0);
        if (!$repeat)
              $ctx->restore($localvars);
        return $ret;
    }

    if ($counter < $selected_count) {
        $repeat = true;
        $count = $counter + 1;
        $ctx->stash('flcf_option_value', $selected[$counter]['value']);
        $ctx->stash('flcf_option_label', $selected[$counter]['label']);
        $ctx->stash('flcf_option_group', $selected[$counter]['group']);
        $ctx->stash('flcf_option_selected', 1);
        $ctx->stash('_flcf_options_counter', $counter + 1);
        $ctx->stash('_flcf_options_group', $group);
        $ctx->__stash['vars']['__counter__'] = $count;
        $ctx->__stash['vars']['__odd__'] = ($count % 2) == 1;
        $ctx->__stash['vars']['__even__'] = ($count % 2) == 0;
        $ctx->__stash['vars']['__first__'] = $count == 1;
        $ctx->__stash['vars']['__last__'] = ($count == $selected_count);
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
