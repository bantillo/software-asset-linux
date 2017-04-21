#!/bin/bash

# Sample Asset Installation Script

echo "CONS3RT is installing Zookeeper 3.4.5..."

################################
# SPECIAL ENVIRONMENT VARIABLES
################################

echo "CONS3RT_HOME = ${CONS3RT_HOME}"

echo "ASSET_DIR is a special environment variable pointing to the parent directory of this asset!"
echo "ASSET_DIR = ${ASSET_DIR}"

echo "List the contents of ASSET_DIR:"
find ${ASSET_DIR}

echo "DEPLOYMENT_HOME is a special environment variable point to the deployment.properties file!"
echo "DEPLOYMENT_HOME = ${DEPLOYMENT_HOME}"

echo "List the contents of deployment.properties:"
cat ${DEPLOYMENT_HOME}/deployment.properties

################################
# LOGGING IS YOUR FRIEND
################################

# Check to make sure ASSET_DIR exists
if [ -z ${ASSET_DIR} ] ; then
	echo "ASSET_DIR doesn't exist!"
	exit 1
else
	echo "ASSET_DIR found and set to: ${ASSET_DIR}"
fi

echo "Logs are located here: /opt/cons3rt-agent/log"

cd /opt
echo "Downloading Zookeeper 3.4.5"
wget http://archive.apache.org/dist/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz
echo "Finished downloading Zookeeper 3.4.5"

echo "Installing Zookeeper 3.4.5"
tar -zxf zookeeper-3.4.5.tar.gz

# change the user/owner recursively
chown cons3rt:cons3rt zookeeper-3.4.5 -R

rm zookeeper-3.4.5.tar.gz
echo "Removing Zookeeper 3.4.5 archive"
mv /opt/zookeeper-3.4.5/conf/zoo_sample.cfg /opt/zookeeper-3.4.5/conf/zoo.cfg

echo "createMyIDFile start"
# get the role
zkName=$(getRole)

# parse the number from the role
# it should be of the form zkn, where n is the number in the zookeeper ensemble
zkNumber=${zkName:2}

# create the data directory from the zoo.cfg file, future augmentation
# will be to parse the zoo.cfg file and create that data directory
cd /tmp
mkdir zookeeper

# change the owner to cons3rt, this gives the cons3rt user write capabilities
# to the directory
chown cons3rt:cons3rt /tmp/zookeeper -R

cd zookeeper
# create the myId file and add the zkNumber to the file
echo $zkNumber > myId

echo "createMyIDFile stop"

# retrieve the hostnames
zk1=$(getProperty -r zk1 cons3rt.fap.deployment.machine.hostname)
zk2=$(getProperty -r zk2 cons3rt.fap.deployment.machine.hostname)
zk3=$(getProperty -r zk3 cons3rt.fap.deployment.machine.hostname)

# print out the hostnames
echo "ZK1:"${zk1}
echo "ZK2:"${zk2}
echo "ZK3:"${zk3}

echo "APPENDING SERVERS"

chown cons3rt:cons3rt /opt/zookeeper-3.4.5/conf/zoo.cfg

# append the hostnames in the zoo.cfg file
cat <<EOF >> /opt/zookeeper-3.4.5/conf/zoo.cfg
server.1=${zk1}:2888:3888
server.2=${zk2}:2888:3888
server.3=${zk3}:2888:3888
EOF

echo "APPENDING SERVERS COMPLETED"

echo "STARTING ZOOKEPER"
cd /opt/zookeeper-3.4.5/bin
./zkCLi.sh -server 127.0.0.1:2181
echo "STARTING ZOOKEPER COMPLETED"


# start up the zookeeper
#/opt/zookeeper-3.4.5/bin/zkCli.sh -server 127.0.0.1:2181

################################
# EXIT CODES
################################

# Try changing this value and installing on CONS3RT to see how CONS3RT behaves
exitCode=0

echo "CONS3RT considers the asset a success if this script returns exit code: 0"
echo "Non-zero exit codes will tell CONS3RT to error out and notify you there was an error"

echo "Exiting with code ${exitCode}"
exit #{exitCode}
