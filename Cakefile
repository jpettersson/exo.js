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
    output: 'lib/spine.exo.js' 
    files: [
      'src/spine/controller.coffee'
      'src/spine/list.coffee'
      'src/spine/model.coffee'
    ]
  }
]

SPEC_PACKAGES = [
  {
    output: 'test/build/core.specs.js'
    files: [
      'test/specs/state_machine_spec.coffee'
      'test/specs/node_spec.coffee'
      'test/specs/spine/controller_spec.coffee'
    ]
  },
  {
    output: 'test/build/spine.specs.js'
    files: [
      'test/specs/spine/controller_spec.coffee'
    ]
  }
]

task 'build', 'Build project', ->
  build LIB_PACKAGES, 'lib'

task 'test', 'Run tests', ->
  build LIB_PACKAGES.concat(SPEC_PACKAGES),-> test()


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

  # tester = (file) ->
  #   (callback) ->
  #     mochaCmd = 'mocha' + if process.platform is 'win32' then '.cmd' else ''
  #     mocha = spawn mochaCmd, ['-u', 'bdd', '-R', 'spec', '-t', '20000', '--colors', "test/lib/#{file}"]
  #     mocha.stdout.pipe process.stdout, end: false
  #     mocha.stderr.pipe process.stderr, end: false
  #     mocha.on 'exit', (code) -> callback?(code,code)

  # testFiles = ['mocha-phantomjs.js']
  # testers = (tester file for file in testFiles)
  # async.series testers, (err, results) -> 
  #   passed = results.every (code) -> code is 0
  #   process.exit if passed then 0 else 1


# buildSpecs = ->
#   specs = [
#     'test/specs/state_machine_spec.coffee'
#     'test/specs/node_spec.coffee'
#     'test/specs/spine/controller_spec.coffee'
#   ]

#   compileCoffeeScript ['-cj', "test/specs.js"].concat(specs)

# task 'build', 'Build lib/ from src/', ->
#   buildLib()

# task 'test', "Run the test suites", ->
#   buildLib()
#   buildSpecs()

#   mocha = spawn 'mocha-phantomjs', ['-R dot', 'test/test.html']
#   #mocha = spawn 'mocha', ['--compilers', 'coffee:coffee-script', 'test/test_helper.coffee'], {stdio: "inherit"}

