/******************************************************************************
*
* Copyright (C) 2015 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
*******************************************************************************/

/*****************************************************************************/
/**
*
* @file xfsbl_exit.s
*
* This is the main file which contains exit code for the FSBL.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date        Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00  kc   11/13/13 Initial release
*       mus  02/26/19 Added support for armclang compiler
*
* </pre>
*
* @note
*
******************************************************************************/

/***************************** Include Files *********************************/

/************************** Constant Definitions *****************************/

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/
#if ! defined (__clang__)
.globl XFsbl_Exit

/************************** Variable Definitions *****************************/

XFsbl_Exit:

	mov x30, x0 /* move the destination address into x30 register */

	tlbi ALLE3   /* invalidate All E3 translation tables */
	ic IALLU   /* invalidate I Cache All to PoU, Inner Shareable */

	dsb sy
	isb 			 /* make sure it completes */

	mrs x5, SCTLR_EL3	 /* Read control register */
	mov x6, #0x1005  	 /* D, I , M bits disable */
        bic     x5, x5, x6 	 /* Disable MMU, L1 and L2 I/D cache */
        msr     SCTLR_EL3, x5    /*  */

	isb

	cmp x1, #0  		/* exit to wfe    */
	beq XFsbl_Loop

	cmp x1, #1   /* x1 is 1 - exit in aarch64  */
	beq XFsbl_StartApp

		     /* x1 is 2 - exit in aarch32 */

	mov x2, #2   /* request for warm reset and aarch32 */
	dsb sy
	isb
	msr RMR_EL3,x2 /* write to reset management register */
	isb

XFsbl_Loop:
	wfe				/* wait for event */
	b XFsbl_Loop

.Ldone:
	b		.Ldone		/* Paranoia: we should never get here */

XFsbl_StartApp:
	br 	x30        /* branch to */
.end
#else

	EXPORT XFsbl_Exit
	AREA |.exit|, CODE
XFsbl_Exit


	mov x30, x0 ; move the destination address into x30 register

	tlbi ALLE3   ; invalidate All E3 translation tables
	ic IALLU   ; invalidate I Cache All to PoU, Inner Shareable

	dsb sy
	isb 			; make sure it completes

	mrs x5, SCTLR_EL3	; Read control register
	mov x6, #0x1005		; D, I , M bits disable
	bic     x5, x5, x6 	; Disable MMU, L1 and L2 I/D cache
	msr     SCTLR_EL3, x5

	isb

	cmp x1, #0  		; exit to wfe
	beq XFsbl_Loop

	cmp x1, #1   ; x1 is 1 - exit in aarch64
	beq XFsbl_StartApp

	;x1 is 2 - exit in aarch32

	mov x2, #2   ; request for warm reset and aarch32
	dsb sy
	isb
	msr RMR_EL3,x2 ; write to reset management register
	isb


XFsbl_Loop
	wfe				;wait for event
	b XFsbl_Loop


XFsbl_StartApp
	br 	x30        ; branch to
	END
#endif
