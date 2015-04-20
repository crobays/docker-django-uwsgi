#!/bin/bash
for dir in $(ls src/static)
do
	mkdir -p src/static/$dir/dev-dist
	mkdir -p ./static/$dir
	echo "symlinking: /static/$dir -> dev-dist"
	ln -s ../../src/static/$dir/dev-dist ./static/$dir/dist
done
