# New project setup - Run as org admin

gcloud projects create cymbal-eats-NNNN --organization=NNNN

PROJECT_ID=cymbal-eats-NNNN
gcloud beta billing projects link ${PROJECT_ID} --billing-account=NNNN

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

cat > trusted-images-policy.yaml <<
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
