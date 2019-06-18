# Bootstrapping and Maintaining Puppet 6 Infrastructure (Monolitic)

## Preparation

Following third party are needed:

Check the Puppetfile in the following repo for up to date list : git@git.local.domain:/control_repo_puppet.git

### for the puppet servers infrastructure

````
├── camptocamp-augeas (v1.7.0)
├── crayfishx-ldconfig (v0.1.0)
├── herculesteam-augeasproviders_core (v2.1.5)
├── instruct-puppetserver (v2.0.0)
├── puppetlabs-concat (v5.0.0)
├── puppetlabs-hocon (v1.0.1)
├── puppetlabs-inifile (v2.4.0)
├── puppetlabs-postgresql (v5.10.0)
├── puppetlabs-puppet_agent (v0.1.0)
├── puppetlabs-puppetdb (v7.0.1)
├── puppetlabs-puppetserver_gem (v1.0.0)
├── puppetlabs-stdlib (v4.25.1)
└── puppet (???)
````

### For the Bolt integration (TO BE DONE)

````
├── choria-choria (v0.11.0)
├── choria-mcollective (v0.8.0)
├── choria-mcollective_agent_filemgr (v2.0.1)
├── choria-mcollective_agent_package (v5.0.1)
├── choria-mcollective_agent_puppet (v2.2.0)
├── choria-mcollective_agent_service (v4.0.1)
├── choria-mcollective_choria (v0.11.0)
└── choria-mcollective_util_actionpolicy (v3.0.0)
````

Those modules are mirrored on the gitlab and should be retreived
from this location.

All dependencies are also provided in the Puppetfile in this repository.

## Provisioning puppetless the system and prepare for bootstrap

Create a new host.

### step 1 : create 1 monolitic node

After the node is created, do the following steps :

````
yum update
````

* create /etc/yum.repos.d/puppet6.repo with following content :

````
[puppet6]
name=puppet6 packages
baseurl=http://yum.puppet.com/puppet6/el/7/x86_64/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet6-release
enabled=1
gpgcheck=0
````

* install the puppet6 agent

````
yum clean all
yum install puppet-agent
````

* create a custom fact to define the puppet master environment

````
cat /opt/puppetlabs/facter/facts.d/bootstrap.yaml
---
puppet_master_env: < PUPPET_MASTER_ENV >

````

* create the directory '/etc/puppetlabs/code/environments/production/modules'
* in above directory, checkout all modules defined in the Puppetfile
* Tested with latest version for all modules

````
cd /etc/puppetlabs/code/environment/production/modules
git clone <:git value> <mod value>
git chekout <:ref value>

git clone git@git.local.net:op/puppet/modules/mirror/puppetlabs-stdlib.git stdlib
....
````

When all modules are located there, one can create the following node definitions in the
manifest directory : This can be generated during bootstrap :

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::mononodes'
````

These nodefiles uses the puppet infra certname (see above), making it mandatory to get the puppet
certificate with these aliases as certname.

Node definitions only needs to be installed on the ca_master and all compile nodes.

### step2 - create ca master, pgsql, puppetdb all in onde node

* set the hostname simular to the choosen dns name
  * hostname p6ca-<env>.${domain}
* start local installation with puppet apply

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::monolitic'
````

This will fail because puppetdb is still missing / A bug in the postgresql module:

* Fix selinux context

We should file a bugreport (and patch) for the postgresql module used.
the concat { } statements for config files in ::config.pp should have a $seltype of postgresql_db_t

