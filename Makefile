Dependancies=Dependancies

CXXFLAGS=  -fPIC -O3 -Wpedantic 

ifeq ($(MAKECMDGOALS),debug)
CXXFLAGS+= -O1 -g -lSegFault -rdynamic -DDEBUG
endif

DataModelInclude =
DataModelLib =

MyToolsInclude =
MyToolsLib =

debug: all

all: lib/libMyTools.so lib/libToolChain.so lib/libStore.so include/Tool.h lib/libDataModel.so lib/libLogging.so main

main: src/main.cpp lib/libStore.so lib/libLogging.so lib/libToolChain.so | lib/libMyTools.so  lib/libDataModel.so 
	@echo -e "\e[38;5;214m\n*************** Making " $@ "****************\e[0m"
	g++ $(CXXFLAGS) src/main.cpp -o main -I include -L lib -lStore -lMyTools -lToolChain -lDataModel -lLogging  -lpthread $(DataModelInclude) $(MyToolsInclude) $(ZMQLib) 

lib/libStore.so: $(Dependancies)/ToolFrameworkCore/src/Store/*
	cd $(Dependancies)/ToolFrameworkCore && $(MAKE) lib/libStore.so
	@echo -e "\e[38;5;118m\n*************** Copying " $@ "****************\e[0m"
	cp $(Dependancies)/ToolFrameworkCore/src/Store/*.h include/
	cp $(Dependancies)/ToolFrameworkCore/lib/libStore.so lib/

include/Tool.h:  $(Dependancies)/ToolFrameworkCore/src/Tool/Tool.h
	@echo -e "\e[38;5;118m\n*************** Copying " $@ "****************\e[0m"
	cp $(Dependancies)/ToolFrameworkCore/src/Tool/Tool.h include/
	cp UserTools/*.h include/
	cp UserTools/*/*.h include/
	cp DataModel/*.h include/

lib/libToolChain.so: $(Dependancies)/ToolFrameworkCore/src/ToolChain/* | lib/libLogging.so lib/libStore.so lib/libMyTools.so lib/libLogging.so lib/libDataModel.so
	@echo -e "\e[38;5;226m\n*************** Making " $@ "****************\e[0m"
	cp $(Dependancies)/ToolFrameworkCore/UserTools/Factory/*.h include/
	cp $(Dependancies)/ToolFrameworkCore/src/ToolChain/*.h include/
	g++ $(CXXFLAGS) -shared $(Dependancies)/ToolFrameworkCore/src/ToolChain/ToolChain.cpp -I include -lpthread -L lib -lStore -lDataModel -lLogging -lMyTools -o lib/libToolChain.so $(DataModelInclude) $(DataModelib) $(MyToolsInclude) $(MyToolsLib)


clean: 

	@echo -e "\e[38;5;201m\n*************** Cleaning up ****************\e[0m"
	rm -f include/*.h
	rm -f lib/*.so
	rm -f main
	rm -f UserTools/*/*.o
	rm -f DataModel/*.o

lib/libDataModel.so: DataModel/* lib/libLogging.so lib/libStore.so  $(patsubst DataModel/%.cpp, DataModel/%.o, $(wildcard DataModel/*.cpp))

	@echo -e "\e[38;5;214m\n*************** Making " $@ "****************\e[0m"
	cp DataModel/*.h include/
	g++ $(CXXFLAGS) -shared DataModel/*.o -I include -L lib -lStore -lLogging -o lib/libDataModel.so $(DataModelInclude) $(DataModelLib)


lib/libMyTools.so: UserTools/*/* UserTools/* lib/libStore.so include/Tool.h lib/libLogging.so $(patsubst UserTools/%.cpp, UserTools/%.o, $(wildcard UserTools/*/*.cpp))| lib/libDataModel.so 

	@echo -e "\e[38;5;214m\n*************** Making " $@ "****************\e[0m"
	cp UserTools/*.h include/
	cp UserTools/*/*.h include/
	g++ $(CXXFLAGS) -shared UserTools/*/*.o -I include -L lib -lStore -lDataModel -lLogging -o lib/libMyTools.so $(MyToolsInclude) $(DataModelInclude) $(MyToolsLib)

lib/libLogging.so:  $(Dependancies)/ToolFrameworkCore/src/Logging/* | lib/libStore.so
	cd $(Dependancies)/ToolFrameworkCore && $(MAKE) lib/libLogging.so
	@echo -e "\e[38;5;118m\n*************** Copying " $@ "****************\e[0m"
	cp $(Dependancies)/ToolFrameworkCore/src/Logging/Logging.h include/
	cp $(Dependancies)/ToolFrameworkCore/lib/libLogging.so lib/

UserTools/%.o: UserTools/%.cpp lib/libStore.so include/Tool.h lib/libLogging.so lib/libDataModel.so
	@echo -e "\e[38;5;214m\n*************** Making " $@ "****************\e[0m"
	cp $(shell dirname $<)/*.h include
	-g++ $(CXXFLAGS) -c -o $@ $< -I include -L lib -lStore -lDataModel -lLogging $(MyToolsInclude) $(MyToolsLib) $(DataModelInclude) $(DataModelib)

target: remove $(patsubst %.cpp, %.o, $(wildcard UserTools/$(TOOL)/*.cpp))

remove:
	echo "removing"
	-rm UserTools/$(TOOL)/*.o

DataModel/%.o: DataModel/%.cpp lib/libLogging.so lib/libStore.so  
	@echo -e "\e[38;5;214m\n*************** Making " $@ "****************\e[0m"
	cp $(shell dirname $<)/*.h include
	-g++ $(CXXFLAGS) -c -o $@ $< -I include -L lib -lStore -lLogging  $(DataModelInclude) $(DataModelLib)
