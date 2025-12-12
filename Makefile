NAME        := libasm.a
SRC_DIR     := src
OBJ_DIR     := build
MANDATORY   := ft_strlen.s ft_strcpy.s ft_strcmp.s ft_write.s ft_read.s ft_strdup.s
BONUS       := ft_atoi_base_bonus.s ft_list_push_front_bonus.s ft_list_size_bonus.s ft_list_sort_bonus.s ft_list_remove_if_bonus.s
SRCS        := \
    \
$(addprefix $(SRC_DIR)/,$(MANDATORY))
BONUS_SRCS  := $(addprefix $(SRC_DIR)/,$(BONUS))
OBJS        := $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(SRCS))
BONUS_OBJS  := $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(BONUS_SRCS))
NASM        := nasm
NASMFLAGS   := -f macho64 -Wall -Werror -w-reloc-rel-dword
AR          := ar
ARFLAGS     := rcs
INCLUDES    := -I include
TEST_BIN    := tests/test_libasm
TEST_SRC    := tests/main.c
CC          := cc
CFLAGS      := -Wall -Wextra -Werror $(INCLUDES)

all: $(NAME)

$(NAME): $(OBJ_DIR) $(OBJS)
	$(AR) $(ARFLAGS) $@ $(OBJS)

bonus: $(OBJ_DIR) $(OBJS) $(BONUS_OBJS)
	$(AR) $(ARFLAGS) $(NAME) $(OBJS) $(BONUS_OBJS)

$(OBJ_DIR):
	@mkdir -p $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $(INCLUDES) -o $@ $<

$(TEST_BIN): $(NAME) $(TEST_SRC)
	$(CC) $(CFLAGS) $(TEST_SRC) $(NAME) -o $@

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME) $(TEST_BIN)

re: fclean all

.PHONY: all bonus clean fclean re
