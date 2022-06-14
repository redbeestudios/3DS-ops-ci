#!/usr/bin/env bash

gitUser=$1
passGit=$2
projectName=$3
declare -a projectLibraries=$4
declare -A replacedLibraries=( [REDIS]='\timplementation?'"'"'org.springframework.boot:spring-boot-starter-data-redis'"'"'\n' [KAFKA]='\timplementation?'"'"'org.springframework.kafka:spring-kafka'"'"'\n' [DB]='\timplementation?'"'"'org.springframework.boot:spring-boot-starter-data-jdbc'"'"'\n\truntimeOnly?'"'"'com.microsoft.sqlserver:mssql-jdbc'"'"'\n' )

declare -A removedClass=( [REDIS]='rm -rf ./ms-seed/src/main/java/prisma/tresde/msseed/adapter/redis/ && rm -rf ./ms-seed/src/test/java/prisma/tresde/msseed/adapter/redis/' [KAFKA]='rm -rf ./ms-seed/src/main/java/prisma/tresde/msseed/adapter/kafka/ && rm -rf ./ms-seed/src/test/java/prisma/tresde/msseed/adapter/kafka/' [DB]='rm -rf ./ms-seed/src/main/java/prisma/tresde/msseed/adapter/jdbc/ && ')
msName=ms-$projectName
projectWithoutSlash=ms$(echo $projectName | sed "s/-//g")
camelcaseMS=$(echo $projectName | sed -E "s/-(.)/\U\1/g")
replacePackageName='s/msseed/'
replaceInFile='s/ms-seed/'
replaceInBuild='s/Seed/'
replaceEnd='/g'
replaceEndDouble='/g'
selectedDependenciesText='s/%SELECTED_DEPENDENCIES%/'
application=Application.java

echo comienzo de creacion de $msName

echo clonando el repositorio ms-seed
git clone http://$gitUser:$passGit@gitlab.com/arquitectura-prisma/issuing/3dsecure/projects/ms-seed.git

echo reemplazando variables
cd ms-seed
find . -type f -name "*.java" -exec sed -i $replacePackageName$projectWithoutSlash$replaceEnd {} +

selectedDependencies='\n'
for i in $projectLibraries;
 do
   selectedDependencies=$selectedDependencies${replacedLibraries[$i]}
 done

sed -i $selectedDependenciesText$selectedDependencies$replaceEnd build.gradle
sed -i 's/?/ /g' build.gradle

sed -i $replaceInBuild$camelcaseMS$replaceEnd build.gradle
sed -i $replaceInBuild$camelcaseMS$replaceEnd ./src/main/java/prisma/tresde/msseed/MsSeedApplication.java
find . -type f -exec sed -i $replaceInFile$msName$replaceEnd {} +
cd ..

for index in ${!removedClass[@]};
 do

    if ! [[ " ${projectLibraries[*]} " =~ " ${index} " ]];
    then
      echo $index
      case $index in
      REDIS)
        rm -rf ./ms-seed/src/main/java/prisma/tresde/msseed/adapter/redis/ && rm -rf ./ms-seed/src/test/java/prisma/tresde/msseed/adapter/redis/
        ;;
      KAFKA)
        rm -rf ./ms-seed/src/main/java/prisma/tresde/msseed/adapter/kafka/ && rm -rf ./ms-seed/src/test/java/prisma/tresde/msseed/adapter/kafka/ && rm  ./ms-seed/src/main/java/prisma/tresde/msseed/application/usecase/CreateSeedUseCase.java && rm  ./ms-seed/src/test/java/prisma/tresde/msseed/application/usecase/CreateSeedUseCaseTest.java
        ;;
      DB)
        rm -rf ./ms-seed/src/main/java/prisma/tresde/msseed/adapter/jdbc/ &&  rm ./ms-seed/src/main/java/prisma/tresde/msseed/config/DatabaseConfiguration.java
        ;;
      SPRING_DATA)
        ;;

      esac

    # ...
    fi
 done


echo reemplazando paquetes
mv ./ms-seed/src/main/java/prisma/tresde/msseed/MsSeedApplication.java ./ms-seed/src/main/java/prisma/tresde/msseed/Ms$camelcaseMS$application
mv ./ms-seed/src/main/java/prisma/tresde/msseed ./ms-seed/src/main/java/prisma/tresde/$projectWithoutSlash
mv ./ms-seed/src/test/java/prisma/tresde/msseed ./ms-seed/src/test/java/prisma/tresde/$projectWithoutSlash
mv ./ms-seed ./$msName
echo  iniciando git
cd $msName
rm -rf .git/
git init


