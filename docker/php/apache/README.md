# Passwordcockpit image

## Automantic build image and push to Dockerhub 
Build and push of the image is done via the actio `.github/workflows/docker-image.yml`that is triggered upon creation of a tag.

- Set the hash of backend (PASSWORDCOCKPIT_BACKEND_TAG) and frontend (PASSWORDCOCKPIT_FRONTEND_TAG) in `docker/php/apache/Dockerfile`
- Commit and push the modification
- Tag the version


## Manual build image 
## With predefined tags in the Dockerfile
docker build -t passwordcockpit/passwordcockpit:1.3.3 .

### With custom hashs
For the build better to use the hash instead of the tag since if a tag was already pushed it always uses the old one.

docker build -t passwordcockpit/passwordcockpit:1.3.3 --build-arg PASSWORDCOCKPIT_BACKEND_TAG=f47876589e32961f1eaac80df91d08bb1dd39caa --build-arg PASSWORDCOCKPIT_FRONTEND_TAG=75bc487a5b93bc6137752e71912ef1123cfdec2e .

*_TAG can be a SHA-1 commit or TAG.

## Run
docker run passwordcockpit/passwordcockpit:1.3.3