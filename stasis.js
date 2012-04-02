(function() {
  var highlightNav, smoothScroll;

  smoothScroll = function() {
    return $('a[href*=#]').click(function() {
      var anchor, ran, target;
      anchor = $(this).attr('href').match(/#(.*)/)[1];
      target = $('a[name=' + anchor + ']');
      ran = false;
      $('html, body').animate({
        scrollTop: target.offset().top - 60
      }, 400, function() {
        var offset;
        if (!ran) {
          offset = this.scrollTop;
          location.hash = anchor;
          this.scrollTop = offset;
        }
        return ran = true;
      });
      return false;
    });
  };

  highlightNav = function() {
    var anchor_links, anchors, positions, scrollHappened;
    anchors = $('h2 a[name]');
    anchor_links = $('ul a');
    positions = anchors.map(function(i, item) {
      return $(item).offset().top;
    });
    anchors = $.makeArray(anchors).reverse();
    anchor_links = $.makeArray(anchor_links).reverse();
    positions = $.makeArray(positions).reverse();
    scrollHappened = function() {
      var anchor_index, scroll_y;
      anchor_index = null;
      scroll_y = this.scrollY;
      $.each(positions, function(i, item) {
        if (scroll_y >= item - 70) {
          anchor_index = i;
          return false;
        }
      });
      if (anchor_index != null) {
        $(anchor_links).removeClass('selected');
        $(anchor_links[anchor_index]).addClass('selected');
      }
      if (scroll_y < positions[positions.length - 1] - 70) {
        return $(anchor_links).removeClass('selected');
      }
    };
    $(window).scroll(scrollHappened);
    return scrollHappened();
  };

  $(function() {
    smoothScroll();
    return highlightNav();
  });

}).call(this);
