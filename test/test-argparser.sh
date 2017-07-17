#!/usr/bin/env bash
#
## How to run this tests:
##  Recommanded
##   $ path-to/test-argparser.sh 2>/dev/null
##
##  If you want to see the standar errors
##   $ path-to/test-argparser.sh


source $(cd "$(dirname "$(readlink -f "$BASH_SOURCE")")/" && pwd)/../argparser

function test_argparser()
{
    printf "%s: %s: " "$FUNCNAME" 'argparser should store the right value to globals varibles'
    local app_name='fakeapp'
    local prologue='%(prog)s prologue'
    local usage='%(prog)s do something'
    local add_help=true
    local desc='%(prog)s description'
    local epilog='%(prog)s Author: ekeyme'
    local help='%(prog)s help'
    local prefix_chars='-+'
    local nargs_extending_EOT='!'

    argparser $app_name \
        prefix_chars="$prefix_chars" prologue="$prologue" \
        usage="$usage" \
        add_help="$add_help" desc="$desc" \
        epilog="$epilog" \
        help="$help" \
        nargs_extending_EOT="$nargs_extending_EOT"

    (
        is_the_same_arr "$Argparser_prog_name" "$Argparser_prologue" \
                "$Argparser_usage" "$Argparser_add_help" "$Argparser_desc" \
                "$Argparser_epilog" "$Argparser_help" "$Argparser_prefix_chars" \
                "$Argparser_nargs_extending_EOT" \
                -- "$app_name" "$prologue" "$usage" "$add_help" "$desc" \
                "$epilog" "$help" "$prefix_chars" "$nargs_extending_EOT"
    )
    ok_or_fail $?
}

function test_argparser1()
{
    argparser usage='This is usage of %(prog)s'
    printf "%s: %s: " "$FUNCNAME" "argparser should output the right supplied usage string"
    ex_output='usage: This is usage of test-argparser.sh'
    output=$(argparser_parse -h | head -n1)

    [[ $ex_output == $output ]]
    ok_or_fail $?
}

function test_argparser_add_arg()
{
    argparser add_help=false
    printf '%s: %s: ' "$FUNCNAME" "should register the right values to globals varibles"
    local dest=(dest dest1)
    local check=(check_callback check_callback)
    local action=(action_callback action_callback)
    local desc=(desc desc1)
    local metavar=(metavar metavar1)
    local required=(false true)
    local choices=(choices choices1)
    local default=(default default1)
    local const=(const const1)
    local nargs=('?' '*')
    argparser_add_arg -n --name \
        dest=${dest[0]} check=${check[0]} action=${action[0]} desc=${desc[0]} \
        metavar=${metavar[0]} required=${required[0]} choices=${choices[0]} \
        default=${default[0]} const=${const[0]} nargs=${nargs[0]}
    argparser_add_arg -a --age \
        dest=${dest[1]} check=${check[1]} action=${action[1]} desc=${desc[1]} \
        metavar=${metavar[1]} required=${required[1]} choices=${choices[1]} \
        default=${default[1]} const=${const[1]} nargs=${nargs[1]}

    [[ '-a|--age' = ${Argparser_argument_flag[1]} ]] && \
    [[ ${dest[1]} = ${Argparser_argument_dest[1]} ]] && \
    [[ ${check[1]} = ${Argparser_argument_check[1]} ]] && \
    [[ ${action[1]} = ${Argparser_argument_action[1]} ]] && \
    [[ ${default[1]} = ${Argparser_argument_default[1]} ]] && \
    [[ ${const[1]} = ${Argparser_argument_const[1]} ]] && \
    [[ ${nargs[1]} = ${Argparser_argument_nargs[1]} ]] && \
    [[ ${desc[1]} = ${Argparser_argument_desc[1]} ]] && \
    [[ ${metavar[1]} = ${Argparser_argument_metavar[1]} ]] && \
    [[ ${required[1]} = ${Argparser_argument_required[1]} ]] && \
    [[ ${choices[1]} = ${Argparser_argument_choices[1]} ]]
    ok_or_fail $?
}

