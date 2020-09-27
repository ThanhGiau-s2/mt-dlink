#!/usr/bin/perl -w
# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

BEGIN{
  use strict;
  use File::Basename;
  require( dirname($0) . '/aform_config.cgi');

  # set default if empty
  $AForm::Config::MTDir = $AForm::Config::MTDir || (dirname($0) . '/../../');
  $AForm::Config::AFormDir = $AForm::Config::AFormDir || (dirname($0) . '/./');
  # add slash if not exists
  $AForm::Config::MTDir .= '/' if( $AForm::Config::MTDir !~ m/\/$/ );
  $AForm::Config::AFormDir .= '/' if( $AForm::Config::AFormDir !~ m/\/$/ );

  $ENV{MT_HOME} = $AForm::Config::MTDir;
}
use lib $AForm::Config::AFormDir . 'lib';
use lib $AForm::Config::MTDir . 'lib';
use lib $AForm::Config::MTDir . 'extlib';
use MT::Bootstrap App => 'AFormEngineCGI';
