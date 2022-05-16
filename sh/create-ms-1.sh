#!/usr/bin/env bash

gitUser=$1
passGit=$2
projectName=$3
declare -a projectLibraries=$4
declare -A replacedLibraries=( [REDIS]='\timplementation?'"'"'org.springframework.boot:spring-boot-starter-data-redis'"'"'\n' [KAFKA]='\timplementation?'"'"'org.springframework.kafka:spring-kafka'"'"'\n' [DB]='\timplementation?'"'"'org.springframework.boot:spring-boot-starter-data-jdbc'"'"'\n\truntimeOnly?'"'"'com.microsoft.sqlserver:mssql-jdbc'"'"'\n' )

declare -A removedClass=( [REDIS]='rm -rf ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/adapter/redis/ && rm -rf ./3DS-ms-seed/src/test/java/prisma/tresde/msseed/adapter/redis/' [KAFKA]='rm -rf ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/adapter/kafka/ && rm -rf ./3DS-ms-seed/src/test/java/prisma/tresde/msseed/adapter/kafka/' [DB]='rm -rf ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/adapter/jdbc/ && ')
msName=ms-$projectName
projectWithoutSlash=ms$(echo $projectName | sed "s/-//g")
camelcaseMS=$(echo $projectName | sed -E "s/-(.)/\U\1/g")
replacePackageName='s/msseed/'
replaceInFile='s/3DS-ms-seed/'
replaceInBuild='s/Seed/'
replaceEnd='/g'
replaceEndDouble='/g'
selectedDependenciesText='s/%SELECTED_DEPENDENCIES%/'
application=Application.java

echo comienzo de creacion de $msName

echo clonando el repositorio 3DS-ms-seed
git clone http://$gitUser:$passGit@github.com/redbeestudios/3DS-ms-seed.git

echo reemplazando variables
cd 3DS-ms-seed
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
        rm -rf ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/adapter/redis/ && rm -rf ./3DS-ms-seed/src/test/java/prisma/tresde/msseed/adapter/redis/
        ;;
      KAFKA)
        rm -rf ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/adapter/kafka/ && rm -rf ./3DS-ms-seed/src/test/java/prisma/tresde/msseed/adapter/kafka/ && rm  ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/application/usecase/CreateSeedUseCase.java && rm  ./3DS-ms-seed/src/test/java/prisma/tresde/msseed/application/usecase/CreateSeedUseCaseTest.java
        ;;
      DB)
        rm -rf ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/adapter/jdbc/ &&  rm ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/config/DatabaseConfiguration.java
        ;;
      SPRING_DATA)
        ;;

      esac

    # ...
    fi
 done


echo reemplazando paquetes
mv ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/MsSeedApplication.java ./3DS-ms-seed/src/main/java/prisma/tresde/msseed/Ms$camelcaseMS$application
mv ./3DS-ms-seed/src/main/java/prisma/tresde/msseed ./3DS-ms-seed/src/main/java/prisma/tresde/$projectWithoutSlash
mv ./3DS-ms-seed/src/test/java/prisma/tresde/msseed ./3DS-ms-seed/src/test/java/prisma/tresde/$projectWithoutSlash
mv ./3DS-ms-seed ./$msName
echo  iniciando git
cd $msName
rm -rf .git/
git init


