function! unite#sources#p4_opened#define()
	return s:source
endfunction

" ********************************************************************************
" source - p4_opened 
" @param[in]	args		�\������`�F���W���X�g
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_opened',
			\ 'description' : '�ҏW���Ă���t�@�C���̕\�� ( �`�F���W���X�g�ԍ� )',
			\ }
function! s:getPathFromOpened(str) "{{{
	let dpath = a:str                           " # depot path
	let dpath = substitute(dpath,'#.*','','')   " # ���r�W�����ԍ��̍폜
	let path = <SID>get_path_from_depot(dpath) " # ���\�[�X�̃p�X�̎擾
	return path 
endfunction "}}}
function! s:get_DepotPath_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # ���r�W�����ԍ��̍폜
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	let cmds = len(a:args)
				\ ? map( a:args, "'p4 opened -c '.v:val") 
				\ : ['p4 opened']

	" depot���̎擾
	let outs = []
	for cmd in cmds
		let outs += okazu#Get_cmds(cmd)
	endfor

	" �ǉ��t�@�C�����Ɩ�肪��������
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_depot',
				\ 'action__depot' : <SID>get_DepotPath_from_opened(v:val)
				\ }")

	return candidates
endfunction "}}}
