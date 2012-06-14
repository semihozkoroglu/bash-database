#!/bin/bash

_temp=./answer
index=0
filecount=0
filelist=''

#These variables will be used in some different functions
#And these must be global so i used them here.
#_temp is my temporary file.

countfile(){

  filecount=$(ls -l *.md |wc -l)
  filelist=(`ls *.md`)
  if [ $filecount -eq 0 ]; then
     notable;
     menu;
  fi
#countfile function is list the ´.md´ extension files and count them
#if there isn't any file call notable function.
#then goes to menu
#filelist isn't related with this function But i will use this value all i call this function
#i use here for don't be repetition code.   
 }
gotomenu(){

  if [ $? -eq 1 ]; then
      menu;
  fi
#if return value is equal to 1.Namely if user press cancel go to menu.
}
notable(){
 
	dialog --msgbox "\n There isn't table" 8 52
#if there isn't table this message box will be shown
}

showtables() {

  for i in *.md; do
    c="${i%.*}"
    echo "$index $c off"
    let index+=1
  done
#Wander on ´.md´ extension files and throw the extension,
#put the screen index and only bare file names namely table names
}

menu(){

  dialog --menu "Please select a command" 30 50 7 \
     1 "Create Table" \
     2 "Delete Table" \
     3 "Insert Record" \
     4 "Delete Record"\
     5 "Sort Table"\
     6 "Help" \
     7 "Quit" 2> $_temp
#here is my menu box user select here one of them
#i have seven case so i prefer to use case command
#menu's output goes to _temp, then i use the output in cases
  if [ $? -eq 0 ]; then
    result=`cat $_temp`
    case $result in
      1)create_table;
      ;;
      2)delete_table;
      ;;
      3)insert_record;
      ;;
      4)delete_record;
      ;;
      5)sort_table;
      ;;
      6)helpy;
      ;;
      7)exit;;
    esac
  
  elif [ $? -eq 1 ];then
    exit
  fi
#if user press cancel button output will be ´1´.
#So if output equal to 1, program will exit.
}

create_table() {

  dialog --backtitle "Create Table"\
        --inputbox "Please enter table name:" 8 52 2>$_temp
  gotomenu;


  result=`cat $_temp`
  table_name=$result
#user write a table name and output goes to result variable then to table_name varible.

  dialog --backtitle "Create Table"\
         --inputbox "Please enter column number:" 8 52 2>$_temp
  gotomenu;

  result=`cat $_temp`
  column_number=$result
#user write here the column number and output save as to column_number variable
  while ! [[ "$result" =~ ^[0-9]+$ ]]; do 
    dialog --msgbox "Please enter as number" 8 52
    dialog --backtitle "Create Table"\
           --inputbox "Please enter column numbers:" 8 52 2>$_temp
#But ´if column_number isn't a number´ control is provided with while fool.
#User must enter here a number.
 
    result=`cat $_temp`
    column_number=$result
 done

  gotomenu;
  id=0
  t_n=$table_name.md
  height=`expr $column_number \* 10`
  width=`expr $height \/ 2`
  dialog --backtitle "Create Table"\
         --form "Please enter column names:" $width $height $column_number \
              $(for (( i=1; i<=$column_number;i++ )); do
              echo  "$id $i 1 Input $i 13 30 40"
              let id+=1
              done) 2>$_temp
  gotomenu;
#dialog-form wants to us a width and height number
#i could use here fix numbers 
#but i want to use changeable values according to inputs number.
  result=`cat $_temp`
  column_name=$result
  c=$(echo $column_name | sed 's/ /:/g')
#here i seperate the columns accoring to spaces 
#change the spaces with ":"
#Because when i use this values, reading from file will be easier 
  echo $c>$t_n 

  dialog --msgbox "\nYou entered table name:  $table_name\n
                 \nYou entered column numbers:  $column_number\n 
                 \nYou entered columns:\n$column_name" 15 52
  menu;
}
#message box puts here my values.
delete_table(){

  index=0
	
  countfile;

  dialog --backtitle "Delete Table"\
         --radiolist "Please select table that want to delete:" 50 50 $filecount\
       $(showtables) 2>$_temp
  gotomenu;
#Here user select a table name to delete
  result=`cat $_temp`
  filename="${filelist[$result]%.*}"
#filelist list the ´.md´ extension files. i take here selected table's bare name.
  dialog --yesno "Do you really want to delete $filename?\n" 8 52 
    if [ $? -eq 0 ]; then
      rm -rf $filename.md
      delete_table;
    else
      gotomenu;
    fi
#if you really want to delete table it will delete or you will be directed to menu.    
}

