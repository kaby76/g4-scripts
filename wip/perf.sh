#

set -x
set -e

cwd=`pwd`

# Check requirements.
if ! command -v dotnet &> /dev/null
then
    echo "'dotnet' could not be found. Install Microsoft NET."
    exit 1
fi
if ! command -v trxml2 &> /dev/null
then
    local=1
fi
if ! command -v dotnet trxml2 -- --version &> /dev/null
then
    echo "'dotnet' could not be found. Install Microsoft NET."
    exit 1
fi

while getopts 'a:b:' opt; do
    case "$opt" in
        a)
            after="${OPTARG}"
            ;;
        b)
            before="${OPTARG}"
            ;;
    esac
done

if [ "$after" == "" ]
then
    echo "'after' not set."
    exit 1
fi
if [ "$before" == "" ]
then
    echo "'before' not set."
    exit 1
fi

#############################
#############################
# Get last commit/pr. Note, some of the PR merges don't
# fit the pattern, but we'll ignore them. Get "prior" commit before all these
# changes.
prs=( After Before )
com=( $after $before )
echo PRS = ${prs[@]}
echo COM = ${com[@]}
echo '#PRS' = ${#prs[@]}
echo ${#com[@]}

#===========================
for ((i=0; i<${#prs[@]}; i++))
do
	echo $i
	pushd "${com[$i]}"
	xxx=${prs[$i]}
	echo $xxx
	rm -f $xxx
	# Try first and scale number of times to work in 10 minutes tops.
	# Format is in seconds, in floating point format.
	runtime=`bash run.sh ../examples/*.on 2>&1 | grep "Total Time" | awk '{print $3}'`
	times=`python -c "print(int(min(40,600/$runtime)))"`
	for ((j=1;j<=times;j++)); do
		bash run.sh ../examples/*.on 2>&1 | grep "Total Time" | awk '{print $3}' >> $cwd/$xxx.txt
	done
	popd
done

echo Graphing out.
rm -f $cwd/xx.m
echo "pkg load statistics" >> $cwd/xx.m
for ((i=0; i<${#prs[@]}; i++))
do
xxx=${prs[$i]}
g=${com[$i]}
echo xxx $xxx
echo $g $g
	echo "p$i=["`cat "$cwd/$xxx.txt"`"];" >> $cwd/xx.m
	echo "mp$i=mean(p$i);" >> $cwd/xx.m
	echo "sd$i=std(p$i);" >> $cwd/xx.m
	echo "printf('disp($i)\n');" >> $cwd/xx.m
	echo "disp($i);" >> $cwd/xx.m
	echo "printf('disp(p$i)\n');" >> $cwd/xx.m
	echo "disp(p$i);" >> $cwd/xx.m
	echo "printf('mp$i = %f\n', mp$i);" >> $cwd/xx.m
	echo "printf('sd$i = %f\n', sd$i);" >> $cwd/xx.m
done
echo -n "x = [" >> $cwd/xx.m
for ((i=1; i<=${#prs[@]}; i++))
do
	echo -n " $i" >> $cwd/xx.m
done
echo "];" >> $cwd/xx.m
echo -n "str = [ " >> $cwd/xx.m
for ((i=0; i<${#prs[@]}; i++))
do
	if [ "$i" != "0" ]; then echo -n "; " >> $cwd/xx.m; fi
	echo -n " '"PR${prs[$i]}"'" >> $cwd/xx.m
done
echo " ];" >> $cwd/xx.m
echo -n "data = [" >> $cwd/xx.m
for ((i=0; i<${#prs[@]}; i++))
do
	echo -n " mp$i" >> $cwd/xx.m
done
echo " ];" >> $cwd/xx.m
echo -n "errhigh = [" >> $cwd/xx.m
for ((i=0; i<${#prs[@]}; i++))
do
	echo -n " sd$i" >> $cwd/xx.m
done
echo " ];" >> $cwd/xx.m
echo -n "errlow = [" >> $cwd/xx.m
for ((i=0; i<${#prs[@]}; i++))
do
	echo -n " sd$i" >> $cwd/xx.m
done
echo " ];" >> $cwd/xx.m
cat >> $cwd/xx.m <<EOF
	bar(x,data);
	set(gca, 'XTickLabel', str, 'XTick', 1:numel(x));
	hold on
	er = errorbar(x,data,errlow,errhigh);
	hold off
	set(er, "color", [0 0 0])
	set(er, "linewidth", 3);
	set(er, "linestyle", "none");
	set(gca, "fontsize", 6)
	xlabel("Target");
	ylabel("Runtime (s)");
	title("Comparison of Runtimes")
	print("./times-$g.svg", "-dsvg")
	[pval, t, df] = welch_test(p0, p1)
	if (abs(pval) < 0.03 && mp0/mp1 > 1.05)
	  printf("The PR statistically and practically decreased performance for $g.\n");
	else
	  printf("The PR did not signficantly negatively alter performance for $g.\n");
	endif
EOF
echo ========
cat $cwd/xx.m
echo ========
exit
cat $cwd/xx.m | octave --no-gui

exit 0
