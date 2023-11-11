# FileAnomalyFinder2.0
I like the idea behind the original FAF. So went ahead and reworked it a bit. Thank you RM, from ST

This script runs on Unix-based host or guest systems.

If all goes well will look like this:

![image](https://github.com/STashakkori/FileAnomalyFinder2.0/assets/4257899/9bc32931-8ec6-474d-a9ce-3211403b2e0e)

This is the original FAF 1.0:
```
#!/bin/sh
##############################################################################
#
# You may edit anything below this point at your own risk, do not request
# support for modified versions of this software. This is free software
# and free for redistribution in accordance with the GNU GPL.
#
##############################################################################
#
# Created by: Ryan M. <ryan@r-fx.net>
# R-fx Networks (c) 1999-2003
# FaF 0.5 <apf@r-fx.net>
#
##############################################################################
#
# Just a global PATH so we can find common binaries
PATH=/sbin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin:$PATH
RESULTS=report.txt

dosearch() {
if [ -f "$RESULTS" ]; then
	rm -f $RESULTS
	touch $RESULTS
	chmod 640 $RESULTS
else
        touch $RESULTS
        chmod 640 $RESULTS
fi
	echo "Begining file anomaly search at $(date)" >> $RESULTS
#cat >> $RESULTS <<EOF
#################################
       SUID/SGID Binaries
#################################
EOF
	find $2 -type f \( -perm -04000 -o -perm -02000 \) \-exec ls -lg {} \; >> $RESULTS
	echo "" >> $RESULTS

cat >> $RESULTS <<EOF
#################################
         No Owner/Group
#################################
EOF
if [ -d "/home/virtual" ] || [ -d "/usr/lib/opcenter" ]; then
        find $2 -nogroup -type f >> $RESULTS
        find $2 -nogroup -type d >> $RESULTS
else
        find $2 -nouser -o -nogroup -type f >> $RESULTS
	find $2 -nouser -o -nogroup -type d >> $RESULTS
fi
	echo "" >> $RESULTS
cat >> $RESULTS <<EOF
#################################
        World Writable
#################################
EOF
	find $2 -perm -002 -type f >> $RESULTS
	find $2 -perm -002 -type d >> $RESULTS
	echo "" >> $RESULTS
cat >> $RESULTS <<EOF
#################################
       Hidden Files/Paths
#################################
EOF
	find $2 -name "..*" -xdev >> $RESULTS
	echo "" >> $RESULTS

	echo "Ended file anomaly search at $(date)" >> $RESULTS
}

case "$1" in
-s)
	echo "Generating report, this may take awile..."
	dosearch >> /dev/null 2>&1
	cat $RESULTS
	;;
-q)
	dosearch >> /dev/null 2>&1
	;;
*)
	echo "usage $0: [-s] [-q]
	echo "-s	Standard"
	echo "-q	Quiet"
esac
exit 0
```
