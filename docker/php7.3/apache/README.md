# passwordcockpit docker

# Build image
## With predefined tags
docker build -t passwordcockpit/passwordcockpit:1.0.0 .

## With custom tags
docker build -t passwordcockpit/passwordcockpit:1.0.0 --build-arg PASSWORDCOCKPIT_BACKEND_TAG=0.5.6 --build-arg PASSWORDCOCKPIT_FRONTEND_TAG=0.5.1 .

# Run
docker run passwordcockpit/passwordcockpit:1.0.0