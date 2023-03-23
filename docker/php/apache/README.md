# Passwordcockpit image

## Build the image
### With predefined tags in the Dockerfile
docker build -t passwordcockpit/passwordcockpit:1.3.1 .

### With custom hashs
For the build better to use the hash instead of the tag since if a tag was already pushed it always uses the old one.

docker build -t passwordcockpit/passwordcockpit:1.3.1-beta --build-arg PASSWORDCOCKPIT_BACKEND_TAG=a85d73deeeede99e664d785764c1922ef30f8b72 --build-arg PASSWORDCOCKPIT_FRONTEND_TAG=3ebac333208325b1339641af237ae4c6a892902c .

*_TAG can be a SHA-1 commit or TAG.

## Run
docker run passwordcockpit/passwordcockpit:1.3.1