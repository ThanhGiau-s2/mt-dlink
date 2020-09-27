# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormEngineCGI::CheckSerialNumber;

use strict;

sub check_serialnumber {
  my $plugin = MT->component('AForm');

  my $serialnumber = $plugin->get_config_value('serialnumber');

  if ($serialnumber =~ m/[^a-zA-Z0-9]/) {
    return 0;
  }
  return 1 if (length($serialnumber) == 12); 

  my $s = substr($serialnumber, 0, 2);

  # check type1 and type2
  my $type1 = substr($serialnumber, int($s)+0, 1);
  my $type2 = substr($serialnumber, int($s)+1, 1);
  if( $type1 ne $plugin->get_config_value('type1') || $type2 ne $plugin->get_config_value('type2') ){
    return 0;
  }

  require 'crc.pl';
  my $tvmx = substr($serialnumber, int($s), 10) . substr($serialnumber, 2, int($s)-2) . substr($serialnumber, int($s)+18);
  my $c = substr($serialnumber, int($s)+10, 8);

  my $v = sprintf("%d", substr($serialnumber, int($s)+4, 3));
  my $plugin_v = $plugin->version;
  $plugin_v =~ s/^(\d+).*$/$1/;
  if( length($serialnumber) == 33 && _crc32($tvmx) eq $c && check_version($plugin_v, $v) ){
    return 1;
  }else{
    return 0;
  }
}

sub check_version {
  my ($plugin_v, $serial_v) = @_;

  if ($plugin_v <= $serial_v) {
    return 1;
  }
  # 3.x serial is allowed for A-Form-4.x
  elsif ($plugin_v == 4 && $serial_v == 3) {
    return 1;
  }
  return 0;
}

1;
