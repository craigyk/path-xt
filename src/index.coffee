
path = require 'path'

path.decomp = (fpath) ->
    base = path.basename fpath
    root = fpath.replace base, ''
    ext  = path.extname base
    base = base.replace ext, ''
    [root,base,ext]

module.exports = path