````
chcon --reference=/var/lib/pgsql /var/opt/rh/rh-postgresql96/lib/puppetdb/*.conf
systemctl start rh-postgresql96-postgresql
````

* start the puppetserver manually

````
systemctl start puppetserver
````

* run puppet agent to generate the ca certificate (and make sure ssl certificates are in the correct place for puppetdb)

````
puppet agent  -t --onetime --no-daemonize --noop
puppetdb ssl-setup
````

* Run puppet apply again

````
systemctl stop puppetdb
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::monolitic'
````

* Run the puppet apply command a few more times and you should be good to go

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::monolitic'
puppet agent -t # Can now also be used
````

# Bootstrapping and Maintaining Puppet 5 Infrastructure

## the initial setup

Per environment:

* one CA_master
* multiple compile masters
* one puppetdb
* one postgresql

### The SandBox nodes

| official host name | puppet infra role | main ip address | puppet infra certname |
|---|---|---|---|
| host1.${domain} | ca_master          | ${ipaddress}  | p5ca-${domain}  |
| host2.${domain} | postgresql         | ${ipaddress}  | p5pg-${domain}  |
| host3.${domain} | puppetdb           | ${ipaddress}  | p5db-${domain}  |
| host4.${domain} | compile_master 01  | ${ipaddress}  | p5pm1-${domain} |
| host5.${domain} | agent              | ${ipaddress}  | |

### Naming convention

* ca server : p5ca-<environment> where environment in [ 'sbx', 'tst', 'prd', 'dev' ]
* puppetdb server : p5db-<environment> where environment in [ 'sbx', 'tst', 'prd', 'dev' ]
* postgresql server : p5pg-<environment> where environment in [ 'sbx', 'tst', 'prd', 'dev' ]
* compilemaster : p5m[1-9]-<environment> where environment in [ 'sbx', 'tst', 'prd', 'dev' ]

## Procedure too bootstrap a monolitic setup

* boot up a node
* yum update -y 
* yum install http://yum.puppet.com/puppet6-release-el-7.noarch.rpm
* yum install puppet-agent
* reboot the system
* Transfer all needed modules to the target node:

````
/etc/puppetlabs/code/environments/production/modules
├── camptocamp-augeas (v1.7.0)
├── crayfishx-ldconfig (v0.1.0)
├── croddy-make (v999.999.999)
├── gentoo-portage (v2.3.0)
├── herculesteam-augeasproviders_core (v2.4.0)
├── instruct-puppetserver (v2.0.0)
├── puppet (???)
├── puppet-r10k (v4.0.2)
├── puppetlabs-apt (v7.0.1)
├── puppetlabs-concat (v6.0.0)
├── puppetlabs-firewall (v2.0.0)
├── puppetlabs-gcc (v0.2.0)
├── puppetlabs-git (v0.5.0)
├── puppetlabs-hocon (v1.0.1)
├── puppetlabs-inifile (v3.0.0)
├── puppetlabs-pe_gem (v0.2.0)
├── puppetlabs-postgresql (v6.1.0)
├── puppetlabs-puppetdb (v7.3.0)
├── puppetlabs-puppetserver_gem (v1.1.0)
├── puppetlabs-ruby (v1.0.1)
├── puppetlabs-stdlib (v5.2.0)
├── puppetlabs-translate (v1.2.0)
└── puppetlabs-vcsrepo (v3.0.0)
````

* optional: edit /opt/puppetlabs/facter/facts.d/bootstrap.yaml
````    
---
puppet_master_env: sandbox
````
* puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::mononodes'
* puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::monolitic'

One could run last command multiple time.

Test for succesfull isntallation : run **puppet agent -t**

This should succeed without error

## Preparation

Following third party are needed:

Check the Puppetfile in the following repo for up to date list : git@git.local.domain:/control_repo_puppet.git

### for the puppet servers infrastructure

````
├── camptocamp-augeas (v1.7.0)
├── crayfishx-ldconfig (v0.1.0)
├── herculesteam-augeasproviders_core (v2.1.5)
├── instruct-puppetserver (v2.0.0)
├── puppetlabs-concat (v5.0.0)
├── puppetlabs-hocon (v1.0.1)
├── puppetlabs-inifile (v2.4.0)
├── puppetlabs-postgresql (v5.10.0)
├── puppetlabs-puppet_agent (v0.1.0)
├── puppetlabs-puppetdb (v7.0.1)
├── puppetlabs-puppetserver_gem (v1.0.0)
├── puppetlabs-stdlib (v4.25.1)
└── puppet (???)
````

### For the Bolt integration (TO BE DONE)

````
├── choria-choria (v0.11.0)
├── choria-mcollective (v0.8.0)
├── choria-mcollective_agent_filemgr (v2.0.1)
├── choria-mcollective_agent_package (v5.0.1)
├── choria-mcollective_agent_puppet (v2.2.0)
├── choria-mcollective_agent_service (v4.0.1)
├── choria-mcollective_choria (v0.11.0)
└── choria-mcollective_util_actionpolicy (v3.0.0)
````

Those modules are mirrored on the gitlab and should be retreived
from this location.

All dependencies are also provided in the Puppetfile in this repository.

## Provisioning puppetless the system and prepare for bootstrap

In foreman, create a new host.

### step 1 : create 3 nodes for CA, Postgresql and puppetdb

After the nodes are created, do the following steps :

**needed on all nodes**

* create /etc/yum.repos.d/puppet5.repo with following content :

````
# For your nodes
[puppet5]
name=puppet5 packages
baseurl=http://yum.puppet.com/puppet5/el/7/x86_64/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5-release
enabled=1
gpgcheck=0
````

````
# in your vagrant environment with local repos
[puppet5]
name=puppet5 packages
baseurl=file:///vagrant/repos/puppet5/el/7/x86_64
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5-release
enabled=1
gpgcheck=0
````

* install the puppet5 agent

````
yum clean all
yum install puppet-agent
````
* create a custom fact to define the puppet master environment

````
cat /opt/puppetlabs/facter/facts.d/bootstrap.yaml
---
puppet_master_env: < PUPPET_MASTER_ENV >

````

* create the directory '/etc/puppetlabs/code/environments/production/modules'
* in above directory, checkout all modules defined in the Puppetfile

````
cd /etc/puppetlabs/code/environment/production/modules
git clone <:git value> <mod value>
git chekout <:ref value>

git clone git@git.local.net:op/puppet/modules/mirror/puppetlabs-stdlib.git stdlib
git checkout 5.1.0
....
````

When all modules are located there, one can create the following node definitions in the
manifest directory : This can be generated during bootstrap :

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::nodes'
````

These nodefiles uses the puppet infra certname (see above), making it mandatory to get the puppet
certificate with these aliases as certname.

Node definitions only needs to be installed on the ca_master and all compile nodes.

### step2 - create ca master

* execute step1 on the ca node
* set the hostname simular to the choosen dns name
  * hostname p5ca.${domain}
* start local installation with puppet apply

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::ca_master'
````

or

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules /etc/puppetlabs/code/environments/production/manifests/p5ca.${domain}.pp
````

This will fail because puppetdb is still missing:

* run puppet agent to generate the ca certificate

````
puppet agent  --onetime --no-daemonize
````

* start the puppetserver manually

````
systemctl start puppetserver
````


### step 3 - Create the postgresql

* install puppet-agent 5.x on the pg node (see step #1)
* add p5ca.${domain} to the local /etc/hosts if not resolvable by dns
* do a puppet agent : node definitions should be generated on the ca_master

````
puppet agent -t --server p5ca.${domain}
````

This action should be succesfull, and postgresql should be up and running, and accessible

### step 4 - Create the puppetdb

* install puppet-agent 5.x on the db node (see step #1)
* add p5ca.${domain} to the local /etc/hosts if not resolvable by dns
* add p5pg.${domain} to the local /etc/hosts if not resolvable by dns
* do a puppet agent : node definitions should be generated on the ca_master

````
puppet agent -t --server p5ca.${domain}
````

When getting an error like :

````
Error: Execution of '/usr/bin/yum -d 0 -e 0 -y install puppetdb' returned 1: warning: /var/cache/yum/x86_64/7Server/rhel-7-server-rpms/packages/copy-jdk-configs-3.3-10.el7_5.noarch.rpm: Header V3 RSA/SHA256 Signature, key ID fd431d51: NOKEY
Public key for copy-jdk-configs-3.3-10.el7_5.noarch.rpm is not installed
````

execute a **yum clean all** and retry above apply or agent run

This should give you a running and accessible puppetdb.

### step 5 - on the ca_master node : puppetdb activation

* add p5db.${domain} to the local /etc/hosts if not resolvable by dns
* stop puppetserver

````
systemctl stop puppetserver
````

* run puppet apply again

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules /etc/puppetlabs/code/environments/production/manifests/p5ca.{domain}.pp
````

Now a succesfull run should happen, and the puppetserver service should be started succesfully

### step 6 - export needed resources

On all 3 systems just created, one should execute a puppet agent run, to make the exported reources available.  One should
do this seuentially on all nodes two times in a row.


````
puppet agent -t --server p5ca.domain
````

### step 7 - active choria configuration in the node definitions

In the nodefiles, all choria profiles are commented out.  Since the choria modules needs a working
puppetserver/puppetdb setup, now we need to uncomment them and execute a puppet agent run the
ca_master first, since this will be the choria broker node.  After that one can trigger puppet runs on
the remaining nodes to install the choria mco server part and plugins.

Those generated node files can now be added to the manifest directory of your control repo.

Keep in mind that following needs to be true:

* host aliases must be resolvable (dns or /etc/hosts) (is maintained using exported reources)
* The puppet infrastructure is managed at this moment in the default 'production' environment

### Adding a compile master

* install puppet-agent 5.x on the compile master node (see step #1)
* install all puppetcode in /etc/puppetlabs/code/environments/production (as is done on the CA master)
* add p5ca-sbxjdw.${domain} to the local /etc/hosts if not resolvable by dns
* add p5db-sbxjdw.${domain} to the local /etc/hosts if not resolvable by dns
* do a puppet apply (mandatory)

````
puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules -e 'include puppet::puppet::server::compile_master'
````

* remove /etc/puppetlabs/puppet/ssl if existing
* do a puppet agent run and sign the certificate.  This must be done manually due to using dns_alt_mames

````
puppet agent -t --ca_server p5ca.${domain}
# on the ca_master-
puppet ca list
puppet ca sign <compile_master certificate> --allow_dns_alt_names
````

* Now one can do a puppet agent run to configure the compile master

````
puppet agent -t --server p5ca.${domain}
````

# r10k
## Gitlab actions

* Create a gitlab user dedicated for r10k: username r10k
* Create a ssh key for this user : id_deploy_gitlab_rsa
* Add the public key in gitlab to the r10k user:
  * using the gitlab web interface :
    * login as the r10k user
    * go to the user settings (via dropdown user gravitar right corner)
    * select SSH keys from the left menu
    * copy the public key into the box and press 'add key'
* assign rights to the r10k user
  * Login as a user wuith admin rights
  * Go to the **op/puppet/modules** group
  * search for the **r10k** user
  * Assign the **Reporter** role to this user, and press **Add to group**
* If git projects are used outside the **op/puppet/modules** group, grant r10k also the **Reporter** rights:
  * Go to the project
  * In **Settings** (left menu), select **members**, and add **r10k** as a **Reporter**

## This module

* add at least the private key to the **files** directory of this module.

In the puppet::puppet::server::r10k class, this file wil be installed at : **/etc/puppetlabs/r10k/id_deploy_gitlab_rsa**

