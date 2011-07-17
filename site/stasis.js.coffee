smoothScroll = ->
  $('a[href*=#]').click ->
    anchor = $(this).attr('href').match(/#(.*)/)[1]
    target = $('a[name=' + anchor + ']')
    ran = false
    $('html, body').animate { scrollTop: target.offset().top - 60 }, 400, ->
      unless ran
        offset = this.scrollTop
        location.hash = anchor
        this.scrollTop = offset
      ran = true
    false

highlightNav = ->
  anchors = $('h2 a[name]')
  anchor_links = $('ul a')
  positions = anchors.map (i, item) ->
    $(item).offset().top

  anchors = $.makeArray(anchors).reverse()
  anchor_links = $.makeArray(anchor_links).reverse()
  positions = $.makeArray(positions).reverse()

  scrollHappened = ->
    anchor_index = null
    scroll_y = this.scrollY
    $.each positions, (i, item) ->
      if scroll_y >= item - 70
        anchor_index = i
        return false
    if anchor_index?
      $(anchor_links).removeClass 'selected'
      $(anchor_links[anchor_index]).addClass 'selected'
    if scroll_y < positions[positions.length - 1] - 70
      $(anchor_links).removeClass 'selected'

  $(window).scroll scrollHappened
  scrollHappened()

$ ->
  smoothScroll()
  highlightNav()