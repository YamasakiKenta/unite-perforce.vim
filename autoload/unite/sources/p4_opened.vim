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
function! s:get_DepotPath_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # ���r�W�����ԍ��̍폜
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" �N���C�A���g or �ʏ�
	let cmds = len(a:args)
				\ ? map( a:args, "'opened -c '.v:val") 
				\ : ['opened']

	" depot���̎擾
	let outs = []
	for cmd in cmds
		let outs += perforce#cmds(cmd)
	endfor

	" �ǉ��t�@�C�����Ɩ�肪��������
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_depot',
				\ 'action__depot' : <SID>get_DepotPath_from_opened(v:val)
				\ }")

	return candidates
endfunction "}}}
