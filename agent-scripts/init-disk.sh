mkfs.xfs -f /dev/sdb
mkfs.xfs -f /dev/sdc

mkdir /dcos/path0 -p
mkdir /dcos/path1 -p

mount /dev/sdb /dcos/path0
mount /dev/sdc /dcos/path1

/dev/sdb	/dcos/path0	xfs	defaults	0 0
/dev/sdc	/dcos/path1	xfs	defaults	0 0
