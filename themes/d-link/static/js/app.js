// object-fit IE対応
if (typeof objectFitImages === 'function') {
  objectFitImages('.js-fit');
}

/**
* スクロール要素の取得
* @return {Object} スクロール対象となるオブジェクト
*/
var scrollElm = (function() {
  if ('scrollingElement' in document) {
    return document.scrollingElement;
  }
  if (navigator.userAgent.indexOf('WebKit') != -1) {
    return document.body;
  }
  return document.documentElement;
})();

var $window = $(window);

/**
* ページをスクロールさせる関数
* @type {Object} $t スクロール位置
*/
function scrollAnimate($t) {
  var headerHeight = $('.js-header')[0] ? $('.js-header').outerHeight() : 0,
    targetTop = $t.offset().top - headerHeight;
  $(scrollElm).animate({
    scrollTop: targetTop
  }, 400);
}

//共通アンカーボタン
$('.js-anchor').on('click', function (e) {
  e.preventDefault();
  var $this = $(this);
  var href = $this.attr('href');
  $target = $(href === '#' || href === '' ? 'html' : href);
  scrollAnimate($target);
});

// トップに戻るボタンのスクロール制御
var $pagetopBtn = $('.js-totop');
$window.on('scroll resize', function () {
  var windowScrollTop = $window.scrollTop();
  var windowHeight = $window.outerHeight();
  btnVisible($pagetopBtn, windowScrollTop, windowHeight);
});

//アニメーションが終わったら非表示にする
$pagetopBtn.on('animationend', function () {
  var $this = $(this);
  if ($this.hasClass('is-hidden')) {
    $this.removeClass('is-visible');
  }
});

/**
* トップに戻るボタンの表示切替
* @type {Object} $e トップに戻るボタン
* @type {Number} s ウィンドウのスクロール位置
* @type {Number} h ウィンドウの高さ
*/
function btnVisible($e, s, h) {
  if (s < h) {
    $e.addClass('is-hidden');
  }
  else {
    $e.removeClass('is-hidden');
    $e.addClass('is-visible');
  }
}
btnVisible($pagetopBtn, $window.scrollTop(), $window.outerHeight());

// ヘッダーのカレント表示
var pageURL = location.pathname;
var pageURLArr = pageURL.split('/');
var pageURLArrCategory = pageURLArr[1];
var pageURLArrSubCategory = pageURLArr[2];

$('.js-nav_current a').each(function (i, e) {
  var $self = $(e);
  var selfhref = $self.attr('href');
  var hrefArr = selfhref.split('/');
  var hrefArrCategory = hrefArr[1];

  //パスの第1階層とhref属性の第1階層を比較して同じ値であればcurrentを付与する
  if (pageURLArrCategory === hrefArrCategory) {
    $self.addClass('is-current');
  }
});

// ローカルナビの自動カレント表示
if ($('.js-local_nav_current')[0]) {
  $('.js-local_nav_current a').each(function (i, e) {
    var $self = $(e);
    var selfhref = $self.attr('href');
    var hrefArr = selfhref.split('/');
    var hrefArrCategory = hrefArr[1];
    var hrefArrSubCategory = hrefArr[2];

    if (pageURLArrCategory === hrefArrCategory && pageURLArrSubCategory === hrefArrSubCategory) {
      $self.addClass('is-current');
    }
  });
}

// フッターの外部リンクのアイコンをマウスオンで切り替える
$('.js-toggle_png').hover(
  function () {
    var $img = $(this).find('img');
    var replace_str = $img.attr('src').replace('.png', '_on.png');
    $img.attr('src', replace_str);
  },
  function () {
    var $img = $(this).find('img');
    var replace_str = $img.attr('src').replace('_on.png', '.png');
    $img.attr('src', replace_str);
  }
);

// ハンバーガーメニューを閉じる動作
function close_hamburger() {
  $('.js-menu_open').removeClass('is-active');
  $('.js-hamburger').stop().slideUp();
}

// メガメニューを閉じる動作
function close_megamenu() {
  $('.js-menu').removeClass('is-active');
  $('.js-megamenu_overlay').hide();
  $('.js-megamenu').slideUp();
}

