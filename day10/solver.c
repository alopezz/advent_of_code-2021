#include <stdlib.h>
#include <stdio.h>
#include <string.h>


typedef struct {
  void** contents;
  int capacity;
  int index;
  int item_size;
} Stack;

Stack new_stack(int capacity, unsigned int size) {
  Stack new_stack;
  new_stack.item_size = size;

  new_stack.contents = calloc(capacity, sizeof(void*));
  if (new_stack.contents == NULL) {
    new_stack.index = -1;
    new_stack.capacity = -1;
    return new_stack;
  }

  new_stack.index = 0;
  new_stack.capacity = capacity;
  return new_stack;
}

void destroy_stack(Stack stack) {
  for (int idx=0; idx < stack.index; idx++) {
    free(stack.contents[idx]);
  }
  free(stack.contents);
}

void* stack_pop(Stack* stack) {
  if (stack->index <= 0 || stack->index >= stack->capacity) {
    return 0;
  }
  stack->index--;
  return stack->contents[stack->index];
}

void* stack_peek(Stack stack) {
  if (stack.index <= 0 || stack.index >= stack.capacity) {
    return 0;
  }
  return stack.contents[stack.index - 1];
}

int stack_push(Stack* stack, void* elt) {
  // Resize capacity when index is about to go over it. For simplicity,
  // the idea is to resize it in an amount equal to the initial capacity.
  if (stack->index >= stack->capacity) {
    int new_size = (stack->capacity + stack->index);
    stack->contents = realloc(stack->contents, new_size * sizeof(void*));
    if (stack->contents == NULL) {
      return 0;
    }
    stack->capacity = new_size;
  }

  void* new_ptr = calloc(1, stack->item_size);

  if (new_ptr == NULL) return 0;

  memcpy(new_ptr, elt, stack->item_size);
  stack->contents[stack->index] = new_ptr;
  stack->index++;

  return 1;
}

int is_opening_char(char c) {
  return (c == '(' || c == '{' || c == '[' || c == '<');
}

int is_closing_pair(char a, char b) {
  return (a == '(' && b == ')')
    || (a == '[' && b == ']')
    || (a == '{' && b == '}')
    || (a == '<' && b == '>');
}

int score_illegal(char c) {
  switch (c) {
  case ')':
    return 3;
  case ']':
    return 57;
  case '}':
    return 1197;
  case '>':
    return 25137;
  }
  return 0;
}

int score_for_completing(char c) {
  switch (c) {
  case '(':
    return 1;
  case '[':
    return 2;
  case '{':
    return 3;
  case '<':
    return 4;
  }
  return 0;
}

unsigned long score_completion(Stack* stack) {
  unsigned long score = 0;
  while (stack_peek(*stack) != 0) {
    score *= 5;
    score += score_for_completing(*(char*) stack_pop(stack));
  }
  return score;
}

typedef struct {
  int part1;
  unsigned long part2;
} Score;

Score score_line(char* line) {
  Stack stack = new_stack(64, sizeof(char));
  Score score = {0, 0};

  for (int idx = 0;; idx++) {
    char c = line[idx];

    /* Reaching the end of the line means we try to complete */
    if (c == '\n' || c == 0) {
      score.part2 = score_completion(&stack);
      break;
    }

    /* Character matching logic */
    if (is_opening_char(c)) {
      stack_push(&stack, &c);
    } else if (is_closing_pair(*(char*) stack_peek(stack), c)) {
      stack_pop(&stack);
    } else {
      score.part1 += score_illegal(c);
      break;
    }
  }
  destroy_stack(stack);

  return score;
}

int compare(const void* a, const void* b) {
  unsigned long arg1 = **(const unsigned long**)a;
  unsigned long arg2 = **(const unsigned long**)b;
 
  if (arg1 < arg2) return -1;
  if (arg1 > arg2) return 1;
  return 0;
}

unsigned long winner_score(Stack* scores) {
  qsort(scores->contents, scores->index, scores->item_size, compare);
  return *(unsigned long*) scores->contents[scores->index/2];
}

int main() {
  int score1 = 0;
  Stack score2_list = new_stack(32, sizeof(unsigned long));

  char buffer[256];
  while (fgets(buffer, sizeof buffer, stdin) != NULL) {
    Score new_score = score_line(buffer);
    score1 += new_score.part1;
    if (new_score.part2 > 0) {
      stack_push(&score2_list, &new_score.part2);
    }
  }
  printf("Score (part 1) is %d!\n", score1);
  printf("Score (part 2) is %lu!\n", winner_score(&score2_list));

  destroy_stack(score2_list);

  return 0;
}
