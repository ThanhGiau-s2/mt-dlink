if ($('.js-mv_slider')[0]) {
  var option = {
    autoplay: false,
    autoplaySpeed: 4000,
    speed: 800,
    dotsClass: 'p-mv__dots',
    dots: true,
    fade: true,
    pauseOnHover: true,
  };
  $('.js-mv_slider').slick(option);
}
