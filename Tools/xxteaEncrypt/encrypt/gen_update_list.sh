if [ $# -le 0 ]; then
	echo "Usage: $0 dirlist";
	exit 1;
fi

gen_dir()
{
	rm -f $1/files.md5;
	rm -f $1/all.md5;

	local i;
	for i in `find $1 -type f -name ".*"`; do
		rm -f $i;
	done

	for i in `find $1 -type f`; do
		md5=`openssl md5 $i |cut -f2 -d ' '`;
		size=$(wc -c $i | awk '{print $1}');
		#size=`du -b $i|cut -f1`;
		echo "$i	$md5	$size";	
	done
}

for i in $@; do
	echo "gen_dir $i...";
	gen_dir $i >files.md5;
	openssl md5 files.md5|cut -f2 -d ' ' >all.md5
	mv files.md5 $i/
	mv all.md5 $i/
done
