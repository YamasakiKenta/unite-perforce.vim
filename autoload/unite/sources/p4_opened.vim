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
			\ 'is_quit' : 0,
			\ }
function! s:source.gather_candidates(args, context) "{{{

	let outs = []
	if len(a:args)
		" ����������ꍇ
		for arg in a:args
			let outs += perforce#pfcmds('opened','','-c '.arg)
		endfor
	else
		" �������Ȃ��ꍇ
		let outs += perforce#pfcmds('opened','')
	endif

	" �ǉ��t�@�C�����Ɩ�肪��������
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_depot',
				\ 'action__depot' : <SID>get_DepotPath_from_opened(v:val)
				\ }")

	return candidates
endfunction "}}}

"================================================================================
" sub routine
"================================================================================
function! s:get_DepotPath_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # ���r�W�����ԍ��̍폜
endfunction "}}}
