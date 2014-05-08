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

module.exports = Transport
