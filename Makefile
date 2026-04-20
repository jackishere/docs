.PHONY: help serve build clean deploy release release-push set-default versions serve-versioned

VERSION ?= $(shell git describe --tags 2>/dev/null || echo "dev")

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  serve            Start local dev server (http://127.0.0.1:8000)"
	@echo "  build            Build static site to ./site"
	@echo "  clean            Remove ./site directory"
	@echo "  deploy           Deploy to GitHub Pages (unversioned)"
	@echo ""
	@echo "Versioning (requires: pip install -r requirements.txt)"
	@echo "  serve-versioned  Serve gh-pages branch locally with version selector"
	@echo "  versions         List deployed versions"
	@echo "  release          Deploy version locally then push  TAG=v1.2.0"
	@echo "  release-push     Deploy and push atomically        TAG=v1.2.0"
	@echo "  set-default      Set default version               VER=v1.2.0"

serve:
	mkdocs serve

build:
	mkdocs build

clean:
	rm -rf site

# Legacy unversioned deploy — prefer release-push when using mike
deploy:
	mkdocs gh-deploy

serve-versioned:
	mike serve

versions:
	mike list

release:
	@[ -n "$(TAG)" ] || (echo "Error: TAG is required. Usage: make release TAG=v1.2.0"; exit 1)
	mike deploy --update-aliases $(TAG) latest
	mike set-default latest
	git push origin gh-pages

release-push:
	@[ -n "$(TAG)" ] || (echo "Error: TAG is required. Usage: make release-push TAG=v1.2.0"; exit 1)
	mike deploy --update-aliases --push $(TAG) latest
	mike set-default --push latest

set-default:
	@[ -n "$(VER)" ] || (echo "Error: VER is required. Usage: make set-default VER=v1.2.0"; exit 1)
	mike set-default --push $(VER)
