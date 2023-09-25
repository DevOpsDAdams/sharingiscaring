if ! aws s3api head-bucket --bucket $1 2>/dev/null
then 
    aws s3api create-bucket --bucket $1 --region $2
fi
