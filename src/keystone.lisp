#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-openstackclient
  (:use :cl))
(in-package :cl-openstackclient)

(annot:enable-annot-syntax)

(setf drakma:*drakma-default-external-format* :utf-8)
(pushnew (cons "application" "json") drakma:*text-content-types* :test #'equal)

@export
(defclass keystone ()
  ((api-version :initform 2   :initarg :api-version)
   (auth-url    :initform nil :initarg :auth-url)
   (tenantname  :initform nil :initarg :tenantname)
   (username    :initform nil :initarg :username)
   (password    :initform nil :initarg :password)
   (token       :initform nil :initarg :token)
   (tenantid    :initform nil :initarg :tenantid)
   (endpoints   :initform nil)))


(defclass endpoint ()
  ((region   :initform nil :initarg :region)
   (name     :initform nil :initarg :name)
   (type     :initform nil :initarg :type)
   (id       :initform nil :initarg :id)
   (admin    :initform nil :initarg :admin)
   (public   :initform nil :initarg :public)
   (internal :initform nil :initarg :internal)))

@export
(defmethod k-init-authorication ((k keystone))
  (multiple-value-bind (status body)
      (with-slots (auth-url api-version tenantname username password) k
        (keystone-request-auth auth-url api-version
                               (keystone-create-auth-json tenantname username password)))
    (setf (slot-value k 'token)     (keystone-get-property-from-hash body "access" "token" "id"))
    (setf (slot-value k 'tenantid)  (keystone-get-property-from-hash body "access" "token" "tenant" "id"))
    (setf (slot-value k 'endpoints) (keystone-create-endpoints-instance-list body)))
  k)



(defun keystone-create-auth-json (tenantname username password)
  "Create JSON strig for keystone auth. => json string"
  (json:encode-json-to-string
   `(("auth" ("tenantName" . ,tenantname)
             ("passwordCredentials" ("username" . ,username)
                                    ("password" . ,password))))))

(defun keystone-request-auth (url version json)
  "send auth request to keystone => t/nil and messages"
  (cond
    ((eql version 1) (setf url (concatenate 'string url "/v1.0/tokens")))
    ((eql version 2) (setf url (concatenate 'string url "/v2.0/tokens")))
    ((eql version 3) (setf url (concatenate 'string url "/v3.0/tokens")))
    (t (error "Invalid Auth Version.")))
  (multiple-value-bind (body-or-stream status-code headers 
                                       uri stream must-close reason-phrase)
      (drakma:http-request url
                           :content-type "application/json"
                           :method       :post
                           :content      json)
    (unless (= status-code 200)
      (return-from keystone-request-auth (values nil body-or-stream)))
    (values t (yason:parse body-or-stream))))


(defun keystone-get-property-from-hash (k-res &rest values)
  "get specified properties from hashed keystone response"
  (let ((x k-res))
    (dolist (y values)
      (setf x (gethash y x)))
    x))


(defun keystone-get-endpoint-from-hash (k-res servicename)
  "get specified endpoint date from hashed keystone response. => a endpoint hashtable"
  (dolist (endpoint (keystone-get-property-from-hash k-res "access" "serviceCatalog"))
    (when (string= (gethash "name" endpoint) servicename)
      (return-from keystone-get-endpoint-from-hash endpoint))))


(defun keystone-check-endpoint (k-res)
  (mapcar #'(lambda (x) (gethash "name" x)) 
          (keystone-get-property-from-hash k-res "access" "serviceCatalog")))


(defun keystone-create-endpoint-instace (k-res servicename)
  (let ((endpointinfo (keystone-get-endpoint-from-hash k-res servicename)))
    (make-instance 'endpoint
                   :name     servicename
                   :type     (gethash "type" endpointinfo)
                   :id       (gethash "id"          (first (gethash "endpoints" endpointinfo)))
                   :region   (gethash "region"      (first (gethash "endpoints" endpointinfo)))
                   :admin    (gethash "adminURL"    (first (gethash "endpoints" endpointinfo)))
                   :public   (gethash "publicURL"   (first (gethash "endpoints" endpointinfo)))
                   :internal (gethash "internalURL" (first (gethash "endpoints" endpointinfo))))))

(defun keystone-create-endpoints-instance-list (k-res)
  (loop for i in (keystone-check-endpoint k-res)
       collect (keystone-create-endpoint-instace k-res i)))
