# cloudseed4eta
Scripts and documentation to seed AWS cloud environment for ETA BILD-AQ project


~~~~

# Role of this repo.

Help LBL ETA researchers initialize their AWS (and perhaps GCP) cloud account/project.
create a very simple instance (EC2, GCP?).
Create a number of default security group / firewall rules
that allows for LBL, UCB, and popular ISP from the bay area.

so that they can then just tweak and edit an seeded project, 
yet to more secure than having everything wide open to the whole internet.

Seeding AWS was done via TerraForm, under  terraform_websvr/ 
(ec2_creation TF config from F.C. also worked, but no firewall rules there)

BUT...

terraform is NOT reat as cross platform between AWS and GCP, 
It does not abstract the platform-specific clause.  While TF's HCL can support code that
deploys to both AWS and GCP, the code is very platform specific.
Does not gain much over the native CloudFormation tool (but the google one sucks?)


New plan: Use Ansible
---------------------


There is the gcp module, which is still hard coding to the provider.  
https://docs.ansible.com/ansible/2.5/scenario_guides/guide_gce.html
The gcp module replaces the old gce.

Hopefully Ansible has as much power/feature as TF.
Then at least subsequent machine config can use existing Ansible playbooks.


PS.  There is an Ansible  CloudStack module, 
it seems pretty high level, platform agnostic, and provide a higher level of abstraction:
https://docs.ansible.com/ansible/2.5/scenario_guides/guide_cloudstack.html#introduction
BUT It is for VMware, HyperV, KVM and other VM stuff.  
Not AWS/GCP?

