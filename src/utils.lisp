#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-openstackclients)

(annot:enable-annot-syntax)

(setf drakma:*drakma-default-external-format* :utf-8)
(pushnew (cons "application" "json") drakma:*text-content-types* :test #'equal)

(defun alist->json (alist)
  (json:encode-json-to-string alist))

(defun json->hash (json)
  (yason:parse json))

(defun http-post-request (url content-json)
  (multiple-value-bind (body-or-stream
                        status-code
                        headers
                        uri
                        stream
                        must-close
                        reason-phrase)
      (drakma:http-request url
                           :content-type "application/json"
                           :method       :post
                           :content      content-json)
    (values status-code body-or-stream)))

(defun http-get-request (url headers-alist)
  (multiple-value-bind (body-or-stream
                        status-code
                        headers
                        uri
                        stream
                        must-close
                        reason-phrase)
      (drakma:http-request url
                           :method :get
                           :additional-headers headers-alist)
    (values status-code body-or-stream)))


(defun get-property-from-hash (hash &rest values)
  "get specified properties from hash"
  (let ((x hash))
    (dolist (y values)
      (setf x (gethash y x)))
    x))
