;; Solution for AOC 2021, day 4

;; The overall approach for part 1 is to pick up the numbers from the
;; first row one by one and using a regexp search-and-replace to mark
;; those numbers directly in the buffer for all boards.
;; Then it's a matter of applying that several times until we get a
;; winning board.

(defvar bingo-marker " X")

(defun bingo-mark-number (number &optional buffer)
  "Mark a number on a bingo-board.
Assumes every board postion occupies two characters."
  (interactive "nInsert number to mark: ")
  (let ((buffer (or buffer (current-buffer))))
    (with-current-buffer buffer
      (replace-regexp (format "%2d\\b" number) bingo-marker))))

(defun bingo-play-next (&optional buffer)
  "Play the next turn in a game of Bingo.
Sets the buffer-local last-bingo-number variable."
  (interactive)
  (let ((buffer (or buffer (current-buffer))))
    (with-current-buffer buffer
      (save-excursion
        ;; Go to the start of the buffer, extract the first word as a
        ;; number, and pass it to bingo-mark-number to mark matching numbers.
        (goto-char (point-min))
        (forward-word)
        ;; We check if the forward-word movement has actually caused
        ;; movement and it hasn't jumped lines to consider the number valid
        (if (and
             (not (= (point) (point-min)))
             (= (line-number-at-pos (point)) (line-number-at-pos (point-min))))
            (atomic-change-group
              (let* ((next-input (delete-and-extract-region (point-min) (point)))
                     (number (string-to-number (string-trim next-input ","))))
                (bingo-mark-number number buffer)
                (setq-local last-bingo-number number)))
          ;; Signal that no numbers are left with a special -1 value
          (setq-local last-bingo-number -1))))))

(defun get-boards (buffer)
  ;; We get the boards by their double-line separation after skipping
  ;; the first two lines
  (with-current-buffer buffer
    (save-excursion
      (goto-char (point-min))
      (forward-line)
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
    (let ((winning-regexp (format "\\( *%s\\)\\{5\\}" bingo-marker)))
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
   (split-string (replace-regexp-in-string "[^ \n[:digit:]]" "" board))))

(defun bingo-board-score-with-last-number (board number)
  (* number (apply '+ (numbers-in-board board))))

(defun bingo-board-score (board)
  (bingo-board-score-with-last-number board last-bingo-number))

(defun bingo-last-board-score ()
  (bingo-board-score-with-last-number last-winning-board last-winning-bingo-number))

(defun bingo-remove-board-from-buffer (board &optional buffer)
  "Find and remove board from buffer"
  (with-current-buffer (or buffer (current-buffer))
    (save-excursion
      (goto-char (point-min))
      (replace-string winning-board ""))))

(defun check-bingo-boards-buffer (buffer)
  "Check if any board is winning and return that board."
  (seq-find 'check-bingo-board (get-boards buffer)))

(defun aoc-bingo-play-buffer (buffer)
  "Play the whole game until a board wins."
  (with-current-buffer buffer
    (setq-local last-bingo-number nil)
    (while (and
            (not (check-bingo-boards-buffer buffer))
            (not (equal last-bingo-number -1)))
      (bingo-play-next buffer))
    (check-bingo-boards-buffer buffer)))

(defun aoc-day4-part1-buffer (buffer)
  (let ((winning-board (aoc-bingo-play-buffer buffer)))
    (with-current-buffer buffer
      (when winning-board
        (bingo-board-score winning-board)))))

(defun aoc-day4-part2-buffer (buffer)
  (with-current-buffer buffer
    (setq-local last-bingo-number nil)
    (while
        (not (equal last-bingo-number -1))
      (let ((winning-board (aoc-bingo-play-buffer buffer)))
        (when winning-board
          (setq-local last-winning-bingo-number last-bingo-number)
          (setq-local last-winning-board winning-board)
          (bingo-remove-board-from-buffer winning-board))))
    (bingo-last-board-score)))

(defun aoc-solve-on-file (filepath solver)
  (with-temp-buffer
    (insert-file-contents filepath)
    (funcall solver (current-buffer))))

(defun aoc-day4-part1 (filepath)
  (aoc-solve-on-file filepath 'aoc-day4-part1-buffer))

(defun aoc-day4-part2 (filepath)
  (aoc-solve-on-file filepath 'aoc-day4-part2-buffer))