## Using r10k

### Deploy from puppet_control_repo

This will checkout the controlrepo, and create environments for all branches found in this repo. It will
also checkout all modules defined in the Puppetfile as defined in the branch.

````
r10k deploy environment --puppetfile -v
````

### Deploy in current directory in ./modules

````
r10k puppetfile install
````

R10k will use a Puppetfile in the current directory

# Choria installation - puppe module mirroring

Keep  in mind one cannot use the github projects for choria plugins, since these or not puppet modules.  One
need to use the modules only provided on the forge.  We mirrored those module manually using following procedure:

* checkout the projects on git.local.net, in the group **op/puppet/modukles/forge**
* goto your cloned project
* In the metadata.json, check the forge project name
* download the latest version from the forge : **puppet module install <forge project> --modulepath .**
* add all changes and commit them locally
* create a tag of the version downloaded from the forge
* push them to git.local.net : **git push origin master**
* push the tags to git.local.net : **git push tags**
* Adjust whatever system is used to deploy modules to the puppet compile masters

We choose to install the choria brooker and dependencies the CA_master.

The choria client will be on a dedicated node.  From this node, choria commands will be issued.

## Choria infrastructure

We will still be using puppet-mcollective with choria, since the re-written choria server is still in beta.

For production, we should be using DNS SRV records, but for other enironments we need to configure mcollective using
hieradata.

