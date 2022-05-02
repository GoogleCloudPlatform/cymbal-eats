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

# vpc-access connectors creation.
cat > vmCanIpForward.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/compute.vmCanIpForward
spec:
 rules:
 - allowAll: true
ENDOFFILE

gcloud org-policies set-policy vmCanIpForward.yaml --project=$PROJECT_ID

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
