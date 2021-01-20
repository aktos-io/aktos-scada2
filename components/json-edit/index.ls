require! 'relaxed-json': rjson

Ractive.components['json-edit'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    data: ->
        objTmp: null
        value: null
        err: null
        timeout: 500ms 
        readonly: no 
        title: null 

    computed:
        objFormatted:
            get: ->
                if @get \objTmp
                    that
                else
                    JSON.stringify (@get('value') or null), null, 2

            set: (objStr) ->
                objStr ?= null 
                return if @get \readonly 
                try
                    obj = rjson.parse objStr
                    @set \value, obj
                    @set \objTmp, null
                    @set \err, null
                catch
                    #console.warn "json-edit error was: ", e
                    @set \err, e.message
                    @set \objTmp, objStr
