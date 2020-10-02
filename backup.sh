#!/usr/bin/bash

#This bash script is used to backup a user's home directory to /tmp/.

#I changed the input to "/c/Users/$user" originally, but because it actually started the process
# and took a very long time to complete, I decided to change it to "/Users/$user". It doesn't work
# the way it was supposed to, but it is better than when it ran for ages without bearing results.

function backup {

	if [ -z $1 ]; then
		user=$(whoami)
	else
		if [ ! -d "/home/$1" ]; then
			echo "Requested $1 user home directory doesn't exist."
			exit 1
		fi
		user=$1
	fi

	input=/Users/$user
	output=/tmp/${user}_home_$(date +%Y-%m-%d_%H%M%S).tar.gz

	#The function total_files reports a total number of files for a given directory.
	function total_files {
		find $1 -type f | wc -1
	}

	#The function total_directories reports a total number of directories
	#for a given directory.
	function total_directories {
		find $1 -type d | wc -1
	}

	function total_archived_directories {
		tar -tzf $1 | grep /$ | wc -1
	}

	function total_archived_files {
		tar -tzf $1 | grep -v /$ | wc -1
	}

	tar -czf $output $input 2> /dev/null

	src_files=$(total_files $input)
	src_directories=$(total_directories $input)

	arch_files=$(total_archived_files $output)
	arch_directories=$(total_archived_directories $output)

	echo "########## $user ##########"
	echo "Files to be included: $src_files"
	echo "Directories to be included: $src_directories"
	echo "Files archived: $arch_files"
	echo "Directories archived: $arch_directories"

	if [ $src_files -eq $arch_files ]; then
		echo "Backup of $input completed!"
		echo "Details about the output backup file:"
		ls -l $output
	else
		echo "Backup of $input failed!"
	fi
}
for directory in $*; do
	backup $directory
done;