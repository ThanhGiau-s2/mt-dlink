<?php
class PluginConfig {
    private static $cache = array();
    private $db;
    private $plugin;

    public function __construct($db, $plugin) {
        $this->db = $db;
        $this->plugin = $plugin;
    }

    public function get_config_value($key, $scope) {
        $cache_key = $plugin . ':' . $scope;
        if (isset(self::$cache[$cache_key])) {
            $plugin_data = self::$cache[$cache_key];
        }
        else {
            $plugin_data = $this->db->fetch_plugin_config($this->plugin, $scope);
            self::$cache[$cache_key] = $plugin_data;
        }
        return $plugin_data[$key];
    }
}
?>
