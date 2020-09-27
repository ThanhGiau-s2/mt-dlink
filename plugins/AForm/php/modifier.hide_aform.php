<?php
function smarty_modifier_hide_aform($entry_text, $args) {
  $entry_text = preg_replace("/<\!--aform\d.*-->/i", "", $entry_text);
  $entry_text = preg_replace("/\[\[aform\d.*\]\]/i", "", $entry_text);
  return $entry_text;
}
?>
