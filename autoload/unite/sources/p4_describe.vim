let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_describe#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_describe',
			\ 'description' : '�T�u�~�b�g�ς݂̃`�F���W���X�g�̍�����\��',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	let chnums = a:args
	let outs = perforce#pfcmds('describe','',join(chnums)).outs
	return perforce#get_source_diff_from_diff(outs) 
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

