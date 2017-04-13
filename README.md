# Argparser
A pythonic command-line arguments parser for bash shell.

This script, argparser, can help you write a much user-friendly command-line parsing code in your bash shell script. You could just register the arguments which are requied in your program. And then apgparser will finish the left: parses the comand-line paramters you supplied, automatically generates usage and help message.

## Examples

### Simple example: a mimic simple mv
- bash script file: mymv

```bash
source argparser

# register the arguments 
argparser
argparser_add_arg source \
            nargs=+ \
            desc='source file or directory'
argparser_add_arg destination \
            nargs=1 \
            desc='where source file or directory will be moved to'
argparser_parse "$@"

# after doing argparser_parse, the values passed from the user should be binded correctly to the bash variables, source and destination.
echo "variable source: ${source[@]}"
echo "variable destination: $destination"
# do something using those variables
##/bin/mv "$source"  "$destination"
```
- argparser could help you generate help docstring automatically
```bash
$ ./mymv -h
usage: mymv [-h] source destination

  -h, --help                      show this help message and exit
  source                          source file or directory
  destination                     where source file or directory will be moved to
```

- argparser could help you bind values from command-line parameters to variables you registered using `argparser_add_arg`
```bash
$ ./mymv source/file1 source/file2 source/file3 dest/path
variable source: source/file1 source/file2 source/file3
variable destination: dest/path
```

## Simple Document(developing...)

1 Setup the argument parser
For example:
```bash
argparser \
        desc='Connect mysql database, and support extending options of mysql.' \
        epilog='E.G. %(prog)s magic lims -se "SELECT * FROM gene LIMIT 1"'
#argparser_DEBUG
```
2 Registering(adding) arguments
For example:
```bash

argparser_add_arg host \
            dest='which_host' nargs=1 \
            desc='database host identifer. choose in [%(choices)s]' \
            choices='magic|crassus|wiz'
argparser_add_arg mysql_args \
            nargs='remain' desc='arguments like mysql'
```
3 Parsing arguments
For example:
```bash
argparser_parse "$@"
set -- "${mysql_args[@]}"
```

