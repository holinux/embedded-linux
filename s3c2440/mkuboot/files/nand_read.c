
/* NAND FLASH (see S3C2440 manual chapter 6) */
#define NFCONF              (*(volatile unsigned long *)0x4E000000)
#define NFCONT              (*(volatile unsigned long *)0x4E000004)
#define NFCMMD              (*(volatile unsigned char *)0x4E000008) // 这里不能写成long,切记！
#define NFADDR              (*(volatile unsigned char *)0x4E00000C)
#define NFDATA              (*(volatile unsigned char *)0x4E000010)
#define NFSTAT              (*(volatile unsigned char *)0x4E000020)

/* 供外部调用的函数 */
void nand_initial(void);
void nand_read(unsigned char *buf, unsigned long start_addr, int size);

/* S3C2440的NAND Flash操作函数 */

/* 等待NAND Flash就绪 */
static void s3c2440_wait_idle(void)
{
    int i;
    while(!(NFSTAT & 1))
        for(i=0; i<10; i++);
}

/* 发出地址 */
static void s3c2440_write_addr(unsigned int addr)
{
    int i;
    NFADDR = addr & 0xff;        //写入最低8位
    for(i=0; i<10; i++);         //延时
    NFADDR = (addr >> 9) & 0xff; //写入第二个8位
    for(i=0; i<10; i++);         //延时
    NFADDR = (addr >> 17) & 0xff;//写入第三个8位
    for(i=0; i<10; i++);         //延时
    NFADDR = (addr >> 25) & 0xff;//写入第四个8位
    for(i=0; i<10; i++);         //延时
}

/* 初始化NAND Flash */
void nand_initial(void)
{
    //时间参数设为:TACLS=0 TWRPH0=3 TWRPH1=0
    NFCONF = 0x300;
    /* 使能NAND Flash控制器, 初始化ECC, 禁止片选 */
    NFCONT = (1<<4)|(1<<1)|(1<<0);
    
    /* 复位NAND Flash */
    NFCONT &= ~(1<<1);  //发出片选信号
    NFCMMD = 0xFF;      //复位命令
    s3c2440_wait_idle();//循环查询NFSTAT位0，直到它等于1
    NFCONT |= 0x2;      //取消片选信号
}


#define NAND_SECTOR_SIZE    512
#define NAND_BLOCK_MASK     (NAND_SECTOR_SIZE - 1)

/* 读函数 */
void nand_read(unsigned char *buf, unsigned long start_addr, int size)
{
    int i, j;
    
    if ((start_addr & NAND_BLOCK_MASK) || (size & NAND_BLOCK_MASK)) {
        return ;    /* 地址或长度不对齐 */
    }

    NFCONT &= ~(1<<1);  //发出片选信号

    for(i=start_addr; i < (start_addr + size);)
    {
        NFCMMD = 0; //发出READ0命令
        s3c2440_write_addr(i);  //Write Address
        s3c2440_wait_idle();    //循环查询NFSTAT位0，直到它等于1
        for(j=0; j < NAND_SECTOR_SIZE; j++, i++)
        {
            *buf = (unsigned char)NFDATA;
            buf++;
        }
    }

    NFCONT |= 0x2;      //取消片选信号
        
    return ;
}

