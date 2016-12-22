list_path=$(find "$1" | grep -E '\.jpg')

IFS=$'\n'
for path in $list_path;
do
	exif_jpg=$(exif "$path")
	if [ ! "$exif_jpg" ]; then
		exif_jpg=$(exiftool "$path")
		
		list_time=$(echo "$exif_jpg" | grep -E 'Date\/Time Original' | grep -Eo '[0-9]{4}.[0-9]{2}.[0-9]{2} +[0-9]{2}.[0-9]{2}.[0-9]{2}')
		if [ ! "$list_time" ]; then
			list_time=$(echo "$exif_jpg" | grep -E 'Create Date' | grep -Eo '[0-9]{4}.[0-9]{2}.[0-9]{2} +[0-9]{2}.[0-9]{2}.[0-9]{2}')
		fi
		path_dir=$(echo "$list_time" | grep -Eo '^[^ ]*' | sed 's/[^0-9 ]\+/\//g')
		name_time=$(echo "$list_time" |  sed 's/^[^ ]* *//g' |  sed 's/:/-/g' )
		manufacturer=$(echo "$exif_jpg" | grep -Eo 'Make *.*' | sed 's/^[^:]*://g')
		model=$(echo "$exif_jpg" | grep -Eo 'Camera Model Name *.*' | sed 's/^[^:]*://g')
		name_file="$name_time-""$manufacturer""-$model"	
	else
		list_time=$(echo "$exif_jpg" | grep -Eo '[0-9]{4}.[0-9]{2}.[0-9]{2} +[0-9]{2}.[0-9]{2}.[0-9]{2}' | sort -u)
		path_dir=$(echo "$list_time" | grep -Eo '^[^ ]*' | sed 's/[^0-9 ]\+/\//g' | head -n 1)
		name_time=$(echo "$list_time" |  sed 's/^[^ ]* *//g' |  sed 's/:/-/g' | head -n 1)
		manufacturer=$(echo "$exif_jpg" | grep -Eo 'Manufacturer.*' | sed 's/^[^\]*|//g')
		model=$(echo "$exif_jpg" | grep -Eo 'Model.*' | sed 's/^[^\]*|//g')
		name_file="$name_time-""$manufacturer""-$model"	
	fi


	if [ ! "$name_file" ] ; then		
		continue
	fi

	if [ ! "$path_dir" ] ; then		
		continue
	fi

	if [ -e "$2/$path_dir/$name_file.jpg" ] ; then
		echo "$1/$path_dir/$name_file"
		hash1=$(md5sum  "$path" | grep -Eo '^.{32}')
		hash2=$(md5sum  "$2/$path_dir/$name_file.jpg" | grep -Eo '^.{32}')
		if [ "$hash1" == "$hash2" ]; then 		
			echo "------------------------------------"
			echo "$2/$path_dir/$name_file.jpg"
			echo "[ dubl ]   $path"
			
			rm "$path"
		else			
			echo "[ good ]   $hash1 != $hash2"
			mv "$path" "$2/$path_dir/$name_file"_"$hash1.jpg"
		fi
	else
		echo "[ uniq ]   "$2/$path_dir/$name_file.jpg""
		mkdir -p "$2/$path_dir"
		mv "$path" "$2/$path_dir/$name_file.jpg"
	fi
done

