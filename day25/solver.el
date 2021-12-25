;; Solution for AOC 2021, day 25

;; Idea: Use regexp-replace to replace s/.>/>. and go char by char for east-moving
;; sea cucumbers, transpose for south cucumbers

(defun aoc-transpose ()
  "Transpose sea cucumbers in current buffer"
  (interactive)
  (let* ((cucumbers
          (mapcar 'string-to-list (split-string (buffer-string) "\n")))
         (transposed-cucumbers
          (mapcar
           (lambda (n)
             (apply 'string
                    (seq-filter 'identity
                            (mapcar
                             (lambda (line)
                               (let ((c (nth n line)))
                                 (cond
                                  ((equal c ?v) ?>)
                                  ((equal c ?>) ?v)
                                  (t c))))
                             cucumbers))))
           (number-sequence 0 (- (length (car cucumbers)) 1)))))
    (erase-buffer)
    (insert (string-join transposed-cucumbers "\n"))))

(defun aoc-move-east-herd ()
  "Move east-facing heard"
  (interactive)
  (save-excursion
    ;; This pads the map left and right so that it simulates the
    ;; wrapping at the edges; the padding has to be deleted
    ;; afterwards.
    (goto-char (point-min))
    (while (< (point) (point-max))
      (let ((first-char
             (progn
               (beginning-of-line)
               (char-after (point))))
            (last-char
             (progn
               (end-of-line)
               (char-before (point)))))
        (beginning-of-line)
        (insert last-char)
        (end-of-line)
        (insert first-char))
      (forward-line))
    ;; The actual 'movement' happens here through replacement
    (goto-char (point-min))
    (while (re-search-forward ">\\." nil t)
      (replace-match ".>"))
    ;; And now we remove the padding
    (goto-char (point-min))
    (while (< (point) (point-max))
      (beginning-of-line)
      (delete-char 1)
      (end-of-line)
      (delete-char -1)
      (forward-line))))

(defun aoc-move-south-heard ()
  "Move south-facing herd"
  (interactive)
  ;; The idea is to transpose the map, insert it into a temporary
  ;; buffer, apply aoc-move-east-heard, and then transpose back again
  (aoc-transpose)
  (aoc-move-east-herd)
  (aoc-transpose))

(defun aoc-sea-cucumbers-step ()
  "A step in the simulation"
  (interactive)
  (aoc-move-east-herd)
  (aoc-move-south-heard))

(defun aoc-day25-part1-buffer ()
  (interactive)
  (buffer-disable-undo)
  (setq-local steps 0)
  (setq-local last-contents "")
  (while (not (string= (buffer-string) last-contents))
    (setq-local last-contents (buffer-string))
    (aoc-sea-cucumbers-step)
    (setq-local steps (+ steps 1)))
  (message "The solution to part 1 is: %d steps" steps))

(defun aoc-solve-on-file (filepath solver)
  (with-current-buffer (generate-new-buffer "sea-cucumbers")
    (insert-file-contents filepath)
    (funcall solver)))

(defun aoc-day25-part1 (filepath)
  (interactive "fFile name: ")
  (aoc-solve-on-file filepath 'aoc-day25-part1-buffer))
