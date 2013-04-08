fs      = require 'fs'
path    = require 'path'
async   = require 'async'
{print} = require 'util'
{spawn} = require 'child_process'

LIB_PACKAGES = [
  { 
    output: 'lib/exo.js'
    files: [
      'src/core/exo.coffee'
      'src/core/state_machine.coffee'
      'src/core/node.coffee' 
    ] 
  },
  { 
    output: 'lib/exo.spine.js' 
    files: [
      'src/spine/controller.coffee'
      'src/spine/list.coffee'
      'src/spine/model.coffee'
      'src/spine/modules/css_transitioner.coffee'
      'src/spine/modules/dom_inflater.coffee'
    ]
  }
]

SPEC_PACKAGES = [
  {
    output: 'test/build/core.specs.js'
    files: [
      'test/specs/state_machine_spec.coffee'
      'test/specs/node_spec.coffee'
    ]
  },
  {
    output: 'test/build/spine.specs.js'
    files: [
      'test/specs/spine/controller_spec.coffee'
      'test/specs/spine/list_spec.coffee'
      'test/specs/spine/model_spec.coffee'
      'test/specs/spine/modules/css_transitioner_spec.coffee'
      'test/specs/spine/modules/dom_inflater_spec.coffee'
    ]
  }
]

task 'build', 'Build project', ->
  build LIB_PACKAGES, 'lib'

task 'test', 'Run tests', ->
  build LIB_PACKAGES.concat(SPEC_PACKAGES),-> test()

task 'doc', 'Generate documentation', ->
  spawn 'codo', ['src/'], {stdio: "inherit"}

build = (packages, callback) ->
  builder = (args...) ->
    (callback) ->
      coffeeCmd = 'coffee' + if process.platform is 'win32' then '.cmd' else ''
      console.log coffeeCmd, args.join(' ')
      coffee = spawn coffeeCmd, args
      coffee.stderr.on 'data', (data) -> process.stderr.write data.toString()
      coffee.stdout.on 'data', (data) -> print data.toString()
      coffee.on 'exit', (code) -> callback?(code,code)

  jobs = packages.map((pack)-> 
    builder.apply @, ['-c', '-j', pack.output].concat(pack.files)
  )

  async.parallel(jobs, (err, results) -> callback?() unless err)

test = ->
  mochaCmd = 'mocha-phantomjs' + if process.platform is 'win32' then '.cmd' else ''
  args = ['-R', 'dot', 'test/test.html']
  
  console.log mochaCmd, args.join ' '
  spawn mochaCmd, args, {stdio: "inherit"}