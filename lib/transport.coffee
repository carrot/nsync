fs = require 'fs'
async = require 'async'
path = require 'path'

###*
 * Base class for transports
###
class Transport

  ###*
   * Constructor, *options* are passed in from the cli tool or manually when
     using nsync as a library. Transports are responsible for validating their
     own options and should throw an error if something is amiss.
   * @param {[type]} options [description]
   * @return {[type]} [description]
  ###
  constructor: (options) ->

  ###*
   * Do any needed setup here, callback when done.
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  setup: (callback) ->

  ###*
   * Called after sync completes, do any cleanup needed here. close sockets
     etc.
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  cleanup: (callback) ->

  ###*
   * Callback with a array of filenames and directories in *dirname*.
     Directories should be indicated with a trailing slash (e.g. foo/).
   * @param  {[type]}   dirname  [description]
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  listDirectory: (dirname, callback) ->

  ###*
   * Create *dirname*, *callback* when done.
   * @param  {[type]}   dirname  [description]
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  makeDirectory: (dirname, callback) ->

  ###*
   * Delete directory *dirname*, callback when done. Only needs to handle
     empty directories.
   * @param  {[type]}   dirname  [description]
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  deleteDirectory: (dirname, callback) ->

  ###*
   * Fetching files: you can choose to implement either of the following
     methods. createReadStream is prefered and will be used first if
     implemented.
  ###

  ###*
   * Return a readable stream for *filename*. File not found and other errors
     should be emitted on stream.
   * @param  {[type]} filename [description]
   * @return {[type]}          [description]
  ###
  createReadStream: (filename) ->

  ###*
   * Callback with a *Stream* or *Buffer* object for *filename*, or an error
     if *filename* can not be found.
   * @param  {[type]}   filename [description]
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  getFile: (filename, callback) ->

  ###*
   * Write *stream* of *size* bytes to *filename*, *callback* when done.
   * @param  {[type]}   filename [description]
   * @param  {[type]}   size     [description]
   * @param  {[type]}   stream   [description]
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  putFile: (filename, size, stream, callback) ->

  ###*
   * Delete *filename*, *callback* when done.
   * @param  {[type]}   filename [description]
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
  ###
  deleteFile: (filename, callback) ->

Transport.validate = (transport, callback) ->
  ### Validate *transport*, *callback* with error if it's missing any methods. ###
  if not transport.createReadStream? and not transport.getFile?
    throw new Error "TransportError - #{ transport.constructor.name } missing file fetching, implement createReadStream or getFile"
  for method of Transport.prototype
    if method is 'createReadStream' or method is 'getFile'
      continue
    if not transport[method]?
      throw new Error "TransportError - #{ transport.constructor.name } is missing method: #{ method }"
  return

Transport.getName = (transport) ->
  ### Return canonical name for *transport*. ###
  if transport.name?
    return transport.name
  return transport.constructor.name.toLowerCase().replace(/transport$/, '')


class FsTransport
  ### File system transport using node's fs module. ###

  constructor: (@options) ->
    if not @options.path?
      throw new Error "Missing 'path' in options"

  setup: (callback) ->
    @logger.debug 'Verifying path %s', @options.path
    async.waterfall [
      (callback) => fs.realpath @options.path, callback
      (@localPath, callback) => fs.stat @localPath, callback
      (stat, callback) =>
        if not stat.isDirectory()
          callback new Error "Invalid path: #{ @localPath }"
        else
          callback()
    ], (error) =>
      if error?.code is 'ENOENT'
        callback new Error "Invalid path: #{ @localPath or @options.path }"
      else
        callback error

  cleanup: (callback) -> callback()

  resolvePath: (filename) ->
    path.join @localPath, filename

  createReadStream: (filename) ->
    fs.createReadStream @resolvePath filename

  putFile: (filename, size, stream, callback) ->
    writeStream = fs.createWriteStream @resolvePath filename
    writeStream.on 'error', callback
    writeStream.on 'finish', callback
    stream.pipe writeStream

  deleteFile: (filename, callback) ->
    fs.unlink @resolvePath(filename), callback

  makeDirectory: (filename, callback) ->
    fs.mkdir @resolvePath(filename), callback

  deleteDirectory: (filename, callback) ->
    fs.rmdir @resolvePath(filename), callback

  listDirectory: (dirname, callback) ->
    dir = @resolvePath dirname
    async.waterfall [
      (callback) -> fs.readdir dir, callback
      (files, callback) ->
        async.map files, (file, callback) ->
          async.waterfall [
            (callback) -> fs.stat path.join(dir, file), callback
            (stat, callback) ->
              file += '/' if stat.isDirectory()
              callback null, file
          ], callback
        , callback
    ], callback


FsTransport.options =
  path:
    required: true
    description: 'filesystem path'

### Exports ###

module.exports = {Transport, FsTransport}
