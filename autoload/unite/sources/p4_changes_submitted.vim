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

	" pf_changes#gather_candidates と同じ

	" 表示するクライアント名の取得
	if a:context.source__client_flg == 0
		let clients = perforce#data#get('g:unite_perforce_clients')
	else
		let clients = a:context.source__client
	endif

	let candidates = []

	let users          = perforce#data#get_users()
	let noport_clients = perforce#data#get_noport_clients_from_arg(clients)
	let ports          = perforce#data#get_ports_from_arg(clients)
	let max            = perforce#data#get_max()

	for noport_client in noport_clients
		for user in users
			let cmd = 'p4 changes '.max.''.user.'-s submitted'
			let data_ds = perforce#cmd#clients(clients, cmd)
			call extend(candidates, pf_changes#get(a:context, data_ds))
		endfor
	endfor

	return candidates
endfunction

call unite#define_source(s:source_p4_changes_submitted)

let &cpo = s:save_cpo
unlet s:save_cpo
