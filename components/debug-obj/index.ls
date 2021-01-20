Ractive.components['debug-obj'] = Ractive.extend do
    template: require('./index.pug')
    data: ->
        obj: null
        title: null
        public: false
