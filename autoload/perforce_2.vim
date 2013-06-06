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
	" @param[in]      = <`2`>
	" @return        <`3`> = <`4`>
	" ********************************************************************************
	call perforce#util#LogFile('p4show', 1, a:str)
endfunction
"}}}
"
let &cpo = s:save_cpo
unlet s:save_cpo
