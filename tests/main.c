#include "libasm.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

void test_strlen(void)
{
    printf("\n=== Testing ft_strlen ===\n");
    printf("ft_strlen(\"Hello\") = %zu (expected: 5)\n", ft_strlen("Hello"));
    printf("ft_strlen(\"\") = %zu (expected: 0)\n", ft_strlen(""));
    printf("ft_strlen(\"Hello, libasm!\") = %zu (expected: 14)\n", ft_strlen("Hello, libasm!"));
}

void test_strcpy(void)
{
    printf("\n=== Testing ft_strcpy ===\n");
    char dst1[100];
    char dst2[100];
    printf("ft_strcpy(dst, \"Hello\") = \"%s\"\n", ft_strcpy(dst1, "Hello"));
    printf("ft_strcpy(dst, \"\") = \"%s\"\n", ft_strcpy(dst2, ""));
}

void test_strcmp(void)
{
    printf("\n=== Testing ft_strcmp ===\n");
    printf("ft_strcmp(\"abc\", \"abc\") = %d (expected: 0)\n", ft_strcmp("abc", "abc"));
    printf("ft_strcmp(\"abc\", \"abd\") = %d (expected: < 0)\n", ft_strcmp("abc", "abd"));
    printf("ft_strcmp(\"abd\", \"abc\") = %d (expected: > 0)\n", ft_strcmp("abd", "abc"));
    printf("ft_strcmp(\"\", \"\") = %d (expected: 0)\n", ft_strcmp("", ""));
}

void test_write(void)
{
    printf("\n=== Testing ft_write ===\n");
    ssize_t ret = ft_write(1, "Test write: ", 12);
    printf(" (returned: %zd)\n", ret);
    ret = ft_write(1, "OK\n", 3);
    printf("ft_write returned: %zd\n", ret);
}

void test_read(void)
{
    printf("\n=== Testing ft_read ===\n");
    char buf[10] = {0};
    ssize_t ret = ft_read(0, buf, 0);
    printf("ft_read(STDIN, buf, 0) = %zd (expected: 0)\n", ret);
}

void test_strdup(void)
{
    printf("\n=== Testing ft_strdup ===\n");
    char *dup1 = ft_strdup("Hello");
    printf("ft_strdup(\"Hello\") = \"%s\"\n", dup1);
    free(dup1);
    
    char *dup2 = ft_strdup("");
    printf("ft_strdup(\"\") = \"%s\" (len: %zu)\n", dup2, ft_strlen(dup2));
    free(dup2);
    
    char *dup3 = ft_strdup("copy");
    printf("ft_strdup(\"copy\") = \"%s\"\n", dup3);
    free(dup3);
}

void test_atoi_base(void)
{
    printf("\n=== Testing ft_atoi_base ===\n");
    printf("ft_atoi_base(\"1010\", \"01\") = %d (expected: 10)\n", ft_atoi_base("1010", "01"));
    printf("ft_atoi_base(\"FF\", \"0123456789ABCDEF\") = %d (expected: 255)\n", ft_atoi_base("FF", "0123456789ABCDEF"));
    printf("ft_atoi_base(\"-42\", \"0123456789\") = %d (expected: -42)\n", ft_atoi_base("-42", "0123456789"));
    printf("ft_atoi_base(\"+123\", \"0123456789\") = %d (expected: 123)\n", ft_atoi_base("+123", "0123456789"));
    printf("ft_atoi_base(\"  42\", \"0123456789\") = %d (expected: 42)\n", ft_atoi_base("  42", "0123456789"));
    printf("ft_atoi_base(\"invalid\", \"01\") = %d (expected: 0)\n", ft_atoi_base("invalid", "01"));
    printf("ft_atoi_base(\"42\", \"\") = %d (expected: 0)\n", ft_atoi_base("42", ""));
    printf("ft_atoi_base(\"42\", \"0\") = %d (expected: 0)\n", ft_atoi_base("42", "0"));
}

int cmp_str(void *a, void *b)
{
    return ft_strcmp((char *)a, (char *)b);
}

