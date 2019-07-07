
declare-option -docstring 'command to copy to clipboard' \
    str kakboard_copy_cmd "xsel --input --clipboard"

declare-option -docstring 'command to paste from clipboard' \
    str kakboard_paste_cmd "xsel --output --clipboard"

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

define-command -docstring 'enable clipboard integration' kakboard-enable %{
    set-option window kakboard_enabled true

    hook window -group kakboard NormalKey %sh{
        echo "$kak_opt_kakboard_copy_keys" | tr ' ' '|'
    } %{ nop %sh{
        if test -z "$kak_register"; then
            printf '%s' "$kak_main_reg_dquote" | $kak_opt_kakboard_copy_cmd
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
