#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-openstackclient-test
  (:use :cl
        :cl-openstackclient
        :cl-test-more))
(in-package :cl-openstackclient-test)

(plan nil)

;; blah blah blah.
(defparameter *auth-url* "http://v157-7-133-23.myvps.jp:5000/v2.0/tokens")
(defparameter *tenant*   "admin")
(defparameter *username* "admin")
(defparameter *password* "openstack2013")

(plan 9)

(diag "keystone-create-auth-json")
(is (keystone-create-auth-json *tenant* *username* *password*) 
    "{\"auth\":{\"tenantName\":\"admin\",\"passwordCredentials\":{\"username\":\"admin\",\"password\":\"openstack2013\"}}}")



(finalize)
