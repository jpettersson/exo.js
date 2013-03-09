{print} = require 'util'
{spawn} = require 'child_process'

build = (pack) ->
  coffee = spawn 'coffee', ['-cj', "lib/#{pack.output}"].concat(pack.files)
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'build', 'Build lib/ from src/', ->
  packages = 
    core:
      output: 'exo.js'
      files: [
        'src/exo.coffee'
        'src/core/state_machine.coffee'
        'src/core/node.coffee'
      ]
    spine:
      output: 'spine.exo.js' 
      files: [
        'src/spine.coffee'
        'src/spine/controller.coffee'
        'src/spine/list.coffee'
        'src/spine/model.coffee'
      ]

  for name, pack of packages
    build pack

task 'test', "Run the core lib test suite", ->
  mocha = spawn 'mocha', ['--compilers', 'coffee:coffee-script', 'test/test_helper.coffee'], {stdio: "inherit"}