require! 'prelude-ls': {group-by, keys}
require! './merge': {merge}
x =
    * client: \eee
      a:
          * x: 11    # mold-type
            y: 2     # recipe
            z: \cc   # lot
          * x: 12
            y: 2
            z: \bb
      b: 2

    * client: \iii
      a:
          * x: 12
            y: 3
            z: \aa
          * x: 14
            y: 5
            z: \aa
      b: 3

vres =
    11:
        2:
            cc:
                client: \eee
                a:
                    * x: 11
                      y: 2
                      z: \cc
                    ...
    12:
        2:
            bb:
                client: \eee
                a:
                    * x: 12
                      y: 2
                      z: \bb
                    ...

        3:
            aa:
                client: \iii
                a:
                    * x: 12
                      y: 3
                      z: \aa
                    ...

    14:
        5:
            aa:
                client: \iii
                a:
                    * x: 14
                      y: 5
                      z: \aa
                    ...


obj-copy = (x) -> JSON.parse JSON.stringify x

res = {}
for o in x
    o.a = group-by (.x), o.a

    for i in keys o.a
        o__ = obj-copy o
        o__.a = o.a[i]
        attach res, i, o__

console.log "res: ", JSON.stringify res, null, 2

res2 = {}
for k, oo of res
    for o in oo
        o.a = group-by (.y), o.a

        for i in keys o.a
            o__ = obj-copy o
            o__.a = o.a[i]
            res2 `merge` {"#{k}": "#{i}": o__}

console.log "res2: ", JSON.stringify res2, null, 2

res3 = {}
for k, oo of res2
    for kk, o of oo
        o.a = group-by (.z), o.a
        console.log "o.a: ", o.a
        for i in keys o.a
            o__ = obj-copy o
            o__.a = o.a[i]
            x =  {"#{k}": "#{kk}": "#{i}": o__}
            console.log x
            res3 `merge` x

console.log "res3: ", JSON.stringify res3, null, 2
