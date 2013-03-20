#|
  This file is a part of cl-openstackclient project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-openstackclient-test-asd
  (:use :cl :asdf))
(in-package :cl-openstackclient-test-asd)

(defsystem cl-openstackclient-test
  :author "Tomoaki Nakajima"
  :license "LLGPL"
  :depends-on (:cl-openstackclient
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:file "cl-openstackclient")
                 (:file "keystone"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
