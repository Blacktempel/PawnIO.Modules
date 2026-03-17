//  PawnIO Modules - Modules for various hardware to be used with PawnIO.
//  Copyright (C) 2026  namazso <admin@namazso.eu>
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

/// Query DELL SMM.
///
/// @param in Input registers in order eax ecx edx ebx esi edi
/// @param in_size Must be 6
/// @param out Output registers in order eax ecx edx ebx esi edi
/// @param out_size Must be 6
/// @return An NTSTATUS
DEFINE_IOCTL_SIZED(ioctl_query_smm, 6, 6) {
    return query_dell_smm(in, out) ? STATUS_SUCCESS : STATUS_UNSUCCESSFUL;
}

NTSTATUS:main() {
    return STATUS_SUCCESS;
}
