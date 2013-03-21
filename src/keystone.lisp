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
  ((api-version :initform "v2.0" 
                :initarg :api-version 
                :accessor get-keystone-api-version)
   (auth-url    :initform nil :initarg :auth-url   :accessor get-keystone-auth-url)
   (tenantname  :initform nil :initarg :tenantname :accessor get-keystone-tenantname)
   (username    :initform nil :initarg :username   :accessor get-keystone-username)
   (password    :initform nil :initarg :password   :accessor get-keystone-password)
   (token       :initform nil :initarg :token      :accessor get-keystone-token)
   (tenantid    :initform nil :initarg :tenantid   :accessor get-keystone-tenantid)
   (endpoints   :initform nil :initarg :endpoints  :accessor get-keystone-endpoints)))


(defclass endpoint ()
  ((region   :initform nil :initarg :region   :accessor get-endpoint-region)
   (name     :initform nil :initarg :name     :accessor get-endpoint-name)
   (type     :initform nil :initarg :type     :accessor get-endpoint-type)
   (id       :initform nil :initarg :id       :accessor get-endpoint-id)
   (admin    :initform nil :initarg :admin    :accessor get-endpoint-admin)
   (public   :initform nil :initarg :public   :accessor get-endpoint-public)
   (internal :initform nil :initarg :internal :accessor get-endpoint-internal)))

@export
(defmethod k-init-authorication ((k keystone))
  (multiple-value-bind (status body)
      (with-slots (auth-url api-version tenantname username password) k
        (keystone-request-auth auth-url api-version
                               (keystone-create-auth-json tenantname username password)))
    (setf (get-keystone-token k)     (keystone-get-property-from-hash body "access" "token" "id"))
    (setf (get-keystone-tenantid k)  (keystone-get-property-from-hash body "access" "token" "tenant" "id"))
    (setf (get-keystone-endpoints k) (keystone-create-endpoints-instance-list body)))
  k)

(defmethod k-get-specific-endpoint ((k keystone) servicename)
  (loop for i in (get-keystone-endpoints k)
     if (string= servicename (get-endpoint-name i)) return i))

@export
(defmethod k-get-tenants-list ((k keystone))
  (multiple-value-bind (body-or-stream status-code headers 
                                       uri stream must-close reason-phrase)
      (drakma:http-request (concatenate 'string
                                        (first (get-endpoint-public 
                                                (k-get-specific-endpoint k "keystone")))
                                        "/tenants")
                           :method :get
                           :additional-headers (list (cons "X-Auth-Token" (get-keystone-token k))))
    body-or-stream))

@export
(defmethod k-get-users-list ((k keystone))
  (multiple-value-bind (body-or-stream status-code headers 
                                       uri stream must-close reason-phrase)
      (drakma:http-request (concatenate 'string
                                        (first (get-endpoint-public 
                                                (k-get-specific-endpoint k "keystone")))
                                        "/users")
                           :method :get
                           :additional-headers (list (cons "X-Auth-Token" (get-keystone-token k))))
    body-or-stream))


(defun keystone-get-api-version (url)
  "Get supported api version from keystone => list which include version string."
  (multiple-value-bind (body-or-stream status-code headers 
                                       uri stream must-close reason-phrase)
      (drakma:http-request url
                           :content-type "application/json"
                           :method       :get)
    (unless (= status-code 300)
      (return-from keystone-get-api-version nil))
    (loop for i in 
         (keystone-get-property-from-hash (yason:parse body-or-stream) "versions" "values")
       collect (gethash "id" i))))


(defun keystone-create-auth-json (tenantname username password)
  "Create JSON strig for keystone auth. => json string"
  (json:encode-json-to-string
   `(("auth" ("tenantName" . ,tenantname)
             ("passwordCredentials" ("username" . ,username)
                                    ("password" . ,password))))))

(defun keystone-request-auth (url version json)
  "send auth request to keystone => t/nil and messages"
  (unless (member version (keystone-get-api-version url) :test #'string=)
    (error "Invalid api version"))
  (cond
    ((string= version "v1.0") (setf url (concatenate 'string url "/v1.0/tokens")))
    ((string= version "v2.0") (setf url (concatenate 'string url "/v2.0/tokens")))
    ((stirng= version "v3.0") (setf url (concatenate 'string url "/v3.0/tokens")))
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
                   :id       (keystone-collect-region-endpoint endpointinfo "id")
                   :region   (keystone-collect-region-endpoint endpointinfo "region")
                   :admin    (keystone-collect-region-endpoint endpointinfo "adminURL")
                   :public   (keystone-collect-region-endpoint endpointinfo "publicURL")
                   :internal (keystone-collect-region-endpoint endpointinfo "internalURL"))))

(defun keystone-collect-region-endpoint (hash property)
  (loop for i in (gethash "endpoints" hash)
     collect
       (gethash property i)))

(defun keystone-create-endpoints-instance-list (k-res)
  (loop for i in (keystone-check-endpoint k-res)
       collect (keystone-create-endpoint-instace k-res i)))
