let s:save_cpo = &cpo
set cpo&vim

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

	" �����̐ݒ�
	if len(a:args) > 0
		let datas = map(a:args, "'-c '.v:val")
	else 
		let datas = [""]
	endif

	let tmps = []
	for arg in datas
		call extend(tmps, perforce#cmd#new('opened', '', arg))
	endfor

	" �ǉ��t�@�C�����Ɩ�肪��������
	let candidates = []
	for tmp in tmps

		let client = tmp.client
		let tmps = map(tmp.outs, "{
					\ 'word'           : ''.client.' : '.v:val,
					\ 'kind'           : 'k_depot',
					\ 'action__depot'  : perforce#get#depot#from_opened(v:val),
					\ 'action__client' : client,
					\ }")
		call extend(candidates , tmps)
	endfor


	return candidates
endfunction
"}}}
let s:source_p4_opened = deepcopy(s:source)

call unite#define_source(s:source_p4_opened) 

let &cpo = s:save_cpo
unlet s:save_cpo

