#!/bin/bash

aws s3api create-bucket --bucket kore-miteyo-bucket --region ap-northeast-1 --create-bucket-configuration LocationConstraint=ap-northeast-1 --profile admin