function test_argparser_add_arg1()
{
    argparser
    printf '%s: ' "$FUNCNAME" "should give the right nargs for position argment"
    argparser_add_arg name default='has default'
    argparser_add_arg age
    set -- "${Argparser_argument_nargs[@]}"

    [[ $2 = '?' && $3 = 1 ]]
    ok_or_fail $?
}

function test_argparser_add_arg2()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" "should not support const/required option for position argment"
    ! (
        (argparser_add_arg name const='this should not supply') && \
                    (argparser_add_arg age required=true)
    )
    ok_or_fail $?

    # if (argparser_add_arg name const='this should not supply') && \
    #         (argparser_add_arg age required=true); then
    #     echo -e "\033[31mfail\033[0m"
    # else
    #     echo ok
    # fi
}

function test_argparser_add_arg3()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'could only support just 1 position argments'
    ! (argparser_add_arg name name2)
    ok_or_fail $?
}

function test_argparser_parse1_1()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'Extending(nargs=+) Test: change the order of adding arguments'
    argparser_add_arg files nargs=+
    argparser_add_arg dest nargs=1

    # test 1
    cl_args=(file1 file2 file3 file4)
    files_expected=(file1 file2 file3)
    dest_expected=(file4)
    argparser_parse "${cl_args[@]}"

    (
        is_the_same_arr "${files_expected[@]}" -- "${files[@]}" &&\
        is_the_same_arr "${dest_expected[@]}" -- "${dest[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse1_2()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'Extending(nargs=+) Test: change the order of adding arguments'
    argparser_add_arg file nargs=1
    argparser_add_arg dest_dirs nargs=+
    args=(file1 file2 'dd ff f' file4)
    file_ex=(file1)
    dest_dirs_ex=(file2 'dd ff f' file4)
    argparser_parse "${args[@]}"

    (
        is_the_same_arr "${file_ex[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${dest_dirs_ex[@]}" -- "${dest_dirs[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse2_1()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'With just 1 Extending nargs test'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -q dest=quit_model default=false const=true nargs=0
    argparser_add_arg -n --name default=ekeyme nargs=?
    argparser_add_arg -e --emails dest=emails nargs=2
    argparser_add_arg money dest=how_much nargs=1
    argparser_add_arg currency nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg source default='Guangzhou Doc' nargs='?'
    
    arg=(-vqeekeyme@gmail.com ekeyme@foxmail.com 9999 dollar Beijing Hongkong - Zhanjiang)
    e_verbose=(true)
    e_quit_model=(true)
    e_name=(ekeyme)
    e_emails=(ekeyme@gmail.com ekeyme@foxmail.com)
    e_how_much=(9999)
    e_currency=(dollar)
    e_distribution_to=(Beijing Hongkong)
    e_source=(Zhanjiang)
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_quit_model[@]}" -- "${quit_model[@]}" &&\
        is_the_same_arr "${e_name[@]}" -- "${name[@]}" &&\
        is_the_same_arr "${e_emails[@]}" -- "${emails[@]}" &&\
        is_the_same_arr "${e_how_much[@]}" -- "${how_much[@]}" &&\
        is_the_same_arr "${e_currency[@]}" -- "${currency[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_source[@]}" -- "${source[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse2_2()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'With just 1 Extending nargs test'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -q dest=quit_model default=false const=true nargs=0
    argparser_add_arg -n --name default=ekeyme nargs=?
    argparser_add_arg -e --emails dest=emails nargs=2
    argparser_add_arg money dest=how_much nargs=1
    argparser_add_arg currency nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg source default='Guangzhou Doc' nargs='?'
    
    # test 2
    arg=(-vqeekeyme@gmail.com ekeyme@foxmail.com 9999 dollar Beijing Hongkong Zhanjiang)
    e_verbose=(true)
    e_quit_model=(true)
    e_name=(ekeyme)
    e_emails=(ekeyme@gmail.com ekeyme@foxmail.com)
    e_how_much=(9999)
    e_currency=(dollar)
    e_distribution_to=(Beijing Hongkong Zhanjiang)
    e_source=('Guangzhou Doc')
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_quit_model[@]}" -- "${quit_model[@]}" &&\
        is_the_same_arr "${e_name[@]}" -- "${name[@]}" &&\
        is_the_same_arr "${e_emails[@]}" -- "${emails[@]}" &&\
        is_the_same_arr "${e_how_much[@]}" -- "${how_much[@]}" &&\
        is_the_same_arr "${e_currency[@]}" -- "${currency[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_source[@]}" -- "${source[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse2_3()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'With just 1 Extending nargs test'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -q dest=quit_model default=false const=true nargs=0
    argparser_add_arg -n --name default=ekeyme nargs=?
    argparser_add_arg -e --emails dest=emails nargs=2
    argparser_add_arg money dest=how_much nargs=1
    argparser_add_arg currency nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg source default='Guangzhou Doc' nargs='?'
    
    arg=(-v -e ekeyme@gmail.com ekeyme@foxmail.com 9999 -n mozz dollar Beijing Hongkong Zhanjiang)
    e_verbose=(true)
    e_quit_model=(false)
    e_name=(mozz)
    e_emails=(ekeyme@gmail.com ekeyme@foxmail.com)
    e_how_much=(9999)
    e_currency=(dollar)
    e_distribution_to=(Beijing Hongkong Zhanjiang)
    e_source=('Guangzhou Doc')
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_quit_model[@]}" -- "${quit_model[@]}" &&\
        is_the_same_arr "${e_name[@]}" -- "${name[@]}" &&\
        is_the_same_arr "${e_emails[@]}" -- "${emails[@]}" &&\
        is_the_same_arr "${e_how_much[@]}" -- "${how_much[@]}" &&\
        is_the_same_arr "${e_currency[@]}" -- "${currency[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_source[@]}" -- "${source[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse3_1()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'Multiple extending nargs test: whether the nargs_Extending_EOT works'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -f --file default=ekeyme nargs=+
    argparser_add_arg -t --type default=r nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg user default=mozz nargs=?

    arg=(-vf file1 file2 file3 -tdir magic castor - zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse3_2()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'Multiple extending nargs test: whether the nargs_Extending_EOT works'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -f --file default=ekeyme nargs=+
    argparser_add_arg -t --type default=r nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg user default=mozz nargs=?

    arg=(-vf file1 file2 file3 - magic castor -tdir zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse3_3()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'Multiple extending nargs test: whether the nargs_Extending_EOT works'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -f --file default=ekeyme nargs=+
    argparser_add_arg -t --type default=r nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg user default=mozz nargs=?

    arg=(-v magic castor -f file1 file2 file3 -tdir zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse3_4()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'Multiple extending nargs test: whether the nargs_Extending_EOT works'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -f --file default=ekeyme nargs=+
    argparser_add_arg -t --type default=r nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg user default=mozz nargs=?

    arg=(magic castor -v -f file1 file2 file3 -tdir zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse4_1()
{
    printf '%s: %s: ' "$FUNCNAME" 'nargs=remain test'
    argparser
    argparser_add_arg command
    argparser_add_arg -o dest=options nargs=remain

    arg=(mycommand -o -v -f file2 -t text)
    e_command=(mycommand)
    e_options=(-v -f file2 -t text)
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_command[@]}" -- "${command[@]}" && \
        is_the_same_arr "${e_options[@]}" -- "${options[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse4_1()
{
    printf '%s: %s: ' "$FUNCNAME" 'nargs=remain test'
    argparser
    argparser_add_arg command
    argparser_add_arg -o dest=options nargs=remain

    arg=(mycommand -o)
    e_command=(mycommand)
    e_options=()
    argparser_parse "${arg[@]}"

    (
        is_the_same_arr "${e_command[@]}" -- "${command[@]}" && \
        is_the_same_arr "${e_options[@]}" -- "${options[@]}"
    )
    ok_or_fail $?
}

function test_argparser_parse5()
{
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should exit when required argument does not supplied'
    argparser
    argparser_add_arg -f dest=file required=true
    argparser_add_arg -n dest=name nargs=1
    ! (argparser_parse -n ekeyme)
    ok_or_fail $?
}

function test_argparser_parse6()
{
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should tear down the functions and variables created by argparser'
    argparser
    argparser_add_arg -f dest=file
    argparser_parse -f 'ddd'

    # set the have tear-down functions to argv
    set -- _format_option_flag _format_usge _get_argparser_optional_arg_key argparser argparser_add_arg
    while (($# > 0)); do
        if (type "$1" 1>/dev/null 2>/dev/null); then
            local flag=false
            break
        fi
        shift
    done
    [[ $flag != false ]]
    ok_or_fail $?
}

function test_argparser_parse7()
{
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should give the default value of positional option with nargs=remain, when no more argument supplied'
    argparser
    argparser_add_arg -f dest=file
    argparser_add_arg more_args nargs=remain default='default value for remain'
    argparser_parse -f file1 

    ex_value='default value for remain'
    [[ $more_args = $ex_value ]]
    ok_or_fail $?
}

function test_argparser_parse9()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should print help doc and exit'
    local help_doc=$(argparser_parse -h)
    local exit_code=$?
    ( (($exit_code == 0)) && grep -q '^usage: ' <<< "$help_doc" )
    ok_or_fail $?
}

function test_argparser_parse10()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'Dots should not cause argument errors'

    argparser_add_arg command

    arg=(.mycommand)
    e_command=(.mycommand)
    argparser_parse "${arg[@]}"
    (is_the_same_arr "${e_command[@]}" -- "${command[@]}")
    ok_or_fail $?
}

function test_argparser_parse11()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'error message should redirect into stderr when error occurs'

    argparser_add_arg name
    err=$(argparser_parse 2>/dev/null)
    [[ "$err" == '' ]]
    ok_or_fail $?
}

function test_argparser_help()
{
    printf '%s: %s: ' "$FUNCNAME" 'argparser_help should print the right help doc'
    argparser app_test \
            prologue='prologue' \
            desc='desc of %(prog)s' \
            epilog='epilog'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -q dest=quit_model default=false const=true nargs=0
    argparser_add_arg -n --name default=ekeyme nargs=?
    argparser_add_arg -e --emails dest=emails nargs=2
    argparser_add_arg money dest=how_much nargs=1
    argparser_add_arg currency nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg source default='Guangzhou Doc' nargs='?'

    local ex_help_doc=/tmp/source_01_argparser_help
    local argparser_help_doc=/tmp/out_01_argparser_help
    local ex_help='prologue

usage: app_test [-h] [-v] [-q] [-n [name]] [-e emails emails] how_much currency [distribution_to ...] [source]
desc of app_test

  -h, --help                      show this help message and exit                      
  -v                                                                                   
  -q                                                                                   
  -n, --name=[name]                                                                    
  -e, --emails=emails ...                                                              
  how_much                                                                             
  currency                                                                             
  distribution_to                                                                      
  source                                                                               

epilog'
    echo "$ex_help" > "$ex_help_doc"
    (argparser_help) > "$argparser_help_doc"

    (diff -q "$ex_help_doc" "$argparser_help_doc" 1>/dev/null)
    ok_or_fail $?
}

function ok_or_fail()
{
    local return_code=$(($1 * 1))
    if (($return_code == 0)); then
        echo ok
    else
        echo -e "\033[31mfail\033[0m"
    fi

    return $return_code
}

function is_the_same_arr()
{
    local arr1=()
    local arr2=()
    while (($# > 0)); do
        if [[ $1 == '--' ]]; then
            shift
            while (($# > 0)); do
                arr2=("${arr2[@]}" "$1")
                shift
            done
        else
            arr1=("${arr1[@]}" "$1")
            shift
        fi
    done
    local i v1 v2
    ((${#arr1[@]} == ${#arr2[@]})) &&\
        for ((i=0; i < ${#arr1[@]}; i++)); do
            v1=${arr1[$i]}
            v2=${arr2[$i]}
            if [[ $v1 != $v2 ]]; then
                return 1
            fi
        done
}

function action_callback() { :; }
function check_callback() { :; }
function callback() { :; }


# run the test
function __main__()
{
    test_funcs=($(declare -F | cut -d' ' -f3 | grep -P '^test_.+$'))
    success_n=0
    for func in "${test_funcs[@]}"; do
        ($func)
        if (($? == 0)); then
            ((success_n++))
        fi
    done

    printf "\n%s\nRun %d tests: %d failed\n" \
                "======================================================================" \
                "${#test_funcs[@]}" \
                "$((${#test_funcs[@]} - success_n))"
}

__main__