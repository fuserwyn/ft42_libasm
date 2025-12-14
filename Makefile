NAME        := libasm.a
SRC_DIR     := src
BONUS_DIR   := src/bonus
OBJ_DIR     := build
MANDATORY   := ft_strlen.s ft_strcpy.s ft_strcmp.s ft_write.s ft_read.s ft_strdup.s
BONUS       := ft_atoi_base_bonus.s ft_list_push_front_bonus.s ft_list_size_bonus.s ft_list_sort_bonus.s ft_list_remove_if_bonus.s
SRCS        := \
    \
$(addprefix $(SRC_DIR)/,$(MANDATORY))
BONUS_SRCS  := $(addprefix $(BONUS_DIR)/,$(BONUS))
OBJS        := $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(SRCS))
BONUS_OBJS  := $(patsubst $(BONUS_DIR)/%.s,$(OBJ_DIR)/%.o,$(BONUS_SRCS))
NASM        := nasm
UNAME_S     := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    NASMFLAGS   := -f elf64 -Wall -Werror
else
    NASMFLAGS   := -f macho64 -Wall -Werror -w-reloc-rel-dword
endif
AR          := ar
ARFLAGS     := rcs
RANLIB      := ranlib
INCLUDES    := -I include
TEST_BIN    := tests/test_libasm
TEST_SRC    := tests/main.c
CC          := cc
CFLAGS      := -Wall -Wextra -Werror $(INCLUDES)
ifeq ($(UNAME_S),Darwin)
    CFLAGS  += -arch x86_64
endif

all: $(NAME)

$(NAME): $(OBJ_DIR) $(OBJS)
	@rm -f $@
	$(AR) $(ARFLAGS) $@ $(OBJS)
ifeq ($(UNAME_S),Linux)
	@$(AR) s $@ 2>/dev/null || $(RANLIB) $@
else
	@$(RANLIB) $@
endif

bonus: $(OBJ_DIR) $(OBJS) $(BONUS_OBJS)
	@rm -f $(NAME)
	$(AR) $(ARFLAGS) $(NAME) $(OBJS) $(BONUS_OBJS)
ifeq ($(UNAME_S),Linux)
	@$(AR) s $(NAME) 2>/dev/null || $(RANLIB) $(NAME)
else
	@$(RANLIB) $(NAME)
endif

$(OBJ_DIR):
	@mkdir -p $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $(INCLUDES) -o $@ $<

$(OBJ_DIR)/%.o: $(BONUS_DIR)/%.s | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $(INCLUDES) -o $@ $<

$(TEST_BIN): $(NAME) $(TEST_SRC)
	$(CC) $(CFLAGS) $(TEST_SRC) $(NAME) -o $@

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME) $(TEST_BIN)

re: fclean all

test: bonus $(TEST_BIN)
	@./$(TEST_BIN)

.PHONY: all bonus clean fclean re test
