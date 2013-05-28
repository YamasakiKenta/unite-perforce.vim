let s:_file  = expand("<sfile>")
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('Unite-perforce.vim')
let s:Perforce = s:V.import('Mind.Perforce')
"
"
function! unite#kinds#k_p4_clients#define()
	return s:kind_clients
endfunction

function! s:get_client_path_from_name(str) 
	let str  = system('p4 clients | grep '.a:str) " # ref ���ڃf�[�^�����炤���@�͂Ȃ�����
	let path = str
	let path = matchstr(path,'.* \d\d\d\d/\d\d/\d\d root \zs\S*')
	let path = substitute((path, '\\', '\/', 'g')
	return path
endfunction

" ********************************************************************************
" kind - k_p4_clients
" ********************************************************************************
let s:kind_clients = {
			\ 'name' : 'k_p4_clients',
			\ 'default_action' : 'a_p4_client',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4', 'common'],
			\}
call unite#define_kind(s:kind_clients)

let s:kind_clients.action_table.a_p4_client_set = {
			\ 'description' : '�N���C�A���g�̕ύX', 
			\ }
function! s:kind_clients.action_table.a_p4_client_set.func(candidates) "{{{

	" �ۑ����閼�O�̎擾
	let clname = a:candidates.action__clname
	let port   = matchstr(a:candidates.action__port, '\(-p\s*\)*\zs.*')
	let clpath = s:get_client_path_from_name(clname)

	" �쐬����t�@�C���̖��O�̕ۑ� ( �؂�ւ� ) 
	call perforce#set#PFCLIENTNAME(clname)
	call perforce#set#PFPORT(port)
	call s:Perforce.get_client_root(1)

endfunction
"}}}

let s:kind_clients.action_table.a_p4_client_sync = { 
			\'is_selectable' : 1,
			\'description' : '�ŐV����', 
			\}
function! s:kind_clients.action_table.a_p4_client_sync.func(candidates) "{{{
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port
		exe '!start p4 '.port.' -c '.clname.' sync'
	endfor
endfunction
"}}}

let s:kind_clients.action_table.a_p4_client_info = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�N���C�A���g�̏�� ( info ) ',
			\ }
function! s:kind_clients.action_table.a_p4_client_info.func(candidates) "{{{
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = matchstr(l:candidate.action__port, '\(-p\s*\)*\zs.*')

		" �e�N���C�A���g���Ƃɕ\������
		call perforce#common#LogFile(port.'_'.clname, 0)
		let outs = perforce#cmd#base('info', port.' -c '.clname).outs
		call append(0,outs)
	endfor
endfunction
"}}}

let s:kind_clients.action_table.a_p4_client = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�N���C�A���g�̏�� ( client )',
			\ }
function! s:kind_clients.action_table.a_p4_client.func(candidates) "{{{
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port

		" �e�N���C�A���g���Ƃɕ\������
		call perforce#common#LogFile(clname, 0)
		let outs = perforce#cmd#base('client', port, '-o '.clname).outs
		call append(0,outs)
	endfor
endfunction
"}}}

if 1
	call unite#define_kind(s:kind_clients)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

