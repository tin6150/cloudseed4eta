# Setup for Ansible playbook to use aws collection 

```
python >= 3.6
boto3 >= 1.15.0
botocore >= 1.18.0
```

packages maybe avail form OS, but CentOS 7 yum have version that are too old

# Manually maintain ansible galaxy amazon.aws collection

## one time setup






## one time setup

```
python3 -m venv ./venv4ansible
source venv4ansible/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```


Manually install the amazon.aws ansible collection 
Omit if/when have Ansible 6.3.0 (python 3.9+)
but, Hima only have Python 3.6 and this isnt going to work.
It would still need the ansible playbook to be updated and install ansible galaxy collection 
as a run time task

// *sigh* ansible wants python 3.8, and this old python 3.6 


```
ansible-galaxy collection install amazon.aws
ansible-galaxy collection list
```


# regular use

```
source venv4ansible/bin/activate

```


### anaconda, not using if pip works out


// #xx conda create ansible
