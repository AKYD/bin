#!/bin/bash

for file in ~/notes/*.txt
do
	dropbox_uploader.sh upload ~/notes/$(basename $file) pie-rate/notes/$(basename $file)
done
