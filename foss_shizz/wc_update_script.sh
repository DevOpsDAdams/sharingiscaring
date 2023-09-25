#!/bin/bash



######################
#
#
# Variable Definitions
#
#
######################
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
print_bold() {
    echo "$(tput bold)*****$@*****$(tput sgr0)"
}
#
#
#
print_bold "Revoking all accounts"
gcloud auth revoke --all
#
#
#

print_bold "Presenting Login for GCP Service Account"
project_name=software-builds
iam_account=image-puller
print_bold "Run the below command in a separate terminal to get the image-puller password:"
sleep 1
sleep 1
print_bold "Press Enter To Continue"
read
if ls ${HOME}/secrets/software-builds.json; then
    print_bold "Software-Builds.json already exists. Skipping Decryption."
else
    print_bold "Decrypting JSON File"
    mkdir -p ${HOME}/secrets
    # --yes to assume "yes" for questions
    gpg --yes --decrypt --output ${HOME}/secrets/software-builds.json ${WORKDIR}/prod_deploy.d/software-builds.json.gpg
fi
print_bold "Authenticating to Google Cloud"
gcloud auth activate-service-account --key-file=${HOME}/secrets/software-builds.json
# Configue GCP application default credentials
echo "export GOOGLE_APPLICATION_CREDENTIALS=${HOME}/secrets/software-builds.json" | tee -a ~/.bash_aliases
#
#
#
#
print_bold "Performing APT Update"
sudo apt update
#
#
#
