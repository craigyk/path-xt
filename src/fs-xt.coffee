
fs = require 'fs'
path = require 'path'

fs.path = path
#fs.watch = require './watch'

fs.ls = (dirpath,next) ->
    fs.readdir dirpath, (error,filenames) ->
        if error then return next error
        next null, filenames.map (filename) -> fs.path.resolve fs.path.join dirpath, filename

fs.path.decomp = (fpath) ->
    base = path.basename fpath
    root = fpath.replace base, ''
    ext  = path.extname base
    base = base.replace ext, ''
    [root,base,ext]

fs.path.isabs = (fpath) ->
    if fpath.length > 1
        if fpath[0] == path.sep
            return true
    return false

module.exports = fs