To be compatible with the hierarchy, we need to add the following yaml files :

* /etc/puppetlabs/code/hieradata/puppet/common.yaml appicable to vagrant environments
* /etc/puppetlabs/code/hieradata/puppet/<pupept_env>.yaml applicable to puppet_mater_env environments

Add the following entries to above yaml files:

```
cat common.yaml
---
mcollective_choria::config:
  use_srv_records: false
  puppetserver_host: "p5m.%{facts.domain}"
  puppetserver_port: 8140
  puppetca_host: "p5ca.%{facts.domain}"
  puppetca_port: 8140
  puppetdb_host: "p5db.%{facts.domain}"
  puppetdb_port: 8081
  discovery_host: "p5db.%{facts.domain}"
  discovery_port: 8085
  middleware_hosts: "p5nats.%{facts.domain}:4222"
````

```
cat <PUPPET_ENV>.yaml
---
mcollective_choria::config:
  use_srv_records: false
  puppetserver_host: "p5m-<PUPPET_ENV>.%{facts.domain}"
  puppetserver_port: 8140
  puppetca_host: "p5ca-<PUPPET_ENV>.%{facts.domain}"
  puppetca_port: 8140
  puppetdb_host: "p5db-<PUPPET_ENV>.%{facts.domain}"
  puppetdb_port: 8081
  discovery_host: "p5db-<PUPPET_ENV>.%{facts.domain}"
  discovery_port: 8085
  middleware_hosts: "p5nats-<PUPPET_ENV>.%{facts.domain}:4222"
