NAME := "choose"
VERSION := "v0.1.0"

WORKDIR := justfile_directory()
GOOS := shell("go env GOOS")
GOARCH := shell("go env GOARCH")
GOARM := shell("go env GOARM")

TARGETPLATFORM := f"docker/{{GOOS}}/{{GOARCH}}/{{GOARM}}"
PROGRAM := f"{{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}"
DATA := "_license"

default:
  just --list --unsorted --justfile {{justfile()}}

build:
  shards build

release:
  shards build --release

run ARGS="": build
  cd src/{{NAME}} && {{WORKDIR}}/bin/{{NAME}} {{ ARGS }}

target: release
  mkdir -p target/{{TARGETPLATFORM}}
  ln -f bin/{{NAME}} target/{{TARGETPLATFORM}}/
  cp -a src/{{NAME}}/{{DATA}} target/{{TARGETPLATFORM}}/
  # tree target

  cd target/{{TARGETPLATFORM}}/ && ./{{NAME}} list

upload: release
  mkdir -p upload/{{PROGRAM}}
  ln -f bin/{{NAME}} upload/{{PROGRAM}}/
  cp -a src/{{NAME}}/{{DATA}} upload/{{PROGRAM}}/
  # tree upload

  cd upload/{{PROGRAM}}/ && ./{{NAME}} list
  cd upload && just zip '-r {{PROGRAM}}.zip {{PROGRAM}}'
  cd upload && just sha256sum '{{PROGRAM}}.zip >> {{PROGRAM}}.sha256sum'

upload-single: release
  mkdir -p upload
  ln -f bin/{{NAME}} upload/{{PROGRAM}}
  # tree upload

  cd upload && just sha256sum '{{PROGRAM}} >> {{PROGRAM}}.sha256sum'

clean:
  rm -rf target upload

[no-cd, unix]
sha256sum ARGS:
  sha256sum {{ARGS}}

[no-cd, windows]
sha256sum ARGS:
  C:/msys64/usr/bin/sha256sum.exe {{ARGS}}

[no-cd, unix]
zip ARGS:
  zip {{ARGS}}

[no-cd, windows]
zip ARGS:
  C:/msys64/usr/bin/zip.exe {{ARGS}}
