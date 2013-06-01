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
	let datas = []
	if a:context.source__client_flg == 1
		let datas = a:context.source__client
	endif


	let clients     = call('perforce#data#get_clients'          , datas)
	let ports       = call('perforce#data#get_ports'            , datas)
	let use_clients = call('perforce#data#get_use_port_clients' , datas)

	" default�̕\��
	let candidates = []

	if a:status == 'pending'
		call extend(candidates, map( copy(use_clients), "{
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
"
function! s:pf_change(str,...) "{{{
	"********************************************************************************
	" �`�F���W���X�g�̍쐬
	" @param[in]	str		�`�F���W���X�g�̃R�����g
	" @param[in]	...		�ҏW����`�F���W���X�g�ԍ�
	"********************************************************************************
	"
	"�`�F���W�ԍ��̃Z�b�g ( ���������邩 )
	let chnum     = get(a:,'1','')

	"ChangeList�̐ݒ�f�[�^���ꎞ�ۑ�����
	let tmp = system('p4 change -o '.chnum)                          

	"�R�����g�̕ҏW
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\nFiles:\)\?','\t'.a:str.'\n','') 

	" �V�K�쐬�̏ꍇ�́A�t�@�C�����܂܂Ȃ�
	if chnum == "" | let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') | endif

	"�ꎞ�t�@�C���̏����o��
	call writefile(split(tmp,'\n'),perforce#get_tmp_file())

	" �`�F���W���X�g�̍쐬
	" �� client �ɑΉ�����
	let out = split(system('more '.perforce#get_kk(perforce#get_tmp_file()).' | p4 '.a:client.'change -i', '\n'))

	return out

endfunction
"}}}
function! pf_changes#make_new_changes(candidate) "{{{
" ********************************************************************************
" �`�F���W���X�g�̔ԍ��̎擾������ ( new �̏ꍇ�́A�V�K�쐬 )
" @param[in]	candidate	unite �̂���	
" @retval       chnum		�ԍ�
" ********************************************************************************

	let chnum = a:candidate.action__chnum

	if chnum == 'new'
		let chname = a:candidate.action__chname

		" �`�F���W���X�g�̍쐬
		let outs = s:pf_change(chname)

		"�`�F���W���X�g�̐V�K�쐬�̌��ʂ���ԍ����擾����
		let chnum = outs[1]
	endif

	return chnum
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
