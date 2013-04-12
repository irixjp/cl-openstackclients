#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-openstackclients)

(annot:enable-annot-syntax)

(setf drakma:*drakma-default-external-format* :utf-8)
(pushnew (cons "application" "json") drakma:*text-content-types* :test #'equal)

(defun nova-get-vm-list (k-res)
  (multiple-value-bind (body-or-stream status-code headers uri stream must-close reason-phrase)
      (drakma:http-request 
       (concatenate 'string (keystone-get-endpoint k-res "nova" "publicURL") "/servers/detail")
       :method :get
       :additional-headers (list
                            (cons "X-Auth-Token"      (keystone-get-token  k-res))
                            (cons "X-Auth-Project-Id" (keystone-get-tenant k-res))))
    (yason:parse body-or-stream)))
