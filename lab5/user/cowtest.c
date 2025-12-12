#include <stdio.h>
#include <ulib.h>
#include <string.h>

int global_var = 0;

int main(void) {
    cprintf("COW Test Start\n");
    int pid = fork();
    if (pid == 0) {
        // Child
        cprintf("Child: global_var = %d\n", global_var);
        global_var = 100;
        cprintf("Child: global_var changed to %d\n", global_var);
        exit(0);
    }
    
    // Parent
    cprintf("Parent: global_var = %d\n", global_var);
    global_var = 200;
    cprintf("Parent: global_var changed to %d\n", global_var);
    
    waitpid(pid, NULL);
    cprintf("Parent: child exited.\n");
    cprintf("Parent: global_var is %d (should be 200)\n", global_var);
    
    if (global_var == 200) {
        cprintf("COW Test Passed!\n");
    } else {
        cprintf("COW Test Failed!\n");
    }
    return 0;
}
