#!/bin/bash

year=$(date +%G)
month_num=$(date +%m)
day=$(date +%d)
diary_dir="diary"
build_dir="build"
pdfs_dir="pdfs"
todays_entry="$day.tex"
author="Ahmed Essam"
year_to_compile="meh"
entry_to_compile="meh"
style_file="research_diary.sty"
other_files_path="other_files/"
images_files_path="images/"
main_file="main"
text_editor="code"
DOW=$(date +%u)


declare -a months=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
month=${months[10#$month_num - 1]}

add_entry ()
{
    echo "Today is $year/$month/$day"
    echo "Your diary is located in: $diary_dir/."

    if [ ! -d "$diary_dir" ]; then
        mkdir "$diary_dir"
    fi

    if [ ! -d "$diary_dir/$year" ]; then
        mkdir "$diary_dir/$year"
    fi

    if [ ! -d "$diary_dir/$year/$month" ]; then
	mkdir "$diary_dir/$year/$month"
    fi

    if [ -d "$diary_dir/$year/$month" ]; then
        echo "Adding new entry to directory $diary_dir/$year/$month."

        cd "$diary_dir/$year/$month" || exit -1
        filename="$day.tex"

        if [ -f "$filename" ]; then
            echo "File for today already exists: $diary_dir/$year/$filename."
            echo "Happy writing!"
        else
            touch "$filename"
	    echo "\begin{entry}[$DOW]{Title}" > "$filename"
	    echo "% content" >> "$filename"
	    echo "\end{entry}" >> "$filename" 
            echo "Finished adding $filename to $year/$month."
        fi
	cd ../../../ || exit -1
	$text_editor "$diary_dir/$year/$month/$filename" 
	anthology_live
    fi
}

clear_build()
{
   rm -f "$build_dir"/*
}

move_pdfs()
{
   mv -v "$build_dir"/*.pdf "$pdfs_dir"/
}

create_anthology ()
{
    echo "Compiling..."
    if ! latexmk -pdf --interaction=nonstopmode -outdir=$build_dir "$main_file.tex" ; then
        echo "Compilation failed. Exiting."
        exit -1
    fi
    move_pdfs
    xdg-open "$pdfs_dir/$main_file.pdf"
}

anthology_live ()
{
    clear_build
    echo "Starting live preview..."
    
    latexmk -pdf -f --interaction=nonstopmode -outdir=$build_dir "$main_file.tex"

    xdg-open "$build_dir/$main_file.pdf"
    if ! latexmk -pdf -pvc --interaction=nonstopmode -outdir=$build_dir "$main_file.tex" ; then
	echo "Operation failed. Exiting."
	exit -1
    fi
    move_pdfs
}


usage ()
{
    cat << EOF
    OPTIONS:
    -h  Show this message and quit
    -t  Add new entry for today
    -c  Create anthology
    -l  live preview of the anthology 
EOF

}

if [ "$#" -eq 0 ]; then
    usage
    exit 0
fi

while getopts "ltca:hp:s:" OPTION
do
    case $OPTION in
        t)
            add_entry
            exit 0
            ;;
        c)
            create_anthology
            exit 0
            ;;
	l)
	    anthology_live
	    exit 0
	    ;;
        ?)
            usage
            exit 0
            ;;
    esac
done
