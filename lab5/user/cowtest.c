#include <stdio.h>
#include <ulib.h>
#include <string.h>

const int max_iter = 10;

int main(void) {
    int pid, ret;
    cprintf("COW test start\n");

    // Allocate a shared variable
    // In ucore, global variables are in data segment, which is private (COW).
    static volatile int shared_var = 100;

    if ((pid = fork()) == 0) {
        // Child
        cprintf("Child: shared_var = %d\n", shared_var);
        assert(shared_var == 100);

        cprintf("Child: modifying shared_var to 200\n");
        shared_var = 200;
        cprintf("Child: shared_var = %d\n", shared_var);
        assert(shared_var == 200);

        exit(0);
    }

    assert(pid > 0);
    // Parent
    // Wait for child to modify
    if (waitpid(pid, &ret) == 0) {
        cprintf("Parent: child exited.\n");
    }

    cprintf("Parent: shared_var = %d\n", shared_var);
    assert(shared_var == 100);

    cprintf("COW test passed!\n");
    return 0;
}
