#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-openstackclients-test
  (:use :cl
        :cl-openstackclients
        :cl-test-more))
(in-package :cl-openstackclients-test)

(plan nil)

(defparameter *auth-url* "http://hostname:5000")
(defparameter *tenant*   "admin")
(defparameter *username* "admin")
(defparameter *password* "openstack")

(diag "keystone-create-auth-json")
(is (cl-openstackclients::keystone-create-auth-json *tenant* *username* *password*) 
    "{\"auth\":{\"tenantName\":\"admin\",\"passwordCredentials\":{\"username\":\"admin\",\"password\":\"openstack2013\"}}}")


(finalize)
