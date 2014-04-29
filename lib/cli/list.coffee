fs = require 'fs'
{globalPaths, Module} = require 'module'

###*
 * Module that lists modules.
###

###*
 * Return a copy of *array* with duplicates removed.
 * @param  {[type]} array [description]
 * @return {[type]}       [description]
###
removeDuplicates = (array) ->
  map = {}
  map[array[key]] = array[key] for key in [0...array.length]
  return (value for key, value of map)

###*
 * Return first directory found in *paths*, or null if none is found.
 * @param  {[type]} paths [description]
 * @return {[type]}       [description]
###
firstDirectory = (paths) ->
  for dir in paths
    try
      stat = fs.statSync dir
      if stat.isDirectory()
        return dir
    catch error
      throw error if error.code isnt 'ENOENT'
  return null

###*
 * Return a list of available modules for a script running from *cwd*. Will
   also include global modules if *includeGlobal* is true.
###
listModules = (cwd, includeGlobal=true) ->
  modules = []
  modulePaths = []

  if includeGlobal
    # globalPaths contains a empty string for some reason, filter that out
    globalPaths = globalPaths.filter (item) -> item.length
    modulePaths.push firstDirectory globalPaths

  # https://github.com/joyent/node/blob/master/lib/module.js#L202
  localPaths = Module._nodeModulePaths cwd
  modulePaths.push firstDirectory localPaths

  for dir in modulePaths
    continue unless dir? # firstDirectory can return null
    modules = modules.concat fs.readdirSync dir

  modules = modules.filter (name) -> name[0] isnt '.'
  return removeDuplicates modules


module.exports = listModules
