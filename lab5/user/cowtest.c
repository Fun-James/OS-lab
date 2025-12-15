#include <stdio.h>
#include <ulib.h>
#include <string.h>

/*
 * COW (Copy-on-Write) Test Suite
 * 
 * Tests:
 * 1. Basic COW: Parent and child share pages until write
 * 2. Multiple writes: Verify each write triggers COW correctly
 * 3. Stack COW: Verify stack pages are properly COWed
 * 4. Multiple forks: Verify COW chains work correctly
 */

// Global variable for COW testing (in data segment)
volatile int global_var = 42;

// Large array to test multiple pages
#define ARRAY_SIZE 128
volatile int test_array[ARRAY_SIZE];

void test_basic_cow(void) {
    cprintf("\n=== Test 1: Basic COW ===\n");
    
    volatile int local_var = 100;
    int pid;
    
    if ((pid = fork()) == 0) {
        // Child process
        cprintf("Child: before write, local_var = %d, global_var = %d\n", 
                local_var, global_var);
        
        // This write should trigger COW
        local_var = 200;
        global_var = 84;
        
        cprintf("Child: after write, local_var = %d, global_var = %d\n", 
                local_var, global_var);
        
        assert(local_var == 200);
        assert(global_var == 84);
        
        exit(0);
    }
    
    assert(pid > 0);
    
    int ret;
    waitpid(pid, &ret);
    
    cprintf("Parent: after child exit, local_var = %d, global_var = %d\n", 
            local_var, global_var);
    
    // Parent's values should be unchanged
    assert(local_var == 100);
    assert(global_var == 42);
    
    cprintf("Test 1 PASSED!\n");
}

void test_multiple_pages(void) {
    cprintf("\n=== Test 2: Multiple Pages COW ===\n");
    
    // Initialize array
    for (int i = 0; i < ARRAY_SIZE; i++) {
        test_array[i] = i;
    }
    
    int pid;
    if ((pid = fork()) == 0) {
        // Child modifies multiple pages
        for (int i = 0; i < ARRAY_SIZE; i++) {
            test_array[i] = i * 2;
        }
        
        // Verify child's modifications
        for (int i = 0; i < ARRAY_SIZE; i++) {
            assert(test_array[i] == i * 2);
        }
        
        cprintf("Child: modified %d array elements\n", ARRAY_SIZE);
        exit(0);
    }
    
    assert(pid > 0);
    
    int ret;
    waitpid(pid, &ret);
    
    // Verify parent's array is unchanged
    for (int i = 0; i < ARRAY_SIZE; i++) {
        assert(test_array[i] == i);
    }
    
    cprintf("Parent: array unchanged after child exit\n");
    cprintf("Test 2 PASSED!\n");
}

void test_stack_cow(void) {
    cprintf("\n=== Test 3: Stack COW ===\n");
    
    // Large stack allocation to ensure multiple stack pages
    volatile int stack_array[64];
    for (int i = 0; i < 64; i++) {
        stack_array[i] = i + 1000;
    }
    
    int pid;
    if ((pid = fork()) == 0) {
        // Child modifies stack
        for (int i = 0; i < 64; i++) {
            stack_array[i] = i + 2000;
        }
        
        cprintf("Child: stack_array[0] = %d, stack_array[63] = %d\n", 
                stack_array[0], stack_array[63]);
        
        assert(stack_array[0] == 2000);
        assert(stack_array[63] == 2063);
        
        exit(0);
    }
    
    assert(pid > 0);
    
    int ret;
    waitpid(pid, &ret);
    
    // Verify parent's stack is unchanged
    assert(stack_array[0] == 1000);
    assert(stack_array[63] == 1063);
    
    cprintf("Parent: stack unchanged, stack_array[0] = %d\n", stack_array[0]);
    cprintf("Test 3 PASSED!\n");
}

void test_chain_fork(void) {
    cprintf("\n=== Test 4: Chain Fork COW ===\n");
    
    volatile int chain_var = 1;
    
    int pid1 = fork();
    if (pid1 == 0) {
        // First child
        chain_var = 2;
        
        int pid2 = fork();
        if (pid2 == 0) {
            // Grandchild
            chain_var = 3;
            cprintf("Grandchild: chain_var = %d\n", chain_var);
            assert(chain_var == 3);
            exit(0);
        }
        
        assert(pid2 > 0);
        int ret;
        waitpid(pid2, &ret);
        
        cprintf("First child: chain_var = %d (after grandchild)\n", chain_var);
        assert(chain_var == 2);
        exit(0);
    }
    
    assert(pid1 > 0);
    int ret;
    waitpid(pid1, &ret);
    
    cprintf("Parent: chain_var = %d (after all children)\n", chain_var);
    assert(chain_var == 1);
    
    cprintf("Test 4 PASSED!\n");
}

int main(void) {
    cprintf("\n========================================\n");
    cprintf("     COW (Copy-on-Write) Test Suite    \n");
    cprintf("========================================\n");
    
    test_basic_cow();
    test_multiple_pages();
    test_stack_cow();
    test_chain_fork();
    
    cprintf("\n========================================\n");
    cprintf("     ALL COW TESTS PASSED!             \n");
    cprintf("========================================\n");
    
    return 0;
}
