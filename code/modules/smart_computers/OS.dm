
/datum/file/program/OS
	name = "LoseDos"
	extension = null
	file_icon_state = "OS"
	prog_desc	= "Jump to OS"
	var/list/OS_users = list() //List of usernames, Associatied with their Passwords
	var/last_login_fail = 0

/datum/file/program/OS/file_priviliges(var/mob/user)
	if(!login(user))
		return 0

///////////
// Login //
///////////
// massive login function, ugh

/datum/file/program/OS/proc/login(var/mob/user) //Gosh I hate this.
	if(!can_use(user))
		return 0

	var/login = 0
	var/login_fails = 0
	var/username
	var/found_user = 0
	var/password

	while(!login)
		if(last_login_fail+300 >= world.time)
			user << browse("Please Wait, Brute force login protection")
			return 0

		if(login_fails >= 3)
			last_login_fail = world.time
			login_fails = 0

		username = input(user,"Input your username (1-20 Chars)","Username") as text
		if(username)
			username = trim(copytext(sanitize(username), 1, 20))

		var/found_user = 0
		for(var/U in OS_users)
			if(U == username)
				found_user++
				break

		if(found_user)
			password = input(user,"Input your password (1-8 Chars)","Password") as text
			if(password)
				password = trim(copytext(sanitize(password), 1, 8))

			if(password && username)
				if(OS_users[username] == password)
					user << browse("Login succesful!")
					login++
				else
					user << browse("Login Error")
					login_fails++
			else
				login_fails++
		else
			user << browse("No such user: [username]")
			var/y_alert = alert(user,"Add user to database?","User Database","Yes","No")
			if(y_alert)
				switch(y_alert)
					if("Yes")
						var/n_pass = input(user, "Choose a password (1-8 Chars)","Password") as text
						if(n_pass)
							n_pass = trim(copytext(sanitize(n_pass),1,8))
							OS_users[username] = n_pass
					if("No")
						return 0

	return 1



/datum/file/program/OS/proc/boot(var/mob/user)
	if(!can_use(user))
	return 0