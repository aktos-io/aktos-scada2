Ractive.components['text-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        @on do
            _buttonclick: (ev, val) ->
                __.fire \buttonclick, ev, (__.get 'amount'), val

    data: ->
        amount: null
        value: null
        disabled: no
        enabled: yes
        inputType: "text"
        buttonType: "info"
