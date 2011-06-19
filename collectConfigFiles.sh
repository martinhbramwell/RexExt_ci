#!/bin/bash 

OURFILE="config.xml"
FILESOURCE="/var/lib/"
FILEDESTINATION="/home/hasan/GitManaged/private/RexExt_ci/src/main/resources/"
FILEPATH="jenkins/jobs/"
# echo ${FILESOURCE}${FILEPATH} 
cd ${FILESOURCE}${FILEPATH}

# ==============
# Build command.
# ==============

for job in $(ls -1)
do
     echo "Copying ${FILESOURCE}${FILEPATH}${job}/${OURFILE} to ${FILEDESTINATION}${FILEPATH}${job}"
     mkdir -p ${FILEDESTINATION}${FILEPATH}${job}
     cp ${FILESOURCE}${FILEPATH}${job}/${OURFILE} ${FILEDESTINATION}${FILEPATH}${job}
done
