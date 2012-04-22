/*
 * (C) Copyright 2006 OpenMoko, Inc.
 * Author: Harald Welte <laforge@openmoko.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <common.h>

#if 0
#define DEBUGN	printf
#else
#define DEBUGN(x, args ...) {}
#endif

#if defined(CONFIG_CMD_NAND)
#if !defined(CONFIG_NAND_LEGACY)

#include <nand.h>
#include <s3c2410.h>
#include <asm/io.h>


#define S3C2440_NFCONF   (*(volatile unsigned int *)(0x4E000000))
#define S3C2440_NFCONT   (*(volatile unsigned int *)(0x4E000004))
#define S3C2440_NFCMD    (*(volatile unsigned short *)(0x4E000008))
#define S3C2440_NFADDR   (*(volatile unsigned short *)(0x4E00000C))
#define S3C2440_NFDATA   (*(volatile unsigned int *)(0x4E000010))
#define S3C2440_NFECCD0  (*(volatile unsigned int *)(0x4E000014))
#define S3C2440_NFECCD1  (*(volatile unsigned int *)(0x4E000018))
#define S3C2440_NFECCD   (*(volatile unsigned int *)(0x4E00001C))
#define S3C2440_NFSTAT   (*(volatile unsigned char *)(0x4E000020))
#define S3C2440_NFESTAT0 (*(volatile unsigned int *)(0x4E000024))
#define S3C2440_NFESTAT1 (*(volatile unsigned int *)(0x4E000028))
#define S3C2440_NFMECC0  (*(volatile unsigned int *)(0x4E00002C))
#define S3C2440_NFMECC1  (*(volatile unsigned int *)(0x4E000030))
#define S3C2440_NFSECC   (*(volatile unsigned int *)(0x4E000034))
#define S3C2440_NFSBLK   (*(volatile unsigned int *)(0x4E000038))
#define S3C2440_NFEBLK   (*(volatile unsigned int *)(0x4E00003C))

#define S3C2440_NFCONF_BUSWIDTH_8       (0<<0)
#define S3C2440_NFCONF_BUSWIDTH_16      (1<<0)
#define S3C2440_NFCONF_ADVFLASH         (1<<3)
#define S3C2440_NFCONF_TACLS(x)         ((x)<<12)
#define S3C2440_NFCONF_TWRPH0(x)        ((x)<<8)
#define S3C2440_NFCONF_TWRPH1(x)        ((x)<<4)

#define S3C2440_NFCONT_LOCKTIGHT        (1<<13)
#define S3C2440_NFCONT_SOFTLOCK         (1<<12)
#define S3C2440_NFCONT_ILLEGALACC_EN    (1<<10)
#define S3C2440_NFCONT_RNBINT_EN        (1<<9)
#define S3C2440_NFCONT_RN_FALLING       (1<<8)
#define S3C2440_NFCONT_SPARE_ECCLOCK    (1<<6)
#define S3C2440_NFCONT_MAIN_ECCLOCK     (1<<5)
#define S3C2440_NFCONT_INITECC          (1<<4)
#define S3C2440_NFCONT_nFCE             (1<<1)
#define S3C2440_NFCONT_ENABLE           (1<<0)

#define S3C2440_NFSTAT_READY            (1<<0)
#define S3C2440_NFSTAT_nCE              (1<<1)
#define S3C2440_NFSTAT_RnB_CHANGE       (1<<2)
#define S3C2440_NFSTAT_ILLEGAL_ACCESS   (1<<3)



#define S3C2440_ADDR_NALE 0x08
#define S3C2440_ADDR_NCLE 0x0C

static void s3c2440_hwcontrol(struct mtd_info *mtd, int cmd, unsigned int ctrl)
{
	struct nand_chip *chip = mtd->priv;
       
	DEBUGN("hwcontrol(): 0x%02x 0x%02x\n", cmd, ctrl);

	if (ctrl & NAND_CTRL_CHANGE) {
		ulong IO_ADDR_W = 0x4E000000;

		if (!(ctrl & NAND_CLE))
			IO_ADDR_W |= S3C2440_ADDR_NCLE;
		if (!(ctrl & NAND_ALE))
			IO_ADDR_W |= S3C2440_ADDR_NALE;

		chip->IO_ADDR_W = (void *)IO_ADDR_W;

		if (ctrl & NAND_NCE)
			S3C2440_NFCONT &= ~S3C2440_NFCONT_nFCE;
		else
			S3C2440_NFCONT |= S3C2440_NFCONT_nFCE;
	}

	if (cmd != NAND_CMD_NONE)
		writeb(cmd, chip->IO_ADDR_W);

}

static int s3c2440_dev_ready(struct mtd_info *mtd)
{
	DEBUGN("dev_ready\n");
	return (S3C2440_NFSTAT & S3C2440_NFSTAT_READY);
}

#ifdef CONFIG_S3C2440_NAND_HWECC
void s3c2440_nand_enable_hwecc(struct mtd_info *mtd, int mode)
{
	DEBUGN("s3c2440_nand_enable_hwecc(%p, %d)\n", mtd, mode);
	NFCONT |= S3C2440_NFCONT_INITECC;
}

static int s3c2440_nand_calculate_ecc(struct mtd_info *mtd, const u_char *dat,
				      u_char *ecc_code)
{
	ecc_code[0] = NFMECC0;
	ecc_code[1] = NFMECC0>>8;
	ecc_code[2] = NFMECC0>>16;
	DEBUGN("s3c2440_nand_calculate_hwecc(%p,): 0x%02x 0x%02x 0x%02x\n",
		mtd , ecc_code[0], ecc_code[1], ecc_code[2]);

	return 0;
}

static int s3c2440_nand_correct_data(struct mtd_info *mtd, u_char *dat,
				     u_char *read_ecc, u_char *calc_ecc)
{
	if (read_ecc[0] == calc_ecc[0] &&
	    read_ecc[1] == calc_ecc[1] &&
	    read_ecc[2] == calc_ecc[2])
		return 0;

	printf("s3c2440_nand_correct_data: not implemented\n");
	return -1;
}
#endif

int board_nand_init(struct nand_chip *nand)
{
	u_int32_t cfg;
	u_int8_t tacls, twrph0, twrph1;
	S3C24X0_CLOCK_POWER * const clk_power = S3C24X0_GetBase_CLOCK_POWER();

	DEBUGN("board_nand_init()\n");

	clk_power->CLKCON |= (1 << 4);

	/* initialize hardware */
	twrph0 = 3; twrph1 = 0; tacls = 0;

	cfg = S3C2440_NFCONF_TACLS(tacls);
	cfg |= S3C2440_NFCONF_TWRPH0(twrph0);
	cfg |= S3C2440_NFCONF_TWRPH1(twrph1);

	//S3C2440_NFCONT |= S3C2440_NFCONT_ENABLE;
	//S3C2440_NFCONF = cfg;
	S3C2440_NFCONT = 0x1;
	S3C2440_NFCONF = 0x2440;

	/* initialize nand_chip data structure */
	nand->IO_ADDR_R = nand->IO_ADDR_W = (void *)0x4e000010;

	/* read_buf and write_buf are default */
	/* read_byte and write_byte are default */

	/* hwcontrol always must be implemented */
	nand->cmd_ctrl = s3c2440_hwcontrol;

	nand->dev_ready = s3c2440_dev_ready;

#ifdef CONFIG_S3C2440_NAND_HWECC
	nand->ecc.hwctl = s3c2440_nand_enable_hwecc;
	nand->ecc.calculate = s3c2440_nand_calculate_ecc;
	nand->ecc.correct = s3c2440_nand_correct_data;
	nand->ecc.mode = NAND_ECC_HW3_512;
#else
	nand->ecc.mode = NAND_ECC_SOFT;
#endif

#ifdef CONFIG_S3C2440_NAND_BBT
	nand->options = NAND_USE_FLASH_BBT;
#else
	nand->options = 0;
#endif

        DEBUGN("board_nand_init() in cpu/arm920t/s3c24x0/nand.c\n");

	DEBUGN("end of nand_init\n");

	return 0;
}

#else
 #error "U-Boot legacy NAND support not available for S3C2440"
#endif
#endif
