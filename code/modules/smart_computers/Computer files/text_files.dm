
/datum/file/text
	file_name = "MyPasswords"
	extension = ".txt"
	file_icon_state = "file_text"
	var/file_content = ""

/////////////
// Copy to //
/////////////
// Desc: Copies a file to a destination
// Used: File.Topic()

/datum/file/text/copy_to(var/mob/living/user, var/obj/item/smart_computer/storage/destination)
	var/datum/file/text/T = ..(user,destination)
	if(T)
		T.file_content = file_content
		T.file_stats |= file_stats
		T.file_size = file_size

/////////
// New //
/////////
// Desc: New
// Used: New instances

/datum/file/text/New()
	..()

	if(file_content)
		file_size = length(file_content)


