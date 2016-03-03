. optparser

optparser # start

function test__parse_parameters()
{
    printf '%s: ' test__parse_optparser_parameters
    v='
            dfs
    fdsf
    ddd
    '
    in_parameter=(NAME=name AGE=age -- name="$v" age=26 add=unkonwn)
    _parse_parameters "${in_parameter[@]}"

    if [[ ( $NAME = ekeyme ) && ( $AGE = 26 ) ]]; then
        echo ok
    else
        echo fail
    fi
}

test__parse_parameters