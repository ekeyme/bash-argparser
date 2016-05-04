#Argparser
A pythonic command-line arguments parser for bash shell.

This script, argparser, can help you write a much user-friendly command-line parsing code in your bash shell script. You could just register what arguments requied in your program. And then apgparser will finish the left: parses the comand-line paramters you supplied, automatically generates usage and help message.

##Usage
```bash
source argparser

argparser 'mv'
argparser_add_arg source \
            nargs=1 \
            desc='source file or directory'
argparser_add_arg destination \
            nargs=1 \
			desc='where source file or directory will be moved to'
argparser_parse "$@"
```
