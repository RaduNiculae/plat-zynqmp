#include <uk/config.h>
#include <arm/arm64/cpu.h>
#include <zynqmp/config.h>
#include <uk/essentials.h>
#include <libfdt.h>
#include <uk/plat/common/sections.h>
#include <xparameters.h>
#include <uk/essentials.h>
#include <rtc/rtc.h>

struct zynqmpplat_config _libzynqmpplat_cfg = { 0 };
static const char *appname = CONFIG_UK_NAME;

extern char *_heap_start;
extern char *_heap_end;
extern char *_STACK_SIZE;
extern char *__uk_dtb_start;

extern void _libplat_newstack(uint64_t stack_start,
		              void (*tramp)(void *), void *arg);
extern int _libplat_rtc_init(const void *dtb __maybe_unused);

extern uint64_t rtc_boot_ticks;
smcc_psci_callfn_t smcc_psci_call;
struct zynqmpplat_config _libzynqmpplat_cfg;


const void *ukplat_dtb_get(void)
{
	return _libzynqmpplat_cfg.dtb.base;
}

static void _libzynqplat_mem_setup(void)
{
	_libzynqmpplat_cfg.heap.base = (void *) &_heap_start;
	_libzynqmpplat_cfg.heap.len = (uintptr_t) &_heap_end -
				(uintptr_t)&_heap_start;

	_libzynqmpplat_cfg.bstack.base = (void *)
			((uintptr_t)XPAR_PSU_OCM_RAM_0_S_AXI_HIGHADDR);
	_libzynqmpplat_cfg.bstack.len = (uintptr_t)&_STACK_SIZE;

}


void _libzynqmpplat_entry2(void *args __unused)
{
	/* Initialize the zynq platform */
	XFsbl_Initialize(&_libzynqmpplat_cfg.xfsblps);


#ifdef CONFIG_ZYNQMP_UARTPS
	/* TODO:move the page table initialization here */
	_libplat_init_console(_libzynqmpplat_cfg.dtb.base);
#endif /* CONFIG_ZYNQMP_UARTPS */

	/* Initialize the interrupt controller */
	intctrl_init();

#ifdef CONFIG_ZYNQMP_XLNX_RTC
	/* Initialize the boot tick */
	_libplat_rtc_init(_libzynqmpplat_cfg.dtb.base);
#endif /* CONFIG_ZYNQMP_XLNX_RTC */


	ukplat_entry_argp(DECONST(char *, appname),
              NULL, 0);
}

void _libplat_start(void *dtb_pointer __unused)
{
	int ret;

	memset(&_libzynqmpplat_cfg, 0, sizeof(_libzynqmpplat_cfg));
	if ((ret = fdt_check_header(__uk_dtb_start)))
		UK_CRASH("Invalid DTB: %s\n", fdt_strerror(ret));

	_libzynqmpplat_cfg.dtb.base = __uk_dtb_start;
	_libzynqmpplat_cfg.dtb.len = fdt_totalsize(__uk_dtb_start);

	_libzynqplat_mem_setup();
	_libplat_newstack(_libzynqmpplat_cfg.bstack.base,
			_libzynqmpplat_entry2, NULL);

}
