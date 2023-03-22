# Passwordcockpit image

## Build the image
### With predefined tags in the Dockerfile
docker build -t passwordcockpit/passwordcockpit:1.3.0 .

### With custom tags
docker build -t passwordcockpit/passwordcockpit:1.3.0 --build-arg PASSWORDCOCKPIT_BACKEND_TAG=1.3.0 --build-arg PASSWORDCOCKPIT_FRONTEND_TAG=1.2.0 .

*_TAG can be a SHA-1 commit.

## Run
docker run passwordcockpit/passwordcockpit:1.3.0