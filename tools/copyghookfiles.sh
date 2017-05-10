#!/bin/bash

if [ ! -e .git/hooks/commit-msg ]; then
	cp yongyida/tools/ghooks/* .git/hooks/
fi 