#include <uk/config.h>
#include <arm/arm64/cpu.h>
#include <zynqmp/config.h>
#include <uk/essentials.h>

struct zynqmpplat_config _libzynqmpplat_cfg = { 0 };

smcc_psci_callfn_t smcc_psci_call;
struct zynqmpplat_config _libzynqmpplat_cfg;

const void *ukplat_dtb_get(void)
{
	return _libzynqmpplat_cfg.dtb.base;
}

void _libplat_zynqmp_entry(void *args __unused)
{

}

void _libplat_start(void *dtb_pointer)
{
	int ret;

	if ((ret = fdt_check_header(dtb_pointer)))
		UK_CRASH("Invalid DTB: %s\n", fdt_strerror(ret));

	_libzynqmpplat_cfg.dtb.base = dtb_pointer;
	_libzynqmpplat_cfg.dtb.size = fdt_totalsize(dtb_pointer);
	uk_pr_info("Found device tree on: %p\n", dtb_pointer);

	/* Initialize the zynq platform */
	XFsbl_Initialize(&__libzynqmpplat.xfsblps);
}
