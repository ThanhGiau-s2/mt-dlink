# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormField::L10N::ja;

use strict;
use base qw( AFormField::L10N::en_us );
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
    'Id' => 'フォームID',
    'AFormField Plugin' => 'お問い合わせフォームプラグイン',
    '_PLUGIN_DESCRIPTION' => 'お問い合わせフォーム機能をMTに追加するプラグインです。お問い合わせフォームの設置、管理、お問い合わせデータのDLといった機能が利用可能になります',
    '_PLUGIN_AUTHOR' => 'ARK-Web\'s MT Plugin Developers',
    'AFormField' => 'お問い合わせフォームフィールド',
    'AFormFields' => 'お問い合わせフォームフィールド',
    'Unpublished' => '非公開',
    'Waiting' => '公開待ち',
    'Published' => '公開',
    'Closed' => '終了',
);

1;
