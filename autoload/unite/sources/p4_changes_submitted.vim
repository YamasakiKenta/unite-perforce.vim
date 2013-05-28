let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_changes_submitted#define()
	return s:source_p4_changes_submitted
endfunction

let s:source_p4_changes_submitted = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit 済みチェンジリスト',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4change_describe',
			\ 'default_kind' : 'k_p4_change_submitted',
			\ }

let s:source_p4_changes_submitted.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source_p4_changes_submitted.gather_candidates(args, context)

	" 表示するクライアント名の取得
	if a:context.source__client_flg == 0
		let clients = perforce#data#get('g:unite_perforce_clients')
	else
		let clients = a:context.source__client
	endif

	let candidates = []

	let max = perforce#data#get('g:unite_perforce_show_max')
	if max > 0
		let max_str = '-m '.max.' '
	else
		let max_str = ''
	endif

	let users = perforce#data#get('g:unite_perforce_username')
	if len(users) == 0
		let users = ['']
	endif

	let data_ds = []

	for user in users
		if len(user) > 0
			let user_str = '-u '.user.' '
		else
			let user_str = ''
		endif
		let cmd = 'p4 changes '.max_str.''.user_str.'-s submitted'
		call extend(data_ds, perforce#cmd#clients(clients, cmd))
	endfor

	call extend(candidates, pf_changes#get(a:context, data_ds))
	return candidates
endfunction

call unite#define_source(s:source_p4_changes_submitted)

let &cpo = s:save_cpo
unlet s:save_cpo
