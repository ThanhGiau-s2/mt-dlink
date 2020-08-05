package Trackback::L10N::ja;

use strict;
use warnings;
use utf8;
use base 'Trackback::L10N';

our %Lexicon = (

## plugins/Trackback/config.yaml
	'Provides Trackback.' => 'トラックバックの機能を提供します。',
	'Mark as Spam' => 'スパムに指定',
	'Remove Spam status' => 'スパム指定を解除',
	'Unpublish TrackBack(s)' => 'トラックバックの公開取り消し',
	'weblogs.com' => 'weblogs.com',
	'New Ping' => '新しいトラックバック',

## plugins/Trackback/default_templates/new-ping.mtml
	q{An unapproved TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{サイト '[_1]' の記事 '[_3]' (ID:[_2]) に未公開のトラックバックがあります。公開するまでこのトラックバックはサイトに表示されません。},
	q{An unapproved TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{サイト '[_1]' のウェブページ '[_3]' (ID:[_2]) に未公開のトラックバックがあります。公開するまでこのトラックバックはサイトに表示されません。},
	q{An unapproved TrackBack has been posted on your site '[_1]', on category #[_2], ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{サイト '[_1]' のカテゴリ '[_3]' (ID:[_2]) に未公開のトラックバックがあります。公開するまでこのトラックバックはサイトに表示されません。},
	q{A new TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{サイト '[_1]' の記事 '[_3]' (ID:[_2]) に新しいトラックバックがあります。},
	q{A new TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{サイト '[_1]' のウェブページ '[_3]' (ID:[_2]) に新しいトラックバックがあります。},
	q{A new TrackBack has been posted on your site '[_1]', on category #[_2] ([_3]).} => q{サイト '[_1]' のカテゴリ '[_3]' (ID:[_2]) に新しいトラックバックがあります。},
	'Approve TrackBack' => 'トラックバックを承認する',
	'View TrackBack' => 'トラックバックを見る',
	'Report TrackBack as spam' => 'トラックバックをスパムとして報告する',
	'Edit TrackBack' => 'トラックバックの編集',

## plugins/Trackback/default_templates/trackbacks.mtml

## plugins/Trackback/lib/MT/App/Trackback.pm
	'You must define a Ping template in order to display pings.' => '表示するにはトラックバックテンプレートを定義する必要があります。',
	'Trackback pings must use HTTP POST' => 'Trackback pings must use HTTP POST',
	'TrackBack ID (tb_id) is required.' => 'トラックバックIDが必要です。',
	'Invalid TrackBack ID \'[_1]\'' => 'トラックバックID([_1])が不正です。',
	'You are not allowed to send TrackBack pings.' => 'トラックバック送信を許可されていません。',
	'You are sending TrackBack pings too quickly. Please try again later.' => '短い期間にトラックバックを送信しすぎです。少し間をあけても
 一度送信してください。',
	'You need to provide a Source URL (url).' => 'URLが必要です。',
	'Invalid URL \'[_1]\'' => '不正なURL \'[_1]\'',
	'This TrackBack item is disabled.' => 'トラックバックは無効に設定されています。',
	'This TrackBack item is protected by a passphrase.' => 'トラックバックはパスワードで保護されています。',
	'TrackBack on "[_1]" from "[_2]".' => '[_2]から\'[_1]\'にトラックバックがありました。',
	'TrackBack on category \'[_1]\' (ID:[_2]).' => 'カテゴリ\'[_1]\'にトラックバックがありました。',
	'Cannot create RSS feed \'[_1]\': ' => 'フィード([_1])を作成できません: ',
	'New TrackBack ping to \'[_1]\'' => '\'[_1]\'に新しいトラックバックがありました',
	'New TrackBack ping to category \'[_1]\'' => 'カテゴリ\'[_1]\'にの新しいトラックバックがありました',

## plugins/Trackback/lib/MT/CMS/TrackBack.pm
	'(Unlabeled category)' => '(無名カテゴリ)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from category \'[_4]\'' => '\'[_3]\'が\'[_2]\'のトラックバック(ID:[_1])をカテゴリ\'[
_4]\'から削除しました。',
	'(Untitled entry)' => '(タイトルなし)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => '\'[_3]\'が\'[_2]\'のトラックバック(ID:[_1])を削除しました。
',
	'No Excerpt' => '抜粋なし',
	'Orphaned TrackBack' => '対応する記事のないトラックバック',
	'category' => 'カテゴリ',

## plugins/Trackback/lib/MT/Template/Tags/Ping.pm
	'<\$MTCategoryTrackbackLink\$> must be used in the context of a category, or with the \'category\' attribute to the tag.' => '<\$MTCategoryTrackbackLink\$>はカテゴリのコンテキストかまたはcategory属性とともに利用してください。',

## plugins/Trackback/lib/MT/XMLRPC.pm
	'No WeblogsPingURL defined in the configuration file' => '構成ファイルにWeblogsPingURLが設定されていません。',
	'No MTPingURL defined in the configuration file' => '構成ファイルにMTPingURLが設定されていません。',
	'HTTP error: [_1]' => 'HTTPエラー: [_1]',
	'Ping error: [_1]' => 'Pingエラー: [_1]',

## plugins/Trackback/lib/Trackback.pm
	'<a href="[_1]">Ping from: [_2] - [_3]</a>' => '<a href="[_1]">[_2] - [_3]からのトラックバック</a>',
	'Not spam' => 'スパムではない',
	'Reported as spam' => 'スパム',
	'Trackbacks on [_1]: [_2]' => '[_1] \'[_2]\'のトラックバック',
	'__PING_COUNT' => 'トラックバック数',
	'Trackback Text' => 'トラックバックの本文',
	'Trackbacks on My Entries/Pages' => '自分の記事/ウェブページへのトラックバック',
	'Non-spam trackbacks' => 'スパムでないトラックバック',
	'Non-spam trackbacks on this website' => 'ウェブサイトのスパムでないトラックバック',
	'Pending trackbacks' => '保留中のトラックバック',
	'Published trackbacks' => '公開されているトラックバック',
	'Trackbacks on my entries/pages' => '自分の記事/ウェブページへのトラックバック',
	'Trackbacks in the last 7 days' => '最近7日間以内のトラックバック',
	'Spam trackbacks' => 'スパムトラックバック',

## plugins/Trackback/lib/Trackback/App/ActivityFeed.pm
	'[_1] TrackBacks' => '[_1]へのトラックバック',
	'All TrackBacks' => 'すべてのトラックバック',

## plugins/Trackback/lib/Trackback/App/CMS.pm
	'Are you sure you want to remove all trackbacks reported as spam?' => 'スパムとして報告したすべてのトラックバックを削除しますか?',
	'Delete all Spam trackbacks' => '全てのスパムトラックバックを削除する',

## plugins/Trackback/lib/Trackback/Blog.pm
	'Cloning TrackBacks for blog...' => 'トラックバックを複製しています...',
	'Cloning TrackBack pings for blog...' => 'トラックバックを複製しています...',

## plugins/Trackback/lib/Trackback/CMS/Comment.pm
	'You do not have permission to approve this trackback.' => 'このトラックバックを承認する権限がありません。',
	'The entry corresponding to this comment is missing.' => 'このコメントに対応する記事が見つかりません。',
	'You do not have permission to approve this comment.' => 'このコメントを承認する権限がありません。',

## plugins/Trackback/lib/Trackback/CMS/Entry.pm
	'Ping \'[_1]\' failed: [_2]' => '[_1]へトラックバックできませんでした: [_2]',

## plugins/Trackback/lib/Trackback/CMS/Search.pm
	'Source URL' => '送信元のURL',

## plugins/Trackback/lib/Trackback/Import.pm
	'Creating new ping (\'[_1]\')...' => '\'[_1]\'のトラックバックをインポートしています...',
	'Saving ping failed: [_1]' => 'トラックバックを保存できませんでした: [_1]',

## plugins/Trackback/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Image photo',

## plugins/Trackback/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Original Test',

## plugins/Trackback/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml

);

1;