void test_list_push_front(void)
{
    printf("\n=== Testing ft_list_push_front ===\n");
    t_list *list = NULL;
    
    ft_list_push_front(&list, "third");
    ft_list_push_front(&list, "second");
    ft_list_push_front(&list, "first");
    
    printf("List after push_front: ");
    t_list *tmp = list;
    int count = 0;
    while (tmp)
    {
        if (count > 0) printf(" -> ");
        printf("\"%s\"", (char *)tmp->data);
        tmp = tmp->next;
        count++;
    }
    printf(" (expected: \"first\" -> \"second\" -> \"third\")\n");
    
    // Cleanup
    while (list)
    {
        t_list *next = list->next;
        free(list);
        list = next;
    }
}

void test_list_size(void)
{
    printf("\n=== Testing ft_list_size ===\n");
    t_list *list = NULL;
    
    printf("ft_list_size(NULL) = %d (expected: 0)\n", ft_list_size(list));
    
    ft_list_push_front(&list, "third");
    printf("ft_list_size(list) = %d (expected: 1)\n", ft_list_size(list));
    
    ft_list_push_front(&list, "second");
    printf("ft_list_size(list) = %d (expected: 2)\n", ft_list_size(list));
    
    ft_list_push_front(&list, "first");
    printf("ft_list_size(list) = %d (expected: 3)\n", ft_list_size(list));
    
    // Cleanup
    while (list)
    {
        t_list *next = list->next;
        free(list);
        list = next;
    }
}

void test_list_sort(void)
{
    printf("\n=== Testing ft_list_sort ===\n");
    t_list *list = NULL;
    
    ft_list_push_front(&list, "zebra");
    ft_list_push_front(&list, "apple");
    ft_list_push_front(&list, "banana");
    
    printf("Before sort: ");
    t_list *tmp = list;
    while (tmp)
    {
        printf("\"%s\" ", (char *)tmp->data);
        tmp = tmp->next;
    }
    printf("\n");
    
    ft_list_sort(&list, cmp_str);
    
    printf("After sort: ");
    tmp = list;
    while (tmp)
    {
        printf("\"%s\" ", (char *)tmp->data);
        tmp = tmp->next;
    }
    printf("(expected: \"apple\" \"banana\" \"zebra\")\n");
    
    // Cleanup
    while (list)
    {
        t_list *next = list->next;
        free(list);
        list = next;
    }
}

void free_str(void *data)
{
    // Data is string literal, no need to free
    (void)data;
}

int cmp_remove(void *a, void *b)
{
    return ft_strcmp((char *)a, (char *)b);
}

void test_list_remove_if(void)
{
    printf("\n=== Testing ft_list_remove_if ===\n");
    t_list *list = NULL;
    
    ft_list_push_front(&list, "keep3");
    ft_list_push_front(&list, "remove");
    ft_list_push_front(&list, "keep2");
    ft_list_push_front(&list, "remove");
    ft_list_push_front(&list, "keep1");
    
    printf("Before remove_if: ");
    t_list *tmp = list;
    while (tmp)
    {
        printf("\"%s\" ", (char *)tmp->data);
        tmp = tmp->next;
    }
    printf("\n");
    
    ft_list_remove_if(&list, "remove", cmp_remove, free_str);
    
    printf("After remove_if: ");
    tmp = list;
    while (tmp)
    {
        printf("\"%s\" ", (char *)tmp->data);
        tmp = tmp->next;
    }
    printf("(expected: \"keep1\" \"keep2\" \"keep3\")\n");
    
    // Cleanup
    while (list)
    {
        t_list *next = list->next;
        free(list);
        list = next;
    }
}

int main(void)
{
    printf("=== Libasm Test Suite ===\n");
    
    test_strlen();
    test_strcpy();
    test_strcmp();
    test_write();
    test_read();
    test_strdup();
    
    printf("\n=== Bonus Tests ===\n");
    test_atoi_base();
    test_list_push_front();
    test_list_size();
    test_list_sort();
    test_list_remove_if();
    
    printf("\n=== All tests completed ===\n");
    return 0;
}
