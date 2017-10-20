# NOVA

Basic Vagrant VM for Node.js development using VirtualBox, Ubuntu 14.04, Nginx and MongoDB.

## What's included?

* [Ubuntu 14.04](https://www.ubuntu.com)
* [Nginx](https://nginx.org/en/)
* [Node.js](https://nodejs.org)
* [npm](https://www.npmjs.com/)
* [MongoDB](https://www.mongodb.com/)
* [PM2](https://github.com/Unitech/pm2)
* [MailDev](https://github.com/djfarrelly/MailDev)
* [Git](https://git-scm.com/)
* [curl](https://curl.haxx.se/)

## Getting Started

1. Download and install [VirtualBox](https://www.virtualbox.org/)
2. Download and install [Vagrant](https://www.vagrantup.com/)
   1. Install [vagrant-hostmanager](https://github.com/smdahlen/vagrant-hostmanager)
      `vagrant plugin install vagrant-hostmanager`
   2. (Optional) Install [vagrant-timezone](https://github.com/tmatilai/vagrant-timezone)
      `vagrant plugin install vagrant-timezone`
3. Clone this repository
    ```bash
    git clone https://github.com/attilabuti/nova.git
    ```
4. Start the VM
    ```bash
    cd nova
    vagrant up
    ```

You can now access your project at [http://projectname.local](http://projectname.local).

The web root is located in the project directory at `app/` and you can install your files there.

## Default VM parameters

You can customize settings by editing config.yaml file.

```yaml
name: projectname
hostname: projectname.local
aliases:
  - mail.projectname.local
virtualbox:
  gui: false
  cpus: 2
  memory: 1024
ip: 10.10.10.150
timezone: Europe/Budapest
appPort: 3000
mongodb:
  user: admin
  password: admin
```

## Usage

Some basic information on interacting with the vagrant box.

### Port Forwards

* 80 - Nginx
* 443 - Nginx
* 1025 - MailDev SMTP port
* 1080 - MailDev web interface
* 9229 - Node.js Inspector
* 27017 - MongoDB

### MongoDB

* Hostname: projectname.local
* Port: 27017
* User: admin
* Password: admin

**Note:** Remote database access is enabled by default, so you can access the MongoDB database using your favorite client with the above credentials.

## What is the provision.sh script doing?

* This file is only run when the virtual machine is initially created or recreated after a `vagrant destroy`
* Updates software on the VM
* Installs necessary packages
* Install Nginx, Node.js, MongoDB, MailDev, PM2
* Generate a self-signed SSL certificate
* Configure Nginx, MongoDB
* Starts Nginx, MongoDB, MailDev

## What is the startup.sh script doing?

This file is run every time the virtual machine is started from a `vagrant up`.

## MailDev

### What is MailDev?

[MailDev](https://github.com/djfarrelly/MailDev) is a simple way to test your project's generated emails during development with an easy to use web interface that runs on your machine built on top of Node.js.

### Using MailDev

Load [http://mail.projectname.local](http://mail.projectname.local) in your browser to view the MailDev interface.

## Vagrant

Vagrant is [very well documented](https://www.vagrantup.com/docs/index.html) but here are a few common commands:

* `vagrant up` starts the virtual machine and provisions it
* `vagrant suspend` will essentially put the machine to 'sleep' with `vagrant resume` waking it back up
* `vagrant halt` attempts a graceful shutdown of the machine and will need to be brought back with `vagrant up`
* `vagrant ssh` gives you shell access to the virtual machine
*	`vagrant destroy` stops and deletes all traces of the vagrant machine

## Changelog

### [1.0.0] (2017-10-20)
* Initial release

## Issues

Submit the [issues](https://github.com/attilabuti/nova/issues) if you find any bug or have any suggestion.

## Contribution

Fork the [repo](https://github.com/attilabuti/nova) and submit pull requests.

## License

This project is licensed under the [MIT License](https://raw.githubusercontent.com/attilabuti/nova/master/LICENSE).