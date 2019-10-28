#!/bin/bash -x
kernel_name="myKernel"
linux_version="5.3.5"
JOBS=$[$(grep cpu.cores /proc/cpuinfo | sort -u | sed 's/[^0-9]//g') + 1]

function init (){
	local url="https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-${linux_version}.tar.xz"
	local syscall_num=436
	local syscall_tbl="arch/x86/entry/syscalls/syscall_64.tbl"
	local syscall_name="hello"
	local incert_line="${syscall_num}	common	${syscall_name}			__x64_sys_${syscall_name}"
	local func_name="mycall.c"

	curl -O -J ${url}

	tar xvf linux-${linux_version}.tar.xz

	zcat /proc/config.gz > ./linux-${linux_version}/.config

	cd ./linux-${linux_version}

	zcat /proc/config.gz > .config 

sed -i -e '/^CONFIG_LOCALVERSION=/s/\".\+\"$/\"-'${kernel_name}'\"/gi' .config

	cat ${syscall_tbl} | grep -n `expr ${syscall_num} - 1` | sed -e 's/:.*//g' > tmp

	local incert_num=`expr $(cat tmp) + 1`

	sed -i -e "${incert_num}i ${incert_line}" ${syscall_tbl} 

	echo "#include \"../../${func_name}\""  >> kernel/sys.c

	make oldconfig
}

function deploy (){
	cd ./linux-${linux_version}

	set -e

	make 
	make modules_install 

	cp arch/x86_64/boot/bzImage /boot/vmlinuz-linux-${kernel_name}

	sed s/linux/linux-${kernel_name}/g \
	    </etc/mkinitcpio.d/linux.preset \
	   	>/etc/mkinitcpio.d/linux-${kernel_name}.preset
	mkinitcpio -p linux-${kernel_name}

	grub-mkconfig -o /boot/grub/grub.cfg
}

function clearn (){
	rm -rf linux-${linux_version}*
}

if [ $# -eq 0 ]; then
	echo "error: argument is required"
	exit 1
fi

echo $1

if [ $1 = "init" ]; then
	init
elif [ $1 = "deploy" ]; then
	deploy
elif [ $1 = "clearn" ]; then
	clearn
else
	echo "error: invalid argument"
fi

exit 0

