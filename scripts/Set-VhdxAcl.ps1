# Apply the NTFS DACL required for WSL to mount a kernelModules VHDX.
# WSL 2.7.1+ rejects vhdx files lacking read access for AppContainer SIDs
# with Wsl/Service/CreateInstance/CreateVm/HCS/E_ACCESSDENIED. This resets
# the DACL to mirror the official modules.vhd shape.
#
# SIDs are used directly to avoid locale-dependent name lookups:
#   S-1-5-18         NT AUTHORITY\SYSTEM                       (F)
#   S-1-5-32-544     BUILTIN\Administrators                    (F)
#   S-1-5-32-545     BUILTIN\Users                             (RX)
#   S-1-15-2-1       APPLICATION PACKAGE AUTHORITY\
#                    ALL APPLICATION PACKAGES                  (RX)
#   S-1-15-2-2       APPLICATION PACKAGE AUTHORITY\
#                    ALL RESTRICTED APPLICATION PACKAGES       (RX)
#
# Owner is left as-is (extraction-time owner, typically the current user).
# Setting owner to BUILTIN\Administrators would require SeRestorePrivilege,
# which a non-elevated Scoop install does not hold. WSL's access check looks
# at the DACL only, so this is sufficient.

function Set-VhdxAcl {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    & icacls.exe $Path /inheritance:r /grant:r `
        '*S-1-5-18:(F)' `
        '*S-1-5-32-544:(F)' `
        '*S-1-5-32-545:(RX)' `
        '*S-1-15-2-1:(RX)' `
        '*S-1-15-2-2:(RX)' | Out-Null
}

# Usage:
# . $bucketsdir\$bucket\scripts\Set-VhdxAcl.ps1
# Set-VhdxAcl -Path $vhdx_file
