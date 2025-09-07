#!/bin/sh

dotnet trperf -c mF $@ 2> /dev/null \
	| grep -v '^0' \
	| awk '{sum[$2] += $1} END {for (key in sum) print sum[key], key}' \
	| sort -k1 -n
