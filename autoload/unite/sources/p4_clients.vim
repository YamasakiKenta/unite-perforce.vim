function! unite#sources#p4_clients#define()
	return [s:source_p4_clients , s:source_p4_all_clients]
endfunction

function! s:get_pfclients(str) "{{{
	" ********************************************************************************
	" �N���C�A���g��\������
	" @param[in]	str		�\���̐���
	" ********************************************************************************

	"�|�[�g�̃N���C�A���g��\������
	let datas = []
	for port in g:pf_ports
		let datas += map(perforce#cmds('-p '.port.' clients '.a:str), "{
					\ 'port' : port,
					\ 'client' : v:val,
					\ }")
	endfor

	let candidates = map(datas, "{
				\ 'word' : '-p '.v:val.port.' -c '.perforce#get_ClientName_from_client(v:val.client),
				\ 'kind' : 'k_p4_clients',
				\ 'action__clname' : perforce#get_ClientName_from_client(v:val.client),
				\ 'action__port' : v:val.port,
				\ }")
	return candidates
endfunction "}}}

let s:source = {
			\ 'name' : 'p4_clients',
			\ 'default_action' : 'a_p4_client_set',
			\ 'description' : '�N���C�A���g�̕\��',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	return <SID>get_pfclients(perforce#get_PFUSER_for_pfcmd()) 
endfunction "}}}
let s:source_p4_clients = s:source
unlet s:source

let s:source = {
			\ 'name' : 'p4_all_clients',
			\ 'default_action' : 'a_p4_client_info',
			\ 'description' : '�S�ẴN���C�A���g�̕\��',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	return <SID>get_pfclients(" ")
endfunction "}}}
let s:source_p4_all_clients = s:source
unlet s:source
