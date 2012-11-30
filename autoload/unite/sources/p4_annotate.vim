let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_annotate#define()
	return [ 
				\ s:source__p4_annotate,
				\ s:source__p4_annotate_ai,
				\ ]
endfunction

function! s:getRevisionNumFromAnnotate(str) "{{{
	return substitute(a:str,'^\(\d\+\).*','\1','')
endfunction "}}}
function! s:get_chnum_from_annotate(str) "{{{
	let low  = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\1', '')
	let high = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\2', '')

	return {
				\ 'low' : low,
				\ 'high' : high,
				\ }
endfunction "}}}

let s:source = {
			\ 'name' : 'p4_annotate',
			\ 'description' : '�e�s�Ƀ��r�W�����ԍ���\��',
			\ 'hooks' : {},
			\ }
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')


function! s:source.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	let lnum = 1
	for depot in depots 
		let outs = perforce#pfcmds('annotate','',perforce#common#get_kk(depot)).outs

		for out in outs
		let candidates += map( [out], "{
					\ 'word' : lnum.' : '.v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__depot' : depot,
					\ 'action__revnum' : s:getRevisionNumFromAnnotate(v:val),
					\ }")
		let lnum += 1
	endfor

	return candidates
endfunction "}}}
let s:source__p4_annotate = deepcopy(s:source)

let s:source = {
			\ 'name' : 'p4_annotate_ai',
			\ 'description' : '�e�s�Ƀ`�F���W���X�g�ԍ���\�� ( �S�� )',
			\ 'hooks' : {},
			\ }
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')
function! s:source.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	for depot in depots 

		let outs = perforce#pfcmds('annotate','','-ai '.perforce#common#get_kk(depot)).outs

		let candidates += map( outs, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__depot' : depot,
					\ 'action__chnum' : s:get_chnum_from_annotate(v:val),
					\ }")
	endfor

	return candidates
endfunction "}}}
let s:source__p4_annotate_ai = deepcopy(s:source)

let &cpo = s:save_cpo
unlet s:save_cpo

