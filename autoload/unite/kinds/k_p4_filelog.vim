let s:save_cpo = &cpo
set cpo&vim

let s:Tab = vital#of('unite-perforce.vim').import('Mind.Tab')
function! unite#kinds#k_p4_filelog#define()
	return s:kind
endfunction

functio! s:p4_print(candidates) "{{{
	let filetype_old = &filetype
	let files = []
	for l:candidate in deepcopy(a:candidates)

		let name = perforce#get_path_from_depot(candidate.action__depot)
		

		" �\������o�[�W�������擾����
		if exists('candidate.action__revnum')
			let file_numstr = '\#'.candidate.action__revnum
			let numstr      =  '#'.candidate.action__revnum
		elseif exists('candidate.action__chnum')
			let file_numstr =  '@'.candidate.action__chnum
			let numstr      =  '@'.candidate.action__chnum
		endif

		" �t�@�C�����o�͂���
		let strs = perforce#pfcmds('print','','-q '.perforce#common#get_kk(name.''.numstr)).outs
		let file = fnamemodify(name,':t').file_numstr

		call perforce#common#LogFile(file, 0, strs) 
		call add(files, file)

		" �f�[�^�̏o��
		exe 'setf' filetype_old

		quit

	endfor
	call s:Tab.open_files(files)
endfunction "}}}
" ********************************************************************************
" kind - k_p4_filelog
" ********************************************************************************
let s:kind = {
			\ 'name' : 'k_p4_filelog',
			\ 'default_action' : 'a_p4_print',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_print = {
			\ 'description' : '�t�@�C���̕\��',
			\ 'is_selectable' : 1, 
			\ }
functio! s:kind.action_table.a_p4_print.func(candidates) "{{{
	return s:p4_print(a:candidates)
endfunction "}}}

let s:kind.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0, 
			\ }
function! s:kind.action_table.preview.func(candidate) "{{{
	let l:candidate = a:candidate

	let name = perforce#get_path_from_depot(candidate.action__depot)

	let filetype_old = &filetype

	" �\������o�[�W�������擾����
	if exists('candidate.action__revnum')
		let file_numstr = '\#'.candidate.action__revnum
		let numstr      =  '#'.candidate.action__revnum
	elseif exists('candidate.action__chnum')
		let file_numstr =  '@'.candidate.action__chnum
		let numstr      =  '@'.candidate.action__chnum
	endif

	" �t�@�C�����o�͂���
	let strs = perforce#pfcmds('print','','-q '.perforce#common#get_kk(name.''.numstr)).outs
	let file = fnamemodify(name,':t').file_numstr

	call perforce#common#LogFile(file, 0, strs) 

	" �f�[�^�̏o��
	"exe 'setf' filetype_old
	wincmd p

endfunction "}}}

call unite#define_kind(s:kind)

let &cpo = s:save_cpo
unlet s:save_cpo

