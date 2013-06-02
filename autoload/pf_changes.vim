let s:save_cpo = &cpo
set cpo&vim

function! s:get_change_num_from_changes(str) 
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
						\ 'action__chnum'  : s:get_change_num_from_changes(out),
						\ 'action__client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ 'action__out'    : out,
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
	let datas = []
	if a:context.source__client_flg == 1
		let datas = a:context.source__client
	endif


	let clients          = call('perforce#data#get_clients'          , datas)
	let ports            = call('perforce#data#get_ports'            , datas)
	let use_port_clients = call('perforce#data#get_use_port_clients' , datas)

	call s:get_port_clients(use_port_clients)

	" default�̕\��
	let candidates = []

	if a:status == 'pending'
		call extend(candidates, map( copy(use_port_clients), "{
					\ 'word'           : 'default by '.v:val,
					\ 'action__chnum'  : 'default',
					\ 'action__client' : v:val,
					\ 'action__depots' : a:context.source__depots,
					\ }"))
	endif

	let users   = perforce#data#get_users()
	let max     = perforce#data#get_max()

	for client in clients
		for user in users
			let cmd     = 'p4 changes '.user.''.client.''.max.'-s '.a:status
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
		let clients = s:get_port_clients()
		for client in clients
			call add(candidates, {
						\ 'word'           : '[new] '.client.'     : '.newfile,
						\ 'kind'           : 'k_p4_change_reopen',
						\ 'action__chname' : newfile,
						\ 'action__chnum'  : 'new',
						\ 'action__client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endif

	return candidates

endfunction
"}}}

function! pf_changes#make(strs, port_client, ...) "{{{
	"********************************************************************************
	" �`�F���W���X�g�̍쐬
	" @param[in]	str		�`�F���W���X�g�̃R�����g
	" @param[in]	...		�ҏW����`�F���W���X�g�ԍ�
	"********************************************************************************
	"
	"�`�F���W�ԍ��̃Z�b�g ( ���������邩 )
	let chnum     = get(a:,'1','')

	"ChangeList�̐ݒ�f�[�^���ꎞ�ۑ�����
	let cmd = 'p4 change -o '.chnum
	let tmp = system('p4 '.a:port_client. ' change -o '.chnum)

	" �V�K�쐬�̏ꍇ�́A�t�@�C�����܂܂Ȃ�
	if chnum == "" 
		let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') 
	endif

	"�R�����g�̕ҏW
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\n\w\+:\|$\)','','') 

	let outs = split(tmp, "\n")
	let i = 0

	while(outs[i]) !~ '^Description:'
		let i = i + 1
	endwhile

	let strs = map(copy(a:strs), "' '.v:val")
	let outs = extend(outs, strs, i+1)

	"�ꎞ�t�@�C���̏����o��
	call writefile(outs, perforce#get_tmp_file())

	" �`�F���W���X�g�̍쐬
	let  cmd = 'more '.perforce#get_kk(perforce#get_tmp_file()).' | p4 '.a:port_client.' change -i'
	echo cmd
	let out = split(system(cmd), "\n")

	return out

endfunction
"}}}
" === kind ===
function! pf_changes#make_new_changes(candidate) "{{{
" ********************************************************************************
" �`�F���W���X�g�̔ԍ��̎擾������ ( new �̏ꍇ�́A�V�K�쐬 )
" @param[in]	candidate	unite �̂���	
" @retval       chnum		�ԍ�
" ********************************************************************************

	let chnum       = a:candidate.action__chnum
	let port_client = pf_changes#get_port_client( a:candidate ) 

	if chnum == 'new'
		let chname = a:candidate.action__chname

		" �`�F���W���X�g�̍쐬
		let outs = pf_changes#make(chname, port_client)

		"�`�F���W���X�g�̐V�K�쐬�̌��ʂ���ԍ����擾����
		let chnum = outs[1]
	endif

	return chnum
endfunction
"}}}

let s:port_clients = perforce#data#get_use_port_clients()
function! s:get_port_clients(...) "{{{
	if exists('a:1')
		let s:port_clients = a:1
	endif
	return s:port_clients
endfunction
"}}}

function! s:get_client_from_change(candidate) 
	return matchstr(a:candidate.action__out, '@\zs\w*')
endfunction
function! pf_changes#get_port_client(candidate)  "{{{
	let port_client = a:candidate.action__client

	if port_client !~ '-c'
		let client = s:get_client_from_change(a:candidate)
		let port_client = port_client.' -c '.client
	endif

	return port_client
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
