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
    printf '%s: ' 'parse_parameters should give the right value when has more than 1 options to parse'
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

function test__parse_parameters4()
{
    optparser
    printf '%s: ' 'parse_parameters should give the right value when has just 1 option to parse'
    v='ekeyme
    dsf
    fdsf'\''d

    sdsf'\'
    in_parameter=(NAME=name -- name="$v")
    _parse_parameters "${in_parameter[@]}"

    if [[ $NAME = $v ]]; then
        echo ok
    else
        echo fail
    fi
}

function test_optparser_add_option()
{
    optparser
    printf '%s: ' 'optparser_add_option should give right array to store data'
    local to=(to to1)
    local check=(check check1)
    local action=(action action1)
    local desc=(desc desc1)
    local metavar=(metavar metavar1)
    local required=(required required1)
    local choices=(choices choices1)
    local default=(default default1)
    local const=(const const1)
    local nargs=(nargs nargs1)
    optparser_add_option -n --name \
        to=${to[0]} check=${check[0]} action=${action[0]} desc=${desc[0]} \
        metavar=${metavar[0]} required=${required[0]} choices=${choices[0]} \
        default=${default[0]} const=${const[0]} nargs=${nargs[0]}
    optparser_add_option -a --age \
        to=${to[1]} check=${check[1]} action=${action[1]} desc=${desc[1]} \
        metavar=${metavar[1]} required=${required[1]} choices=${choices[1]} \
        default=${default[1]} const=${const[1]} nargs=${nargs[1]}

    if [[ '-a|--age' = ${Optparser_option_strings[1]} ]] && \
            [[ ${to[1]} = ${Optparser_option_to[1]} ]] && \
            [[ ${check[1]} = ${Optparser_option_check[1]} ]] && \
            [[ ${action[1]} = ${Optparser_option_action[1]} ]] && \
            [[ ${default[1]} = ${Optparser_option_default[1]} ]] && \
            [[ ${const[1]} = ${Optparser_option_const[1]} ]] && \
            [[ ${nargs[1]} = ${Optparser_option_nargs[1]} ]] && \
            [[ ${desc[1]} = ${Optparser_option_desc[1]} ]] && \
            [[ ${metavar[1]} = ${Optparser_option_metavar[1]} ]] && \
            [[ ${required[1]} = ${Optparser_option_required[1]} ]] && \
            [[ ${choices[1]} = ${Optparser_option_choices[1]} ]]; then
        echo ok
    else
        echo fail
    fi
}

function test_optparser_add_option1()
{
    optparser
    printf '%s: ' 'optparser_add_option should raise error when const not supply and nargs is 0|?|*'

    if (optparser_add_option -n --name nargs='0'); then
        echo fail
    else
        echo ok
    fi
}

function test_optparser_parse()
{
    optparser
    printf '%s: ' 'test_optparser_parse should give the right values of options'
    optparser_add_option -n --name desc=name default=ekeyme
    optparser_add_option -b --binary const=true default=false
    optparser_add_option age default=26
    optparser_parse -n no_body -a

}

test_optparser_add_option