#/usr/bin/env bash

# Run this at the root of the project
test_dir=./.build/debug
test_binary=$test_dir/Spec

swift build
if [ -e $test_binary ] && [ "$?" -eq 0 ]; then
    $test_binary
else
    echo "Could not run tests..."
    exit 1
fi
