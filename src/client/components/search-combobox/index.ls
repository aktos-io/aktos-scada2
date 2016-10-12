map-to-ascii = (x) ->
    x = x.to-lower-case!
    m = 'çalışöğünÇALIŞÖĞÜN': "calisoguncalisogun"
    for source, target of m
        for i of source
            x = x.replace (new RegExp source[i], "gi"), target[i]
    x

component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        face = $ @find '.face'
        container = $ @find \.selection-list
        searchbox = $ @find \.searchbox
        dd = $ @find \.dropdown

        get-data = ->
            __.get(\data) or []

        face.on \click, ->
            opened = __.get \slVisible
            __.set \slVisible, not opened

        do filter-selection = (new-val) ->
            orig-data = get-data!
            unless new-val
                filtered = orig-data
            else
                filtered = [.. for orig-data when map-to-ascii(..name).index-of(map-to-ascii new-val) > -1 ]
            __.set \filtered, filtered

        @observe \searchedText, filter-selection
        @observe \data, ->
            filter-selection ''

        @on do
            select: (val) ->
                selected-text = [..name for get-data! when ..id is val].0 or __.get \selectedText
                __.set \selected, val
                __.set \selectedText, selected-text
                __.set \slVisible, no 


        selected = @get \selected
        if selected
            @fire \select, selected

        @observe \selected, (val) ->
            /*
            # try to convert selected into integer
            unless isNaN parse-int val
                val = parse-int val
            */
            __.fire \select, val

    data: ->
        sl-visible: no
        selected-text: "Seçim Yapılmadı"
        searched-text: ''
