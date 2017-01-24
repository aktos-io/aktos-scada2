
component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-theme')

component-name = "aea-menu"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-menu')
    isolated: yes
    data: ->
        expand: yes
        show-submenu: no

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-content')

window.is-menu-open = yes
$ \document .ready ->
    $ \.main-sidebar-button .click !->
        if window.is-menu-open
            # close the menu

            $ \.main-sidebar .addClass \collapsed
            $ \.sub-menu-open .removeClass \sub-menu-open
            $ \.glyphicon-chevron-up .removeClass \glyphicon-chevron-up .addClass \glyphicon-chevron-down
        else
            # open the menu

            $ \.main-sidebar .removeClass \collapsed

        window.is-menu-open = !window.is-menu-open
    $ \.menu-item-dropdown .click !->
        $ this .parent! .next \.sub-menu .toggleClass \sub-menu-open
        $ this .toggleClass \glyphicon-chevron-down .toggleClass \glyphicon-chevron-up
