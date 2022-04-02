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

There are two methods:

1. Clone this repository and `source` the file `kakboard.kak` in your `kakrc`, or
2. Simply clone the repo into your `autoload` subdirectory.

Then, set it up to run with:
```
hook global WinCreate .* %{ kakboard-enable }
```


## Usage

Just copy and paste with the normal commands (`y`, `c`, `p`, `R`, etc.)! Copy
keys copy the main selection to the system clipboard and paste commands sync the
system clipboard with the `"` register before executing. Copying/pasting to/from
the system clipboard can be prevented by specifying a register to use, even the
default `"` register.

### Configuration

The `kakboard_copy_cmd` and `kakboard_paste_cmd` options specify the commands to
copy to and paste from the system clipboard. If they are unset, kakboard will
try to detect command pair to use.

Currently supports:

- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (Wayland)
- [xsel](http://www.kfish.org/software/xsel/)
- [xclip](https://github.com/astrand/xclip)
- pbcopy/pbpaste (macOS)

To change the keys for which clipboard syncing is done, just set the
`kakboard_copy_keys` and `kakboard_paste_keys` options.

Note: This plugin will map all of the keys in `kakboard_paste_keys` and
`kakboard_copy_keys`, so if you already have mappings for these keys, you will
have to edit those bindings to call `kakboard-{pull,push}-if-unset` to sync the
clipboard after copying / before pasting and remove said keys from kakboard's
lists.

### Commands

- `kakboard-enable`/`kakboard-disable`/`kakboard-toggle`: enable/disable/toggle
  clipboard integration
- `kakboard-pull-clipboard`: Pull system clipboard into the `"` register.
- `kakboard-pull-if-unset`: Call `kakboard-pull-clipboard` if
  `%val{register}` is empty.
- `kakboard-with-pull-clipboard <keys>`: Call `kakboard-pull-if-unset` then
  execute `<keys>`.
- `kakboard-push-clipboard`: Set system clipboard from the `"` register.
- `kakboard-push-if-unset`: Call `kakboard-push-clipboard` if
  `%val{register}` is empty.
- `kakboard-with-push-clipboard <keys>`: Execute `<kys>` then call
  `kakboard-push-if-unset`


## Limitations

System clipboards don't support multiple selections, so only the primary
selection is copied to the clipboard. Correspondingly, when the `"` register is
synced to the system clipboard, it is filled with a single value and remaining
values, if any, are deleted. To get around this, the `"` register can be
specified explicitly when pasting multiple selections (before syncing with the
system clipboard) as mentioned above.


## License

MIT License
