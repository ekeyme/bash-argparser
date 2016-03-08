source ./optparser

function test_optparser()
{
    printf '%s: ' 'optparser should store the right value to globals varibles'

    local app_name='fakeapp'
    local prologue='prologue'
    local usage_string='%(prog_name) %(other_difine_string) do something'
    local add_help=true
    local description='app description'
    local epilog='Author: ekeyme'
    local overwrited_usage='callback'
    local prefix_chars='-+'

    optparser $app_name \
        prefix_chars="$prefix_chars" prologue="$prologue" \
        usage_string="$usage_string" \
        add_help="$add_help" description="$description" \
        epilog="$epilog" \
        overwrited_usage="$overwrited_usage"

    if [[ $Optparser_prog_name = $app_name ]] && \
            [[ $Optparser_prologue = $prologue ]] && \
            [[ $Optparser_usage_string = $usage_string ]] && \
            [[ $Optparser_add_help = $add_help ]] && \
            [[ $Optparser_description = $description ]] && \
            [[ $Optparser_epilog = $epilog ]] && \
            [[ $Optparser_overwrited_usage = $overwrited_usage ]] && \
            [[ $Optparser_prefix_chars = $prefix_chars ]]
    then
        echo ok
    else
        echo fail
    fi
}

function test__parse_parameters()
{
    optparser
    printf '%s: ' 'parse_parameters should give the right value'
    v='ekeyme
    dsf
    fdsf'\''d

    sdsf'\'
    in_parameter=(NAME=name AGE=age -- name="$v" age=26)
    _parse_parameters "${in_parameter[@]}"

    if [[ ( $NAME = $v ) && ( $AGE = 26 ) ]]; then
        echo ok
    else
        echo fail
    fi
}

function test__parse_parameters2()
{
    optparser
    printf '%s: ' 'parse_parameters should exit when get invalid varible name'
    in_parameter=('invalid varible name'=name -- name=ekeyme)
    if (_parse_parameters "${in_parameter[@]}"); then
        echo fail
    else
        echo ok
    fi
}

function test__parse_parameters3()
{
    optparser
    printf '%s: ' 'parse_parameters should exit when get unkonwn to parsing option'
    in_parameter=('NAME'=name -- name=ekeyme unkonwn_option=kk)
    if (_parse_parameters "${in_parameter[@]}"); then
        echo fail
    else
        echo ok
    fi
}

function test_optparser_add_option()
{
    optparser
    printf '%s: ' 'optparser_add_option should give right array to store data'

    optparser_add_option -n --name \
        to=to_variable_name \
        check=check_fn \
        default=ekeyme \
        desc='option description msg' \
        metavar='NAME' \
        required=true \
        choices='value1|value2|value3...' \
        action=callback
}

(test_optparser)