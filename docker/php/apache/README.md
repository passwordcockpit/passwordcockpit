# Passwordcockpit image

## Build the image
### With predefined tags in the Dockerfile
docker build -t passwordcockpit/passwordcockpit:1.3.2 .

### With custom hashs
For the build better to use the hash instead of the tag since if a tag was already pushed it always uses the old one.

docker build -t passwordcockpit/passwordcockpit:1.3.2 --build-arg PASSWORDCOCKPIT_BACKEND_TAG=f47876589e32961f1eaac80df91d08bb1dd39caa --build-arg PASSWORDCOCKPIT_FRONTEND_TAG=75bc487a5b93bc6137752e71912ef1123cfdec2e .

*_TAG can be a SHA-1 commit or TAG.

## Run
docker run passwordcockpit/passwordcockpit:1.3.2