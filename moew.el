;;; My Org Elnode webservice (moew)

(require 'elnode)

(defvar moew:org-dir "/home/larsen/Dropbox/org")
(defvar moew:org-filename "mobile-notes.org")
(defvar moew:port 8002)

(defun moew:org-complete-filename ()
  (format "%s/%s" moew:org-dir moew:org-filename))

(defun moew:main-handler (httpcon)
  (elnode-hostpath-dispatcher
     httpcon
     `(("^.*//form"     . moew:form)
       ("^.*//keywords" . moew:keywords)
       ("^.*//save"     . moew:save))))

(defun moew:form (httpcon)
  (elnode-http-start httpcon 200 '("Content-type" . "text/html"))
  (elnode-send-file httpcon "form.html"))

(defun moew:keywords (httpcon)
  (elnode-send-json httpcon
                    (json-encode (cdr (car org-todo-keywords)))))

(defun moew:todo-item-complete-text (keyword body)
  (format "* %s %s\n" keyword body))

(defun moew:save (httpcon)
  (let ((todo-item-body (elnode-http-param httpcon "text"))
        (todo-item-keyword (elnode-http-param httpcon "keyword")))
    (append-to-file 
     (moew:todo-item-complete-text todo-item-keyword todo-item-body)
     nil (moew:org-complete-filename))
    (elnode-send-json httpcon (json-encode "ok"))))

(elnode-start 'moew:main-handler :port moew:port :host "*")
