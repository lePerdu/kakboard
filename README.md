# kakboard

Clipboard integration for [kakoune](https://kakoune.org).


## Installation

### With [plug.kak](https://github.com/andreyorst/plug.kak) (recommended)

Just add this to your `kakrc`:
```
plug "lePerdu/kakboard" %{
    hook global WinCreate .* %{ kakboard-enable }
}
```

### Manually

Clone this repository and `source` the file `kakboard.kak` in your `kakrc`.


## Usage

Just copy and paste with the normal commands (`y`, `c`, `p`, `R`, etc.)! Copy
keys copy the main selection to the system clipboard and paste commands sync the
system clipboard with the `"` register before executing. Copying/pasting to/from
the system clipboard can be prevented by specifying a register to use, even the
default `"` register.

### Configuration

The `kakboard_copy_cmd` and `kakboard_paste_cmd` options specify the commands to
copy to and paste from the system clipboard. These will be dependent on the
system, but the following should work:

| OS                   | Copy                 | Paste                |
| -------------------- | -------------------- | -------------------- |
| Linux (xsel)         | `xsel -ib`           | `xsel -ob`           |
| Linux (xclip)        | `xclip -i -sel clip` | `xclip -o -sel clip` |
| Linux (wl-clipboard) | `wl-copy -f`         | `wl-paste -n`        |
| MacOS                | `pbcopy`             | `pbpaste`            |

To change the keys for which clipboard syncing is done, just set the
`kakboard_copy_keys` and `kakboard_paste_keys` options.

Note: This plugin will map all of the keys in `kakboard_paste_keys`, so if you
already have mappings for these keys, you will have to edit those bindings to
call `kakboard-pull-for-dquote` to sync the clipboard.

### Commands

- `kakboard-enable`/`kakboard-disable`/`kakboard-toggle`: enable/disable/toggle
  clipboard integration
- `kakboard-pull-clipboard`: Pull system clipboard into the `"` register.
- `kakboard-pull-for-dquote`: Call `kakboard-pull-clipboard` if
  `%val{register}` is empty.


## Limitations

System clipboards generally don't support multiple selections, so only the
primary selection is copied to the clipboard. Correspondingly, when the `"`
register is synced to the system clipboard, it is filled with a single value
and remaining values, if any, are deleted. To get around this, the `"` register
can be specified when pasting multiple selections as mentioned above.


## License

MIT License
