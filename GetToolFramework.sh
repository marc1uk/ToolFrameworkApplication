#!/bin/bash

toolframework=1
final=1

while [ ! $# -eq 0 ]
do
    case "$1" in
	--help | -h)
	    echo "This script should be run once after initially cloning the ToolFrameworkApplication repository. It retrieves the ToolFrameworkCore repository that provides the core framework on which your application will be built."
	    exit
	    ;;
	
	--no_toolframework )
	    echo "Installing dependencies without ToolFramework"
	    toolframework=0
	    ;;

	--no_final )
            echo "Installing ToolFramework without compiling Applciaiton"
            final=0
            ;;

	
	--Final )
            echo "Compiling Apliciaion"
	    init=0
	    tooldaq=0
            ;;

    esac
    shift
done

mkdir -p Dependencies

cd Dependencies

if [ $toolframework -eq 1 ]
then

git clone https://github.com/ToolFramework/ToolFrameworkCore.git
cd ToolFrameworkCore
make clean
make

export LD_LIBRARY_PATH=`pwd`/lib:$LD_LIBRARY_PATH

fi

cd ../..

if [ $final -eq 1 ]
then
    
    echo "current directory"
    echo `pwd`
    make clean
    make 
    
    export LD_LIBRARY_PATH=`pwd`/lib:$LD_LIBRARY_PATH
fi
