FILENAME := a286476964434f1dcb7f620f37115d8bfca347b1.tar.gz

.PHONY: package
package: ./myhtml-c/lib/libmyhtml_static.a

./myhtml-c:
	git clone --depth 1 https://github.com/lexborisov/myhtml.git ./myhtml-c
	# cd myhtml-c && git reset --hard b473eb71c8150a3bb274ebb1de916574eb15e7d1
	# rm -rf ./myhtml-c
	# wget https://github.com/lexborisov/myhtml/archive/$(FILENAME)
	# mkdir -p myhtml-c
	# tar -xzf $(FILENAME) -C myhtml-c --strip-components 1
	# rm ./$(FILENAME)

./myhtml-c/lib/libmyhtml_static.a: ./myhtml-c
	cd myhtml-c && make library MyHTML_BUILD_SHARED=OFF MyCORE_BUILD_WITHOUT_THREADS=YES PROJECT_OPTIMIZATION_LEVEL=-O3

.PHONY: clean
clean:
	rm ./myhtml-c/lib/libmyhtml_static.a
	rm -rf ./mhtml-c
