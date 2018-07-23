#!/bin/bash

##################################################################
##   Copyright (C) 2018 Guglielmo De Angelis (a.k.a. Gulyx, see
##   https://github.com/gulyx).
##   
##   This file is has been developed for easing the interaction with 
##   the pykmaze project (see at https://github.com/eblot/pykmaze).
##   It has been developed and (not really) tested under Ubuntu 18.04 LTS
##   with KeyMaze 500.
##
##   This is free software: you can redistribute it and/or modify
##   it under the terms of the GNU Lesser General Public License as 
##   published by the Free Software Foundation, either version 3 of the 
##   License, or (at your option) any later version.
##
##   This software is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU Lesser General Public License for more details.
##
##   You should have received a copy of the GNU Lesser General Public License
##   along with this source.  If not, see <http://www.gnu.org/licenses/>.
##
##################################################################

PYKMAZE="/opt/pykmaze/pykmaze/pykmaze.py"
DEVICE="/dev/ttyUSB0"
TARGET_PATH="./"

OPTIND=1
while getopts c:p:o:h OPT
do	case "$OPT" in
# command
	c)	echo "foo"; PYKMAZE="${OPTARG}";;
# device
	p)	DEVICE="${OPTARG}";;
# output dir
	o)	if [ -d "${OPTARG}" ]
        then 
            TARGET_PATH="${OPTARG}/"
        else
            echo >&2 "Target dir \"${OPTARG}\" does not exist!!"
            exit 1
        fi;;
	[h?])	echo >&2 "USAGE $0 [-c <command>] [-p <device>] [-o <target_dir>]"
		exit 1;;
	esac
done

for line in `${PYKMAZE} -p ${DEVICE} -c | tail -n +3 | sed "s/ \+/@/g"`;
## for line in @01@2014-10-12@07:55@13:59@05h33m@13.22km@695m@1717m
do
    id=`echo $line | cut -d @ -f 2`
    date=`echo $line | cut -d @ -f 3`

    filename=$0;
    while [ -e "${filename}" ]
    do
        tmp=`mktemp -u XXX.kml`;
        filename="${TARGET_PATH}${date}_${tmp}"
    done
    
    echo "Processing ${id} --INTO--> ${filename}"
    ${PYKMAZE} -p ${DEVICE} -t ${id} -k ${filename}
done
