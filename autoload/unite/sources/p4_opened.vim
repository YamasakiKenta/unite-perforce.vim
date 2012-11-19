function! unite#sources#p4_opened#define()
	return s:source_p4_opened
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

	if len(a:args)
		" ����������ꍇ
		let tmps = map( a:args, "
					\ perforce#pfcmds_new('opened','','-c '.v:val)
					\ ")
	else
		" �������Ȃ��ꍇ
		let tmps = perforce#pfcmds_new('opened','','')
	endif

	" �ǉ��t�@�C�����Ɩ�肪��������
	let candidates = []
	for tmp in tmps
		let client = tmp.client
		call extend(candidates , map(tmp.outs, "{
					\ 'word'           : ''.client.' : '.v:val,
					\ 'kind'           : 'k_depot',
					\ 'action__depot'  : perforce#get_depot_from_opened(v:val),
					\ 'action__client' : client,
					\ }"))
	endfor

	return candidates
endfunction "}}}
let s:source_p4_opened = deepcopy(s:source)

"call unite#define_source(s:source_p4_opened) | unlet s:source_p4_opened