insert_record(){

  index=0
  tmp=0

  countfile;

  dialog --backtitle "Insert Record"\
               --radiolist "Please select table that want to insert record:" 40 52 $filecount\
                $(showtables) 2>$_temp
	gotomenu;
#Here user select a table name to insert record in it
  result=`cat $_temp`
  filename="${filelist[$result]%.*}"
#filelist list the ´.md´ extension files. i take here selected table's bare name.
  line=$(head -n 1 $filename.md)
#line variable take file's first line i will use these as fields name 
  filehead=(`echo $line | tr ":" "\n"`)
# i took the first line and these have ":" between them so i must change ":" to \n
#because i will put the screen them one under to other. 
  last=${#filehead[@]}
#last variable is these filehead's number  
  height=`expr $last \* 10`
#i took this variable for use in form as height 
  dialog --backtitle "Insert Record"\
         --form "$filename" 12 $height $last \
          $( for ((i=1; i<=$last;i++)); do
                 echo  "${filehead[$tmp]}  $i 1 input $i 13 30 40 "
		 let tmp+=1
             done ) 2>$_temp
#all fields are put the screen with input spaces for user enter here.	   
             if [ $? -eq 1 ]; then
                  insert_record;
              fi
#if user press cancel program goes to insert_record menu.
	result=`cat $_temp | tr '\n' ':'`
	c="${result%:*}"
	echo $c >> $filename.md
#then i reverse my operation and i add the new records to my table file.
	insert_record;
}

delete_record(){
  
  index=0
  tmp=0

	countfile;

	dialog --backtitle "Delete Record"\
               --radiolist "Please select table that want to delete record:" 40 50 $filecount\
                $(showtables) 2>$_temp
              gotomenu;

  result=`cat $_temp`
  filename="${filelist[$result]%.*}"
#filelist list the ´.md´ extension files. i take here selected table's bare name.
  if  [ `tail $filename.md | wc -l` -eq 1 ];then
      dialog --msgbox "This table is empty" 8 52
      delete_record;
  fi
#here file's last line is equal to 1, message box appear.
#Because if there is a line in the table, this line equal to fields name
#so we mustn't delete this field. And program won't allow this. 
	dialog --backtitle "Delete Record"\
                --inputbox "Please give a string that want to delete rows:" 8 52 2>$_temp

	if [ $? -eq 1 ]; then
  		delete_record;
  	fi
#user enter a string here and
#if press ´cancel´ program goes to delete_record menu
	result=`cat $_temp`
	sed -i "/\<$result\>/d" $filename.md
        delete_record;
#if press ´ok´ program search the given word in table
# and delete row that includes given word.
	if [ $? -ne 0 ]; then
  	dialog --msgbox "\n Given word couldn't find in this table" 8 52
		delete_record;
        fi
#if given word isn't in the table message box appear 
#and program goes to delete_record menu.
}
sort_table(){

	index=0
	field=1
  tmp=0

  countfile;

  dialog --backtitle "Sort Table"\
         --radiolist "Please select table that want to sort:" 40 52 $filecount\
                $(showtables) 2>$_temp
  gotomenu;

  result=`cat $_temp`
  filename="${filelist[$result]%.*}"
#filelist list the ´.md´ extension files. i take here selected table's bare name.
  line=$(head -n 1 $filename.md)
#line variable take file's first line i will use these as fields name 
  filehead=(`echo $line | tr ":" "\n"`)
# i took the first line and these have ":" between them so i must change ":" to \n
#because i will put the screen them one under to other. 
	dialog --backtitle "Sort Table"\
               --radiolist "Please select field to sort:" 20 52 ${#filehead[@]}\
            $( for ((i=0; i<${#filehead[@]};i++)); do
	          echo "$i ${filehead[$i]} off"
  	       done ) 2>$_temp
#all fields are pressed the screen to select one of them
#program will sort the contents according the selected one.               

	lastline=$(tail -n 1 $filename.md)
#i took file's last line here.	
	filelast=(`echo $lastline | tr ":" "\n"`)
#lastline's have ":" between them.Here i change ":" to "\n"
#because i will put the screen them one under to other	
	result=`cat $_temp`

	let field+=$result

	if [[ ${filelast[$result]} =~ ^[0-9]+$ ]]; then
		content=`cat $filename.md | sort -n -t ':' -k $( echo $field )`
	else
		content=`cat $filename.md | sort -t ':' -k $( echo $field )`
	fi
#if token content is a numerical expression
#program accept ":" as a bracket 
#and sort it according numbers	
#unless again program accept ":" as a bracket and 
#sort it as alphabetical		

  if  [ `tail $filename.md | wc -l` -eq 1 ];then
  	dialog --msgbox "This table is empty" 8 52
    sort_table;
	else
		dialog --msgbox "`echo $content | sed 's/ /\n/g' | sed 's/:/ /g'`" 40 52
		sort_table;
  fi
#here file's last line is equal to 1, message box appear.
#Because if there is a line in the table,
# this line equal to fields name
#so we mustn't delete this field. 
#if table have more than one line 
#a message box appear and show us sorting content
}
helpy(){
dialog --colors --msgbox "
           \Z5\ZbHello welcome to helpy :)     
*\Z7Don't be afraid! Using this database is very easy      
*\Z6You can use arrow keys to go up-down-right-left.       
*\Z4On the selection menu's you can select  press spacebar.
*\Z3And certainly for confirm your selection press enter.  
*         \Z1Contact : seylul@bil.omu.edu.tr               
*         \Z2****       Best wishes     ****               " 15 60
              }

#message box give us some information about the program
#adding the color in my box i use the dialog command's ´colors´ option. 
menu;
