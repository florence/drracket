
#lang scheme/unit
  (require string-constants
           "drsig.ss"
           mzlib/list
           mred)
  
  
  (import)
  (export drscheme:init^)
  
  (define original-output-port (current-output-port))
  (define original-error-port (current-error-port))
  
  (define primitive-eval (current-eval))
  (define primitive-load (current-load))
  
  (define system-custodian (current-custodian))
  (define system-eventspace (current-eventspace))
  (define system-thread (current-thread))
  (define system-namespace (current-namespace))
  (define first-dir (current-directory))
  
  (define error-display-eventspace (make-eventspace))
  
  (define original-error-display-handler (error-display-handler))
  
  (define error-display-handler-message-box-title
    (make-parameter (string-constant drscheme-internal-error)))
  
  ;; override error-display-handler to duplicate the error
  ;; message in both the standard place (as defined by the
  ;; current error-display-handler) and in a message box
  ;; identifying the error as a drscheme internal error.
  (error-display-handler
   (λ (msg exn)
     
     ;; this  may raise an exception if the port is gone.
     (with-handlers ([exn:fail? (λ (x) (void))])
       (original-error-display-handler msg exn))
     
     (let ([title (error-display-handler-message-box-title)])
       (let ([text (let ([p (open-output-string)])
                     (parameterize ([current-error-port p]
                                    [current-output-port p])
                       (original-error-display-handler msg exn))
                     (get-output-string p))])
         
         (parameterize ([current-custodian system-custodian])
           (parameterize ([current-eventspace error-display-eventspace])
             (message-box title text #f '(stop ok))))))))