// 検索モジュールを閉じる動作
function close_search() {
  $('.js-search_close').hide();
  $('.js-search_button').show();
  $('.js-search_overlay').hide();
  $('#header_search').stop().slideUp();
}

// SPのハンバーガーメニューを表示する
$('.js-menu_open').on('click', function (e) {
  e.preventDefault();
  var $this = $(this);
  $this.toggleClass('is-active');
  if ($this.hasClass('is-active')) {
    close_search();
    $('.js-hamburger').stop().slideDown();
  }
  else {
    $('.js-hamburger').stop().slideUp();
  }
});

// ハンバーガーメニュー内の閉じるボタン
$('.js-hamburger_close').on('click', function (e) {
  e.preventDefault();
  close_hamburger();
});

// ハンバーガーメニューの子要素の表示を切り替える
$('.js-hamburger_child').on('click', function (e) {
  e.preventDefault();
  var $this = $(this);
  $this.toggleClass('is-active');
  if ($this.hasClass('is-active')) {
    $this.next().stop().slideDown();
  }
  else {
    $this.next().stop().slideUp();
  }
});

// メガメニューを表示するグローバルナビはクリックしても何もしない
$('.js-menu').on('click', function (e) {
  e.preventDefault();
  var $this = $(this);
  var id = $this.attr('href');
  if ($(id).is(':visible')) {
    close_megamenu();
  }
});

// メガメニューを表示するグローバルナビにマウスオンしたらメガメニューを表示する
$('.js-menu').on('mouseenter', function (e) {
  var $this = $(this);
  var id = $this.attr('href');
  close_search();
  if ($(id).is(':hidden')) {
    $('.js-megamenu').hide();
    $this.addClass('is-active');
    $('.js-megamenu_overlay').show();
    $(id).stop().slideDown();
  }
});

// 他のグローバルナビにマウスオンしたときに、メガメニューを非表示にする
$('.js-megamenu_close').on('mouseenter', function () {
  close_megamenu();
});

// メガメニューのオーバーレイをクリックしたらメガメニューを閉じる
$('.js-megamenu_overlay').on('click', function () {
  close_megamenu();
});

// メガメニュー内の閉じるボタンをクリックしたら閉じる
$('.js-menu_close').on('click', function () {
  close_megamenu();
});

// サイト内検索モジュール
var $search_button = $('.js-search_button');
var $search_close = $('.js-search_close');
var $search_overlay = $('.js-search_overlay');
var $header_search = $('#header_search');

//検索モジュールの表示
$search_button.on('click', function (e) {
  e.preventDefault();
  close_megamenu();
  close_hamburger();
  $search_button.hide();
  $search_close.show();
  $search_overlay.show();
  $header_search.stop().slideDown();
});

//検索モジュールの非表示
$search_close.on('click', function (e) {
  e.preventDefault();
  close_search();
});

//検索モジュールのオーバーレイをクリックしたら非表示にする
$search_overlay.on('click', function () {
  close_search();
});

//ニュースのタブ切り替え
if ($('.js-news_tab')[0]) {
  var $news_tab = $('.js-news_tab');
  var $tab_button = $news_tab.find('a');
  $tab_button.on('click', function (e) {
    e.preventDefault();
    var $self = $(this);
    news_tab_change($self);
  });

  // 初回ロード時は一番最初のメニューを表示する
  $news_tab.each(function (i, e) {
    var tab_button_first = $(e).find('a')[0];
    var $tab_button_first = $(tab_button_first);
    $tab_button_first.addClass('is-active');
    news_tab_change($tab_button_first);
  });

  /**
  * 指定のニュースを表示する
  * @type {Object} $el 選択されたタブボタン要素
  */
  function news_tab_change($el) {
    var id = $el.attr('href');
    var $id = $(id);
    if ($tab_button.hasClass('is-active')) {
      $el.parent().siblings().find('a').removeClass('is-active');
      $el.addClass('is-active');
      $id.siblings().hide();
      $id.fadeIn();
    }
    else {
      $id.show();
    }
  }
}

//ニュースの分類選択
if ($('.js-select_show')[0] && $('.js-select_menu')[0] && $('.js-select_list')[0]) {
  $('.js-select_show').on('click', function () {
    $('.js-select_menu').toggleClass('is-active');
    $('.js-select_list').stop().slideToggle();
  });
}
