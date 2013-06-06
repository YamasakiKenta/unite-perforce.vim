let s:save_cpo = &cpo
set cpo&vim

function! perforce_2#complate_have(A,L,P) "{{{
	"********************************************************************************
	" �⊮ : perforce ��ɑ��݂���t�@�C����\������
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
"}}}
function! perforce_2#edit_add(add_flg, ...) "{{{
	" ********************************************************************************
	" @par �ҏW��ԁA�������͒ǉ���Ԃɂ���
	" @param[in] a:add_flg = 1 - TREUE : �N���C�A���g�ɑ��݂��Ȃ��ꍇ�́A�t�@�C����ǉ�
	" @param[in] a:000     {�t�@�C����}     �l���Ȃ��ꍇ�́A���݂̃t�@�C����ҏW����
	" ********************************************************************************
	"
	let files_ = call('perforce#util#get_files', a:000)

	let data_ds = []
	let data_d = perforce#cmd#files('edit', files_, 1, 1)
	call extend(data_ds, data_d)
	if ( a:add_flg == 1 )
		let data_d = perforce#cmd#files('add', files_, 0, 1)
		call extend(data_ds, data_d)
	endif

	let outs = perforce#get#outs(data_ds)
endfunction
"}}}
function! perforce_2#revert(...) "{{{
	" ********************************************************************************
	" @param[in] �t�@�C����
	" ********************************************************************************
	let files_ = call('perforce#util#get_files', a:000)

	let data_ds = []
	call extend(data_ds, perforce#cmd#files('revert -a', files_, 0, 1))
	call extend(data_ds, perforce#cmd#files('revert'   , files_, 1, 1))

	let outs = perforce#get#outs(data_ds)

	call perforce#LogFile(outs)
endfunction 
"}}}
function! perforce_2#echo_error(message) "{{{
  echohl WarningMsg 
  echo a:message 
  echohl None
endfunction
"}}}
function! perforce_2#show(str) "{{{
	" ********************************************************************************
	" @par  �K����windows ��\������
	" ********************************************************************************
	call perforce#util#LogFile('p4show', 1, a:str)
endfunction
"}}}

function! s:get_args(default_key, args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @par �����^�ɕϊ�����
	"
	" @param[in]     a:default_key
	"  - ���X�g�^�̏ꍇ�̏ꍇ�ɐݒ肵�����L�[
	"
	" @param[in]     args
	"  - �ϊ�����ϐ�
	"
	" @return        data_ds
	" ********************************************************************************
	if len(a:args) == 0
		let data_ds = [{}]
	elseif type({}) == type(a:args[0])
		let data_ds = a:args
	else
		let data_ds = map(deepcopy(a:args), "{ a:default_key : v:val }")
	endif
	return data_ds
endfunction
"}}}
function! perforce_2#get_chnum_client(args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @param[in]      = <`2`>
	" @return        [{'num_' : 0, 'use_port_clients' : ['']}]
	" ********************************************************************************
	let data_ds = s:get_args('num_', a:args)

	let rtn_ds = []
	for data_d in data_ds
		if exists('data_d.num_')
			let num_ = '-c '.data_d.num_
		else
			let num_ = ''
		endif

		if exists('data_d.client')
			let use_port_clients = perforce#data#get_use_port_clients(data_d.client)
		else
			let use_port_clients = perforce#data#get_use_port_clients()
		endif

		call add(rtn_ds, {
					\ 'num_'            : num_,
					\ 'use_port_clients' : use_port_clients,
					\ })
	endfor

	return rtn_ds
endfunction
"}}}
let &cpo = s:save_cpo
unlet s:save_cpo
