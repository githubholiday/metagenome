#!/bin/bash
if [ $# -ne 1 ]
then
    echo "#########################"
    echo "usage   : $0 report_md"
    echo "example : $0 report_md "
    echo 'author  : Ren Xue '
    echo 'date    : 20201208 '
    echo 'version : v0.0.1'
    exit 1
fi
sed -i 's/\\|/\&#124;/g' $1
#sed -i -r 's/:([_A-Za-Z0-9-]*):/\&#58;\1\&#58;/g' $1
sed -i -r 's/:([_A-Za-Z0-9]+[_A-Za-Z0-9-]*):/\&#58;\1\&#58;/g' $1
