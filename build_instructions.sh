#!/bin/sh

echo "Building for linux/amd64 into build/linux_x86_64/"
GOOS=linux GOARCH=amd64 go build -o build/linux_x86_64/

echo "Building for darwin/amd64 into build/darwin_x86_64"
GOOS=darwin GOARCH=amd64 go build -o build/darwin_x86_64/

echo "Building for darwin/arm64 into build/darwin_arm_64"
GOOS=darwin GOARCH=arm64 go build -o build/darwin_arm_64/

echo "Building for windows/amd64 into build/windows_x86_64"
GOOS=windows GOARCH=amd64 go build -o build/windows_x86_64/
