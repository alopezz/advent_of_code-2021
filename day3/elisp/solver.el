;; Solution for AOC 2021, day 3
;; After loading this file, the solver functions become available
;; for interactive use. The interactive functions show the result
;; in a temprary buffer.
;; The functions are:
;; - aoc-day-3: Asks for an input file which to calculate the solutions
;; - aoc-day-3-buffer: Asks for a buffer to be used as input

;; General idea of the approach:
;; The idea of this solution is to use Emacs buffers as a way to manipulate
;; the data as much as possible.
;; For the first part, this is only used to isolate the columns in the input.
;; For the second part, the idea was to delete the lines that don't fulfill
;; the criteria on every iteration. This became the most messy part and one
;; that may be worth reviewing.

(defun aoc-solve-on-file (filepath solver)
  (with-temp-buffer
    (insert-file-contents filepath)
    (funcall solver (current-buffer))))

(defun get-column-contents (column buffer)
  "Gets the contents of a buffer column as a string"
  (with-current-buffer buffer
    (save-excursion
      (goto-char (point-min))
      (forward-char column)
      (push-mark)
      (goto-char (point-max))
      (beginning-of-line)
      (forward-char column)
      (let ((rectangle-contents (extract-rectangle (mark) (+ (point) 1))))
        (pop-mark)
        rectangle-contents))))

(defun most-common-bit-value (lst)
  "Finds the most common bit value.
Returns nil if both bits are equally common."
  (let* ((number-of-ones (seq-count (lambda (x) (string= x "1")) lst))
         (number-of-zeros (- (length lst) number-of-ones)))
    (cond
     ((> number-of-ones number-of-zeros) "1")
     ((< number-of-ones number-of-zeros) "0"))))

(defun least-common-bit-value (lst)
  "The opposite of most-common-bit-value."
  (let ((x (most-common-bit-value lst)))
    (cond
     ((string= x "1") "0")
     ((string= x "0") "1"))))

(defun apply-on-buffer-columns (fun buffer)
  "Iterate over all the columns in buffer, applying fun on its
contents."
  (with-current-buffer buffer
    (let ((n-columns
           (save-excursion
             (goto-char (point-min))
             (end-of-line)
             (point))))
      (apply
       'concat
       (mapcar (lambda (idx)
                 (funcall fun (get-column-contents idx buffer)))
               (number-sequence 0 (- n-columns 2)))))))

(defun rate-to-integer (binary-rate)
  (string-to-number binary-rate 2))

(defun get-gamma-rate (buffer)
  "Calculate gamma rate from a buffer."
  (rate-to-integer (apply-on-buffer-columns 'most-common-bit-value buffer)))

(defun get-epsilon-rate (buffer)
  "Calculate epsilon rate from a buffer."
  (rate-to-integer (apply-on-buffer-columns 'least-common-bit-value buffer)))

(defun aoc-solve-part1-buffer (buffer)
  "Solve AoC day3 part 1 on buffer."
  (* (get-gamma-rate buffer)
     (get-epsilon-rate buffer)))

(defun aoc-solve-part1 (filepath)
  (aoc-solve-on-file filepath 'aoc-solve-part1-buffer))

(defun number-of-lines ()
  (count-lines (point-min) (point-max)))

(defun apply-until-one-left (fun buffer)
  (with-temp-buffer
    (insert-buffer-substring buffer)
    (let ((n-columns
           (save-excursion
             (goto-char (point-min))
             (end-of-line)
             (point))))
      (dotimes (idx (- n-columns 1))
        (unless (<= (number-of-lines) 1)
          (let ((winning-bit (funcall fun (get-column-contents idx (current-buffer)))))
            (goto-char (point-min))
            (beginning-of-line)
            (forward-char idx)
            (push-mark)
            (while (< (line-number-at-pos (pop-mark)) (line-number-at-pos (point-max)))
              (push-mark)
              (if (equal (char-to-string (char-after)) winning-bit)
                  (forward-line)
                (kill-whole-line))
              (forward-char idx))
            ;; Clean up last line if necessary
            (while (and (char-after)
                        (not (equal (char-to-string (char-after)) winning-bit)))
              (kill-whole-line) (backward-delete-char 1)
              (beginning-of-line) (forward-char idx))))))
    (buffer-string)))

(defun get-oxygen-rating (buffer)
  "Get oxygen generator rating from a buffer."
  (rate-to-integer
   (apply-until-one-left
    (lambda (x)
      (let ((b (most-common-bit-value x)))
        (or b "1")))
    buffer)))

(defun get-co2-rating (buffer)
  "Get CO2 scrubber rating from a buffer"
  (rate-to-integer
   (apply-until-one-left
    (lambda (x)
      (let ((b (least-common-bit-value x)))
        (or b "0")))
    buffer)))

(defun aoc-solve-part2-buffer (buffer)
  "Solve AoC day3 part 2 on buffer."
  (* (get-oxygen-rating buffer)
     (get-co2-rating buffer)))

(defun aoc-solve-part2 (filepath)
  (aoc-solve-on-file filepath 'aoc-solve-part2-buffer))

(defun aoc-day-3-print-solutions (solution-1 solution-2)
  (with-output-to-temp-buffer "Aoc-day3"
    (princ "Welcome to AoC day 3!\n")
    (princ "=====================\n\n")
    (princ
     (format "The solution for part 1 is %d.\nThe solution for part 2 is %d.\n"
             solution-part-1 solution-part-2))))

(defun aoc-day-3-buffer (buffer)
  "Solve AoC day 3 puzzle on buffer and display results in a
temporary buffer."
  (interactive "BInput buffer: ")
  (let ((solution-part-1 (aoc-solve-part1-buffer buffer))
        (solution-part-2 (aoc-solve-part2-buffer buffer)))
    (aoc-day-3-print-solutions solution-part-1 solution-part-2)))

(defun aoc-day-3 (filepath)
  "Solve AoC day 3 puzzle on file and display results in a
temporary buffer."
  (interactive "fInput file: ")
  (let ((solution-part-1 (aoc-solve-part1 filepath))
        (solution-part-2 (aoc-solve-part2 filepath)))
    (aoc-day-3-print-solutions solution-part-1 solution-part-2)))
