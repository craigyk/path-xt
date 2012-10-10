
fs = require 'fs'
fs.path = require 'path'
fs.watch = require './watch'

fs.path.decomp = (fpath) ->
    base = path.basename fpath
    root = fpath.replace base, ''
    ext  = path.extname base
    base = base.replace ext, ''
    [root,base,ext]

module.exports = fs

