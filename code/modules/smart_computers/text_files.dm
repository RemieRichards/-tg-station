

////////////////
// Text Files //
////////////////

/datum/file/text
	name = "MyPasswords"
	extension = ".txt"
	file_icon_state = "file_text"
	var/file_content = ""

/datum/file/text/copy_to_device(var/mob/user)
	var/datum/file/text/T = ..(device)
	if(T)
		T.file_content = text
		T.file_stats |= file_stats
		T.file_size = file_size

/datum/file/text/New()
	..()

	if(file_content)
		file_size = length(file_content)


