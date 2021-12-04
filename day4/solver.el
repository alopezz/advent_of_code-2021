;; Solution for AOC 2021, day 4

;; The overall approach for part 1 is to pick up the numbers from the
;; first row one by one and using a regexp search-and-replace to mark
;; those numbers directly in the buffer for all boards.
;; Then it's a matter of applying that several times until we get a
;; winning board.

(defun make-bingo-marker (&optional marker)
  (format "%2s" (or marker "X")))

(defun bingo-mark-number (number &optional buffer marker)
  "Mark a number on a bingo-board.
Assumes every board postion occupies two characters."
  (interactive "nInsert number to mark: ") 
  (let ((buffer (or buffer (current-buffer)))
        (marker (make-bingo-marker marker)))
    (with-current-buffer buffer
      (replace-regexp (format "%2d\\b" number) marker))))

(defun bingo-play-next (&optional buffer marker)
  "Play the next turn in a game of Bingo.
Sets the buffer-local last-bingo-number variable."
  (interactive)
  (let ((buffer (or buffer (current-buffer)))
        (marker (make-bingo-marker marker)))
    (with-current-buffer buffer
      (save-excursion
        ;; Go to the start of the buffer, extract the first word as a
        ;; number, and pass it to bingo-mark-number to mark matching numbers.
        (goto-char (point-min))
        (forward-word)
        (atomic-change-group
          (let* ((next-input (delete-and-extract-region (point-min) (point)))
                 (number (string-to-number (string-trim next-input ","))))
            (bingo-mark-number number buffer marker)
            (setq-local last-bingo-number number)))))))

(defun get-boards (buffer)
  ;; We get the boards by their double-line separation after skipping
  ;; the first two lines
  (with-current-buffer buffer
    (save-excursion
      (goto-char (point-min))
      (forward-line 2)
      (split-string (buffer-substring (point) (point-max)) "\n\\{2,\\}"))))

(defun transpose-bingo-board ()
  "Transposes bingo board on current buffer in-place."
  (let* ((board (buffer-string))
         (board-lines (split-string board "\n")))
    (erase-buffer)
    (dotimes (n 5)
      (insert
       (string-join
        (mapcar
         (lambda (line)
           (format "%2s" (nth n (split-string line))))
         board-lines)
        " "))
      (newline))))

(defun check-bingo-board (board)
  "Check if a board is winning"
  (with-temp-buffer
    (insert board)
    (let ((winning-regexp "\\( +X\\)\\{5\\}"))
      (goto-char (point-min))
      (or
       (re-search-forward winning-regexp nil t)
       (progn
         (transpose-bingo-board)
         (goto-char (point-min))
         (re-search-forward winning-regexp nil t))))))

(defun numbers-in-board (board)
  (mapcar
   'string-to-number
   (split-string (replace-regexp-in-string "[X\\n]" "" board))))

(defun check-bingo-boards-buffer (buffer)
  "Check if any board is winning and return that board."
  (seq-find 'check-bingo-board (get-boards buffer)))

(defun aoc-bingo-play-buffer (buffer)
  "Play the whole game until a board wins."
  (while (not (check-bingo-boards-buffer buffer))
    (bingo-play-next buffer))
  (check-bingo-boards-buffer buffer))

(defun aoc-day4-part1-buffer (buffer)
  (let ((winning-board (aoc-bingo-play-buffer buffer)))
    (with-current-buffer buffer
      (* last-bingo-number (apply '+ (numbers-in-board winning-board))))))
