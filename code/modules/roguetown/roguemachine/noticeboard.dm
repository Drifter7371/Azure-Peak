/obj/structure/roguemachine/noticeboard
	name = "Notice Board"
	desc = "A large wooden notice board, carrying postings from all across Azurea. A ZAD perch sits atop it."
	icon = 'icons/roguetown/misc/64x64.dmi'
	icon_state = "noticeboard"
	density = TRUE
	anchored = TRUE
	max_integrity = 0
	blade_dulling = DULLING_BASH
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	var/current_category = "Postings"
	var/list/categories = list("Postings", "Premium Postings")

/obj/structure/roguemachine/boardbarrier //Blocks sprite locations
	name = ""
	desc = "A large wooden notice board, carrying postings from all across Azurea. A ZAD perch sits atop it."
	icon = 'icons/roguetown/underworld/underworld.dmi'
	icon_state = "spiritpart"
	density = TRUE
	anchored = TRUE

/obj/structure/roguemachine/noticeboard/Initialize()
	. = ..()
	SSroguemachine.noticeboards += src

/datum/noticeboardpost
	var/title
	var/truepostername
	var/posterstitle
	var/poster
	var/message
	var/banner

/obj/structure/roguemachine/noticeboard/examine(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return
	if(user in GLOB.board_viewers)
		return
	else
		GLOB.board_viewers += user
		to_chat(user, span_smallred("A new posting has been made since I last checked!"))


/obj/structure/roguemachine/noticeboard/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user)) return
	var/mob/living/carbon/human/guy = user
	var/list/noticemenu = list("Check Posts", "Make a Posting", "Remove Posting")
	if(user.job in list("Man at Arms","Inquisitor", "Knight", "Sergeant", "Knight Captain", "Orthodoxist"))
		noticemenu += "Authoritative Removal"
	if(user.job in list("Bathmaster","Merchant", "Innkeeper", "Steward", "Court Magician"))
		noticemenu += "Make a Premium Posting"
	var/selection = input(user, "What shall I do...", src) as null|anything in noticemenu
	switch(selection)
		if("Check Posts")
			check_postings(guy)
			GLOB.board_viewers += guy
		if("Make a Premium Posting")
			premium_post(guy)
		if("Make a Posting")
			make_post(guy)
		if("Remove Posting")
			remove_post(guy)
		if("Authoritative Removal")
			authority_removepost(guy)

/obj/structure/roguemachine/noticeboard/proc/check_postings(mob/living/carbon/human/user)
	var/check_menu
	var/post_found = FALSE
	check_menu += "<center>POSTINGS<BR>"
	check_menu += "--------------<BR>"
	var/list/noticeboards = list("Premium", "Normal")
	var/selection = input(user, "Which board shall I view...", src) as null|anything in noticeboards
	switch(selection)
		if("Normal")
			for(var/datum/noticeboardpost/saved_post in GLOB.noticeboard_posts)
				check_menu += saved_post.banner
				post_found = TRUE
			if(post_found)
				var/datum/browser/popup = new(user, "COMMUNITY POSTS", "", 800, 500)
				popup.set_content(check_menu)
				popup.open()
			else
				to_chat(user, ("No one has made any postings..."))
		if("Premium")
			for(var/datum/noticeboardpost/saved_post in GLOB.premium_noticeboardposts)
				check_menu += saved_post.banner
				post_found = TRUE
			if(post_found)
				var/datum/browser/popup = new(user, "PREMIUM POSTS", "", 800, 500)
				popup.set_content(check_menu)
				popup.open()
			else
				to_chat(user, ("No one has made any postings..."))


/obj/structure/roguemachine/noticeboard/proc/premium_post(mob/living/carbon/human/guy)
	if(guy.has_status_effect(/datum/status_effect/debuff/postcooldown))
		to_chat(guy, span_warning("I must wait a time until my next posting..."))
		return
	var/inputtitle = input(guy, "What shall the title of my posting be?", "NOTICEBOARD", null)
	if(!inputtitle)
		return
	var/inputmessage = stripped_multiline_input(guy, "What shall I write for this posting?", "NOTICEBOARD", no_trim=TRUE)
	if(inputmessage)
		if(length(inputmessage) > 2000)
			to_chat(guy, span_warning("Too long! You shall surely overburden the with this novel!"))
			return
	else
		return
	var/inputname = input(guy, "What name shall I use on the posting?", "NOTICEBOARD", null)
	if(!inputname)
		return
	var/inputrole = input(guy, "What personal title shall I use on the posting?", "NOTICEBOARD", null)
	add_post(inputmessage, inputtitle, inputname, inputrole, guy.real_name, TRUE)
	guy.apply_status_effect(/datum/status_effect/debuff/postcooldown)
	message_admins("[ADMIN_LOOKUPFLW(guy)] has made a notice board post. The message was: [inputmessage]")
	for(var/obj/structure/roguemachine/noticeboard/board in SSroguemachine.noticeboards)
		if(board != src)
			playsound(board, 'sound/ambience/noises/birds (7).ogg', 50, FALSE, -1)
			board.visible_message(span_smallred("A ZAD lands, delivering a new posting!"))



