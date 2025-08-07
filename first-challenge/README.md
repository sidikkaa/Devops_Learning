Hello from XOPS-A Static webpage with docker

#How to build the image
docker build -t image_name//docker build -t first-micro-challenge .
#Rebuild the image
docker build --no-cache -t first-micro-challenge .

#How to run the Container
docker run -d -p 8080:80 image_name

#To view build images
docker images
