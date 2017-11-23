for f in "$@"
do
	echo "$f" >> $HOME/Desktop/log
	echo "/Users/user/Desktop/mri-post-process/mri-post-process.sh $f" | batch
done
