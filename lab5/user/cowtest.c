#include <stdio.h>
#include <ulib.h>
#include <string.h>

/*
 * ============================================
 *   COW (Copy-on-Write) 功能测试
 * ============================================
 */

// 全局变量（数据段）
volatile int global_var = 42;

// 大数组测试多页面 COW
#define ARRAY_SIZE 128
volatile int test_array[ARRAY_SIZE];

/* Test 1: 基本 COW 测试 */
void test_basic_cow(void) {
    cprintf("\n=== Test 1: Basic COW ===\n");
    
    volatile int local_var = 100;
    int pid;
    
    if ((pid = fork()) == 0) {
        // Child
        cprintf("[Child] Before: local=%d, global=%d\n", local_var, global_var);
        local_var = 200;
        global_var = 84;
        cprintf("[Child] After: local=%d, global=%d\n", local_var, global_var);
        
        assert(local_var == 200);
        assert(global_var == 84);
        exit(0);
    }
    
    assert(pid > 0);
    int ret;
    waitpid(pid, &ret);
    
    cprintf("[Parent] After child: local=%d, global=%d\n", local_var, global_var);
    assert(local_var == 100);
    assert(global_var == 42);
    
    cprintf("Test 1 PASSED!\n");
}

/* Test 2: 多页面 COW 测试 */
void test_multiple_pages(void) {
    cprintf("\n=== Test 2: Multiple Pages COW ===\n");
    
    for (int i = 0; i < ARRAY_SIZE; i++) {
        test_array[i] = i;
    }
    
    int pid;
    if ((pid = fork()) == 0) {
        for (int i = 0; i < ARRAY_SIZE; i++) {
            test_array[i] = i * 2;
        }
        for (int i = 0; i < ARRAY_SIZE; i++) {
            assert(test_array[i] == i * 2);
        }
        cprintf("[Child] Array modified correctly\n");
        exit(0);
    }
    
    assert(pid > 0);
    int ret;
    waitpid(pid, &ret);
    
    for (int i = 0; i < ARRAY_SIZE; i++) {
        assert(test_array[i] == i);
    }
    cprintf("[Parent] Array unchanged\n");
    cprintf("Test 2 PASSED!\n");
}

/* Test 3: 栈 COW 测试 */
void test_stack_cow(void) {
    cprintf("\n=== Test 3: Stack COW ===\n");
    
    volatile int stack_array[64];
    for (int i = 0; i < 64; i++) {
        stack_array[i] = i + 1000;
    }
    
    int pid;
    if ((pid = fork()) == 0) {
        for (int i = 0; i < 64; i++) {
            stack_array[i] = i + 2000;
        }
        assert(stack_array[0] == 2000);
        assert(stack_array[63] == 2063);
        cprintf("[Child] Stack modified: [0]=%d\n", stack_array[0]);
        exit(0);
    }
    
    assert(pid > 0);
    int ret;
    waitpid(pid, &ret);
    
    assert(stack_array[0] == 1000);
    assert(stack_array[63] == 1063);
    cprintf("[Parent] Stack unchanged: [0]=%d\n", stack_array[0]);
    cprintf("Test 3 PASSED!\n");
}

/* Test 4: 链式 Fork COW 测试 */
void test_chain_fork(void) {
    cprintf("\n=== Test 4: Chain Fork COW ===\n");
    
    volatile int chain_var = 1;
    
    int pid1 = fork();
    if (pid1 == 0) {
        chain_var = 2;
        int pid2 = fork();
        if (pid2 == 0) {
            chain_var = 3;
            cprintf("[Grandchild] chain_var=%d\n", chain_var);
            assert(chain_var == 3);
            exit(0);
        }
        assert(pid2 > 0);
        int ret;
        waitpid(pid2, &ret);
        cprintf("[Child] chain_var=%d\n", chain_var);
        assert(chain_var == 2);
        exit(0);
    }
    
    assert(pid1 > 0);
    int ret;
    waitpid(pid1, &ret);
    
    cprintf("[Parent] chain_var=%d\n", chain_var);
    assert(chain_var == 1);
    cprintf("Test 4 PASSED!\n");
}

int main(void) {
    cprintf("\n========================================\n");
    cprintf("   COW (Copy-on-Write) Test Suite\n");
    cprintf("========================================\n");
    
    test_basic_cow();
    test_multiple_pages();
    test_stack_cow();
    test_chain_fork();
    
    cprintf("\n========================================\n");
    cprintf("   ALL COW TESTS PASSED!\n");
    cprintf("========================================\n");
    
    return 0;
}
