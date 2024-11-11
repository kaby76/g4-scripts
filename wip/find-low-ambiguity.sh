dotnet trperf -c aF $@ \
	| grep -v '^0' \
	| awk '{sum[$2] += $1} END {for (key in sum) print sum[key], key}' \
	| sort -k1 -n \
	| head
