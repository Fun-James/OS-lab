#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>

/*
 * RR_init initializes the run-queue rq with correct assignment for
 * member variables, including:
 *
 *   - run_list: should be an empty list after initialization.
 *   - proc_num: set to 0
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_init(struct run_queue *rq)
{
    // LAB6: 2313447
    // 初始化运行队列
    list_init(&(rq->run_list));  // 初始化运行队列链表为空
    rq->proc_num = 0;            // 初始化进程数量为 0
}

/*
 * RR_enqueue inserts the process ``proc'' into the tail of run-queue
 * ``rq''. The procedure should verify/initialize the relevant members
 * of ``proc'', and then put the ``run_link'' node into the queue.
 * The procedure should also update the meta data in ``rq'' structure.
 *
 * proc->time_slice denotes the time slices allocation for the
 * process, which should set to rq->max_time_slice.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 2313447
    assert(list_empty(&(proc->run_link)));  // 确保进程不在任何队列中
    
    // 将进程插入到运行队列的尾部
    list_add_before(&(rq->run_list), &(proc->run_link));
    
    // 如果进程的时间片已用完或超过最大时间片，重置为最大时间片
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    
    // 设置进程所属的运行队列
    proc->rq = rq;
    
    // 更新运行队列中的进程数量
    rq->proc_num++;
}

/*
 * RR_dequeue removes the process ``proc'' from the front of run-queue
 * ``rq'', the operation would be finished by the list_del_init operation.
 * Remember to update the ``rq'' structure.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 2313447
    assert(!list_empty(&(proc->run_link)));  // 确保进程在队列中
    
    // 从运行队列中删除该进程
    list_del_init(&(proc->run_link));
    
    // 更新运行队列中的进程数量
    rq->proc_num--;
}

/*
 * RR_pick_next picks the element from the front of ``run-queue'',
 * and returns the corresponding process pointer. The process pointer
 * would be calculated by macro le2proc, see kern/process/proc.h
 * for definition. Return NULL if there is no process in the queue.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    // LAB6: 2313447
    // 获取运行队列的第一个元素（队首）
    list_entry_t *le = list_next(&(rq->run_list));
    
    // 如果队列为空，返回 NULL
    if (le != &(rq->run_list)) {
        // 使用 le2proc 宏将链表节点转换为进程控制块指针
        return le2proc(le, run_link);
    }
    return NULL;
}

/*
 * RR_proc_tick works with the tick event of current process. You
 * should check whether the time slices for current process is
 * exhausted and update the proc struct ``proc''. proc->time_slice
 * denotes the time slices left for current process. proc->need_resched
 * is the flag variable for process switching.
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 2313447
    // 如果进程的时间片大于 0，减少时间片
    if (proc->time_slice > 0) {
        proc->time_slice--;
    }
    
    // 如果时间片用完，设置需要调度标志
    if (proc->time_slice == 0) {
        proc->need_resched = 1;
    }
}

struct sched_class default_sched_class = {
    .name = "RR_scheduler",
    .init = RR_init,
    .enqueue = RR_enqueue,
    .dequeue = RR_dequeue,
    .pick_next = RR_pick_next,
    .proc_tick = RR_proc_tick,
};
