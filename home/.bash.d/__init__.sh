_config_path="$(dirname "${BASH_SOURCE:-$0}")"
_config_path="${_config_path:-.}"


case $(uname -s) in
    Darwin)
        source "$_config_path/aliases"
        source "$_config_path/mac/aliases"
        source "$_config_path/commands"
        source "$_config_path/mac/commands"
        ;;
    Linux)
        source "$_config_path/aliases"
        source "$_config_path/linux/aliases"
        source "$_config_path/commands"
        source "$_config_path/linux/commands"
        ;;
esac


unset _config_path
