{spawn, exec} = require 'child_process'

call = (command, args = [], fn = null) ->
    exec "#{command} #{args.join(' ')}", (err, stdout, stderr) ->
        if err?
            console.error "Error :"
            return console.dir   err
        fn err if fn

system = (command, args) ->
    spawn command, args, stdio: "inherit"

build = (fn = null) ->
    call 'coffee',      ['-c', '-o', 'lib', 'src']
    call 'coffee',      ['-c', '-o', 'examples', 'examples']
    call 'coffee',      ['-c', '-o', 'tests', 'tests']
    do fn if fn

docgen = (fn = null) ->
    system './node_modules/doxx/bin/doxx', ['--source', 'lib/', '--target', 'docs/', '--template', 'docgen/template.jade']
    do fn if fn

watch = (fn = null) ->
    system 'coffee',    ['-w', '-c', '-o', 'lib', 'src']
    system 'coffee',    ['-w', '-c', '-o', 'examples', 'examples']
    system 'coffee',    ['-w', '-c', '-o', 'tests', 'tests']
    do fn if fn

task 'watch', 'continually build the JavaScript code', ->
    watch ->
        console.log "Done !"

task 'build', 'build the JavaScript code', ->
    build ->
        console.log "Done !"

task 'docs', 'build the docs', ->
    build ->
        docgen ->
            console.log "Done !"
