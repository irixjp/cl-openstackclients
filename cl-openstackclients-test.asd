#|
  This file is a part of cl-openstackclients project.
  Copyright (c) 2013 Tomoaki Nakajima (powered.by.solaris@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-openstackclients-test-asd
  (:use :cl :asdf))
(in-package :cl-openstackclients-test-asd)

(defsystem cl-openstackclients-test
  :author "Tomoaki Nakajima"
  :license "LLGPL"
  :depends-on (:cl-openstackclients
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:file "cl-openstackclients"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
