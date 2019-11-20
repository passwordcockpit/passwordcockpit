# Passwordcockpit image

## Build the image
### With predefined tags in the Dockerfile
docker build -t passwordcockpit/passwordcockpit:1.0.0-php-7.3-apache .

### With custom tags
docker build -t passwordcockpit/passwordcockpit:1.0.0-php-7.3-apache  --build-arg PASSWORDCOCKPIT_BACKEND_TAG=0.5.6 --build-arg PASSWORDCOCKPIT_FRONTEND_TAG=0.5.1 .

*_TAG can be a SHA-1 commit.

## Run
docker run passwordcockpit/passwordcockpit:1.0.0-php-7.3-apache