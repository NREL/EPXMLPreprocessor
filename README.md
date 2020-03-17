# EPXMLPreprocessor

The EPXMLPreprocessor is a computer program that reads an abstract description of a building and writes a complete, fully-functional EnergyPlus input file.  The building xml model is the text input file to the Preprocessor which contains a minimal set of high-level parameters to describe the building type, geometry, loads, and systems. The Preprocessor constructs the resulting EnergyPlus building model by automatically generating and connecting all of the required EnergyPlus objects based on a set of built-in modeling assumptions.

This software is no longer supported and users may use at their own risk

## License

See the [LICENCE.txt](./LICENSE.txt) for the current license. Note that this project contains 3rd party open source code including NativeXml and RegExpr. Those licences are found in the source/3rdparty directory.

## Building on Windows

* Install Lazarus from [here](https://www.lazarus-ide.org/)
* Open `build-lazarus/EPXMLpreproc2.lpi`
* Build the project from the run -> build command
* The binary will be `build-lazarus/bin/EPXMLPreproc2.exe`. This file needs to be moved to the /bin directory where the `include` folder exists.
* Test running in command line by calling `EPXMLPreproc2.exe ../tests/AllSouthWindows/in.xml` and inspect the `../tests/AllSouthWindows/out_pp2.idf`
	
## Building with Lazarus and Docker for Linux

* Run the following command to launch docker with free pascal compiler

```
docker run -it -v $PWD:/app -w /app gabrielrcouto/docker-lazarus:latest /bin/bash
```

* Build the application within the docker container

```
cd /app/build-make
make

# Test using the following command
cd /app/bin
./EPXMLPreproc2 ../tests/AllSouthWindows/in.xml

# Inspect the resulting idf in ../tests/AllSouthWindows/out_pp2.idf
```

* Note that it may be possible to compile the Lazarus project as well using this container.
