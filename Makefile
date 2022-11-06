HUGO_BIN=hugo
#HUGO_BIN=/Users/bapt/go/bin/hugo

.PHONY: build sync dev help
.DEFAULT_GOAL := help

DN=westsidevolley.net

define CHECKLIST
# grammarly
# png-to-webp
# resize
# remove draft state
# gcloud
# sync
# setcache
# twitter card
# google search console, request sitemap 
# google search console, request page indexation
endef
export CHECKLIST

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

gcloud: ## use my personal GCP account
	gcloud config configurations activate baptiste
	# gcloud config set account baptiste.collard@gmail.com
	# gcloud config set project personal-218506

build: ## just build the blog with the 'hugo' command
	$(HUGO_BIN) --gc

dev: ## start local server with livereload
	$(HUGO_BIN) server --disableFastRender -D -F --enableGitInfo --cleanDestinationDir

sync: build gcloud ## build and push blog to GCS
	gsutil -m rsync -d -r ./public/ gs://${DN}

setcache: ## set the cache-control on static resources in the bucket
	gsutil -m setmeta -h "Cache-Control:public, max-age=3600" gs://${DN}/\*/\*.css
	gsutil -m setmeta -h "Cache-Control:public, max-age=3600" gs://${DN}/\*/\*.jpg
	gsutil -m setmeta -h "Cache-Control:public, max-age=3600" gs://${DN}/\*/\*.webp
	gsutil -m setmeta -h "Cache-Control:public, max-age=3600" gs://${DN}/\*/\*.png
	gsutil -m setmeta -h "Cache-Control:public, max-age=3600" gs://${DN}/\*/\*.js

clearcacheforpath: ## clear cache for the given path
	@read -p "Enter path for domain baptistout.net (ex. "/posts/slug/"): " BLOGPATH; \
	gcloud compute url-maps invalidate-cdn-cache blog-global-lb --path $$BLOGPATH --host ${DN}

png-to-webp: ## convert png files to webp
	# for file in static/<slug>/*.png; do cwebp -q 50 "$file" -o "${file%.*}.webp"; done
	# for file in static/<slug>/*.jpg; do cwebp -q 50 "$file" -o "${file%.*}.webp"; done
	# sed -i '' 's/.png/.webp/g' content/posts/<slug>.adoc
	# sed -i '' 's/.jpg/.webp/g' content/posts/<slug>.adoc

resize: ## resize webp images
    # /usr/local/Cellar/graphicsmagick/1.3.36/bin/gm convert blog-advanced-mtls.webp -resize 30% blog-advanced-mtls-30.webp
	# gm convert
	# see also https://www.youtube.com/watch?v=y6_v7Jc6R2I


checklist: ## quick reminder of the pre-publish steps
	@H=$$(echo "$$CHECKLIST" | sed -E 's/^> (.*)$$/\\033[90m\1\\033[0m/g') ;\
	echo "$$H" ;\