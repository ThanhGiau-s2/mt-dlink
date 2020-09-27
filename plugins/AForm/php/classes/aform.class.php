<?php
require_once('class.baseobject.php');

class Aform extends BaseObject
{
    public $_table = 'mt_aform';
    protected $_prefix = "aform_";
    protected $_has_meta = false;


    function Save() {
        if (empty($this->aform_class))
            $this->aform_class = 'aform';
		if( $this->start_at == '' ){
			$this->start_at = '1970-01-01 00:00:00';
		}
		if( $this->end_at == '' ){
			$this->end_at = '1970-01-01 00:00:00';
		}
        return parent::Save();
    }

    function set_status($status){
        global $mt;

        $status = (int)$status;
        if( $this->status != $status ){
            $this->status = $status;
            $this->save();
        }
    }
    function published(){
        $this->set_status(2);
    }
    function unpublished(){
        $this->set_status(0);
    }
    function set_auto_status($status){
        global $mt;

        $status = (int)$status;
        if( $this->auto_status != $status ){
            $this->auto_status = $status;
            $this->save();
        }
    }
}
?>
