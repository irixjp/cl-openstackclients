#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

#|
  Author: Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-openstackclient-asd
  (:use :cl :asdf))
(in-package :cl-openstackclient-asd)

(defsystem cl-openstackclient
  :version "0.1"
  :author "Tomoaki Nakajima"
  :license "LLGPL"
  :depends-on (:cl-annot
               :drakma
               :cl-ppcre
               :cl-json
               :yason
               :local-time
               )
  :components ((:module "src"
                :components
                ((:file "cl-openstackclient")
                 (:file "keystone")
                 (:file "nova"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (load-op cl-openstackclient-test))))
