$ ->
  $('#query').keyup(() ->
    if $(this).val().length >= 0
      # @todo url_for
      query = { q: $(this).val(), type: $(this).data('search-type') }
      result = $.get('/search_tweet', query, (data) ->
        eval(data)
      , 'text')
  )
