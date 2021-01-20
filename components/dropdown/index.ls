"""
Design considerations (TO BE COMPLETED)

* Multiple:

    1. If data is not available but `selected-key` is set, dropdown should display
    a loading icon


# Testing procedure:

1. Place 2 dropdown side by side (exact copy of each other)
2. Change one, expect the other to be exactly the same of the one
"""
require! 'prelude-ls': {find, empty, take, compact}
require! 'actors': {RactiveActor}
require! 'aea': {sleep}

require! 'sifter': Sifter
require! 'dcs/lib/asciifold': asciifold

Ractive.components['dropdown'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    oninit: (ctx) ->
        @actor = new RactiveActor this, do
            name: "dropdown.#{@_guid}"
            debug: yes

        # map attributes to classes
        for attr, cls of {\multiple, 'fit-width': \fluid}
            if @get attr then @set \class, "#{@get 'class'} #{cls}"

        if @get \key => @set \keyField, that
        if @get \name => @set \nameField, that

        if @get \start-with-loading
            @set \loading, yes

        if @getContext!.has-listener \select, yes
            if @get \debug
                @actor.log.debug "Found 'select' listener."
            @set \async, yes

        #@link \selected-item, \item

    onrender: (ctx) ->
        c = @clone-context!
        c.actor = @actor
        dd = $ @find '.ui.dropdown'
        keyField = @get \keyField
        nameField = @get \nameField
        external-change = no

        @push \search-fields, keyField
        @push \search-fields, nameField


        small-part-of = (data) ~>
            if data? and not empty data
                take @get('load-first'), data
            else
                []

        selected-key-observer = null
        update-dropdown = (_new) ~>
            if @get \debug
                @actor.log.log "#{@_guid}: selected key is _being_ changed to: ", _new
            <~ set-immediate
            external-change := yes
            <~ :lo(op) ~>
                try
                    throw {code: 'keyempty'} unless _new
                    if @get \multiple
                        dd.dropdown 'set exactly', _new
                        dd.dropdown 'refresh'
                        return op!
                    else
                        if @get \debug => @actor.log.debug "Setting new visual to #{_new}"
                        if empty ((@get \data) or [])
                            if @get \debug => @actor.log.debug "No data yet, not updating dropdown."
                            return
                        item = find (.[keyField].to-string! is _new), compact @get \dataReduced
                        unless item
                            item = find (.[keyField].to-string! is _new), @get \data
                            unless item
                                # no such key can be found
                                @set \nomatch, true
                                throw {code: \nomatch}
                            else
                                @push \dataReduced, item
                        if item
                            @set \nomatch, false

                        @set \item, item

                        unless (@get \selected-key) is _new
                            # a new selected-key is set by the async handler,
                            # so set selected-key explicitly
                            selected-key-observer.silence!
                            @set \selected-key, _new
                            selected-key-observer.resume!
                        <~ set-immediate
                        dd.dropdown 'set selected', _new
                        dd.dropdown 'refresh'
                        return op!
                catch
                    if e.code in <[ nomatch keyempty ]>
                        dd.dropdown 'restore defaults'
                        @set \item, {}
                        # call the listener with an empty object
                        # useful for handling "clear selection"
                        # button action. When selected key is cleared, all
                        # necessary actions are handled in the listener.
                        @fire \select, c, {}, (err) ~>
                            if err and typeof! err is \String
                                @actor.v-err err
                        return op!
                    else
                        throw e
            external-change := no

        set-item = (value-of-key) ~>
            if @get \data
                data = that
                if @get \multiple
                    items = []
                    selected-keys = []
                    selected-names = []
                    for val in value-of-key when val
                        if find (.[keyField].to-string! is val), data
                            items.push that
                            selected-keys.push that[keyField]
                            selected-names.push that[nameField]
                            if @get \debug => @actor.c-log "Found #{val} in .[#{keyField}]", that[keyField]
                        else
                            # how can't we find the item?
                            debugger
                    @set \item, unless empty items => items else [{}]
                    @set \selected-name, selected-names
                    @set \selected-key, selected-keys
                    @fire \select, {}, (unless empty items => items else [{}])
                else
                    # set a single value
                    if find (.[keyField].to-string! is value-of-key), data
                        selected = that
                        if @get('async') or @get('selected-key') isnt that[keyField]
                            if @get \debug => @actor.c-log "selected key is changed to:", selected[keyField]
                            if @get \debug => @actor.c-log "Found #{value-of-key} in .[#{keyField}]", selected, selected[keyField]
                            if @get \async
                                selected-key-observer.silence!
                                @fire \select, c, selected, (err) ~>
                                    unless err
                                        @set \emptyReduced, no
                                        update-dropdown selected[keyField]
                                    else
                                        curr = @get \selected-key
                                        if typeof! err is \String
                                            @actor.v-err err
                                            @actor.c-warn "Error reported for dropdown callback: ", err,
                                                "falling back to #{curr}"
                                        @set \emptyReduced, yes
                                        update-dropdown curr
                                    selected-key-observer.resume!
                            else
                                @set \selected-key, selected[keyField]

                        unless @get \async
                            @set \item, selected
                            @set \selected-name, selected[nameField]
                    #else
                    #    @actor.c-warn "TODO: item not found: ", value-of-key, "how do we handle this? "
                    #    update-dropdown value-of-key
        dd
            .dropdown 'restore defaults'
            .dropdown 'setting', do
                forceSelection: no
                #allow-additions: @get \allow-additions ## DO NOT SET THIS; SEMANTICS' NOT UX FRIENDLY
                full-text-search: (text) ~>
                    @set \search-term, text
                    data = @get \data
                    if text
                        #@actor.c-log "Dropdown (#{@_guid}) : searching for #{text}..."
                        result = @get \sifter .search asciifold(text), do
                            fields: @get \search-fields
                            sort: [{field: nameField, direction: 'asc'}]
                            nesting: no
                            conjunction: "and"

                        reduced = [data[..id] for small-part-of(result.items)]

                        if @get \debug
                            @actor.c-log "Dropdown (#{@_guid}) : searching for #{text}..."
                            @actor.log.debug "Search fields: ", @get \search-fields
                            @actor.log.debug "reduced ids: ", small-part-of(result.items)
                            @actor.c-log "reduced data:", reduced
                        @set \dataReduced, reduced
                        if empty reduced
                            @actor.log.err "No such item found: #{text}"
                        @set \emptyReduced, empty reduced

                        #@actor.c-log "Dropdown (#{@_guid}) : data reduced: ", [..id for @get \dataReduced]
                    else
                        #@actor.c-log "Dropdown (#{@_guid}) : searchTerm is empty"
                        @set \dataReduced, small-part-of data
                on-change: (value, text, selected) ~>
                    if external-change and not @get('listen-external')
                        if @get \debug => @actor.c-log "Dropdown: Exiting from on-change handler as this is an external change."
                        return 
                    if @get \debug => @actor.c-log "Dropdown: #{@_guid}: dropdown is changed: ", value
                    if @get \multiple
                        set-item unless value? => [] else value.split ','
                    else
                        set-item value
                    @set \dataReduced, small-part-of @get \data

        @observe \data, (data) ~>
            if @get \debug => @actor.c-log "Dropdown (#{@_guid}): data is changed: ", data
            <~ set-immediate
            @set \sifter, new Sifter(data or [])
            if data and not empty data
                @set \loading, no
                @set \dataReduced, small-part-of data
                # Update dropdown visually when data is updated
                selected-handler @get \selected-key
                @set \emptyReduced, false
            else
                @set \emptyReduced, true

        @observe \object-data, (_data) ~>
            if _data?
                @set \data, [{id: k, name: k, content: v} for k, v of _data]

        @observe \simple-data, (_data) ~>
            if _data?
                @set \data, [{id: .., name: ..} for _data when ..?]


        selected-handler = (_new, old) ~>
            if @get \multiple
                if typeof! _new is \Array
                    if JSON.stringify(_new or []) isnt JSON.stringify(old or [])
                        update-dropdown _new
            else
                if not (_new? or old?)
                    if @get \debug => @actor.c-log "Observe: Skipping no-change."
                    return 
                if @get \debug => @actor.c-log "Observe: selected key set to:", _new
                #@actor.c-log "DROPDOWN: selected key set to:", _new
                unless @get \data
                    #@actor.c-warn "...but returning as there is no data yet."
                    return
                update-dropdown _new

        selected-key-observer = @observe \selected-key, ((val) ~>
            unless val?
                dd.dropdown 'clear'
            if @get \async
                console.log "this is async mode and item is changed: ", val
                set-item val
            else
                selected-handler val
            ), {-init}

        # first update should be silent
        set-immediate ~> 
            dd.dropdown 'set selected', @get('selected-key')
            dd.dropdown 'refresh'

        @on do
            teardown: ->
                dd.dropdown 'destroy'

            '_add': (ctx) ->
                c.button = ctx.component
                sleep 10, -> dd.dropdown 'show'
                err <~ @fire \add, c, @get \search-term
                # dropdown should only be closed if there is
                # no error returned
                unless err
                    dd.dropdown 'hide'
                    @set \emptyReduced, false
                    @set \search-term, ''
                    # clear the dropdown search field
                    $('.ui.dropdown').find(".search").val("")
    data: ->
        'search-fields': <[ description ]>
        'search-term': ''
        'async': no ## FIXME: we actually don't need this variable.
        data: undefined
        dataReduced: []
        debug: no
        keyField: \id
        nameField: \name
        nothingSelected: '---'
        item: {}
        loading: no
        'start-with-loading': no
        sifter: null
        nomatch: false
        button: null
        inline: null

        # this is very important. if you omit this, "selected"
        # variable will be bound to class prototype (thus shared
        # across the instances)
        'selected-key': null
        'selected-name': null
        'load-first': 100
