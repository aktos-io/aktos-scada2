require! 'prelude-ls': {take, drop, split, find}

export basename = (.split(/[\\/]/).pop!) # https://stackoverflow.com/questions/3820381#comment29942319_15270931

export get-offset = ->
    $ 'body' .scrollTop!

export scroll-to = (anchor) ->
    offset = $ "span[data-id='#{anchor}']" .offset!
    if offset
        dist = (offset?.top or 0) - (window.top-offset or 0)
        x= $ 'html, body' .animate {scrollTop: dist}, 200ms, -> 
            #console.log "Animation is completed?"

export make-link = (scene, anchor) ->
    curr = parse-link get-window-hash!
    scene-part = if scene? => that else curr.scene

    scene-part = if scene-part
        '#/' + that
    else
        '#'

    anchor-part = if anchor?
        '#' + that
    else
        ''

    link = scene-part + anchor-part
    #console.log "Making link from scene: #{scene}, anchor: #{anchor} => #{link} (curr.scene: #{curr.scene})"
    return link

export get-window-hash = ->
    hash = window.location.hash
    _hash = hash.replace '%23', '#'
    if hash isnt _hash
        hash = _hash
        set-window-hash hash, silent=yes
    hash or '#/'

hash-listener = ->
_scroll-top = null

export set-window-hash = (hash, silent) ->
    #console.log "setting window hash to: #{hash}, curr is: #{window.location.hash}"
    if history.pushState
        history.pushState(null, null, hash)
    else
        window.location.hash = hash

    unless silent
        hash-listener hash

export parse-link = (link) ->
    if link.match /http[s]?:\/\//
        return {external: yes}

    [scene, anchor] = ['/', '']
    switch take 2, link
    | '#/' => [scene, anchor] = drop 2, link .split '#'
    | '##' => [scene, anchor] = ['', (drop 2, link)]
    |_     => [scene, anchor] = [undefined, (drop 1, link)]

    #console.log "parsing link: #{link} -> scene: #{scene}, anchor: #{anchor}"
    return do
        scene: scene
        anchor: anchor

export change-hash-listener = (listener) -> 
    hash-listener := listener 


export set-scroll-top = (val) -> 
    _scroll-top := val 

export get-scroll-top = -> 
    _scroll-top