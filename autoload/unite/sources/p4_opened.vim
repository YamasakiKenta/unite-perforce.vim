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
			let outs += perforce#pfcmds_for_unite('opened','','-c '.arg).outs
		endfor
	else
		" �������Ȃ��ꍇ
		let outs += perforce#pfcmds_for_unite('opened','').outs
	endif

	" �ǉ��t�@�C�����Ɩ�肪��������
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_depot',
				\ 'action__depot' : perforce#get_depot_from_opened(v:val)
				\ }")

	return candidates
endfunction "}}}
