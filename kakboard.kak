
declare-option -docstring 'command to copy to clipboard' \
    str kakboard_copy_cmd

declare-option -docstring 'command to paste from clipboard' \
    str kakboard_paste_cmd

declare-option -docstring 'keys to pull clipboard for' \
    str-list kakboard_paste_keys p P R <a-p> <a-P> <a-R>

declare-option -docstring 'keys to copy to clipboard' \
    str-list kakboard_copy_keys y c d

declare-option -hidden bool kakboard_enabled false

define-command -docstring 'copy system clipboard into the " reigster' \
    kakboard-pull-clipboard %{ evaluate-commands %sh{
    # Shell expansions are stripped of new lines, so the output of the
    # command has to be wrapped in quotes (and its quotes escaped)
    #
    # (All of this quoting and escaping really messes up kakoune's syntax
    # highlighter)
    printf 'set-register dquote %s' \
        "'$($kak_opt_kakboard_paste_cmd | sed -e "s/'/''/g"; echo \')"
}}

define-command -docstring 'copy system clipboard if current register is "' \
    kakboard-pull-for-dquote %{ evaluate-commands %sh{
    if test -z "$kak_register"; then
        echo "kakboard-pull-clipboard"
    fi
}}

# Pull the clipboard and execute the key with the same context
define-command -hidden kakboard-with-clipboard -params 1 %{
    evaluate-commands %sh{
        if test -n "$kak_register"; then
            register="$kak_register"
        else
            register='"'
        fi
        echo "kakboard-pull-for-dquote"
        echo "execute-keys '\"$register$kak_count$1'"
    }
}

define-command -hidden kakboard-autodetect %{
    evaluate-commands %sh{
        # Don't override if there are already commands
        if [ -n "$kak_opt_kakboard_copy_cmd" -o \
            -n "$kak_opt_kakboard_paste_cmd" ]
        then
            exit
        fi

        copy=
        paste=
        case $(uname -s) in
            Linux)
                if [ -n "$WAYLAND_DISPLAY" ] \
                    && command -v wl-copy >/dev/null \
                    && command -v wl-paste >/dev/null
                then
                    # wl-clipboard
                    copy="wl-copy --foreground"
                    paste="wl-paste --no-newline"
                elif [ -n "$DISPLAY" ] && command -v xsel >/dev/null; then
                    # xsel
                    copy="xsel --input --clipboard"
                    paste="xsel --output --clipboard"
                elif [ -n "$DISPLAY" ] && command -v xclip >/dev/null; then
                    # xclip
                    copy="xclip -in -selection clipboard"
                    paste="xclip -out -selection clipboard"
                fi
                ;;

            Darwin)
                copy="pbcopy"
                paste="pbpaste"
                ;;

            *)
                ;;
        esac

        if [ -n "$copy" -a -n "$paste" ]; then
            echo "set-option global kakboard_copy_cmd '$copy'"
            echo "set-option global kakboard_paste_cmd '$paste'"
        else
            echo "echo -debug 'kakboard: Could not auto-detect clipboard commands. Please set them explicitly.'"
        fi
    }
}

define-command -docstring 'enable clipboard integration' kakboard-enable %{
    set-option window kakboard_enabled true

    kakboard-autodetect

    hook window -group kakboard NormalKey %sh{
        echo "$kak_opt_kakboard_copy_keys" | tr ' ' '|'
    } %{ nop %sh{
        if test -z "$kak_register"; then
            printf '%s' "$kak_main_reg_dquote" \
                | ($kak_opt_kakboard_copy_cmd) >/dev/null 2>&1 &
        fi
    }}

    evaluate-commands %sh{
        eval set -- "$kak_quoted_opt_kakboard_paste_keys"
        while [ $# -gt 0 ]; do
            escaped=$(echo "$1" | sed -e 's/</<lt>/')
            echo map global normal "$1" \
                "': kakboard-with-clipboard $escaped<ret>'"
            shift
        done
    }
}

define-command -docstring 'disable clipboard integration' kakboard-disable %{
    set-option window kakboard_enabled false

    remove-hooks window kakboard

    evaluate-commands %sh{
        eval set -- "$kak_quoted_opt_kakboard_paste_keys"
        while [ $# -gt 0 ]; do
            echo unmap global normal "$1"
            shift
        done
    }
}

define-command -docstring 'toggle clipboard integration' kakboard-toggle %{
    evaluate-commands %sh{
        if test "$kak_opt_kakboard_enabled" = true; then
            echo "kakboard-disable"
        else
            echo "kakboard-enable"
        fi
    }
}
