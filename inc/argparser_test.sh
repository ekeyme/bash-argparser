source ./argparser

function test_argparser()
{
    printf '%s: ' 'argparser should store the right value to globals varibles'

    local app_name='fakeapp'
    local prologue='prologue'
    local usage_string='%(prog_name) %(other_difine_string) do something'
    local add_help=true
    local description='app description'
    local epilog='Author: ekeyme'
    local overwrited_usage='callback'
    local prefix_chars='-+'

    argparser $app_name \
        prefix_chars="$prefix_chars" prologue="$prologue" \
        usage_string="$usage_string" \
        add_help="$add_help" description="$description" \
        epilog="$epilog" \
        overwrited_usage="$overwrited_usage"

    if [[ $Argparser_prog_name = $app_name ]] && \
            [[ $Argparser_prologue = $prologue ]] && \
            [[ $Argparser_usage_string = $usage_string ]] && \
            [[ $Argparser_add_help = $add_help ]] && \
            [[ $Argparser_description = $description ]] && \
            [[ $Argparser_epilog = $epilog ]] && \
            [[ $Argparser_overwrited_usage = $overwrited_usage ]] && \
            [[ $Argparser_prefix_chars = $prefix_chars ]]
    then
        echo ok
    else
        echo fail
    fi
}

function test__parse_parameters()
{
    argparser
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
    argparser
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
    argparser
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
    argparser
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

function test_argparser_add_option()
{
    argparser
    printf '%s: ' 'argparser_add_option should give right array to store data'
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
    argparser_add_option -n --name \
        to=${to[0]} check=${check[0]} action=${action[0]} desc=${desc[0]} \
        metavar=${metavar[0]} required=${required[0]} choices=${choices[0]} \
        default=${default[0]} const=${const[0]} nargs=${nargs[0]}
    argparser_add_option -a --age \
        to=${to[1]} check=${check[1]} action=${action[1]} desc=${desc[1]} \
        metavar=${metavar[1]} required=${required[1]} choices=${choices[1]} \
        default=${default[1]} const=${const[1]} nargs=${nargs[1]}

    if [[ '-a|--age' = ${Argparser_option_strings[1]} ]] && \
            [[ ${to[1]} = ${Argparser_option_to[1]} ]] && \
            [[ ${check[1]} = ${Argparser_option_check[1]} ]] && \
            [[ ${action[1]} = ${Argparser_option_action[1]} ]] && \
            [[ ${default[1]} = ${Argparser_option_default[1]} ]] && \
            [[ ${const[1]} = ${Argparser_option_const[1]} ]] && \
            [[ ${nargs[1]} = ${Argparser_option_nargs[1]} ]] && \
            [[ ${desc[1]} = ${Argparser_option_desc[1]} ]] && \
            [[ ${metavar[1]} = ${Argparser_option_metavar[1]} ]] && \
            [[ ${required[1]} = ${Argparser_option_required[1]} ]] && \
            [[ ${choices[1]} = ${Argparser_option_choices[1]} ]]; then
        echo ok
    else
        echo fail
    fi
}

function test_argparser_add_option1()
{
    argparser
    printf '%s: ' 'argparser_add_option should raise error when const not supply and nargs is 0|?|*'

    if (argparser_add_option -n --name nargs='0'); then
        echo fail
    else
        echo ok
    fi
}

function test_argparser_add_option2()
{
    argparser
    printf '%s: ' 'argparser_add_option should give the right nargs for position argment'
    argparser_add_option name default='has default'
    argparser_add_option age
    set -- "${Argparser_option_nargs[@]}"
    if [[ $1 = '?' && $2 = 1 ]]; then
        echo ok
    else
        echo fail
    fi
}

function test_argparser_add_option3()
{
    argparser
    printf '%s: ' 'argparser_add_option should not support const and required option for position argment'
    if (argparser_add_option name const='this should not supply') && \
            (argparser_add_option age required=true); then
        echo fail
    else
        echo ok
    fi
}

function test_argparser_add_option4()
{
    argparser
    printf '%s: ' 'argparser_add_option should not support 1+ position argment'
    if (argparser_add_option name name2); then
        echo fail
    else
        echo ok
    fi
}

function test_argparser_parse()
{
    argparser
    printf '%s: ' 'test_argparser_parse should give the right values of options'
    argparser_add_option -n --name desc=name default=ekeyme
    argparser_add_option -b --binary const=true default=false
    argparser_add_option age default=26
    argparser_parse -n no_body -a

}

(test_argparser_add_option2)
(test_argparser_add_option3)
(test_argparser_add_option4)