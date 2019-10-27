/*
 * original function
 */
SYSCALL_DEFINE0(hello)
{
  printk(KERN_INFO "[hello from kernel]\"%s\"\n");
  return 0;
}
