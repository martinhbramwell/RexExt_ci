#!/bin/bash 

OURFILE="config.xml"
JENKINS_HOME="../../../"
FILEPATH="jobs/"
FILEDESTINATION=$('pwd')
FILEDESTINATION=${FILEDESTINATION}/src/main/resources/jenkins/${FILEPATH}
echo "Destination directory is $FILEDESTINATION"
cd ${JENKINS_HOME}${FILEPATH}
BASE_DIR=$('pwd')
echo "Base directory is now $BASE_DIR"

# ==============
# Build command.
# ==============

for job in $(ls -1)
do
     SOURCE=$BASE_DIR/${job}/${OURFILE}
     DESTINATION=${FILEDESTINATION}${job}
     echo "Copying ${SOURCE} to ${DESTINATION}"
     mkdir -p ${DESTINATION} 
     cp ${SOURCE} ${DESTINATION}
done


SOURCE=$BASE_DIR/BuildRexster/workspace/mowaRexster.xml
DESTINATION=${FILEDESTINATION}BuildRexster/workspace/
echo "Copying ${SOURCE} to ${DESTINATION}"
 mkdir -p ${DESTINATION} 
 cp -fr ${SOURCE} ${DESTINATION}

SOURCE=$BASE_DIR/KillRexster/workspace/WaitForRexsterToDie.sh 
DESTINATION=${FILEDESTINATION}KillRexster/workspace/
echo "Copying ${SOURCE} to ${DESTINATION}"
 mkdir -p ${DESTINATION} 
 cp -fr ${SOURCE} ${DESTINATION}

SOURCE=$BASE_DIR/StartRexster/workspace/testLife.sh  
DESTINATION=${FILEDESTINATION}StartRexster/workspace/
echo "Copying ${SOURCE} to ${DESTINATION}"
 mkdir -p ${DESTINATION} 
 cp -fr ${SOURCE} ${DESTINATION}


SOURCE=$BASE_DIR/../*.xml
DESTINATION=${FILEDESTINATION}../
echo "Copying ${SOURCE} to ${DESTINATION}"
 mkdir -p ${DESTINATION}
 cp -fr ${SOURCE} ${DESTINATION}



