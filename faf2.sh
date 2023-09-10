#!/bin/bash
##############################################################################
# File Anomaly Finder 2.0
##############################################################################
# This script continues work by Ryan MacDonald at R-FX Networks.
# To protect and empower. -QVLx Labs
##############################################################################

WHICH_CMD=$(command -v which)
FIND_CMD="$(which find)"
LS_CMD="$(which ls)"
CHMOD_CMD="$(which chmod)"
DATE_CMD="$(which date)"
TOUCH_CMD="$(which touch)"
CAT_CMD="$(which cat)"
RM_CMD="$(which rm)"

# Define the output file path
RESULTS="results_faf.txt"

dosearch() {
  if [ -f "$RESULTS" ]; then
    $RM_CMD -f $RESULTS
    $TOUCH_CMD $RESULTS
    $CHMOD_CMD 640 $RESULTS
  else
    $TOUCH_CMD $RESULTS
    $CHMOD_CMD 640 $RESULTS
  fi
  echo "Beginning file anomaly search at $($DATE_CMD)" >> $RESULTS

  cat >> $RESULTS << EOF
#################################
        SUID/SGID Binaries
#################################
EOF
  $FIND_CMD $2 -type f \( -perm -04000 -o -perm -02000 \) -exec $LS_CMD -lg {} \; >> $RESULTS

  cat >> $RESULTS << EOF
#################################
            No Owner
#################################
EOF
  $FIND_CMD $2 -type f ! -user "*" >> $RESULTS
  $FIND_CMD $2 -type d ! -user "*" >> $RESULTS

  cat >> $RESULTS << EOF
#################################
            No Group
#################################
EOF
  $FIND_CMD $2 -type f ! -group "*" >> $RESULTS
  $FIND_CMD $2 -type d ! -group "*" >> $RESULTS

  cat >> $RESULTS << EOF
#################################
         World Writable
#################################
EOF
  $FIND_CMD $2 -perm -002 -type f >> $RESULTS
  $FIND_CMD $2 -perm -002 -type d >> $RESULTS

  cat >> $RESULTS << EOF
#################################
        Hidden Files/Paths
#################################
EOF
  $FIND_CMD $2 -name "..*" -xdev >> $RESULTS

  cat >> $RESULTS << EOF
#################################
    Executable Files in Home
#################################
EOF
  $FIND_CMD /home -type f -executable >> $RESULTS

  cat >> $RESULTS << EOF
#################################
 World-Readable SSH Private Keys
#################################
EOF
  $FIND_CMD /etc/ssh -name "id_*" -perm -0040 >> $RESULTS

  cat >> $RESULTS << EOF
#################################
  Unowned Files and Directories
#################################
EOF
  $FIND_CMD $2 -type f -nouser >> $RESULTS
  $FIND_CMD $2 -type d -nouser >> $RESULTS

  cat >> $RESULTS << EOF
#################################
     Unreadable /etc/shadow
#################################
EOF
  if [ -f "/etc/shadow" ] && [ ! -r "/etc/shadow" ]; then
    echo "/etc/shadow is unreadable by the current user" >> $RESULTS
  fi

  echo "Ended file anomaly search at $($DATE_CMD)" >> $RESULTS
}

case "$1" in
  -s)
    echo "Generating report, this may take a while..."
    dosearch >> /dev/null 2>&1
    $CAT_CMD $RESULTS
    ;;
  -q)
    dosearch >> /dev/null 2>&1
    ;;
  *)
    echo "usage $0: [-s] [-q]"
    echo "-s        Standard"
    echo "-q        Quiet"
    ;;
esac

exit 0
