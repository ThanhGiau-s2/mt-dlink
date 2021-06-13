<?php
function smarty_block_mtflcftable($args, $content, &$ctx, &$repeat) {
    $localvars = array(array('flcf_def', 'flcf_fields', 'flcf_field_value', 'flcf_table_rows', '_flcf_table_is_null', '_flcf_def_org', '_flcf_fields_org', '_flcf_field_value_org', '_flcf_table_counter', 'glue', 'conditional', 'else_content'), common_loop_vars());
    $counter = 0;

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
        $table_def = $flcf_def['fields'][$name];
        $pseudo_def = array('fields' => array());
        foreach ($table_def['columns'] as $column) {
            $pseudo_def['fields'][$column['name']] = $column;
        }
        if (isset($args['glue'])) {
            $glue = $args['glue'];
        } else {
            $glue = '';
        }
        $ctx->stash('_flcf_field_value_org', $field_value);
        $rows = $field_value->$name;
        if ($args['skip_null']) {
            $org_rows = $rows;
            $rows = array();
            foreach ($org_rows as $row) {
                if (isset($row['flcf_row_is_null']) &&
                    !$row['flcf_row_is_null']) {
                    array_push($rows, $row);
                }
            }
        }
        $table_is_null = 1;
        for ($i = 0; $i < count($rows); $i++) {
            if (!$rows[$i]->flcf_row_is_null) {
                $table_is_null = 0;
                break;
            }
        }
        $pseudo_fields = $pseudo_def['fields'];
        $ctx->stash('flcf_table_rows', $rows);
        $ctx->stash('_flcf_def_org', $flcf_def);
        $ctx->stash('_flcf_fields_org', $ctx->stash('flcf_fields'));
        $ctx->stash('flcf_fields', $pseudo_fields);
        $ctx->stash('_flcf_table_is_null', $table_is_null);
        $ctx->stash('flcf_def', $pseudo_def);
        $ctx->stash('glue', $glue);
        $ctx->stash('__out', false);
    }
    else {
        $rows = $ctx->stash('flcf_table_rows');
        $counter = $ctx->stash('_flcf_table_counter');
        $table_is_null = $ctx->stash('_flcf_table_is_null');
        $pseudo_def = $ctx->stash('flcf_def');
        $pseudo_fields = $ctx->stash('flcf_fields');
        $glue = $ctx->stash('glue');
        $out = $ctx->stash('__out');
    }

    $row_count = count($rows);
    $is_empty = empty($rows) || !$row_count || $table_is_null;
    $ctx->stash('conditional', $is_empty ? 0 : 1);
    if ($is_empty) {
        $ret = $ctx->_hdlr_if($args, $content, $ctx, $repeat, 0);
        if (!$repeat)
              $ctx->restore($localvars);
        return $ret;
    }

    if ($counter < $row_count) {
        $repeat = true;
        $count = $counter + 1;
        $ctx->stash('flcf_def', $pseudo_def);
        $ctx->stash('flcf_fields', $pseudo_fields);
        $ctx->stash('flcf_field_value', $rows[$counter]);
        $ctx->stash('_flcf_table_counter', $counter + 1);
        $ctx->__stash['vars']['__counter__'] = $count;
        $ctx->__stash['vars']['__odd__'] = ($count % 2) == 1;
        $ctx->__stash['vars']['__even__'] = ($count % 2) == 0;
        $ctx->__stash['vars']['__first__'] = $count == 1;
        $ctx->__stash['vars']['__last__'] = ($count == count($rows));
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
