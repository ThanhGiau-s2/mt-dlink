<?php
require_once('class.baseobject.php');

class AformData extends BaseObject
{
    public $_table = 'mt_aform_data';
    protected $_prefix = "aform_data_";
    protected $_has_meta = false;


    function Save() {
        if (empty($this->aform_class))
            $this->aform_class = 'aform_data';
        return parent::Save();
    }
}
?>
