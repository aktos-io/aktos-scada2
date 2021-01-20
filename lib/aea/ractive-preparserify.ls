require! <[ through pug path ]>  
require! 'ractive': Ractive
require! '../../templates/filters': {pug-filters}
/*******************************************************************************
USAGE:

    ractive = new Ractive do
        el: '#main-output'
        template: require('./base.pug')

********************************************************************************/

preparse-pug = (filename, template) ->
    """
    Returns {parsed, dependencies}
    """
    ext = path.extname filename 
    dirname = path.dirname filename
    template-full-path = path.join dirname, filename

    dependencies = [filename]
    error = null 
    try 
        if ext is \.html 
            template-html = template 
        else if ext is \.pug
            # include templates/mixins.pug file
            mixin-relative = path.relative dirname, process.cwd!
            template = """
                include #{mixin-relative}/templates/mixins.pug
                #{template}
                """
            # TODO: We should get dependencies and rendered content in one function call
            opts = {filename: filename, filters: pug-filters, doctype: 'html'}
            compile = pug.compile template, opts
            deps = (pug.compileClientWithDependenciesTracked template, opts).dependencies
            # End of TODO
            dependencies ++= deps 
            template-html = compile!
        parsed = Ractive.parse template-html
    catch 
        error = e 
    
    return {parsed, dependencies, error}

function isTemplate file
    return /.*\.(html|pug)$/.test(file);

export ractive-preparserify = (file) ->
        if not isTemplate(file)
            return through()        
 
        #console.log "Ractive preparserifying file: #file"
        contents = ''
        write = (chunk) !->
            contents += chunk.to-string \utf-8

        end = -> 
            x = preparse-pug file, contents
            for x.dependencies
                # register the dependencies to browserify
                @emit \file, ..

            unless x.error 
                @queue "module.exports = #{JSON.stringify x.parsed}"
            else
                console.error "Preparserify error: ", x.error
                @emit 'error', x.error 
            @queue null 

        return through write, end
