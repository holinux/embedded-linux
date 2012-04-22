#include <common.h>
#include <command.h>
#include <image.h>
#include <malloc.h>
#include <zlib.h>
#include <bzlib.h>
#include <environment.h>
#include <asm/byteorder.h>
#include <config.h>

#define	GPBCON		(*(volatile unsigned long *)0x56000010) //控制LED灯输入/输出寄存器地址
#define	GPBDAT		(*(volatile unsigned long *)0x56000014) //控制LED亮灭寄存器地址
#define LEDS   (1<<5|1<<6|1<<7|1<<8)  //LED全灭

#if (CONFIG_COMMANDS & CFG_CMD_LED)
int do_led (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
	GPBCON	 = 0x00015400;
	if(strcmp(argv[2],"0")==0){
		if(strcmp(argv[1],"1")==0)
			GPBDAT=GPBDAT | (1<<5);
		else if(strcmp(argv[1],"2")==0)
					GPBDAT=GPBDAT | (1<<6);
		else if(strcmp(argv[1],"3")==0)
					GPBDAT=GPBDAT | (1<<7);
		else if(strcmp(argv[1],"4")==0)
					GPBDAT=GPBDAT | (1<<8);
			else{
				printf("Usage :\nled arg1[1-4] arg2[0-1]    --control LEDs\n");	
				return -1;
			}
		}
		else if(strcmp(argv[2],"1")==0){
			if(strcmp(argv[1],"1")==0)
				GPBDAT=GPBDAT & (~(1<<5));
			else if(strcmp(argv[1],"2")==0)
						GPBDAT=GPBDAT & (~(1<<6));
			else if(strcmp(argv[1],"3")==0)
						GPBDAT=GPBDAT & (~(1<<7));
			else if(strcmp(argv[1],"4")==0)
						GPBDAT=GPBDAT & (~(1<<8));
				else{
					printf("Usage :\nled arg1[1-4] arg2[0-1]    --control LEDs\n");	
					return -1;
				}
		}
		else{
			printf("Usage :\nled arg1[1-4] arg2[0-1]    --control LEDs\n");	
			return -1;
			}
		
	return 1;
}

U_BOOT_CMD(
 	led,	CFG_MAXARGS,	1,	do_led,
 	"led     - control LEDs\n",
 	"led arg1[1-4] arg2[0-1]\n    arg1--the number of LED\n"
 	"    arg2--LED on or off\n"
);
#endif /* (CONFIG_COMMANDS & CFG_CMD_LED) */