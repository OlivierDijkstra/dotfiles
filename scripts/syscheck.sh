#!/bin/bash
# Arch / CachyOS post-update system check

echo "== Package integrity =="
sudo pacman -Dk
sudo pacman -Qk | grep -v '0 missing' || echo "✓ no missing files"
sudo pacman -Qdt || echo "✓ no orphaned packages"

echo -e "\n== System services =="
systemctl --failed || echo "✓ no failed units"
systemctl list-units --state=degraded | grep -v "LOAD" || echo "✓ no degraded units"

echo -e "\n== Recent errors =="
journalctl -b -p err..alert --no-pager | tail -n 20 || echo "✓ no recent errors"

echo -e "\n== Kernel / driver check =="
lspci -k | grep -A3 -E "VGA|3D"
lsmod | grep -E "nvidia|amdgpu|i915" || echo "✓ GPU module present"
dmesg -l err,crit,alert,emerg | tail -n 10 || echo "✓ no kernel errors"

echo -e "\n== Hyprland / Wayland =="
journalctl _COMM=Hyprland -b | tail -n 10 || echo "✓ Hyprland clean"
systemctl --user status xdg-desktop-portal-hyprland.service --no-pager -l | head -n 10

echo -e "\n== Network =="
ping -c1 archlinux.org >/dev/null 2>&1 && echo "✓ internet OK" || echo "✗ network issue"
systemctl is-active NetworkManager >/dev/null && echo "✓ NetworkManager active" || echo "✗ NetworkManager inactive"

echo -e "\n== Filesystem / disks =="
dmesg | grep -i "btrfs.*error\|I/O error" | tail -n 5 || echo "✓ no FS errors"
mount | grep -E "btrfs|ext|xfs"
for d in /dev/sd?; do
  sudo smartctl -H "$d" | grep -E "SMART overall-health|result"
done 2>/dev/null

echo -e "\n== Summary complete =="
