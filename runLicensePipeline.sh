#!/bin/bash

# You need an ssh-key for github and it has to be added to the ssh-agent:
echo "Add ssh key"
ssh-add ~/.ssh/github.key

# Clone the repo while using ssh-key:
echo "git clone"
git clone git@github.com:fasten-project/fasten-docker-deployment.git

# Jump in the project folder:
echo "cd fasten-docker-deployment"
cd fasten-docker-deployment

# Change the branch
echo "git checkout license-detector"
git checkout license-detector

# Use the docker-compose.yml with useful container names instead of the original one:
echo "cp ../docker-compose.yml fasten-docker-deployment/docker-compose.yml"
cp ../docker-compose.yml docker-compose.yml

# Use the new image location in .env file:
echo "cp ../env fasten-docker-deployment/.env"
cp ../env .env

# Pull the images:
echo "docker-compose pull"
docker-compose pull

# Build the images, especially needed for the metadata-db image:
echo "docker-compose build"
docker-compose build

# Run the licence-detection pipeline:
echo "docker-compose --profile license-detection up -d"
docker-compose --profile license-detection up -d

# Wait 300 s:
 echo "wait 300 s"
 sleep 300

# Feed the database:
echo "cat test-resources/license-detection/fasten.mvn.releases/valid-urls/mvn-projects.txt | docker-compose exec -T kafka kafka-console-producer.sh --broker-list kafka:19092 --topic fasten.mvn.releases --property 'parse.key=true' --property 'key.separator=|'"
cat test-resources/license-detection/fasten.mvn.releases/valid-urls/mvn-projects.txt | docker-compose exec -T kafka kafka-console-producer.sh --broker-list kafka:19092 --topic fasten.mvn.releases --property 'parse.key=true' --property 'key.separator=|'
 
# Wait 300 s:
echo "wait 300 s"
sleep 300

# # Query the database:
echo "query the database"
echo 'PGPASSWORD=fasten1234 psql --host localhost --port 5432 --username fasten fasten_java --command="SELECT * FROM package_versions;"'
PGPASSWORD=fasten1234 psql --host localhost --port 5432 --username fasten fasten_java --command="SELECT * FROM package_versions;"
 
# # Shut down all started containers of this project:
# echo "shut down"
# docker-compose down -v
 
# # Remove the bind-volumes:
# echo "rm -r docker-volumes/fasten"
# rm -r docker-volumes/fasten
