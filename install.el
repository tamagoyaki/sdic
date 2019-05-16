;; -*- Emacs-Lisp -*-
;; $Id: install.el.in,v 1.8 2002/07/02 11:17:46 tsuchiya Exp $

;; Author: TSUCHIYA Masatoshi <tsuchiya@namazu.org>
;; Keywords: dictionary

;; This file is part of SDIC.

;; SDIC is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; SDIC is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with SDIC; if not, write to the Free Software Foundation,
;; Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


;;; Commentary:

;; ���Υե�����ϡ�GENE�������¼���Ȥ��ƻȤ���EDICT������±Ѽ����
;; ���ƻȤ�����������Ԥʤ� Emacs-Lisp �ץ������Ǥ������ Windows 
;; �Ķ������Ѥ��뤳�Ȥ����ꤷ�Ƥ��ޤ���UNIX �Ķ��ǥ��󥹥ȡ����Ԥʤ�
;; ���ϡ����̤� configure �� make ��ȤäƲ�������
;;
;; (1) GENE����Υǡ��� gene95.lzh �ޤ��� gene95.tar.gz ��Ÿ�����ơ�
;;     gene.txt �򤳤Υե������Ʊ���ǥ��쥯�ȥ���֤��Ʋ�������
;;
;; (2) EDICT����Υǡ��� edict.gz ��Ÿ�����ơ�edict �򤳤Υե������Ʊ
;;     ���ǥ��쥯�ȥ���֤��Ʋ�������
;;
;; (3) �ʲ��Υ��ޥ�ɤ�¹Ԥ��Ʋ�������
;;
;;         meadow -batch -q -no-site-file -l install.el -f make-sdic
;;
;;     ����ȡ��¹Ԥ��줿 meadow �δĶ�����Ŭ�ڤʥ��󥹥ȡ���������
;;     ���ơ����󥹥ȡ����¹Ԥ��ޤ������󥹥ȡ�������ѹ����������
;;     �ϡ����ץ����ǻ��ꤷ�Ƥ���������
;;
;;         --infodir=DIR              Info �򥤥󥹥ȡ��뤹��ǥ��쥯�ȥ�����
;;         --with-lispdir=DIR         Lisp �ץ������򥤥󥹥ȡ��뤹��ǥ��쥯�ȥ�����
;;         --with-dictdir=DIR         ����򥤥󥹥ȡ��뤹��ǥ��쥯�ȥ�����
;;         --with-multidict=(yes|no)  ʣ������θ��Ф�Ԥ����� yes (�ǥե���Ȥ� no)
;;
;; (4) �ʲ�������� .emacs ���դ��ä��Ʋ�������
;;
;;         (setq load-path (cons (expand-file-name "../../site-lisp/sdic" data-directory) load-path))
;;         (autoload 'sdic "sdic" "��ñ��ΰ�̣��Ĵ�٤�" t nil)
;;         (global-set-key "\C-cw" 'sdic)
;;
;;     �����Х���ɤ�Ŭ�����ѹ����Ʋ�������Meadow-1.03 �ʹߤʤɤǤϡ�
;;     load-path �ˤĤ��Ƥ�������פ�ʤ������Τ�ޤ���


;;; Code:

;; Emacs-20 �ʾ�ξ���ɬ�פ����ܸ�Ķ�������
(and (boundp 'emacs-major-version)
     (>= emacs-major-version 20)
     (fboundp 'set-language-environment)
     (set-language-environment "Japanese"))


;; ���󥹥ȡ���������

(defvar make-sdic-lisp-directory
  ;; Mule-for-Windows �� Meadow �Ǥϥǥ��쥯�ȥ깽�����ۤʤ�
  (if (fboundp 'mule-for-win32-version)
      (expand-file-name "../site-lisp/sdic" data-directory)
    (expand-file-name "../../site-lisp/sdic" data-directory))
  "Lisp program �򥤥󥹥ȡ��뤹��ǥ��쥯�ȥ�")

(defvar make-sdic-info-directory (and (require 'info) (car Info-directory-list))
  "Info �򥤥󥹥ȡ��뤹��ǥ��쥯�ȥ�")

(defvar make-sdic-dict-directory make-sdic-lisp-directory
  "����򥤥󥹥ȡ��뤹��ǥ��쥯�ȥ�")

(defvar make-sdic-gene-coding-system (if (>= emacs-major-version 20) 'sjis-dos *autoconv*)
  "���ۤ���Ƥ���GENE����δ���������")

(defvar make-sdic-edict-coding-system (if (>= emacs-major-version 20) 'euc-japan-unix *autoconv*)
  "���ۤ���Ƥ���EDICT����δ���������")


;; �ѥå������Υǥ��쥯�ȥ깽¤���ѿ�������

(defvar make-sdic-version "2.1.3")

(defvar make-sdic-root-directory (expand-file-name default-directory)
  "�ѥå������Υȥåץǥ��쥯�ȥ�")

(defvar make-sdic-src-directory (expand-file-name "lisp" make-sdic-root-directory)
  "Lisp program ����Ǽ����Ƥ���ǥ��쥯�ȥ�")

(defvar make-sdic-texi-directory (expand-file-name "texi" make-sdic-root-directory)
  "Info �Υ���������Ǽ����Ƥ���ǥ��쥯�ȥ�")

(defvar make-sdic-eiwa-candidates
  '("gene.sdic" "ejdict.sdic" "eedict.sdic" "eijirou.sdic"
    "gene.dic" "ejdict.dic" "eedict.dic" "eijirou.dic"
    "e4jwords.sdic" "ecompdic.sdic" "eenamdict.sdic"
    "e4jwords.dic" "ecompdic.dic" "eenamdict.dic")
  "���󥹥ȡ���Ѥα��¼���򸡺���������оݤȤʤ�ե�����̾�Υꥹ��")

(defvar make-sdic-waei-candidates
  '("edict.sdic" "jedict.sdic" "jgene.sdic" "waeijirou.sdic"
    "jedict.dic" "jgene.dic" "waeijirou.dic"
    "j4jwords.sdic" "jcompdic.sdic" "jenamdict.sdic"
    "j4jwords.dic" "jcompdic.dic" "jenamdict.dic")
  "���󥹥ȡ���Ѥ��±Ѽ���򸡺���������оݤȤʤ�ե�����̾�Υꥹ��")

(defvar make-sdic-detect-multi-dictionary nil
  "ʣ������򸡽Ф������ t �ˤ���")

(defvar make-sdic-debug nil)


;; load-path ������
(mapcar (lambda (dir)
	  (or (member dir load-path)
	      (setq load-path (cons dir load-path))))
	(list make-sdic-root-directory
	      make-sdic-src-directory))


(setq sdic-eiwa-dictionary-list nil
      sdic-waei-dictionary-list nil)
(load "sdic.el.in")
(require 'sdicf)
(require 'texinfmt)


;;; ������������

(defun make-sdic ()
  (defvar command-line-args-left)	;Avoid 'free variable' warning
  (if (not noninteractive)
      (error "`make-sdic' is to be used only with -batch"))
  (while command-line-args-left
    (cond
     ((string= "-n" (car command-line-args-left))
      (setq make-sdic-debug t))
     ((string= "-?" (car command-line-args-left))
      (make-sdic-help))
     ((string-match "^--with-lispdir=" (car command-line-args-left))
      (setq make-sdic-lisp-directory (substring (car command-line-args-left) (match-end 0))))
     ((string-match "^--infodir=" (car command-line-args-left))
      (setq make-sdic-info-directory (substring (car command-line-args-left) (match-end 0))))
     ((string-match "^--with-dictdir=" (car command-line-args-left))
      (setq make-sdic-dict-directory (substring (car command-line-args-left) (match-end 0))))
     ((string-match "^--with-multidict=\\(yes\\|no\\)" (car command-line-args-left))
      (setq make-sdic-detect-multi-dictionary (string= "yes" (substring (car command-line-args-left) -3))))
     (t (make-sdic-help "Illegal option")))
    (setq command-line-args-left (cdr command-line-args-left)))
  ;; ���󥹥ȡ�����Υǥ��쥯�ȥ����
  (or make-sdic-debug
      (mapcar (lambda (dir)
		(or (file-directory-p dir)
		    (progn
		      (message "Make directory: %s" dir)
		      (make-directory dir))))
	      (list make-sdic-lisp-directory
		    make-sdic-info-directory
		    make-sdic-dict-directory)))
  ;; ���󥹥ȡ���Ѥμ��񤬤��뤫Ĵ�٤�
  (let ((eiwa (or (delq nil (mapcar (lambda (basename)
				      (and (file-exists-p (expand-file-name basename make-sdic-dict-directory))
					   basename))
				    make-sdic-eiwa-candidates))
		  (file-exists-p "gene.txt")))
	(waei (or (delq nil (mapcar (lambda (basename)
				      (and (file-exists-p (expand-file-name basename make-sdic-dict-directory))
					   basename))
				    make-sdic-waei-candidates))
		  (file-exists-p "edict"))))
    ;; ���󥹥ȡ���Ѥμ��񤫤��ʣ���Ƥ����Τ������
    (or (eq eiwa t)
	(eq eiwa nil)
	(setq eiwa (delq t (mapcar (lambda (basename)
				     (if (string-match "\\.dic" basename)
					 (if (member (concat (substring basename 0 -3) "sdic") eiwa) t basename)
				       basename))
				   eiwa))))
    (or (eq waei t)
	(eq waei nil)
	(setq waei (delq t (mapcar (lambda (basename)
				     (if (string-match "\\.dic" basename)
					 (if (member (concat (substring basename 0 -3) "sdic") waei) t basename)
				       basename))
				   waei))))
    ;; --with-multidict=no �ξ��ϡ��ǽ�˸��Ĥ��ä�����Τߤ����Ѥ���
    (or make-sdic-detect-multi-dictionary
	(progn
	  (or (eq eiwa t)
	      (eq eiwa nil)
	      (setq eiwa (list (car eiwa))))
	  (or (eq waei t)
	      (eq waei nil)
	      (setq waei (list (car waei))))))
    (make-sdic-sdic_el (if (eq eiwa t) (list "gene.sdic") eiwa) (if (eq waei t) (list "jedict.sdic") waei))
    (make-sdic-install-lisp)
    (make-sdic-install-info)
    (if (eq eiwa t) (make-sdic-install-gene))
    (if (eq waei t) (make-sdic-install-jedict))
    (make-sdic-sample_emacs)
    ))


(defun make-sdic-help (&optional msg)
  "�إ�ץ�å���������Ϥ��Ƥ��Τޤ޽�λ����ؿ�"
  (error "%s\
Usage: emacs -batch -q -no-site-file -l install.el -f make-sdic [options]
Options:
Action:
  -?  Print this message.
  -n  Print files thath would be created and installed, but do not install them.

Direcotry:
  --infodir=DIR           info documentation in DIR [guessed]
  --with-lispdir=DIR      emacs lisp files go to DIR [guessed]
  --with-dictdir=DIR      dictionary files go to DIR [guessed]
  --with-multidict=(ARG)  use multiple dictionaries (yes|no) [no]
"
	 (if msg (concat msg "\n") "")))


(defun make-sdic-sample_emacs ()
  "sample.emacs.in ���� sample.emacs ����������ؿ�"
  (let ((in-file (expand-file-name "sample.emacs.in" make-sdic-src-directory))
	(out-file (expand-file-name "sample.emacs" make-sdic-src-directory)))
    (if make-sdic-debug
	(message "%s" out-file)
      (message "%s -> %s" in-file out-file)
      (or (file-readable-p in-file) (error "Can't find file : %s" in-file))
      (let ((buf (generate-new-buffer "*sample.emacs*")))
	(unwind-protect
	    (progn
	      (set-buffer buf)
	      (sdicf-insert-file-contents in-file sdic-default-coding-system)
	      (goto-char (point-min))
	      (search-forward (concat "@" "lispdir" "@"))
	      (delete-region (goto-char (match-beginning 0)) (match-end 0))
	      (insert make-sdic-lisp-directory)
	      (make-sdic-write-file out-file))
	  (kill-buffer buf))))))


(defun make-sdic-sdic_el (eiwa waei)
  "sdic.el.in ���� sdic.el ����������ؿ�"
  (let ((in-file (expand-file-name "sdic.el.in" make-sdic-src-directory))
	(out-file (expand-file-name "sdic.el" make-sdic-src-directory)))
    (if make-sdic-debug
	(message "%s" (expand-file-name "sdic.el" make-sdic-lisp-directory))
      (message "%s -> %s" in-file out-file)
      (or (file-readable-p in-file) (error "Can't find file : %s" in-file))
      (let ((buf (generate-new-buffer "*sdic.el*")))
	(unwind-protect
	    (progn
	      (set-buffer buf)
	      (sdicf-insert-file-contents in-file sdic-default-coding-system)
	      (goto-char (point-min))
	      (search-forward (concat "@" "VERSION" "@"))
	      (delete-region (goto-char (match-beginning 0)) (match-end 0))
	      (insert make-sdic-version)
	      (if (listp eiwa)
		  (progn
		    (goto-char (point-min))
		    (search-forward (concat "@" "EIWA_DICT_LIST" "@"))
		    (delete-region (goto-char (match-beginning 0)) (match-end 0))
		    (insert
		     (mapconcat (lambda (s) s)
				(mapcar (lambda (basename)
					  (format "\"%s\"" (expand-file-name basename make-sdic-dict-directory)))
					eiwa)
				" "))))
	      (if (listp waei)
		  (progn
		    (goto-char (point-min))
		    (search-forward (concat "@" "WAEI_DICT_LIST" "@"))
		    (delete-region (goto-char (match-beginning 0)) (match-end 0))
		    (insert
		     (mapconcat (lambda (s) s)
				(mapcar (lambda (basename)
					  (format "\"%s\"" (expand-file-name basename make-sdic-dict-directory)))
					waei)
				" "))))
	      (make-sdic-write-file out-file))
	  (kill-buffer buf))))))


(defun make-sdic-install-lisp ()
  "���ƤΥե������Х��ȥ���ѥ��뤷�ƥ��󥹥ȡ��뤹��ؿ�"
  (mapcar (lambda (basename)
	    (let ((in-file (expand-file-name basename make-sdic-src-directory))
		  (out-file (expand-file-name basename make-sdic-lisp-directory)))
	      (if make-sdic-debug
		  (message "%s" out-file)
		(message "%s -> %s" in-file out-file)
		(byte-compile-file in-file)
		(copy-file in-file out-file t t)
		(copy-file (concat in-file "c") (concat out-file "c") t t))))
	  (directory-files make-sdic-src-directory nil "^\\(sdic.*\\|stem\\)\\.el$")))


(defun make-sdic-install-info ()
  "Info ��������ƥ��󥹥ȡ��뤹��ؿ�"
  (let ((in-file (expand-file-name "sdic.texi" make-sdic-texi-directory))
	(out-file (expand-file-name "sdic.info" make-sdic-texi-directory))
	(copy-file (expand-file-name "sdic.info" make-sdic-info-directory)))
    (if make-sdic-debug
	(message "%s" copy-file)
      (message "%s -> %s -> %s" in-file out-file copy-file)
      (or (file-readable-p in-file) (error "Can't find file : %s" in-file))
      (let ((buf (generate-new-buffer "*sdic.texi*")))
	(unwind-protect
	    (progn
	      (set-buffer buf)
	      (insert-file-contents in-file)
	      (texinfo-format-buffer)
	      (write-file out-file))
	  (kill-buffer buf)))
      (copy-file out-file copy-file t t))))


(defun make-sdic-install-gene ()
  "GENE�����SDIC�������Ѵ����ƥ��󥹥ȡ��뤹��ؿ�"
  (let* ((in-file (expand-file-name "gene.txt" make-sdic-root-directory))
	 (out-file (expand-file-name "gene.sdic" make-sdic-root-directory))
	 (copy-file (expand-file-name "gene.sdic" make-sdic-dict-directory)))
    (if make-sdic-debug
	(message "%s" copy-file)
      (message "%s -> %s -> %s" in-file out-file copy-file)
      (or (file-readable-p in-file) (error "Can't find file : %s" in-file))
      (make-sdic-gene in-file out-file)
      (copy-file out-file copy-file t t))))


(defun make-sdic-install-jedict ()
  "EDICT�����SDIC�������Ѵ����ƥ��󥹥ȡ��뤹��ؿ�"
  (let* ((in-file (expand-file-name "edict" make-sdic-root-directory))
	 (out-file (expand-file-name "jedict.sdic" make-sdic-root-directory))
	 (copy-file (expand-file-name "jedict.sdic" make-sdic-dict-directory)))
    (if make-sdic-debug
	(message "%s" copy-file)
      (message "%s -> %s -> %s" in-file out-file copy-file)
      (or (file-readable-p in-file) (error "Can't find file : %s" in-file))
      (make-sdic-jedict in-file out-file)
      (copy-file out-file copy-file t t))))


(defun make-sdic-write-file (output-file)
  (let ((buffer-file-coding-system sdic-default-coding-system)
	(file-coding-system sdic-default-coding-system))
    (message "Writing %s..." output-file)
    (write-region (point-min) (point-max) output-file)))


(defun make-sdic-gene (input-file &optional output-file)
  "GENE�����SDIC�������Ѵ�����"
  (interactive "fInput dictionary file name: ")
  (or output-file
      (setq output-file (concat (if (string-match "\\.[^\\.]+$" input-file)
				    (substring input-file 0 (match-beginning 0))
				  input-file)
				".sdic")))
  (let ((buf (generate-new-buffer "*gene*")))
    (unwind-protect
	(save-excursion
	  (set-buffer buf)
	  (message "Reading %s..." input-file)
	  (sdicf-insert-file-contents input-file make-sdic-gene-coding-system)
	  (message "Converting %s..." input-file)
	  ;; �ǽ��2�Ԥϥ����Ȥ����顢��Ƭ�� # ����������
	  (goto-char (point-min))
	  (insert "# ")
	  (forward-line)
	  (beginning-of-line)
	  (insert "# ")
	  (forward-line)
	  (beginning-of-line)
	  (save-restriction
	    (narrow-to-region (point) (point-max))
	    (make-sdic-escape-region (point-min) (point-max))
	    (let (head list key top)
	      (while (progn
		       (setq top (point))
		       (end-of-line)
		       (delete-region (point) (progn (skip-chars-backward "[ \t\f\r]") (point)))
		       (setq head (buffer-substring top (point))
			     key (make-sdic-replace-string (downcase head) "\\s-+" " "))
		       (if (string-match " +\\+[0-9]+$" key)
			   (setq key (substring key 0 (match-beginning 0))))
		       (beginning-of-line)
		       (if (string= head key)
			   (progn
			     (insert "<K>")
			     (end-of-line)
			     (insert "</K>"))
			 (insert "<H>")
			 (end-of-line)
			 (insert "</H><K>" key "</K>"))
		       (delete-char 1)
		       (end-of-line)
		       (forward-char)
		       (not (eobp)))))
	    (message "Sorting %s..." input-file)
	    (sort-lines nil (point-min) (point-max)))
	  (make-sdic-write-file output-file))
      (kill-buffer buf))))


(defun make-sdic-jedict (input-file &optional output-file)
  "EDICT�����SDIC�������Ѵ�����"
  (interactive "fInput dictionary file name: ")
  (or output-file
      (setq output-file (concat (if (string-match "\\.[^\\.]+$" input-file)
				    (substring input-file 0 (match-beginning 0))
				  input-file)
				".sdic")))
  (let ((buf (generate-new-buffer "*jedict*")))
    (unwind-protect
	(save-excursion
	  (set-buffer buf)
	  (message "Reading %s..." input-file)
	  (sdicf-insert-file-contents input-file make-sdic-edict-coding-system)
	  (message "Converting %s..." input-file)
	  ;; �ǽ��1�Ԥϥ����Ȥ����顢��Ƭ�� # ����������
	  (delete-region (goto-char (point-min)) (progn (forward-char 4) (point)))
	  (insert "# ")
	  (forward-line)
	  (beginning-of-line)
	  (save-restriction
	    (narrow-to-region (point) (point-max))
	    (make-sdic-escape-region (point-min) (point-max))
	    (while (progn
		     (insert "<K>")
		     (looking-at "\\cj+")
		     (goto-char (match-end 0))
		     (insert "</K>")
		     (delete-char 1)
		     (if (looking-at "\\[\\(\\cj+\\)\\] +")
			 (let ((key (buffer-substring (match-beginning 1) (match-end 1))))
			   (delete-region (match-beginning 0) (match-end 0))
			   (insert "<K>" key "<K>")))
		     (delete-char 1)
		     (end-of-line)
		     (backward-char)
		     (delete-char 1)
		     (forward-char)
		     (not (eobp))))
	    (message "Sorting %s..." input-file)
	    (sort-lines nil (point-min) (point-max)))
	  (make-sdic-write-file output-file))
      (kill-buffer buf))))


(defun make-sdic-replace-string (string from to) "\
ʸ���� STRING �˴ޤޤ�Ƥ���ʸ���� FROM ������ʸ���� TO ���ִ�����ʸ������֤�
FROM �ˤ�����ɽ����ޤ�ʸ��������Ǥ��뤬��TO �ϸ���ʸ���󤷤������
���ʤ��Τǡ����դ��ƻȤ����ȡ�"
  (let ((start 0) list)
    (while (string-match from string start)
      (setq list (cons to (cons (substring string start (match-beginning 0)) list))
	    start (match-end 0)))
    (eval (cons 'concat (nreverse (cons (substring string start) list))))))


(defun make-sdic-escape-string (str &optional escape-lf)
  "STR �˴ޤޤ�Ƥ����ü�ʸ���򥨥������פ���"
  (save-match-data
    (setq str (make-sdic-replace-string str "&" "&amp;"))
    (if escape-lf
	(setq str (make-sdic-replace-string str "\n" "&lf;")))
    (setq str (make-sdic-replace-string str "<" "&lt;"))
    (make-sdic-replace-string str ">" "&gt;")))


(defun make-sdic-escape-region (start end &optional escape-lf)
  "�꡼�����˴ޤޤ�Ƥ����ü�ʸ���򥨥������פ���"
  (save-excursion
    (save-match-data
      (save-restriction
	(narrow-to-region start end)
	(goto-char (point-min))
	(while (search-forward "&" nil t)
	  (replace-match "&amp;" t t))
	(goto-char (point-min))
	(while (search-forward "<" nil t)
	  (replace-match "&lt;" t t))
	(goto-char (point-min))
	(while (search-forward ">" nil t)
	  (replace-match "&gt;" t t))
	(if escape-lf
	    (progn
	      (goto-char (point-min))
	      (while (search-forward "\n" nil t)
		(replace-match "&lf;" t t))))
	))))