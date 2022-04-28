#!/bin/bash
mkdir -p coverage
lcov --capture --directory . --output-file coverage/coverage.info
cd coverage
genhtml coverage.info --output-directory .
x-www-browser ${PWD}/index.html
