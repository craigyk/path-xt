
set = (items) ->
    mapped = {}
    items.forEach (x) -> mapped[x] = x
    mapped

ls = (dirpath,next) ->
    fs.readdir dirpath, (err,names) ->
        names = names ? []
        next names.map (name) -> join dirpath, name

lstat = (path,next) ->
        fs.lstat path, (e,stat) ->
            next null, [path,stat ? {}]

onchange = (path,next) ->
    fs.watch path, (e) ->
        if e != 'rename'
            next path

watch = (dirpath,opts) ->

    if typeof opts == 'function'
        next = opts
        opts =
            ondeleted : (x) -> next deleted: x
            onchanged : (x) -> next changed: x
            onadded   : (x) -> next added: x
            onrenamed : (x,y) -> next renamed: [x,y]

    ondeleted = opts.ondeleted ? ->
    onchanged = opts.onchanged ? ->
    onadded   = opts.onadded   ? ->
    select    = opts.select    ? -> true
    onrenamed = opts.onrenamed ? ->

    by_path = {}
    by_stat = {}

    add_entry = (path,ino) ->
        by_stat[ino] = path
        by_path[path] = ino

    delete_entry = (path,ino) ->
        delete by_stat[ino]
        delete by_path[path]

    rename_entry = (path,ino) ->
        by_stat[ino] = path
        by_path[path] = ino

    watchers = []
    scan_directory = ->
        ls dirpath, (paths) ->
            paths = paths.filter (p) -> select p
            # stat them all to detect renames
            async.map paths, lstat, (e,statted) ->
                watchers.forEach (w) -> do w.close
                watchers = []
                statted.forEach ([path,{ino}]) ->
                    watchers.push fs.watch path, (e) ->
                        if e != 'rename' then onchanged path
                    if ino not of by_stat
                        add_entry path, ino
                        onadded path
                    else if by_stat[ino] != path
                        # tracked, but path name changed, update entries
                        onrenamed by_stat[ino], path
                        rename_entry path, ino
                # now we remove paths still being tracked that weren't found
                # in the last run, we create a reverse-mapping for efficiency
                mapping = set statted.map ([_,{ino}]) -> ino
                for ino of by_stat
                    path = by_stat[ino]
                    if ino not of mapping
                        delete_entry path, ino
                        ondeleted path

    fs.watch dirpath, scan_directory
    do scan_directory

module.exports = watch
