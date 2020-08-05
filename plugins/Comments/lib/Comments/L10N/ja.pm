package Comments::L10N::ja;

use strict;
use warnings;
use utf8;
use base 'Comments::L10N';

our %Lexicon = (

## plugins/Comments/config.yaml
	'Provides Comments.' => 'コメント機能を提供します。',
	'Mark as Spam' => 'スパムに指定',
	'Remove Spam status' => 'スパム指定を解除',
	'Unpublish Comment(s)' => 'コメントの公開取り消し',
	'Trust Commenter(s)' => 'コメント投稿者を承認',
	'Untrust Commenter(s)' => 'コメント投稿者の承認を解除',
	'Ban Commenter(s)' => 'コメント投稿者を禁止',
	'Unban Commenter(s)' => 'コメント投稿者の禁止を解除',
	'Registration' => '登録/認証',
	'Manage Commenters' => 'コメント投稿者の管理',
	'Comment throttle' => 'コメントスロットル',
	'Commenter Confirm' => 'コメントの確認',
	'Commenter Notify' => 'コメントの通知',
	'New Comment' => '新しいコメント',

## plugins/Comments/default_templates/comment_detail.mtml

## plugins/Comments/default_templates/comment_listing.mtml

## plugins/Comments/default_templates/comment_preview.mtml

## plugins/Comments/default_templates/comment_response.mtml

## plugins/Comments/default_templates/comment_throttle.mtml
	'If this was an error, you can unblock the IP address and allow the visitor to add it again by logging in to your Movable Type installation, choosing Blog Config - IP Banning, and deleting the IP address [_1] from the list of banned addresses.' => 'これが間違いである場合は、Movable Typeにサインインして、ブログの設定画面に進み、禁止IPリストからIPアドレスを削除してください。',
	'A visitor to your blog [_1] has automatically been banned by adding more than the allowed number of comments in the last [_2] seconds.' => '[_1]を禁止しました。[_2]秒の間に許可された以上のコメントを送信してきました。',
	'This was done to prevent a malicious script from overwhelming your weblog with comments. The banned IP address is' => 'これは悪意のスクリプトがブログをコメントで飽和させるのを阻止するための措置です。以下のIPアドレスを禁止しました。',

## plugins/Comments/default_templates/commenter_confirm.mtml
	'Thank you for registering an account to comment on [_1].' => '[_1]にコメントするために登録していただきありがとうございます。',
	'For your security and to prevent fraud, we ask you to confirm your account and email address before continuing. Once your account is confirmed, you will immediately be allowed to comment on [_1].' => 'セキュリティ上の理由から、登録を完了する前にアカウントとメールアドレスの確認を行っています。確認を完了次第、[_1]にコメントできるようになります。',
	'To confirm your account, please click on the following URL, or cut and paste this URL into a web browser:' => 'アカウントの確認のため、次のURLをクリックするか、コピーしてブラウザのアドレス欄に貼り付けてください。',
	q{If you did not make this request, or you don't want to register for an account to comment on [_1], then no further action is required.} => q{このメールに覚えがない場合や、[_1]に登録するのをやめたい場合は、何もする必要はありません。},
	'Sincerely,' => ' ',

## plugins/Comments/default_templates/commenter_notify.mtml
	q{This email is to notify you that a new user has successfully registered on the blog '[_1]'. Here is some information about this new user.} => q{これは新しいユーザーがブログ「[_1]」に登録を完了したことを通知するメールです。新しいユーザーの情報は以下に記載されています。},
	'New User Information:' => '新規登録ユーザー:',
	'Full Name: [_1]' => '名前: [_1]',
	'To view or edit this user, please click on or cut and paste the following URL into a web browser:' => 'このユーザーの情報を見たり編集する場合には、下記のURLをクリックするか、URLをコピーしてブラウザのアドレス欄に貼り付けてください。',

## plugins/Comments/default_templates/comments.mtml

## plugins/Comments/default_templates/new-comment.mtml
	q{An unapproved comment has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{未公開のコメントがサイト '[_1]' の記事 '[_3]' (ID:[_2]) に投稿されました。公開するまでこのコメントはサイトに表示されません。},
	q{An unapproved comment has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{未公開のコメントがサイト '[_1]' のウェブページ '[_3]' (ID:[_2]) に投稿されました。公開するまでこのコメントはサイトに表示されません。},
	q{A new comment has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{サイト '[_1]' の記事 '[_3]' (ID:[_2]) に新しいコメントが投稿されました。},
	q{A new comment has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{サイト '[_1]' のウェブページ '[_3]' (ID:[_2]) に新しいコメントが投稿されました。},
	'Commenter name: [_1]' => 'コメント投稿者: [_1]',
	'Commenter email address: [_1]' => 'メールアドレス: [_1]',
	'Commenter URL: [_1]' => 'URL: [_1]',
	'Commenter IP address: [_1]' => 'IPアドレス: [_1]',
	'Approve comment:' => 'コメントを承認する:',
	'View comment:' => 'コメントを見る:',
	'Edit comment:' => 'コメントを編集する:',
	'Report the comment as spam:' => 'コメントをスパムとして報告する:',

## plugins/Comments/default_templates/recent_comments.mtml

## plugins/Comments/lib/Comments.pm
	'Search for other comments from anonymous commenters' => '匿名ユーザーからのコメントを検索する。',
	'__ANONYMOUS_COMMENTER' => '匿名ユーザー',
	'Search for other comments from this deleted commenter' => '削除されたユーザーからのコメントを検索する。',
	'(Deleted)' => '削除されたユーザー',
	'Edit this [_1] commenter.' => '[_1]であるコメンターを編集する。',
	'Comments on [_1]: [_2]' => '[_1] [_2]のコメント',
	'Not spam' => 'スパムではない',
	'Reported as spam' => 'スパム',
	'All comments by [_1] \'[_2]\'' => '[_1]\'[_2]\'のコメント',
	'__COMMENTER_APPROVED' => '承認',
	'Moderator' => 'モデレータ',
	'Can comment and manage feedback.' => 'コメントを投稿し、コメントやトラックバックを管理できます。',
	'Can comment.' => 'コメントを投稿できます。',
	'Comments on My Entries/Pages' => '自分の記事/ウェブページへのコメント',
	'Entry/Page Status' => '記事/ウェブページの公開状態',
	'Date Commented' => 'コメント日',
	'Comments in This Website' => 'ウェブサイトのコメント',
	'Comments in This Site' => 'このサイトのコメント',
	'Non-spam comments' => 'スパムでないコメント',
	'Non-spam comments on this website' => 'ウェブサイトのスパムでないコメント',
	'Pending comments' => '保留中のコメント',
	'Published comments' => '公開されているコメント',
	'Comments on my entries/pages' => '自分の記事/ウェブページへのコメント',
	'Comments in the last 7 days' => '最近7日間以内のコメント',
	'Spam comments' => 'スパムコメント',
	'Enabled Commenters' => '有効なコメント投稿者',
	'Disabled Commenters' => '無効なコメント投稿者',
	'Pending Commenters' => '保留中のコメント投稿者',
	'Externally Authenticated Commenters' => '外部サービスで認証されたコメント投稿者',
	'Entries with Comments Within the Last 7 Days' => '最近7日間以内にコメントされた記事',
	'Pages with comments in the last 7 days' => '最近7日間以内にコメントされたウェブページ',

## plugins/Comments/lib/Comments/App/ActivityFeed.pm
	'[_1] Comments' => '[_1]へのコメント',
	'All Comments' => 'すべてのコメント',

## plugins/Comments/lib/Comments/App/CMS.pm
	'Are you sure you want to remove all comments reported as spam?' => 'スパムコメントをすべて削除しますか?',
	'Delete all Spam comments' => '全てのスパムコメントを削除する',

## plugins/Comments/lib/Comments/Blog.pm
	'Cloning comments for blog...' => 'コメントを複製しています...',

## plugins/Comments/lib/Comments/CMS/Search.pm

## plugins/Comments/lib/Comments/Import.pm
	'Creating new comment (from \'[_1]\')...' => '\'[_1]\'からのコメントをインポートしています...',
	'Saving comment failed: [_1]' => 'コメントを保存できませんでした: [_1]',

## plugins/Comments/lib/Comments/Upgrade.pm
	'Creating initial comment roles...' => 'コメント権限を作成しています...',

## plugins/Comments/lib/MT/App/Comments.pm
	'Error assigning commenting rights to user \'[_1] (ID: [_2])\' for weblog \'[_3] (ID: [_4])\'. No suitable commenting role was found.' => '\'[_1]\' (ID:[_2])にブログ\'[_3]\'(ID:[_2])へのコメント権限を与えられませんでした。コメント権限を与えるためのロールが見つかりません。',
	'Invalid commenter login attempt from [_1] to blog [_2](ID: [_3]) which does not allow Movable Type native authentication.' => '[_1]がブログ[_2](ID:[_3])にサインインしようとしましたが、このブログではMovable Type認証が有効になっていません。',
	'Successfully authenticated, but signing up is not allowed.  Please contact your Movable Type system administrator.' => '認証されましたが、登録は許可されていません。システム管理者に連絡してください。',
	'You need to sign up first.' => '先に登録してください。',
	'Login failed: permission denied for user \'[_1]\'' => 'サインインに失敗しました。[_1]には権限がありません。',
	'Login failed: password was wrong for user \'[_1]\'' => 'サインインに失敗しました。[_1]のパスワードが誤っています。',
	'Signing up is not allowed.' => '登録はできません。',
	'Movable Type Account Confirmation' => 'Movable Type アカウント登録確認',
	'Your confirmation has expired. Please register again.' => '有効期限が過ぎています。再度登録してください。',
	'<a href="[_1]">Return to the original page.</a>' => '<a href="[_1]">元のページに戻る</a>',
	'Commenter \'[_1]\' (ID:[_2]) has been successfully registered.' => 'コメント投稿者\'[_1]\'(ID:[_2])が登録されました。',
	'Thanks for the confirmation.  Please sign in to comment.' => '登録ありがとうございます。サインインしてコメントしてください。',
	'[_1] registered to the blog \'[_2]\'' => '[_1]がブログ\'[_2]\'に登録されました。',
	'No id' => 'IDがありません。',
	'No such comment' => 'コメントがありません。',
	'IP [_1] banned because comment rate exceeded 8 comments in [_2] seconds.' => '[_1]からのコメントが[_2]秒間に8個続いたため、このIPアドレスを禁止リストに登録しました。',
	'IP Banned Due to Excessive Comments' => '大量コメントによるIP禁止',
	'No such entry \'[_1]\'.' => '記事\'[_1]\'がありません。',
	'_THROTTLED_COMMENT' => '短い期間にコメントを大量に送りすぎです。しばらくたってからやり直してください。',
	'Comments are not allowed on this entry.' => 'この記事にはコメントできません。',
	'Comment text is required.' => 'コメントを入力していません。',
	'Registration is required.' => '登録しなければなりません。',
	'Name and E-mail address are required.' => '名前とメールアドレスは必須です。',
	'Invalid URL \'[_1]\'' => 'URL([_1])は不正です。',
	'Comment save failed with [_1]' => 'コメントを保存できませんでした: [_1]',
	'Comment on "[_1]" by [_2].' => '[_2]が\'[_1]\'にコメントしました。',
	'Failed comment attempt by pending registrant \'[_1]\'' => 'まだ登録を完了していないユーザー\'[_1]\'がコメントしようとしました。',
	'You are trying to redirect to external resources. If you trust the site, please click the link: [_1]' => '外部のサイトへリダイレクトしようとしています。あなたがそのサイトを信頼できる場合、リンクをクリックしてください。[_1]',
	'No entry was specified; perhaps there is a template problem?' => '記事が指定されていません。テンプレートに問題があるかもしれません。',
	'Somehow, the entry you tried to comment on does not exist' => 'コメントしようとした記事がありません。',
	'Invalid entry ID provided' => '記事のIDが不正です。',
	'All required fields must be populated.' => '必須フィールドのすべてに正しい値を設定してください。',
	'Commenter profile has successfully been updated.' => 'コメント投稿者のユーザー情報を更新しました。',
	'Commenter profile could not be updated: [_1]' => 'コメント投稿者のユーザー情報を更新できませんでした: [_1]',

## plugins/Comments/lib/MT/CMS/Comment.pm
	'No such commenter [_1].' => '[_1]というコメント投稿者は存在しません。',
	'User \'[_1]\' trusted commenter \'[_2]\'.' => '\'[_1]\'がコメント投稿者\'[_2]\'を承認しました。',
	'User \'[_1]\' banned commenter \'[_2]\'.' => '\'[_1]\'がコメント投稿者\'[_2]\'を禁止しました。',
	'User \'[_1]\' unbanned commenter \'[_2]\'.' => '\'[_1]\'がコメント投稿者\'[_2]\'を保留にしました。',
	'User \'[_1]\' untrusted commenter \'[_2]\'.' => '\'[_1]\'がコメント投稿者\'[_2]\'の承認を取り消しました。',
	'The parent comment id was not specified.' => '返信先のコメントが指定されていません。',
	'The parent comment was not found.' => '返信先のコメントが見つかりません。',
	'You cannot reply to unapproved comment.' => '未公開のコメントには返信できません。',
	'You cannot create a comment for an unpublished entry.' => '公開されていない記事にはコメントできません。',
	'You cannot reply to unpublished comment.' => '公開されていないコメントには返信できません。',
	'Comment (ID:[_1]) by \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => '\'[_3]\'がコメント\'[_1]\'(ID:[_2])を削除しました。',
	'You do not have permission to approve this trackback.' => 'トラックバックを承認する権限がありません。',
	'The entry corresponding to this comment is missing.' => '存在しない記事に対してコメントしています。',
	'You do not have permission to approve this comment.' => 'コメントを公開する権限がありません。',
	'Orphaned comment' => '記事のないコメント',

## plugins/Comments/lib/MT/DataAPI/Endpoint/Comment.pm

## plugins/Comments/lib/MT/Template/Tags/Comment.pm
	'The MTCommentFields tag is no longer available.  Please include the [_1] template module instead.' => 'MTCommentFieldsタグは利用できません。代わりにテンプレートモジュール「[_1]」をインクルードしてください。',

## plugins/Comments/lib/MT/Template/Tags/Commenter.pm
	'This \'[_1]\' tag has been deprecated. Please use \'[_2]\' instead.' => 'テンプレートタグ \'[_1]\' は廃止されました。代わりに \'[_2]\'を使用してください。',

## plugins/Comments/php/function.mtcommentauthor.php

## plugins/Comments/php/function.mtcommentauthorlink.php

## plugins/Comments/php/function.mtcommenternamethunk.php
	'The \'[_1]\' tag has been deprecated. Please use the \'[_2]\' tag in its place.' => 'テンプレートタグ \'[_1]\' は廃止されました。代わりに \'[_2]\'を使用してください。',

## plugins/Comments/php/function.mtcommentreplytolink.php

## plugins/Comments/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Image photo',

## plugins/Comments/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Original Test',

## plugins/Comments/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml

);

1;
