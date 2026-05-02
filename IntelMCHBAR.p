//  PawnIO Modules - Modules for various hardware to be used with PawnIO.
//  Copyright (C) 2026  Gen Li
//
//  This library is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with this library; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//  SPDX-License-Identifier: LGPL-2.1-or-later

#include <pawnio.inc>

// PawnIO Intel MCHBAR Driver

#define PCI_VENDOR_ID_INTEL 0x8086

#define MCHBAR_BASE_REG_LOW     0x48
#define MCHBAR_BASE_REG_HIGH    0x4C

#define MCHBAREN        0x01

// 128KB
#define MCHBAR_SIZE     0x20000

new g_mchbar_addr = 0;

NTSTATUS:mchbar_init() {
    new didvid;
    new NTSTATUS:status = pci_config_read_dword(0, 0, 0, 0, didvid);
    if (!NT_SUCCESS(status))
        return status;
    if (didvid & 0xFFFF != PCI_VENDOR_ID_INTEL)
        return STATUS_NOT_SUPPORTED;

    new base_lo = 0;
    new base_hi = 0;

    pci_config_read_dword(0, 0, 0, MCHBAR_BASE_REG_LOW, base_lo);
    if (!(base_lo & MCHBAREN))
        return STATUS_NOT_SUPPORTED;
    pci_config_read_dword(0, 0, 0, MCHBAR_BASE_REG_HIGH, base_hi);

    g_mchbar_addr = ((base_hi & 0xFFFFFFFF) << 32) | (base_lo & 0xFFFFFFFF);
    g_mchbar_addr &= 0x3FFFFFF8000;
    if (g_mchbar_addr == 0)
        return STATUS_NOT_SUPPORTED;

    return STATUS_SUCCESS;
}

/// Read a dword from mchbar.
///
/// @param in [0] = offset
/// @param in_size Must be 1
/// @param out [0] = Value read
/// @param out_size Must be 1
/// @return An NTSTATUS
DEFINE_IOCTL_SIZED(ioctl_read_dword, 1, 1) {
    new offset = in[0];

    if (offset >= MCHBAR_SIZE)
        return STATUS_ACCESS_DENIED;
    if (offset & 0x3)
        return STATUS_ACCESS_DENIED;

    new VA:va = io_space_map(g_mchbar_addr + offset, 4);
    if (va == NULL)
        return STATUS_INSUFFICIENT_RESOURCES;
    new value = 0;
    new NTSTATUS:status = virtual_read_dword(va, value);
    io_space_unmap(va, 4);

    out[0] = value;
    return status;
}

/// Read a qword from mchbar.
///
/// @param in [0] = offset
/// @param in_size Must be 1
/// @param out [0] = Value read
/// @param out_size Must be 1
/// @return An NTSTATUS
DEFINE_IOCTL_SIZED(ioctl_read_qword, 1, 1) {
    new offset = in[0];

    if (offset >= MCHBAR_SIZE)
        return STATUS_ACCESS_DENIED;
    if (offset & 0x7)
        return STATUS_ACCESS_DENIED;

    new VA:va = io_space_map(g_mchbar_addr + offset, 8);
    if (va == NULL)
        return STATUS_INSUFFICIENT_RESOURCES;
    new value = 0;
    new NTSTATUS:status = virtual_read_qword(va, value);
    io_space_unmap(va, 8);

    out[0] = value;
    return status;
}

NTSTATUS:main() {
    if (get_arch() != ARCH_X64)
        return STATUS_NOT_SUPPORTED;

    if (get_cpu_vendor() != CpuVendor_Intel)
        return STATUS_NOT_SUPPORTED;

    return mchbar_init();
}
