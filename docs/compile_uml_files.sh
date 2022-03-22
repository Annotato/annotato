#!/bin/sh

JAR_FILE=plantuml.jar

if [ ! -f "$JAR_FILE" ]; then
    echo "\n$JAR_FILE does not exist.\n"
    echo "Download from https://plantuml.com/download"
    exit
fi

java -jar plantuml.jar diagrams/plantuml/*.puml -o ../

