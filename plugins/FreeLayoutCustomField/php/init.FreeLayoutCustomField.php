<?php
$mt = MT::get_instance();
$ctx = &$mt->context();

require_once('class.baseobject.php');
require_once('class.mt_field.php');
require_once('spyc.php');

// load flcf fields
$fld = new Field();
$flcf_field_list_org = $fld->Find("field_type = 'flcf'");
global $flcf_field_list;
$flcf_field_list = array();
if (!empty($flcf_field_list_org)) {
    $count = count($flcf_field_list_org);
    for ($i = 0; $i < $count; $i++) {
        $field = $flcf_field_list_org[$i];
        $tag_name = strtolower($field->field_tag);
        $flcf_field_list[$field->field_blog_id][$tag_name] = $field;
        $fn_name = $field->field_id;
        $dynamic_function = <<<CODE
function flcf_block_$fn_name(\$args, \$content, &\$ctx, &\$repeat) {
    return flcf_block(\$args, \$content, \$ctx, \$repeat, '$tag_name');
}
CODE;
        eval($dynamic_function);
        $ctx->add_container_tag($tag_name . 'block', 'flcf_block_' . $fn_name);
        $ctx->conditionals['mt' . $tag_name . 'block'] = 1;
    }
}
$ctx->conditionals['mtflcfasset'] = 1;
$ctx->conditionals['mtflcfifunitname'] = 1;
$ctx->conditionals['mtflcfoptions'] = 1;
$ctx->conditionals['mtflcfifoptionselected'] = 1;
$ctx->conditionals['mtflcfifvalue'] = 1;
$ctx->conditionals['mtflcfunlessvalue'] = 1;

function flcf_block($args, $content, &$ctx, &$repeat, $tag = null) {
    $localvars = array(array('flcf_field_values', 'flcf_field_value', 'flcf_count', 'flcf_def', 'flcf_fields', 'flcf_is_empty', 'flcf_old_unit', 'flcf_unit_counter', 'glue', 'conditional', 'else_content'), common_loop_vars());
    global $flcf_field_list;

    if (!isset($content)) {
        $ctx->localize($localvars);

        $blog_id = $ctx->stash('blog_id');
        $field = $flcf_field_list[$blog_id][$tag];
        if (!$field) {
            $field = $flcf_field_list[0][$tag];
        }
        if (!$field) return '';

        $obj = _hdlr_customfield_obj($ctx, $field->field_obj_type);
        if (!isset($obj) || empty($obj)) return '';
        $field_values_str = $obj->{$obj->_prefix . 'field.' . $field->field_basename};
        $field_values = json_decode($field_values_str);
        $flcf_def = SPYC::YAMLLoadString($field->field_flcf_def);
        $flcf_fields = $flcf_def['fields'];
        $counter = 0;
        if (empty($field_values)) {
            $is_empty = true;
        }
        else {
            $is_empty = true;
            foreach ($field_values as $field_value) {
                if (!$field_value->flcf_row_is_null) {
                    $is_empty = false;
                    break;
                }
/*
                foreach ($field_value as $key => $value) {
                    if ($value !== '') {
                        $is_empty = false;
                        break;
                    }
                }
*/
            }
        }
        if (isset($args['glue'])) {
            $glue = $args['glue'];
        } else {
            $glue = '';
        }
        if ($args['skip_null']) {
            $org_values = $field_values;
            $field_values = array();
            foreach ($org_values as $field_value) {
                if (isset($field_value['flcf_row_is_null']) &&
                    !$field_value['flcf_row_is_null']) {
                    array_push($field_values, $field_value);
                }
            }
        }
        $field_count = count($field_values);
        $ctx->stash('flcf_field_values', $field_values);
        $ctx->stash('flcf_field_count', $field_count);
        $ctx->stash('flcf_def', $flcf_def);
        $ctx->stash('flcf_fields', $flcf_fields);
        $ctx->stash('flcf_field_counter', 0);
        $ctx->stash('flcf_is_empty', $is_empty);
        $ctx->stash('glue', $glue);
        $ctx->stash('__out', false);
        if (isset($field_values[0]->flcf_unit_name)) {
            $old_unit = '';
            $unit_counter = 0;
            $ctx->stash('flcf_old_unit', $old_unit);
            $ctx->stash('flcf_unit_counter', $unit_counter);
        }
    }
    else {
        $field_values = $ctx->stash('flcf_field_values');
        $field_count  = $ctx->stash('flcf_field_count');
        $flcf_def     = $ctx->stash('flcf_def');
        $flcf_fields  = $ctx->stash('flcf_fields');
        $counter      = $ctx->stash('flcf_field_counter');
        $is_empty     = $ctx->stash('flcf_is_empty');
        $old_unit     = $ctx->stash('flcf_old_unit');
        $unit_counter = $ctx->stash('flcf_unit_counter');
        $glue         = $ctx->stash('glue');
        $out          = $ctx->stash('__out');
    }

    if ($is_empty) {
        $ret = $ctx->_hdlr_if($args, $content, $ctx, $repeat, 0);
        if (!$repeat) {
            $ctx->restore($localvars);
        }
        return $ret;
    }
    else {
        $ctx->stash('conditional', 1);
        if (VERSION >= 6.3) {
            $ctx->assign('conditional', 1);
        }
    }

    if ($counter < $field_count) {
        $repeat = true;
        $unit_name = $field_values[$counter]->flcf_unit_name;
        $count = $counter + 1;
        $ctx->stash('flcf_field_value', $field_values[$counter]);
        $ctx->stash('flcf_field_counter', $counter + 1);
        $ctx->__stash['vars']['__counter__'] = $count;
        $ctx->__stash['vars']['__odd__'] = ($count % 2) == 1;
        $ctx->__stash['vars']['__even__'] = ($count % 2) == 0;
        $ctx->__stash['vars']['__first__'] = $count == 1;
        $ctx->__stash['vars']['__last__'] = ($count == count($field_values));
        $ctx->__stash['vars']['__unit__'] = $unit_name;
        if (isset($unit_name)) {
            if ($unit_name != $old_unit) {
                $old_unit = $unit_name;
                $unit_first = 1;
                $unit_counter = 0;
            }
            else {
                $unit_first = 0;
            }
            if ($counter < $field_count - 1) {
                $next_unit = $field_values[$counter + 1]->flcf_unit_name;
                $unit_last = ($next_unit != $old_unit) ? 1 : 0;
            }
            else {
                $unit_last = 1;
            }
        }
        $ctx->__stash['vars']['__unit_first__'] = $unit_first;
        $ctx->__stash['vars']['__unit_last__'] = $unit_last;
        $ctx->__stash['vars']['__unit_odd__'] = ($unit_counter % 2 == 0) ? 1 : 0;
        $ctx->__stash['vars']['__unit_even__'] = ($unit_counter % 2 == 1) ? 1 : 0;
        $ctx->__stash['vars']['__unit_counter__'] = $unit_counter + 1;
        $ctx->stash('flcf_old_unit', $old_unit);
        $ctx->stash('flcf_unit_counter', $unit_counter + 1);
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
