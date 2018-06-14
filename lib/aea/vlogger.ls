require! './logger': {Logger}

export class VLogger
    (@context, name)->
        @logger = new Logger (name or \VLogger)
        @clog = @logger.log
        @cerr = @logger.err
        @cwarn = @logger.warn

        @modal = @context.root.find-component \logger

        unless @modal
            @logger.err "VLogger class requires 'logger' component. Add it first."
            return

    info: (msg, callback) ->
        if typeof! callback is \Object
            @cerr "DEPRECATED IMMEDIATELY: Do not use opts for VLogger."

        msg = message: msg if typeof! msg is \String
        default-opts =
            title: 'Info'
            icon: 'info sign'
            closable: yes

        @modal.fire \showDimmed, {}, (default-opts <<< msg), callback

    error: (msg, callback) ->
        if typeof! callback is \Object
            @cerr "DEPRECATED IMMEDIATELY: Do not use opts for VLogger."

        msg = message: msg if typeof! msg is \String
        default-opts =
            title: 'Error'
            icon: 'warning sign'
            closable: yes
        @modal.fire \showDimmed, {}, (default-opts <<< msg), callback

    yesno: (msg, callback) ->
        if typeof! callback is \Object
            @cerr "DEPRECATED IMMEDIATELY: Do not use opts for VLogger."

        msg = message: msg if typeof! msg is \String
        default-opts =
            title: 'Yes or No'
            icon: 'map signs'
            closable: no
            buttons:
                no:
                    text: 'No'
                    color: \red
                    icon: \remove

                yes:
                    text: \Yes
                    color: \green
                    icon: \remove
        @modal.fire \showDimmed, {}, (default-opts <<< msg), callback
