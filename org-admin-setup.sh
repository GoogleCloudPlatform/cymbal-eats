# New project setup - Run as org admin

PROJECT_ID=cymbal-eats-<random number>

gcloud projects create $PROJECT_ID --organization=$ORGANIZAITON_ID

gcloud beta billing projects link ${PROJECT_ID} --billing-account=$BILLING_ACCOUNT

gcloud config set project ${PROJECT_ID}

gcloud services enable orgpolicy.googleapis.com

cat > vmCanIpForward.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/compute.vmCanIpForward
spec:
 rules:
 - allowAll: true
ENDOFFILE

gcloud org-policies set-policy vmCanIpForward.yaml --project=$PROJECT_ID

cat > allowedPolicyMemberDomains.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/iam.allowedPolicyMemberDomains
spec:
 rules:
 - allowAll: true
ENDOFFILE

gcloud org-policies set-policy allowedPolicyMemberDomains.yaml --project=$PROJECT_ID

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

cat > allowedIngressSettings.yaml << ENDOFFILE
name: projects/$PROJECT_ID/policies/cloudfunctions.allowedIngressSettings
spec:
 rules:
 - allowAll: true
ENDOFFILE

gcloud org-policies set-policy allowedIngressSettings.yaml --project=$PROJECT_ID

# Grant your GCP account owner role on the new project
GCP_USER_ACCOUNT=user@userdomain.altostrat.com
gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:$GCP_USER_ACCOUNT --role=roles/owner

# Login with your GCP account, clone the repo and and run ```./setup.sh```
