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