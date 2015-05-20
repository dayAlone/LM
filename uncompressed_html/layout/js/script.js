(function() {
  var debounce, delay, end, sizeAction, triggerNav;

  end = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd';

  delay = function(ms, func) {
    return setTimeout(func, ms);
  };

  sizeAction = function() {
    var el, left, scroll;
    $('.tabs').elem('content').height($(window).height() - 50);
    scroll = $('.packages').elem('scroll');
    if (scroll.length > 0) {
      el = scroll.find('a:nth-child(2)');
      left = (el.position().left + el.width() / 2) - $('body').width() / 2;
      return $('.packages').elem('scroll').animate({
        scrollLeft: left
      }, 300);
    }
  };

  debounce = function(func, wait, immediate) {
    var timeout;
    timeout = void 0;
    return function() {
      var args, callNow, context, later;
      context = this;
      args = arguments;
      later = function() {
        timeout = null;
        if (!immediate) {
          func.apply(context, args);
        }
      };
      callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) {
        func.apply(context, args);
      }
    };
  };

  triggerNav = function(trigger) {
    var el, mod;
    el = $("[data-target='" + (trigger.data('target')) + "']");
    if (el.hasMod('active')) {
      el.mod('active', false);
    } else {
      el.mod('active', true);
    }
    mod = 'open--' + trigger.data('target');
    if ($('body').hasClass(mod)) {
      $('body').removeClass('open');
      $('body').removeClass(mod);
    } else {
      $('body').addClass(mod + ' open');
    }
    return sizeAction();
  };

  $(document).ready(function() {
    var scrollTimer, x;
    $('.sidebar').elem('trigger').on('click scroll touchstart mousewheel', function(e) {
      return debounce(triggerNav($(this)), 400);
    });
    $('.toolbar').elem('trigger').on('click', function(e) {
      triggerNav($(this));
      return e.preventDefault();
    });
    $('.toolbar').elem('profile').on('click', function(e) {
      triggerNav($(this));
      return e.preventDefault();
    });
    $('.present').elem('slider').on('fotorama:showend', function(e, f) {
      var id;
      id = f.activeFrame.id;
      $('.present').elem('content').mod('active', false);
      $("#p-" + id).mod('active', true);
      return console.log($("#p-" + id));
    }).fotorama();
    x = void 0;
    $(window).resize(function() {
      clearTimeout(x);
      return x = delay(200, function() {
        return sizeAction();
      });
    });
    scrollTimer = false;
    $(window).scroll(function() {
      clearTimeout(scrollTimer);
      if (!$('.scroll-fix').hasMod('on')) {
        $('.scroll-fix').mod('on', true);
      }
      return scrollTimer = delay(300, function() {
        return $('.scroll-fix').mod('on', false);
      });
    });
    return delay(300, function() {
      return sizeAction();
    });
  });

}).call(this);
