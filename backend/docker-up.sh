#!/bin/bash

docker build -t img-miteyo-backend .

docker run -p 8080:8080 img-miteyo-backend
