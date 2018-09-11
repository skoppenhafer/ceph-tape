<<<<<<< HEAD
#CEPH VTL

##BACKGROUND

-The goal of this project is to determine feasibility of having a tape system backend Ceph.
-This would provide value by offloading cold objects to low cost storage
-The methodology is to use LTFS as the filesystem beneath the OSD.
-Using ansible for configuration due to ease of deployment with ceph-ansible.

##INSTALLATION

1)  Provision required infrastructure.

Provision test infrastructure, ceph and VTL will be collocated. 3-node cluster, minimum two virtual disks per node.  One for ceph and one for the VTL. 

2) Implement and configure ansible including hosts and SSH keys (ceph-deploy currently incompatible with version ansible 2.6)

Set your ansible configuration for the VTL group.  For this demo the VTL will be colocated on a ceph node.

3) Deploy Ceph cluster using ansible.

Follow ceph ansible install [instructions](http://docs.ceph.com/ceph-ansible/master/)

$ansible-playbook site.yml

4) Install the prereqs for the VTL.  This will restart the nodes.

'$ansible-playbook install_prereqs.yml'

5) Download v3.0.27 from the quadstor website and install the VTL. Verify quadstor-vtl-ext-3.0.27-rhel.x86_64.rpm is in working directory and ensure nodes have completely restarted '$ansible all -m ping)'

'$ansible-playbook install_VTL.yml'

6) Create virtual tape drives and media from the quadstor console

>>Add firewall (HTTP) access to machines
>>add the physical drives to the storage pool
>>configure a new LTO-6 standalone drive ( "Virtual Drives")
>>configure media for the drive ( "Virtual Media")

7) Download and Install the IBM Tape Driver.

>>ensure lin_tape-3.0.31-1.src.rpm is in working directory
$ansible-playbook Install_IBM_Driver.yml

8) Download and install IBM LTF standard edition.

>>ensure ltfssde-2.4.0.2-10071-RHEL7.x86_64.rpm is in working directory
$ansible-playbook install_LTFS.yml

//--------------CONFIGURE TAPE BACKEND------------------//

1) On the Ceph/VTL host... Ensure permissions are correct on the device and verify the devices are available

$sudo chmod a+rw /dev/IBMtape*
$ltfs -o device_list

2) Create filesystem (you may get an XML error, try again.)

$mkltfs -d /dev/IBMtape0 -s VTL001

3) create the osd.  Remember the the output in the next steps, for example osd #3 below (http://docs.ceph.com/docs/jewel/rados/operations/add-or-rm-osds/)

$sudo ceph osd create

7) Make the directory where the file system will be mounted and mount the LTFS filesystem.  The ceph user will be the owner of the directory. If mounting fails do to XML error, attempt to remount

$sudo mkdir /var/lib/ceph/osd/ceph-3
$sudo chown ceph: /var/lib/ceph/osd/ceph-3
$sudo /usr/local/bin/ltfs -o devname=/dev/IBMtape0 -o uid=ceph -o gid=ceph /var/lib/ceph/osd/ceph-3

8) add the following to the ceph conf file (/etc/ceph/ceph.conf)
>>osd max object name len = 256
>>osd max object namespace len = 64
>>journal aio = false

9) initialize the OSD data directory

$cd /var/lib/ceph/osd/ceph-3
$sudo ceph-osd -i 3 --mkfs --mkkey --setuser ceph --setgroup ceph

10) Register the OSD authentication key

$sudo ceph auth add osd.3 osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-3/keyring

11) add the OSD to the default bucket. This is just for testing and will need to be changed later, you can view the crush tree with $sudo ceph osd crush tree to examine the weighting/location
$sudo ceph osd crush add 3 <WEIGHT> host=<HOSTNAME> root=default

12) start the OSD

$sudo systemctl start ceph-osd@3
$sudo systemctl status ceph-osd@3

####FOR REFERENCE, REMOVE THE FOLLOWING LINE IN FINAL VERSION
$sudo /usr/bin/ceph-osd -f --cluster ceph --id 3 --setuser ceph --setgroup ceph

//----------------------TESTING-----------------//

//create storage pool
$sudo ceph osd pool create mypool 64

//write file
$touch test1.txt
$sudo rados -p mypool put test1 test1.txt

//list file writes
$sudo rados -p mypool ls -

//benchmark the object store
$sudo rados bench -p mypool 1 write --no-cleanup

//--------------------REMOVE OSD---------------------------//

$ceph osd out 3
$sudo ceph auth del osd.3
$sudo ceph osd crush remove osd.3
$sudo ceph osd rm 3
=======
This repository contains some helpful playbooks and a procedure for testing ceph with LTFS via a virtual tape library.  Initial testing was successful however this virtual environment is inadequate to determine whether or not this is feasible.  Long term benefit is to create cold storage option and hierarchical storage management possibilities within ceph.  


See procedure.txt for outline.
>>>>>>> dc4538220a3a388e092f6a0849b8f11b4b41708a