````
## Choria client installation

* On a clean node, install puppet 5
* Generate the certificate doeing a puppet run : **puppet agent -t --server p5ca-<PUPPET_ENV>.${domain}**
* classify this node with the profile : puppet::choria::client
* execute a puppet run

### Testing initial choria client

As a regular user :

* mco choria request-cert
* mco ping

This should create a signed ssl certificate and one should see a list of all nodes with the choria server part
installed on.

# TODO

* make the code aware if running apply or agent mode (using $trusted['authorization]' {local|remote}] fact)
* monitoring
    * built in monitoring : https://<compile_master>:8140/puppet/experimental/dashboard.html
    * check https://logz.io/blog/puppet-server-monitoring-part-1/ for ELK/grafana integration
* loadbalancer (netscaler)
* pipeline/control repo ???
* foreman for puppet5 ???

# Repos mirroring

Following are some methods to mirror both yum.puppetlabs.com and the choria repositries.  Keep in  mind that these
intructions are mainly to be used in your own vagrant environment to have those repos locally available.

## yum.puppetlabs.com repo

* Create a directory for the downloaded rpms. ( ~/<vagrant project dir>/repos/puppet5/el/7/x86_64)
* Make this directory your current one
* Execute following wget command (this will only download new packages):

````
wget -c  --no-parent --no-directories -P . -r  -l1 -A.rpm http://yum.puppetlabs.com/puppet5/el/7/x86_64/
````

* execute a createrepo command :

````
createrep_c .
````

## Choria repositories

To make things more easier, create a vagrant box with the distribution you want to have the packages mirrored.
On that box, as root, execute :

* yum -y install yum-utils
* curl -s https://packagecloud.io/install/repositories/choria/release/script.rpm.sh | sudo bash
* reposync --repoid='choria_release'
* cd choria_release
* createrep_c .

This will create a /etc/yum.repo/choria_release.repo for the current OS and mirror the packages inside a choria_release directory
in your current dir.
