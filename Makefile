SHELL := /bin/bash

.PHONY: elm watch minify

default: all

NPM_PATH := ./node_modules/.bin
SRC_DIR := ./src
DIST_DIR := ./dist

export PATH := $(NPM_PATH):$(PATH)

all: elm

assets:
		@mkdir ${DIST_DIR}
		@cp -r ${SRC_DIR}/static ${DIST_DIR}/static
		@cp -r ${SRC_DIR}/index.html ${DIST_DIR}

build: clean assets elmoptimized minify

clean:
		@rm -Rf ${DIST_DIR}/*

deps:
		@npm install
		@elm package install --yes

distclean: clean
		@rm -rf elm-stuff
		@rm -rf node_modules

elm:
		@elm make ${SRC_DIR}/Main.elm --output ${DIST_DIR}/app.js

elmoptimized:
		@elm make --optimize ${SRC_DIR}/Main.elm --output ${DIST_DIR}/app.js

help:
		@echo "Run: make <target> where <target> is one of the following:"
		@echo "  all                    Compile all Elm files"
		@echo "  clean                  Remove 'dist' folder"
		@echo "  deps                   Install build dependencies"
		@echo "  distclean              Remove build dependencies"
		@echo "  help                   Magic"
		@echo "  watch                  Run 'make all' on Elm file change"

minify:
		@npx uglify-js ${DIST_DIR}/app.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | npx uglify-js --mangle --output=${DIST_DIR}/app.js\

serve:
		cd ./dist && python -m http.server 4001

watch:
		find ${SRC_DIR} -name '*.elm' | entr -c make elm
