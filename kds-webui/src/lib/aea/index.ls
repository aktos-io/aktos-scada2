require! {
    './cca-pouchdb-auth': {
        signup
    }
    './merge': {
        merge
    }
    './sleep': {
        sleep
        after
        clear-timer
    }
    './signal': {
        wait-for
        timeout-wait-for
        go
    }
    './debug-log': {
        debug-log
    }
}

PouchDB = require \pouchdb
    ..plugin require \pouchdb-authentication

module.exports = {
    signup, PouchDB
    sleep, after, clear-timer
    merge
    wait-for, timeout-wait-for, go
    debug-log
}