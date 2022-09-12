# cloudseed4eta

Scripts and documentation to seed AWS cloud environment for ETA BILD-AQ project

See [aws_cli.md](./aws_cli.md) for example aws cli command.

Below is info about script to create the EC2 instance.

~~

# Role of this repo.

Help LBL ETA researchers initialize their AWS (and perhaps GCP) cloud account/project.
create a very simple instance (EC2, GCP?).
Create a number of default security group / firewall rules
that allows for LBL, UCB, and popular ISP from the bay area.

so that they can then just tweak and edit an seeded project, 
yet to more secure than having everything wide open to the whole internet.

Seeding AWS was done via TerraForm, under  [terraform_svr/](terraform_svr/)

BUT...

terraform is NOT reat as cross platform between AWS and GCP, 
It does not abstract the platform-specific clause.  While TF's HCL can support code that
deploys to both AWS and GCP, the code is very platform specific.
Does not gain much over the native CloudFormation tool (but the google one sucks?)


New plan: Use Ansible
---------------------


Planning to move to Ansible, 
but need to rely on Ansible Galaxy amazon.aws collection
Determining best way to do this.
TBD.


