let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_opened#define()
	return s:source_p4_opened
endfunction

" ********************************************************************************
" source - p4_opened 
" @param[in]	args		�\������`�F���W���X�g
" ********************************************************************************
let s:source_p4_opened = {
			\ 'name' : 'p4_opened',
			\ 'description' : '�ҏW���Ă���t�@�C���̕\�� ( �`�F���W���X�g�ԍ� )',
			\ 'is_quit' : 0,
			\ }


function! s:source_p4_opened.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" @param[in]     a:args[] = NULL,
	"                           0,
	"                           {'chnum' : 1, 'client' : '-p localhost:1818' }:
	" ********************************************************************************
	" �����̐ݒ�
	let data_ds = perforce_2#get_args('chnum', a:args)

	let tmps = []
	for data_d in data_ds
		if exists('data_d.chnum')
			let chnum = '-c '.data_d['chnum']
		else
			let chnum = ''
		endif

		if exists('data_d.client')
			call extend(tmps, perforce#cmd#clients([data_d.client], 'opened', '', chnum))
		else
			call extend(tmps, perforce#cmd#new('opened', '', chnum))
		endif
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

call unite#define_source(s:source_p4_opened) 

let &cpo = s:save_cpo
unlet s:save_cpo

