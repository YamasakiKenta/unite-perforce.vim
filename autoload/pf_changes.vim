let s:save_cpo = &cpo
set cpo&vim

function! s:get_ChangeNum_from_changes(str) 
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction

function! pf_changes#get(context,data_ds)  "{{{
	" ********************************************************************************
	" @par          p4_changes Untie �p�� �Ԃ�l��Ԃ�
	" @param[in]	context
	" @param[in]	data_ds
	" ********************************************************************************
	let candidates = []
	for data_d in a:data_ds
		let client = data_d.client
		for out in data_d.outs
			call add( candidates, {
						\ 'word'           : client.' : '.out,
						\ 'action__chnum'  : s:get_ChangeNum_from_changes(out),
						\ 'action__client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endfor

	return candidates
endfunction
"}}}
function! pf_changes#gather_candidates(args, context, status)  "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕\�� �\���ݒ�֐�
	" �`�F���W���X�g�̕ύX�̏ꍇ�A�J��������t�@�C����ύX���邩�Aaction�Ŏw�肵���t�@�C��
	" @param[in]	args				depot
	" ********************************************************************************
	"
	" �\������N���C�A���g���̎擾
	if a:context.source__client_flg == 0
		let clients = perforce#data#get_clients()
		let ports   = perforce#data#get_ports()
	else
		let datas = a:context.source__client
		let clients = perforce#data#get_clients_from_arg(datas)
		let ports   = perforce#data#get_ports_from_arg(datas)
	endif


	" default�̕\��
	let candidates = []

	if a:status == 'pending'
		call extend(candidates, map( copy(clients), "{
					\ 'word'           : 'default by '.v:val,
					\ 'kind'           : 'k_p4_change_pending',
					\ 'action__chnum'  : 'default',
					\ 'action__client' : v:val,
					\ 'action__depots' : a:context.source__depots,
					\ }"))
	endif

	let users   = perforce#data#get_users()
	let max     = perforce#data#get_max()

	for client in clients
		for user in users
			let cmd = 'p4 changes '.user.''.client.''.max.'-s '.a:status
			let data_ds = perforce#cmd#clients(ports, cmd)
			call extend(candidates, pf_changes#get(a:context, data_ds))
		endfor
	endfor

	return candidates
endfunction
"}}}
function! pf_changes#change_candidates(args, context)  "{{{
	" ********************************************************************************
	" p4 change �\�[�X�� �ω��֐�
	" @param[in]	
	" @retval       
	" ********************************************************************************
	" Unite �œ��͂��ꂽ����
	let newfile = a:context.input
	let candidates = []

	" ���͂��Ȃ��ꍇ�́A�\�����Ȃ�
	if newfile != ""
		let clients = perforce#data#get_port_clients()
		for client in clients
			call add(candidates, {
						\ 'word' : '[new] '.client.' : '.newfile,
						\ 'kind' : 'k_p4_change_reopen',
						\ 'action__chname' : newfile,
						\ 'action__chnum' : 'new',
						\ 'action_client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endif

	return candidates

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
