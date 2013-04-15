# cl-openstackclient

The cl-openstackclient is simple openstack client libraries.
I tested on Clozure CL 1.9 & Windows7(64bit).


## Usage

### keystone

At first, create keystone instance.

    (setf *keystone* (make-instance 'keystone-v2
                                    :auth-url "http://keystonehost:5000"
                                    :tenantname "tenantname"
                                    :username   "username"
                                    :password   "password")

Second, request auth info to keystone. This method set token & endpoint data to keystone instance from keystone responses.

    (keystone-initialize *keystone*)

If you want the token from keystone instance,

    (get-k2-token *keystone*)
       => bSJ9LCB7ImVuZHBvaW50cyI6IFt7Im ....

If you want specific endpoint url,

    (keystone-get-endpoint *key* "compute")
       => "http://127.0.0.1:8774/v2/6638856879454e00a548871a01463850"

    (keystone-get-endpoint *key* "image" :urltype "adminURL")
       => "http://127.0.0.1:9292"



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


