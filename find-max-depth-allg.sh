#!/usr/bin/bash

# glob patterns
shopt -s globstar

# Get full path of this script, and root.
full_path_script=$(realpath $0)
full_path_script_dir=`dirname $full_path_script`
full_path_templates=$(dirname $full_path_script)/templates

rm -rf `find . -name 'Generated*' -type d`

descs=`find . -name desc.xml`
for i in $descs
do
    echo "i = $i"
    d=`dirname $i`
    pushd $d > /dev/null
    d=`pwd`
    g=${d##*$root/}
    testname=$g
    rm -rf Generated-*
    dotnet trgen -- -t CSharp
    if [ "$?" -ne 0 ]
    then
        continue
    fi
    for j in Generated-*
    do
        pushd $j 2> /dev/null
        bash build.sh
        status="$?"
        if [ "$status" -ne 0 ]
        then
            echo Fail.
            continue
        fi
	files_exp=`grep "files2=" test.sh | sed 's#^.*find ##' | sed 's# -type f.*$##'`
	files=`find $files_exp -type f | grep -v '.errors$' | grep -v '.tree$'`
	for k in $files
	do
	    bash $full_path_script_dir/max-depth.sh $k
	done
	popd 2> /dev/null
        rm -rf $j
    done
    popd 2> /dev/null
done
