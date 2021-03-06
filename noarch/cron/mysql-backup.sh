#!/bin/sh
#
#  mysql-backup.sh
#  Backup a MySQL database and create a time stamped archive.
#
#  Copyright 2002-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    mysqldump
#
#  Notes:
#   - This script has been tested to work with Unix-like operating systems
#   - This script must be run as root
#   - This script can be run via cronjob
#

TIMESTAMP=`date +%Y%m%d-%H%M%S`

good=0

while [ "$#" != 0 ]; do
    flag=$1
    case "$flag" in
        -d) if [ $# -gt 1 ]; then
                database=$2
                good=1
                shift
            else
                echo "You failed to provide a database name using the -d flag"
                good=0
            fi
                ;;

        -u) if [ $# -gt 1 ]; then
                username=$2
                good=1
                shift
            else
                echo "You failed to provide a database username using the -u flag"
                good=0
            fi
                ;;

        -p) if [ $# -gt 1 ]; then
                password=$2
                good=1
                shift
            else
                echo "You failed to provide a database password using the -p flag"
                good=0
            fi
                ;;

        -o) if [ $# -gt 1 ]; then
                outdir=$2
                good=1
                shift
            else
                echo "You failed to provide an output directory using the -o flag"
                good=0
            fi
                ;;

        -r) if [ $# -gt 1 ]; then
                hostname=$2
                good=1
                shift
            fi
                ;;

        -e) if [ $# -gt 1 ]; then
                expire=$2
                good=1
                shift
            fi
                ;;

         *) good=0
                ;;
    esac
    shift
done

if [ $good = 0 ]; then
cat <<EOT

Usage: mysql-backup.sh [-d database] [-u username] [-p password]
                                     [-o output directory] [-r remote host] [-e expire days]
Options:
  -d database name     : specify the database you want to backup
  -u username          : specify the database user name
  -p password          : specify the database password
  -o output directory  : specify the path to the output directory
  -r remote host       : specify the hostname of a remote database
  -e expire days       : specify number of days to keep backup files (default: 365)
EOT

else
    if [ -z "${hostname}" ]; then
        hostname=localhost
    fi

    if [ -z "${expire}" ]; then
        expire=365
    fi

    output="${outdir}/$TIMESTAMP.sql.gz"

    mysqldump -q -e -h${hostname} -u${username} -p${password} ${database} | gzip - > $output

    echo "Backup created in $output"

    # remove expired backups
    find ${outdir} -name *.sql.gz -ctime +${expire} | xargs rm -f
fi

exit 0