/obj/structure/roguemachine/noticeboard/proc/make_post(mob/living/carbon/human/guy)
	if(guy.has_status_effect(/datum/status_effect/debuff/postcooldown))
		to_chat(guy, span_warning("I must wait a time until my next posting..."))
		return
	var/inputtitle = stripped_input(guy, "What shall the title of my posting be?", "NOTICEBOARD", null)
	if(!inputtitle)
		return
	if(length(inputtitle) > 50)
		to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
		return
	var/inputmessage = stripped_multiline_input(guy, "What shall I write for this posting?", "NOTICEBOARD", no_trim=TRUE)
	if(inputmessage)
		if(length(inputmessage) > 2000)
			to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
			return
	else
		return
	var/inputname = stripped_input(guy, "What name shall I use on the posting?", "NOTICEBOARD", null)
	if(!inputname)
		return
	if(length(inputname) > 50)
		to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
		return
	var/inputrole = stripped_input(guy, "What personal title shall I use on the posting?", "NOTICEBOARD", null)
	if(length(inputrole) > 50)
		to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
		return
	add_post(inputmessage, inputtitle, inputname, inputrole, guy.real_name, FALSE)
	guy.apply_status_effect(/datum/status_effect/debuff/postcooldown)
	message_admins("[ADMIN_LOOKUPFLW(guy)] has made a notice board post. The message was: [inputmessage]")
	for(var/obj/structure/roguemachine/noticeboard/board in SSroguemachine.noticeboards)
		if(board != src)
			playsound(board, 'sound/ambience/noises/birds (7).ogg', 50, FALSE, -1)
			board.visible_message(span_smallred("A ZAD lands, delivering a new posting!"))


/obj/structure/roguemachine/noticeboard/proc/remove_post(mob/living/carbon/human/guy)
	var/list/myposts_list = list()
	for(var/datum/noticeboardpost/removable_posts in GLOB.noticeboard_posts)
		if(removable_posts.truepostername == guy.real_name)
			myposts_list += removable_posts.title
	for(var/datum/noticeboardpost/removable_postspremium in GLOB.premium_noticeboardposts)
		if(removable_postspremium.truepostername == guy.real_name)
			myposts_list += removable_postspremium.title
	if(!myposts_list.len)
		to_chat(guy, span_warning("There are no posts I can take down."))
		return
	var/post2remove = input(guy, "Which post shall I take down?", src) as null|anything in myposts_list
	if(!post2remove)
		return
	playsound(loc, 'sound/foley/dropsound/paper_drop.ogg', 50, FALSE, -1)
	loc.visible_message(span_smallred("[guy] tears down a posting!"))
	for(var/datum/noticeboardpost/removing_post in GLOB.noticeboard_posts)
		if(post2remove == removing_post.title && removing_post.truepostername == guy.real_name)
			GLOB.noticeboard_posts -= removing_post
			message_admins("[ADMIN_LOOKUPFLW(guy)] has removed their post, the message was [removing_post.message]")
	for(var/datum/noticeboardpost/removing_post in GLOB.premium_noticeboardposts)
		if(post2remove == removing_post.title && removing_post.truepostername == guy.real_name)
			GLOB.premium_noticeboardposts -= removing_post
			message_admins("[ADMIN_LOOKUPFLW(guy)] has removed their post, the message was [removing_post.message]")

/obj/structure/roguemachine/noticeboard/proc/authority_removepost(mob/living/carbon/human/guy)
	var/list/posts_list = list()
	for(var/datum/noticeboardpost/removable_posts in GLOB.noticeboard_posts)
		posts_list += removable_posts.title
	if(!posts_list.len)
		to_chat(guy, span_warning("There are no posts I can take down."))
		return
	var/post2remove = input(guy, "Which post shall I take down?", src) as null|anything in posts_list
	if(!post2remove)
		return
	playsound(loc, 'sound/foley/dropsound/paper_drop.ogg', 50, FALSE, -1)
	loc.visible_message(span_smallred("[guy] tears down a posting!"))
	for(var/datum/noticeboardpost/removing_post in GLOB.noticeboard_posts)
		if(post2remove == removing_post.title)
			GLOB.noticeboard_posts -= removing_post
			message_admins("[ADMIN_LOOKUPFLW(guy)] has authoritavely removed a post, the message was [removing_post.message]")



/proc/add_post(message, chosentitle, chosenname, chosenrole, truename, premium)
	var/datum/noticeboardpost/new_post = new /datum/noticeboardpost
	new_post.poster = chosenname
	new_post.title = chosentitle
	new_post.message = message
	new_post.posterstitle = chosenrole
	new_post.truepostername = truename
	compose_post(new_post)
	GLOB.board_viewers = list()
	if(!premium)
		GLOB.noticeboard_posts += new_post
	else
		GLOB.premium_noticeboardposts += new_post



/proc/compose_post(datum/noticeboardpost/new_post)
	new_post.banner += "<center><b>[new_post.title]</b><BR>"
	new_post.banner += "[new_post.message]<BR>"
	new_post.banner += "- [new_post.poster]"
	if(new_post.posterstitle)
		new_post.banner += ", [new_post.posterstitle]"
	new_post.banner += "<BR>"
	new_post.banner += "--------------<BR>"


/datum/status_effect/debuff/postcooldown
	id = "postcooldown"
	duration = 5 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/debuff/postcooldown

/atom/movable/screen/alert/status_effect/debuff/postcooldown
	name = "Recent messenger"
	desc = "I'll have to wait a bit before making another posting!"
