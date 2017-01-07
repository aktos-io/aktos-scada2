require! 'aea':{pack, unpack}

Ractive.components['assign'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        try
            if @get \if-null
                # only update if output is null at the beginning
                #console.log "...update if null at the beginning..."
                output = @get \output
                if output not in [void, null, '']
                    #console.log "...but the output isnt null (#{@get 'output'})"
                    return
            @observe \input, (new-val, old-val) ->
                #console.log "ASSIGN: assigning new value: ", new-val
                @set \output, unpack pack new-val
        catch
            debugger
