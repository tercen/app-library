#!/usr/bin/env bash


rm -r packrat && rm .Rprofile && R --vanilla -e "packrat::init(options = list(use.cache = TRUE))"



git add -A && git commit -m "tercen lib upgrade" && git tag -a 0.2.3 -m "++" && git push && git push --tags
