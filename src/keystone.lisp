#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-openstackclients)

(annot:enable-annot-syntax)

(setf drakma:*drakma-default-external-format* :utf-8)
(pushnew (cons "application" "json") drakma:*text-content-types* :test #'equal)

(defun ks-get-api-version (url)
  "Get supported api version from keystone => list which include version string."
  (multiple-value-bind (status main)
      (http-get-request url nil)
    (unless (= status 300)
      (return-from ks-get-api-version nil))
    (loop for i in (get-property-from-hash (json->hash main) "versions" "values")
         collect (get-property-from-hash i "id"))))

(defun ks-create-auth-json (tenantname username password)
  "Create JSON strig for keystone auth. => json string"
  (alist->json
   `(("auth" ("tenantName" . ,tenantname)
             ("passwordCredentials" ("username" . ,username)
                                    ("password" . ,password))))))

(defun ks-v2-request-auth (url auth-json)
  (multiple-value-bind (status main)
      (http-post-request (concatenate 'string url "/v2.0/tokens") auth-json)
    (unless (= status 200)
      (format t "~a~%" main)
      (error "Not Authorized"))
    (json->hash main)))

(defun ks-request-auth (url version auth-json)
  "send auth request to keystone => t/nil and messages"
  (unless (member version (ks-get-api-version url) :test #'string=)
    (error "You can't use API which you specified api version"))
  (cond
    ((string= version "v1.0") nil)
    ((string= version "v2.0") (ks-v2-request-auth url auth-json))
    ((string= version "v3.0") nil)
    (t (error "Invalid Auth Version."))))

(defun ks-v2-collect-endpoints-type (endpoints-list)
  "collect endpoint type => list of endpoint type"
  (loop for i in endpoints-list
     collect (get-property-from-hash i "type")))

(defun ks-v2-get-endpoint-from-hash (endpoints-list servicename)
  "get specified endpoint date from hashed keystone response. => a endpoint hashtable"
  (dolist (endpoint endpoints-list)
    (when (string= (get-property-from-hash endpoint "type") servicename)
      (return-from ks-v2-get-endpoint-from-hash endpoint))))

(defun ks-v2-print-endpoint-info (hashed-endpoint)
  (format t "~a" (get-property-from-hash hashed-endpoint "type"))
  (format t "~10t~a" (get-property-from-hash hashed-endpoint "name"))
  )


@export
(defclass keystone-v2 ()
  ((api-version :initform "v2.0"
                :initarg :api-version
                :accessor get-keystone-api-version)
   (auth-url    :initform nil :initarg :auth-url   :accessor get-k2-auth-url)
   (tenantname  :initform nil :initarg :tenantname :accessor get-k2-tenantname)
   (username    :initform nil :initarg :username   :accessor get-k2-username)
   (password    :initform nil :initarg :password   :accessor get-k2-password)
   (token       :initform nil :initarg :token      :accessor get-k2-token)
   (tenantid    :initform nil :initarg :tenantid   :accessor get-k2-tenantid)
   (endpoints   :initform nil :initarg :endpoints  :accessor get-k2-endpoints)))

@export
(defgeneric keystone-initialize (keystone)
  (:documentation "initialize keystone instance"))

(defmethod keystone-initialize ((k keystone-v2))
  (let ((hash
         (with-slots (auth-url api-version tenantname username password) k
           (ks-request-auth auth-url
                            api-version
                            (ks-create-auth-json tenantname
                                                 username
                                                 password)))))
    (setf (get-k2-token k)
          (get-property-from-hash hash "access" "token" "id"))
    (setf (get-k2-tenantid k)
          (get-property-from-hash hash "access" "token" "tenant" "id"))
    (setf (get-k2-endpoints k)
          (get-property-from-hash hash "access" "serviceCatalog"))
    k))

@export
(defgeneric keystone-get-endpoint (keystone servicetype &key urltype region)
  (:documentation "get endpoint url"))

(defmethod keystone-get-endpoint ((k keystone-v2) servicename &key
                                                                (urltype "publicURL")
                                                                (region "RegionOne"))
  (let ((endpoint (ks-v2-get-endpoint-from-hash (get-k2-endpoints k) servicename)))
    (if endpoint
        (loop for i in (get-property-from-hash endpoint "endpoints")
           if (string= region (get-property-from-hash i "region"))
           do (return (get-property-from-hash i urltype)))
        nil)))


@export
(defgeneric keystone-print-endpoints (keystone &optional servicename)
  (:documentation "print all or specific endpoints"))

(defmethod keystone-print-endpoints ((k keystone-v2) &optional (servicename nil))
  (if servicename
      (progn
        (let ((endpoint (ks-v2-get-endpoint-from-hash (get-k2-endpoints k) servicename)))
          (if endpoint
              (loop for i in (get-property-from-hash endpoint "endpoints")
                 if (string= region (get-property-from-hash i "region"))
                 do (return (get-property-from-hash i urltype)))
              nil)))
      (progn
        (loop for i in (ks-v2-collect-endpoints-type (get-k2-endpoints k))
           do (progn
                )))))
          

;(defmethod k-get-specific-endpoint ((k keystone) servicename)
;  (loop for i in (get-keystone-endpoints k)
;     if (string= servicename (get-endpoint-name i)) return i))
; 
;@export
;(defmethod k-get-tenants-list ((k keystone))
;  (multiple-value-bind (body-or-stream status-code headers 
;                                       uri stream must-close reason-phrase)
;      (drakma:http-request (concatenate 'string
;                                        (first (get-endpoint-public 
;                                                (k-get-specific-endpoint k "keystone")))
;                                        "/tenants")
;                           :method :get
;                           :additional-headers (list (cons "X-Auth-Token" (get-keystone-token k))))
;    body-or-stream))
; 
;@export
;(defmethod k-get-users-list ((k keystone))
;  (multiple-value-bind (body-or-stream status-code headers 
;                                       uri stream must-close reason-phrase)
;      (drakma:http-request (concatenate 'string
;                                        (first (get-endpoint-public 
;                                                (k-get-specific-endpoint k "keystone")))
;                                        "/users")
;                           :method :get
;                           :additional-headers (list (cons "X-Auth-Token" (get-keystone-token k))))
;    body-or-stream))







