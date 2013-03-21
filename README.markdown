# cl-openstackclient

The cl-openstackclient is simple openstack client libraries.
I tested on Clozure CL 1.9 & Windows7(64bit).


## Usage

### keystone

At first, create keystone instance.

    (setf *keystone* (make-instance 'keystone
                                    :auth-url "http://keystonehost:5000"
                                    :tenantname "tenantname"
                                    :username   "username"
                                    :password   "password")

Second, request auth info to keystone. This method set token & endpoint data to keystone instance from keystone responses.

    (k-init-authorication *keystone*)






## Installation

Put this library on loadable Path from common lisp processing system.

ex.)

    ~/.ccl-init.lisp
    -----------------------------------
    (push #P"/home/username/.system-lisp/" asdf:*central-registry*)
    -----------------------------------

    # cd /home/username/.system-lisp
    # git clone https://github.com/irixjp/cl-openstackclients.git

### If you are using Linux.

    # ln -s cl-openstackclients/cl-openstackclient.asd .
    # ln -s cl-openstackclients/cl-openstackclient-test.asd .

### If you are usinf Windows

Create shortcut file of cl-openstackclients/cl-openstackclient.asd & cl-openstackclients/cl-openstackclient-test.asd in "/home/username/.system-lisp"


### Load cl-openstackclient

    # (ql:quickload :cl-openstackclient) 

or

    # (require :cl-openstackclient)


### When you want to test this library.

    # (ql:quickload :cl-openstackclient-test)

or

    # (require :cl-openstackclient-test)


## Dependencies

### main

* cl-annot
* drakma
* cl-ppcre
* cl-json
* yason
* local-time

### for test

* cl-test-more


## Author

* Tomoaki Nakajima

## Copyright

Copyright (c) 2013 Tomoaki Nakajima

# License

Licensed under the LLGPL License.


