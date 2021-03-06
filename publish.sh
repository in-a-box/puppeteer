#!/usr/bin/env bash
# 
# To trigger a docker push:
# git tag -a $3 -m "$3" 
# git push origin $3  

set -x

sed -i "s/baseimage/$BASE_IMAGE/g" Dockerfile
sed -i "s/nodejsversion/$NODEJS_VERSION/g" Dockerfile

echo 'Building docker image...'
docker-compose up -d
echo 'Testing docker image...'
sleep 3
docker-compose ps
docker-compose logs puppeteer
docker-compose exec puppeteer npm list | grep puppeteer  
docker-compose exec puppeteer npm start 
ls screenshot.png

echo 'Testing docker-compose.yml...'
docker-compose down
cd examples/puppeteer
docker-compose up -d
sleep 3
docker images
docker-compose ps
docker-compose logs puppeteer
docker-compose exec puppeteer npm list | grep puppeteer  
docker-compose exec puppeteer npm start 
ls screenshot.png

if [ ! -z "$TRAVIS_TAG" ]; then
  if [[ $BASE_IMAGE == 'ubuntu:16.04' && $DOCKER_VERSION == '17.03.0' && $DOCKER_COMPOSE_VERSION == '1.9.0' ]]; then
    docker tag puppeteer nicosmaris/puppeteer:$TRAVIS_TAG
    docker login -u nicosmaris -p "$DOCKER_PASS"
    docker push nicosmaris/puppeteer:$TRAVIS_TAG
  fi
fi

