all:
	mkdir -p bin
	fpc -S2cdgi  -gl -vewnhi -l -Fu../source/ -Fu../source/3rdparty/regexpr -Fu../source/3rdparty/nativexml -Fu../source/shared/ -FE./bin ../source/EPXMLPreproc2.dpr
# copy over into build
	chmod +x bin/EPXMLPreproc2
	mv bin/EPXMLPreproc2 ../bin/EPXMLPreproc2

clean:
	rm -f ./bin/*.ppu
	rm -f ./bin/*.o
	rm -f ../bin/EPXMLPreproc2
	rm -f ./bin/EPXMLPreproc2

cleanup:
	rm ./bin/*.ppu
	rm ./bin/*.o