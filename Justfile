NAME := "choose"
VERSION := "v0.1.0"

WORKDIR := justfile_directory()
GOOS := shell("go env GOOS")
GOARCH := shell("go env GOARCH")
GOARM := shell("go env GOARM")
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
  mkdir -p target/{{GOOS}}/{{GOARCH}}/{{GOARM}}
  ln -f bin/{{NAME}} target/{{GOOS}}/{{GOARCH}}/{{GOARM}}/
  cp -a src/{{NAME}}/{{DATA}} target/{{GOOS}}/{{GOARCH}}/{{GOARM}}/
  # tree target

  cd target/{{GOOS}}/{{GOARCH}}/{{GOARM}}/ && ./{{NAME}} list

upload: release
  mkdir -p upload/{{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}
  ln -f bin/{{NAME}} upload/{{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}/
  cp -a src/{{NAME}}/{{DATA}} upload/{{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}/
  # tree upload

  cd upload/{{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}/ && ./{{NAME}} list
  cd upload && zip -r {{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}.zip {{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}
  cd upload && sha256sum {{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}.zip > {{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}.sha256sum

upload-single: release
  mkdir -p upload
  ln -f bin/{{NAME}} upload/{{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}
  # tree upload

  cd upload && sha256sum {{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}} > {{NAME}}-{{VERSION}}-{{GOOS}}-{{GOARCH}}{{GOARM}}.sha256sum

clean:
  rm -rf target upload
