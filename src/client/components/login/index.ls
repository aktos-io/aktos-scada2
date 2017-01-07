/*
    context =
        ok: true/false login ok
        err: true/false login err
        user:
            name: user name
            passwd: user password
*/

require! 'aea': {gen-entry-id, hash8, sleep, pack, CouchNano, merge}
require! \cradle

config =
    cloudant:
        url: "https://demeter.cloudant.com"
        port: 443
        database: "domates2"

    aktos:
        url: "https://aktos.io/couchdb"
        port: 443
        database: "domates7"

    local:
        url: "http://10.0.9.92"
        port: 5984
        database: "domates7"


Ractive.components['login'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        __ = @
        username-input = $ @find \.username-input
        password-input = $ @find \.password-input
        login-button = @find-component \ack-button
        enter-key = 13
        checking-logged-in = $ @find \.check-state

        username-input.on \keyup, (key) ->
            if key.key-code is enter-key
                password-input.focus!
            <- sleep 10ms
            inp = username-input.val!
            lower = inp.to-lower-case!
            __.set \warnCapslock, (inp isnt lower)
            username-input.val lower

        password-input.on \keyup, (key) ->
            if key.key-code is enter-key
                login-button.fire \click

        @on do
            do-login: (e, server) ->
                db-conf = config[server]
                __ = @
                # setup db

                #err, key <- server.open-session
                #debugger
                #return

                db-opts =
                    cache: yes
                    raw: no
                    force-save: yes
                    retries: 3
                    retryTimeout: 30_000ms
                    request:
                        jar: true

                e.component.fire \state, \doing
                user = __.get \context ._user
                unless user
                    return e.component.fire \state, \error, "Kullanıcı adı/şifre boş olamaz!"

                db-opts.auth =
                    username: user.name
                    password: user.password

                conn = new(cradle.Connection) db-conf.url, db-conf.port, db-opts
                db = conn.database db-conf.database
                db.gen-entry-id = gen-entry-id
                db.hash = hash8

                get-credentials = (callback) ->
                    unless user.name is \demeter
                        err, res <- conn.database "_users" .get "org.couchdb.user:#{user.name}"
                        if err
                            console.error err
                            e.component.fire \state, \error, err.message
                            return
                        callback res
                    else
                        res =
                            user: \demeter
                            roles:
                                \admin
                                ...
                        callback res

                res <- get-credentials

                context =
                    ok: yes
                    err: null
                    user: res

                # FIXME: workaround for not being login via cookie
                #username-input.val ''
                #password-input.val ''

                __.set \db, db
                __.set \context, context
                __.fire \success
                e.component.fire \state, \done...

            do-logout: (e) ->
                __ = @
                e.component.fire \state, \doing
                #console.log "LOGIN: Logging out!"

                # FIXME: workaround for not being login via cookie
                username-input.val ''
                password-input.val ''

                err, res <- __.get \db .logout!
                #console.log "LOGIN: Logged out: err: #{err}, res: ", res
                if err
                    e.component.fire \state, \error, err.message
                    __.set \context.err err
                    return

                if res.ok
                    __.set \context.ok, no
                    __.fire \logout
                    e.component.fire \state, \done...

            logout: ->
                console.log "LOGIN: We are logged out..."

    data: ->
        context: null
        db: null
        username-placeholder: \Username
        password-placeholder: \Password
        warn-capslock: no
        server-list:
            * id: \aktos
              name: "Cici Meze (Begos, İzmir)"
            * id: \cloudant
              name: "Cloudant (Avusturya)"
            #* id: \local
            #  name: "CM (Failover)"
        selected-server: \aktos
