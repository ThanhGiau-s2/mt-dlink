# A plugin for adding "AFormSalesforce" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package AFormSalesforce::L10N::ja;

use strict;
use base qw( AFormSalesforce::L10N::en_us );
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
  'Salesforce Setting' => 'Salesforce連携',
  'To add posted datas as the lead in Salesforce' => '投稿内容をSalesforceのリードとして追加する',
  'To add posted datas as the case in Salesforce' => '投稿内容をSalesforceのケースとして追加する',
  'Salesforce Web-to-lead(Web-to-case) oid' => 'Salesforce Web-To-リード(Web-To-ケース) oid',
  'Please enter oid to authenticate the API.' => 'APIの認証につかうoidを設定してください。',
  'Send as type of checkbox' => 'チェックボックス型として送信する項目のパーツID',
  'Please input parts IDs by CSV format.' => 'パーツIDをカンマ区切りで入力してください。',
  'Post to' => '送信先',
  'Post to Production enviroment' => 'Salesforceの本番環境へ送信する',
  'Post to Sandbox enviroment' => 'SalesforceのSandbox環境へ送信する',
);
1;
