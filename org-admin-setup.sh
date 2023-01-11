# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# New project setup - Run as org admin

PROJECT_ID=cymbal-eats-$RANDOM-$RANDOM
ORGANIZATION_ID=your org id
BILLING_ACCOUNT=your billing account id
GCP_USER_ACCOUNT=user@userdomain.altostrat.com

gcloud projects create $PROJECT_ID --organization=$ORGANIZATION_ID

gcloud beta billing projects link ${PROJECT_ID} --billing-account=$BILLING_ACCOUNT

gcloud config set project ${PROJECT_ID}

gcloud services enable \
    orgpolicy.googleapis.com \
    compute.googleapis.com

gcloud compute networks create default --subnet-mode=auto

sleep 1m

# vmExternalIpAccess
cat > vmExternalIpAccess.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/compute.vmExternalIpAccess
spec:
 rules:
 - allowAll: true
ENDOFFILE
gcloud org-policies set-policy vmExternalIpAccess.yaml --project=$PROJECT_ID

# vpc-access connectors creation.
cat > vmCanIpForward.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/compute.vmCanIpForward
spec:
 rules:
 - allowAll: true
ENDOFFILE

gcloud org-policies set-policy vmCanIpForward.yaml --project=$PROJECT_ID

# requireOsLogin
# cat > requireOsLogin.yaml << ENDOFFILE
# name: projects/$PROJECT_ID/policies/compute.requireOsLogin
# spec:
#  rules:
#  - allowAll: true
# ENDOFFILE
# gcloud org-policies set-policy requireOsLogin.yaml --project=$PROJECT_ID

# requireShieldedVm
# cat > requireShieldedVm.yaml << ENDOFFILE
# name: projects/$PROJECT_ID/policies/compute.requireShieldedVm
# spec:
#  rules:
#  - allowAll: true
# ENDOFFILE
# gcloud org-policies set-policy requireShieldedVm.yaml --project=$PROJECT_ID

# Domain restricted sharing. To allow allUsers access on resource, ex. GCS.
# Allow Cloud Run public access
cat > allowedPolicyMemberDomains.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/iam.allowedPolicyMemberDomains
spec:
 rules:
 - allowAll: true
ENDOFFILE

gcloud org-policies set-policy allowedPolicyMemberDomains.yaml --project=$PROJECT_ID

# Define trusted image projects. serverless-vpc-access-images.
cat > trusted-images-policy.yaml << ENDOFFILE
constraint: constraints/compute.trustedImageProjects
listPolicy:
 allowedValues:
 - projects/suse-sap-cloud
 - projects/opensuse-cloud
 - projects/rhel-sap-cloud
 - projects/windows-sql-cloud
 - projects/suse-cloud
 - projects/cos-cloud
 - projects/debian-cloud
 - projects/fedora-coreos-cloud
 - projects/rocky-linux-cloud
 - projects/fedora-cloud
 - projects/centos-cloud
 - projects/rhel-cloud
 - projects/ubuntu-os-cloud
 - projects/confidential-vm-images
 - projects/windows-cloud
 - projects/ubuntu-os-pro-cloud
 - projects/serverless-vpc-access-images
ENDOFFILE

gcloud resource-manager org-policies set-policy trusted-images-policy.yaml --project=$PROJECT_ID

# Allowed ingress settings (Cloud Functions)
cat > allowedIngressSettings.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/cloudfunctions.allowedIngressSettings
spec:
 rules:
 - allowAll: true
ENDOFFILE

gcloud org-policies set-policy allowedIngressSettings.yaml --project=$PROJECT_ID

# Grant your GCP account owner role on the new project
gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:$GCP_USER_ACCOUNT --role=roles/owner

# Login with your GCP account, clone the repo and run ```./setup.sh```
