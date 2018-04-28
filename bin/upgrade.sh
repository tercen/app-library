#!/usr/bin/env bash


rm -r packrat && rm .Rprofile && R --vanilla -e "packrat::init(options = list(use.cache = TRUE))"



git add -A && git commit -m "packrat added" && git tag -a 0.1.6 -m "++" && git push && git push --tags
