package OpenID::L10N::ja;

use strict;
use warnings;
use utf8;
use base 'OpenID::L10N';

our %Lexicon = (

## plugins/OpenID/config.yaml
	'Provides OpenID authentication.' => 'OpenID認証機能を提供します。',

## plugins/OpenID/lib/MT/Auth/GoogleOpenId.pm
	'A Perl module required for Google ID commenter authentication is missing: [_1].' => 'Google ID認証を利用するのに必要なPerlモジュールのうちいくつがありません: [_1]',

## plugins/OpenID/lib/MT/Auth/OpenID.pm
	'Could not save the session' => 'セッションを保存できませんでした。',
	'Could not load Net::OpenID::Consumer.' => 'Net::OpenID::Consumerをロードできませんでした。',
	'The address entered does not appear to be an OpenID endpoint.' => '入力されたアドレスはOpenIDではありません。',
	'The text entered does not appear to be a valid web address.' => '正しいURLを入力してください。',
	'Unable to connect to [_1]: [_2]' => '[_1]に接続できません: [_2]',
	'Could not verify the OpenID provided: [_1]' => 'OpenIDを検証できませんでした: [_1]',

## plugins/OpenID/tmpl/comment/auth_aim.tmpl
	'Your AIM or AOL Screen Name' => 'AIMまたはAOLのスクリーンネーム',
	'Sign in using your AIM or AOL screen name. Your screen name will be displayed publicly.' => 'AIMまたはAOLのスクリーンネームでサインインします。スクリーンネームは公開されます。',

## plugins/OpenID/tmpl/comment/auth_googleopenid.tmpl
	'Sign in using your Gmail account' => 'Gmailのアカウントでサインインする',
	'Sign in to Movable Type with your[_1] Account[_2]' => '[_1] アカウント[_2]',

## plugins/OpenID/tmpl/comment/auth_hatena.tmpl
	'Your Hatena ID' => 'はてなID',

## plugins/OpenID/tmpl/comment/auth_livedoor.tmpl

## plugins/OpenID/tmpl/comment/auth_livejournal.tmpl
	'Your LiveJournal Username' => 'あなたのLiveJournalのユーザー名',
	'Learn more about LiveJournal.' => 'LiveJournalについて詳しくはこちら',

## plugins/OpenID/tmpl/comment/auth_openid.tmpl
	'OpenID URL' => 'あなたのOpenID URL',
	'Sign in with one of your existing third party OpenID accounts.' => 'すでに登録済みの、OpenIDに対応した別サービスのアカウントでサインインします。',
	'http://www.openid.net/' => 'http://www.sixapart.jp/about/openid.html',
	'Learn more about OpenID.' => 'OpenIDについて詳しくはこちら',

## plugins/OpenID/tmpl/comment/auth_wordpress.tmpl
	'Your Wordpress.com Username' => 'Wordpress.comのユーザー名',
	'Sign in using your WordPress.com username.' => 'Wordpress.comのユーザー名でサインインします。',

## plugins/OpenID/tmpl/comment/auth_yahoo.tmpl
	'Turn on OpenID for your Yahoo! account now' => 'Yahoo!のアカウントをOpenIDにする',

## plugins/OpenID/tmpl/comment/auth_yahoojapan.tmpl
	'Turn on OpenID for your Yahoo! Japan account now' => 'Yahoo! JAPANのOpenIDを取得してください。',

);

1;
