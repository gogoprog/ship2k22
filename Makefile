default: build

compile:
	haxe build.hxml

build: compile
	mkdir -p build
	cat src/before.html > build/index.html
	cat temp/main.js >> build/index.html
	cat src/after.html >> build/index.html

retail: compile
	mkdir -p retail
	# uglifyjs --compress --mangle --mangle-props --toplevel -O ascii_only=true -- temp/main.js > temp/main.min.js
	terser --compress unsafe_arrows=true,unsafe=true,toplevel=true,passes=8 --mangle --mangle-props --toplevel --ecma 6 -O ascii_only=true -- temp/main.js > temp/main.min.js
	cat src/before.html > retail/index.html
	cat temp/main.min.js >> retail/index.html
	cat src/after.html >> retail/index.html
	stat retail/index.html | grep Size

zip: retail
	rm -f retail/index.zip
	cd retail && zip index.zip index.html
	stat retail/index.zip | grep Size

.PHONY: build retail
